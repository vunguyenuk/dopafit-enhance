"""Reproduce descriptive US review-sample counts and research indexes.

This is keyword screening, not sentiment classification or population inference.
Manual evidence paraphrases live separately in APP-STORE-EVIDENCE.csv.
"""
import csv
import json
import re
from collections import Counter
from pathlib import Path

BASE = Path(__file__).resolve().parent
SOURCE = BASE / "sources"
RECENT_START = "2026-08-09"
RECENT_END = "2026-11-09"
PATTERNS = {
    "reliability_data": r"crash|freez|glitch|bug|disappear|lost|losing|delet|won.t load|black screen|not sav|doesn.t save|didn.t save",
    "watch_sync": r"watch|sync|healthkit|health connect|apple health|garmin|coros|fitbit",
    "programming_control": r"program|recommend|progress|weight|reps|split|recover|routine|overload|deload|de.load",
    "catalog_search_equipment": r"exercise|equipment|machine|search|variation|plate|barbell|dumbbell",
    "commercial": r"subscri|paywall|pric|expensive|charg|refund|trial|cancel|cost|free version|not free",
    "interaction": r"interface|navigat|keyboard|tap|click|timer|rpe|confus|complicat|annoy|rate|review|music|audio",
    "support": r"support|customer service|ticket|human|bot|reply|response",
    "habit_value": r"consisten|motivat|accountab|confiden|no think|not.*think|guess|decision|show up|personal trainer",
    "social_identity": r"community|friend|team|coach|badge|streak|challenge|record|pr\b",
}
compiled = {k: re.compile(v, re.I) for k, v in PATTERNS.items()}
rows = []
summaries = []
seen = set()
for path in sorted(SOURCE.glob("*-reviews-normalized.json")):
    app_rows = json.loads(path.read_text())
    for row in app_rows:
        key = (row["app"], row["id"])
        assert key not in seen, key
        seen.add(key)
        row["recent_window"] = RECENT_START <= row["date"][:10] <= RECENT_END
        row["keyword_flags"] = [
            tag for tag, pattern in compiled.items()
            if pattern.search(row["title"] + " " + row["body"])
        ]
        rows.append(row)
    recent = [r for r in app_rows if r["recent_window"]]
    summaries.append({
        "app": app_rows[0]["app"], "total": len(app_rows),
        "oldest": min(r["date"][:10] for r in app_rows),
        "newest": max(r["date"][:10] for r in app_rows),
        "recent_window": len(recent),
        "recent_le3stars": sum(int(r["rating"]) <= 3 for r in recent),
        "older": len(app_rows) - len(recent),
        "all_rating_counts": dict(Counter(r["rating"] for r in app_rows)),
        "recent_rating_counts": dict(Counter(r["rating"] for r in recent)),
        "keyword_hits_all_not_sentiment": {
            tag: sum(tag in r["keyword_flags"] for r in app_rows)
            for tag in PATTERNS
        },
    })

with (BASE / "APP-STORE-KEYWORD-INDEX.csv").open("w", newline="") as handle:
    fields = ["app", "id", "date", "rating", "version", "recent_window", "keyword_flags", "feed", "url"]
    writer = csv.DictWriter(handle, fieldnames=fields, extrasaction="ignore")
    writer.writeheader()
    for row in rows:
        writer.writerow({**row, "keyword_flags": ";".join(row["keyword_flags"])})
(BASE / "APP-STORE-SAMPLE-METRICS.json").write_text(json.dumps({
    "method": "All 1200 rows screened by explicit regex; keywords are topic hints, not sentiment or verified bugs.",
    "recent_start": RECENT_START, "recent_end": RECENT_END,
    "total_unique": len(rows), "recent_window": sum(r["recent_window"] for r in rows),
    "apps": summaries,
}, ensure_ascii=False, indent=2))
print(json.dumps(summaries, ensure_ascii=False, indent=2))
