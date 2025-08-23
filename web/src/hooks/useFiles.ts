import { useState, useEffect } from 'react'
import { supabase } from '../supabaseClient'

export interface FileItem {
  id: string
  project_id: string
  name: string
  description?: string
  file_type?: string
  mime_type?: string
  storage_path?: string
  external_id?: string
  external_url?: string
  current_version?: number
  current_version_id?: string
  total_versions: number
  total_size_bytes: number
  created_by?: string
  updated_by?: string
  created_at: string
  updated_at?: string
}

export interface FileVersion {
  id: string
  file_id: string
  version?: number
  version_number?: number
  name?: string
  size_bytes?: number
  checksum?: string
  storage_key?: string
  storage_path?: string
  external_id?: string
  upload_status?: string
  change_notes?: string
  uploaded_at?: string
  created_by?: string
  created_at?: string
}

export function useFiles(projectId: string, taskId?: string) {
  const [files, setFiles] = useState<FileItem[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // ファイル一覧取得
  const fetchFiles = async () => {
    // projectIdが空の場合は何もしない
    if (!projectId || projectId.trim() === '') {
      setLoading(false)
      setFiles([])
      return
    }

    setLoading(true)
    try {
      if (taskId) {
        // タスクIDが指定されている場合はデータベースから取得（task_idを使用）
        const { data, error } = await supabase
          .from('files')
          .select('*')
          .eq('project_id', projectId)
          .eq('task_id', taskId)
          .order('created_at', { ascending: false })

        if (error) throw error
        setFiles(data || [])
      } else {
        // プロジェクトベースの従来クエリ（task_idを使わない）
        const { data, error } = await supabase
          .from('files')
          .select('*')
          .eq('project_id', projectId)
          .order('created_at', { ascending: false })

        if (error) throw error
        setFiles(data || [])
      }
    } catch (err) {
      console.error('Error fetching files:', err)
      setError(err instanceof Error ? err.message : 'Failed to fetch files')
    } finally {
      setLoading(false)
    }
  }

  // ファイルアップロード
  const uploadFile = async (file: File): Promise<string | null> => {
    try {
      const fileName = `${Date.now()}_${file.name.replace(/[^a-zA-Z0-9._-]/g, '_')}`
      
      let bucket = 'files'
      let filePath = `${projectId}/${fileName}`

      console.log('🔍 Upload debug - Initial state:', { 
        taskId, 
        projectId, 
        fileName, 
        defaultBucket: bucket, 
        defaultPath: filePath 
      })

      // タスクIDが指定されている場合はタスク専用ストレージを使用
      if (taskId) {
        console.log('📁 Task detected, fetching storage_folder for taskId:', taskId)
        
        // タスクのstorage_folderを取得
        const { data: taskData, error: taskError } = await supabase
          .from('tasks')
          .select('storage_folder')
          .eq('id', taskId)
          .single()

        console.log('📂 Task data response:', { taskData, taskError })

        if (taskData?.storage_folder) {
          bucket = 'task-files'
          filePath = `${taskData.storage_folder}/${fileName}`
          console.log('✅ Using task-files bucket:', { bucket, filePath })
        } else {
          console.log('⚠️ No storage_folder found, using default bucket')
        }
      }

      console.log('📤 Attempting upload to:', { bucket, filePath })

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from(bucket)
        .upload(filePath, file)

      if (uploadError) {
        console.error('❌ Storage upload error:', uploadError)
        throw uploadError
      }

      console.log('✅ Upload successful:', { uploadData, bucket, path: uploadData.path })

      // 2. ファイルメタデータをDBに保存
      const { data: fileData, error: fileError } = await supabase
        .from('files')
        .insert({
          project_id: projectId,
          task_id: taskId || null,
          name: file.name,
          provider: 'supabase',
          storage_path: uploadData.path,
          current_version: 1,
          created_by: (await supabase.auth.getUser()).data.user?.id
        })
        .select()
        .single()

      if (fileError) throw fileError

      // 3. 初回バージョンをfile_versionsに追加
      const { data: { user } } = await supabase.auth.getUser()
      console.log('👤 Current user for file_versions:', { userId: user?.id, userEmail: user?.email })

      const { error: versionError } = await supabase
        .from('file_versions')
        .insert({
          file_id: fileData.id,
          version: 1,
          version_number: 1,
          size_bytes: file.size,
          storage_key: uploadData.path,
          storage_path: uploadData.path,
          created_by: user?.id
        })

      if (versionError) throw versionError

      // 4. ファイルの合計サイズを更新
      const { error: updateError } = await supabase
        .from('files')
        .update({
          total_size_bytes: file.size,
          total_versions: 1
        })
        .eq('id', fileData.id)

      if (updateError) throw updateError

      // 5. ファイル一覧を再取得
      await fetchFiles()
      
      return fileData.id
    } catch (err) {
      console.error('Error uploading file:', err)
      setError(err instanceof Error ? err.message : 'Failed to upload file')
      return null
    }
  }

  // ファイルダウンロード
  const downloadFile = async (filePath: string, fileName: string) => {
    try {
      console.log('Attempting to download file:', { filePath, fileName })
      
      if (!filePath || filePath.trim() === '') {
        throw new Error('ファイルパスが指定されていません')
      }

      // パスの前後のスラッシュを正規化
      const normalizedPath = filePath.replace(/^\/+|\/+$/g, '')
      console.log('Normalized path:', normalizedPath)

      // タスクファイルかどうかでバケットを判定
      const bucket = taskId ? 'task-files' : 'files'

      const { data, error } = await supabase.storage
        .from(bucket)
        .download(normalizedPath)

      if (error) {
        console.error('Storage download error:', error)
        
        // 具体的なエラー情報をログに出力
        console.error('Error details:', {
          message: error.message,
          path: normalizedPath,
          error: error
        })
        
        // より詳細なエラーメッセージを提供
        throw new Error(`ファイルダウンロードに失敗しました: ${error.message || 'ファイルが見つからない可能性があります'}`)
      }

      // ブラウザでダウンロード
      const url = URL.createObjectURL(data)
      const a = document.createElement('a')
      a.href = url
      a.download = fileName
      document.body.appendChild(a)
      a.click()
      document.body.removeChild(a)
      URL.revokeObjectURL(url)
      
      console.log('File download completed successfully')
    } catch (err) {
      console.error('Error downloading file:', err)
      setError(err instanceof Error ? err.message : 'Failed to download file')
    }
  }

  // ファイル削除
  const deleteFile = async (fileId: string, storagePath?: string) => {
    try {
      // 1. Storageからファイル削除
      if (storagePath) {
        const { error: storageError } = await supabase.storage
          .from('files')
          .remove([storagePath])
        
        if (storageError) console.warn('Storage deletion error:', storageError)
      }

      // 2. DBからファイル削除（CASCADE でfile_versionsも削除される）
      const { error } = await supabase
        .from('files')
        .delete()
        .eq('id', fileId)

      if (error) throw error

      // 3. ファイル一覧を再取得
      await fetchFiles()
    } catch (err) {
      console.error('Error deleting file:', err)
      setError(err instanceof Error ? err.message : 'Failed to delete file')
    }
  }

  // ファイルバージョン履歴取得
  const getFileVersions = async (fileId: string): Promise<FileVersion[]> => {
    try {
      const { data, error } = await supabase
        .from('file_versions')
        .select('*')
        .eq('file_id', fileId)
        .order('version_number', { ascending: false })

      if (error) throw error
      return data || []
    } catch (err) {
      console.error('Error fetching file versions:', err)
      return []
    }
  }

  // 新バージョンアップロード
  const uploadNewVersion = async (fileId: string, file: File, changeNotes?: string): Promise<boolean> => {
    try {
      // 1. 現在のファイル情報を取得
      const { data: fileData, error: fileError } = await supabase
        .from('files')
        .select('*')
        .eq('id', fileId)
        .single()

      if (fileError) throw fileError

      // 2. 新しいバージョン番号を計算
      const newVersionNumber = (fileData.total_versions || 1) + 1

      // 3. Supabase Storageにファイルアップロード
      const fileExt = file.name.split('.').pop()
      const fileName = `${Date.now()}_v${newVersionNumber}.${fileExt}`
      // 既存ファイルのパスから適切なフォルダを判定
      const isTaskFile = fileData.storage_path?.includes('/task_')
      const filePath = isTaskFile 
        ? `${fileData.project_id}/${fileData.storage_path.split('/').slice(1, 2).join('/')}/${fileName}`
        : `${fileData.project_id}/${fileName}`

      const { data: uploadData, error: uploadError } = await supabase.storage
        .from('files')
        .upload(filePath, file)

      if (uploadError) throw uploadError

      // 4. 新バージョンをfile_versionsに追加
      const { data: versionData, error: versionError } = await supabase
        .from('file_versions')
        .insert({
          file_id: fileId,
          version: newVersionNumber,
          version_number: newVersionNumber,
          name: file.name,
          storage_path: uploadData.path,
          size_bytes: file.size,
          upload_status: 'completed',
          change_notes: changeNotes,
          created_by: (await supabase.auth.getUser()).data.user?.id
        })
        .select()
        .single()

      if (versionError) throw versionError

      // 5. ファイルのメタデータを更新
      const { error: updateError } = await supabase
        .from('files')
        .update({
          current_version_id: versionData.id,
          total_versions: newVersionNumber,
          total_size_bytes: (fileData.total_size_bytes || 0) + file.size,
          storage_path: uploadData.path, // 最新バージョンのパスを更新
          updated_by: (await supabase.auth.getSession()).data.session?.user?.id
        })
        .eq('id', fileId)

      if (updateError) throw updateError

      // 6. ファイル一覧を再取得
      await fetchFiles()
      
      return true
    } catch (err) {
      console.error('Error uploading new version:', err)
      setError(err instanceof Error ? err.message : 'Failed to upload new version')
      return false
    }
  }

  // ファイルタイプ判定
  const getFileType = (mimeType: string): string => {
    if (mimeType.startsWith('image/')) return 'image'
    if (mimeType.startsWith('video/')) return 'video'
    if (mimeType.startsWith('audio/')) return 'audio'
    if (mimeType.includes('pdf') || mimeType.includes('document') || mimeType.includes('text')) return 'document'
    return 'other'
  }

  useEffect(() => {
    fetchFiles()
  }, [projectId])

  return {
    files,
    loading,
    error,
    uploadFile,
    uploadNewVersion,
    downloadFile,
    deleteFile,
    getFileVersions,
    refetch: fetchFiles
  }
}
