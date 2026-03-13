# Homepage Drift Focus Pause Design

## Summary

Pause the homepage drift animation loop when the page is not focused, such as when the user switches to another tab or window. Resume the loop when focus returns.

This change should affect only the drift animation loop. It should not reset visual state, alter scroll-linked layout behavior, or change reduced-motion handling.

## Scope

- Pause the existing homepage animation frame loop when the page is inactive
- Resume the loop when the page becomes active again
- Preserve current transform state while paused
- Reset frame timing on resume to avoid velocity spikes

## Out of Scope

- Changing hero or portal reveal behavior
- Clearing transforms while inactive
- Refactoring the homepage animation system into multiple schedulers

## Recommended Approach

Use a small activity controller around the existing `requestAnimationFrame` loop in `assets/js/homepage.js`.

Add:

- an `isPageActive` flag
- a stored animation frame id
- `startAnimationLoop()` and `stopAnimationLoop()` helpers
- a `syncPageActivity()` function using `document.visibilityState` and `document.hasFocus()`

The frame function should only reschedule itself when the page is active. On resume, reset `lastFrameAt` before restarting so drift movement does not jump after time spent in a background tab.

## Behavior

- Homepage drift runs normally while the page is active
- If the tab becomes hidden or the window loses focus, the drift loop stops
- Existing transforms remain in place while paused
- When focus returns, the loop resumes smoothly from the current state
- Reduced-motion behavior remains unchanged

## Verification

1. Load the homepage and confirm the drift animation is active
2. Switch to another tab or another app window and confirm drift stops
3. Return to the page and confirm drift resumes without snapping
4. Confirm no errors appear in the console
5. Confirm `bundle exec jekyll build --drafts` still succeeds
