import re
import json
import os

BOOK_PATH = r"c:\Users\jacob\Projects\novel-writing-with-ai\book.md"
OUTPUT_PATH = r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\data\book_content.json"

def markdown_to_bbcode(text):
    """Converts basic markdown formatting to Godot BBCode."""
    if not text:
        return ""
    
    # Clean up openxml / html page breaks
    text = re.sub(r'```\{=openxml\}.*?```', '', text, flags=re.DOTALL)
    text = re.sub(r'```\{=html\}.*?```', '', text, flags=re.DOTALL)
    
    # Bold **text** -> [b]text[/b]
    text = re.sub(r'\*\*(.*?)\*\*', r'[b]\1[/b]', text)
    # Italic *text* -> [i]text[/i]
    text = re.sub(r'\*(.*?)\*', r'[i]\1[/i]', text)

    lines = text.split('\n')
    new_lines = []
    in_quote = False
    for line in lines:
        sline = line.strip()
        if sline.startswith('>'):
            quote_content = sline[1:].strip()
            if not in_quote:
                new_lines.append('[indent][i]' + quote_content)
                in_quote = True
            else:
                new_lines.append(quote_content)
        else:
            if in_quote:
                new_lines[-1] += '[/i][/indent]'
                in_quote = False
            new_lines.append(line)
    if in_quote:
        new_lines[-1] += '[/i][/indent]'
        
    text = '\n'.join(new_lines)
    
    # Headings formatting
    text = re.sub(r'^#### (.*?)$', r'[font_size=18][b][color=#d4a574]\1[/color][/b][/font_size]', text, flags=re.MULTILINE)
    text = re.sub(r'^##### (.*?)$', r'[font_size=16][b][color=#e8a849]\1[/color][/b][/font_size]', text, flags=re.MULTILINE)
    text = re.sub(r'^### (.*?)$', r'[font_size=20][b][color=#d4a574]\1[/color][/b][/font_size]', text, flags=re.MULTILINE)
    
    return text.strip()

def fix_comic_path(img_path):
    if not img_path:
        return ""
    filename = os.path.basename(img_path)
    return f"res://assets/images/comics/{filename}"

def parse_book():
    with open(BOOK_PATH, 'r', encoding='utf-8') as f:
        content = f.read()

    part_matches = list(re.finditer(r'^# Part ([IVXLCDM]+):\s*(.*?)$', content, re.MULTILINE))
    
    parts = []
    chapters = []

    for i, p_match in enumerate(part_matches):
        part_title = p_match.group(2).strip()
        part_id = f"part_{i+1}"
        
        start_idx = p_match.start()
        end_idx = part_matches[i+1].start() if i + 1 < len(part_matches) else len(content)
        part_section = content[start_idx:end_idx]
        
        # Part Comic
        part_comic = ""
        comic_m = re.search(r'!\[Part.*?\]\((images/.*?)\)', part_section)
        if comic_m:
            part_comic = fix_comic_path(comic_m.group(1))
            
        # Part Description
        part_desc = ""
        desc_m = re.search(r'^# Part [IVXLCDM]+:.*?\n(.*?)(?=\n!\[|\n## Chapter)', part_section, re.DOTALL)
        if desc_m:
            part_desc = desc_m.group(1).strip()

        # Find all Chapter headers inside this part: ## Chapter X: Title
        chap_matches = list(re.finditer(r'^## Chapter (\d+):\s*(.*?)$', part_section, re.MULTILINE))
        chapter_ids = []

        for j, c_match in enumerate(chap_matches):
            chap_num = int(c_match.group(1))
            chap_title = c_match.group(2).strip()
            chap_id = f"ch_{chap_num}"
            chapter_ids.append(chap_id)
            
            c_start = c_match.start()
            c_end = chap_matches[j+1].start() if j + 1 < len(chap_matches) else len(part_section)
            chap_section = part_section[c_start:c_end]
            
            # Chapter Comic
            chap_comic = ""
            c_comic_m = re.search(r'!\[Chapter.*?\]\((images/.*?)\)', chap_section)
            if c_comic_m:
                chap_comic = fix_comic_path(c_comic_m.group(1))

            # Sample Prompt
            sample_prompt = ""
            prompt_m = re.search(r'### 3\. Sample Prompt.*?\n```(?:text)?\n(.*?)```', chap_section, re.DOTALL)
            if prompt_m:
                sample_prompt = prompt_m.group(1).strip()

            # Interactive Activity
            activity_text = ""
            act_m = re.search(r'### 2\. Interactive AI Activity\s*\n(.*?)(?=### 3\. Sample Prompt|$)', chap_section, re.DOTALL)
            if act_m:
                activity_text = act_m.group(1).strip()

            # Principles
            principles_text = ""
            princ_m = re.search(r'### 1\. Principles.*?\n(.*?)(?=### 2\. Interactive AI Activity|$)', chap_section, re.DOTALL)
            if princ_m:
                principles_text = princ_m.group(1).strip()
            elif not act_m and not prompt_m:
                principles_text = chap_section.strip()

            chapters.append({
                "id": chap_id,
                "number": chap_num,
                "title": chap_title,
                "part_id": part_id,
                "comic": chap_comic,
                "principles_bbcode": markdown_to_bbcode(principles_text),
                "activity_bbcode": markdown_to_bbcode(activity_text),
                "sample_prompt": sample_prompt
            })

        parts.append({
            "id": part_id,
            "number": i + 1,
            "title": part_title,
            "description": part_desc,
            "comic": part_comic,
            "chapter_ids": chapter_ids
        })

    data = {
        "parts": parts,
        "chapters": chapters
    }

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Successfully updated book_content.json with res:// image paths!")

if __name__ == "__main__":
    parse_book()
