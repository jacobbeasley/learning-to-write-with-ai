---
name: generate_part_image
description: Generates a witty, full-color 3-panel overarching comic or illustrative image for a major book Part (e.g., Part I: Sentence Craft) encompassing all principles across its chapters, loosely themed around silly SFW romance novel tropes with mild comedic tension between Professor Jennifer and Jacob, saves it to the images/ directory, and embeds it into book.md.
---

# Part Image & Comic Generation Skill

Use this skill when tasked with inventing, generating, and embedding overarching comic illustrations or visual assets for a major **Part** section in `book.md` (e.g., Part I: Sentence Craft, Part II: Scene & Character, Part III: Story Architecture).

---

## Scope & Purpose

Unlike a chapter comic which focuses on a single chapter's principles, a **Part Comic** synthesizes the overarching theme and all key craft concepts taught across **all chapters within that Part**.

- **Part I (Sentence Craft):** Synthesizes Sentence Music (Ch 1), Strong Verbs (Ch 2), and Economy of Language (Ch 3).
- **Part II (Scene & Character):** Synthesizes Dialogue, Subtext, Character Wants/Needs, and Scene Dynamics.
- **Part III (Story & Structure):** Synthesizes Outlining, Beat Sheets, Pacing, and Series Architecture.

---

## Comic Theme & Tone Guidance: Silly SFW Romance Tropes

- **Tone:** Lighthearted, witty, comedic, and strictly **safe-for-work (SFW)**.
- **Character Dynamic:** All Part comics should lean loosely into silly, melodramatic **romance novel tropes** featuring a **very mild, PG-rated, humorous tension** between Professor Jennifer (the sharp, analytical robot professor) and Jacob (the earnest 35-year-old student).
- **Trope Examples to Weave into Part Synthesis:**
  - Dramatic cover-art-style poses over glowing manuscripts or giant sentence blueprints.
  - Accidental hand-touches on a single pen while co-authoring a scene.
  - Jennifer analyzing Jacob's emotional romantic dialogue with cold robotic metrics while Jacob tries to play it cool.
  - Over-the-top romance genre melodrama used as the ongoing story element being edited across the Part.

---

## Characters & Visual Style Standard

- **Professor Jennifer:** Sleek android/robot female professor with silver/grey ponytail, wire-rimmed glasses, blazer, and subtle cybernetic facial/neck accents (use `Gemini_Generated_Image_s3r1los3r1los3r1.png` as the reference image in `ImagePaths`).
- **Jacob:** 35-year-old male student with medium-length curly brown hair and expressive facial expressions.
- **Art Style:** Full-color digital comic book style, crisp linework, vibrant coloring, clean panel dividers, clear legible speech bubbles.

---

## Step-by-Step Workflow

### Step 1: Analyze the Part & Pitch Premises
1. Review the title and all chapters included within the target Part in `book.md`.
2. Identify 3 distinct overarching craft themes (e.g., for Part I: rhythm, verb engine, wordiness trim).
3. Brainstorm 3 distinct, witty comic concepts that synthesize all chapters in the Part while blending in silly SFW romance tropes and mild comedic tension between Jennifer and Jacob.
4. Present the 3 premises clearly to the user with panel-by-panel breakdowns, visual gags, and character dialogue. **Do not generate images until the user selects or approves a premise.**

### Step 2: Craft Image Generation Prompt & Generate
1. Once the user selects a premise, construct a detailed text prompt for `generate_image`:
   - Layout: Full-color horizontal 3-panel comic strip (Left, Middle, Right).
   - Reference Image: Always pass `Gemini_Generated_Image_s3r1los3r1los3r1.png` in `ImagePaths` to maintain visual consistency for Professor Jennifer.
   - Describe each panel's setting, character poses, romantic trope visuals (dramatic lighting, blushes, sound effect text), and exact speech bubble dialogue.
2. Call `generate_image` with a descriptive `ImageName` (e.g. `part1_sentence_craft_comic`).

### Step 3: Save Image Asset to Repository
1. Copy the generated artifact image from the brain directory to the repository's local `images/` directory.
2. Naming convention: `images/part[N]_[topic]_comic.png` (e.g., `images/part1_sentence_craft_comic.png`).

### Step 4: Embed into `book.md`
1. Locate the `# Part [N]: [Title]` section header in `book.md`.
2. Insert the markdown image tag immediately following the Part's introductory tagline sentence (before the first chapter heading `## Chapter [X]`):
   ```markdown
   # Part I: Sentence Craft
   Before building a world, a writer must know how to build a sentence.

   ![Part I Comic: Sentence Craft](images/part1_sentence_craft_comic.png)

   ## Chapter 1: The Music of Prose
   ```
3. Verify the edit in `book.md` using `view_file`.
