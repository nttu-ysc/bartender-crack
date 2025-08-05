#!/bin/bash

set -e

# Binary 與安裝目標
BINARY_NAME="bartender_crack"
INSTALL_DIR="$HOME/bartender-crack"
PLIST_NAME="com.shun.bartender_crack.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME"

echo "===== Bartender Crack 安裝程式 ====="
echo "請輸入你想排程執行的時間："
read -p "小時（0-23）： " HOUR
read -p "分鐘（0-59）： " MINUTE

# 驗證輸入是否為合法數字
if ! [[ "$HOUR" =~ ^[0-9]{1,2}$ ]] || [ "$HOUR" -lt 0 ] || [ "$HOUR" -gt 23 ]; then
    echo "❌ 錯誤：無效的『小時』輸入"
    exit 1
fi

if ! [[ "$MINUTE" =~ ^[0-9]{1,2}$ ]] || [ "$MINUTE" -lt 0 ] || [ "$MINUTE" -gt 59 ]; then
    echo "❌ 錯誤：無效的『分鐘』輸入"
    exit 1
fi

echo "[1] 安裝執行檔到 $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp "$BINARY_NAME" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"

echo "[2] 建立 plist 檔案到 $PLIST_DEST..."

mkdir -p "$(dirname "$PLIST_DEST")"

cat > "$PLIST_DEST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/$BINARY_NAME</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>$HOUR</integer>
        <key>Minute</key>
        <integer>$MINUTE</integer>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/${BINARY_NAME}.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/${BINARY_NAME}.err</string>
</dict>
</plist>
EOF

echo "[3] 啟用 launchctl 排程..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo "[✓] 安裝完成！將於每天 $HOUR:$MINUTE 自動執行。"
