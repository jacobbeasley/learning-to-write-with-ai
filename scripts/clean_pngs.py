import glob, os, re
from PIL import Image

# Target Parts 1-10 and Chapters 1-34 icons
TARGET_PATTERN = re.compile(r'^(part_0[1-9]|part_10|ch_0[1-9]|ch_[12][0-9]|ch_3[0-4])')

search_dirs = [
    r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\images\map_icons\*.png",
]

cleaned_count = 0
for s_dir in search_dirs:
    for path in glob.glob(s_dir):
        fname = os.path.basename(path)
        if not TARGET_PATTERN.match(fname):
            continue
            
        try:
            with Image.open(path) as img:
                img = img.convert("RGBA")
                img.save(path, "PNG", optimize=True)
                cleaned_count += 1
                print(f"Cleaned PNG: {fname}")
                
            import_file = path + ".import"
            if os.path.exists(import_file):
                os.remove(import_file)
        except Exception as e:
            print(f"Error processing {path}: {e}")

print(f"\nPNG cleaning complete! Cleaned {cleaned_count} icons for Parts 1-10 & Chapters 1-34.")
