---
name: Firebase rules source synchronization
description: The repository keeps root and firebase copies of Firestore and Storage rules.
---

Both the root Firebase rule files and the copies under `firebase/` must carry the same
security policy. A change in only one copy can leave the documented rules and the
deployable rules inconsistent.

**Why:** The project exposes both locations and does not have a Firebase CLI workflow
that automatically derives one from the other.

**How to apply:** Update both copies together and verify they are byte-for-byte
identical before completing a security-related task.