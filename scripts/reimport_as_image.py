import glob
import re

comics_dir = r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\images\comics\*.import"

for path in glob.glob(comics_dir):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    content = re.sub(r'importer=".*?"', 'importer="image"', content)
    content = re.sub(r'type=".*?"', 'type="Image"', content)
    content = re.sub(r'valid=false', 'valid=true', content)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)

print(f"Successfully re-configured {len(glob.glob(comics_dir))} comic import files to importer='image' and type='Image'!")
W