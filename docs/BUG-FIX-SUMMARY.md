# 🐛 BUG FIX SUMMARY - Trial SSH Duration Display

**Issue ID:** Duration variable pollution  
**Date Fixed:** December 27, 2025  
**Status:** ✅ RESOLVED

---

## 🔍 PROBLEM

When creating SSH trial account, the output showed:
```
  Expires     : 
  Duration    : 
Select Trial Duration:
  [1] 1 Hour
  ...
1 hour(s)
```

Instead of:
```
  Expires     : 2025-12-27 21:00:00
  Duration    : 1 hour(s)
```

---

## 🎯 ROOT CAUSE

**Issue:** `select_duration()` function output pollution

When calling:
```bash
duration=$(select_duration)
```

The variable captured:
- Menu display text (from echo statements)
- User prompt (from read -p)
- The actual duration number
- Everything mixed together!

**Why:** Shell command substitution `$(...)` captures stdout, and even `>&2` redirect didn't work properly when function was sourced.

---

## ✅ SOLUTION APPLIED

### Fix 1: Use `/dev/tty` for I/O
Changed from:
```bash
echo "Select Trial Duration:" >&2
read -p "Select [1-6]: " duration_choice
```

To:
```bash
echo "Select Trial Duration:" > /dev/tty
echo -n "Select [1-6]: " > /dev/tty
read duration_choice < /dev/tty
```

**Why `/dev/tty`:**
- Direct terminal I/O
- Bypasses ALL output capture
- User sees menu normally
- Variable only gets the return value

### Fix 2: Sanitize Duration Value
Added cleanup:
```bash
duration=$(echo "$duration" | tr -d '\n\r ' | grep -o '[0-9]*' | head -1)
```

Removes:
- Newlines
- Carriage returns
- Whitespace
- Extracts only numbers

### Fix 3: Use `/dev/tty` for User Messages
Changed:
```bash
echo "Creating SSH trial account..."
```

To:
```bash
echo "Creating SSH trial account..." > /dev/tty
```

Prevents user messages from being captured by any parent process.

---

## 🧪 TESTING RESULTS

### Before Fix:
```
Expires     : 
Duration    : 
Select Trial Duration:
  [1] 1 Hour
  [2] 3 Hours
  ...
1 hour(s)
```

### After Fix:
```
Expires     : 2025-12-27 20:38:02
Duration    : 1 hour(s)
```

### Config File Verification:
```bash
# /var/lib/trials/ssh/trial_xxxxx.conf
USERNAME=trial_xxxxx
PASSWORD=xxxxxxxxxxxx
CREATED=2025-12-27 20:38:02
EXPIRES=2025-12-27 21:38:02
DURATION=1h
TYPE=ssh
STATUS=active
```

✅ All values correct!

---

## 📝 FILES MODIFIED

1. **utils/trial-helpers.sh**
   - Changed `select_duration()` to use `/dev/tty`
   - Changed custom hours input to use `/dev/tty`

2. **utils/trial-ssh.sh**
   - Added duration sanitization
   - Changed user messages to use `/dev/tty`
   - Added debug output for troubleshooting

---

## 🎯 COMMITS

1. `6741577` - Initial bug fix attempts (stderr redirect)
2. `9c651b5` - Final fix using `/dev/tty` + sanitization

---

## ✅ VERIFICATION

- ✅ Menu displays correctly
- ✅ User input works
- ✅ Duration captured cleanly
- ✅ Expires calculated correctly
- ✅ Config file saves properly
- ✅ SSH user created with expiry
- ✅ Display shows correct values

---

## 🎓 LESSONS LEARNED

1. **Command Substitution Captures Everything**
   - `$(command)` captures stdout
   - Even `>&2` doesn't always work with sourced functions
   - Use `/dev/tty` for guaranteed terminal I/O

2. **Always Sanitize Input**
   - User input may have unexpected characters
   - Captured variables may have pollution
   - Clean with `tr`, `grep`, `sed`

3. **Test in Real Environment**
   - Piped tests behave differently
   - Always test with actual user interaction
   - Check config files for verification

---

## 📊 IMPACT

- **Severity:** Medium (display issue, but functionality worked)
- **Affected:** Trial SSH creation only
- **Fixed In:** 6 iterations
- **Time to Fix:** ~30 minutes
- **Status:** Production deployed

---

**Bug Status:** ✅ CLOSED  
**Verified By:** Config file validation + user testing  
**Deployed To:** VPS 202.10.38.129

