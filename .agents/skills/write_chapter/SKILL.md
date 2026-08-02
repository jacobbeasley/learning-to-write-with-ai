---
name: write_chapter
description: Drafts a complete, publishable chapter for "Learning to Write Novels with AI" following the exact college professor persona, 3-part chapter structure, blockquoted examples, interactive AI activity, and strict grading prompt pattern established in Chapter 1.
---

# Chapter Writing Skill: "Learning to Write Novels with AI"

Use this skill when tasked with drafting or expanding any chapter outline in `book.md` into a full chapter. Persona and tone rules are defined in `.agents/AGENTS.md`—do not duplicate them here.

---

## Step 1: Draft the Chapter

Every chapter must follow this exact 3-part structure:

### Section 1: Chapter Principles & Examples

- Format the section header as `### 1. Principles of [Chapter Topic]` tailored specifically to the chapter's focus (e.g., `### 1. Principles of Verb Selection`, `### 1. Principles of World-Building Architecture`, `### 1. Principles of Three-Act Structure`).
- Open with a 1–2 sentence professor-voice hook grounding the concept in real fiction craft.
- Present 2–4 craft principles.
- Under each principle, write 2–3 concise sentences explaining the concept.
- Under each principle, provide exactly 3 examples formatted as shown below.

**Example formatting standard:**

```
##### Example 1: [Scenario Name]

**Original ([Flaw Label]):**
> [Flawed passage text]

**Corrected ([Fix Label]):**
> [Improved passage text]
```

**Rules for writing good examples:**
- Each example must use a distinct fictional scenario (different genre, character, or setting).
- The Original must clearly exhibit the specific flaw the principle teaches—not just generic "bad writing."
- The Corrected version must demonstrate the principle in action. The reader should be able to identify exactly which technique fixed the passage.
- Principles within the same chapter must teach genuinely different concepts. If the examples for two principles could be swapped without the reader noticing, the principles overlap too much.

### Section 2: Interactive AI Activity

- **Objective:** 1 sentence describing what the student will practice.
- **Instructions:** Follow this 6-step pattern, adapting the bracketed text to fit the chapter's exercise type:

```
1. Copy the **Sample Prompt** below.
2. Open your preferred AI platform (Gemini, ChatGPT, or Claude).
3. Paste the prompt into the chat. The AI will [present a challenge appropriate to this chapter].
4. [Write / Rewrite / Complete / Correct] your response applying the chapter's principles, then submit it.
5. Work with your AI coach to refine your work until you earn a grade of **B** or higher.
6. Want more practice? Reply to the AI with *"Generate another [exercise type]"* to take on a fresh challenge.
```

**Activity types by chapter topic:**
- **Prose mechanics chapters (e.g., sentence length, verbs, economy):** AI generates a flawed passage → student rewrites → AI grades the rewrite.
- **Character/story design chapters (e.g., ghost & lie, antagonist, wants vs. needs):** AI presents a flat or flawed character element → student writes or rewrites to add depth → AI grades the craft.
- **Planning/structural chapters (e.g., outlining, story bible, beat sheets):** AI presents a scenario or incomplete framework → student fills in or corrects the structure → AI grades completeness and logic.
- **AI collaboration chapters (e.g., prompt engineering, ethics):** AI presents a challenge scenario → student crafts a response (prompt, workflow, ethical judgment) → AI evaluates effectiveness. In these cases, the student is meant to craft something real with the help of the AI. 
- **Publishing chapters (e.g., blurbs, feedback synthesis):** AI presents raw material → student writes or refines a deliverable (blurb, critique synthesis) → AI grades quality.

The key constant: **the student must always produce written work that the AI then evaluates with the grading rubric.**

### Section 3: Sample Prompt

- Open with: `Paste this prompt into the AI Chatbot of your choice (Gemini, ChatGPT, or Claude) to begin the exercise. Challenge yourself to get at least a B grade before proceeding to the next chapter.`
- The prompt must follow this 2-step structure inside a fenced `text` code block:

**Step 1** instructs the AI to present the exercise. Rules:
- The challenge must directly target the chapter's specific principles.
- For prose chapters: generate a flawed passage with flaws matching the chapter's principles.
- For non-prose chapters: present a scenario, incomplete framework, or challenge that requires the student to apply the chapter's concepts.
- Specify scope (e.g., passage length, number of characters, framework type).
- Include: "Do not provide any hints, analysis, or suggestions. Stop and wait for my reply."

**Step 2** instructs the AI to grade the student's submission. Rules:
- The grading criteria must map 1:1 to the chapter's principles. If the chapter teaches 2 principles, the prompt lists 2 matching criteria (plus 1 overall execution criterion).
- For each criterion, the AI must quote or reference specific parts of the student's submission to support its evaluation.
- Must assign a letter grade (A–F) with coaching feedback.
- Must enforce a B-minimum threshold: below B requires a revision; B or higher congratulates and offers "Generate another [type]" for repeat practice.
- Must include: `Be appropriately strict as if this is a masters-level creative writing course at a major university.`

---

## Step 2: Self-Review Quality Check

After drafting the chapter, review it against this checklist before presenting to the user. Fix any failures silently.

### Content Quality
- [ ] **Succinct prose:** Every sentence in the chapter earns its place. No filler, no restating what was just said, no padding.
- [ ] **Principle distinctness:** Each principle teaches a genuinely different concept. Examples for Principle 1 could NOT be swapped into Principle 2 without feeling wrong.
- [ ] **Example accuracy:** Every Original passage clearly exhibits the specific flaw named in the label. Every Corrected passage clearly demonstrates the fix.
- [ ] **Example variety:** Examples use different genres, characters, and settings—not three variations of the same scene.

### Structure & Formatting
- [ ] Exactly 2–4 principles per chapter.
- [ ] Exactly 3 distinct examples per principle.
- [ ] All examples use `##### Example X` headers, bold **Original/Corrected** labels, and blockquoted text (`>`).
- [ ] Objective + 6-step instructions present in Section 2.
- [ ] Section 3 prompt is inside a fenced `text` code block.

### Prompt Completeness
- [ ] Step 1 presents a challenge that directly targets the chapter's principles (not generic or off-topic).
- [ ] Step 1 includes "Do not provide any hints" and "Stop and wait for my reply."
- [ ] Step 2 grading criteria map 1:1 to the chapter's principles.
- [ ] Step 2 requires quoting/referencing specific parts of the student's submission.
- [ ] Letter grading (A–F) with masters-level strictness is specified.
- [ ] B-minimum threshold with revision loop is enforced.
- [ ] "Generate another" repeat practice option is included.
- [ ] No broken markdown, no orphaned links, no citation tags.

