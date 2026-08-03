---
name: generate_chapter_image
description: Generates a witty, full-color 3-panel comic or illustrative image for a book chapter featuring Professor Jennifer (robot professor) and Jacob (student), intermixing Sci-Fi, Fantasy, Thriller, and Romance tropes with mild comedic tension, saves it to the images/ directory, and embeds it into book.md.
---

# Chapter Image & Comic Generation Skill

Use this skill when tasked with inventing, generating, and embedding chapter comic illustrations or visual assets into `book.md`.

---

## Comic Theme & Genre Guidance: Intermixing Sci-Fi, Fantasy, Romance, & Thrillers

- **Tone:** Lighthearted, witty, comedic, and strictly **safe-for-work (SFW)**.
- **Genre Variety:** Intermix a diverse blend of fiction genres across chapters—including **Science Fiction, High Fantasy, Cyberpunk, Mystery Thriller, and Romance**.
- **Character Dynamic:** All chapter comics feature Professor Jennifer (the sharp, analytical robot professor) and Jacob (the earnest 35-year-old student) engaging in high-stakes writing lessons across absurd genre scenarios.
- **Genre Scenario Examples:**
  - **Fantasy:** Casting magic spells that accidentally turn weak adverbs into fireballs, or taming dragons with proper sentence rhythm.
  - **Sci-Fi / Cyberpunk:** Hacking starship warp engines with strong action verbs, or calibrating quantum hyperdrives using dialogue subtext.
  - **Romance:** Over-dramatic eye contact across glowing holograms, accidental hand-touches on laser pens, melodramatic hero dialogues.
  - **Mystery / Thriller:** Interrogating suspects using deep POV immersion or defusing bombs with tight word economy.

---

## Characters & Visual Style Standard

- **Professor Jennifer:** Sleek android/robot female professor with silver/grey ponytail, wire-rimmed glasses, blazer, and subtle cybernetic/robotic facial and neck seams (use `Gemini_Generated_Image_s3r1los3r1los3r1.png` as the reference image in `ImagePaths`).
- **Jacob:** 35-year-old male student with medium-length curly brown hair and expressive facial expressions.
- **Art Style:** Full-color digital comic book style, crisp linework, vibrant coloring, clean panel dividers, clear legible speech bubbles.

---

## Step-by-Step Workflow

### Step 1: 2-Round Ideation & Premise Refinement
1. Read the target chapter in `book.md` to identify the core craft principles.
2. **Round 1 (Brainstorming):** Draft 2 distinct genre-focused premises (mixing Sci-Fi, Fantasy, Romance, or Thrillers).
3. **Round 2 (Refinement):** Polish the chosen premise's 3-panel structure, visual punchlines, and character dialogue for maximum comedic effect before generating.

### Step 2: Craft Image Generation Prompt & Generate
1. Construct a detailed text prompt for `generate_image`:
   - Layout: Full-color horizontal 3-panel comic strip (Left, Middle, Right).
   - Reference Image: Always include `Gemini_Generated_Image_s3r1los3r1los3r1.png` in `ImagePaths` to maintain visual consistency for Professor Jennifer.
   - Describe each panel's genre setting (starship bridge, wizard tower, noir interrogation room, romance ballroom), character poses, sound effects, and exact speech bubble dialogue.
2. Call `generate_image` with a descriptive `ImageName` (e.g. `chapter9_trusting_reader_comic`).

### Step 3: Save Image Asset to Repository
1. Copy the generated artifact image from the brain directory to the repository's local `images/` directory.
2. Naming convention: `images/chapter[N]_[topic]_comic.png` (e.g., `images/chapter9_trusting_reader_comic.png`).

### Step 4: Embed into `book.md`
1. Locate the chapter introduction paragraph in `book.md`.
2. Insert the standard markdown image tag immediately under the intro paragraph:
   ```markdown
   ![Chapter [N] Comic: [Title]](images/chapter[N]_[topic]_comic.png)
   ```
3. Verify the edit in `book.md` using `view_file`.
