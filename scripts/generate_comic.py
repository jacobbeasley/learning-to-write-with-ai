import os
import sys
import argparse
import subprocess
from google import genai
from google.genai import types

# Standard 3-panel horizontal comic strip prompt style for Professor Jennifer & Jacob (1:1 Square Canvas)
DEFAULT_COMIC_PREFIX = "A full-bleed 1:1 square canvas containing a horizontal 3-panel digital comic strip (3 comic panels arranged horizontally inside the square canvas). Vibrant digital comic book style, bold black linework, rich saturated colors, clear legible speech bubbles and panel dividers, full-frame composition extending flush to all edges of the square image without outer margins. "
DEFAULT_COMIC_SUFFIX = " Featuring Professor Jennifer (sleek female robot professor with ponytail, wire-rimmed glasses, blazer, cybernetic facial seams) and Jacob (35yo male student with curly brown hair). Square 1:1 format, clean digital comic art."

# Prompts for Part XI and Chapters 35-42
PART_XI_COMICS = {
    "part11_beyond_the_novel_comic.png": (
        "Panel 1: Professor Jennifer and Jacob stand in a futuristic holograph theater. Jennifer points to floating holographic film reels, audio soundwaves, and comic book panel layouts. Jennifer: 'Beyond prose lies a multiverse of storytelling mediums.' "
        "Panel 2: Jacob wearing a VR headset holding a glowing stylus, attempting to draw a screenplay scene in 3D mid-air looking amazed. Jacob: 'So AI can help me write screenplays, games, and comics?!' "
        "Panel 3: Professor Jennifer adjusting her glasses with a sly robotic smile as a hologram dragon flies out of a comic frame. Jennifer: 'Craft principles never change, Jacob. Only the medium evolves!'"
    ),
    "chapter35_poetry_lyric_prose_comic.png": (
        "Panel 1: Jacob sitting at a wooden desk struggling to write a poem, surrounded by crumpled paper with abstract words like 'SADNESS' and 'DARKNESS'. Jacob: 'My verse feels so abstract and flat!' "
        "Panel 2: Professor Jennifer taps a glowing digital tuning fork that radiates golden musical waves of meter and stress across the room. Jennifer: 'Anchor your rhythm in concrete objects, Jacob!' "
        "Panel 3: Jacob gasps with joy as his paper sparkles, revealing vivid lines about frost on glass and iron rain. Jacob: 'The prose is singing!'"
    ),
    "chapter36_screenplays_scriptwriting_comic.png": (
        "Panel 1: Jacob sitting in front of a giant cinema movie screen holding a thick 500-page novel manuscript. Jacob: 'How do I fit all this internal monologue on screen?' "
        "Panel 2: Professor Jennifer holding film clapperboard and scissors, cutting a long novel paragraph into lean 3-line action blocks and sluglines. Jennifer: '1 page equals 1 minute! Show external behavior, not internal thoughts!' "
        "Panel 3: On the movie screen, a film noir scene plays dynamically with a detective dodging rain. Jacob: 'Subtext says more than words!'"
    ),
    "chapter37_interactive_game_writing_comic.png": (
        "Panel 1: Jacob sitting in front of a glowing arcade machine with branching dialogue trees floating around his head in neon green. Jacob: 'Every choice I write creates twenty new branches!' "
        "Panel 2: Professor Jennifer standing at a digital flowchart board showing state variables ($trust, $gold) folding back into anchor nodes. Jennifer: 'Use state variables and fold-back structures to preserve player agency without chaos!' "
        "Panel 3: Jacob playing the RPG game on screen, smiling as his trust variable unlocks a secret door. Jacob: 'Meaningful choices with real consequences!'"
    ),
    "chapter38_flash_fiction_comic.png": (
        "Panel 1: Jacob trying to squeeze a giant 1,000-word book into a tiny micro-envelope. Jacob: 'It won't fit into 250 words!' "
        "Panel 2: Professor Jennifer using a high-tech shrink ray beam to vaporize weak adverbs and slow backstory setup. Jennifer: 'Launch in media res! Cut every word that doesn't carry double weight!' "
        "Panel 3: The tiny micro-envelope glows with intense energy, delivering a powerful punch ending spark. Jacob: 'Small size, massive emotional impact!'"
    ),
    "chapter39_graphic_novels_comic.png": (
        "Panel 1: Jacob staring at an empty 4-panel comic page layout holding a pencil. Jacob: 'How do I pace panels for an illustrator or AI engine?' "
        "Panel 2: Professor Jennifer operating a local workstation with ComfyUI and IP-Adapter-Plus loading character reference sheets. Jennifer: 'Keep character consistency with IP-Adapter and build page-turn cliffhangers!' "
        "Panel 3: The comic page fills with vibrant action art, speech bubbles, and a dramatic bottom-right cliffhanger. Jacob: 'The page-turn reveal is electric!'"
    ),
    "chapter40_memoir_creative_nonfiction_comic.png": (
        "Panel 1: Jacob looking at a dusty framed photo of his 10-year-old self. Jacob: 'How do I write about my past without sounding like a diary?' "
        "Panel 2: Professor Jennifer projecting a dual-hologram showing younger Jacob crying over a broken plate alongside older reflective Jacob analyzing the memory. Jennifer: 'Balance the experiencing self with the reflective narrator!' "
        "Panel 3: Jacob writing in a leather journal as warm light illuminates the page. Jacob: 'Personal truth turned into universal resonance!'"
    ),
    "chapter41_audio_dramas_comic.png": (
        "Panel 1: Jacob in a recording studio wearing large studio headphones, getting tongue-tied reading a visual novel paragraph aloud into a microphone. Jacob: 'This print prose trips up my tongue!' "
        "Panel 2: Professor Jennifer at an audio mixing console sliding up faders for ElevenLabs voice tracks and Meta Audiocraft sound effects. Jennifer: 'Write for the ear! Layer ambient audio tracks and SFX cues!' "
        "Panel 3: Waves of rich surround sound, thunder SFX, and clear dialogue fill the studio. Jacob: 'It sounds like a movie for the mind!'"
    ),
    "chapter42_conclusion_comic.png": (
        "Panel 1: Jacob standing on a mountain peak looking out at a horizon filled with books, film reels, game controllers, and AI spark icons. Jacob: 'We reached the end of the manuscript!' "
        "Panel 2: Professor Jennifer handing Jacob a glowing golden pen with a warm robotic smile. Jennifer: 'In AI-empowered writing, the finish line is just the next beginning.' "
        "Panel 3: Jacob and Jennifer walking together into the sunset toward a bright glowing doorway marked 'YOUR NEXT STORY'. Jacob: 'Time to start the series!'"
    )
}

def generate_comic(filename, prompt, api_key, out_dir="images", force=False):
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, filename)
    
    if not force and os.path.exists(out_path) and os.path.getsize(out_path) > 0:
        print(f"[SKIP] {out_path} already exists.")
        return True

    full_prompt = f"{DEFAULT_COMIC_PREFIX}{prompt}{DEFAULT_COMIC_SUFFIX}"
    client = genai.Client(api_key=api_key)
    
    # Prioritize Gemini 3.1 Flash Image and Imagen models
    models = ['gemini-3.1-flash-image', 'gemini-2.5-flash-image', 'imagen-3.0-generate-002']
    for model_name in models:
        try:
            print(f"[GENERATING] {filename} with model {model_name}...")
            response = client.models.generate_content(
                model=model_name,
                contents=full_prompt,
                config=types.GenerateContentConfig(
                    response_modalities=["IMAGE"]
                )
            )
            if response.candidates and response.candidates[0].content.parts:
                for part in response.candidates[0].content.parts:
                    if part.inline_data and part.inline_data.data:
                        with open(out_path, "wb") as f:
                            f.write(part.inline_data.data)
                        print(f"[SUCCESS] Saved {out_path} ({os.path.getsize(out_path)} bytes)")
                        return True
        except Exception as e:
            print(f"[WARNING] Model {model_name} failed for {filename}: {e}")
            continue

    print(f"[ERROR] Failed to generate {filename}")
    return False

def main():
    parser = argparse.ArgumentParser(description="Generate Part XI & Chapter comics using Gemini API")
    parser.add_argument("--api-key", "-k", required=True, help="Gemini API Key")
    parser.add_argument("--force", "-f", action="store_true", help="Force overwrite existing images")
    args = parser.parse_args()

    repo_dir = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    out_dir = os.path.join(repo_dir, "images")

    successes = 0
    total = len(PART_XI_COMICS)

    for filename, prompt in PART_XI_COMICS.items():
        if generate_comic(filename, prompt, api_key=args.api_key, out_dir=out_dir, force=args.force):
            successes += 1

    print(f"\n[DONE] Successfully generated {successes}/{total} comic images.")

if __name__ == "__main__":
    main()
