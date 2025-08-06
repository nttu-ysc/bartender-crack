# Go source file
BINARY_NAME := bartender_crack
SOURCE := main.go
BINARY_AMD=$(BINARY_NAME)_amd
BINARY_ARM=$(BINARY_NAME)_arm
RELEASE_AMD_ZIP=bartender-crack-darwin-amd64.zip
RELEASE_ARM_ZIP=bartender-crack-darwin-arm64.zip

# Detect architecture for native builds
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
    ARCH_SUFFIX := _arm
else ifeq ($(ARCH),x86_64)
    ARCH_SUFFIX := _amd
endif
NATIVE_BINARY := $(BINARY_NAME)$(ARCH_SUFFIX)

# .PHONY declaration for targets that are not files
.PHONY: all build build-arm64 build-amd64 install clean

# Default target: builds for both architectures
all: build-arm64 build-amd64

# Build for the native architecture with arch suffix
build:
	@echo "🚀 Building for native architecture ($(ARCH))..."
	go build -o $(NATIVE_BINARY) $(SOURCE)
	@echo "✅ Done! Binary '$(NATIVE_BINARY)' created."

# Build specifically for Apple Silicon (arm64)
build-arm64:
	@echo "💪 Building for macOS (ARM64)..."
	GOOS=darwin GOARCH=arm64 go build -o $(BINARY_ARM) $(SOURCE)
	@echo "✅ Done! Binary '$(BINARY_ARM)' created."

# Build specifically for Intel (amd64)
build-amd64:
	@echo "💻 Building for macOS (AMD64)..."
	GOOS=darwin GOARCH=amd64 go build -o $(BINARY_AMD) $(SOURCE)
	@echo "✅ Done! Binary '$(BINARY_AMD)' created."

# Create release zip files
release: all
	@echo "Creating release zip files..."
	@zip -j $(RELEASE_AMD_ZIP) $(BINARY_AMD) install.sh uninstall.sh
	@echo "✅ Created $(RELEASE_AMD_ZIP)"
	@zip -j $(RELEASE_ARM_ZIP) $(BINARY_ARM) install.sh uninstall.sh
	@echo "✅ Created $(RELEASE_ARM_ZIP)"

# Install the crack
install: build
	@echo "🔧 Running install script..."
	@./install.sh

# Clean up build artifacts
clean:
	@echo "🧹 Cleaning up..."
	@rm -f $(BINARY_NAME) $(BINARY_AMD) $(BINARY_ARM) *.zip
	@echo "✅ Done!"
