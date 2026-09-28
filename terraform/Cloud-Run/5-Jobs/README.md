## Lessons Learned

- Cloud Run Jobs are designed for finite batch workloads, not HTTP services.
- A Job has no public HTTP endpoint; it runs work and exits.
- Creating a Job does not execute it automatically.
- `task_count` defines how many tasks belong to an execution.
- `parallelism` controls how many tasks may run at the same time.
- Lower parallelism can protect downstream systems from excessive load.
- Each task receives its own `CLOUD_RUN_TASK_INDEX`.
- `CLOUD_RUN_TASK_COUNT` exposes the total number of tasks in the execution.
- A non-zero process exit code marks a task as failed.
- `max_retries` controls how many times a failed task may be retried.
- Retries happen at the task level; successful tasks do not need to run again.
- `CLOUD_RUN_TASK_ATTEMPT` can be used to detect retry attempts.