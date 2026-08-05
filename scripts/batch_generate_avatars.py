import os, sys, subprocess
from generate_image import generate_image

OUTPUT_DIR = r"game\prose-quest\assets\images\avatars"
os.makedirs(OUTPUT_DIR, exist_ok=True)

AVATAR_DESCRIPTIONS = {
    # Female Avatars (8)
    "avatar_01_novice_scribe.png": "a stylish and attractive slender female novice scribe with blonde hair tied in a high ponytail with a pink ribbon, wearing soft pink lipstick and makeup, fitted linen tunic, holding a feather quill and leather scroll bag",
    "avatar_02_cyberpunk_hacker.png": "a glamorous and athletic female cyber-runner with twin high pigtails, wearing a cropped leather jacket with glowing neon trim and a cybernetic arm interface",
    "avatar_03_wandering_bard.png": "a graceful and attractive female musician with an elegant braided updo under a feathered cap, wearing a fitted traveling cloak and carrying a wooden lute",
    "avatar_04_clockwork_engineer.png": "a fit and muscular female engineer with a high messy bun updo, wearing a fitted leather corseted apron and brass goggles on her forehead, holding a spanner wrench",
    "avatar_05_high_elf_archivist.png": "an elegant and sleek high elf female with a high ponytail adorned with silver hair rings, wearing fitted silk robes and holding an ancient glowing scroll",
    "avatar_06_desert_cartographer.png": "an attractive and slender female cartographer with a stylish braided updo and silk headscarf, wearing fitted adventurer garb, leather map case, and compass",
    "avatar_07_alchemist_researcher.png": "an alluring and athletic female alchemist with high pigtails featuring purple highlights, wearing a dark fitted leather coat with brass straps, holding a bubbling flask",
    "avatar_08_shadow_scriptor.png": "a sleek and striking female assassin with a high ponytail cascading from a dark hooded cowl, wearing fitted black leather armor with silver buckles and a quill dagger",

    # Male Avatars (8)
    "avatar_09_arcane_scholar.png": "a slender and boyish young male scholar with long flowing silver hair tied in a high ponytail, wearing glowing spectacles and open collar scholar robes",
    "avatar_10_royal_historian.png": "a dignified noble male with shoulder-length wavy dark hair, wearing rich velvet robes with gold embroidery, holding a brass inkhorn",
    "avatar_11_dragon_archivist.png": "a broad-shouldered muscular male warrior with a long braided dark mane down his back, wearing dragon-scale chest armor and holding a dragon codex",
    "avatar_12_imperial_laureate.png": "a slender and boyish male poet with long blonde hair tied in a sleek high ponytail, wearing a golden laurel wreath and draped golden mantle",
    "avatar_13_sea_captain_chronicler.png": "a weathered sailor male with long chest-length dark hair with beads, wearing a tricorn hat and eyepatch, holding a ship logbook",
    "avatar_14_paladin_scriptor.png": "a broad knight male build with a neat short crop haircut, wearing polished plate armor with a tabard, holding a sacred scripture tome",
    "avatar_15_space_station_cryptographer.png": "a lean and youthful slender male build with a sharp futuristic bob cut hairstyle, wearing a sleek sci-fi jumpsuit with a holographic wrist-pad interface",
    "avatar_16_dwarven_runesmith.png": "a short and stout dwarven male with long braided copper hair and a matching braided beard, holding an iron hammer and rune-carved stone tablet",
}

def main():
    api_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if not api_key and len(sys.argv) > 1:
        api_key = sys.argv[1].strip()
        
    if not api_key:
        print("Usage: python scripts/batch_generate_avatars.py <YOUR_GEMINI_API_KEY>")
        sys.exit(1)
        
    print(f"Starting batch generation of {len(AVATAR_DESCRIPTIONS)} profile avatars...")
    success_count = 0
    for filename, prompt in AVATAR_DESCRIPTIONS.items():
        out_path = os.path.join(OUTPUT_DIR, filename)
        if generate_image(prompt, out_path, api_key=api_key, clean_png=False):
            success_count += 1
            
    print(f"\nBatch generation complete! {success_count}/{len(AVATAR_DESCRIPTIONS)} profile avatars ready.")
    
    # Run PNG metadata cleaner
    ps_script = os.path.join(os.path.dirname(__file__), "clean_pngs.ps1")
    if os.path.exists(ps_script):
        print("Cleaning PNG metadata via clean_pngs.ps1...")
        subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", ps_script])

if __name__ == "__main__":
    main()
