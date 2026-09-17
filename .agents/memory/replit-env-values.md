---
name: Replit environment values
description: Non-obvious behavior when storing project configuration through Replit environment settings.
---

Values requested as shared environment variables may be materialized in the
versioned `.replit` file under `[userenv.shared]`. This is unsuitable for
configuration that must not be committed, even when a value is not technically
confidential.

**Why:** A Firebase client configuration was written into the working
`.replit` file after being requested as shared variables.

**How to apply:** Use Replit secrets for Firebase configuration that must stay
out of Git, and keep `.replit` limited to package, workflow, and port settings.