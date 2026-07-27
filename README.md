# Jar Comparator Tool

A standalone HTML tool for comparing JAR files between two folders. Select two directories and instantly see which JARs match, differ, or exist in only one folder. Dive deeper to inspect per-entry differences and side-by-side content diffs.

> **Live Demo:** https://chankingching.github.io/Jar-Comparator-Tool/

---

## Features

-   **Two-folder comparison** — pick two folders (with subdirectories), match JARs by filename
-   **Summary bar** — total JARs per folder, identical / different / only-one-side counts
-   **Per-JAR diff card** — expand each JAR to see a summary table of entries (added / removed / modified)
-   **Side-by-side content diff** — view actual text changes inside modified files with smart line alignment
-   **Collapsible entries** — click to toggle individual file diffs on/off
-   **Filter & sort** — filter by status (identical, different, only-A, only-B) or text search
-   **Bulk expand/collapse** — expand or collapse all details at once
-   **Light / dark mode** — toggle with one click, persists via localStorage
-   **Cancel comparison** — abort long-running comparisons mid-flight
-   **Fully offline** — single HTML file, no install, no server needed

---

## Quick Start

1.  Open `index.html` in Chrome or Edge (requires `webkitdirectory` support)
2.  Click the **資料夾 A** area and select a directory containing `.jar` files
3.  Click the **資料夾 B** area and select another directory
4.  Click **🔍 開始比對**
5.  Click any JAR card to expand its diff result

## Screenshot

![screenshot](docs/screenshot.png)

---

## Project Structure

```
Jar-Comparator-Tool-v1.0/
├── index.html              # Main tool (single-file, zero dependencies)
├── README.md
├── docs/
│   └── screenshot.png
└── tests/
    └── 2026-07-27_test-scenario-2/
        ├── folderA/        # 21 JARs covering 22 test scenarios
        ├── folderB/        # 21 JARs (paired + only-one-side)
        └── generate.ps1    # Script to regenerate all test JARs
```

## Test Scenarios (22 cases)

| Type | Count | Description |
|------|-------|-------------|
| Identical | 7 | identical, empty, single, many-files, zero-byte, multi-loc, lib-common |
| Different | 13 | diff-size, diff-content, added-file, removed-file, mod-content, shift-content, multi-mod, deep-path, special-chars, binary-diff, large-file, mixed, same-lines-diff-order |
| Only-in-A | 1 | only-a |
| Only-in-B | 1 | only-b |

Open `folderA` and `folderB` inside the test directory to verify all scenarios.

---

## Technical Notes

- Built with **vanilla HTML / CSS / JavaScript** — no frameworks
- Uses [JSZip 3.10.1](https://stuk.github.io/jszip/) from CDN for reading ZIP/JAR entries
- Requires browser with `webkitdirectory` support (Chrome, Edge, Opera)
- All processing happens client-side — no data is uploaded anywhere

---

## License

MIT
