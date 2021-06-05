# Project Megacosm
This Flutter based application aims to facilitate the delegation and governance process of any COSMOS based Blockchain network.<br>

## Feature List
## App Side Features
1. Mnemonic is stored in encrypted way and user password is not stored at all, so app is really secure.
2. Users can switch between some predefined networks, or add new network.
3. Users can swtich between networks instantly.
### Banking
1. Transfer Tokens to a different account
### Staking
1. Stake tokens to a validator.
2. Withdraw rewards from Validators.
3. Redelegate your stake.
4. Undelegate your stake.
### Governance
1. Creating new text proposals.
2. Adding deposits to the proposals.
3. Voting to a proposal.
### Codebase
1. This application is purely written in dart thus it can run on both iOS and android without changing a single line of code.
2. Clean codebase for easy modeification and usage.

#
### Screenshots
|<img src="Screenshots/6.png" width="400">|<img src="Screenshots/2.png" width="400">
|<img src="Screenshots/3.png" width="400">|<img src="Screenshots/4.png" width="400">
|<img src="Screenshots/5.png" width="400">|<img src="Screenshots/8.png" width="400">
|<img src="Screenshots/9.png" width="400">|<img src="Screenshots/10.png" width="400">
- Head over to screenshots folder for more screenshots.

Instructions to build:

https://flutter.dev/docs/get-started/install/macos
https://flutter.dev/docs/deployment/android
https://flutter.dev/docs/deployment/ios

- Be sure to run "pod install" in the ios folder, for a newly installed copy of the code. Then, "open the Runner.xcworkspace" folder. Increment the build number, build an archive, distribute to app store, wait for approval, and then goto AppStoreConnect, and distribute as required.

- For Android, update the "version" in pubspec.yaml in the application folder to a new version (increment, typically). Then, run "flutter build appbundle". Then, goto Google Play Console (https://play.google.com), goto Release Management, App Releases, Manage the Internal Test under "Internal Test Track", click "Create Release" to create a new release, upload the new app bundle created, wait till it completes and then click save at the bottom, then review, then "start rollout to internal test"

- Be sure to also place a key.properties file in the android folder with the following contents:
  storePassword=*******
  keyPassword=*******
  keyAlias=key
  storeFile=/path/to/key.jks

If you want to just run a local debug build, run:

flutter run

You might have to specify the device if you have multiple devices (physical or simulators). 

The following command is your friend to get details and diagnostics:

flutter doctor

Update the following to add/modify/delete networks that are pre-configured with the app:

assets/networks.json

You can specify things like: Chain id (cid), Big Dipper base URL, REST (1317) URL for network's client sentry round-robin endpoint.
