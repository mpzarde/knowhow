# knowhow

Tools to set up a Claude-maintained knowledge base: LLM wikis (Karpathy
pattern) split into domain-segregated vaults, with one place to ask across them.

- **Vaults** hold one domain each (personal, a work org, family history...).
  Each is its own git repo with its own rules, so domains never share a remote.
- **Claude maintains the wiki.** You drop sources in; Claude writes and links
  the pages, cites sources, and commits. It never pushes.
- **One entry point.** From `~/kb` you ask across every vault, and files you
  drop in `inbox/` are routed to the right vault.

```
~/kb/
  CLAUDE.md -> knowhow/templates/root/CLAUDE.md   # router across vaults
  inbox/                                          # drop new sources here
  personal/                                       # a vault (own repo)
    CLAUDE.md                                     # the vault's rules
    raw/                                          # sources, never edited
    wiki/                                         # Claude's pages, by topic
    index.md  log.md  .claude/skills/             # map, history, /ingest /ask /lint
  acme/                                           # another domain
```

## Getting started

**Prerequisites.** The script checks these first. It stops before changing
anything if a required one is missing, and prints install commands
(Homebrew or apt) for anything recommended.

| | Needed for |
|---|---|
| git, with `user.name`/`user.email` set | required: every vault is a repo |
| perl | required: fills in templates (built into macOS) |
| pandoc | required: converts .docx, .epub, .html and other non-text sources for ingest |
| [gh](https://cli.github.com), signed in | required with `--github`; recommended otherwise |
| [Claude Code](https://claude.com/claude-code) | recommended: runs the kb |
| pdftotext (poppler) | recommended: large or scanned PDFs |
| [Obsidian](https://obsidian.md) | optional: browsing vaults |

1. **Get the tools**
   ```
   git clone https://github.com/mpzarde/knowhow.git ~/projects/knowhow
   ```
2. **Create your first vault**
   ```
   ~/projects/knowhow/bin/setup-kb.sh personal --github
   ```
   This creates `~/kb` with the router and `inbox/`, creates `~/kb/personal`
   as a git repo with a first commit, creates a private GitHub repo
   (`kb-personal`) and pushes to it, and adds a pointer to
   `~/.claude/CLAUDE.md` so Claude checks the kb from any project.
   Leave out `--github` to stay local-only.
3. **Add a source.** Drop a file (PDF, doc, note, web clip) in `~/kb/inbox/`.
4. **Ingest it**
   ```
   cd ~/kb && claude
   > ingest the inbox
   ```
   Claude picks the vault, moves the file to that vault's `raw/`, writes the
   pages, updates the indexes, and commits.
5. **Ask.** In the same session: `> what do I know about <topic>?` or
   `> where did I put <thing>?` You don't need to know which vault it's in:
   Claude searches all of them and says where the answer came from.

Claude commits but never pushes; run `git push` in a vault when you want a
backup. Check a vault's health now and then: `cd ~/kb/<vault> && claude`, then `/lint`.

## Adding a domain

```
setup-kb.sh acme --github
```
The folder name is the domain. Every vault gets the same rules: it holds only
its own domain's material, and Claude asks when a source looks like it belongs
elsewhere. Nothing else to configure; the router finds new vaults by listing
`~/kb`.

To give Claude a clearer picture of a domain, add a line under Boundaries in
the vault's `CLAUDE.md` (e.g. "Acme work: projects, clients, internal tools").

## Ignoring a domain

Every domain is used everywhere by default. To leave one out, say so:
- **For a session:** "ignore personal".
- **For a project:** add `kb: ignore personal` to that project's `CLAUDE.md`.

## Remotes

- `--github [repo]` creates a private repo under your `gh` account and pushes.
  The default name is `kb-<name>`. It works on an existing vault too, and skips
  if the vault already has a remote.
- Prefer another host? Leave out `--github` and add your own remote:
  `git -C ~/kb/<name> remote add origin <url> && git -C ~/kb/<name> push -u origin main`.

## New machine

```
git clone https://github.com/mpzarde/knowhow.git ~/projects/knowhow
~/projects/knowhow/bin/setup-kb.sh personal --clone <personal-vault-url>
~/projects/knowhow/bin/setup-kb.sh acme --clone <acme-vault-url>
```

## Good to know
- **Slash commands are per vault (accepted gap).** `/ingest`, `/ask` and
  `/lint` only appear when Claude Code starts inside a vault. From `~/kb` or
  any project, just ask in plain words ("ingest the inbox", "where did I put
  my lease?"); the router and global pointer handle it.
- **Re-running is safe.** The script never overwrites a file.
- **Template edits don't reach existing vaults.** Each vault's files are its
  own after setup; edit them there. The router is the exception: it's a
  symlink, so `git pull` in knowhow updates it everywhere.
- `KB_USER` sets the name Claude uses for you (default: first word of
  `git config user.name`). `KB_ROOT` moves `~/kb`.
- Keep `~/kb` out of iCloud-synced folders; the script refuses them.

## Layout
- `bin/setup-kb.sh`: the setup script (`--help` for options).
- `templates/root/CLAUDE.md`: the router.
- `templates/vault/`: files for a new vault. `dot-` becomes `.` in paths;
  `{{VAR}}` is filled in.
- `templates/global.md`: the pointer added to `~/.claude/CLAUDE.md`.
- `docs/design.md`: decisions and open questions.

## License
MIT. See `LICENSE`.
