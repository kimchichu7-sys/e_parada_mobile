#!/usr/bin/env python3
"""
E-Parada: Render Backend Keep-Alive Utility
Pings the Render production backend every 4 minutes to prevent free-tier containers
from sleeping, eliminating the 60-second cold-start freeze for evaluation respondents.
"""

import sys
import time
import urllib.request
import urllib.error
from datetime import datetime

sys.stdout.reconfigure(encoding='utf-8')

TARGET_URL = "https://e-parada.onrender.com/up"
INTERVAL_SECONDS = 240  # 4 minutes (Render sleeps at 15 minutes)

print("=" * 70)
print("     E-PARADA BACKEND KEEP-ALIVE UTILITY (RENDER PRODUCTION)")
print(f"     Target Endpoint: {TARGET_URL}")
print(f"     Ping Interval:   Every {INTERVAL_SECONDS // 60} minutes")
print("     Press Ctrl+C to terminate.")
print("=" * 70)

ping_count = 0
while True:
    ping_count += 1
    now = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    t0 = time.time()
    try:
        req = urllib.request.Request(
            TARGET_URL,
            headers={"User-Agent": "E-Parada-KeepAlive/1.0"}
        )
        with urllib.request.urlopen(req, timeout=30) as response:
            status = response.status
            elapsed_ms = (time.time() - t0) * 1000
            print(f"[{now}] Ping #{ping_count:03d} -> HTTP {status} OK | Latency: {elapsed_ms:.1f} ms | Server Active")
    except urllib.error.HTTPError as e:
        elapsed_ms = (time.time() - t0) * 1000
        print(f"[{now}] Ping #{ping_count:03d} -> HTTP {e.code} | Latency: {elapsed_ms:.1f} ms | Still Active")
    except urllib.error.URLError as e:
        elapsed_ms = (time.time() - t0) * 1000
        print(f"[{now}] Ping #{ping_count:03d} -> Network Error: {e.reason} ({elapsed_ms:.1f} ms)")
    except Exception as e:
        print(f"[{now}] Ping #{ping_count:03d} -> Exception: {e}")

    try:
        time.sleep(INTERVAL_SECONDS)
    except KeyboardInterrupt:
        print("\nKeep-Alive terminated by user.")
        break
