---
title: Cache vs Buffer
---

## Cache
Store data for reuse --- data saved to avoid recomputing or re-fetching
## Buffer 
Store data in transit 

I/O Buffer 
```
Your app writes data:
app → [buffer] → disk

Without buffer:              With buffer:
write 1 byte  → disk         collect 1000 writes in buffer
write 1 byte  → disk    →    flush to disk in one operation
write 1 byte  → disk         much faster — fewer disk I/Os
(thousands of slow trips)    (one fast trip)
```