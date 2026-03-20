#!/usr/bin/env python3
"""爬取 danluu.com 全部文章，转为Zola格式Markdown存入 content/blog/."""

import re
import time
from pathlib import Path

import html2text
import requests
from bs4 import BeautifulSoup

# ==== 配置 ====
BASE_URL    = "https://danluu.com"
OUTPUT_DIR  = Path(__file__).resolve().parent.parent / "content" / "blog"
DELAY       = 0.5                          # 请求间隔(秒)
HEADERS     = {"User-Agent": "Mozilla/5.0 (blog-seed-crawler; educational use)"}
DATE_RE     = re.compile(r"^(\d{1,2})/(\d{2})")  # MM/YY at start of link text

# html2text 配置
H2T = html2text.HTML2Text()
H2T.body_width        = 0                 # 不自动折行
H2T.protect_links     = True              # 保留完整URL
H2T.wrap_links        = False
H2T.unicode_snob      = True              # 用unicode字符而非ASCII替代
H2T.skip_internal_links = True            # 跳过锚点链接(脚注)


def fetch(url: str) -> str:
    """GET请求，返回HTML文本。"""
    resp = requests.get(url, headers=HEADERS, timeout=30)
    resp.raise_for_status()
    resp.encoding = resp.apparent_encoding
    return resp.text


def parse_index(html: str) -> list[dict]:
    """解析首页，提取文章链接、标题、日期。

    Returns: [{"slug": str, "title": str, "date": str}, ...]
    """
    soup = BeautifulSoup(html, "html.parser")
    articles = []
    seen = set()

    for li in soup.find_all("li"):
        a = li.find("a", href=True)
        if not a:
            continue

        href = a["href"]

        # 匹配 danluu.com 文章链接(绝对URL)
        if not href.startswith(BASE_URL + "/"):
            continue
        slug = href[len(BASE_URL):].strip("/")
        if not slug or "/" in slug:
            continue
        if slug in ("atom.xml", "atom", "rss"):
            continue
        if slug in seen:
            continue
        seen.add(slug)

        # 日期在 <d> 标签中，格式 MM/YY
        date = "2020-01-01"
        d_tag = li.find("d")
        if d_tag:
            m = DATE_RE.match(d_tag.get_text(strip=True))
            if m:
                month, year = m.group(1).zfill(2), m.group(2)
                century = "20" if int(year) < 90 else "19"
                date = f"{century}{year}-{month}-01"

        title = a.get_text(strip=True)
        if not title:
            title = slug.replace("-", " ").title()

        articles.append({"slug": slug, "title": title, "date": date})

    return articles


def extract_article_content(html: str) -> str:
    """从文章页提取正文HTML，去除导航/footer。"""
    soup = BeautifulSoup(html, "html.parser")

    # 移除 <style> 和 <script>
    for tag in soup.find_all(["style", "script"]):
        tag.decompose()

    body = soup.find("body") or soup

    # 将相对链接转为绝对链接
    for a in body.find_all("a", href=True):
        href = a["href"]
        if href.startswith("/"):
            a["href"] = BASE_URL + href

    # 将相对图片src转为绝对
    for img in body.find_all("img", src=True):
        src = img["src"]
        if src.startswith("/"):
            img["src"] = BASE_URL + src

    return str(body)


def html_to_markdown(html: str, title: str = "") -> str:
    """将HTML转为Markdown，清理标题重复和导航。"""
    md = H2T.handle(html)

    lines = md.split("\n")
    clean = []
    skip_footer = False
    title_removed = False

    for line in lines:
        stripped = line.strip()

        # 跳过文章开头的重复标题行(含Patreon链接)
        if not title_removed and title and stripped:
            # 标题行通常包含加粗标题 + Patreon链接
            if "Patreon" in stripped and title[:20] in stripped:
                title_removed = True
                continue
            # 纯标题行
            plain = stripped.strip("# *")
            if plain == title:
                title_removed = True
                continue

        # 跳过标题后紧跟的分隔线
        if title_removed and not clean and stripped in ("* * *", "---", "***", ""):
            continue

        # 检测footer: Archive/Patreon导航链接
        if stripped.startswith("[Archive]") or stripped.startswith("[Patreon]"):
            skip_footer = True
        if skip_footer:
            continue

        clean.append(line)

    md = "\n".join(clean)

    # 压缩连续空行为最多2个
    md = re.sub(r"\n{4,}", "\n\n\n", md)
    return md.strip()


def make_frontmatter(title: str, date: str) -> str:
    """生成Zola TOML frontmatter。"""
    # 转义标题中的引号
    safe_title = title.replace('"', '\\"')
    return f"""+++
title = "{safe_title}"
date  = {date}
[taxonomies]
tags  = ["danluu"]
+++"""


def crawl():
    """主流程: 爬取首页 → 逐篇下载 → 转换 → 保存。"""
    print(f"[1/3] 获取首页 {BASE_URL} ...")
    index_html = fetch(BASE_URL)
    articles = parse_index(index_html)
    print(f"      发现 {len(articles)} 篇文章")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    success, skip, fail = 0, 0, 0
    total = len(articles)

    print(f"[2/3] 开始逐篇爬取...")
    for i, art in enumerate(articles, 1):
        slug     = art["slug"]
        out_path = OUTPUT_DIR / f"danluu-{slug}.md"

        # 已存在则跳过(支持断点续爬)
        if out_path.exists():
            skip += 1
            print(f"  [{i:3d}/{total}] skip  {slug}")
            continue

        url = f"{BASE_URL}/{slug}/"
        try:
            html = fetch(url)
            content_html = extract_article_content(html)
            md = html_to_markdown(content_html, art["title"])
            frontmatter = make_frontmatter(art["title"], art["date"])
            out_path.write_text(f"{frontmatter}\n\n{md}\n", encoding="utf-8")
            success += 1
            print(f"  [{i:3d}/{total}] saved {slug}")
        except Exception as e:
            fail += 1
            print(f"  [{i:3d}/{total}] FAIL  {slug}: {e}")

        time.sleep(DELAY)

    print(f"[3/3] 完成: {success} saved, {skip} skipped, {fail} failed")


if __name__ == "__main__":
    crawl()
