#!/bin/bash

# Stop on first error
set -e

# --- Configuration ---
# Installation directory in the user's home
INSTALL_DIR="$HOME/.bartender-crack"
# Name of the binary
BINARY_NAME="bartender_crack"
# The name for the service (used in plist)
PLIST_LABEL="com.shun.bartender_crack"
# Path to the plist file
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"

# --- Helper Functions ---
function print_success() {
  echo "✅  $1"
}

function print_info() {
  echo "ℹ️  $1"
}

function print_warning() {
  echo "⚠️  $1"
}

function print_error() {
  echo "❌  $1" >&2
}

# --- Main Script ---
echo "--- Bartender Crack 解除安裝程式 ---"
print_info "此腳本將會移除 Bartender Crack 的所有相關檔案和設定。"

# 1. Unload launchctl service
print_info "正在停用 launchctl 排程服務..."
if [ -f "$PLIST_PATH" ]; then
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    print_success "排程服務已停用。"
else
    print_warning "找不到 plist 檔案 ($PLIST_PATH)，可能已被移除或從未安裝。"
fi

# 2. Delete plist file
print_info "正在刪除 plist 檔案 ($PLIST_PATH)..."
if [ -f "$PLIST_PATH" ]; then
    rm -f "$PLIST_PATH"
    print_success "plist 檔案已刪除。"
else
    print_warning "找不到 plist 檔案，無需刪除。"
fi

# 3. Delete installation directory
print_info "正在刪除安裝目錄 ($INSTALL_DIR)..."
if [ -d "$INSTALL_DIR" ]; then
    rm -rf "$INSTALL_DIR"
    print_success "安裝目錄 '$INSTALL_DIR' 已刪除。"
else
    print_warning "找不到安裝目錄，無需刪除。"
fi

# 4. Delete log files (if they were created in the install directory)
print_info "正在刪除日誌檔案..."
LOG_FILE="$INSTALL_DIR/${BINARY_NAME}.log"
ERR_FILE="$INSTALL_DIR/${BINARY_NAME}.err"

if [ -f "$LOG_FILE" ]; then
    rm -f "$LOG_FILE"
    print_success "日誌檔案 '$LOG_FILE' 已刪除。"
else
    print_warning "找不到日誌檔案 '$LOG_FILE'，無需刪除。"
fi

if [ -f "$ERR_FILE" ]; then
    rm -f "$ERR_FILE"
    print_success "錯誤日誌檔案 '$ERR_FILE' 已刪除。"
else
    print_warning "找不到錯誤日誌檔案 '$ERR_FILE'，無需刪除。"
fi

echo ""
print_success "--- 解除安裝完成！ ---"
echo ""