# Core System Files

Core engine files for IP Limit and Quota Management system.

## Files

### xray-iplimit.sh (29K, 821 lines)
Main engine containing all IP limit and quota functions.

**Functions:**
- `set_limit()` - Set IP limit for user
- `lock_user()` - Lock user manually
- `unlock_user()` - Unlock user
- `show_status()` - Show IP limit status
- `list_users()` - List all users with limits
- `set_quota()` - Set quota limit
- `check_quota()` - Check quota usage
- `show_quota_status()` - Show all quotas
- `reset_quota()` - Reset user quota
- `monitor_iplimit()` - Monitor IP violations
- `monitor_quota()` - Monitor quota usage

**Installation:**
```bash
cp xray-iplimit.sh /usr/bin/xray-iplimit
chmod +x /usr/bin/xray-iplimit
```

### menu-quota.sh (7.9K, 236 lines)
Interactive menu for quota management (10 options).

**Installation:**
```bash
cp menu-quota.sh /usr/bin/menu-quota
chmod +x /usr/bin/menu-quota
```

### menu-xray-iplimit.sh (6.2K, 178 lines)
Interactive menu for IP limit management (13 options).

**Installation:**
```bash
cp menu-xray-iplimit.sh /usr/bin/menu-xray-iplimit
chmod +x /usr/bin/menu-xray-iplimit
```

## Dependencies

- `/var/lib/xray-iplimit/` - Data directory
- `/var/log/xray/` - Log directory
- `/etc/cron.d/xray-iplimit` - Cron jobs

## Usage

```bash
# IP Limit commands
xray-iplimit set <user> <max_ip> <lock_min>
xray-iplimit status
xray-iplimit list

# Quota commands
xray-iplimit quota-set <user> <quota_gb>
xray-iplimit quota-check <user>
xray-iplimit quota-status

# Interactive menus
menu-quota
menu-xray-iplimit
```
