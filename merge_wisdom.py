#!/usr/bin/env python3
"""Merge wisdom batch files into single wisdom_data.json"""
import json
import os

data_dir = os.path.join(os.path.dirname(__file__), "ChiebukuroWalk", "Data")
output = os.path.join(data_dir, "wisdom_data.json")

all_items = []
for i in range(1, 5):
    batch_file = os.path.join(data_dir, f"wisdom_batch{i}.json")
    if os.path.exists(batch_file):
        with open(batch_file, "r", encoding="utf-8") as f:
            items = json.load(f)
            all_items.extend(items)
            print(f"Batch {i}: {len(items)} items")
    else:
        print(f"Batch {i}: NOT FOUND")

# Verify no duplicate IDs
ids = [item["id"] for item in all_items]
dupes = [id for id in ids if ids.count(id) > 1]
if dupes:
    print(f"WARNING: Duplicate IDs found: {set(dupes)}")

# Sort by ID
all_items.sort(key=lambda x: x["id"])

with open(output, "w", encoding="utf-8") as f:
    json.dump(all_items, f, ensure_ascii=False, indent=1)

print(f"\nTotal: {len(all_items)} items -> {output}")
print(f"File size: {os.path.getsize(output):,} bytes")

# Category breakdown
cats = {}
for item in all_items:
    cats[item["category"]] = cats.get(item["category"], 0) + 1
for cat, count in sorted(cats.items(), key=lambda x: -x[1]):
    print(f"  {cat}: {count}")
