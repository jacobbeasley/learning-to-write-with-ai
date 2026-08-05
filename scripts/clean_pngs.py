import glob
from PIL import Image

map_icons_dir = r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\images\map_icons\*.png"

png_files = glob.glob(map_icons_dir)
for path in png_files:
    try:
        with Image.open(path) as img:
            img = img.convert("RGBA")
            # Save clean PNG without extra metadata chunks
            img.save(path, "PNG", optimize=True)
            print(f"Cleaned PNG: {path}")
    except Exception as e:
        print(f"Error processing {path}: {e}")

print("PNG cleaning complete!")
