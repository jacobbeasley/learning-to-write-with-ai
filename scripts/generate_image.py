import os, sys, argparse, subprocess
from google import genai
from google.genai import types

DEFAULT_PREFIX = "A full-bleed 1:1 square 8-bit retro pixel art RPG UI avatar portrait with a rustic brown carved wood frame extending flush to the outer edges of the image. Isometric 3/4 view portrait of "
DEFAULT_SUFFIX = ", dark fantasy RPG UI icon style, rustic dark wood carved frame, 16-color palette, sharp crisp pixels, full-bleed borderless framing, centered composition, no text, no outer margin."

def generate_image(prompt, out_path, api_key=None, prefix=DEFAULT_PREFIX, suffix=DEFAULT_SUFFIX, force=False, clean_png=True):
    out_dir = os.path.dirname(os.path.abspath(out_path))
    if out_dir:
        os.makedirs(out_dir, exist_ok=True)
        
    if not force and os.path.exists(out_path) and os.path.getsize(out_path) > 0:
        print(f"[SKIP] {out_path} already exists.")
        return True
        
    if not api_key:
        api_key = os.environ.get("GEMINI_API_KEY", "").strip()
        
    if not api_key:
        print("[ERROR] No API key provided. Pass --api-key or set GEMINI_API_KEY env var.")
        return False
        
    full_prompt = f"{prefix}{prompt}{suffix}"
    client = genai.Client(api_key=api_key)
    
    models = ['gemini-3.1-flash-image', 'gemini-2.5-flash-image']
    for model_name in models:
        try:
            response = client.models.generate_content(
                model=model_name,
                contents=full_prompt,
                config=types.GenerateContentConfig(response_modalities=["IMAGE"])
            )
            if response.candidates and response.candidates[0].content.parts:
                for part in response.candidates[0].content.parts:
                    if part.inline_data and part.inline_data.data:
                        with open(out_path, "wb") as f:
                            f.write(part.inline_data.data)
                        print(f"[SUCCESS] Generated {out_path} using {model_name}")
                        
                        # Clean PNG metadata
                        if clean_png:
                            ps_script = os.path.join(os.path.dirname(__file__), "clean_pngs.ps1")
                            if os.path.exists(ps_script):
                                subprocess.run(["powershell", "-ExecutionPolicy", "Bypass", "-File", ps_script])
                        return True
        except Exception as e:
            print(f"[DEBUG] Model {model_name} failed: {e}")
            continue
            
    print(f"[ERROR] Failed to generate image for {out_path}")
    return False

def main():
    parser = argparse.ArgumentParser(description="Generic Image Generator CLI using Gemini API")
    parser.add_argument("--prompt", "-p", required=True, help="Image description prompt")
    parser.add_argument("--out", "-o", required=True, help="Output destination file path (.png)")
    parser.add_argument("--api-key", "-k", help="Gemini API Key")
    parser.add_argument("--prefix", default=DEFAULT_PREFIX, help="Custom prompt prefix")
    parser.add_argument("--suffix", default=DEFAULT_SUFFIX, help="Custom prompt suffix")
    parser.add_argument("--force", "-f", action="store_true", help="Force overwrite existing file")
    
    args = parser.parse_args()
    success = generate_image(args.prompt, args.out, api_key=args.api_key, prefix=args.prefix, suffix=args.suffix, force=args.force)
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
