## Lessons Learned

- A Cloud Run Service can have multiple immutable revisions.
- Changing the container image or revision template creates a new revision.
- Changing only traffic allocation does not create a new revision.
- A new revision can be deployed with 0% traffic.
- Traffic can be gradually shifted between revisions, for example:
  - 90/10
  - 50/50
  - 0/100
- Traffic percentages are probabilistic, so 100 requests do not always produce an exact split.
- Rollback does not require rebuilding the image; traffic can simply be moved back to an existing revision.
- The Cloud Run Service URL stays the same while traffic moves between revisions.