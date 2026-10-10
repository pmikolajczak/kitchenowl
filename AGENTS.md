# KitchenOwl family fork
Read docs/PROJECT_VISION.md and docs/DEPLOYMENT.md before deployment changes.
No functional changes, AI models, or additional services in iteration 0.
Never touch other stacks, globally prune Docker, or reset/overwrite Tailscale Serve.
Runtime secrets/data/backups live outside this public repository in ../config,
../data, ../backups, ../state. Never commit them or print JWT secret contents.
Use upstream stable releases and preserve upstream remote / AGPL-3.0 license.
Do not create production test accounts without the owner's agreement.
Record untested phone/offline/account flows honestly; source review is not a test.
Use scoped Compose -f deploy/family/compose.yaml commands only.
