from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit


REPOSITORY = Path(__file__).resolve().parents[2]
SITE = REPOSITORY / "portfolio-site"
HTML_FILE = SITE / "index.html"


class PortfolioParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = set()
        self.duplicates = set()
        self.references = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        element_id = attrs.get("id")
        if element_id:
            if element_id in self.ids:
                self.duplicates.add(element_id)
            self.ids.add(element_id)

        for attribute in ("href", "src"):
            value = attrs.get(attribute)
            if value:
                self.references.append((tag, attribute, value))


parser = PortfolioParser()
parser.feed(HTML_FILE.read_text(encoding="utf-8"))
parser.close()

errors = []
if parser.duplicates:
    errors.append("Duplicate HTML id(s): " + ", ".join(sorted(parser.duplicates)))

checked = 0
for tag, attribute, value in parser.references:
    parsed = urlsplit(value)
    if parsed.scheme or parsed.netloc:
        continue

    relative_path = unquote(parsed.path)
    target = (SITE / relative_path).resolve() if relative_path else HTML_FILE.resolve()
    if SITE.resolve() not in target.parents and target != SITE.resolve():
        errors.append(f"{tag} {attribute} escapes the portfolio folder: {value}")
        continue
    if not target.is_file():
        errors.append(f"Missing local file referenced by {tag} {attribute}: {value}")
        continue

    checked += 1
    if parsed.fragment and target == HTML_FILE.resolve():
        if unquote(parsed.fragment) not in parser.ids:
            errors.append(f"Missing page section referenced by {tag} {attribute}: {value}")

if errors:
    raise SystemExit("Portfolio checks failed:
- " + "
- ".join(errors))

print(f"Portfolio checks passed: {len(parser.ids)} unique IDs and {checked} local file references.")
