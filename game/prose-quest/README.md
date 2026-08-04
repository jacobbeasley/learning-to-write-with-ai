# Prose Quest 🎮✍️

**Prose Quest** is a locally-run interactive educational game built with **Godot 4.7**, designed to turn the book *"Learning to Write Novels with AI: From Sentence to Series"* into an engaging, learn-by-doing experience inspired by CodeCombat.

Players create writer profiles, navigate through 10 Parts and 35 Chapters of fiction writing craft, study craft principles with before-and-after examples, interact with an embedded AI chatbot coach (via **LM Studio** running locally), earn letter grades (A–F), and accumulate XP points.

---

## 🌟 Features

- **Profile System:** Create, select, and manage persistent writer profiles with custom names, avatar color selections, total XP tracking, confirmation dialog on deletion, and per-chapter grade histories.
- **Full Book Content (35 Chapters across 10 Parts):** Includes all lesson craft principles, before-and-after example passages, interactive AI activity instructions, and ready-to-run prompts.
- **Local AI Chatbot Integration (LM Studio / Gemma 3 1B):** Real-time interactive AI writing coach session inside the game screen. Communicates with LM Studio's OpenAI-compatible endpoint (`http://127.0.0.1:1234/v1/chat/completions`).
- **Deterministic AI Function / Tool Calling:** Uses OpenAI function calling (`gradeActivity(grade, feedback_summary)`) with regex fallback to capture letter grades programmatically.
- **Dynamic Points & Improvement Mechanics:**
  - Grade **A** = 1,000 XP
  - Grade **B** = 750 XP
  - Grade **C** = 500 XP
  - Grade **D** = 100 XP
  - Grade **F** = 0 XP
  - Retaking lessons and earning a higher grade awards the point difference (`+500 XP` on C → A improvement!).
- **Full-Color Comic Cutscenes:** Embedded 3-panel comic illustrations shown before entering each Part and Chapter.
- **Split-Screen Lesson Workspace:** Adjustable `HSplitContainer` displaying lesson principles on the left and the interactive AI chat on the right, complete with `Ctrl+Enter` send shortcut.
- **Dark Academia Aesthetic:** Rich UI theme (`#1a1a2e` navy/charcoal background, gold `#d4a574` and amber `#e8a849` accents, parchment text panels).

---

## 📁 System Architecture

```
game/prose-quest/
├── project.godot                     # Godot 4 Engine project file
├── README.md                         # Project documentation
├── assets/
│   ├── data/
│   │   └── book_content.json         # Extracted JSON containing all 10 Parts & 35 Chapters
│   └── images/
│       └── comics/                   # 47 full-color PNG comic illustrations
└── src/
    ├── autoload/
    │   ├── game_manager.gd           # Content registry, navigation router & scene transitions
    │   ├── save_manager.gd           # JSON profile management in user://profiles/ & settings
    │   └── ai_manager.gd             # HTTP client for LM Studio API, tool schema & grade parser
    ├── data/
    │   └── grade_utils.gd            # Grade ranking, point values & color mappings
    └── ui/
        ├── title_screen/             # Main menu screen
        ├── profile_select/           # Profile list, profile creation & delete confirmation modal
        ├── world_map/                # 10-Part overview map with chapter progress
        ├── chapter_list/             # Chapter selection screen per Part
        ├── comic_viewer/             # Full-screen comic illustration cutscenes
        ├── lesson_screen/            # Split-view craft materials & live AI chat panel
        ├── grade_popup/              # Evaluation result popup with XP gains & grade badges
        ├── settings/                 # LM Studio API URL config & connection test dialog
        └── components/
            ├── grade_badge.tscn      # Color-coded letter grade badge
            └── chat_bubble.tscn      # User (green) & AI (blue) message bubbles
```

---

## 🚀 Getting Started

### 1. Prerequisites

- **Godot Engine 4.x** (tested on Godot 4.7.1 GL Compatibility / Forward+).
- **LM Studio** (or Ollama / local OpenAI-compatible server).
- **Local Model:** Recommended model: `google/gemma-3-1b` (or any 3B–8B model loaded in LM Studio).

### 2. Setting Up LM Studio

1. Open **LM Studio**.
2. Search and download `google/gemma-3-1b` (or your preferred local LLM).
3. Go to the **Developer / Local Server** tab in LM Studio.
4. Select `google/gemma-3-1b` and click **Start Server**.
5. Note the Base URL (default: `http://127.0.0.1:1234`).

---

## 💻 How to Run the Game

### Running via Godot GUI
1. Open Godot Engine.
2. Click **Import** and select `game/prose-quest/project.godot`.
3. Click **Edit**, then press **F5** to run the game!

### Running via Command Line / PowerShell

```powershell
godot.exe --path "c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest"
```

---

## 🛠️ How to Compile / Export the Game

To build a standalone `.exe` binary for Windows:

### Via Godot GUI Editor
1. Open the project in Godot.
2. Go to **Project → Export...**
3. Select **Windows Desktop** (or click *Add...* → *Windows Desktop*).
4. Click **Export Project...**, choose an output folder (e.g. `build/ProseQuest.exe`), and click **Save**.

### Via Command Line (Headless Export)
Ensure you have a Windows export preset configured in `export_presets.cfg`, then run:

```powershell
godot.exe --headless --path "c:\Users\jacob\Projects\novel-writing-with-ai\game\prose-quest" --export-release "Windows Desktop" "build/ProseQuest.exe"
```

---

## 🔄 Updating Book Content

The game loads lesson materials from `assets/data/book_content.json`. If you edit `book.md` in the root repository, regenerate the game data by running the Python parser:

```bash
python scripts/parse_book.py
```

This updates `book_content.json` automatically while converting Markdown to Godot BBCode!

---

## ⚙️ Configuration & Data Storage

- **Profiles Path:** User save files are stored as JSON at `%APPDATA%\Godot\app_userdata\Prose Quest\profiles\`.
- **Settings Path:** Stored at `%APPDATA%\Godot\app_userdata\Prose Quest\settings.json`.
- **Custom LM Studio URL:** Can be changed in-game via the **Settings** menu at any time.
