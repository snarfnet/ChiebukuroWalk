#!/bin/bash
# おばあちゃんの知恵袋ウォーク - Mac Mini 完全セットアップ＆提出スクリプト
#
# 使い方:
#   1. Mac Miniでこのリポジトリをクローン
#      git clone https://github.com/snarfnet/ChiebukuroWalk.git
#   2. このスクリプトを実行
#      cd ChiebukuroWalk && chmod +x setup_and_submit.sh && ./setup_and_submit.sh

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$PROJECT_DIR/ChiebukuroWalk.xcodeproj"
SCHEME="ChiebukuroWalk"
ARCHIVE_PATH="$PROJECT_DIR/build/ChiebukuroWalk.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build/export"

echo "========================================="
echo " おばあちゃんの知恵袋ウォーク"
echo " Mac Mini ビルド＆提出スクリプト"
echo "========================================="
echo ""

# Step 0: Xcode check
echo "[0/6] Xcode確認..."
if ! command -v xcodebuild &> /dev/null; then
    echo "ERROR: Xcodeがインストールされていません"
    exit 1
fi
XCODE_VER=$(xcodebuild -version | head -1)
echo "  $XCODE_VER"

# Step 1: Clean
echo "[1/6] クリーン..."
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME" -quiet 2>/dev/null || true

# Step 2: Resolve dependencies
echo "[2/6] ビルド確認..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
    -destination "generic/platform=iOS" \
    -quiet \
    build 2>&1 | tail -5

# Step 3: Archive
echo "[3/6] アーカイブ中..."
mkdir -p "$PROJECT_DIR/build"
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -quiet

echo "  アーカイブ完了: $ARCHIVE_PATH"

# Step 4: Create ExportOptions.plist
echo "[4/6] ExportOptions生成中..."
cat > "$PROJECT_DIR/build/ExportOptions.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>83VGKGSQUH</string>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
PLIST

# Step 5: Export & Upload to App Store Connect
echo "[5/6] App Store Connectにアップロード中..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$PROJECT_DIR/build/ExportOptions.plist" \
    -exportPath "$EXPORT_PATH" \
    -quiet

# Step 6: Done
echo "[6/6] 完了！"
echo ""
echo "========================================="
echo " アップロード成功！"
echo "========================================="
echo ""
echo "App Store Connect (https://appstoreconnect.apple.com) で以下を設定："
echo ""
echo "  アプリ名: おばあちゃんの知恵袋ウォーク"
echo "  サブタイトル: 歩いて集める日本の生活の知恵2000"
echo "  カテゴリ: ヘルスケア/フィットネス"
echo "  価格: 無料"
echo "  対象年齢: 4+"
echo ""
echo "  プライバシーポリシーURL:"
echo "    https://snarfnet.github.io/ChiebukuroWalk/privacy.html"
echo ""
echo "  サポートURL:"
echo "    https://snarfnet.github.io/ChiebukuroWalk/support.html"
echo ""
echo "  App内課金:"
echo "    Product ID: com.chiebukurowalk.premium"
echo "    種類: 非消耗型"
echo "    価格: ¥120"
echo "    表示名: プレミアム版"
echo "    説明: 知恵袋の解放が5,000歩→1,000歩に短縮"
echo ""
echo "  説明文・キーワードは docs/appstore_metadata.txt を参照"
echo ""
echo "  スクリーンショットはシミュレータで撮影してアップロード"
echo "========================================="
