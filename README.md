# SpendIt - Smart Spending Planner

> Plan where your money goes **before** you spend it, not after.

A modern iOS app that helps you create proactive spending plans and track your financial goals with a beautiful, intuitive interface.

## ✨ Features

### Core Functionality
- **📊 Smart Plans** - Create spending plans for any period (monthly, weekly, custom)
- **💰 Three Categories** - Organize items into Expenses, Income, and Savings
- **❄️ Freeze/Activate** - Pause items to explore "what-if" scenarios without deleting
- **🔄 Clone Plans** - Duplicate plans for recurring periods with smart date calculation
- **📱 Real-time Summary** - Always-visible financial overview with live calculations

### Modern Design
- 🎨 Warm gradient backgrounds with glassmorphism effects
- 🎴 Floating cards with smooth shadows
- ➕ Context-aware floating action button
- 🧮 Built-in calculator for amount entry
- 🎯 Custom tab picker with animated transitions
- ⚡️ Haptic feedback throughout
- 🌓 Full dark mode support

### Smart Features
- **Remaining Balance** - Instant calculation of leftover money
- **Convert to Savings** - One-tap conversion of remaining balance
- **Multi-Currency** - Support for different currencies
- **iCloud Sync** - Automatic backup (Release mode only)
- **Accessibility** - Full VoiceOver support and WCAG AA compliant

## 🚀 Quick Start

### Requirements
- **Xcode** 15.0 or later
- **iOS** 17.6 or later
- **macOS** 14.0 or later (for development)

### Installation

1. **Clone or download** this repository
   ```bash
   cd ~/Downloads
   # If you have the folder, navigate to it
   cd spenditapp
   ```

2. **Open in Xcode**
   ```bash
   open spenditapp.xcodeproj
   ```

3. **Select your target**
   - For **Simulator**: Choose any iPhone simulator
   - For **Physical Device**: Select "Rayed iPhone" or your device

4. **Build and Run**
   - Press `⌘R` or click the Play button
   - App will launch on your selected device

### First Build
- First build may take 1-2 minutes (compiling Swift packages)
- Subsequent builds are much faster (incremental compilation)

## 📖 How to Use

### Creating Your First Plan

1. **Launch the app** → See the plans list (empty at first)
2. **Tap the + button** → "Create Plan" sheet appears
3. **Fill in details**:
   - Plan name (e.g., "January 2025 Budget")
   - Start date and end date
   - Toggle recurring if needed
4. **Tap "Create"** → Your plan is ready!

### Adding Items

1. **Open a plan** → Tap on it from the list
2. **Tap the floating + button** (bottom-right)
3. **Enter item details**:
   - Name (e.g., "Rent", "Salary", "Emergency Fund")
   - Amount (use built-in calculator)
   - Icon (choose from category-specific options)
   - Notes (optional)
4. **Tap "Add"** → Item appears in the list

### Managing Items

- **Edit**: Tap on any item
- **Freeze**: Swipe right on an item → removes it from calculations
- **Unfreeze**: Swipe right again → adds it back to calculations
- **Delete**: Edit item → "Delete Item" button at bottom
- **Reorder**: Long press and drag items up/down

### Understanding the Summary

The summary card at the top shows:
- **Income** - Total active income (green)
- **Expenses** - Total active expenses (red)
- **Savings** - Total active savings (blue)
- **Remaining** - Income - Expenses - Savings

**Color coding**:
- 🟢 Green = Positive remaining (money left over)
- 🟠 Orange = Low remaining (< 5% of income)
- 🔴 Red = Negative remaining (overspending)

### Converting Remaining to Savings

If you have remaining balance:
1. Look for **"Convert to Savings"** button in summary
2. Tap it → Creates a new savings item automatically
3. Switch to **Savings tab** to see it

### Cloning Plans

For recurring plans (monthly budgets):
1. **Open a plan** → Tap ⋯ menu (top-right)
2. **Tap "Clone Plan"**
3. App automatically:
   - Calculates next period dates
   - Generates a new name
   - Copies all items
4. **Tap "Clone"** → New plan created!

## 🏗️ Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **Core Data** - Local persistence with relationships
- **CloudKit** - iCloud sync (enabled in Release builds)
- **Combine** - Reactive programming
- **Swift 5.9+** - Latest Swift features

### Architecture
- **MVVM** - Model-View-ViewModel pattern
- **Component-based** - Reusable UI components
- **Type-safe** - Enums for all states
- **Accessible** - WCAG AA compliant

## 🔧 Build Modes

### Debug Mode (Default)
- CloudKit sync **disabled**
- Faster builds
- Better for testing
- Data stays local only

### Release Mode
- CloudKit sync **enabled**
- Optimized performance
- App Store ready
- Requires Apple Developer account

To switch:
```
Edit Scheme → Run → Build Configuration → Release
```

## 📂 Project Structure

```
spenditapp/
├── SpendItApp.swift          # App entry point
├── Models/                   # Core Data entities
│   ├── Enums.swift
│   ├── PlanEntity+*.swift
│   └── PlanItemEntity+*.swift
├── Views/                    # SwiftUI screens
│   ├── Plans/               # Plan list & detail
│   ├── Items/               # Add/Edit items
│   └── Settings/            # App settings
├── Components/              # Reusable UI components
│   ├── Calculator/          # Custom calculator
│   ├── SummaryBar/          # Financial summary
│   └── CustomTabPicker/     # Tab navigation
├── Utilities/               # Helper classes
│   ├── GradientStyles.swift
│   ├── CardStyles.swift
│   ├── CurrencyFormatter.swift
│   └── HapticManager.swift
└── Persistence/             # Core Data setup
    └── PersistenceController.swift
```

## 🎨 Design System

### Colors
- **Expenses**: Red (#F87171 → #DC2626)
- **Income**: Green (#10B981 → #059669)
- **Savings**: Blue (#60A5FA → #2563EB)
- **Background**: Warm gradients (lavender, peach, sky)

### Typography
- **System font** with SF Rounded for numbers
- **Dynamic Type** support for accessibility
- **Weight variations**: Medium (body), Semibold (emphasis), Bold (headers)

### Spacing
- **4pt grid system** - All spacing in multiples of 4
- **Minimum touch targets**: 44pt (Apple HIG)
- **Enhanced targets**: 56-68pt for primary actions

## 🛠️ Troubleshooting

### Build Fails
1. Clean build folder: `⌘⇧K`
2. Delete derived data: `⌘⇧K` + hold Option
3. Restart Xcode

### CloudKit Errors (Release mode)
- Need Apple Developer account
- Enable iCloud in Signing & Capabilities
- Or switch to Debug mode (CloudKit disabled)

### App Crashes on Launch
- Check iOS version (requires 17.6+)
- Reset Core Data: Delete app and reinstall
- Check Console for error messages

## 📱 Testing

### Recommended Test Flow
1. Create a plan for current month
2. Add 3-5 income items
3. Add 10-15 expense items
4. Add 2-3 savings items
5. Test freeze/unfreeze functionality
6. Verify summary calculations
7. Test "Convert to Savings"
8. Clone the plan for next month
9. Test in both light and dark mode
10. Test VoiceOver accessibility

## 📄 License

This project is for educational and personal use.

## 🤝 Contributing

This is a personal project, but feel free to:
- Report issues
- Suggest features
- Learn from the code
- Build your own version

## 💡 Tips

- **Freeze items** you're unsure about instead of deleting
- Use **recurring plans** for monthly budgets
- Set up **iCloud sync** before adding lots of data
- Use **icons** to make items easy to identify
- Check the **summary card** before finalizing your plan

---

**Built with ❤️ using SwiftUI, Core Data, and modern iOS design principles**

🤖 *Enhanced with [Claude Code](https://claude.com/claude-code)*
