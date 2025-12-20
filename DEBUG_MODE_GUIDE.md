# DEBUG Mode Configuration Guide

## What Changed

The app has been configured to work **without Apple Developer account** in DEBUG mode by disabling CloudKit sync.

## Changes Made

### 1. **PersistenceController.swift**
- CloudKit sync is **DISABLED** in DEBUG builds
- CloudKit sync is **ENABLED** in RELEASE builds
- Data is stored locally only when in DEBUG mode

### 2. **SettingsView.swift**
- Shows "Disabled (Debug)" in orange when running in DEBUG
- Shows "Enabled" in green when running in RELEASE
- Footer text explains the current sync status

## How It Works

### DEBUG Mode (Current)
```swift
#if DEBUG
// CloudKit is DISABLED
// ✅ No Apple Developer account needed
// ✅ No iCloud capability required
// ✅ No code signing issues
// ⚠️ Data stored locally only (no sync)
#endif
```

### RELEASE Mode (Production)
```swift
#else
// CloudKit is ENABLED
// ☁️ Syncs to iCloud
// 🔐 Requires Apple Developer account
// 📱 Requires iCloud capability
#endif
```

## Running the App

### Current Setup (DEBUG)
1. **Just run it!** No configuration needed
2. Data will be stored locally on your device
3. All features work except iCloud sync
4. Perfect for development and testing

### Future Setup (When You Get Apple Developer Account)

1. **Enable iCloud Capability in Xcode:**
   - Select your project in Xcode
   - Go to "Signing & Capabilities" tab
   - Click "+ Capability"
   - Add "iCloud"
   - Check "CloudKit"
   - Select or create container: `iCloud.com.spendit.app`

2. **Enable Push Notifications:**
   - Click "+ Capability"
   - Add "Push Notifications"

3. **Test in RELEASE mode:**
   - Change scheme to Release
   - Build and run
   - CloudKit sync will automatically activate

## What You'll See

### In Xcode Console (DEBUG):
```
📱 DEBUG MODE: CloudKit sync is DISABLED
```

### In Settings Screen (DEBUG):
- **iCloud Sync:** Disabled (Debug) 🟠
- Footer: "Running in DEBUG mode. CloudKit sync is disabled. Data is stored locally only."

### In Settings Screen (RELEASE):
- **iCloud Sync:** Enabled 🟢
- Footer: "Your data is securely synced to your private iCloud account"

## Benefits

✅ **No blocking issues** - Develop without Apple Developer account
✅ **Faster iteration** - No signing/provisioning delays
✅ **Local testing** - All features work locally
✅ **Easy transition** - Automatic CloudKit when you're ready
✅ **No code changes** - Just build in RELEASE mode later

## Migration Path

When you get your Apple Developer account:

1. Configure capabilities (see above)
2. Build in RELEASE configuration
3. CloudKit automatically activates
4. Existing local data will sync to iCloud

## Need to Force DEBUG Behavior?

Even in RELEASE, you can force disable CloudKit by:
```swift
// In PersistenceController.swift, temporarily add:
description.cloudKitContainerOptions = nil
```

---

**Note:** All app functionality works in DEBUG mode. Only multi-device sync is disabled.
