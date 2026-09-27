## Lessons Learned

- Cloud Run automatically scales instances based on demand.
- `min_instances = 0` allows scale-to-zero and reduces idle cost.
- `min_instances > 0` keeps warm capacity available and can reduce cold-start latency.
- `max_instances` limits scale-out and helps control cost and downstream load.
- A low concurrency value can force Cloud Run to create more instances under load.
- If demand exceeds the available capacity and `max_instances` is reached, requests may return `429`.
- Scale-out happens as load increases; scale-in happens after demand drops.
- Cold requests can be noticeably slower than warm requests.
- Scaling settings are part of the Cloud Run revision configuration.