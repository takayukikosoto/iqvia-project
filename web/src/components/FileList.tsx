import React, { useState } from 'react'
import { FileItem, FileVersion } from '../hooks/useFiles'
import FileVersionUpload from './FileVersionUpload'

interface FileListProps {
  files: FileItem[]
  loading: boolean
  onDownload: (filePath: string, fileName: string) => void
  onDelete: (fileId: string, storagePath?: string) => void
  onGetVersions: (fileId: string) => Promise<FileVersion[]>
  onUploadNewVersion: (fileId: string, file: File, changeNotes?: string) => Promise<boolean>
}

export default function FileList({ files, loading, onDownload, onDelete, onGetVersions, onUploadNewVersion }: FileListProps) {
  const [expandedFile, setExpandedFile] = useState<string | null>(null)
  const [versions, setVersions] = useState<Record<string, FileVersion[]>>({})
  const [loadingVersions, setLoadingVersions] = useState<Record<string, boolean>>({})
  const [showVersionUpload, setShowVersionUpload] = useState<string | null>(null)

  const formatFileSize = (bytes: number): string => {
    if (bytes === 0) return '0 B'
    const k = 1024
    const sizes = ['B', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  }

  const getFileIcon = (fileType?: string, mimeType?: string) => {
    if (fileType === 'image' || mimeType?.startsWith('image/')) return '🖼️'
    if (fileType === 'video' || mimeType?.startsWith('video/')) return '🎥'
    if (fileType === 'audio' || mimeType?.startsWith('audio/')) return '🎵'
    if (fileType === 'document' || mimeType?.includes('pdf')) return '📄'
    return '📁'
  }

  const handleToggleVersions = async (fileId: string) => {
    if (expandedFile === fileId) {
      setExpandedFile(null)
      return
    }

    setExpandedFile(fileId)
    
    if (!versions[fileId]) {
      setLoadingVersions(prev => ({ ...prev, [fileId]: true }))
      try {
        const fileVersions = await onGetVersions(fileId)
        setVersions(prev => ({ ...prev, [fileId]: fileVersions }))
      } catch (error) {
        console.error('Failed to load versions:', error)
      } finally {
        setLoadingVersions(prev => ({ ...prev, [fileId]: false }))
      }
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-8">
        <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-600"></div>
        <span className="ml-2 text-sm text-gray-600">ファイル読み込み中...</span>
      </div>
    )
  }

  if (files.length === 0) {
    return (
      <div className="bg-white rounded-xl border border-gray-200/50 p-12">
        <div className="text-center">
          <div className="w-16 h-16 mx-auto mb-4 bg-gray-100 rounded-full flex items-center justify-center">
            <svg className="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
            </svg>
          </div>
          <h3 className="text-lg font-medium text-gray-900 mb-2">ファイルがありません</h3>
          <p className="text-gray-500">ファイルをアップロードして開始しましょう</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center space-x-2 mb-6">
        <div className="p-2 bg-emerald-50 rounded-lg">
          <svg className="w-5 h-5 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
          </svg>
        </div>
        <h3 className="text-lg font-semibold text-gray-900">プロジェクトファイル ({files.length})</h3>
      </div>
      
      {files.map((file) => (
        <div key={file.id} className="bg-white border border-gray-200/50 rounded-xl hover:shadow-md transition-shadow duration-200">
          <div className="p-6">
            <div className="flex items-center justify-between">
              <div className="flex items-center space-x-4">
                <div className="w-12 h-12 bg-blue-50 rounded-lg flex items-center justify-center">
                  <svg className="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                </div>
                <div>
                  <h4 className="font-semibold text-gray-900 text-base">{file.name}</h4>
                  <div className="text-sm text-gray-500 flex items-center space-x-4 mt-1">
                    <span className="px-2 py-1 bg-gray-100 rounded text-xs font-medium">{formatFileSize(file.total_size_bytes || 0)}</span>
                    <span>{new Date(file.created_at).toLocaleDateString('ja-JP')}</span>
                    {file.total_versions && file.total_versions > 1 && (
                      <span className="px-2 py-1 bg-blue-100 text-blue-700 rounded text-xs font-medium">v{file.total_versions}</span>
                    )}
                  </div>
                </div>
              </div>
              
              <div className="flex items-center space-x-2">
                <button
                  onClick={() => handleToggleVersions(file.id)}
                  className="px-4 py-2 text-sm font-medium text-gray-600 bg-gray-100 hover:bg-gray-200 rounded-lg transition-colors duration-200"
                >
                  履歴
                  <svg className="w-4 h-4 ml-1 inline" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                  </svg>
                </button>
                <button
                  onClick={() => onDownload(file.storage_path || '', file.name)}
                  className="px-4 py-2 text-sm font-semibold bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors duration-200 flex items-center space-x-1"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 10v6m0 0l-3-3m3 3l3-3m2 8H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                  </svg>
                  <span>ダウンロード</span>
                </button>
                <button
                  onClick={() => setShowVersionUpload(file.id)}
                  className="px-4 py-2 text-sm font-medium text-emerald-600 bg-emerald-50 hover:bg-emerald-100 rounded-lg transition-colors duration-200 flex items-center space-x-1"
                >
                  <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 6v6m0 0v6m0-6h6m-6 0H6" />
                  </svg>
                  <span>新バージョン</span>
                </button>
              </div>
            </div>
            
            {file.description && (
              <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                <p className="text-sm text-gray-600">{file.description}</p>
              </div>
            )}
          </div>

          {/* Version History */}
          {expandedFile === file.id && (
            <div className="border-t bg-gray-50 p-4">
              <h5 className="font-medium text-gray-700 mb-2">バージョン履歴</h5>
              
              {loadingVersions[file.id] ? (
                <div className="flex items-center text-sm text-gray-600">
                  <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-blue-600 mr-2"></div>
                  履歴読み込み中...
                </div>
              ) : versions[file.id] && versions[file.id].length > 0 ? (
                <div className="space-y-2">
                  {versions[file.id].map((version) => (
                    <div key={version.id} className="flex items-center justify-between bg-white p-3 rounded border">
                      <div>
                        <div className="font-medium text-sm">
                          v{version.version_number || version.version} - {version.name || file.name}
                        </div>
                        <div className="text-xs text-gray-500">
                          {version.size_bytes && formatFileSize(version.size_bytes)} • 
                          {new Date(version.created_at || version.uploaded_at || '').toLocaleString('ja-JP')}
                        </div>
                        {version.change_notes && (
                          <div className="text-xs text-gray-600 mt-1">変更点: {version.change_notes}</div>
                        )}
                      </div>
                      <button
                        onClick={() => version.storage_path && onDownload(version.storage_path, version.name || file.name)}
                        className="px-2 py-1 text-xs bg-blue-100 hover:bg-blue-200 text-blue-700 rounded"
                        disabled={!version.storage_path}
                      >
                        📥
                      </button>
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-gray-500">バージョン履歴がありません</p>
              )}
            </div>
          )}
        </div>
      ))}
      
      {/* Version Upload Modal */}
      {showVersionUpload && (
        <FileVersionUpload
          fileId={showVersionUpload}
          fileName={files.find(f => f.id === showVersionUpload)?.name || ''}
          currentVersion={files.find(f => f.id === showVersionUpload)?.total_versions || 1}
          onVersionUpload={onUploadNewVersion}
          onCancel={() => setShowVersionUpload(null)}
        />
      )}
    </div>
  )
}
