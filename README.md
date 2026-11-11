# claude-skills

One place for the skills I use in both **Claude** (claude.ai, desktop and mobile) and **Claude Code**.
The repo is a Claude plugin marketplace, so both apps install from the same source and pick up the
same updates.

| Plugin | What it is | Skill | Source |
| --- | --- | --- | --- |
| `impeccable` | Design vocabulary and anti-slop checks for frontends. Commands such as `/impeccable polish`, `audit`, `critique`, `typeset`, `layout`. | `impeccable` | [pbakaus/impeccable](https://github.com/pbakaus/impeccable) (Apache 2.0) |
| `taste-skill` | Art direction, licensed real photographs and a real-browser check for websites. | `design-taste-frontend` | [Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill) (MIT) |
| `my-skills` | My own skills. Starts with `cabinfit-brand`. | `cabinfit-brand` | this repo |

```
.claude-plugin/marketplace.json   catalog of the plugins below
plugins/
  impeccable/                     vendored copy of upstream plugin/ (skill, hooks, agents)
  taste-skill/                    vendored copy of upstream skills/taste-skill + our plugin.json
  my-skills/                      my own skills, one folder per skill under skills/
upstream.json                     where each vendored plugin comes from, pinned to a commit
scripts/sync-upstream.sh          refresh the vendored copies from upstream
scripts/package-skills.sh         zip each skill for a manual claude.ai upload
```

## Install

Replace `OWNER` with the GitHub account that holds this repo.

**Claude Code** (in a session):

```
/plugin marketplace add OWNER/claude-skills
/plugin install impeccable@francisco-skills
/plugin install taste-skill@francisco-skills
/plugin install my-skills@francisco-skills
```

Then open `/plugin` > Marketplaces > `francisco-skills` > **Enable auto-update**, so new commits
arrive without running `/plugin marketplace update francisco-skills`.

**Claude** (claude.ai or desktop, paid plans): Customize > Plugins > Add > Add marketplace >
Add from a repository > `OWNER/claude-skills`, then add the three plugins. Plugin skills work in
chat; hooks and sub-agents only run in Claude Code and Cowork.

**Fallback, single skills in claude.ai**: run `scripts/package-skills.sh` and upload the zips from
`dist/` in Customize > Skills > + > Upload a skill. Taste Skill bundles about 40 MB of assets and may
exceed the upload limit; the marketplace route avoids that.

## Requirements

- Taste Skill runs its scripts with Node 22+ and Chrome, Edge or Chromium.
- Impeccable ships a launcher in `skills/impeccable/scripts/`. Its hooks check UI edits in Claude
  Code. Run `/impeccable init` in a project to create `PRODUCT.md` and `DESIGN.md`.
- Hooks from both plugins run in Claude Code only.

## Update the third-party skills

```bash
scripts/sync-upstream.sh              # all
scripts/sync-upstream.sh taste-skill  # one
git diff --stat                       # review, then commit and push
```

`upstream.json` records the exact upstream commit after each sync. To follow a release tag instead
of `main`, change that entry's `ref`.

Versioning: `taste-skill` and `my-skills` have no `version` in `plugin.json`, so installs follow this
repo's commits. `impeccable` keeps upstream's `version`, which changes when its author releases.

## Add your own skill

1. Create `plugins/my-skills/skills/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. Run `claude plugin validate .`
3. Commit and push. Claude Code picks it up on the next update; in claude.ai, update the marketplace.

Skills in a plugin are invoked with the plugin prefix in Claude Code, for example
`/my-skills:cabinfit-brand`, and also load automatically when their description matches the task.

## Licenses

Vendored plugins keep their upstream license files: `plugins/impeccable/LICENSE` and `NOTICE.md`
(Apache 2.0), `plugins/taste-skill/LICENSE` (MIT). Everything else in this repo is mine.
