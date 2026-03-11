# Homepage Redesign Design Doc

Date: 2026-03-11
Project: `hktonylee.github.io`
Topic: immersive homepage redesign and interactive blog format

## Summary

Redesign the homepage from a plain Jekyll post index into a full-screen immersive canvas that introduces a new form of blog. The homepage should feel like an explorable digital environment rather than a list of articles. Posts should appear as portals inside that environment, and each post should open into a full-screen interactive piece where text, visuals, and motion carry equal weight.

The overall direction is dark, thin-bordered, and artistically decorated. The visual system should feel technical and expressive at the same time, using restrained matrix-like motifs, scanlines, grid geometry, signal noise, and interface fragments. The tone should reflect the author's personality: always improving, learning, and harassing AI.

## Goals

- Replace the default chronological post-list homepage with an immersive front door.
- Establish a new blog format where each post is a multimedia interactive composition.
- Create a distinct visual identity that is dark, precise, and artistic rather than conventional personal-site minimalism.
- Surface the author's personality clearly in the hero copy and throughout the interface system.
- Keep the experience navigable and readable despite the experimental presentation.

## Non-Goals

- Rebuild the entire publishing system in this phase.
- Turn the homepage into an open-world or game-like experience that obscures navigation.
- Require every post to have a completely bespoke rendering engine.
- Optimize for a conventional blog-reader audience that expects plain text first.

## Design Direction

Working concept: `Signal Pool`

The homepage is a single immersive black-canvas environment. A fluid simulation forms the base layer, behaving more like moving ink, smoke, or magnetic liquid than bright liquid color. Above that sits a sparse but richly detailed spatial interface made of post portals, faint grids, code-rain accents, annotation markers, scanline haze, and thin framed surfaces.

The homepage should not read as a list. It should read as an explorable interface for ideas. Each post exists as an object in the scene with a visual identity, motion behavior, and media preview.

## Homepage Experience

### Structure

The homepage consists of three layers:

1. Background simulation layer
2. Interface and atmospheric decoration layer
3. Anchored identity and portal layer

The background simulation is always present and gives the page its living surface. The interface decoration layer provides structure and atmosphere without becoming literal UI clutter. The top layer contains the author identity, manifesto copy, and the interactive post portals.

### Hero

The first screen should communicate who the site belongs to and what kind of work lives there. The hero should introduce the author as someone who is always improving, learning, and harassing AI. The wording should feel sharp and self-aware, not throwaway or meme-heavy.

This hero copy should function more like a manifesto than a bio. It establishes that the site is a lab for evolving ideas, experiments, and essays.

### Post Portals

Each post appears as a portal embedded in the scene. Portals may look like dark terminals, monolithic frames, diagnostic windows, or floating slabs. They should have:

- Thin borders
- Minimal metadata
- A strong title treatment
- Small preview motion or image fragments
- Hover states that reveal additional signals or content hints

The portals should feel alive inside the fluid environment but remain legible and clickable.

### Navigation Behavior

Users should be able to explore the homepage through subtle scroll and pointer influence. Motion should suggest depth and responsiveness, but the page must remain understandable with standard scrolling and clicking. The experience should feel like navigating a curated exhibition, not mastering a control scheme.

Clicking a portal should transition directly into the full-screen post experience with continuity between homepage and post.

## Post Experience

Each post is a full-screen interactive composition. It is not a normal article template with effects layered on top. Writing, visuals, and motion are all first-class parts of the post.

### Core Principle

The reading experience must remain meaningful even if the user does not fully engage with optional interactions. Interaction should deepen the work, not become a prerequisite for basic comprehension.

### Post Structure Model

Posts should be assembled from reusable scene primitives rather than one rigid article template. Candidate primitives:

- Intro frame
- Text slab
- Media window
- Reactive background layer
- Annotation rail
- Quote interruption
- Transition frame
- Exit portal

This model keeps authoring flexible while preventing each post from becoming an engineering one-off.

### Reading Model

Scroll should remain the primary navigation mechanic. Additional behaviors such as hover, drag, click, or pointer-reactive motion can reveal secondary layers. This allows posts to feel exploratory while still being readable end-to-end.

### Multimedia Role

Posts can incorporate:

- Motion graphics
- Images
- Video fragments
- Layered typography
- Procedural visuals
- Reactive decorative systems

These elements should support narrative, mood, or argument. They should not exist only to show technical novelty.

## Visual Language

### Tone

The visual system should feel dark, precise, intelligent, and slightly abrasive in a controlled way. It should avoid looking like a standard portfolio, a generic hacker aesthetic, or a neon cyberpunk parody.

### Palette

- Near-black and charcoal as primary surfaces
- Cold gray for body typography
- Restrained green or cyan accents for signal states
- Rare bright highlights used as emphasis only

### Materials and Decoration

Decorative elements should feel infrastructural, not ornamental for their own sake. Candidate elements:

- Matrix-like code rain
- Faint grids
- Coordinate ticks
- Numeric annotations
- Scanlines
- Noise textures
- Waveform traces
- Ghosted panels
- Micro-labels and system marks

The rule is density with discipline. The interface can be rich, but each decorative artifact must feel intentional and compositional.

### Borders and Surfaces

Surfaces should use very thin borders and light separation rather than heavy card shadows. Frames should feel precise and engineered. This gives the site a sharper, more contemporary presence and supports the desired dark aesthetic.

## Motion and Fluid Simulation

### Homepage Fluid Layer

The homepage fluid effect is a structural feature, not just a background animation. It should create the sense that portals and typography sit above an active field. The motion should be elegant and slightly uncanny, with low-saturation contrast that does not compete with text.

### Motion Principles

- Motion should be continuous but calm at rest
- Interaction should create localized response
- Hover states should feel magnetic or signal-based rather than playful
- Transitions into posts should preserve visual continuity from the homepage

### Performance Boundaries

The fluid layer should be implemented using a performant GPU-friendly approach when possible. Lower-powered devices should receive a graceful fallback such as reduced simulation resolution or an animated texture approximation. The visual identity must survive without requiring full simulation fidelity on every device.

## Personality and Voice

The site should present the author as someone evolving in public through experiments, writing, and technical curiosity. The key personality markers are:

- Always improving
- Always learning
- Harassing AI until it becomes useful

This voice should appear in hero copy, microcopy, and post framing, but it should be used with discipline. The tone should feel confident, sharp, and authored rather than repetitive.

## Content Strategy

This redesign implies a shift from "posts as entries in a feed" to "posts as interactive exhibits." The homepage should prioritize curation and identity over chronology.

Implications:

- Recent posts may still exist, but not as the dominant homepage structure
- Each post should have a visual signature and media strategy
- Posts should be treated as compositions with narrative pacing, not just text files with metadata

## Technical Implications

The current site is a minimal Jekyll site with a default post-list homepage. This redesign will likely require:

- A custom homepage layout
- New CSS and JavaScript architecture for layered scenes
- A content model for post-level interactive modules
- A strategy for storing and loading media assets per post
- Progressive enhancement and fallbacks for less capable browsers/devices

The implementation should aim for a reusable system for interactive posts rather than fully bespoke code for every entry.

## Risks

- Over-indexing on atmosphere and losing readability
- Building a simulation-heavy homepage that performs poorly on modest hardware
- Creating a post format that is too expensive to author consistently
- Letting decorative motifs become visual noise

## Success Criteria

- The homepage no longer reads as a default blog index
- Visitors immediately understand the site as an interactive personal publishing space
- The visual identity feels distinct, dark, and intentional
- The homepage fluid simulation adds structure and mood rather than distraction
- Posts can support full-screen interactive storytelling with reusable building blocks
- The author's personality is clearly visible in the experience

## Recommended Next Step

Create an implementation plan that breaks this redesign into phases:

1. Homepage architecture and visual system
2. Fluid simulation integration and fallback behavior
3. Portal interaction model
4. Interactive post template system
5. Content migration strategy for existing posts
