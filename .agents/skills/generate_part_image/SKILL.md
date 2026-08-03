---
name: generate_part_image
description: Generates a witty, full-color 3-panel overarching comic or illustrative image for a major book Part (e.g., Part I: Sentence Craft) encompassing all principles across its chapters, intermixing Sci-Fi, Fantasy, Thriller, and Romance tropes with mild comedic tension, saves it to the images/ directory, and embeds it into book.md.
---

# Part Image & Comic Generation Skill

Use this skill when tasked with inventing, generating, and embedding overarching comic illustrations or visual assets for a major **Part** section in `book.md` (e.g., Part I: Sentence Craft, Part II: Scene & Character, Part III: Story Architecture).

---

## Scope & Purpose

Unlike a chapter comic which focuses on a single chapter's principles, a **Part Comic** synthesizes the overarching theme and all key craft concepts taught across **all chapters within that Part**.

---

## Comic Theme & Genre Guidance: Intermixing Sci-Fi, Fantasy, Romance, & Thrillers

- **Tone:** Lighthearted, witty, comedic, and strictly **safe-for-work (SFW)**.
- **Genre Variety:** Intermix a diverse blend of fiction genres across Parts—including **Science Fiction, High Fantasy, Cyberpunk, Mystery Thriller, and Romance**.
- **Character Dynamic:** All Part comics feature Professor Jennifer (the sharp, analytical robot professor) and Jacob (the earnest 35-year-old student) engaging in epic, multi-genre writing challenges.
- **Genre Scenario Examples:**
  - **Fantasy:** Designing a magic system story bible, fighting wordy monsters with legendary swords.
  - **Sci-Fi / Cyberpunk:** Quantum warp navigation using 3-act beats, cybernetic mind-sync prompt engineering.
  - **Romance:** Over-dramatic weightlifting or blueprint planning with subtle academic chemistry.
  - **Mystery / Thriller:** Uncovering plot twists and evidence boards across multi-book series continuity.

---

## Characters & Visual Style Standard

- **Professor Jennifer:** Sleek android/robot female professor with silver/grey ponytail, wire-rimmed glasses, blazer, and subtle cybernetic facial/neck accents (use `Gemini_Generated_Image_s3r1los3r1los3r1.png` as the reference image in `ImagePaths`).
- **Jacob:** 35-year-old male student with medium-length curly brown hair and expressive facial expressions.
- **Art Style:** Full-color digital comic book style, crisp linework, vibrant coloring, clean panel dividers, clear legible speech bubbles.

---

## Step-by-Step Workflow

### Step 1: 2-Round Ideation & Premise Refinement
1. Review the title and all chapters included within the target Part in `book.md`.
2. **Round 1 (Brainstorming):** Draft 2 distinct genre-focused premises (mixing Sci-Fi, Fantasy, Romance, or Thrillers).
3. **Round 2 (Refinement):** Polish the chosen premise's 3-panel structure, visual punchlines, and character dialogue for maximum comedic effect before generating.

### Step 2: Craft Image Generation Prompt & Generate
1. Construct a detailed text prompt for `generate_image`:
   - Layout: Full-color horizontal 3-panel comic strip (Left, Middle, Right).
   - Reference Image: Always pass `Gemini_Generated_Image_s3r1los3r1los3r1.png` in `ImagePaths` to maintain visual consistency for Professor Jennifer.
   - Describe each panel's genre setting, character poses, sound effects, and exact speech bubble dialogue.
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
