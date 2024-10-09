#!/bin/bash

git clone https://github.com/todaywhat/TodayWhat-Secret.git

cd ../

rm -rf XCConfig/

mv ./TodayWhat-Secret/XCConfig .
mv ./TodayWhat-Secret/GoogleService-Info.plist ./Projects/App/iOS/Resources/GoogleService-Info.plist

curl https://mise.run | sh
echo "eval \"\$(/Users/local/.local/bin/mise activate zsh)\"" >> "/Users/local/.zshrc"
eval "$(/opt/homebrew/bin/mise activate --shims zsh)"

mise install

make cd_generate