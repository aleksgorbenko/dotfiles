# 0007. One word per concept, enforced by lint

- Status: Accepted __DATE__

## Decision
- DOMAIN.md "Enforced Vocabulary" lists the preferred word per concept; each banned synonym is a SwiftLint `custom_rules` entry.
- Localisation keys are window + subject + role (`settingsLaunchAtLoginLabel`); `scripts/check_strings.py` runs in `make lint`.
- The code uses the same term users see.

## Rejected
- Guidance only: drift happens anyway.
