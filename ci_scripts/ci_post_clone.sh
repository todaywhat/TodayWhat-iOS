#!/bin/bash

git clone https://github.com/todaywhat/TodayWhat-Secret.git

cd ../

rm -rf XCConfig/

mv ./TodayWhat-Secret/XCConfig .
mv ./TodayWhat-Secret/GoogleService-Info.plist ./Projects/App/iOS/Resources/GoogleService-Info.plist

make cd_generate