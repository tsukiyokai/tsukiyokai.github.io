# Personal Blog Implementation Plan

> For agentic workers: REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

Goal: Build a danluu-style minimal personal blog with Zola, deployed to GitHub Pages.

Architecture: Zola SSG generates static HTML from Markdown content and Tera templates. Near-zero CSS, browser defaults for everything. GitHub Actions auto-deploys on push to main.

Tech Stack: Zola (Rust SSG), Tera templates, SCSS (minimal), GitHub Actions

Design doc: `docs/plans/2026-03-20-homepage-design.md`

---

## File Map

| File                              | Responsibility                        |
|-----------------------------------|---------------------------------------|
| `config.toml`                     | Zola site config, taxonomy, highlight |
| `content/_index.md`               | Homepage content                      |
| `content/blog/_index.md`          | Blog section config                   |
| `content/blog/hello-world.md`     | Sample blog post                      |
| `content/projects/_index.md`      | Projects section config               |
| `content/projects/planck.md`      | Sample project entry                  |
| `templates/base.html`             | Base layout (head, nav, footer)       |
| `templates/index.html`            | Homepage template                     |
| `templates/blog.html`             | Blog list template                    |
| `templates/blog-page.html`        | Single post template                  |
| `templates/projects.html`         | Project list template                 |
| `templates/project-page.html`     | Single project template               |
| `sass/style.scss`                 | Minimal CSS overrides                 |
| `static/.gitkeep`                 | Placeholder for static assets         |
| `.github/workflows/deploy.yml`    | GitHub Actions deployment             |
| `.gitignore`                      | Ignore public/ and build artifacts    |

---

## Chunk 1: Project Init & Base

### Task 1: Install Zola & init project

Files:
- Create: `config.toml`, `.gitignore`

- [ ] Step 1: Install Zola

```bash
brew install zola
```

Expected: `zola --version` prints version number.

- [ ] Step 2: Initialize git repo

```bash
cd /Users/shanshan/repo/_me/blog
git init
```

- [ ] Step 3: Create `.gitignore`

```gitignore
public/
```

- [ ] Step 4: Create `config.toml`

```toml
base_url = "https://example.github.io/blog"

title = "shanshan's blog"
description = "tech & life"

compile_sass = true
minify_html  = false

generate_feeds = false

highlight_code      = true
highlight_theme     = "base16-ocean-light"

taxonomies = [
    { name = "tags" },
]
```

Note: `base_url` needs to be updated to the actual GitHub Pages URL later.

- [ ] Step 5: Create directory structure

```bash
mkdir -p content/blog content/projects templates sass static
touch static/.gitkeep
```

- [ ] Step 6: Verify Zola recognizes the project

```bash
zola check
```

Expected: no errors (warnings about missing templates are OK at this stage).

- [ ] Step 7: Commit

```bash
git add config.toml .gitignore static/.gitkeep
git commit -m "chore: 初始化Zola项目结构"
```

---

### Task 2: Create base template & minimal CSS

Files:
- Create: `templates/base.html`, `sass/style.scss`

- [ ] Step 1: Create `sass/style.scss`

```scss
img {
    max-width: 100%;
    height:    auto;
}

pre {
    max-width:   100%;
    white-space: pre-wrap;
}
```

- [ ] Step 2: Create `templates/base.html`

```html
<!DOCTYPE html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{% block title %}{{ config.title }}{% endblock %}</title>
    <link rel="stylesheet" href="{{ get_url(path='style.css') }}">
</head>
<body>
<nav>
    <a href="{{ get_url(path='/') }}">home</a> /
    <a href="{{ get_url(path='@/blog/_index.md') }}">blog</a> /
    <a href="{{ get_url(path='@/projects/_index.md') }}">projects</a>
</nav>

{% block content %}{% endblock %}

<footer>
    <a href="https://github.com/shanshan">github</a>
</footer>
</body>
</html>
```

- [ ] Step 3: Create a minimal `content/_index.md` to test

```markdown
+++
title = "home"
+++

shanshan's blog.
```

- [ ] Step 4: Create `templates/index.html`

```html
{% extends "base.html" %}

{% block content %}
{{ section.content | safe }}
{% endblock %}
```

- [ ] Step 5: Verify build

```bash
zola build
```

Expected: `public/index.html` generated, no errors.

- [ ] Step 6: Local preview

```bash
zola serve
```

Expected: browser at `http://127.0.0.1:1111` shows page with nav + "shanshan's blog." text.

- [ ] Step 7: Commit

```bash
git add templates/base.html templates/index.html sass/style.scss content/_index.md
git commit -m "feat: 添加基础布局模板和极简CSS"
```

---

## Chunk 2: Blog Section

### Task 3: Blog list page

Files:
- Create: `content/blog/_index.md`, `templates/blog.html`

- [ ] Step 1: Create `content/blog/_index.md`

```markdown
+++
title = "blog"
sort_by = "date"
paginate_by = 20
+++
```

- [ ] Step 2: Create `templates/blog.html`

```html
{% extends "base.html" %}

{% block title %}blog - {{ config.title }}{% endblock %}

{% block content %}
<h1>blog</h1>
<ul>
{% for page in paginator.pages %}
    <li>
        {{ page.date }} -
        <a href="{{ page.permalink }}">{{ page.title }}</a>
        {% for tag in page.taxonomies.tags | default(value=[]) %}
        [{{ tag }}]
        {% endfor %}
    </li>
{% endfor %}
</ul>

{% if paginator.previous %}
<a href="{{ paginator.previous }}">&lt; prev</a>
{% endif %}
{% if paginator.next %}
<a href="{{ paginator.next }}">next &gt;</a>
{% endif %}
{% endblock %}
```

- [ ] Step 3: Verify build (will warn about no pages, that's OK)

```bash
zola build
```

- [ ] Step 4: Commit

```bash
git add content/blog/_index.md templates/blog.html
git commit -m "feat: 添加博客列表页模板"
```

---

### Task 4: Blog post page + sample post

Files:
- Create: `templates/blog-page.html`, `content/blog/hello-world.md`

- [ ] Step 1: Create `templates/blog-page.html`

```html
{% extends "base.html" %}

{% block title %}{{ page.title }} - {{ config.title }}{% endblock %}

{% block content %}
<h1>{{ page.title }}</h1>
<p>{{ page.date }}
{% for tag in page.taxonomies.tags | default(value=[]) %}
 [{{ tag }}]
{% endfor %}
</p>

{{ page.content | safe }}

<p>
    <a href="{{ get_url(path='@/blog/_index.md') }}">&lt; back to blog</a>
</p>
{% endblock %}
```

- [ ] Step 2: Create `content/blog/hello-world.md`

```markdown
+++
title = "hello world"
date = 2026-03-20
[taxonomies]
tags = ["life"]
+++

First post. Testing.
```

- [ ] Step 3: Verify build and preview

```bash
zola build && zola serve
```

Expected:
- `/blog/` shows post list with "hello world" entry
- `/blog/hello-world/` shows full post
- Nav links work

- [ ] Step 4: Commit

```bash
git add templates/blog-page.html content/blog/hello-world.md
git commit -m "feat: 添加博客文章模板和示例文章"
```

---

## Chunk 3: Projects Section

### Task 5: Project list + detail pages

Files:
- Create: `content/projects/_index.md`, `content/projects/planck.md`, `templates/projects.html`, `templates/project-page.html`

- [ ] Step 1: Create `content/projects/_index.md`

```markdown
+++
title = "projects"
sort_by = "weight"
+++
```

- [ ] Step 2: Create `templates/projects.html`

```html
{% extends "base.html" %}

{% block title %}projects - {{ config.title }}{% endblock %}

{% block content %}
<h1>projects</h1>
<ul>
{% for page in section.pages %}
    <li>
        <a href="{{ page.permalink }}">{{ page.title }}</a> -
        {{ page.description | default(value="") }}
    </li>
{% endfor %}
</ul>
{% endblock %}
```

- [ ] Step 3: Create `templates/project-page.html`

```html
{% extends "base.html" %}

{% block title %}{{ page.title }} - {{ config.title }}{% endblock %}

{% block content %}
<h1>{{ page.title }}</h1>
<p>{{ page.description | default(value="") }}</p>

{{ page.content | safe }}

<p>
    <a href="{{ get_url(path='@/projects/_index.md') }}">&lt; back to projects</a>
</p>
{% endblock %}
```

- [ ] Step 4: Create `content/projects/planck.md`

```markdown
+++
title = "planck"
description = "A Rust project"
weight = 1
+++

Planck project description goes here.

* repo: [github.com/shanshan/planck](https://github.com/shanshan/planck)
```

- [ ] Step 5: Verify build and preview

```bash
zola build && zola serve
```

Expected:
- `/projects/` shows "planck" entry
- `/projects/planck/` shows detail page
- All nav links work across sections

- [ ] Step 6: Commit

```bash
git add content/projects/ templates/projects.html templates/project-page.html
git commit -m "feat: 添加作品展示页模板和示例项目"
```

---

## Chunk 4: Homepage & Polish

### Task 6: Complete homepage with latest posts

Files:
- Modify: `content/_index.md`, `templates/index.html`

- [ ] Step 1: Update `content/_index.md`

```markdown
+++
title = "home"
+++

shanshan

tech & life.
```

- [ ] Step 2: Update `templates/index.html`

```html
{% extends "base.html" %}

{% block content %}
{{ section.content | safe }}

<h2>recent posts</h2>
<ul>
{% set blog = get_section(path="blog/_index.md") %}
{% for page in blog.pages | slice(end=5) %}
    <li>
        {{ page.date }} -
        <a href="{{ page.permalink }}">{{ page.title }}</a>
    </li>
{% endfor %}
</ul>
<a href="{{ get_url(path='@/blog/_index.md') }}">all posts &gt;</a>
{% endblock %}
```

- [ ] Step 3: Verify build and preview

```bash
zola build && zola serve
```

Expected: homepage shows intro text + latest posts list.

- [ ] Step 4: Commit

```bash
git add content/_index.md templates/index.html
git commit -m "feat: 完善首页模板，展示最新文章"
```

---

## Chunk 5: Deployment

### Task 7: GitHub Actions deployment

Files:
- Create: `.github/workflows/deploy.yml`

- [ ] Step 1: Create `.github/workflows/deploy.yml`

```yaml
name: Deploy to GitHub Pages

on:
  push:
    branches: [main]

permissions:
  contents: write

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Zola
        run: |
          ZOLA_VERSION="0.19.2"
          curl -sL "https://github.com/getzola/zola/releases/download/v${ZOLA_VERSION}/zola-v${ZOLA_VERSION}-x86_64-unknown-linux-gnu.tar.gz" | tar xz
          sudo mv zola /usr/local/bin/

      - name: Build
        run: zola build

      - name: Deploy
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./public
```

Note: `ZOLA_VERSION` should match a real release version. Verify at https://github.com/getzola/zola/releases before deploying.

- [ ] Step 2: Verify workflow YAML is valid

```bash
cat .github/workflows/deploy.yml | python3 -c "import sys,yaml;yaml.safe_load(sys.stdin);print('valid')"
```

- [ ] Step 3: Commit

```bash
git add .github/workflows/deploy.yml
git commit -m "ci: 添加GitHub Pages自动部署"
```

---

### Task 8: Final verification

- [ ] Step 1: Full build check

```bash
zola build
```

Expected: no errors, no warnings.

- [ ] Step 2: Local end-to-end preview

```bash
zola serve
```

Verify all pages:
- `http://127.0.0.1:1111/` — homepage with nav + latest posts
- `http://127.0.0.1:1111/blog/` — blog list
- `http://127.0.0.1:1111/blog/hello-world/` — sample post
- `http://127.0.0.1:1111/projects/` — project list
- `http://127.0.0.1:1111/projects/planck/` — sample project
- All nav links work, no broken links

- [ ] Step 3: Check generated HTML is minimal

```bash
wc -c public/index.html
```

Expected: small file size (< 2KB), confirming near-zero bloat.

- [ ] Step 4: Update `config.toml` base_url to actual GitHub Pages URL

After creating the GitHub repo, update `base_url` to match.

- [ ] Step 5: Final commit

```bash
git add -A
git commit -m "docs: 更新配置和文档"
```

- [ ] Step 6: Push to GitHub and verify deployment

```bash
git remote add origin <repo-url>
git push -u origin main
```

Expected: GitHub Actions triggers, site live at GitHub Pages URL.
