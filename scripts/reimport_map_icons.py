import glob
import re

map_icons_dir = r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\images\map_icons\*.import"

import_files = glob.glob(map_icons_dir)
for path in import_files:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = re.sub(r'importer=".*?"', 'importer="image"', content)
    content = re.sub(r'type=".*?"', 'type="Image"', content)
    content = re.sub(r'valid=false', 'valid=true', content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

print(f"Successfully re-configured {len(import_files)} map_icon import files to valid=true!")
