# Image Downloader Skill

Kurz: Dieses Skill automatisiert das Finden und Herunterladen von lizenzfreien Bildern (z. B. Unsplash/Pexels) inklusive optionaler Annahme von Cookie‑Bannern per Playwright und sichert Lizenzangaben in `assets/credits.md`.

Features
- Browser‑gestützte Suche & Cookie‑Akzeptanz (Playwright)
- Extraktion von `src` / `srcset` / site `napi` metadata (Unsplash)
- Robust Downloader mit UA + Referer + Pillow‑basierter Variantenerzeugung (640/1280 + WebP)
- Append Credits in `assets/credits.md` and optional update of `data/model-metadata.json`

Usage (example)

1. Create venv and install deps:

```bash
python -m venv .venv
source .venv/bin/activate  # or .venv\Scripts\Activate.ps1 on Windows
pip install -r skills/image-downloader/requirements.txt
playwright install
```

2. Run the skill (example: download by photo page URL):

```bash
python skills/image-downloader/image_skill.py --page-url "https://unsplash.com/de/fotos/..." --out-base assets/images/hero-3
```

3. Or search term via UI (uses browser search; add `--no-headless` to open visible browser for demo):

```bash
# headless (default):
python skills/image-downloader/image_skill.py --search "artificial intelligence" --pick 1 --out-base assets/images/feature-2

# non-headless demo (shows cookie acceptance and the UI):
python skills/image-downloader/image_skill.py --search "artificial intelligence" --pick 1 --out-base assets/images/feature-2 --no-headless

# Convenience wrapper (runs an interactive demo):
python scripts/image_skill_cli.py --demo
```
Notes & Ethics
- Respect `robots.txt` and ToS of image providers. Do not bypass paywalls or CAPTCHAs.
- Prefer official APIs (Unsplash/Pexels) when available and authorized; the skill supports both API and UI approaches (UI used as fallback when public API is blocked).
- Always save credit metadata and check the license before publishing.

Files
- `image_skill.py` — main skill script
- `requirements.txt` — dependency list
- `config.example.json` — sample config with placeholders for API keys

Contributions: Make sure to update `assets/credits.md` and `data/model-metadata.json` after downloads.
