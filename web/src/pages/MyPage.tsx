import React from 'react'
import { useAuth } from '../hooks/useAuth'
import { useUserRoles } from '../hooks/useUserRoles'
import AdminMyPage from '../components/mypage/AdminMyPage'
import ProjectManagerMyPage from '../components/mypage/ProjectManagerMyPage'
import MemberMyPage from '../components/mypage/MemberMyPage'

export default function MyPage() {
  const { user } = useAuth()
  const { userRoles, loading } = useUserRoles()

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  if (!user) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-500">ログインが必要です</p>
      </div>
    )
  }

  // ロール別にコンポーネントを表示
  if (userRoles.isAdmin) {
    return <AdminMyPage />
  } else if (userRoles.isProjectManager) {
    return <ProjectManagerMyPage />
  } else {
    return <MemberMyPage />
  }
}
