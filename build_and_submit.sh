#!/bin/bash
# おばあちゃんの知恵袋ウォーク - ビルド＆提出スクリプト
# Mac Miniで実行してください

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT="$PROJECT_DIR/ChiebukuroWalk.xcodeproj"
SCHEME="ChiebukuroWalk"
ARCHIVE_PATH="$PROJECT_DIR/build/ChiebukuroWalk.xcarchive"
EXPORT_PATH="$PROJECT_DIR/build/export"

echo "========================================="
echo "おばあちゃんの知恵袋ウォーク ビルドスクリプト"
echo "========================================="

# Step 1: Clean
echo ""
echo "[1/5] クリーン..."
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME" -quiet

# Step 2: Archive
echo "[2/5] アーカイブ中..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -quiet

echo "  アーカイブ完了: $ARCHIVE_PATH"

# Step 3: Create ExportOptions.plist
echo "[3/5] ExportOptions生成中..."
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

# Step 4: Export & Upload
echo "[4/5] App Store Connectにアップロード中..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$PROJECT_DIR/build/ExportOptions.plist" \
    -exportPath "$EXPORT_PATH" \
    -quiet

echo "[5/5] 完了！"
echo ""
echo "========================================="
echo "アップロード成功！"
echo "App Store Connectで以下を設定してください："
echo "  1. スクリーンショット（6.7インチ、6.5インチ）"
echo "  2. アプリの説明文（docs/appstore_metadata.txt参照）"
echo "  3. プライバシーポリシーURL"
echo "  4. サポートURL"
echo "  5. App内課金の設定（com.chiebukurowalk.premium ¥120）"
echo "  6. 審査に提出"
echo "========================================="
