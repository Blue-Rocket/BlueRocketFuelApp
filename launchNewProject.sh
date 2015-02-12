#!/bin/bash -e

if [ -z "$1" ]
  then
    echo "Please supply a Project Name when running this script."
	exit 1
fi

TEMPLATE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_NAME=$1
PROJECT_DIR="$TEMPLATE_DIR/../$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
	echo "A Project already exists at $PROJECT_DIR"
	exit 1
fi

mkdir "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo
echo "Creating new project at: $(pwd)"

cp -fr $TEMPLATE_DIR/BlueRocketFuelAppTests \
$TEMPLATE_DIR/BlueRocketFuelApp \
$TEMPLATE_DIR/xcconfigs \
$TEMPLATE_DIR/BlueRocketFuelApp.xcodeproj \
$TEMPLATE_DIR/config.json \
$TEMPLATE_DIR/strings.json \
$TEMPLATE_DIR/Podfile \
.

/usr/bin/sed -i "" s/BlueRocketFuelApp/$PROJECT_NAME/g BlueRocketFuelApp.xcodeproj/project.pbxproj
/usr/bin/sed -i "" s/BlueRocketFuelApp/$PROJECT_NAME/g BlueRocketFuelApp.xcodeproj/xcshareddata/xcschemes/BlueRocketFuelApp.xcscheme
/usr/bin/sed -i "" s/BlueRocketFuelApp/$PROJECT_NAME/g BlueRocketFuelApp.xcodeproj/xcshareddata/xcschemes/BlueRocketFuelAppStaging.xcscheme
/usr/bin/sed -i "" s/BlueRocketFuelApp/$PROJECT_NAME/g BlueRocketFuelApp.xcodeproj/project.xcworkspace/contents.xcworkspacedata
/usr/bin/sed -i "" s/BlueRocketFuelApp/$PROJECT_NAME/g BlueRocketFuelAppTests/BlueRocketFuelAppTests.m

cd BlueRocketFuelApp.xcodeproj/xcshareddata/xcschemes/
mv -f BlueRocketFuelApp.xcscheme "$PROJECT_NAME.xcscheme"
mv -f BlueRocketFuelAppStaging.xcscheme "${PROJECT_NAME}Staging.xcscheme"

cd "$PROJECT_DIR"
mv -f BlueRocketFuelAppTests/BlueRocketFuelAppTests.m "BlueRocketFuelAppTests/${PROJECT_NAME}Tests.m"
mv -f BlueRocketFuelAppTests "${PROJECT_NAME}Tests"
mv -f BlueRocketFuelApp "$PROJECT_NAME"
mv -f BlueRocketFuelApp.xcodeproj "$PROJECT_NAME.xcodeproj"
mv -f xcconfigs/BlueRocketFuelApp.xcconfig "xcconfigs/${PROJECT_NAME}.xcconfig"
mv -f xcconfigs/BlueRocketFuelAppStaging.xcconfig "xcconfigs/${PROJECT_NAME}Staging.xcconfig"

cd "$PROJECT_NAME.xcodeproj"

rm -rf xcuserdata
rm -rf project.xcworkspace/xcuserdata

echo
echo "Configuring BlueRocketFuel framework as a CocoaPod..."

cd "$PROJECT_DIR"
pod install

echo
echo "Initializing git repository and performing initial commit..."

git init
git add --all
git commit -am "Initial Commit using BlueRocketFuel starter app."

echo "Your new app is ready to go.  Always use $PROJECT_NAME.xcworkspace to open the project."

open -a Xcode "$PROJECT_NAME.xcworkspace"