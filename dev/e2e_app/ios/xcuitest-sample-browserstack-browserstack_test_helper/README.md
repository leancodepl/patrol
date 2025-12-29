# ios-sample-app

A sample iOS app supporting [XCUI Tests](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/09-ui_testing.html) on [Browserstack](https://www.browserstack.com/).

<img src="https://cdn-images-1.medium.com/max/1600/1*Z0AH-kvjNsUKlcgjP01rmA.png" height="120" /> ![BrowserStack Logo](https://d98b8t1nnulk5.cloudfront.net/production/images/layout/logo-header.png?1469004780)

## How to run

1. Select the device as "Generic iOS device"
2. Product -> Clean
3. Build the ipa
	1. Product -> Archive
	2. Window -> Organizer -> Select the most recently created archive -> Distribute App
	3. Export for "Development"
	4. Select the location where you want the ipa to be saved
4. Build the XC UI Tests zip
	1. Product -> Build For -> Testing
	2. From the shell, go to the DerivedData directory (normally ~/Library/Developer/Xcode/DerivedData/)
	3. cd Sample_iOS-&lt;random characters&gt;
	4. cd Build/Products/Debug-iphoneos/
	5. zip -r SampleUITests.zip SampleXCUITests-Runner.app/
5. Use the ipa, and zip file to run on Browserstack

