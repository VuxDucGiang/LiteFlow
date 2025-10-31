# Dashboard Employee Updates

## Overview
This document describes the UI/UX improvements made to the Employee Dashboard page.

## Changes Made

### 1. Attendance Clock Section - Toggle Button

**Before:**
- Two separate buttons: "Chấm công vào" and "Chấm công ra"
- Both buttons visible at all times

**After:**
- Single toggle button that changes based on state
- Button states:
  - **Not clocked in:** Green button showing "Chấm công vào" with clock icon
  - **Clocked in:** Orange button showing "Chấm công ra" with time icon
  - **Completed:** Gray disabled button showing "Đã chấm công" with check icon

**Benefits:**
- Cleaner, more intuitive interface
- Less visual clutter
- Clear indication of current state
- Better mobile responsiveness

### 2. Secondary Actions Added to Attendance Section

Added two secondary action buttons below the main clock toggle:

1. **Quên chấm công** (Forgot to Clock In)
   - Icon: Error circle
   - Currently shows alert (to be implemented)
   - Allows employees to report missed clock-ins

2. **Xin nghỉ phép** (Leave Request)
   - Icon: Calendar check
   - Opens the leave request modal
   - Fully functional with backend integration

**Styling:**
- Clean, bordered buttons
- Hover effects with blue accent
- Grid layout (2 columns)
- Responsive design

### 3. Quick Actions Section Replaced with Notice Board

**Removed:**
- Quick Actions widget with 4 primary action buttons
- Secondary navigation icons section

**Added:**
- Notice Board widget with:
  - Header with notification icon
  - Scrollable notice list
  - Three types of notices:
    - **Important** (Red) - Critical announcements
    - **General** (Blue) - Regular updates
    - **Info** (Green) - Informational notices
  - "View all" link at bottom

**Notice Item Features:**
- Badge showing notice type
- Date display
- Title and content
- Color-coded left border
- Hover animation
- Click interaction ready

**Sample Notices Included:**
1. Holiday announcement (Important)
2. Clock-in process update (General)
3. Meeting schedule update (Info)

## Files Modified

### 1. `src/main/webapp/dashboard-employee.jsp`

**HTML Changes:**
- Replaced two clock buttons with single toggle button
- Added `attendance-secondary-actions` section
- Replaced `quick-actions` widget with `notice-board` widget
- Added sample notice items

**JavaScript Changes:**
- Removed: `clockIn()` and `clockOut()` functions
- Added: `toggleClock()` function that handles both clock-in and clock-out
- Updated: `loadAttendanceStatus()` to handle toggle button states
- Added: `openForgotClockModal()` placeholder function

### 2. `src/main/webapp/css/dashboard-employee.css`

**New Styles Added:**

```css
/* Toggle Clock Button */
.btn-clock-toggle { ... }
.btn-clock-toggle.clock-out-mode { ... }
.btn-clock-toggle.disabled { ... }

/* Secondary Actions */
.attendance-secondary-actions { ... }
.btn-secondary-action { ... }

/* Notice Board */
.widget.notice-board { ... }
.notice-list { ... }
.notice-item { ... }
.notice-item.important { ... }
.notice-item.general { ... }
.notice-item.info { ... }
.notice-badge { ... }
```

## Toggle Button Logic

The toggle button works as follows:

1. **On Page Load:**
   - Fetch attendance status from API
   - Update button appearance based on status

2. **When Button Clicked:**
   - Check if button has `clock-out-mode` class
   - If yes: Call `/api/timesheet/clock-out`
   - If no: Call `/api/timesheet/clock-in`
   - Show loading message
   - Update UI on success
   - Reload status to refresh button state

3. **Button States:**
   ```javascript
   // Not clocked in
   - Green background
   - "Chấm công vào" text
   - Clock icon
   - Enabled

   // Clocked in (waiting for clock out)
   - Orange background
   - "Chấm công ra" text
   - Time icon
   - Enabled
   - Has 'clock-out-mode' class

   // Both completed
   - Gray background
   - "Đã chấm công" text
   - Check icon
   - Disabled
   ```

## Notice Board Features

### Current Implementation:
- Static sample notices (3 items)
- Three notice types with color coding
- Scrollable list
- Responsive design

### Future Enhancements (Optional):
1. **Backend Integration:**
   - Create Notice/Announcement table in database
   - Create API endpoint to fetch notices
   - Load notices dynamically on page load

2. **Interactive Features:**
   - Click to expand full notice
   - Mark as read functionality
   - Filter by notice type
   - Search notices

3. **Admin Panel:**
   - Create/edit/delete notices
   - Schedule notice publication
   - Target specific departments/employees
   - Attach files to notices

## Responsive Design

All new components are fully responsive:
- Toggle button scales appropriately
- Secondary actions stack on smaller screens
- Notice board adjusts height
- Maintains grid layout integrity

## Browser Compatibility

Tested and working on:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## Usage Instructions

### For Employees:

1. **Clock In/Out:**
   - Click the main button in Attendance Clock section
   - Button color and text will change based on state
   - Confirmation message appears after action

2. **Request Leave:**
   - Click "Xin nghỉ phép" button
   - Fill out the modal form
   - Submit request

3. **Report Forgot Clock-In:**
   - Click "Quên chấm công" button
   - (Feature to be implemented)

4. **View Notices:**
   - Scroll through Notice Board
   - Click "Xem tất cả thông báo" for full list

### For Developers:

**To Implement Forgot Clock-In:**
1. Create modal similar to leave request modal
2. Add form fields (date, time, reason)
3. Create API endpoint for forgot clock-in requests
4. Update `openForgotClockModal()` function

**To Add Backend for Notice Board:**
1. Create database table for notices
2. Create API endpoint `/api/notices/`
3. Add JavaScript function to load notices
4. Replace sample HTML with dynamic content

## Testing Checklist

- [x] Toggle button changes from green to orange after clock-in
- [x] Toggle button becomes gray and disabled after clock-out
- [x] Secondary action buttons have hover effects
- [x] Leave request modal opens from attendance section
- [x] Notice board displays correctly
- [x] Notice items have hover animations
- [x] Scrollbar works in notice list
- [x] Page loads without console errors
- [x] Responsive layout works on mobile

## Performance Impact

- **Minimal** - Removed redundant buttons reduces DOM elements
- **Improved** - Single toggle button simplifies state management
- **Optimized** - CSS animations use transform for better performance

## Accessibility

- All buttons have descriptive text
- Icons have semantic meaning
- Color contrast meets WCAG 2.1 AA standards
- Keyboard navigation supported
- Screen reader friendly

## Notes

- The forgot clock-in feature shows an alert message and needs full implementation
- Notice board currently uses static data; backend integration recommended
- All existing functionality (personal schedule, salary summary, timesheet calendar) remains unchanged
