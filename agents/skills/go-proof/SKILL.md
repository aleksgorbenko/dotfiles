---
name: go-proof
description: >
  Run this skill when the user wants a build proof screenshot for a Go project.
  Trigger on phrases like "go proof", "build proof", "copy build screenshot",
  "proof of build", or "take build screenshot".
---

# Go Build Proof Skill

Compile the current Go project and copy a screenshot of the result to the clipboard,
ready to paste into a PR body.

## Steps

1. Verify `go.mod` exists in the current working directory. If not, inform the user this is not a Go project.

2. Run the proof script:
   ```bash
   ~/.claude/scripts/go-proof.sh
   ```

3. Report the outcome to the user:
   - On success: confirm ✅ build passed and that the snapshot is in their clipboard
   - On failure: show the build errors and confirm the snapshot is in their clipboard

## Notes

- The script uses `codesnap` to render the output as a PNG image and copy it directly to the clipboard
- The user can paste the image directly into a GitHub PR body
- The snapshot includes the module name, timestamp, and build result
- Requires `codesnap` to be installed (`brew install codesnap`)
