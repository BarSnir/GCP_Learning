## Lessons Learned

- Concurrency controls how many requests one Cloud Run instance can handle simultaneously.
- Lower concurrency can create more instances and increase request queuing.
- Higher concurrency can improve instance utilization, but the application must be able to handle parallel requests safely.
- CPU and memory are configured per Cloud Run instance.
- More CPU does not automatically mean proportionally faster requests.
- Request-based billing uses CPU mainly while requests are being processed.
- Instance-based billing keeps CPU available throughout the instance lifecycle and can support background work.
- Request-based billing is usually attractive for bursty or idle-heavy workloads.
- Instance-based billing can make more sense for steady workloads or background processing.
- Changes to CPU, memory, concurrency, or billing settings create a new revision.