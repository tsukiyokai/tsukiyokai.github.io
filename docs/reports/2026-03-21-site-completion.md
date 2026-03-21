# Blog站点搭建完成报告

> 日期: 2026-03-21
> 项目: shanshan's blog
> 技术栈: Zola 0.22.1 (Rust SSG) + GitHub Pages + GitHub Actions

## 项目概况

danluu-style极简个人博客。近零CSS，浏览器默认样式，内容即设计。

| 维度       | 决策                                                |
|:-----------|:----------------------------------------------------|
| SSG        | Zola 0.22.1 (Rust, 单二进制, 构建快)               |
| 部署       | GitHub Pages + GitHub Actions (push main自动部署)   |
| 视觉风格   | 浏览器默认: 黑字白底蓝链接, 系统字体, 无外部资源    |
| 内容       | Markdown + Tera模板, tags分类                       |
| 不做(YAGNI)| 评论/RSS/搜索/暗色模式/外部字体/CSS/JS/Hero图片     |

## 构建指标

```
zola build → 114 pages (0 orphan), 2 sections, 389ms

index.html   1,448 bytes   (目标 < 2KB ✓)
站点总大小   4.4 MB        (111篇danluu全文 + 2个项目)
SCSS         2 行          (img max-width + pre wrap)
模板         8 个          (base/index/blog/blog-page/projects/project-page/taxonomy×2)
```

## 内容清单

| 分类      | 数量  | 来源                               |
|:----------|------:|:-----------------------------------|
| 博客文章  |   112 | 1 hello-world + 111 danluu.com爬取 |
| 项目      |     2 | planck (Rust通信库) + dage (DAG编排)|
| 标签      |     2 | life, danluu                       |
| 分页      |     6 | 博客列表每页20篇, 共6页            |

## 文件结构

```
blog/
  config.toml                          Zola配置 (github-light高亮)
  .gitignore                           忽略 public/
  content/
    _index.md                          首页: "shanshan / tech & life."
    blog/
      _index.md                        sort_by=date, paginate_by=20
      hello-world.md                   示例文章
      danluu-*.md (x111)               爬取种子内容
    projects/
      _index.md                        sort_by=weight
      planck.md                        Ascend NPU集合通信库
      dage.md                          DAG Workflow Orchestrator
  templates/
    base.html                          HTML骨架: charset/viewport/nav/footer
    index.html                         首页: intro + recent 5 posts
    blog.html                          博客列表: paginator + 翻页
    blog-page.html                     文章详情: date/tags/content/back
    projects.html                      项目列表: name + description
    project-page.html                  项目详情: description/content/back
    taxonomy_list.html                 标签总览
    taxonomy_single.html               单标签文章列表
  sass/style.scss                      2行CSS (img + pre)
  static/.gitkeep                      静态资源占位
  scripts/crawl_danluu.py              爬虫脚本
  .github/workflows/deploy.yml        CI/CD: Zola 0.22.1 + gh-pages
```

## 模板继承关系

```
base.html
  ├── index.html            首页 (section)
  ├── blog.html             博客列表 (section, paginated)
  ├── blog-page.html        文章详情 (page)
  ├── projects.html         项目列表 (section)
  ├── project-page.html     项目详情 (page)
  ├── taxonomy_list.html    标签总览 (taxonomy)
  └── taxonomy_single.html  标签筛选 (term)
```

section与模板的绑定通过frontmatter显式声明(`template` + `page_template`)，而非目录名自动匹配。

## 实现时间线

4次commit, 跨17轮迭代, 约4小时:

| Commit  | 时间  | 内容                               | 包含Task       |
|:--------|:------|:-----------------------------------|:---------------|
| 54c7ffa | 01:01 | feat(gate_base): base_template     | T1+T2+T3+T4    |
| 5f8b6d3 | 04:43 | feat(gate_projects): projects      | T5              |
| 5771b6d | 04:55 | feat(gate_crawl): crawl_danluu     | T4b             |
| 19733d2 | 05:02 | feat(gate_homepage): homepage      | T6              |

待commit: `.github/workflows/deploy.yml` (T7), SHARED_TASK_NOTES.md更新

## 关键技术发现

### 1. Zola 0.22.x breaking changes (vs plan中的0.19.x)

plan基于Zola 0.19.x编写，实际安装0.22.1。三处不兼容:

| 0.19.x                       | 0.22.x                          |
|:-----------------------------|:--------------------------------|
| `highlight_code = true` (顶层) | `[markdown.highlighting]` 区块  |
| `highlight_theme = "..."`    | `theme = "..."`                 |
| `base16-ocean-light`         | 不存在, 改用 `github-light`     |

### 2. 模板匹配需显式声明

Zola section的默认模板是`section.html`，不按目录名匹配。`content/blog/_index.md`必须在frontmatter中声明`template = "blog.html"` + `page_template = "blog-page.html"`。plan遗漏了此配置。

### 3. Taxonomy模板是延迟暴露的隐性依赖

config.toml声明了`taxonomies = [{name = "tags"}]`，但只有当文章frontmatter使用`[taxonomies] tags = [...]`时才触发模板需求。Task 3不会报错，Task 4添加带tags的hello-world后才暴露——必须补建`taxonomy_list.html`和`taxonomy_single.html`。

## 验证清单 (Task 8)

| 检查项                           | 结果                              |
|:---------------------------------|:----------------------------------|
| `zola build` 无error             | 114 pages, 0 orphan, 2 sections   |
| 首页 `/` 生成                    | public/index.html 存在            |
| 博客列表 `/blog/` 生成           | public/blog/index.html 存在       |
| 文章页 `/blog/hello-world/` 生成 | public/blog/hello-world/index.html|
| 项目列表 `/projects/` 生成       | public/projects/index.html 存在   |
| 项目页 `/projects/planck/` 生成  | public/projects/planck/index.html |
| 项目页 `/projects/dage/` 生成    | public/projects/dage/index.html   |
| 标签页 `/tags/` 生成             | public/tags/index.html 存在       |
| index.html < 2KB                 | 1,448 bytes                       |
| 分页正确 (6页)                   | public/blog/page/1~6/index.html   |
| deploy.yml YAML语法              | python3 yaml.safe_load 通过       |

## 部署就绪状态

站点本地构建完全通过，距上线还需3步:

1. 创建GitHub仓库 (e.g. `shanshan/blog`)
2. 更新`config.toml`中`base_url`为实际GitHub Pages URL
3. `git push`触发GitHub Actions自动部署

### 已知非阻塞问题

- `base_url`当前为占位值`https://example.github.io/blog`，部署前必须更新
- `base_url`末尾含`/blog`路径，会导致permalink出现双重`/blog/blog/`路径——如果仓库名不是`blog`或使用自定义域名，需调整为根路径

## 设计原则回顾

这个站点忠实执行了danluu-style极简理念:

- 零JavaScript, 零外部资源加载
- 2行SCSS, 浏览器默认样式承担所有排版
- 首页HTML仅1.4KB, 比大多数单张图片都小
- 导航是纯文字链接，没有按钮、图标、hamburger menu
- 没有"也许以后用得上"的功能 (RSS/评论/搜索/暗色模式)

一个389ms就能构建完的站点，一个1.4KB的首页，这就是"内容即设计"的极端表达。
