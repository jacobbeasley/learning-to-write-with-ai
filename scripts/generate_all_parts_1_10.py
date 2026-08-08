import os, sys, time, json, argparse, subprocess

OUTPUT_DIR = r"game\prose-quest\assets\images\map_icons"
GENERATE_SCRIPT = r"scripts\generate_image.py"

PREFIX = "A full-bleed 1:1 square 8-bit retro pixel art RPG UI icon with a rustic brown carved wood frame extending flush to the outer edges of the image. Isometric 3/4 view of "
SUFFIX = ", dark fantasy RPG UI icon style, edge-to-edge brown wooden border, 16-color palette, sharp crisp pixels, full-bleed borderless framing, centered composition, no text, no outer margin."

ICONS_DESCRIPTIONS = {
    # Parts (1-10)
    "part_01_sentence_craft.png": "a single feather quill writing a luminous line of golden ink across a scroll",
    "part_02_paragraph_craft.png": "a masonry trowel placing glowing carved stone bricks into a stone wall",
    "part_03_self_editing.png": "a magnifying glass shining over a manuscript page with gold and red edit marks",
    "part_04_mastering_dialogue.png": "two crossed glowing fencing foils with speech bubbles at their tips",
    "part_05_outlining_scaling.png": "an architect blueprint map pinned with gold compass dividers",
    "part_06_psychology_character.png": "a glowing crystal heart inside a carved stone bust silhouette",
    "part_07_story_bible.png": "a massive leather-bound codex wrapped in golden chains and glowing sigils",
    "part_08_narrative_structures.png": "a grand stone archway composed of distinct architectural keystones",
    "part_09_ai_collaboration.png": "a human hand touching a glowing cybernetic robot hand with spark currents",
    "part_10_final_polish.png": "a golden manuscript tied with a wax-sealed ribbon beside a laurel wreath",

    # Chapters (1-34)
    "ch_01_music_of_prose.png": "a musical treble clef intertwined with a golden fountain pen nib writing on parchment",
    "ch_02_strong_verbs.png": "a glowing lightning bolt carving into a granite stone chisel",
    "ch_03_economy_language.png": "a pair of golden shears trimming away loose threads from a parchment scroll",
    "ch_04_concrete_specifics.png": "an iron anchor embedded deep into crystalline bedrock",
    "ch_05_sentence_flow.png": "two ribbons of glowing blue water merging smoothly into a single river stream",
    "ch_06_opening_ending.png": "a flaming torch at one end of a stone bridge with a radiant golden star at the landing",
    "ch_07_deepening_pov.png": "a glowing lens looking through a character heart silhouette",
    "ch_08_dialogue_formatting.png": "two neat stylized speech bubble frames aligned in a gold bracket grid",
    "ch_09_trusting_reader.png": "an ornate golden keyhole glowing with starlight without showing the key",
    "ch_10_proportion_pacing.png": "an ornate brass hourglass with balanced flowing glowing sand",
    "ch_11_dialogue_action.png": "a speech bubble bursting into sparks like a struck iron anvil",
    "ch_12_subtext.png": "an iceberg in dark sea water with a massive glowing underwater mass visible beneath",
    "ch_13_exposition_trap.png": "a traveler leaping over a rope trap attached to an open heavy tome",
    "ch_14_scene_beats.png": "a dramatic theater mask splitting between shadow and light with a shifting arrow",
    "ch_15_character_voice.png": "a brass megaphone emitting distinct colorful sound waves",
    "ch_16_principles_outlining.png": "a constellation node network ascending upward like a ladder",
    "ch_17_scaling_idea.png": "a small glowing seed expanding into a majestic glowing tree canopy",
    "ch_18_ghost_and_lie.png": "a dark shadow figure reflected in a cracked golden mirror",
    "ch_19_wants_vs_needs.png": "a balance scale holding a shiny gold coin on one side and a glowing heart on the other",
    "ch_20_building_antagonist.png": "a dark imposing horned helmet with glowing crimson eyes",
    "ch_21_worldbuilding.png": "a floating mini-globe surrounded by sun, moon, and element runes",
    "ch_22_organization_process.png": "a multi-tiered chest of drawers with organized parchment scrolls",
    "ch_23_three_act_structure.png": "a triptych frame divided into 3 rising golden steps",
    "ch_24_heros_journey.png": "a circular path traversing a mountain peak and returning home",
    "ch_25_save_the_cat.png": "a hero hand reaching out to lift a small cat from a dangerous ledge",
    "ch_26_story_circle.png": "an 8-segmented circular wheel with glowing stage markers",
    "ch_27_prompt_engineering.png": "a glowing quill injecting spark code into a crystalline orb",
    "ch_28_brainstorming_unblocking.png": "a bright lightbulb shattering a stone wall barrier",
    "ch_29_story_bible_assistant.png": "a cute robot scholar holding an open manuscript tome",
    "ch_30_advanced_workspaces.png": "a dual-monitor workspace setup showing code terminal and manuscript glow",
    "ch_31_ethical_boundaries.png": "a golden shield decorated with a balance scale and quill emblem",
    "ch_32_feedback_loop.png": "a circular arrangement of reader speech bubbles pointing to a central manuscript",
    "ch_33_publishing_paths.png": "a fork in a golden road leading to a printing press on one side and a digital tablet on the other",
    "ch_34_self_publishing.png": "a hardcover book popping out of a digital box with five gold rating stars",
}

# Mapping of part_id and chapter_id to new filenames
PART_ICON_MAP = {
    "part_1": "res://assets/images/map_icons/part_01_sentence_craft.png",
    "part_2": "res://assets/images/map_icons/part_02_paragraph_craft.png",
    "part_3": "res://assets/images/map_icons/part_03_self_editing.png",
    "part_4": "res://assets/images/map_icons/part_04_mastering_dialogue.png",
    "part_5": "res://assets/images/map_icons/part_05_outlining_scaling.png",
    "part_6": "res://assets/images/map_icons/part_06_psychology_character.png",
    "part_7": "res://assets/images/map_icons/part_07_story_bible.png",
    "part_8": "res://assets/images/map_icons/part_08_narrative_structures.png",
    "part_9": "res://assets/images/map_icons/part_09_ai_collaboration.png",
    "part_10": "res://assets/images/map_icons/part_10_final_polish.png",
}

CHAPTER_ICON_MAP = {
    "ch_1": "res://assets/images/map_icons/ch_01_music_of_prose.png",
    "ch_2": "res://assets/images/map_icons/ch_02_strong_verbs.png",
    "ch_3": "res://assets/images/map_icons/ch_03_economy_language.png",
    "ch_4": "res://assets/images/map_icons/ch_04_concrete_specifics.png",
    "ch_5": "res://assets/images/map_icons/ch_05_sentence_flow.png",
    "ch_6": "res://assets/images/map_icons/ch_06_opening_ending.png",
    "ch_7": "res://assets/images/map_icons/ch_07_deepening_pov.png",
    "ch_8": "res://assets/images/map_icons/ch_08_dialogue_formatting.png",
    "ch_9": "res://assets/images/map_icons/ch_09_trusting_reader.png",
    "ch_10": "res://assets/images/map_icons/ch_10_proportion_pacing.png",
    "ch_11": "res://assets/images/map_icons/ch_11_dialogue_action.png",
    "ch_12": "res://assets/images/map_icons/ch_12_subtext.png",
    "ch_13": "res://assets/images/map_icons/ch_13_exposition_trap.png",
    "ch_14": "res://assets/images/map_icons/ch_14_scene_beats.png",
    "ch_15": "res://assets/images/map_icons/ch_15_character_voice.png",
    "ch_16": "res://assets/images/map_icons/ch_16_principles_outlining.png",
    "ch_17": "res://assets/images/map_icons/ch_17_scaling_idea.png",
    "ch_18": "res://assets/images/map_icons/ch_18_ghost_and_lie.png",
    "ch_19": "res://assets/images/map_icons/ch_19_wants_vs_needs.png",
    "ch_20": "res://assets/images/map_icons/ch_20_building_antagonist.png",
    "ch_21": "res://assets/images/map_icons/ch_21_worldbuilding.png",
    "ch_22": "res://assets/images/map_icons/ch_22_organization_process.png",
    "ch_23": "res://assets/images/map_icons/ch_23_three_act_structure.png",
    "ch_24": "res://assets/images/map_icons/ch_24_heros_journey.png",
    "ch_25": "res://assets/images/map_icons/ch_25_save_the_cat.png",
    "ch_26": "res://assets/images/map_icons/ch_26_story_circle.png",
    "ch_27": "res://assets/images/map_icons/ch_27_prompt_engineering.png",
    "ch_28": "res://assets/images/map_icons/ch_28_brainstorming_unblocking.png",
    "ch_29": "res://assets/images/map_icons/ch_29_story_bible_assistant.png",
    "ch_30": "res://assets/images/map_icons/ch_30_advanced_workspaces.png",
    "ch_31": "res://assets/images/map_icons/ch_31_ethical_boundaries.png",
    "ch_32": "res://assets/images/map_icons/ch_32_feedback_loop.png",
    "ch_33": "res://assets/images/map_icons/ch_33_publishing_paths.png",
    "ch_34": "res://assets/images/map_icons/ch_34_self_publishing.png",
}

def main():
    parser = argparse.ArgumentParser(description="Batch generate map icons for Parts 1-10 & Chapters 1-34")
    parser.add_argument("--api-key", "-k", help="Gemini API Key")
    parser.add_argument("--force", "-f", action="store_true", help="Force regenerate existing images")
    args, unknown = parser.parse_known_args()

    api_key = args.api_key or os.environ.get("GEMINI_API_KEY", "").strip()
    if not api_key and len(sys.argv) > 1 and not sys.argv[1].startswith("-"):
        api_key = sys.argv[1].strip()

    if not api_key:
        print("[ERROR] No Gemini API key provided!")
        print("Usage: python scripts/generate_all_parts_1_10.py --api-key <YOUR_API_KEY>")
        print("   OR: set GEMINI_API_KEY environment variable.")
        sys.exit(1)

    print(f"Generating {len(ICONS_DESCRIPTIONS)} icons sequentially...")
    total = len(ICONS_DESCRIPTIONS)
    idx = 0

    for fname, desc in ICONS_DESCRIPTIONS.items():
        idx += 1
        out_path = os.path.join(OUTPUT_DIR, fname)
        print(f"\n[{idx}/{total}] Generating {fname}...")

        cmd = [
            sys.executable,
            GENERATE_SCRIPT,
            "--prompt", desc,
            "--out", out_path,
            "--api-key", api_key,
            "--prefix", PREFIX,
            "--suffix", SUFFIX,
        ]
        if args.force:
            cmd.append("--force")

        res = subprocess.run(cmd)
        if res.returncode != 0:
            print(f"[WARNING] Generation failed for {fname}, continuing...")
        time.sleep(1)

    print("\n--- Image Generation Complete ---")
    print("Updating book_content.json...")

    json_path = r"game\prose-quest\assets\data\book_content.json"
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Update parts 1-10
    for p in data.get("parts", []):
        pid = p.get("id")
        if pid in PART_ICON_MAP:
            p["map_icon"] = PART_ICON_MAP[pid]
            print(f"Updated {pid} map_icon -> {p['map_icon']}")

    # Update chapters 1-34
    for c in data.get("chapters", []):
        cid = c.get("id")
        if cid in CHAPTER_ICON_MAP:
            c["map_icon"] = CHAPTER_ICON_MAP[cid]
            print(f"Updated {cid} map_icon -> {c['map_icon']}")

    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)

    print("\n[SUCCESS] All icon paths updated in book_content.json!")

if __name__ == "__main__":
    main()
