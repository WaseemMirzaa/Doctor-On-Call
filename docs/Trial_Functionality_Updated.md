# Trial Functionality - Updated Model

## Overview
The trial system has been updated to provide a better user experience:
- **Days 1-7**: Unlimited access to all features
- **Day 8+**: Limited to 3 items per day (after trial expires)

## Previous Model vs New Model

### Previous Model (Old)
- ❌ During 7-day trial: Users limited to 3 items/day
- Users had to count their usage even during trial period
- Could hit daily limit during "free trial"

### New Model (Current)
- ✅ During 7-day trial: **Unlimited access** to all features
- No counting or restrictions during first 7 days
- After trial expires: 3 items/day limit enforced

## Implementation Details

### Key Constants
```dart
static const int freeTrialDays = 7;
static const int dailyAccessLimitAfterTrial = 3; // Only applies AFTER trial
```

### Access Logic

#### During Trial (Days 1-7)
- `isInFreeTrial()` returns `true`
- `canAccessContent()` returns `true` (no restrictions)
- `getRemainingDailyAccesses()` returns `-1` (unlimited)
- `getAccessStatusMessage()` shows "Unlimited Access (Trial Day X/7)"
- Daily access counter is **NOT** incremented

#### After Trial (Day 8+)
- `isInFreeTrial()` returns `false`
- `canAccessContent()` checks if `dailyAccessCount < 3`
- `getRemainingDailyAccesses()` returns actual count (0-3)
- `getAccessStatusMessage()` shows "Trial Ended • X/3 free today"
- Daily access counter **IS** incremented on each access

### Daily Reset
- Counter resets at midnight UTC
- Managed by `_resetDailyCountIfNeeded()` method
- Checks last access date vs current date

## Updated Components

### 1. SubscriptionManagerService
**File**: `lib/app/services/subscription_manager_service.dart`

**Changes**:
- Removed old constants: `maxFreeViews`, `dailyAccessLimit`
- Added new constant: `dailyAccessLimitAfterTrial = 3`
- Updated `canAccessContent()`: Return `true` during trial (unlimited)
- Updated `getRemainingDailyAccesses()`: Return `-1` during trial
- Updated `getAccessStatusMessage()`: Show "Unlimited Access" during trial
- Removed legacy methods: `getRemainingFreeViews()`, `incrementViewCount()`

### 2. SubscriptionAccessHelper
**File**: `lib/app/helpers/subscription_access_helper.dart`

**Changes**:
- Updated `checkAccessAndNavigate()`:
  - Only increments counter when `!isPremium && !isInTrial`
  - During trial: No counting, unlimited access
  - After trial: Count and enforce 3/day limit

**Before**:
```dart
if (!isPremium && isInTrial) {
  await incrementDailyAccessCount(); // Wrong: counted during trial
}
```

**After**:
```dart
if (!isPremium && !isInTrial) {
  await incrementDailyAccessCount(); // Correct: only after trial
}
```

### 3. SubscriptionAccessMixin
**File**: `lib/app/mixins/subscription_access_mixin.dart`

**Changes**:
- Updated `checkAndIncrementAccess()`:
  - Checks both `isPremium` and `isInTrial` before incrementing
  - Only increments for non-premium users after trial expires

### 4. AccessLimitDialog
**File**: `lib/app/widgets/access_limit_dialog.dart`

**Changes**:
- Updated to use `dailyAccessLimitAfterTrial` constant
- Removed `_remainingDays` field (no longer needed in dialog)
- Simplified message: Shows trial expiry or daily limit reached

## User Experience Flow

### Scenario 1: New User (Day 1)
1. User installs app
2. Trial starts automatically
3. User can access unlimited items for 7 days
4. Status shows: "Unlimited Access (Trial Day 1/7)"
5. No access counter incremented

### Scenario 2: Trial User (Day 5)
1. User still within 7-day trial
2. Can access unlimited items
3. Status shows: "Unlimited Access (Trial Day 5/7)"
4. No daily limits enforced

### Scenario 3: Post-Trial User (Day 8)
1. Trial has expired
2. User limited to 3 items per day
3. Status shows: "Trial Ended • 3/3 free today"
4. Counter increments on each access
5. Blocked after 3rd item until midnight

### Scenario 4: Premium User (Any Day)
1. User purchased lifetime plan
2. Unlimited access forever
3. Status shows: "Lifetime Access"
4. No counting, no restrictions

## Testing Checklist

### Trial Period (Days 1-7)
- [ ] User can access unlimited items
- [ ] Status shows "Unlimited Access (Trial Day X/7)"
- [ ] No "daily limit" dialogs appear
- [ ] `getRemainingDailyAccesses()` returns `-1`
- [ ] Daily counter does NOT increment

### Post-Trial Period (Day 8+)
- [ ] User limited to 3 items per day
- [ ] Status shows "Trial Ended • X/3 free today"
- [ ] Access blocked after 3rd item
- [ ] Dialog shows correct message
- [ ] Counter resets at midnight

### Premium Users
- [ ] Unlimited access at all times
- [ ] No counting or restrictions
- [ ] Status shows "Lifetime Access"

## Migration Notes

### For Existing Users
If users had the old model installed:
- Trial start date remains unchanged
- If within first 7 days: Now have unlimited access (upgrade)
- If past 7 days: 3/day limit applies (same as before)
- Daily counter resets properly

### No Data Migration Needed
- Uses same SharedPreferences keys
- `trial_start_date` remains the same
- `daily_access_count` resets daily
- No breaking changes to data structure

## Code References

### Access Check (Main Entry Point)
```dart
// lib/app/helpers/subscription_access_helper.dart
await SubscriptionAccessHelper.checkAccessAndNavigate(
  routeName: Routes.DETAIL,
  arguments: item,
  contentType: 'clinical_presentation',
);
```

### Status Display
```dart
// lib/app/modules/home/controllers/home_controller.dart
final status = await SubscriptionManagerService.getAccessStatusMessage();
// Returns:
// - "Unlimited Access (Trial Day 3/7)" (during trial)
// - "Trial Ended • 2/3 free today" (after trial)
// - "Lifetime Access" (premium)
```

### Access Control Logic
```dart
// lib/app/services/subscription_manager_service.dart
static Future<bool> canAccessContent() async {
  if (await isPremiumUser()) return true;
  
  if (await isInFreeTrial()) {
    return true; // Unlimited during trial
  }
  
  // After trial: check 3/day limit
  final dailyCount = await getDailyAccessCount();
  return dailyCount < dailyAccessLimitAfterTrial;
}
```

## Summary

The updated trial model provides:
- ✅ Better user acquisition (7 days unlimited)
- ✅ Clear value demonstration (users can explore fully)
- ✅ Smooth transition to 3/day limit after trial
- ✅ Optimized counting (no overhead during trial)
- ✅ Consistent user experience across all access points

This aligns with modern SaaS best practices where trials provide full access to demonstrate value before converting to limited free tier or paid subscription.
