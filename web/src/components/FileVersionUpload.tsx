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
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = (files: FileList | null) => {
    if (!files || files.length === 0) return
    setSelectedFile(files[0])
  }

  const handleSave = async () => {
    if (!selectedFile) return
    
    setUploading(true)
    try {
      const success = await onVersionUpload(fileId, selectedFile, changeNotes || undefined)
      if (success) {
        onCancel() // Close modal on success
      }
    } catch (error) {
      console.error('Version upload failed:', error)
    } finally {
      setUploading(false)
    }
  }

  const handleReset = () => {
    setSelectedFile(null)
    setChangeNotes('')
    if (fileInputRef.current) {
      fileInputRef.current.value = ''
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
          
          {selectedFile ? (
            /* ファイル選択済みのプレビュー表示 */
            <div className="border-2 border-green-200 bg-green-50 rounded-lg p-4">
              <div className="flex items-center">
                <div className="text-green-600 mr-3">
                  <svg className="w-8 h-8" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                  </svg>
                </div>
                <div className="flex-1">
                  <div className="font-medium text-sm text-green-800">{selectedFile.name}</div>
                  <div className="text-xs text-green-600">
                    {(selectedFile.size / 1024).toFixed(1)} KB • {selectedFile.type || '不明なタイプ'}
                  </div>
                </div>
                <button
                  onClick={handleReset}
                  className="ml-2 px-2 py-1 text-xs text-red-600 bg-red-100 hover:bg-red-200 rounded transition-colors"
                  disabled={uploading}
                >
                  削除
                </button>
              </div>
            </div>
          ) : (
            /* ファイル選択エリア */
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
              
              <div className="text-gray-400 mb-1">
                <svg className="mx-auto h-8 w-8" stroke="currentColor" fill="none" viewBox="0 0 48 48">
                  <path d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02" strokeWidth={2} strokeLinecap="round" strokeLinejoin="round" />
                </svg>
              </div>
              <p className="text-sm text-gray-600">
                ファイルを選択してください
              </p>
              <p className="text-xs text-gray-500 mt-1">
                選択後、内容を確認してから保存できます
              </p>
            </div>
          )}
        </div>

        <div className="flex justify-end space-x-3">
          <button
            onClick={onCancel}
            className="px-4 py-2 text-sm text-gray-700 bg-gray-100 hover:bg-gray-200 rounded-md transition-colors"
            disabled={uploading}
          >
            キャンセル
          </button>
          
          {selectedFile ? (
            /* ファイル選択済み - 保存ボタン表示 */
            <>
              <button
                onClick={handleReset}
                className="px-4 py-2 text-sm text-gray-700 bg-white hover:bg-gray-50 border border-gray-300 rounded-md transition-colors"
                disabled={uploading}
              >
                ファイル変更
              </button>
              <button
                onClick={handleSave}
                className="px-4 py-2 text-sm bg-green-600 hover:bg-green-700 text-white rounded-md transition-colors flex items-center"
                disabled={uploading}
              >
                {uploading ? (
                  <>
                    <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-white mr-2"></div>
                    保存中...
                  </>
                ) : (
                  <>
                    <svg className="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M5 13l4 4L19 7" />
                    </svg>
                    新バージョンを保存
                  </>
                )}
              </button>
            </>
          ) : (
            /* ファイル未選択 - ファイル選択ボタン表示 */
            <button
              onClick={() => fileInputRef.current?.click()}
              className="px-4 py-2 text-sm bg-blue-600 hover:bg-blue-700 text-white rounded-md transition-colors"
              disabled={uploading}
            >
              ファイル選択
            </button>
          )}
        </div>
      </div>
    </div>
  )
}
