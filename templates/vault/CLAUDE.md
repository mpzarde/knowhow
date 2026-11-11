# {{TITLE}}

This folder is {{OWNER}}, built on Karpathy's LLM-wiki
pattern. You (the agent) maintain the wiki. {{KB_USER}} adds sources and asks
questions; he rarely edits wiki pages himself.

## Layout
- `raw/`         Sources {{KB_USER}} drops in (web clips, notes, PDFs, transcripts).
                 Never edit or delete anything here.
- `wiki/`        Your pages. One folder per topic, each with its own `index.md`.
- `wiki/general/` Catch-all for material with no clear topic yet.
- `index.md`     Top-level map: one line per topic folder, with a short summary.
- `log.md`       Append-only record of every operation.

## Page rules
- One concept, entity, or question per page. Filenames in kebab-case.
- Frontmatter on every page:
  ```
  ---
  title:
  tags: []
  sources: []    # raw/ files this page draws on
  created: YYYY-MM-DD
  updated: YYYY-MM-DD
  ---
  ```
- Link related pages with Obsidian `[[wikilinks]]`. Prefer updating an
  existing page over creating a near-duplicate.
- Cite the raw source inline for factual claims, as `(raw/file.md)`, adding a
  section or page number for PDFs (`(raw/file.pdf, p. 4)`). Mark your own
  inferences as such.
- If a new source contradicts an existing page, don't overwrite. Flag the
  conflict on the page, cite both sources, and tell {{KB_USER}}.
- Keep pages concise.

## Topics
- Put a page in an existing topic folder when it fits; otherwise `wiki/general/`.
- When 3+ related pages accumulate in `general/`, propose a new topic folder.
  Ask before creating it, then move the pages and fix links.
- Every topic folder has an `index.md` listing its pages, one line each.
- Keep the top-level `index.md` in sync with the topic folders.

## Operations
- **Ingest**: see `/ingest` skill.
- **Ask**: read `index.md` → topic `index.md` → pages. Answer from the wiki,
  citing pages. If the wiki lacks the answer, say so before using outside
  knowledge. Offer to file useful answers back as a page.
- **Lint**: see `/lint` skill.
- After each operation: append one line to `log.md`
  (`YYYY-MM-DD | op | summary`), where `op` is one of `setup`, `ingest`,
  `ask`, `lint`. Then stage only the files you touched (`git add <paths>`,
  never `-A`) and commit with a short message.
- Never push automatically. Push only when {{KB_USER}} asks.

## Boundaries
- This vault holds {{DOMAIN}} material only. Before writing any page from a
  source, check that it fits. If it looks like it belongs to another domain,
  stop and ask.
- Each page lives in one vault. Don't link or copy pages into other vaults.
- No credentials, account numbers, or ID numbers in any page. Run the same
  pre-write check for these; leave them out or ask.
- When unsure about structure or placement, ask.
