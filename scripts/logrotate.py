#!/usr/bin/env python3
"""
Simple logrotate script in Python
Usage: python3 scripts/logrotate.py /path/to/logs ./logrotate.log 5
"""

import os, sys, gzip, shutil, datetime

if len(sys.argv) != 4:
    print("Usage: python3 logrotate.py <log_dir> <log_file> <max_size_mb>")
    sys.exit(1)

log_dir = sys.argv[1]
log_file = sys.argv[2]
max_size = int(sys.argv[3]) * 1024 * 1024
date_str = datetime.datetime.now().strftime("%Y%m%d-%H%M%S")

def log_action(msg):
    with open(log_file, "a") as lf:
        lf.write(f"[{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {msg}\n")

if not os.path.isdir(log_dir):
    print(f"Error: {log_dir} is not a directory")
    sys.exit(1)

for fname in os.listdir(log_dir):
    if fname.endswith(".log"):
        fpath = os.path.join(log_dir, fname)
        size = os.path.getsize(fpath)
        if size > max_size:
            archive = f"{fpath}-{date_str}.gz"
            with open(fpath, "rb") as f_in, gzip.open(archive, "wb") as f_out:
                shutil.copyfileobj(f_in, f_out)
            open(fpath, "w").close()  # truncate
            log_action(f"Rotated {fpath} ({size} bytes) -> {archive}")
