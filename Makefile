# Go source file
BINARY_NAME := bartender_crack
SOURCE := main.go

# Detect architecture for native builds
ARCH := $(shell uname -m)
ifeq ($(ARCH),arm64)
    ARCH_SUFFIX := _arm64
else ifeq ($(ARCH),x86_64)
    ARCH_SUFFIX := _amd64
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
	GOOS=darwin GOARCH=arm64 go build -o $(BINARY_NAME)_arm64 $(SOURCE)
	@echo "✅ Done! Binary '$(BINARY_NAME)_arm64' created."

# Build specifically for Intel (amd64)
build-amd64:
	@echo "💻 Building for macOS (AMD64)..."
	GOOS=darwin GOARCH=amd64 go build -o $(BINARY_NAME)_amd64 $(SOURCE)
	@echo "✅ Done! Binary '$(BINARY_NAME)_amd64' created."

# Install the crack
install: build
	@echo "🔧 Running install script..."
	@./install.sh

# Clean up build artifacts
clean:
	@echo "🧹 Cleaning up..."
	rm -f $(BINARY_NAME) $(BINARY_NAME)_arm64 $(BINARY_NAME)_amd64
	@echo "✅ Done!"
