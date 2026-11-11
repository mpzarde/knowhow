# Knowledge base root

Each subfolder here with its own `CLAUDE.md` is a vault for one domain; the
folder name is the domain. Each vault is a separate git repo, and inside it
that vault's `CLAUDE.md` governs. Find vaults by listing; don't assume names.

## Domains
Use every vault by default. Skip a domain only when the user says to ignore
it, in the session or in the current project's `CLAUDE.md`
(e.g. `kb: ignore personal`).

## Ask
- Read each vault's `index.md`, then follow topic indexes in the relevant ones.
- If the indexes don't answer it, search every vault's `wiki/` and `raw/`
  (page text and file names) before saying it isn't there.
- For "where did I put X" questions, give the vault and file path.
- Cite pages with the vault prefix (`personal/wiki/...`). Say when an answer
  draws on more than one vault.
- To file an answer back, pick one vault and follow its rules.

## Ingest from `inbox/`
- The user drops files in `inbox/`. For each file, read it and pick the vault
  whose domain fits (folder name, `index.md`, existing pages).
- If one vault clearly fits, move the file into its `raw/`, then follow that
  vault's `.claude/skills/ingest/SKILL.md`.
- If none fits, ask whether to create a vault (`setup-kb.sh <name>`). If more
  than one fits, or you're unsure, ask.

## Never
- Link or copy one vault's pages into another vault.
- Push any vault. Commits follow each vault's own rules.
