# Loomiverse — Status
_Auto-updated by Status Brain on every push. Last change: Add Status Brain workflow to auto-generate this file._

**Status:** In progress  
**What it is:** An iOS app that generates AI-written interactive choose-your-own-adventure stories, audiobooks, and sleep stories personalized by character and genre.  
**Stack:** SwiftUI, CoreData, OpenAI API, Xcode.

## What works right now
- Character creation UI with traits and customization (CharacterCreationView.swift, CharacterTrait.swift)
- Story chapter generation via OpenAI API with continuity tracking using actual chapter content (BookModel.swift)
- CoreData persistence layer for Users, Books, Stories, StoryChapters, Characters, and Ownership relationships
- Multiple content view types: AudioBookContentView, BookContentView, AdventureOptionsView
- Genre selection with 10+ genres (Fantasy, Horror, Crime, Sci-Fi, Mystery Thriller, Romance, Western, Dystopian, Action, Young Adult)
- 41 pre-generated story images organized by size (small/medium/large) for visual themes
- Author style definitions in JSON format (AuthorStyles.json)
- Chapter-to-chapter continuity: stores generated chapters and uses them as context for next chapter generation
- Security: API keys removed from version control, using environment/local settings

## Recent changes (newest first)
- 2026-07-20 — Add Status Brain workflow (automated status reporting)
- 2026-07-20 — Add Status Brain script (generates this STATUS.md)
- 2026-01-29 — Add HQ task tracking setup with CLAUDE.md and tasks/ directory for project management
- 2025-12-21 — Organize project files and update story generation system
- 2025-05-23 — Fix chapter continuity: replaced outline points with actual chapter content; added generatedChapters array to persist written chapters
- 2025-05-20 — Add markdown files (documentation)
- 2025-05-20 — Update .gitignore to exclude .DS_Store files
- 2025-05-20 — Remove OpenAI API key from version control (security fix)

## Reusable parts (for other projects)
- **Chapter continuity system** — Stores actual generated chapter text instead of outlines, feeds previous chapters into next generation prompt to maintain narrative consistency — BookModel.swift
- **CoreData schema for story universes** — Reusable multi-entity data model for Users, Books, Stories, Characters, Chapters, and ownership relationships — Coredata Properties & DataClass/ directory
- **Responsive image asset system** — Three-size image sets (small/medium/large) for adaptive UI layouts — Loomiverse/Assets.xcassets/

## Not done / next
- **Audiobook playback not implemented** — AudioBookContentView.swift exists but no actual audio engine or text-to-speech integration
- **Sleep story feature not implemented** — UI mockups exist but no generation logic or player
- **Adventure branching not wired** — AdventureOptionsView.swift UI exists; no backend logic to parse choices and branch story generation
- **User authentication missing** — CoreData models exist but no login/signup flow
- **Search functionality not implemented** — Listed in mockups but no search controller or query logic
- **Favorite/bookmarking system** — UI references exist but no persistence or filtering
- **Profile/account settings** — Profile screen mockups exist but no editable user data view
- **Genre/discovery filtering** — Genre selection exists but no browse/discover pagination
- **Marketplace/token system** — Mentioned in mockups but no purchase flow or in-app economy
- **API integration tests** — No unit tests for OpenAI chapter generation or error handling
- **On-device story caching** — Generated stories not optimized for offline reading
- **Xcode project file** — No .pbxproj or project structure files in repo (may be in .gitignore)
