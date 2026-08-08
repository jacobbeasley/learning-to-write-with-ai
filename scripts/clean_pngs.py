import glob, os, re
from PIL import Image

TARGET_PATTERN = re.compile(r'^(part11_|chapter35_|chapter36_|chapter37_|chapter38_|chapter39_|chapter40_|chapter41_|chapter42_|ch_35_|ch_36_|ch_37_|ch_38_|ch_39_|ch_40_|ch_41_|ch_42_)')

search_dirs = [
    r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\images\map_icons\*.png",
    r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\images\comics\*.png"
]

for s_dir in search_dirs:
    for path in glob.glob(s_dir):
        fname = os.path.basename(path)
        if not TARGET_PATTERN.match(fname):
            continue
            
        try:
            with Image.open(path) as img:
                img = img.convert("RGBA")
                img.save(path, "PNG", optimize=True)
                print(f"Cleaned PNG: {path}")
                
            import_file = path + ".import"
            if os.path.exists(import_file):
                os.remove(import_file)
        except Exception as e:
            print(f"Error processing {path}: {e}")

print("PNG cleaning complete for Part 11 and Chapters 35-42!")
