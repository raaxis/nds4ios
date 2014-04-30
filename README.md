nds4ios
=======
###### Supports iOS 5 to iOS 7.

nds4ios is a port of the multi-platform Nintendo DS emulator, DeSmuME to iOS.

Currently, emulation is powered by a threaded ARM interpreter. As a result, emulation is rather slow on older devices, like the iPhone 4S and below.

nds4ios runs at nearly full speed on the iPhone 5 and above, and achieves full speed on devices using the A7-S5L8960X SoC (iPhone 5s, iPad Air, iPad mini Retina, and anything newer than these devices).

Due to the need to mmap the entire ROM into memory, older devices with only 256MB of RAM are not supported by nds4ios. These devices include the iPod touch 4, iPad 1G, iPhone 3GS, and anything below those devices.

ROMs must be placed in /User/Documents (or /private/var/mobile/Documents, it's a symbolic link).

[nds4ios](http://nds4ios.angelxwind.net/)

[nds4droid](http://jeffq.com/blog/nds4droid/)

[DeSmuME](http://desmume.org/) 

[![Donate](https://www.paypalobjects.com/en_US/i/btn/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MCAFUKL3CM8QQ)

##### We all work hard to make software that users will enjoy and love. If you enjoy nds4ios, please consider making a donation to help us create and provide better things.

Installing nds4ios
------------------------
##### Do not redistribute code-signed copies nds4ios on other sites. We already provide official ways to download nds4ios below. THIS IS A FAIR WARNING.
#### Option 1: Download nds4ios from Karen's Pineapple (KarenP/88888888)

If you're jailbroken, please follow the instructions here: http://nds4ios.angelxwind.net/i/?page/downloads#jailbroken

If you're NOT jailbroken, please follow the instructions here: http://nds4ios.angelxwind.net/i/?page/downloads#notjailbroken

##### Please note that the non-jailbroken distribution of nds4ios is extremely outdated, and can no longer be updated. It's either this, or nothing.

#### Option 2: Compile nds4ios yourself

##### IMPORTANT: Make sure your working directory is devoid of spaces. Otherwise, bad things will happen.

1.  Open a Terminal instance and go to your working directory.

2.  Do
<code>git clone https://github.com/InfiniDev/nds4ios.git</code>

3.  then
Navigate to the "nds4ios" folder in your working directory.

4. Open "nds4ios.xcodeproj", connect your device, select it on Xcode and click the "Run" button (or Command + R). Don't build it for the iOS Simulator. IMPORTANT: Make sure you change your running scheme to Release first. Otherwise you will get errors on compile!

#### Option 2a
1. Alternatively, run
    <code>xcodebuild -configuration Release</code>
   from Terminal and then copy the resulting *.app bundle to your /Applications directory on your device.


Adding ROMs
------------------------
###### Since this apparently needs explaining

#### Option 1 - Via RSTWebViewController (iOS 7 and above)
1. In nds4ios, tap on the + button in the upper right hand corner.
2. Download a ROM package of a ROM that you **own the actual game cartridge for** from a site such as CoolROM. It may come in a zip file. You do not have to have any sort of download manager for this, nds4ios will download zip files.
3. Wait patiently, watch the progress bar, and nds4ios will automatically unzip the file, delete the readme, find the .nds file, and refresh itself. Your ROM should show up in the list. Magic!

#### Option 2 - Via Safari (iOS 6 and iOS 5)
1. In nds4ios, tap on the + button in the upper right hand corner.
2. Download a ROM package of a ROM that you **own the actual game cartridge for** from a site such as CoolROM. It may come in a zip file. You do not have to have any sort of download manager for this, Safari will download zip files.
3. Tap the "Open in..." button in the top left hand corner, and select nds4ios.
4. nds4ios will automatically unzip the file, delete the readme, find the .nds file, and refresh itself. Your ROM should show up in the list. Magic!

#### Option 3 - Via iTunes File Sharing / iFunBox / iExplorer (Non-jailbroken version ONLY)
1. Plug your device into your computer and launch iTunes.
2. Go to your iDevice's info page, then the apps tab.
3. drag and drop .nds files that you have (preferably ones you legally own the actual game cartridge for) into the iTunes file sharing box for nds4ios.
4. Kill nds4ios from the app switcher if it's backgrounded, and launch it again to see changes.

#### Option 3 - Via Safari Download Enabler/Chrome Downloader (Jailbroken version ONLY)
1. If you're jailbroken, grab one of the many download tweaks available for Mobile Safari or Chrome for iOS, or grab one of the many web browsers available with download managers built in, such as [Cobium](https://itunes.apple.com/us/app/cobium-simple-browsing/id502426780?mt=8) (This is totally not a shameless plug).
2. With the new browser or tweak, download a rom, preferably one you own the actual cartridge for.
3. Using iFile or similar too, move the .nds file to the nds4ios directory, into the documents folder.
4. Kill nds4ios from the app switcher if it's backgrounded, and launch it again to see changes.

### Option 4 - Via AFC2 / OpenSSH / iFunBox / iExplorer (Jailbroken verison ONLY)
1. Install OpenSSH if you plan to utilise SCP (SSH) to transfer ROMs.
2. If you do not wish to utilise SCP, then download iFunBox/iExplorer/similar tool that uses AFC2 over USB and install it on your computer.
3. Drag your ROMs into the directory: /User/Documents/
4. Saves go in: /var/mobile/Documents/Battery/

Reporting Bugs
------------------------
###### Ew, bugs.
#### When something in nds4ios isn't working correctly for you, please [open a GitHub issue ticket here](https://github.com/InfiniDev/nds4ios/issues/new).
##### Please include the following information:
* iOS device
* iOS version
* Jailbreak status
* Download location

##### Please do not open issues about the following topics:
* Slow performance
* Crashing on older devices with 256MB of RAM (iPod touch 4, iPhone 3GS, iPad 1, and anything released prior to those devices.)


To-do
------------------------
###### We'll get to these, really!
* GNU LIghtning JIT (Currently running into pointer corruption issues.)
* Paravirtualisation (far-off goal, only after GNU Lightning JIT works)
* OpenGL ES rendering
* Automatically fix permissions of crucial folders on the jailbroken distribution
* Ability to change the folder the ROM chooser reads from
* Minimise memory footprint (which will fix support for devices with low RAM)
* Add more localizations (currently have: English, Traditional Chinese, Simplified Chinese, Spanish, French, Japanese)
* Much more.

Contributors
------------------------
###### We stand on the shoulders of these people.
* [The DeSmuME developers](http://desmume.org/)
* [Jeffrey Quesnelle (jeffq), the developer of nds4droid](http://jeffq.com/blog/nds4droid/)
* [rock88](http://rock88dev.blogspot.com/)
* [Karen Tsai (angelXwind)](http://angelxwind.net/)
* [Brian Tung (inb4ohnoes)](http://brian.weareflame.co/)
* [Jesús A. Álvarez (maczydeco)](http://twitter.com/maczydeco)
* [W.MS](http://github.com/w-ms/)
* [Riley Testut (rileytestut)](https://github.com/rileytestut)
* [David Chavez (dchavezlive)](http://dchavez.net)
* [Michael Zhang (Malvix_)](https://twitter.com/Malvix_)
* [Angela Tsai (vanillastar67)](https://twitter.com/vanillastar67)
* [winocm (winocm)](https://twitter.com/winocm)
* [Jesús Higueras (GranPC)](https://twitter.com/GranPC)
