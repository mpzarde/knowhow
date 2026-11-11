# Design

## Decisions
- **Karpathy LLM-wiki pattern.** The agent writes and maintains the wiki;
  the user adds sources and asks questions. `raw/` is immutable.
- **One vault per domain** (e.g. personal, a work org), each its own private repo, so
  work and personal material never share a remote.
- **Root router at `~/kb`.** The user never picks a vault: asks search all
  vaults, and `inbox/` files are routed by each vault's Boundaries.
- **Root `CLAUDE.md` names no vaults.** It finds them by listing, so adding a
  vault never changes it.
- **Tooling lives here, not in a vault.** Vaults hold knowledge only.
- **Agents commit, never push.** Pushes are the user's call.
- **Same rules for every vault.** The folder name is the domain; no kinds or
  scope options. Domain detail, if needed, is a line in the vault's CLAUDE.md.
- **Route everywhere by default.** One global pointer to the kb root; opt out
  per session or per project (`kb: ignore <domain>`).
- **Remotes are opt-in** via `--github` (gh, private repo `kb-<name>`).

## Open
- Skills are copied per vault, so they drift from templates and only show as
  slash commands inside a vault. Accepted for now; plain-language asks from
  `~/kb` cover it. Fix later: kb-wide skills symlinked into `~/.claude/skills`.
- Template changes don't reach existing vaults. Update those by hand, or add
  a sync/diff command later.
- Harness work: how other surfaces (Claude app, mobile) reach the vaults.
