# SpendIt iOS App
## Product Requirements Document (PRD)

**Version:** 1.0  
**Last Updated:** December 19, 2025  
**Status:** Draft for Review  
**Author:** Product Team  

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Goals & Success Metrics](#2-goals--success-metrics)
3. [User Personas](#3-user-personas)
4. [Information Architecture](#4-information-architecture)
5. [Data Model](#5-data-model)
6. [Functional Requirements](#6-functional-requirements)
7. [User Interface Requirements](#7-user-interface-requirements)
8. [Non-Functional Requirements](#8-non-functional-requirements)
9. [Monetization](#9-monetization)
10. [Edge Cases & Error Handling](#10-edge-cases--error-handling)
11. [Future Considerations](#11-future-considerations)
12. [Appendix](#12-appendix)

---

## 1. Product Overview

### 1.1 Vision Statement

SpendIt is a forward-looking spending planning app that helps users **decide where their money should go before they spend it**, rather than tracking where it went afterward.

### 1.2 Problem Statement

Existing budgeting apps focus on expense tracking (reactive), which creates guilt and doesn't change behavior. Users need a **proactive planning tool** that lets them:
- Visualize spending options before committing
- Easily adjust priorities when circumstances change
- See savings potential in real-time
- Reduce friction when starting a new budget period

### 1.3 Solution

SpendIt introduces **Spending Plans** with three item types (Outcome, Income, Savings) and a unique **freeze/activate mechanism** that lets users toggle spending items on/off to explore different scenarios and prioritize their spending.

### 1.4 Target Platform

- **Primary:** iOS 16.0+
- **Devices:** iPhone (primary), iPad (secondary)
- **Architecture:** SwiftUI + Core Data + CloudKit

---

## 2. Goals & Success Metrics

### 2.1 Product Goals

| Goal | Description |
|------|-------------|
| G1 | Enable users to create and manage spending plans in under 2 minutes |
| G2 | Reduce monthly budget setup friction by 80% through plan cloning |
| G3 | Achieve 30-day retention rate of 20%+ (vs. industry average of 5-6%) |
| G4 | Generate $5,000+ MRR within 12 months of launch |

### 2.2 Key Performance Indicators (KPIs)

| Metric | Target | Measurement |
|--------|--------|-------------|
| Day 1 Retention | 40%+ | Users returning after first day |
| Day 7 Retention | 25%+ | Users returning after first week |
| Day 30 Retention | 15%+ | Users returning after first month |
| Plan Completion Rate | 70%+ | Plans with all items configured |
| Clone Usage Rate | 50%+ | Recurring plans that use clone feature |
| Trial-to-Paid Conversion | 8%+ | Free trial users who subscribe |

---

## 3. User Personas

### 3.1 Primary Persona: "Planner Pat"

- **Age:** 25-35
- **Income:** Variable or fixed salary
- **Pain Points:** 
  - Struggles to know what's "safe to spend"
  - Hates re-entering budget info every month
  - Wants to see impact of cutting certain expenses
- **Goals:**
  - Know exactly where each dollar should go
  - Save more without feeling deprived
  - Quickly adjust when unexpected expenses arise

### 3.2 Secondary Persona: "Freelancer Fiona"

- **Age:** 28-40
- **Income:** Irregular/project-based
- **Pain Points:**
  - Income varies month to month
  - Needs to plan for feast-and-famine cycles
  - Multiple income sources to track
- **Goals:**
  - Plan spending based on projected income
  - Build savings buffer during good months
  - Easily adjust when projects start/end

---

## 4. Information Architecture

### 4.1 App Structure

```
SpendIt App
│
├── Home (Plans List)
│   ├── Current Plan (Active/Editable)
│   ├── Upcoming Plans (Future recurring)
│   └── Historical Plans (Read-only archive)
│
├── Plan Detail View
│   ├── Outcome Tab (Primary) ────────────────┐
│   ├── Income Tab (Secondary)                │ Main Interaction
│   ├── Savings Tab                           │ Area
│   └── Summary Bar (Always visible) ─────────┘
│
├── Settings
│   ├── Account & Subscription
│   ├── iCloud Sync
│   ├── Data Export
│   ├── Currency Settings
│   └── Notifications
│
└── Calculator (Modal)
    └── Custom number input interface
```

### 4.2 Navigation Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         PLANS LIST                               │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐              │
│  │  December   │  │  January    │  │  + New Plan │              │
│  │  (Current)  │  │  (Upcoming) │  │             │              │
│  │  $4,200     │  │  Recurring  │  │             │              │
│  └──────┬──────┘  └─────────────┘  └─────────────┘              │
│         │                                                        │
│         ▼                                                        │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    PLAN DETAIL VIEW                          ││
│  │  ┌─────────┬─────────┬─────────┐                            ││
│  │  │ Outcome │ Income  │ Savings │  ← Tab Navigation          ││
│  │  └────┬────┴─────────┴─────────┘                            ││
│  │       │                                                      ││
│  │       ▼                                                      ││
│  │  ┌─────────────────────────────┐                            ││
│  │  │ 🏠 Rent         $1,200  ✓  │ ← Item (Active)            ││
│  │  │ 🍕 Dining Out     $300  ✓  │                             ││
│  │  │ 🎮 Gaming         $100  ○  │ ← Item (Frozen)            ││
│  │  │ ☰ (drag handle)            │                             ││
│  │  └─────────────────────────────┘                            ││
│  │                                                              ││
│  │  ┌─────────────────────────────┐                            ││
│  │  │ Remaining: $850            │ ← Always Visible Summary   ││
│  │  │ [Convert to Savings]       │                             ││
│  │  └─────────────────────────────┘                            ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## 5. Data Model

### 5.1 Entity Relationship Diagram

```
┌─────────────────────┐       ┌─────────────────────┐
│       Plan          │       │      PlanItem       │
├─────────────────────┤       ├─────────────────────┤
│ id: UUID (PK)       │       │ id: UUID (PK)       │
│ name: String        │       │ planId: UUID (FK)   │
│ startDate: Date     │       │ name: String        │
│ endDate: Date       │       │ amount: Decimal     │
│ isRecurring: Bool   │       │ type: ItemType      │
│ recurrenceType: Enum│◄──────│ isFrozen: Bool      │
│ status: PlanStatus  │ 1───N │ sortOrder: Int      │
│ parentPlanId: UUID? │       │ icon: String        │
│ createdAt: Date     │       │ color: String       │
│ updatedAt: Date     │       │ notes: String?      │
│ currencyCode: String│       │ createdAt: Date     │
└─────────────────────┘       │ updatedAt: Date     │
                              └─────────────────────┘
```

### 5.2 Entity Definitions

#### 5.2.1 Plan Entity

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `name` | String | Yes | User-defined plan name (e.g., "December 2025 Budget") |
| `startDate` | Date | Yes | Plan period start date |
| `endDate` | Date | Yes | Plan period end date |
| `isRecurring` | Boolean | Yes | Whether plan repeats on schedule |
| `recurrenceType` | Enum | No | `monthly`, `biweekly`, `weekly`, `custom` |
| `status` | Enum | Yes | `draft`, `active`, `completed`, `archived` |
| `parentPlanId` | UUID | No | Reference to plan this was cloned from |
| `currencyCode` | String | Yes | ISO 4217 currency code (default: device locale) |
| `createdAt` | Date | Yes | Timestamp of creation |
| `updatedAt` | Date | Yes | Timestamp of last modification |

#### 5.2.2 PlanItem Entity

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier |
| `planId` | UUID | Yes | Foreign key to parent Plan |
| `name` | String | Yes | Item name (e.g., "Rent", "Groceries") |
| `amount` | Decimal | Yes | Monetary value (precision: 2 decimal places) |
| `type` | Enum | Yes | `outcome`, `income`, `savings` |
| `isFrozen` | Boolean | Yes | Whether item is excluded from calculations |
| `sortOrder` | Integer | Yes | Display order within type group |
| `icon` | String | No | SF Symbol name or emoji |
| `color` | String | No | Hex color code for visual identification |
| `notes` | String | No | User notes about this item |
| `createdAt` | Date | Yes | Timestamp of creation |
| `updatedAt` | Date | Yes | Timestamp of last modification |

### 5.3 Enumerations

```swift
enum ItemType: String, Codable {
    case outcome    // Expenses - reduces available funds
    case income     // Money coming in - increases available funds
    case savings    // Money set aside - reduces available but tracked separately
}

enum PlanStatus: String, Codable {
    case draft      // Plan is being created, not yet started
    case active     // Current active plan
    case completed  // Plan period has ended
    case archived   // User has archived this plan
}

enum RecurrenceType: String, Codable {
    case monthly    // Repeats every month
    case biweekly   // Repeats every 2 weeks
    case weekly     // Repeats every week
    case custom     // User-defined interval (future feature)
}
```

### 5.4 Calculated Properties

```swift
extension Plan {
    /// Total of all active (non-frozen) income items
    var totalIncome: Decimal {
        items.filter { $0.type == .income && !$0.isFrozen }
             .reduce(0) { $0 + $1.amount }
    }
    
    /// Total of all active (non-frozen) outcome items
    var totalOutcome: Decimal {
        items.filter { $0.type == .outcome && !$0.isFrozen }
             .reduce(0) { $0 + $1.amount }
    }
    
    /// Total of all active (non-frozen) savings items
    var totalSavings: Decimal {
        items.filter { $0.type == .savings && !$0.isFrozen }
             .reduce(0) { $0 + $1.amount }
    }
    
    /// Remaining amount after outcome and savings
    var remainingAmount: Decimal {
        totalIncome - totalOutcome - totalSavings
    }
    
    /// Indicates if plan is balanced (remaining >= 0)
    var isBalanced: Bool {
        remainingAmount >= 0
    }
    
    /// Amount currently frozen (not in calculations)
    var frozenOutcomeTotal: Decimal {
        items.filter { $0.type == .outcome && $0.isFrozen }
             .reduce(0) { $0 + $1.amount }
    }
}
```

---

## 6. Functional Requirements

### 6.1 Plan Management

#### FR-1.1: Create New Plan

| ID | FR-1.1 |
|----|--------|
| **Title** | Create New Spending Plan |
| **Priority** | P0 (Critical) |
| **Description** | User can create a new spending plan with basic configuration |

**Acceptance Criteria:**
- [ ] User can tap "+" or "New Plan" to initiate creation
- [ ] User must provide:
  - Plan name (required, max 50 characters)
  - Start date (required, defaults to today)
  - End date (required, defaults to end of current month)
- [ ] User can optionally set:
  - Recurring toggle (default: off)
  - Recurrence type (if recurring)
  - Currency (defaults to device locale)
- [ ] Plan is created in `draft` status
- [ ] Plan transitions to `active` when user adds first item
- [ ] System generates unique ID for plan
- [ ] System records creation timestamp
- [ ] User is navigated to Plan Detail view after creation

**Business Rules:**
- End date must be after start date
- Plan name must be unique within user's plans
- Maximum 24 plans can exist at any time (12 active + 12 historical)

---

#### FR-1.2: Clone Existing Plan

| ID | FR-1.2 |
|----|--------|
| **Title** | Clone Plan to New Period |
| **Priority** | P0 (Critical) |
| **Description** | User can create a new plan by copying an existing plan's structure |

**Acceptance Criteria:**
- [ ] Clone option available on any plan (current, historical, or upcoming)
- [ ] Clone creates new plan with:
  - All items copied (names, amounts, icons, colors, sort order)
  - All items set to active (isFrozen = false)
  - New date range (defaults to next period based on source plan)
  - Reference to source plan stored in `parentPlanId`
- [ ] User can edit cloned plan immediately
- [ ] Original plan remains unchanged
- [ ] Clone operation completes in < 500ms

**User Flow:**
```
1. User views existing plan
2. User taps "Clone to New Plan" button
3. System displays date picker for new plan period
4. User confirms dates
5. System creates cloned plan
6. User is navigated to new plan in edit mode
```

---

#### FR-1.3: Delete Plan

| ID | FR-1.3 |
|----|--------|
| **Title** | Delete Spending Plan |
| **Priority** | P1 (High) |
| **Description** | User can permanently delete a plan and all associated items |

**Acceptance Criteria:**
- [ ] Delete option available for all plan statuses
- [ ] Confirmation dialog shown before deletion:
  - "Delete [Plan Name]? This will permanently remove this plan and all its items. This action cannot be undone."
- [ ] Deletion removes plan and all associated PlanItems
- [ ] Deletion syncs to iCloud (if enabled)
- [ ] User is navigated to Plans List after deletion
- [ ] Undo available for 5 seconds after deletion (toast notification)

**Business Rules:**
- Cannot delete the only active plan (must create new one first)
- Deleting a recurring plan does not delete associated historical plans
- Historical plans can be deleted individually

---

#### FR-1.4: View Historical Plans

| ID | FR-1.4 |
|----|--------|
| **Title** | Navigate Historical Plans |
| **Priority** | P1 (High) |
| **Description** | User can browse and view past plans in read-only mode |

**Acceptance Criteria:**
- [ ] Historical plans displayed in Plans List, grouped by year/month
- [ ] Historical plan detail view shows all items and summary
- [ ] All fields are read-only (no editing)
- [ ] "Clone" action available on historical plans
- [ ] "Delete" action available on historical plans
- [ ] Visual indicator differentiates historical from active plans
- [ ] Historical plans sorted by date (most recent first)

---

### 6.2 Plan Item Management

#### FR-2.1: Add Plan Item

| ID | FR-2.1 |
|----|--------|
| **Title** | Add Item to Plan |
| **Priority** | P0 (Critical) |
| **Description** | User can add outcome, income, or savings items to a plan |

**Acceptance Criteria:**
- [ ] Add button available in each tab (Outcome, Income, Savings)
- [ ] User must provide:
  - Item name (required, max 30 characters)
  - Amount (required, entered via custom calculator)
- [ ] User can optionally set:
  - Icon (SF Symbol picker or emoji)
  - Color (preset palette)
  - Notes (max 200 characters)
- [ ] New items added at bottom of list (highest sortOrder + 1)
- [ ] New items are active by default (isFrozen = false)
- [ ] Summary bar updates immediately after save
- [ ] Item can be created with amount of $0.00

**Default Suggestions (First-time users):**
System suggests common items based on type:
- **Outcome:** Rent/Mortgage, Utilities, Groceries, Transportation, Entertainment
- **Income:** Salary, Freelance, Side Hustle, Investments
- **Savings:** Emergency Fund, Vacation, Large Purchase

---

#### FR-2.2: Edit Plan Item

| ID | FR-2.2 |
|----|--------|
| **Title** | Edit Existing Item |
| **Priority** | P0 (Critical) |
| **Description** | User can modify any field of an existing plan item |

**Acceptance Criteria:**
- [ ] Tap on item opens edit view
- [ ] All fields are editable (name, amount, icon, color, notes)
- [ ] Changes save automatically on dismiss
- [ ] Summary bar updates immediately
- [ ] "Delete Item" option available in edit view
- [ ] Swipe-to-delete available in list view (with confirmation)

---

#### FR-2.3: Freeze/Unfreeze Item

| ID | FR-2.3 |
|----|--------|
| **Title** | Toggle Item Freeze State |
| **Priority** | P0 (Critical) |
| **Description** | User can freeze items to exclude them from calculations |

**Acceptance Criteria:**
- [ ] Toggle switch visible on each item in list view
- [ ] Frozen items:
  - Display with reduced opacity (50%)
  - Show "frozen" indicator icon
  - Are excluded from total calculations
  - Remain in their sort position
- [ ] Unfrozen items:
  - Display at full opacity
  - Are included in total calculations
- [ ] Toggle action triggers immediate recalculation
- [ ] Toggle action triggers subtle haptic feedback
- [ ] Frozen total displayed separately: "Frozen: $X,XXX"

**Visual States:**
```
┌────────────────────────────────────────┐
│ 🏠 Rent                    $1,200  [✓] │  ← Active (full opacity)
├────────────────────────────────────────┤
│ 🎮 Gaming (frozen)           $100  [○] │  ← Frozen (50% opacity)
└────────────────────────────────────────┘
```

---

#### FR-2.4: Reorder Items

| ID | FR-2.4 |
|----|--------|
| **Title** | Manual Item Reordering |
| **Priority** | P1 (High) |
| **Description** | User can drag-and-drop items to reorder by priority |

**Acceptance Criteria:**
- [ ] Drag handle visible on each item (☰ icon)
- [ ] Long-press on item initiates drag mode
- [ ] Items can be reordered within their type group only
- [ ] Visual feedback during drag (item lifts, shadow, drop zone indicator)
- [ ] Haptic feedback on pickup and drop
- [ ] Sort order persists after app restart
- [ ] Reordering works in both compact and expanded list views

---

#### FR-2.5: Delete Plan Item

| ID | FR-2.5 |
|----|--------|
| **Title** | Remove Item from Plan |
| **Priority** | P1 (High) |
| **Description** | User can permanently remove an item from a plan |

**Acceptance Criteria:**
- [ ] Swipe left on item reveals delete action
- [ ] Delete button in item edit view
- [ ] Confirmation not required for individual items (undo available)
- [ ] Undo available for 5 seconds via toast notification
- [ ] Summary bar updates immediately after deletion
- [ ] Remaining items' sort order adjusts automatically

---

### 6.3 Summary & Calculations

#### FR-3.1: Real-time Summary Display

| ID | FR-3.1 |
|----|--------|
| **Title** | Plan Summary Bar |
| **Priority** | P0 (Critical) |
| **Description** | Always-visible summary showing financial calculations |

**Acceptance Criteria:**
- [ ] Summary bar fixed at bottom of Plan Detail view
- [ ] Displays:
  - Total Income (sum of active income items)
  - Total Outcome (sum of active outcome items)
  - Total Savings (sum of active savings items)
  - **Remaining Amount** (Income - Outcome - Savings)
- [ ] Remaining amount color-coded:
  - Green: Positive (≥ $0)
  - Red: Negative (< $0)
  - Yellow: Low (< 5% of income)
- [ ] Updates in real-time (< 100ms after any change)
- [ ] Tapping summary expands to full breakdown view

**Summary Bar Layout:**
```
┌─────────────────────────────────────────────────────┐
│  Income        Outcome       Savings     REMAINING  │
│  $4,200        $2,950        $400        $850       │
│  ─────────────────────────────────────  ───────────│
│  [Convert $850 to Savings]                         │
└─────────────────────────────────────────────────────┘
```

---

#### FR-3.2: Convert Remaining to Savings

| ID | FR-3.2 |
|----|--------|
| **Title** | Transfer Remaining to Savings |
| **Priority** | P1 (High) |
| **Description** | User can convert remaining amount into a savings item |

**Acceptance Criteria:**
- [ ] "Convert to Savings" button visible when remaining > 0
- [ ] Tapping button creates new savings item:
  - Name: "Extra Savings" (editable)
  - Amount: Current remaining amount
  - Type: savings
- [ ] After conversion, remaining amount becomes $0
- [ ] User can edit the created savings item normally
- [ ] Button disabled when remaining ≤ 0

---

#### FR-3.3: Carry Forward Savings

| ID | FR-3.3 |
|----|--------|
| **Title** | Use Previous Savings as Income |
| **Priority** | P2 (Medium) |
| **Description** | User can add previous plan's savings as income in new plan |

**Acceptance Criteria:**
- [ ] Option available when creating/cloning new plan
- [ ] Shows previous plan's total savings amount
- [ ] Creates income item: "Carried from [Previous Plan Name]"
- [ ] User can edit or delete this item like any other
- [ ] Works with both manual creation and clone operation

---

### 6.4 Recurring Plans

#### FR-4.1: Configure Recurring Plan

| ID | FR-4.1 |
|----|--------|
| **Title** | Set Up Plan Recurrence |
| **Priority** | P1 (High) |
| **Description** | User can configure a plan to repeat on a schedule |

**Acceptance Criteria:**
- [ ] "Recurring" toggle in plan settings
- [ ] When enabled, user selects recurrence type:
  - Monthly (same dates each month)
  - Bi-weekly (every 14 days)
  - Weekly (every 7 days)
- [ ] System calculates next occurrence dates
- [ ] Recurring indicator badge shown on plan in list view
- [ ] Recurrence can be disabled at any time

---

#### FR-4.2: Auto-Prompt Clone for Recurring Plans

| ID | FR-4.2 |
|----|--------|
| **Title** | Prompt User to Clone When Period Ends |
| **Priority** | P1 (High) |
| **Description** | System prompts user to create next period plan from recurring plan |

**Acceptance Criteria:**
- [ ] 3 days before plan end date, show notification
- [ ] Notification: "Your [Plan Name] ends soon. Ready to plan for [Next Period]?"
- [ ] Tapping notification opens clone flow with dates pre-filled
- [ ] User can dismiss and clone manually later
- [ ] Prompt appears in-app on plan list if notification dismissed
- [ ] System does NOT auto-create plans without user action

---

### 6.5 Data Sync & Export

#### FR-5.1: iCloud Sync

| ID | FR-5.1 |
|----|--------|
| **Title** | Synchronize Data with iCloud |
| **Priority** | P1 (High) |
| **Description** | User's data syncs across all their Apple devices |

**Acceptance Criteria:**
- [ ] Uses CloudKit with private database
- [ ] Sync enabled by default (if user signed into iCloud)
- [ ] Toggle to disable sync in Settings
- [ ] Sync occurs:
  - On app launch
  - When changes are made
  - On app backgrounding
  - Periodically (every 15 minutes when active)
- [ ] Conflict resolution: Last write wins (by timestamp)
- [ ] Offline changes queue and sync when connected
- [ ] Sync status indicator in Settings
- [ ] Error handling for sync failures (retry with backoff)

**Privacy:**
- All data stored in user's private CloudKit container
- No data shared with other users
- No data accessible to app developer

---

#### FR-5.2: Export to Excel

| ID | FR-5.2 |
|----|--------|
| **Title** | Export All Data to Excel File |
| **Priority** | P2 (Medium) |
| **Description** | User can export complete data history as Excel file |

**Acceptance Criteria:**
- [ ] Export option in Settings > Data Export
- [ ] In-app purchase required: $6.99 (one-time, unlocks permanently)
- [ ] Export includes:
  - All plans (active, completed, archived)
  - All items with all fields
  - Summary calculations per plan
- [ ] File format: .xlsx (Excel 2007+ compatible)
- [ ] File structure:
  - Sheet 1: Plans Overview
  - Sheet 2: All Items (with Plan reference)
  - Sheet 3: Monthly Summaries
- [ ] Export via iOS Share Sheet
- [ ] Export completes in < 10 seconds for typical data size

**Excel Structure:**

*Sheet 1: Plans*
| Plan Name | Start Date | End Date | Status | Total Income | Total Outcome | Total Savings | Remaining |
|-----------|------------|----------|--------|--------------|---------------|---------------|-----------|

*Sheet 2: Items*
| Plan Name | Item Name | Type | Amount | Frozen | Sort Order | Notes |
|-----------|-----------|------|--------|--------|------------|-------|

---

### 6.6 Custom Calculator

#### FR-6.1: In-App Calculator Input

| ID | FR-6.1 |
|----|--------|
| **Title** | Custom Calculator for Amount Entry |
| **Priority** | P0 (Critical) |
| **Description** | All monetary amounts entered via custom calculator, not system keyboard |

**Acceptance Criteria:**
- [ ] Tapping any amount field opens calculator modal
- [ ] Calculator displays:
  - Current value (large, prominent)
  - Number pad (0-9)
  - Decimal point button
  - Backspace/Clear button
  - Basic operations (+, -, ×, ÷) for quick math
  - "Done" button to confirm
- [ ] Supports expressions: "1500 + 200" evaluates to 1700
- [ ] Maximum value: 999,999,999.99
- [ ] Minimum value: 0.00
- [ ] Precision: 2 decimal places
- [ ] Haptic feedback on button taps
- [ ] Large touch targets (minimum 44pt)
- [ ] Currency symbol displayed based on plan currency
- [ ] "Done" triggers validation and closes calculator

**Calculator Layout:**
```
┌─────────────────────────────────┐
│                        $1,500.00 │  ← Display
├─────────────────────────────────┤
│  [ C ]   [ ⌫ ]   [ ÷ ]   [ × ]  │
│  [ 7 ]   [ 8 ]   [ 9 ]   [ − ]  │
│  [ 4 ]   [ 5 ]   [ 6 ]   [ + ]  │
│  [ 1 ]   [ 2 ]   [ 3 ]   [ = ]  │
│  [ 0    ]   [ . ]    [ Done ]   │
└─────────────────────────────────┘
```

---

## 7. User Interface Requirements

### 7.1 Design Principles

| Principle | Implementation |
|-----------|----------------|
| **Clarity** | Financial data displayed with clear hierarchy and grouping |
| **Efficiency** | Common actions require ≤ 2 taps |
| **Feedback** | Immediate visual response to all interactions |
| **Forgiveness** | Undo available for destructive actions |
| **Consistency** | Same patterns used throughout app |

### 7.2 Color System

| Usage | Light Mode | Dark Mode | Notes |
|-------|------------|-----------|-------|
| Positive/Income | #34C759 | #30D158 | System Green |
| Negative/Outcome | #FF3B30 | #FF453A | System Red |
| Savings | #007AFF | #0A84FF | System Blue |
| Warning | #FF9500 | #FF9F0A | System Orange |
| Frozen State | 50% opacity | 50% opacity | Any color |
| Primary Background | #FFFFFF | #000000 | System |
| Secondary Background | #F2F2F7 | #1C1C1E | System |

### 7.3 Typography

| Element | Font | Size | Weight |
|---------|------|------|--------|
| Amount Display (Calculator) | SF Pro Rounded | 48pt | Bold |
| Amount Display (List) | SF Pro Rounded | 20pt | Semibold |
| Section Headers | SF Pro | 13pt | Regular (uppercase) |
| Item Name | SF Pro | 17pt | Regular |
| Summary Labels | SF Pro | 15pt | Regular |
| Summary Values | SF Pro Rounded | 17pt | Semibold |

### 7.4 Spacing & Layout

| Element | Value |
|---------|-------|
| Screen edge padding | 16pt |
| Item vertical spacing | 8pt |
| Section spacing | 24pt |
| Touch target minimum | 44pt × 44pt |
| Card corner radius | 12pt |
| Summary bar height | 100pt |

### 7.5 Animations

| Trigger | Animation | Duration |
|---------|-----------|----------|
| Item toggle (freeze) | Opacity fade | 200ms |
| Summary update | Value counter | 300ms |
| Item reorder | Spring physics | 350ms |
| Calculator open | Slide up | 300ms |
| Plan clone | Progress indicator | 500ms |

### 7.6 Haptic Feedback

| Action | Haptic Type |
|--------|-------------|
| Item freeze toggle | Light impact |
| Item reorder pickup | Medium impact |
| Item reorder drop | Light impact |
| Calculator button tap | Light impact |
| Destructive action | Warning notification |
| Success (save, clone) | Success notification |

---

## 8. Non-Functional Requirements

### 8.1 Performance

| Metric | Target |
|--------|--------|
| App launch (cold) | < 2 seconds |
| App launch (warm) | < 0.5 seconds |
| Plan load time | < 300ms |
| Summary recalculation | < 100ms |
| Clone operation | < 500ms |
| Export generation | < 10 seconds |
| UI frame rate | 60 fps minimum |

### 8.2 Reliability

| Metric | Target |
|--------|--------|
| Crash-free sessions | > 99.5% |
| Data loss incidents | 0 |
| Sync success rate | > 99% |

### 8.3 Security

| Requirement | Implementation |
|-------------|----------------|
| Data at rest | iOS Data Protection (hardware encryption) |
| Data in transit | TLS 1.3 for CloudKit |
| Authentication | Device passcode/biometric (via iOS) |
| No external analytics | No third-party tracking SDKs |
| No server-side storage | All data in user's iCloud |

### 8.4 Accessibility

| Requirement | Implementation |
|-------------|----------------|
| VoiceOver | Full support with meaningful labels |
| Dynamic Type | Support all system sizes (xSmall to AX5) |
| Color contrast | WCAG AA minimum (4.5:1) |
| Reduce Motion | Respect system setting |
| Bold Text | Support system setting |

### 8.5 Localization

**Phase 1 (Launch):**
- English (US)
- Currency: All ISO 4217 currencies

**Phase 2 (Post-Launch):**
- Spanish, French, German, Arabic, Japanese
- RTL layout support

---

## 9. Monetization

### 9.1 Pricing Model

| Tier | Price | Features |
|------|-------|----------|
| **Free Trial** | $0 for 7 days | Full feature access |
| **Monthly** | $5.99/month | Full feature access |
| **Annual** | $49.99/year | Full feature access + 30% savings |
| **Export Add-on** | $6.99 one-time | Excel export functionality |

### 9.2 Free Trial Implementation

- 7-day trial starts on first app launch
- All features available during trial
- Trial countdown displayed in Settings
- Soft paywall at day 5 (reminder notification)
- Hard paywall at day 8 (must subscribe to continue)
- Historical data remains viewable after trial expires
- New plans cannot be created without subscription

### 9.3 Paywall Trigger Points

| Trigger | Action |
|---------|--------|
| Trial expired + create plan | Show paywall |
| Trial expired + edit plan | Show paywall |
| Export button (not purchased) | Show export purchase |
| Settings > Subscription | Show subscription options |

### 9.4 In-App Purchase IDs

| ID | Type | Price |
|----|------|-------|
| `com.spendit.subscription.monthly` | Auto-renewable | $5.99 |
| `com.spendit.subscription.annual` | Auto-renewable | $49.99 |
| `com.spendit.export.excel` | Non-consumable | $6.99 |

---

## 10. Edge Cases & Error Handling

### 10.1 Edge Cases

| Scenario | Expected Behavior |
|----------|-------------------|
| Plan with no items | Display empty state with "Add your first item" prompt |
| All items frozen | Show $0 total with note "All items frozen" |
| Negative remaining | Allow (user may be planning deficit); highlight in red |
| Clone plan with 0 items | Clone succeeds with empty item list |
| Delete last plan | Prompt to create new plan before deletion completes |
| Very large amounts | Support up to $999,999,999.99; show abbreviated in lists |
| Currency change mid-plan | Not allowed; must create new plan for new currency |
| 100+ items in plan | Paginate list; lazy load for performance |
| Sync conflict | Last-write-wins; log conflict for debugging |
| Export with 1000+ items | Show progress indicator; allow background processing |

### 10.2 Error Messages

| Error | User Message | Recovery Action |
|-------|--------------|-----------------|
| iCloud unavailable | "Unable to sync. Check your iCloud settings." | Link to Settings |
| Export failed | "Export failed. Please try again." | Retry button |
| Network timeout | "Connection timeout. Data saved locally." | Auto-retry |
| Invalid amount | "Please enter a valid amount." | Return to calculator |
| Duplicate plan name | "A plan with this name exists. Choose another." | Focus name field |
| Storage full | "Device storage full. Delete unused plans." | Link to plan list |

### 10.3 Offline Behavior

| Feature | Offline Behavior |
|---------|------------------|
| View plans | Full functionality |
| Create/edit plans | Full functionality; queued for sync |
| Clone plans | Full functionality; queued for sync |
| Delete plans | Full functionality; queued for sync |
| Export | Full functionality (local file) |
| Subscription verification | Grace period of 7 days |

---

## 11. Future Considerations

### 11.1 Phase 2 Features (Post-Launch)

| Feature | Priority | Rationale |
|---------|----------|-----------|
| Widget support | High | Daily engagement driver |
| Siri Shortcuts | High | "Hey Siri, what's my remaining budget?" |
| Apple Watch companion | Medium | Quick balance checks |
| Spending insights | Medium | "You spend 20% more on dining in Dec" |
| Category templates | Medium | Pre-built plans for common scenarios |
| Family sharing | Low | Shared plans for couples/families |

### 11.2 Technical Debt Considerations

| Item | Recommendation |
|------|----------------|
| Migration strategy | Plan for Core Data model versioning from v1 |
| Analytics | Consider privacy-respecting analytics post-launch |
| A/B testing | Infrastructure for paywall optimization |
| Localization | String extraction from day 1 |

---

## 12. Appendix

### 12.1 Glossary

| Term | Definition |
|------|------------|
| **Plan** | A spending plan for a specific time period |
| **Outcome** | An expense item that reduces available funds |
| **Income** | A money source that increases available funds |
| **Savings** | Money set aside, tracked separately from spending |
| **Frozen** | An item excluded from calculations |
| **Clone** | Creating a new plan based on an existing plan's structure |
| **Remaining** | Income minus Outcome minus Savings |

### 12.2 Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | Dec 19, 2025 | Product Team | Initial draft |

### 12.3 Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Product Owner | | | |
| Engineering Lead | | | |
| Design Lead | | | |
| QA Lead | | | |

---

## Appendix A: User Flow Diagrams

### A.1 First-Time User Experience

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Launch    │────▶│   Welcome   │────▶│ Create First│
│    App      │     │   Screen    │     │    Plan     │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                    ┌─────────────┐            │
                    │ Add First   │◀───────────┘
                    │ Income Item │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ Add Outcome │
                    │   Items     │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Review    │
                    │   Summary   │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Plan List  │
                    │   (Home)    │
                    └─────────────┘
```

### A.2 Monthly Clone Flow

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Existing   │────▶│   Clone     │────▶│ Adjust New  │
│    Plan     │     │   Action    │     │   Dates     │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                    ┌─────────────┐            │
                    │  New Plan   │◀───────────┘
                    │  (Editable) │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │ Adjust Items│
                    │  as Needed  │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │   Done!     │
                    │  Ready to   │
                    │    Use      │
                    └─────────────┘
```

---

## Appendix B: Sample Data

### B.1 Example Plan

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "December 2025 Budget",
  "startDate": "2025-12-01",
  "endDate": "2025-12-31",
  "isRecurring": true,
  "recurrenceType": "monthly",
  "status": "active",
  "currencyCode": "USD",
  "items": [
    {
      "id": "item-001",
      "name": "Salary",
      "amount": 4200.00,
      "type": "income",
      "isFrozen": false,
      "sortOrder": 0,
      "icon": "dollarsign.circle"
    },
    {
      "id": "item-002",
      "name": "Rent",
      "amount": 1200.00,
      "type": "outcome",
      "isFrozen": false,
      "sortOrder": 0,
      "icon": "house"
    },
    {
      "id": "item-003",
      "name": "Groceries",
      "amount": 400.00,
      "type": "outcome",
      "isFrozen": false,
      "sortOrder": 1,
      "icon": "cart"
    },
    {
      "id": "item-004",
      "name": "Gaming Subscription",
      "amount": 100.00,
      "type": "outcome",
      "isFrozen": true,
      "sortOrder": 2,
      "icon": "gamecontroller"
    },
    {
      "id": "item-005",
      "name": "Emergency Fund",
      "amount": 500.00,
      "type": "savings",
      "isFrozen": false,
      "sortOrder": 0,
      "icon": "shield"
    }
  ]
}
```

### B.2 Calculated Values for Example

| Metric | Calculation | Value |
|--------|-------------|-------|
| Total Income | 4200 | $4,200.00 |
| Total Outcome | 1200 + 400 (Gaming frozen) | $1,600.00 |
| Total Savings | 500 | $500.00 |
| **Remaining** | 4200 - 1600 - 500 | **$2,100.00** |
| Frozen Total | 100 | $100.00 |

---

*End of Product Requirements Document*
