---
name: generate_chapter_image
description: Generates a witty, full-color 3-panel comic or illustrative image for a book chapter featuring Professor Jennifer (robot professor) and Jacob (student), loosely themed around silly SFW romance novel tropes with mild comedic tension, saves it to the images/ directory, and embeds it into book.md.
---

# Chapter Image & Comic Generation Skill

Use this skill when tasked with inventing, generating, and embedding chapter comic illustrations or visual assets into `book.md`.

---

## Comic Theme & Tone Guidance: Silly SFW Romance Tropes

- **Tone:** Lighthearted, witty, comedic, and strictly **safe-for-work (SFW)**.
- **Character Dynamic:** All chapter comics should lean loosely into silly, melodramatic **romance novel tropes** featuring a **very mild, PG-rated, humorous tension** between Professor Jennifer (the sharp, analytical robot professor) and Jacob (the earnest 35-year-old student).
- **Trope Examples to Weave into Writing Lessons:**
  - Over-dramatic eye contact across a desk while evaluating a manuscript draft.
  - Accidental hand-touches while pointing out a bad adverb on a paper.
  - Jennifer diagnosing romantic prose with hyper-precise robotic audio/visual analytics while Jacob blushes.
  - Melodramatic romance passages used as the sample text being edited (e.g., *"Lord Sterling gazed into her eyes... and snarled at her weak verbs"*).
  - Playful "strict professor x eager student" or "enemies-to-co-authors" dynamics played purely for comedic effect.

---

## Characters & Visual Style Standard

- **Professor Jennifer:** Sleek android/robot female professor with silver/grey ponytail, wire-rimmed glasses, blazer, and subtle cybernetic/robotic facial and neck seams (use `Gemini_Generated_Image_s3r1los3r1los3r1.png` as the reference image in `ImagePaths`).
- **Jacob:** 35-year-old male student with medium-length curly brown hair and expressive facial expressions.
- **Art Style:** Full-color digital comic book style, crisp linework, vibrant coloring, clean panel dividers, clear legible speech bubbles.

---

## Step-by-Step Workflow

### Step 1: Pitch Premises to the User
1. Read the target chapter in `book.md` to identify the core craft principles (e.g., sentence pacing, read-aloud test, strong verbs, show don't tell).
2. Brainstorm 3 distinct, witty comic concepts that combine the chapter's craft principles with silly SFW romance tropes and mild comedic tension between Jennifer and Jacob.
3. Present the options clearly to the user with panel-by-panel descriptions, visual gags, and character dialogue. **Do not generate images until the user selects or approves a concept.**

### Step 2: Craft Image Generation Prompt & Generate
1. Once the user approves a premise, construct a detailed text prompt for `generate_image`:
   - Layout: Full-color horizontal 3-panel comic strip (Left, Middle, Right).
   - Reference Image: Always include `Gemini_Generated_Image_s3r1los3r1los3r1.png` in `ImagePaths` to maintain visual consistency for Professor Jennifer.
   - Describe each panel's setting, character poses, romantic trope visuals (glowing eyes, dramatic blushes, sound effect text), and exact speech bubble dialogue.
2. Call `generate_image` with a descriptive `ImageName` (e.g. `chapter1_music_of_prose_comic`).

### Step 3: Save Image Asset to Repository
1. Copy the generated artifact image from the brain directory to the repository's local `images/` directory.
2. Naming convention: `images/chapter[N]_[topic]_comic.png` (e.g., `images/chapter1_music_of_prose_comic.png`).

### Step 4: Embed into `book.md`
1. Locate the `IMAGE_HERE` placeholder in the target chapter (or place immediately following the chapter's introductory paragraph).
2. Replace `IMAGE_HERE` with the standard markdown image tag:
   ```markdown
   ![Chapter [N] Comic: [Title]](images/chapter[N]_[topic]_comic.png)
   ```
3. Verify the edit in `book.md` using `view_file`.
