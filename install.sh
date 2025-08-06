#!/bin/bash

set -e

# --- Self-locating script --- 
# Get the absolute path of the script itself, regardless of where it's run from
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# 目標執行檔與安裝路徑
DEST_BINARY_NAME="bartender_crack"
INSTALL_DIR="$HOME/.bartender-crack"
PLIST_NAME="com.shun.bartender_crack.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME"

# 偵測系統架構
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
    SOURCE_BINARY_NAME="bartender_crack_arm"
elif [ "$ARCH" = "x86_64" ]; then
    SOURCE_BINARY_NAME="bartender_crack_amd"
else
    echo "❌ 錯誤：不支援的系統架構: $ARCH"
    read -p "按 Enter 鍵結束..."
    exit 1
fi

# 使用腳本的絕對路徑來定位來源執行檔
SOURCE_BINARY_PATH="$SCRIPT_DIR/$SOURCE_BINARY_NAME"

# 檢查對應的執行檔是否存在
if [ ! -f "$SOURCE_BINARY_PATH" ]; then
    echo "❌ 錯誤：找不到執行檔 '$SOURCE_BINARY_PATH'。"
    echo "請先執行 'make all' 或 'make build' 來編譯。"
    echo
    read -p "按 Enter 鍵結束..."
    exit 1
fi

echo "===== Bartender Crack 安裝程式 ($ARCH) ====="
echo "請輸入你想排程執行的時間："
read -p "小時（0-23）： " HOUR
read -p "分鐘（0-59）： " MINUTE

# 驗證輸入是否為合法數字
if ! [[ "$HOUR" =~ ^[0-9]{1,2}$ ]] || [ "$HOUR" -lt 0 ] || [ "$HOUR" -gt 23 ]; then
    echo "❌ 錯誤：無效的『小時』輸入"
    read -p "按 Enter 鍵結束..."
    exit 1
fi

if ! [[ "$MINUTE" =~ ^[0-9]{1,2}$ ]] || [ "$MINUTE" -lt 0 ] || [ "$MINUTE" -gt 59 ]; then
    echo "❌ 錯誤：無效的『分鐘』輸入"
    read -p "按 Enter 鍵結束..."
    exit 1
fi

echo "正在移除執行檔的隔離屬性以避免系統警告..."
xattr -d com.apple.quarantine "$SOURCE_BINARY_PATH" 2>/dev/null || true

echo "[1] 從 $SOURCE_BINARY_NAME 安裝執行檔到 $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp "$SOURCE_BINARY_PATH" "$INSTALL_DIR/$DEST_BINARY_NAME"
chmod +x "$INSTALL_DIR/$DEST_BINARY_NAME"

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
        <string>$INSTALL_DIR/$DEST_BINARY_NAME</string>
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
    <string>/tmp/${DEST_BINARY_NAME}.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/${DEST_BINARY_NAME}.err</string>
</dict>
</plist>
EOF

echo "[3] 啟用 launchctl 排程..."
launchctl unload "$PLIST_DEST" 2>/dev/null || true
launchctl load "$PLIST_DEST"

echo
echo "[✓] 安裝完成！將於每天 $HOUR:$MINUTE 自動執行。"
echo
read -p "✅ 設定成功！請按 Enter 鍵關閉此視窗..."