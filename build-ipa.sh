#!/bin/bash
set -euo pipefail

# ============================================================
# FinanzApp — Build IPA for sideloading
# Usage: ./build-ipa.sh
# Output: FinanzApp.ipa (in project root)
# Requires: Xcode + XcodeGen (`brew install xcodegen`), run on macOS.
# ============================================================

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
NATIVE_DIR="$PROJECT_DIR/Native_iOS"
PROJECT="FinanzApp.xcodeproj"
SCHEME="FinanzApp"
BUNDLE_ID="marino.finanzapp.app"
TEAM_ID="6C53L638P6"
EXPORT_METHOD="development"

ARCHIVE_PATH="/tmp/FinanzApp-build.xcarchive"
EXPORT_PATH="/tmp/FinanzApp-export"
OUTPUT_IPA="$PROJECT_DIR/FinanzApp.ipa"

# Clean previous build artifacts
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

echo "========================================="
echo "  FinanzApp — IPA Build"
echo "========================================="
echo ""
echo "  Bundle ID : $BUNDLE_ID"
echo "  Team ID   : $TEAM_ID"
echo "  Method    : $EXPORT_METHOD"
echo ""

# Step 1: Regenerate the Xcode project from project.yml (XcodeGen)
echo "🛠  [1/3] Generating Xcode project..."
cd "$NATIVE_DIR"
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "xcodegen not found. Install it with: brew install xcodegen" >&2
  exit 1
fi
xcodegen generate
echo ""

# Step 2: Archive main app (this also builds the FinanzAppWidget extension, which is a
# dependency of the FinanzApp target — see project.yml)
echo "🔨 [2/3] Archiving main app..."
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Release \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  archive \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  COMPILER_INDEX_STORE_ENABLE=NO \
  -allowProvisioningUpdates \
  | tail -5
echo ""

# Step 3: Export IPA
echo "📤 [3/3] Exporting IPA..."
EXPORT_PLIST="/tmp/ExportOptions.plist"
cat > "$EXPORT_PLIST" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDsPropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>$EXPORT_METHOD</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>compileBitcode</key>
    <false/>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
PLIST

xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$EXPORT_PATH" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -allowProvisioningUpdates \
  | tail -5

rm -f "$EXPORT_PLIST"
echo ""

# Copy IPA to project root
cp "$EXPORT_PATH/FinanzApp.ipa" "$OUTPUT_IPA"

# Cleanup
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"

SIZE=$(du -h "$OUTPUT_IPA" | cut -f1)
echo "  ✅ Done! IPA: $OUTPUT_IPA ($SIZE)"
echo "========================================="
