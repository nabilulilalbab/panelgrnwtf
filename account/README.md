# Account Creation Scripts

Scripts for creating user accounts with IP limit and quota configuration.

## Modified Scripts (Include IP & Quota Input)

### add-ws.sh - Vmess Account Creation
Creates Vmess account with automatic IP limit and quota setup.

**New Features:**
- IP Limit input (default: 2)
- Quota limit input (default: 10 GB)
- Lock duration input (default: 60 min)
- Auto-set limits after creation
- Display IP & quota in output
- Expired date at bottom

**Usage:**
```bash
add-ws
# Follow prompts for username, expired, IP limit, quota
```

### add-vless.sh - Vless Account Creation
Same features as add-ws.sh for Vless accounts.

### add-tr.sh - Trojan Account Creation
Same features as add-ws.sh for Trojan accounts.

### Other Account Scripts
- add-ssws.sh - Shadowsocks (basic, no limits)
- add-socks.sh - Socks5 (basic, no limits)
- add-trgo.sh - Trojan-GO (basic, no limits)

## Example Flow

```
Add Xray/Vmess Account
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

User: testuser
Expired (days): 30

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  IP Limit & Quota Configuration
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

IP Limit (max IP, default=2, 0=unlimited): 3
Quota (GB, default=10, 0=unlimited): 50
Lock duration (minutes, default=60): 120

Creating account...
✓ Account created
✓ IP Limit set: Max 3 IP (Lock: 120 minutes)
✓ Quota set: 50 GB

[Account details displayed]

IP Limit : Max 3 IP (Lock: 120 minutes)
Quota : 50 GB
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Expired On : 2026-01-26
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Installation

These scripts are automatically installed by setup-full.sh to `/usr/bin/`
