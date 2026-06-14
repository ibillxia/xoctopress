# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

XOctopress is a personal tech blog (http://ibillxia.github.io) built on Octopress 2.x / Jekyll 3.9.5. It's a static site generator that compiles Markdown posts into HTML. Content is primarily in Chinese.

- **Ruby 3.1.7** (see `.ruby-version`), managed via rbenv/rvm
- **Bundler** for gem dependencies
- **Rake** for build automation

## Common Commands

```bash
bundle install                    # Install dependencies
rake generate                     # Build site (Compass + Jekyll)
rake preview                      # Dev server on localhost:4000 with live reload
rake clean                        # Clear .pygments-cache, .sass-cache
rake new_post["Title"]            # Create new post in source/_posts/
rake new_page["filename"]         # Create new page
rake isolate[post-name]           # Stash other posts for faster builds
rake integrate                    # Restore stashed posts
rake deploy                       # Deploy to GitHub Pages (_deploy branch)
rake gen_deploy                   # Generate + deploy in one step
```

No automated tests or linters are configured. Validate by running `rake generate` and checking for build errors.

## Architecture

**Build pipeline:** `rake generate` runs Compass (Sass → CSS) then Jekyll (Markdown + Liquid templates → static HTML in `public/`).

**Key directories:**
- `source/_posts/` — Blog posts (190+ markdown files, 2009-2025) with YAML frontmatter
- `source/_includes/` — Liquid template partials (header, footer, article, sidebar asides)
- `source/_layouts/` — Page templates (default, post, page, category_index, tag_index)
- `plugins/` — 24 custom Jekyll/Liquid plugins (code blocks, tag/category generators, gist embedding, video tags, etc.)
- `sass/` — SCSS source files; `screen.scss` is the main entry point
- `.themes/` — Installable themes (classic, bootstrap, whitelake)
- `public/` — Generated site output (not committed to source branch)
- `_deploy/` — GitHub Pages deployment directory (force-pushed to master branch)

**Plugin system:** Plugins in `plugins/` define custom Liquid tags (e.g., `{% codeblock %}`, `{% gist %}`, `{% video %}`, `{% img %}`) and generators (category pages, tag pages, sitemap). Key filters are in `octopress_filters.rb`.

**Theme customization:** User overrides go in `source/_includes/custom/` and `sass/custom/`. Theme updates (`rake update_style`, `rake update_source`) preserve these custom directories.

**Deployment:** `rake deploy` copies `public/` into `_deploy/`, commits, and force-pushes to the `master` branch on GitHub Pages.

## Configuration

- `_config.yml` — Jekyll config (site URL, permalink structure `/blog/:year/:month/:day/:title/`, pagination, Disqus, Google Analytics, sidebar asides)
- `config.rb` — Compass config (Sass compilation settings)
- `Rakefile` — All build/deploy task definitions

## Post Frontmatter Format

```yaml
---
layout: post
title: "Post Title"
date: 2025-04-19 10:30
comments: true
categories: [Category1, Category2]
---
```
