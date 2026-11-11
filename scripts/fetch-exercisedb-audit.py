#!/usr/bin/env python3
"""Read-only, resumable snapshot from the official public API, 25 per cursor."""
import json,subprocess,urllib.parse,time
from pathlib import Path
p=Path('third_party/exercisedb/catalog-2026-11-10.json');checkpoint=p.with_suffix('.cursor.json')
rows={x['exerciseId']:x for x in json.loads(p.read_text())} if p.exists() else {}
after=json.loads(checkpoint.read_text())['after'] if checkpoint.exists() else ''
for page in range(200):
 url='https://oss.exercisedb.dev/api/v1/exercises?limit=25'+('&after='+urllib.parse.quote(after) if after else '')
 j=None
 for attempt in range(5):
  result=subprocess.run(['curl','--fail','--silent','--retry','2','--max-time','20',url],capture_output=True)
  try:j=json.loads(result.stdout);assert j.get('success') and j['data'];break
  except:time.sleep(.5)
 if j is None:raise RuntimeError('API snapshot paused at '+after)
 previous=len(rows)
 for row in j['data']:rows[row['exerciseId']]=row
 p.write_text(json.dumps(list(rows.values()),ensure_ascii=False,indent=2)+'\n')
 nextid=j.get('meta',{}).get('nextCursor')
 checkpoint.write_text(json.dumps({'after':nextid or after,'complete':not j.get('meta',{}).get('hasNextPage')}))
 if page%20==0:print('page',page,'unique',len(rows),flush=True)
 if not j.get('meta',{}).get('hasNextPage'):break
 assert nextid and nextid!=after and len(rows)>previous,'Pagination did not progress'
 after=nextid
print('DONE',len(rows))
