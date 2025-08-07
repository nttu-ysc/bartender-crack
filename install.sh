#!/bin/bash

# Stop on first error
set -e

# --- Determine script's own directory ---
# This ensures that the script can find the binary file, even when run from Finder.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# --- Configuration ---
# Installation directory in the user's home
INSTALL_DIR="$HOME/.bartender-crack"
# Name of the binary
BINARY_NAME="bartender_crack"
# The name for the service (used in plist)
PLIST_LABEL="com.shun.bartender_crack"
# Path to the plist file
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"

# GitHub Release Configuration
GITHUB_REPO="nttu-ysc/bartender-crack"
RELEASE_VERSION="v0.0.3"
DOWNLOAD_URL_BASE="https://github.com/${GITHUB_REPO}/releases/download/${RELEASE_VERSION}"

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

# --- Cleanup Function ---
TEMP_DIR="" # Initialize TEMP_DIR globally
function cleanup() {
  # Unset traps to prevent re-execution
  trap - EXIT INT TERM

  if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
    print_info "正在清理臨時檔案..."
    rm -rf "$TEMP_DIR"
    print_success "臨時檔案已清理。"
  fi
  exit 1 # Exit the script after cleanup
}

# --- Main Script ---
echo "--- Bartender Crack 安裝程式 ---"
print_info "此腳本將會安裝 Bartender Crack，並設定為自動在背景執行。"

# Create a temporary directory and set up a trap to clean it up on exit
TEMP_DIR=$(mktemp -d)
print_info "已建立臨時目錄：$TEMP_DIR"

# Trap to clean up temporary directory on EXIT, INT (Ctrl+C), TERM
trap cleanup EXIT INT TERM

# 1. Detect architecture and determine binary name
print_info "正在偵測您的電腦架構..."
ARCH=$(uname -m)
SOURCE_BINARY_SUFFIX=""

if [ "$ARCH" = "arm64" ]; then
    print_info "偵測到 ARM 架構 (Apple Silicon)。"
    SOURCE_BINARY_SUFFIX="_arm"
elif [ "$ARCH" = "x86_64" ]; then
    print_info "偵測到 AMD/Intel 架構。"
    SOURCE_BINARY_SUFFIX="_amd"
else
    print_error "不支援的電腦架構: $ARCH"
    exit 1
fi

SOURCE_BINARY_NAME="${BINARY_NAME}${SOURCE_BINARY_SUFFIX}"
DOWNLOAD_FILE_NAME="${SOURCE_BINARY_NAME}"

# 2. Download the binary from GitHub Release
print_info "正在從 GitHub 下載執行檔 '$DOWNLOAD_FILE_NAME'..."
DOWNLOAD_PATH="$TEMP_DIR/$DOWNLOAD_FILE_NAME"

curl -sSL "${DOWNLOAD_URL_BASE}/${DOWNLOAD_FILE_NAME}" -o "$DOWNLOAD_PATH"

if [ ! -f "$DOWNLOAD_PATH" ]; then
    print_error "錯誤：下載執行檔失敗。請檢查網路連線或 GitHub Release 是否存在。"
    exit 1
fi

# Explicit check for DOWNLOAD_PATH before printing success message
if [ -z "$DOWNLOAD_PATH" ]; then
    print_error "內部錯誤：下載路徑變數為空。請檢查腳本邏輯。"
    exit 1
fi

print_success "執行檔已成功下載到 $DOWNLOAD_PATH。"

SOURCE_BINARY_PATH="$DOWNLOAD_PATH"

# 3. Get scheduled time from user
print_info "請輸入您希望 Bartender Crack 每日自動執行的時間："
read -p "小時 (0-23): " HOUR < /dev/tty
read -p "分鐘 (0-59): " MINUTE < /dev/tty

# Validate input
if ! [[ "$HOUR" =~ ^[0-9]{1,2}$ ]] || [ "$HOUR" -lt 0 ] || [ "$HOUR" -gt 23 ]; then
    print_error "錯誤：無效的『小時』輸入 ($HOUR)。請輸入 0-23 之間的數字。"
    exit 1
fi

if ! [[ "$MINUTE" =~ ^[0-9]{1,2}$ ]] || [ "$MINUTE" -lt 0 ] || [ "$MINUTE" -gt 59 ]; then
    print_error "錯誤：無效的『分鐘』輸入 ($MINUTE)。請輸入 0-59 之間的數字。"
    exit 1
fi
print_success "排程時間已設定為 $HOUR:$MINUTE。"

# 4. Remove quarantine attribute from the binary to avoid Gatekeeper warnings
print_info "正在移除執行檔的隔離屬性以避免系統警告..."
xattr -d com.apple.quarantine "$SOURCE_BINARY_PATH" 2>/dev/null || true
print_success "隔離屬性已移除 (若存在)。"

# 5. Create the installation directory and copy binary
print_info "正在建立安裝目錄於 $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
print_success "目錄已建立。"

print_info "正在安裝執行檔 '$SOURCE_BINARY_NAME' 到 '$INSTALL_DIR/$BINARY_NAME'..."
cp "$SOURCE_BINARY_PATH" "$INSTALL_DIR/$BINARY_NAME"
chmod +x "$INSTALL_DIR/$BINARY_NAME"
print_success "執行檔已安裝。"

# 6. Create the plist file for the LaunchAgent
print_info "正在建立系統服務檔案於 $PLIST_PATH..."
mkdir -p "$(dirname "$PLIST_PATH")" # Ensure the directory exists

cat > "$PLIST_PATH" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$PLIST_LABEL</string>
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
    <string>$INSTALL_DIR/${BINARY_NAME}.log</string>
    <key>StandardErrorPath</key>
    <string>$INSTALL_DIR/${BINARY_NAME}.log</string>
</dict>
</plist>
EOL
print_success "服務檔案已建立。"

# 7. Load and start the service
print_info "正在載入並啟動服務..."
# Unload the service first to ensure we're using the new configuration
launchctl unload "$PLIST_PATH" 2>/dev/null || true
# Load the service
launchctl load "$PLIST_PATH"
print_success "服務已成功載入。"

echo ""
print_success "--- 安裝完成！ ---"
echo ""
print_info "Bartender Crack 現已設定為每日 $HOUR:$MINUTE 自動執行。"
print_info "所有檔案皆已安裝於: $INSTALL_DIR"
print_info "若要查看日誌，請執行此指令："
echo "  tail -f $INSTALL_DIR/${BINARY_NAME}.log"
echo ""
print_info "若要解除安裝，請執行以下指令："
echo "  curl -sSL https://raw.githubusercontent.com/${GITHUB_REPO}/main/uninstall.sh | bash"
echo ""