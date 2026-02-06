ERD (Mermaid) and how to produce PNG/SVG

Files:
- docs/ERD.mmd : Mermaid ERD source (mermaid `erDiagram`).

Generate PNG or SVG using the Mermaid CLI (recommended):

1) Install (via npm):

```bash
npm install -g @mermaid-js/mermaid-cli
```

2) Generate PNG or SVG:

```bash
mmdc -i docs/ERD.mmd -o docs/ERD.png
mmdc -i docs/ERD.mmd -o docs/ERD.svg
```

Alternate: Use VS Code "Markdown Preview Mermaid Support" or "Mermaid Preview" extensions and export the diagram.

Notes:
- The `.mmd` file uses `erDiagram` syntax; Mermaid CLI supports rendering it to SVG/PNG.
- If you prefer a pre-generated PNG, run `mmdc` above locally or in a CI step and commit the output.
