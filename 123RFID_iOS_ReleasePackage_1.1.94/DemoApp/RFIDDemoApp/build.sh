#!/bin/bash

CONFIG=Release

ADHOC_PROFILE="iOS Team Provisioning Profile: com.zebra.RFIDDemoApp"
ADHOC_PROFILE_UUID="5b01e5c7-7258-49fa-ac5a-575d9297d0fa"
ADHOC_CODESIGNID="iPhone Developer: pragnesh s (8BMMDX3V6A)"

APPSTORE_PROFILE="Zebra RFID Demo App"
APPSTORE_PROFILE_UUID="fab8b1a5-055f-495f-91f0-96891de8e22e"
APPSTORE_CODESIGNID="iPhone Distribution: Zebra Technologies Corporation (DNSTESXL8W)"

echo $ADHOC_PROFILE
echo $ADHOC_PROFILE_UUID
echo $ADHOC_CODESIGNID

#INHOUSE_PROFILE="Scanner Demo Application In-House"
#INHOUSE_SIGNID="iOS Distribution: Motorola, Inc."
#echo $INHOUSE_PROFILE
#echo $INHOUSE_SIGNID

RFIDAPPDIR=$(pwd)
RFIDAPPVERSION=$(defaults read $RFIDAPPDIR/RFIDDemoApp/RFIDDemoApp-Info.plist CFBundleShortVersionString)
echo $RFIDAPPVERSION

rm -r -f ./bin/*
mkdir ./bin/adhoc
mkdir ./bin/appstore

# building with ADHOC settings

xcodebuild -project RFIDDemoApp.xcodeproj  clean

rm -r -f ./build

xcodebuild -project RFIDDemoApp.xcodeproj -scheme RFIDDemoApp -archivePath ./bin/adhoc/RFIDDemoApp.xcarchive archive PROVISIONING_PROFILE="$ADHOC_PROFILE_UUID" CODE_SING_IDENTITY="$ADHOC_CODESIGNID"

cd ./bin/adhoc
/usr/bin/zip --recurse-path ./RFIDDemoApp_$RFIDAPPVERSION.adhoc.xcarchive.zip ./RFIDDemoApp.xcarchive
cd ../../
xcodebuild -exportArchive -archivePath ./bin/adhoc/RFIDDemoApp.xcarchive -exportPath ./bin/adhoc/RFIDDemoApp_$RFIDAPPVERSION.adhoc -exportOptionsPlist ./ExportOptionsAdhoc.plist

mv ./bin/adhoc/RFIDDemoApp_$RFIDAPPVERSION.adhoc/*.ipa ./bin/adhoc/RFIDDemoApp_$RFIDAPPVERSION.adhoc.ipa

rm -r -f ./build
rm -r -f ./bin/adhoc/RFIDDemoApp.xcarchive

# building with APPSTORE settings

echo $APPSTORE_PROFILE
echo $APPSTORE_PROFILE_UUID
echo $APPSTORE_CODESIGNID

xcodebuild -project RFIDDemoApp.xcodeproj  clean

rm -r -f ./build

xcodebuild -project RFIDDemoApp.xcodeproj -scheme RFIDDemoApp -archivePath ./bin/appstore/RFIDDemoApp.xcarchive archive PROVISIONING_PROFILE="$APPSTORE_PROFILE_UUID" CODE_SING_IDENTITY="$APPSTORE_CODESIGNID"

cd ./bin/appstore
/usr/bin/zip --recurse-path ./RFIDDemoApp_$RFIDAPPVERSION.appstore.xcarchive.zip ./RFIDDemoApp.xcarchive
cd ../../
xcodebuild -exportArchive -archivePath ./bin/appstore/RFIDDemoApp.xcarchive -exportPath ./bin/appstore/RFIDDemoApp_$RFIDAPPVERSION.appstore -exportOptionsPlist ./ExportOptionsAppStore.plist

mv ./bin/appstore/RFIDDemoApp_$RFIDAPPVERSION.appstore/*.ipa ./bin/appstore/RFIDDemoApp_$RFIDAPPVERSION.appstore.ipa

rm -r -f ./build
rm -r -f ./bin/appstore/RFIDDemoApp.xcarchive

