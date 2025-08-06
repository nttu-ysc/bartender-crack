#!/bin/bash

set -e

echo "===== Bartender Crack 解除安裝程式 ====="

# 目標執行檔與安裝路徑
DEST_BINARY_NAME="bartender_crack"
INSTALL_DIR="$HOME/.bartender-crack"
PLIST_NAME="com.shun.bartender_crack.plist"
PLIST_DEST="$HOME/Library/LaunchAgents/$PLIST_NAME"
LOG_PATH="/tmp/${DEST_BINARY_NAME}.log"
ERR_PATH="/tmp/${DEST_BINARY_NAME}.err"

echo "[1] 正在停用 launchctl 排程..."
if [ -f "$PLIST_DEST" ]; then
    launchctl unload "$PLIST_DEST" 2>/dev/null || true
    echo "排程已停用。"
else
    echo "找不到 plist 檔案，可能已被移除。"
fi

echo "[2] 正在刪除 plist 檔案..."
if [ -f "$PLIST_DEST" ]; then
    rm -f "$PLIST_DEST"
    echo "plist 檔案已刪除。"
else
    echo "找不到 plist 檔案，無需刪除。"
fi

echo "[3] 正在刪除安裝目錄..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    echo "安裝目錄 '$INSTALL_DIR' 已刪除。"
else
    echo "找不到安裝目錄，無需刪除。"
fi

echo "[4] 正在刪除日誌檔案..."
rm -f "$LOG_PATH" "$ERR_PATH"
echo "日誌檔案已刪除。"

echo
echo "[✓] 解除安裝完成！"
echo
read -p "✅ 操作成功！請按 Enter 鍵關閉此視窗..."
