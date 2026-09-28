## Lessons Learned

- Cloud Run Worker Pools are designed for continuous background workloads.
- Worker Pools do not expose a load-balanced HTTP endpoint.
- Unlike Jobs, workers are expected to keep running instead of exiting after completing one task.
- Manual scaling controls how many worker instances run continuously.
- Changing the manual instance count does not require creating a new revision.
- Scaling from 2 to 4 workers increases background processing capacity.
- Scaling to 0 stops all worker instances while keeping the Worker Pool resource and revision.
- Worker Pools are useful for workloads such as Kafka consumers, queue consumers, and long-running background processors.
- Running worker instances consume resources even when they are idle, so manual scaling has a direct FinOps impact.
- Worker Pool stdout and stderr are available through Cloud Logging.