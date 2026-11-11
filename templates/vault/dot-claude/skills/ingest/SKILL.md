---
name: ingest
description: Ingest new or named files from raw/ into the wiki. Use when {{KB_USER}} says ingest, add this, or file this.
---
1. Find the sources: files named by {{KB_USER}}, or files in `raw/` not yet listed
   in any page's `sources:` frontmatter.
2. Read each source. Summarize its key claims, entities, and concepts.
3. For each concept or entity: update the existing page if one exists,
   otherwise create a page in the right topic folder (or `wiki/general/`).
4. Add `[[wikilinks]]` both ways between related pages.
5. Update the topic `index.md` and, if topics changed, the top-level `index.md`.
6. Append to `log.md`, then commit.
7. Report back in a few lines: pages created, pages updated, anything unclear.
