import React, { useState, useRef } from 'react'

interface FileVersionUploadProps {
  fileId: string
  fileName: string
  currentVersion: number
  onVersionUpload: (fileId: string, file: File, changeNotes?: string) => Promise<boolean>
  onCancel: () => void
}

export default function FileVersionUpload({ 
  fileId, 
  fileName, 
  currentVersion, 
  onVersionUpload, 
  onCancel 
}: FileVersionUploadProps) {
  const [changeNotes, setChangeNotes] = useState('')
  const [uploading, setUploading] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = async (files: FileList | null) => {
    if (!files || files.length === 0) return

    const file = files[0]
    setUploading(true)
    
    try {
      const success = await onVersionUpload(fileId, file, changeNotes || undefined)
      if (success) {
        onCancel() // Close modal on success
      }
    } catch (error) {
      console.error('Version upload failed:', error)
    } finally {
      setUploading(false)
    }
  }

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center p-4 z-50">
      <div className="bg-white rounded-lg max-w-md w-full p-6">
        <h3 className="text-lg font-medium mb-4">
          新バージョンアップロード
        </h3>
        
        <div className="mb-4 p-3 bg-gray-50 rounded">
          <div className="text-sm font-medium">現在のファイル</div>
          <div className="text-sm text-gray-600">{fileName}</div>
          <div className="text-xs text-gray-500">現在のバージョン: v{currentVersion}</div>
        </div>

        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            変更内容・理由
          </label>
          <textarea
            value={changeNotes}
            onChange={(e) => setChangeNotes(e.target.value)}
            placeholder="このバージョンで何が変更されましたか？"
            className="w-full px-3 py-2 border border-gray-300 rounded-md text-sm resize-none"
            rows={3}
            disabled={uploading}
          />
        </div>

        <div className="mb-6">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            新しいファイル
          </label>
          <div
            className={`border-2 border-dashed rounded-lg p-4 text-center transition-colors ${
              uploading ? 'opacity-50 pointer-events-none' : 'cursor-pointer hover:border-gray-400'
            }`}
            onClick={() => !uploading && fileInputRef.current?.click()}
          >
            <input
              ref={fileInputRef}
              type="file"
              className="hidden"
              onChange={(e) => handleFileSelect(e.target.files)}
              disabled={uploading}
            />
            
            {uploading ? (
              <div className="flex items-center justify-center">
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-blue-600"></div>
                <span className="ml-2 text-sm text-gray-600">アップロード中...</span>
              </div>
            ) : (
              <>
                <div className="text-gray-400 mb-1">
                  <svg className="mx-auto h-8 w-8" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                    <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                  </svg>
                </div>
                <p className="text-sm text-gray-600">
                  ファイルを選択してアップロード
                </p>
              </>
            )}
          </div>
        </div>

        <div className="flex justify-end space-x-3">
          <button
            onClick={onCancel}
            className="px-4 py-2 text-sm text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors"
            disabled={uploading}
          >
            キャンセル
          </button>
          <button
            onClick={() => fileInputRef.current?.click()}
            className="px-4 py-2 text-sm bg-blue-600 hover:bg-blue-700 text-white rounded-md transition-colors"
            disabled={uploading}
          >
            {uploading ? 'アップロード中...' : 'ファイル選択'}
          </button>
        </div>
      </div>
    </div>
  )
}
