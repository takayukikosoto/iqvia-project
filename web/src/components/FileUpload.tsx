import React, { useState, useRef } from 'react'

interface FileUploadProps {
  onFileUpload: (file: File, description?: string) => Promise<string | null>
  loading?: boolean
}

export default function FileUpload({ onFileUpload, loading = false }: FileUploadProps) {
  const [description, setDescription] = useState('')
  const [isDragging, setIsDragging] = useState(false)
  const [uploading, setUploading] = useState(false)
  const fileInputRef = useRef<HTMLInputElement>(null)

  const handleFileSelect = async (files: FileList | null) => {
    if (!files || files.length === 0) return

    const file = files[0]
    setUploading(true)
    
    try {
      await onFileUpload(file, description || undefined)
      setDescription('')
      if (fileInputRef.current) fileInputRef.current.value = ''
    } catch (error) {
      console.error('Upload failed:', error)
    } finally {
      setUploading(false)
    }
  }

  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(true)
  }

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
  }

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault()
    setIsDragging(false)
    handleFileSelect(e.dataTransfer.files)
  }

  const isDisabled = loading || uploading

  return (
    <div className="mb-6 p-6 bg-white rounded-xl shadow-sm border border-gray-200/50 hover:shadow-md transition-shadow duration-200">
      <div className="flex items-center space-x-2 mb-4">
        <div className="p-2 bg-blue-50 rounded-lg flex-shrink-0">
          <svg className="w-5 h-5 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16a4 4 0 01-.88-7.903A5 5 0 1115.9 6L16 6a5 5 0 011 9.9M15 13l-3-3m0 0l-3 3m3-3v12" />
          </svg>
        </div>
        <h3 className="text-lg font-semibold text-gray-900">ファイルアップロード</h3>
      </div>
      
      <div className="mb-4">
        <input
          type="text"
          placeholder="ファイルの説明を入力..."
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          className="w-full px-4 py-3 border border-gray-200 rounded-lg text-sm focus:outline-none focus:ring-2 focus:ring-blue-500/20 focus:border-blue-500 transition-colors bg-gray-50/50 hover:bg-white"
        />
      </div>

      <div
        className={`border-2 border-dashed rounded-xl p-8 text-center transition-all duration-200 min-h-[200px] flex flex-col justify-center ${
          isDragging 
            ? 'border-blue-400 bg-blue-50/70 scale-[1.02]' 
            : 'border-gray-200 hover:border-blue-300 hover:bg-blue-50/30'
        } ${isDisabled ? 'opacity-50 cursor-not-allowed' : 'cursor-pointer group'}`}
        onDragEnter={(e) => handleDragOver(e)}
        onDragLeave={handleDragLeave}
        onDragOver={handleDragOver}
        onDrop={handleDrop}
        onClick={() => !isDisabled && fileInputRef.current?.click()}
      >
        <input
          ref={fileInputRef}
          type="file"
          className="hidden"
          onChange={(e) => handleFileSelect(e.target.files)}
          disabled={isDisabled}
        />
        
        {uploading ? (
          <div className="flex items-center justify-center space-x-3">
            <div className="relative">
              <div className="w-6 h-6 border-3 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
            </div>
            <span className="text-sm font-medium text-gray-700">アップロード中...</span>
          </div>
        ) : (
          <div className="space-y-3">
            <div className="text-5xl group-hover:scale-110 transition-transform duration-200">📁</div>
            <div className="space-y-1">
              <p className="text-base font-medium text-gray-700">
                ファイルをドラッグ&ドロップするか、<span className="text-blue-600 font-semibold">クリックして選択</span>
              </p>
              <p className="text-sm text-gray-500">すべてのファイルタイプをサポート</p>
            </div>
          </div>
        )}
      </div>
    </div>
  )
}
