# Blog站点搭建 — 跨轮次执行笔记

> 源: docs/superpowers/plans/2026-03-20-personal-blog.md (实现计划)
>     docs/plans/2026-03-20-homepage-design.md (设计文档)
>     blog.yaml (dage DAG编排，是实现计划的超集)

## 项目定位

danluu-style极简个人博客。Zola SSG + GitHub Pages。近零CSS，浏览器默认样式，内容即设计。
YAGNI: 评论、RSS、搜索、暗色模式、外部字体/CSS/JS、Hero图片/头像/banner。

## 仓库现状 (2026-03-20)

- 无git仓库（需git init）
- 无Zola项目结构（需从零创建）
- 现有文件: docs/(设计+实现文档), blog.yaml(dage编排), .dage/(运行时)

## 目标文件结构

```
blog/
  config.toml                     # Zola配置
  .gitignore                      # 忽略public/
  content/
    _index.md                     # 首页
    blog/
      _index.md                   # 博客列表配置
      hello-world.md              # 示例文章
      danluu-*.md                 # 爬取内容(blog.yaml扩展)
    projects/
      _index.md                   # 作品列表配置
      planck.md                   # Rust Plan Compiler
      dage.md                     # DAG Orchestrator(blog.yaml扩展)
  templates/
    base.html                     # 基础布局
    index.html                    # 首页模板
    blog.html                     # 博客列表
    blog-page.html                # 文章详情
    projects.html                 # 作品列表
    project-page.html             # 作品详情
  sass/style.scss                 # ~4行CSS
  static/.gitkeep                 # 占位
  .github/workflows/deploy.yml   # CI/CD
```

## 8个Task详细拆解

### Chunk 1: 项目初始化 + 基础模板

#### Task 1: 初始化Zola项目
- 依赖: 无
- 产出: config.toml, .gitignore, 目录结构, static/.gitkeep
- 验证: `zola check` 无报错(缺模板的warning可以)
- commit: `chore: 初始化Zola项目结构`
- [ ] 确认/安装zola (`brew install zola`, 验证 `zola --version`)
- [ ] `git init`
- [ ] .gitignore: 只写一行 `public/`
- [ ] config.toml: base_url(占位), title="shanshan's blog", compile_sass=true, minify_html=false, generate_feeds=false, highlight_code=true, highlight_theme="base16-ocean-light", taxonomies=[{name="tags"}]
- [ ] `mkdir -p content/blog content/projects templates sass static && touch static/.gitkeep`
- [ ] `zola check`

#### Task 2: 基础布局模板 + 极简CSS
- 依赖: Task 1
- 产出: templates/base.html, templates/index.html, sass/style.scss, content/_index.md
- 验证: `zola build`成功 且 `public/index.html`存在 且 浏览器`http://127.0.0.1:1111`可预览
- commit: `feat: 添加基础布局模板和极简CSS`
- [ ] sass/style.scss: `img{max-width:100%;height:auto}` + `pre{max-width:100%;white-space:pre-wrap}`
- [ ] templates/base.html: `<html lang="zh">`, meta charset+viewport, title block, stylesheet链接, nav(home/blog/projects纯文字), content block, footer(github链接)
- [ ] templates/index.html: extends base, 渲染 `{{ section.content | safe }}`
- [ ] content/_index.md: frontmatter title="home", body="shanshan's blog."
- [ ] `zola build` → 检查 public/index.html 存在

### Chunk 2: 博客功能

#### Task 3: 博客列表页
- 依赖: Task 2 (gate_base)
- 产出: content/blog/_index.md, templates/blog.html
- 验证: `zola build`成功
- commit: `feat: 添加博客列表页模板`
- [ ] content/blog/_index.md: title="blog", sort_by="date", paginate_by=20
- [ ] templates/blog.html: extends base, title block "blog - config.title", 遍历paginator.pages(日期+标题链接+tags), prev/next翻页链接
- [ ] `zola build`

#### Task 4: 博客文章页 + 示例文章
- 依赖: Task 3
- 产出: templates/blog-page.html, content/blog/hello-world.md
- 验证: `zola build`成功 且 `public/blog/index.html`存在 且 `public/blog/hello-world/index.html`存在
- commit: `feat: 添加博客文章模板和示例文章`
- [ ] templates/blog-page.html: extends base, title=page.title, 显示date+tags, page.content, "< back to blog"链接
- [ ] content/blog/hello-world.md: title="hello world", date=2026-03-20, tags=["life"], body="First post. Testing."
- [ ] `zola build` → 检查两个index.html存在

### Chunk 2b: 种子内容 (blog.yaml扩展，原plan无此任务)

#### Task 4b: 爬取danluu.com文章
- 依赖: Task 4 (gate_blog)
- 产出: scripts/crawl_danluu.py, content/blog/danluu-*.md
- 验证: danluu-*.md文件数>0 且 `zola build`成功
- commit: `feat: 爬取danluu.com文章作为种子内容`
- 注意: 限速0.5s/请求, 需pip install requests beautifulsoup4 html2text

### Chunk 3: 作品展示 (可与Chunk 2并行)

#### Task 5: 作品列表 + 详情页
- 依赖: Task 2 (gate_base) — 与Task 3/4无依赖，可并行
- 产出: content/projects/_index.md, templates/projects.html, templates/project-page.html, content/projects/planck.md, content/projects/dage.md(blog.yaml扩展)
- 验证: `zola build`成功 且 public/projects/index.html + public/projects/planck/index.html存在
- commit: `feat: 添加作品展示页模板和示例项目`
- [ ] content/projects/_index.md: title="projects", sort_by="weight"
- [ ] templates/projects.html: extends base, 遍历section.pages(名称+描述链接)
- [ ] templates/project-page.html: extends base, title+description+content, "< back to projects"链接
- [ ] content/projects/planck.md: weight=1, 描述Rust Plan Compiler (从相邻仓库只读取资料)
- [ ] content/projects/dage.md: weight=2, 描述DAG Orchestrator (blog.yaml扩展)
- [ ] `zola build`

### Chunk 4: 首页完善

#### Task 6: 首页展示最新文章
- 依赖: Task 4 + Task 5 都完成(homepage等待gate_crawl和gate_projects)
- 修改: content/_index.md, templates/index.html (不创建新文件)
- 验证: `zola build`成功 且 public/index.html中包含blog链接 (`grep -q 'href.*blog/' public/index.html`)
- commit: `feat: 完善首页模板，展示最新文章`
- [ ] content/_index.md: 更新为"shanshan\n\ntech & life."
- [ ] templates/index.html: `get_section(path="blog/_index.md")`, `blog.pages | slice(end=5)`, 日期+标题链接, "all posts >"链接
- [ ] `zola build` → grep验证

### Chunk 5: 部署

#### Task 7: GitHub Actions部署
- 依赖: Task 6
- 产出: .github/workflows/deploy.yml
- 验证: YAML语法正确 (`python3 -c "import yaml; yaml.safe_load(open(...))"`)
- commit: `ci: 添加GitHub Pages自动部署`
- [ ] deploy.yml: on push main, install zola(curl二进制ZOLA_VERSION="0.19.2"), zola build, peaceiris/actions-gh-pages@v4
- [ ] YAML语法校验

#### Task 8: 最终验证
- 依赖: Task 7
- 修改: config.toml (更新base_url)
- 验证标准:
  - `zola build` 无error无warning
  - 5个页面均生成: /, /blog/, /blog/hello-world/, /projects/, /projects/planck/
  - 导航链接全通
  - public/index.html < 2KB
- commit: `docs: 更新配置和文档`
- [ ] `zola build` 全量检查
- [ ] 本地 `zola serve` 逐页验证
- [ ] `wc -c public/index.html` 确认<2KB
- [ ] 更新config.toml base_url
- [ ] push触发部署

## 依赖关系

```
T1 -> T2 --+--> T3 -> T4 -> [T4b] --+-> T6 -> T7 -> T8
            |                         |
            +--> T5 -----------------+
```

- T3/T4(博客)和T5(作品展示)可在T2完成后并行
- T6(首页)必须等T4(或T4b)和T5都完成
- [T4b]是blog.yaml扩展任务，原plan无此步骤

关键路径: T1 → T2 → T3 → T4 → [T4b] → T6 → T7 → T8

## 风险与待确认

1. ~~zola安装~~ 已解决: Zola 0.22.1 via brew
2. base_url占位 — config.toml中"https://example.github.io/blog"需创建GitHub repo后更新
3. crawl_danluu版权 — 爬取他人博客作种子内容，blog.yaml额外加的，设计文档未提及，需确认合规
4. ~~ZOLA_VERSION="0.19.2"~~ 需更新: 实际安装0.22.1，deploy.yml应同步
5. planck/dage项目信息 — 执行时从相邻仓库只读取，不可修改那些仓库

## 关键发现

### Zola模板匹配机制

section的默认模板是`section.html`，不会按目录名自动匹配。`content/blog/_index.md`不会自动使用`templates/blog.html`，必须在frontmatter中显式声明`template = "blog.html"`。同理`page_template = "blog-page.html"`指定该section下文章的模板。原plan遗漏了此配置，导致首次构建输出Zola默认页面。

### Zola taxonomy模板是隐性依赖

config.toml中声明了`taxonomies = [{name = "tags"}]`，但只要没有文章使用tags就不会报错。一旦某篇文章的frontmatter包含`[taxonomies] tags = [...]`，Zola就会尝试生成标签页面，此时必须存在`taxonomy_list.html`和`taxonomy_single.html`模板，否则build失败。这是一个"延迟暴露"的依赖——Task 3时不会触发，Task 4添加带tags的文章后才暴露。

### Zola 0.22.x vs 0.19.x breaking changes

1. `highlight_code`/`highlight_theme`已从顶层和`[markdown]`移到`[markdown.highlighting]`子区块
2. 字段名变为`theme`（不再是`highlight_theme`），无`enabled`开关（有`[markdown.highlighting]`区块即启用）
3. theme名称变化: 旧版`base16-ocean-light`不存在，可用: `github-light`, `solarized-light`, `one-light`, `dracula`, `nord`等
4. deploy.yml中的ZOLA_VERSION需从"0.19.2"更新为"0.22.1"

## 进度

- [x] 精读plan和design文档，创建执行计划 (第1轮)
- [x] Task 1: 初始化Zola项目 (第2轮，第3轮验证通过)
- [x] Task 2: 基础布局模板 + 极简CSS (第5轮)
- [x] Task 3: 博客列表页 (第7轮)
- [x] Task 4: 博客文章页 + 示例文章 (第10轮)
- [ ] Task 5: 作品展示页
- [ ] Task 6: 首页完善
- [ ] Task 7: GitHub Actions部署
- [ ] Task 8: 最终验证

## 已完成产物

| 文件               | Task | 备注                                    |
|--------------------|------|-----------------------------------------|
| .git/              | T1   | git init                                |
| .gitignore         | T1   | 忽略 public/                            |
| config.toml        | T1   | Zola 0.22.x格式, github-light高亮主题   |
| content/blog/_index.md | T3 | sort_by=date, paginate_by=20, template=blog.html |
| templates/blog.html| T3   | 博客列表: paginator.pages遍历+翻页链接  |
| content/projects/  | T1   | 空目录                                  |
| static/.gitkeep    | T1   | 占位文件                                |
| sass/style.scss    | T2   | img max-width + pre white-space 两条规则 |
| templates/base.html| T2   | HTML骨架: charset/viewport/nav/footer   |
| templates/index.html| T2  | extends base, 渲染section.content       |
| content/_index.md  | T2   | 首页占位: "shanshan's blog."            |
| templates/blog-page.html | T4 | 文章详情: date+tags+content+"< back to blog" |
| content/blog/hello-world.md | T4 | 示例文章: date=2026-03-20, tags=["life"] |
| templates/taxonomy_list.html | T4 | 标签列表页(使用tags触发的隐性依赖)     |
| templates/taxonomy_single.html | T4 | 单标签文章列表页                      |

验证: T1 `zola check`通过, T2 `zola build`通过且public/index.html正确生成

## 当前阶段

第12轮: gate_blog re-verification通过，无需代码修复。
- gate失败原因: DAG时序问题，gate在hello-world.md尚未生成时被触发(2 pages vs 3 pages)
- 现状: `zola build` → 3 pages, 2 sections, 无error; 两个test -f均通过; 输出"blog pages OK"
- 已知非阻塞问题: blog.html中`page.permalink`产生双重/blog/路径(base_url末尾含/blog + content/blog/路径)，部署前需调整base_url

待commit: templates/blog-page.html, content/blog/hello-world.md, templates/taxonomy_list.html, templates/taxonomy_single.html
下一步: Task 5 — 作品展示页
