import os
import time
import uuid


worker_id = str(uuid.uuid4())[:8]
version = os.environ.get("WORKER_VERSION", "unknown")

print(
    f"Worker started | "
    f"id={worker_id} | "
    f"version={version}",
    flush=True
)

counter = 0

while True:
    counter += 1

    print(
        f"Worker heartbeat | "
        f"id={worker_id} | "
        f"version={version} | "
        f"iteration={counter}",
        flush=True
    )

    time.sleep(10)