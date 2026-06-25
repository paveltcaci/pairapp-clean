import zipfile
import re
import html
from pathlib import Path

src = Path("TZ_PairApp_v1.docx")
dst = Path("TZ_PairApp_v1.txt")

if not src.exists():
    raise FileNotFoundError(f"Файл не найден: {src.resolve()}")

with zipfile.ZipFile(src) as z:
    xml = z.read("word/document.xml").decode("utf-8")

text = xml
text = re.sub(r"</w:p>", "\n", text)
text = re.sub(r"</w:tr>", "\n", text)
text = re.sub(r"<[^>]+>", "", text)
text = html.unescape(text)

lines = [line.strip() for line in text.splitlines()]
text = "\n".join(line for line in lines if line)

dst.write_text(text, encoding="utf-8")
print(f"Готово: {dst.resolve()}")