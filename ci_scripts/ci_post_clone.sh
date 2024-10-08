#!/bin/bash

cd ../

git clone https://github.com/todaywhat/TodayWhat-Secret.git

rm -rf XCConfig/

mv ./TodayWhat-Secret/XCConfig .
mv ./TodayWhat-Secret/GoogleService-Info.plist ./Projects/App/iOS/Resources/GoogleService-Info.plist

curl https://mise.run | sh
export PATH="$HOME/.local/bin:$PATH"
echo "eval \"\$(/Users/local/.local/bin/mise activate --shims zsh)\"" >> "/Users/local/.zshrc"
source "/Users/local/.zshrc"

mise install

tuist install
TUIST_ENV=CD tuist generate