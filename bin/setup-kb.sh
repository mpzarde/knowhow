#!/usr/bin/env bash
# setup-kb.sh — set up a knowledge base vault under ~/kb (Karpathy LLM-wiki pattern).
#
#   setup-kb.sh <name>                    new vault ~/kb/<name>, local git repo
#   setup-kb.sh <name> --github [repo]    ...plus a private GitHub repo, pushed
#                                         (default repo: kb-<name>; works on existing vaults too)
#   setup-kb.sh <name> --clone <url>      existing vault onto this machine
#
# The folder name is the domain (personal, acme, family...).
# KB_USER: the name the agent uses for you (default: first word of git user.name).
# KB_ROOT: the kb folder (default: ~/kb).
# Safe to re-run: never overwrites existing files.
set -euo pipefail

usage() { sed -n '2,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

NAME="" URL="" GITHUB="" GH_REPO=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --github) GITHUB=1; if [[ $# -gt 1 && "$2" != -* ]]; then GH_REPO="$2"; shift; fi; shift ;;
    --clone)  URL="${2:?--clone needs a git url}"; shift 2 ;;
    -h|--help) usage ;;
    -*) echo "unknown option: $1" >&2; usage 1 ;;
    *) [[ -z "$NAME" ]] || { echo "one vault name only" >&2; usage 1; }; NAME="$1"; shift ;;
  esac
done
[[ -n "$NAME" ]] || usage 1
[[ "$NAME" =~ ^[a-z0-9][a-z0-9-]*$ ]] || { echo "vault name must be lowercase kebab-case: $NAME" >&2; exit 1; }
[[ -z "$URL" || -z "$GITHUB" ]] || { echo "use --clone or --github, not both" >&2; exit 1; }

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$REPO/templates"
KB_ROOT="${KB_ROOT:-$HOME/kb}"
VAULT="$KB_ROOT/$NAME"
GH_REPO="${GH_REPO:-kb-$NAME}"


say()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m  %s\n' "$*"; }

# --- prerequisites -----------------------------------------------------------
# Required: abort if missing. Recommended: warn and suggest installing.
if command -v brew >/dev/null; then PKG="brew install"
elif command -v apt-get >/dev/null; then PKG="sudo apt-get install"
else PKG="install"; fi
pkg() { # pkg <brew-name> <apt-name>
  [[ "$PKG" == "sudo apt-get install" ]] && echo "$2" || echo "$1"; }

MISSING=() RECOMMEND=()
command -v git  >/dev/null || MISSING+=("git            $PKG git")
command -v perl >/dev/null || MISSING+=("perl           $PKG perl")
command -v pandoc >/dev/null || MISSING+=("pandoc         $PKG pandoc  (converts non-text sources for ingest)")
if command -v git >/dev/null; then
  git config user.name  >/dev/null || MISSING+=("git user.name  git config --global user.name \"Your Name\"")
  git config user.email >/dev/null || MISSING+=("git user.email git config --global user.email you@example.com")
fi
if [[ -n "$GITHUB" ]]; then
  if ! command -v gh >/dev/null; then MISSING+=("gh (--github)  $PKG gh")
  elif ! gh auth status >/dev/null 2>&1; then MISSING+=("gh sign-in     gh auth login"); fi
fi
command -v claude    >/dev/null || RECOMMEND+=("claude     Claude Code, to run the kb: https://claude.com/claude-code")
command -v pdftotext >/dev/null || RECOMMEND+=("pdftotext  reads large or scanned PDFs: $PKG $(pkg poppler poppler-utils)")
[[ -n "$GITHUB" ]] || command -v gh >/dev/null || RECOMMEND+=("gh         for --github remotes: $PKG gh")

if [[ ${#RECOMMEND[@]} -gt 0 ]]; then
  warn "recommended, not installed:"; printf '      %s\n' "${RECOMMEND[@]}"
fi
if [[ ${#MISSING[@]} -gt 0 ]]; then
  warn "required, missing (nothing was changed):"; printf '      %s\n' "${MISSING[@]}"; exit 1
fi

GIT_NAME="$(git config user.name 2>/dev/null || true)"
KB_USER="${KB_USER:-${GIT_NAME%% *}}"
if [[ -z "$KB_USER" && -t 0 ]]; then read -rp "Your first name (the agent uses it in vault rules): " KB_USER; fi
[[ -n "$KB_USER" ]] || { echo "set KB_USER or git config user.name" >&2; exit 1; }
DOMAIN="$(tr '[:lower:]' '[:upper:]' <<< "${NAME:0:1}")${NAME:1}"
TITLE="$DOMAIN knowledge base" OWNER="$KB_USER's $DOMAIN knowledge base"
export KB_USER KB_ROOT DOMAIN TITLE OWNER VAULT TODAY="$(date +%Y-%m-%d)"

# fill: replace {{VAR}} with $VAR from the environment
fill() { perl -pe 's/\{\{(\w+)\}\}/exists $ENV{$1} ? $ENV{$1} : "{{$1}}"/ge' "$1"; }

# render <template> <dest>  (skips if dest exists)
render() {
  if [[ -e "$2" ]]; then warn "exists, skipped: ${2#$HOME/}"; return; fi
  mkdir -p "$(dirname "$2")"
  fill "$1" > "$2"
  say "created: ${2#$HOME/}"
}

case "$KB_ROOT" in
  "$HOME/Library/Mobile Documents"*|"$HOME/Documents"*|"$HOME/Desktop"*)
    warn "kb path looks iCloud-synced — use a path outside Documents/Desktop"; exit 1 ;;
esac

# --- kb root -----------------------------------------------------------------
mkdir -p "$KB_ROOT/inbox"
ROOT_MD="$KB_ROOT/CLAUDE.md"
if [[ -L "$ROOT_MD" || -e "$ROOT_MD" ]]; then
  warn "exists, skipped: ${ROOT_MD#$HOME/}"
else
  ln -s "$TPL/root/CLAUDE.md" "$ROOT_MD"
  say "linked: ${ROOT_MD#$HOME/} -> knowhow/templates/root/CLAUDE.md"
fi

# --- vault -------------------------------------------------------------------
if [[ -n "$URL" ]]; then
  if [[ -e "$VAULT" ]]; then
    warn "$VAULT exists, not cloning"
  else
    git clone -q "$URL" "$VAULT"
    say "cloned $URL -> ${VAULT#$HOME/}"
  fi
else
  mkdir -p "$VAULT/raw"
  touch "$VAULT/raw/.gitkeep"
  # templates/vault/** -> vault, with "dot-" path parts becoming "."
  while IFS= read -r -d '' src; do
    rel="${src#$TPL/vault/}"
    dest="$VAULT/$(perl -pe 's{(^|/)dot-}{$1.}g' <<< "$rel")"
    render "$src" "$dest"
  done < <(find "$TPL/vault" -type f -print0)

  [[ -d "$VAULT/.git" ]] || { git -C "$VAULT" init -q -b main; say "git repo initialized"; }
  if ! git -C "$VAULT" rev-parse -q --verify HEAD >/dev/null; then
    git -C "$VAULT" add -A
    git -C "$VAULT" commit -qm "Initial vault"
    say "first commit made"
  else
    warn "git repo already has commits, left as is"
  fi
fi

# --- GitHub remote -----------------------------------------------------------
if [[ -n "$GITHUB" ]]; then
  if git -C "$VAULT" remote get-url origin >/dev/null 2>&1; then
    warn "origin already set ($(git -C "$VAULT" remote get-url origin)), skipped GitHub"
  elif ! git -C "$VAULT" rev-parse -q --verify HEAD >/dev/null; then
    warn "no commits yet, skipped GitHub"
  else
    gh repo create "$GH_REPO" --private --source "$VAULT" --remote origin --push
    say "created private GitHub repo $GH_REPO and pushed"
  fi
fi

# --- global CLAUDE.md pointer ------------------------------------------------
GLOBAL="$HOME/.claude/CLAUDE.md"
MARKER="<!-- kb-pointer:root -->"
mkdir -p "$HOME/.claude"
if grep -qF "$MARKER" "$GLOBAL" 2>/dev/null; then
  warn "global CLAUDE.md already points to the kb"
else
  { printf '\n%s\n' "$MARKER"; fill "$TPL/global.md"; } >> "$GLOBAL"
  say "added kb pointer to ~/.claude/CLAUDE.md"
fi
if grep -qE '<!-- kb-pointer(:[a-z0-9-]+)? -->' "$GLOBAL" 2>/dev/null && grep -vF "$MARKER" "$GLOBAL" | grep -qE '<!-- kb-pointer'; then
  warn "~/.claude/CLAUDE.md has older per-vault kb pointers; remove those blocks"
fi

cat <<EOF

Done. Next:
  1. Drop files in $KB_ROOT/inbox/, then: cd "$KB_ROOT" && claude, "ingest the inbox"
  2. Obsidian → Open folder as vault → $VAULT  (optional)
EOF
[[ -n "$GITHUB$URL" ]] || echo "  3. Back up: re-run with --github, or add your own remote"
