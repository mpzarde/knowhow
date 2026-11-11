---
name: lint
description: Health check of the wiki. Use when {{KB_USER}} asks for a lint, cleanup, or health check, or on a schedule.
---
Check and report, then fix only what {{KB_USER}} approves:
1. Broken `[[wikilinks]]` and orphan pages (nothing links to them).
2. Pages missing from their topic `index.md`, or index lines with no page.
3. Near-duplicate pages that should merge.
4. Contradictory claims between pages.
5. Pages with no `sources:` or stale `updated:` dates.
6. Clusters of 3+ related pages in `wiki/general/` that could become a topic.
7. Raw files never ingested.
Report as a short list grouped by type. After approved fixes: log, commit.
