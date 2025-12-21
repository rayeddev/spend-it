# How to Record a GIF Demo for SpendIt

## Quick Method (Recommended)

### 1. Install ffmpeg (if not already installed)
```bash
brew install ffmpeg
```

### 2. Start Recording
1. **Open Terminal** and run:
```bash
# Create a recordings directory
mkdir -p ~/Desktop/spendit-demo

# Boot iPhone 17 Pro simulator
xcrun simctl boot "iPhone 17 Pro"

# Open Simulator app
open -a Simulator

# Build and run the app
cd ~/work/spenditapp
xcodebuild -project spenditapp.xcodeproj -scheme spenditapp -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -quiet &

# Wait for app to launch (about 10 seconds), then start recording
sleep 10
xcrun simctl io booted recordVideo ~/Desktop/spendit-demo/demo.mov &

# Note the PID that gets printed
```

### 3. Perform the Demo (30-45 seconds)
Do these actions smoothly:

**Scene 1: Create a Plan (10 seconds)**
1. Tap the **+** button (top-right)
2. Enter plan name: "January Budget"
3. Set dates (keep defaults)
4. Tap **Create**

**Scene 2: Add Items (20 seconds)**
5. Tap the plan to open it
6. Tap the **floating +** button (bottom-right)
7. Switch to **Income** tab
8. Enter "Salary" - tap amount, use calculator to enter 5000
9. Tap **Add**
10. Tap floating **+** again
11. Switch to **Expenses** tab
12. Enter "Rent" - amount 1500
13. Tap **Add**
14. Add one more expense: "Groceries" - 400

**Scene 3: Show Summary (10 seconds)**
15. See the summary update in real-time
16. Scroll through items
17. Try freezing an item (swipe right)
18. End recording

### 4. Stop Recording
```bash
# Press Ctrl+C in the terminal where recording is running
# Or kill the process: kill <PID>
```

### 5. Convert to GIF
```bash
cd ~/Desktop/spendit-demo

# Create a high-quality GIF (optimized for README)
ffmpeg -i demo.mov \
  -vf "fps=15,scale=400:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 \
  demo.gif

# Or create a higher quality version (larger file)
ffmpeg -i demo.mov \
  -vf "fps=20,scale=600:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
  -loop 0 \
  demo-hq.gif
```

### 6. Move to Project
```bash
# Copy GIF to project
cp ~/Desktop/spendit-demo/demo.gif ~/work/spenditapp/assets/demo.gif

# Or just use it from Desktop
```

## Alternative: Use QuickTime or macOS Screenshot

### Method A: QuickTime Screen Recording
1. Open **QuickTime Player**
2. **File → New Screen Recording**
3. Click **Options** → Select iPhone simulator window
4. Click **Record** → Click simulator window
5. Perform demo actions
6. Press **Stop** in menu bar
7. **File → Export As → 1080p**
8. Use ffmpeg to convert (see step 5 above)

### Method B: macOS Screenshot Tool (Easiest!)
1. Press **⌘⇧5** (Screenshot toolbar)
2. Click "Record Selected Portion"
3. Drag to select simulator window
4. Click **Record**
5. Perform demo actions
6. Click **Stop** in menu bar
7. Video saves to Desktop
8. Use ffmpeg to convert to GIF

## Demo Script (What to Show)

```
0:00 - App launches, shows empty plans list
0:03 - Tap + to create plan
0:05 - Enter "January Budget"
0:08 - Tap Create
0:10 - Plan appears, tap to open
0:12 - See summary card at top
0:14 - Tap floating + button (red gradient)
0:16 - Switch to Income tab (green)
0:18 - Enter "Salary" $5,000
0:22 - Tap Add, see item appear
0:24 - Tap + again, switch to Expenses (red)
0:26 - Enter "Rent" $1,500
0:28 - Add another: "Groceries" $400
0:32 - See summary update: Remaining shows green
0:35 - Swipe right on an item to freeze (cyan overlay)
0:38 - Summary updates to show new remaining
0:40 - Tap frozen item to unfreeze
0:42 - Summary updates again
0:45 - End
```

## Optimization Tips

- **Keep it short**: 30-45 seconds max
- **Smooth movements**: Don't rush
- **Show key features**: Create, add, freeze, summary
- **Good lighting**: Screen should be bright
- **Stable camera**: If recording screen, keep it steady

## Final GIF Specs

- **Size**: 400-600px width (GitHub README optimal)
- **FPS**: 15-20 frames per second
- **Format**: GIF with optimized palette
- **File size**: Under 5MB for fast loading
- **Duration**: 30-45 seconds

---

After you create the GIF, place it in the project and I'll update the README to include it!
