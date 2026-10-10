#!/usr/bin/env python3
"""Version Flutter entry scripts so browser caches cannot hide a new release."""
import re
import sys
from pathlib import Path

web = Path(sys.argv[1])
revision = sys.argv[2]
if not re.fullmatch(r"[0-9a-f]{7,64}", revision):
    raise SystemExit("Expected a Git revision")

index = web / "index.html"
bootstrap = web / "flutter_bootstrap.js"
html, html_count = re.subn(
    r'(?<=src=")flutter_bootstrap\.js(?:\?[^"\s]*)?(?=")',
    f"flutter_bootstrap.js?v={revision}",
    index.read_text(),
)
js, js_count = re.subn(
    r'("mainJsPath"\s*:\s*")main\.dart\.js(?:\?[^"\s]*)?(")',
    rf"\g<1>main.dart.js?v={revision}\g<2>",
    bootstrap.read_text(),
)
if html_count != 1 or js_count != 1:
    raise SystemExit("Unexpected Flutter entry scripts; no files changed")

# Write the referenced script first, then publish the HTML pointing to it.
for path, content in ((bootstrap, js), (index, html)):
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_text(content)
    temporary.replace(path)
