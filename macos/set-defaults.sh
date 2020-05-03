# Sets reasonable macOS defaults.
#
# Or, in other words, set shit how I like in macOS.
#
# The original idea (and a couple settings) were grabbed from:
#   https://github.com/mathiasbynens/dotfiles/blob/master/.macos
#
# Run ./set-defaults.sh and you'll be good to go.

source "${HOME}/.dotfiles/script/echos.sh"

set -e

bot "=== Setting MacOS defaults that make sense ==="

###############################################################################
bot "Configuring General System UI/UX..."
###############################################################################
# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
running "Closing any system preferences to prevent issues with automated changes"
osascript -e 'tell application "System Preferences" to quit'
ok

###############################################################################
bot "Languages"
###############################################################################

# Set language and text formats
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
running "Locale - UK. Currency - GBP"
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=GBP";ok
running "Use centimeters"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters";ok
running "Use metric units"
defaults write NSGlobalDomain AppleMetricUnits -bool true;ok

###############################################################################
bot "Finder"
###############################################################################

running "Keep folders on top when sorting by name (version 10.12 and later)"
defaults write com.apple.finder _FXSortFoldersFirst -bool true;ok

running "Expand the following File Info panes: “General”, “Open with”, and “Sharing & Permissions”"
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General -bool true \
  OpenWith -bool true \
  Privileges -bool true;ok

running "Set Desktop as the default location for new Finder windows"
# For other paths, use 'PfLo' and 'file:///full/path/here/'
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/";ok

running "Use AirDrop over every interface. srsly this should be a default"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1;ok

running "Always open everything in Finder's list view. This is important"
defaults write com.apple.Finder FXPreferredViewStyle Nlsv;ok

running "Show the ~/Library folder"
chflags nohidden ~/Library;ok

running "Set the Finder prefs for showing a few different volumes on the Desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true;ok

running "Show hidden files by default"
defaults write com.apple.finder AppleShowAllFiles -bool true;ok

running "Show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true;ok

running "Show status bar"
defaults write com.apple.finder ShowStatusBar -bool true;ok

running "Show path bar"
defaults write com.apple.finder ShowPathbar -bool true;ok

running "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true;ok

running "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false;ok

running "Enable spring loading for directories"
defaults write NSGlobalDomain com.apple.springing.enabled -bool true;ok

running "Remove the spring loading delay for directories"
defaults write NSGlobalDomain com.apple.springing.delay -float 0;ok

running "Allow text selection in Quick Look"
defaults write com.apple.finder QLEnableTextSelection -bool true;ok

running "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf";ok

running "Avoid creating .DS_Store files on network or USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true;ok

running "Disable the warning before emptying the Trash"
defaults write com.apple.finder WarnOnEmptyTrash -bool true;ok

###############################################################################
bot "Animation"
###############################################################################

running "Disable cursos magnification on shake"
defaults write -globalDomain CGDisableCursorLocationMagnification -bool true;ok

running "Disable automatically rearrange Spaces based on recent use"
defaults write com.apple.dock mru-spaces -bool false;ok

running "Speed up animations everywhere"
# https://apple.stackexchange.com/questions/14001/how-to-turn-off-all-animations-on-os-x
# Still not fast enough though :(
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write -g NSScrollAnimationEnabled -bool false
defaults write -g NSWindowResizeTime -float 0.001
defaults write -g QLPanelAnimationDuration -float 0
defaults write -g NSScrollViewRubberbanding -bool false
defaults write -g NSDocumentRevisionsWindowTransformAnimation -bool false
defaults write -g NSToolbarFullScreenAnimationDuration -float 0
defaults write -g NSBrowserColumnAnimationSpeedMultiplier -float 0
defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.dock autohide-time-modifier -float 0
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock expose-animation-duration -float 0
defaults write com.apple.dock springboard-show-duration -float 0
defaults write com.apple.dock springboard-hide-duration -float 0
defaults write com.apple.dock springboard-page-duration -float 0
defaults write com.apple.finder DisableAllAnimations -bool true
defaults write com.apple.Mail DisableSendAnimations -bool true
defaults write com.apple.Mail DisableReplyAnimations -bool true;ok

################################################
bot "Standard System Changes"
################################################

running "Always boot in verbose mode (not MacOS GUI mode)\n"
sudo nvram boot-args="-v";ok

running "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true;ok

running "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true;ok

running "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true;ok

# Disable Resume system-wide
# defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

running "Disable the “Are you sure you want to open this application?” dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false;ok

# Disable Notification Center and remove the menu bar icon
# launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null

running "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40;ok

running "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0;ok

running "Save screenshots to the desktop"
defaults write com.apple.screencapture location -string "${HOME}/Desktop";ok

running "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png";ok

running "Stop iTunes from responding to the keyboard media keys"
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null;ok

running "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0;ok

###############################################################################
bot "Trackpad, mouse, keyboard, Bluetooth accessories, and input"
###############################################################################

running "Trackpad: enable tap to click for this user and for the login screen"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1;ok

# https://www.howtogeek.com/267463/how-to-enable-key-repeating-in-macos.
running "Disable press-and-hold for keys in favor of key repeat"
defaults write -g ApplePressAndHoldEnabled -bool false;ok

running "Set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 10;ok

###############################################################################
bot "=== Configuring Applications ==="
###############################################################################

###############################################################################
bot "Activity Monitor"
###############################################################################

running "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true;ok

running "Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5;ok

running "Show all processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 100;ok

# Show processes in Activity Monitor
# 100: All Processes
# 101: All Processes, Hierarchally
# 102: My Processes
# 103: System Processes
# 104: Other User Processes
# 105: Active Processes
# 106: Inactive Processes
# 106: Inactive Processes
# 107: Windowed Processes
running "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0;ok

running "Set columns for each tab"
defaults write com.apple.ActivityMonitor "UserColumnsPerTab v5.0" -dict \
    '0' '( Command, CPUUsage, CPUTime, Threads, PID, UID, Ports )' \
    '1' '( Command, ResidentSize, Threads, Ports, PID, UID,  )' \
    '2' '( Command, PowerScore, 12HRPower, AppSleep, UID, powerAssertion )' \
    '3' '( Command, bytesWritten, bytesRead, Architecture, PID, UID, CPUUsage )' \
    '4' '( Command, txBytes, rxBytes, PID, UID, txPackets, rxPackets, CPUUsage )';ok

running "Sort columns in each tab"
defaults write com.apple.ActivityMonitor UserColumnSortPerTab -dict \
    '0' '{ direction = 0; sort = CPUUsage; }' \
    '1' '{ direction = 0; sort = ResidentSize; }' \
    '2' '{ direction = 0; sort = 12HRPower; }' \
    '3' '{ direction = 0; sort = bytesWritten; }' \
    '4' '{ direction = 0; sort = txBytes; }';ok

# 1: Very often (1 sec)
# 2: Often (2 sec)
# 5: Normally (5 sec)
running "Update refresh frequency (in seconds)"
defaults write com.apple.ActivityMonitor UpdatePeriod -int 2;ok

running "Show Data in the Disk graph (instead of IO)"
defaults write com.apple.ActivityMonitor DiskGraphType -int 1;ok

running "Show Data in the Network graph (instead of packets)"
defaults write com.apple.ActivityMonitor NetworkGraphType -int 1;ok

running "Change Dock Icon"
# 0: Application Icon
# 2: Network Usage
# 3: Disk Activity
# 5: CPU Usage
# 6: CPU History
defaults write com.apple.ActivityMonitor IconType -int 3;ok

###############################################################################
bot "Safari"
###############################################################################

running "Show Safari's bookmark bar"
defaults write com.apple.Safari ShowFavoritesBar -bool true;ok

running "Set up Safari for development"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" -bool true
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true;ok

###############################################################################
bot "Mac App Store"
###############################################################################

running "Enable the WebKit Developer Tools in the Mac App Store"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true;ok

running "Enable Debug Menu in the Mac App Store"
defaults write com.apple.appstore ShowDebugMenu -bool true;ok

running "Enable the automatic update check"
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true;ok

running "Check for software updates daily, not just once per week"
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1;ok

running "Download newly available updates in background"
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1;ok

running "Install System data files & security updates"
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1;ok

running "Automatically download apps purchased on other Macs"
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1;ok

running "Turn on app auto-update"
defaults write com.apple.commerce AutoUpdate -bool true;ok

###############################################################################
bot "Photos"
###############################################################################

running "Prevent Photos from opening automatically when devices are plugged in"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true;ok

###############################################################################
bot "iTerm"
###############################################################################

running "Specify the preferences directory"
defaults write com.googlecode.iterm2.plist PrefsCustomFolder -string "${HOME}/.dotfiles/iterm2";ok
running "Tell iTerm2 to use the custom preferences in the directory"
defaults write com.googlecode.iterm2.plist LoadPrefsFromCustomFolder -bool true;ok

###############################################################################
bot "TextEdit, and Disk Utility"
###############################################################################

running "Use plain text mode for new TextEdit documents"
defaults write com.apple.TextEdit RichText -int 0;ok

running "Open and save files as UTF-8 in TextEdit"
defaults write com.apple.TextEdit PlainTextEncoding -int 4
defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4;ok

running "Enable the debug menu in Disk Utility"
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true;ok

###############################################################################
bot "Time Machine"
###############################################################################

running "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true;ok

###############################################################################
bot "Messages"
###############################################################################

running "Disable automatic emoji substitution (i.e. use plain text smileys)"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticEmojiSubstitutionEnablediMessage" -bool false;ok

running "Disable smart quotes as it’s annoying for messages that contain code"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "automaticQuoteSubstitutionEnabled" -bool false;ok

running "Disable continuous spell checking"
defaults write com.apple.messageshelper.MessageController SOInputLineSettings -dict-add "continuousSpellCheckingEnabled" -bool false;ok

###############################################################################
# Kill affected applications                                                  #
###############################################################################

bot "OK. Note that some of these changes require a logout/restart to take effect. Killing affected applications (so they can reboot)..."
for app in "Activity Monitor" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Safari" "SystemUIServer" \
  "Terminal"; do
  killall "${app}" > /dev/null 2>&1
done

exit 0
