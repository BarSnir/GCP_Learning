import os
import sys
import time

job = os.environ.get("CLOUD_RUN_JOB")
execution = os.environ.get("CLOUD_RUN_EXECUTION")

task_index = int(os.environ.get("CLOUD_RUN_TASK_INDEX", "0"))
task_count = int(os.environ.get("CLOUD_RUN_TASK_COUNT", "1"))
attempt = int(os.environ.get("CLOUD_RUN_TASK_ATTEMPT", "0"))

print(f"Job: {job}")
print(f"Execution: {execution}")
print(f"Task: {task_index}/{task_count}")
print(f"Attempt: {attempt}")

print("Starting batch work...")

time.sleep(3)

# Simulate a transient failure:
# Task 2 fails only on its first attempt.
if task_index == 2 and attempt == 0:
    print("Simulated transient failure on Task 2")
    sys.exit(1)

print(f"Task {task_index} completed successfully.")
sys.exit(0)