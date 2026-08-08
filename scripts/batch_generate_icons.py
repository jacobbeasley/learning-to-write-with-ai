import os, sys, json, subprocess
from google import genai
from google.genai import types

OUTPUT_DIR = r"game\prose-quest\assets\images\map_icons"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Standardized Prompt Template: Edge-to-Edge Full-Bleed Brown Wood Frame & Isometric Perspective
PREFIX = "A full-bleed 1:1 square 8-bit retro pixel art RPG UI icon with a rustic brown carved wood frame extending flush to the outer edges of the image. Isometric 3/4 view of "
SUFFIX = ", dark fantasy RPG UI icon style, edge-to-edge brown wooden border, 16-color palette, sharp crisp pixels, full-bleed borderless framing, centered composition, no text, no outer margin."

# 41 Remaining Icon Prompts (Parts 2-10 & Chapters 4-35)
RAW_DESCRIPTIONS = {
    # Parts
    "part_02_woodcutter_hut.png": "a woodcutter's rustic log cabin with a timber log stack outside",
    "part_03_hamlet.png": "a small village hamlet with thatched roof cottages and a stone water well",
    "part_04_trading_post.png": "a busy crossroads tavern and trading post with market stalls",
    "part_05_fortified_village.png": "a fortified village with wooden palisade walls and watchtowers",
    "part_06_stone_keep.png": "a stone keep fortress with iron-reinforced gates and battlements",
    "part_07_grand_library_town.png": "a walled town featuring a tall grand library sanctuary spire",
    "part_08_walled_city.png": "a magnificent walled city with double stone walls and tall spires",
    "part_09_crystal_citadel.png": "a magical crystal citadel with glowing blue obsidian spires",
    "part_10_imperial_metropolis.png": "a sprawling futuristic metropolis in the clouds with glowing obsidian-roofed palaces and a triumph archway",
    "part_11_beyond_the_novel.png": "a cosmic starry realm with glowing holographic film reels, audio soundwaves, and game controllers",

    # Chapters
    "ch_04_timber_axe.png": "a heavy woodcutter axe stuck into a tree stump",
    "ch_05_firewood_stack.png": "neatly stacked firewood logs bound with twine",
    "ch_06_sawmill_blade.png": "a circular sawmill blade and hand crosscut saw",
    "ch_07_stone_well.png": "a village stone water well with a rope and bucket",
    "ch_08_roof_shears.png": "thatched roof shears and a large iron needle",
    "ch_09_hearth_smoker.png": "a stone hearth chimney with rising smoke",
    "ch_10_village_signpost.png": "a wooden village signpost with a hanging lantern",
    "ch_11_tavern_tankard.png": "a foaming wooden tavern tankard",
    "ch_12_merchant_scale.png": "a brass merchant balance scale and gold coin",
    "ch_13_trade_contract.png": "a rolled parchment contract with a red wax seal",
    "ch_14_mounted_shields.png": "crossed iron swords behind a mounted shield",
    "ch_15_travel_sack.png": "a heavy leather travel sack and road map scroll",
    "ch_16_palisade_spike.png": "a sharp wooden palisade spike",
    "ch_17_watchtower_horn.png": "a brass signal horn and watchtower ladder",
    "ch_18_keep_keyring.png": "heavy iron fortress keys on a keyring",
    "ch_19_knight_helmet.png": "a knight's visor helmet on an armor stand",
    "ch_20_banner_crest.png": "a woven heraldic banner with a noble crest",
    "ch_21_leather_codex.png": "a thick leather-bound codex tome and feather quill",
    "ch_22_astrolabe_map.png": "a brass astrolabe and star constellation map",
    "ch_23_city_archway.png": "a grand stone city gate archway with iron portcullis",
    "ch_24_plaza_fountain.png": "a carved stone plaza fountain with flowing water",
    "ch_25_blueprint_scroll.png": "an architect blueprint scroll and brass compass",
    "ch_26_clocktower_gear.png": "interlocking brass clocktower gear wheels",
    "ch_27_mana_crystal.png": "a glowing blue mana crystal prism",
    "ch_28_scrying_orb.png": "an enchanted glass scrying orb on a carved pedestal",
    "ch_29_alchemist_flask.png": "a bubbling purple alchemist flask and crucible",
    "ch_30_golem_core.png": "a glowing rune-carved golem core stone",
    "ch_31_leyline_conduit.png": "a pulsing leyline magic energy conduit node",
    "ch_32_royal_seal.png": "a golden royal imperial wax seal with red ribbon",
    "ch_33_typeblock_press.png": "metal printing press movable type blocks",
    "ch_34_imperial_crown.png": "a jeweled golden imperial crown on a velvet cushion",
    "ch_35_triumph_arch.png": "a golden triumph archway entering the metropolis",
    "ch_36_screenplay_slate.png": "a film director clapperboard slate and film reel",
    "ch_37_game_arcade_joystick.png": "a retro arcade joystick and glowing choice buttons",
    "ch_38_flash_fiction_hourglass.png": "a small brass hourglass with glowing sand",
    "ch_39_comic_panel_grid.png": "a comic book page layout frame with speech bubble icons",
    "ch_40_memoir_quill_journal.png": "an open vintage leather memoir journal with a silver quill",
    "ch_41_audio_headphones.png": "studio sound headphones over a soundwave audio visualizer",
    "ch_42_journey_compass.png": "a golden explorer compass pointing toward a glowing horizon door",
}

ICONS_TO_GENERATE = {
    fname: f"{PREFIX}{desc}{SUFFIX}" for fname, desc in RAW_DESCRIPTIONS.items()
}

def generate_with_sdk(client, filename, prompt, force_overwrite=False):
    out_path = os.path.join(OUTPUT_DIR, filename)
    if not force_overwrite and os.path.exists(out_path) and os.path.getsize(out_path) > 0:
        print(f"[SKIP] {filename} already exists.")
        return True
        
    models = ['gemini-3.1-flash-image', 'gemini-2.5-flash-image']
    for model_name in models:
        try:
            response = client.models.generate_content(
                model=model_name,
                contents=prompt,
                config=types.GenerateContentConfig(response_modalities=["IMAGE"])
            )
            if response.candidates and response.candidates[0].content.parts:
                for part in response.candidates[0].content.parts:
                    if part.inline_data and part.inline_data.data:
                        with open(out_path, "wb") as f:
                            f.write(part.inline_data.data)
                        print(f"[SUCCESS] Generated {filename} using {model_name}")
                        return True
        except Exception as e:
            continue
            
    print(f"[ERROR] Failed to generate {filename}")
    return False

def main():
    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not api_key and len(sys.argv) > 1:
        api_key = sys.argv[1].strip()
        
    if not api_key:
        print("Usage: python scripts/batch_generate_icons.py <YOUR_GEMINI_API_KEY>")
        sys.exit(1)
        
    client = genai.Client(api_key=api_key)
    
    print(f"Starting batch generation of {len(ICONS_TO_GENERATE)} icons (skipping existing files)...")
    success_count = 0
    for filename, prompt in ICONS_TO_GENERATE.items():
        if generate_with_sdk(client, filename, prompt):
            success_count += 1
            
    print(f"\nBatch generation complete! {success_count}/{len(ICONS_TO_GENERATE)} icons ready.")
    
    # Run PNG metadata cleaner
    ps_script = os.path.join(os.path.dirname(__file__), "clean_pngs.ps1")
    if os.path.exists(ps_script):
        print("Cleaning PNG metadata via clean_pngs.ps1...")
        subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", ps_script])
        
    # Run book_content.json updater
    update_script = os.path.join(os.path.dirname(__file__), "update_book_content_icons.py")
    if os.path.exists(update_script):
        print("Updating book_content.json links...")
        subprocess.run(["python", update_script])

if __name__ == "__main__":
    main()
