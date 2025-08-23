#!/bin/bash

# データベース安全リセットスクリプト
# データダンプ → リセット → マイグレーション → データ復元

set -e

echo "🔄 データベース安全リセット開始..."

# タイムスタンプ
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups"
DATA_BACKUP="$BACKUP_DIR/data_backup_$TIMESTAMP.sql"
SCHEMA_BACKUP="$BACKUP_DIR/schema_backup_$TIMESTAMP.sql"

# バックアップディレクトリ作成
mkdir -p $BACKUP_DIR

echo "📁 バックアップディレクトリ作成完了"

# 1. データダンプ (データのみ)
echo "💾 データダンプ中..."
npx supabase db dump --data-only --file $DATA_BACKUP

# 2. スキーマダンプ (念のため)
echo "🏗️ スキーマダンプ中..."
npx supabase db dump --schema-only --file $SCHEMA_BACKUP

echo "✅ バックアップ完了:"
echo "   データ: $DATA_BACKUP"
echo "   スキーマ: $SCHEMA_BACKUP"

# 3. データベースリセット
echo "🔄 データベースリセット中..."
npx supabase db reset

# 4. データ復元
echo "📥 データ復元中..."
# 復元時にエラーが発生する可能性があるため、エラーを無視して続行
set +e
psql "postgresql://postgres:postgres@127.0.0.1:54322/postgres" -f $DATA_BACKUP
RESTORE_EXIT_CODE=$?
set -e

if [ $RESTORE_EXIT_CODE -eq 0 ]; then
    echo "✅ データ復元完了"
else
    echo "⚠️ データ復元中に一部エラーが発生しましたが処理を続行します"
    echo "   バックアップファイル: $DATA_BACKUP"
    echo "   手動復元が必要な場合があります"
fi

echo "🎉 データベース安全リセット完了！"
echo ""
echo "📋 作成されたバックアップファイル:"
echo "   $DATA_BACKUP"
echo "   $SCHEMA_BACKUP"
