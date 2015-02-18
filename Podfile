source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.1'

inhibit_all_warnings!

# Remember to run 'pod install' from terminal after modifying this file.

# If you are working on improving BlueRocketFuel, then you'll want to work with local copies of both the App & Core projects.
# This condition causes 'pod install' to use local BlueRocketFuelCore files if the current directory is called BlueRocketFuelApp.
# Conversely, if you used BlueRocketFuelApp as a starter for another project by running launchNewProject.sh, then your
# current directory will be called something else. CocoaPods will then download BlueRocketFuelCore from github instead.
if File.basename(Dir.pwd) == "BlueRocketFuelApp" then
    # use local copy of BlueRocketFuelCore during framework development. In order to preserve source code folders as groups, you need CocoaPods >= 0.36
    pod 'BlueRocketFuelCore', :path => '../BlueRocketFuelCore'
else
    # use latest BlueRocketFuelCore in remote repo
    pod 'BlueRocketFuelCore', :git => 'https://github.com/Blue-Rocket/BlueRocketFuelCore.git', :branch => 'master'

    # use specific version of BlueRocketFuelCore in remote repo
    #pod 'BlueRocketFuelCore', :git => 'https://github.com/Blue-Rocket/BlueRocketFuelCore.git', :tag => '0.1'

    # use BlueRocketFuelCore registered with CocoaPods
    #pod 'BlueRocketFuelCore', '~> 0.1'
end
