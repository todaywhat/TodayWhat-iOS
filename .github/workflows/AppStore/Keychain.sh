security create-keychain -p "" "$KEYCHAIN" 
security list-keychains -s "$KEYCHAIN" 
security default-keychain -s "$KEYCHAIN" 
security unlock-keychain -p "" "$KEYCHAIN"
security set-keychain-settings -lut 3600
security list-keychains