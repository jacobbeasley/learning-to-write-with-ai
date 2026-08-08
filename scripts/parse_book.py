import re
import json
import os

BOOK_PATH = r"c:\Users\jacob\Projects\novel-writing-with-ai\book.md"
OUTPUT_PATH = r"c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest\assets\data\book_content.json"

PART_ICON_MAP = {
    1: "res://assets/images/map_icons/part_01_campsite.png",
    2: "res://assets/images/map_icons/part_02_woodcutter_hut.png",
    3: "res://assets/images/map_icons/part_03_hamlet.png",
    4: "res://assets/images/map_icons/part_04_trading_post.png",
    5: "res://assets/images/map_icons/part_05_fortified_village.png",
    6: "res://assets/images/map_icons/part_06_stone_keep.png",
    7: "res://assets/images/map_icons/part_07_grand_library_town.png",
    8: "res://assets/images/map_icons/part_08_walled_city.png",
    9: "res://assets/images/map_icons/part_09_crystal_citadel.png",
    10: "res://assets/images/map_icons/part_10_imperial_metropolis.png",
    11: "res://assets/images/map_icons/part_11_beyond_the_novel.png",
}

CHAP_ICON_MAP = {
    1: "res://assets/images/map_icons/ch_01_kindling.png",
    2: "res://assets/images/map_icons/ch_02_flint_steel.png",
    3: "res://assets/images/map_icons/ch_03_wood_shavings.png",
    4: "res://assets/images/map_icons/ch_04_timber_axe.png",
    5: "res://assets/images/map_icons/ch_05_firewood_stack.png",
    6: "res://assets/images/map_icons/ch_06_sawmill_blade.png",
    7: "res://assets/images/map_icons/ch_07_stone_well.png",
    8: "res://assets/images/map_icons/ch_08_roof_shears.png",
    9: "res://assets/images/map_icons/ch_09_hearth_smoker.png",
    10: "res://assets/images/map_icons/ch_10_village_signpost.png",
    11: "res://assets/images/map_icons/ch_11_tavern_tankard.png",
    12: "res://assets/images/map_icons/ch_12_merchant_scale.png",
    13: "res://assets/images/map_icons/ch_13_trade_contract.png",
    14: "res://assets/images/map_icons/ch_14_mounted_shields.png",
    15: "res://assets/images/map_icons/ch_15_travel_sack.png",
    16: "res://assets/images/map_icons/ch_16_palisade_spike.png",
    17: "res://assets/images/map_icons/ch_17_watchtower_horn.png",
    18: "res://assets/images/map_icons/ch_18_keep_keyring.png",
    19: "res://assets/images/map_icons/ch_19_knight_helmet.png",
    20: "res://assets/images/map_icons/ch_20_banner_crest.png",
    21: "res://assets/images/map_icons/ch_21_leather_codex.png",
    22: "res://assets/images/map_icons/ch_22_astrolabe_map.png",
    23: "res://assets/images/map_icons/ch_23_city_archway.png",
    24: "res://assets/images/map_icons/ch_24_plaza_fountain.png",
    25: "res://assets/images/map_icons/ch_25_blueprint_scroll.png",
    26: "res://assets/images/map_icons/ch_26_clocktower_gear.png",
    27: "res://assets/images/map_icons/ch_27_mana_crystal.png",
    28: "res://assets/images/map_icons/ch_28_scrying_orb.png",
    29: "res://assets/images/map_icons/ch_29_alchemist_flask.png",
    30: "res://assets/images/map_icons/ch_30_golem_core.png",
    31: "res://assets/images/map_icons/ch_31_leyline_conduit.png",
    32: "res://assets/images/map_icons/ch_32_royal_seal.png",
    33: "res://assets/images/map_icons/ch_33_typeblock_press.png",
    34: "res://assets/images/map_icons/ch_34_imperial_crown.png",
    35: "res://assets/images/map_icons/ch_35_triumph_arch.png",
    36: "res://assets/images/map_icons/ch_36_screenplay_slate.png",
    37: "res://assets/images/map_icons/ch_37_game_arcade_joystick.png",
    38: "res://assets/images/map_icons/ch_38_flash_fiction_hourglass.png",
    39: "res://assets/images/map_icons/ch_39_comic_panel_grid.png",
    40: "res://assets/images/map_icons/ch_40_memoir_quill_journal.png",
    41: "res://assets/images/map_icons/ch_41_audio_headphones.png",
    42: "res://assets/images/map_icons/ch_42_journey_compass.png",
}

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
            raw_desc = desc_m.group(1).strip()
            # Clean openxml and html markup
            raw_desc = re.sub(r'```\{=openxml\}.*?```', '', raw_desc, flags=re.DOTALL)
            raw_desc = re.sub(r'```\{=html\}.*?```', '', raw_desc, flags=re.DOTALL)
            part_desc = raw_desc.strip()

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
                "map_icon": CHAP_ICON_MAP.get(chap_num, CHAP_ICON_MAP.get(35, "")),
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
            "map_icon": PART_ICON_MAP.get(i + 1, PART_ICON_MAP.get(10, "")),
            "chapter_ids": chapter_ids
        })

    data = {
        "parts": parts,
        "chapters": chapters
    }

    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"Successfully updated book_content.json with res:// image paths and map icons!")

if __name__ == "__main__":
    parse_book()
