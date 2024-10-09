#!/bin/bash

git clone https://github.com/todaywhat/TodayWhat-Secret.git

cd ../

rm -rf XCConfig/

if ! mv ./TodayWhat-Secret/XCConfig .; then
    echo "❌ Failed to move XCConfig"
    exit 1
fi

if ! mv ./TodayWhat-Secret/GoogleService-Info.plist ./Projects/App/iOS/Resources/GoogleService-Info.plist; then
    echo "❌ Failed to move GoogleService-Info.plist"
    exit 1
fi
