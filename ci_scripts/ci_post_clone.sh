git clone https://github.com/todaywhat/TodayWhat-Secret.git

cd ../

rm -rf XCConfig/

mv ./ci_scripts/Todaywhat-xcconfig/XCConfig .
mv ./ci_scripts/TodayWhat-XCConfig/GoogleService-Info.plist ./Projects/App/iOS/Resources/GoogleService-Info.plist
