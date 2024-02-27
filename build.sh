xcodebuild archive -archivePath "Hamster" -scheme "Hamster" -sdk "iphoneos" -arch arm64 -configuration Release CODE_SIGNING_ALLOWED=NO
BUILT_PATH=$(find Hamster.xcarchive -name '*.app' -type d | head -1)
find "$BUILT_PATH" -type d -path '*/Frameworks/*.dylib' -exec codesign --force --sign - --timestamp=none \{\} \;
codesign --force --sign - --entitlements "Hamster/Hamster.entitlements" --timestamp=none "$BUILT_PATH"
tar -acf Hamster.xcarchive.tgz Hamster.xcarchive