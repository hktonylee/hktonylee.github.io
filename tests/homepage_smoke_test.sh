#!/usr/bin/env bash
set -euo pipefail

grep -q 'page_class: home-immersive' index.html
grep -q 'home-canvas' index.html
grep -q 'portal-grid' index.html
grep -q 'fluid-canvas' index.html
grep -q 'Vanishing Entropy / hktonylee' index.html
! grep -q 'Signal Pool' index.html
! grep -q 'matrix-rain' index.html
grep -q 'Engineer building without limits' index.html
grep -q 'signal-hero__cluster' index.html
grep -q 'homepage.js' _includes/head.html
grep -q 'page.page_class == "home-immersive"' _includes/head.html
grep -q 'page-content--full-bleed' _layouts/default.html
grep -q 'const squares = \[\];' assets/js/homepage.js
grep -q 'const waves = \[\];' assets/js/homepage.js
grep -q 'const sweepWaves = \[\];' assets/js/homepage.js
grep -q 'signal-hero__cluster' assets/js/homepage.js
grep -q 'function updateHeroCluster' assets/js/homepage.js
grep -q 'function updatePortalGrid' assets/js/homepage.js
grep -q 'interactiveElements' assets/js/homepage.js
grep -q 'portalFieldLink' assets/js/homepage.js
grep -q 'function getPointerInfluence' assets/js/homepage.js
grep -q 'function updateInteractivePointerDrift' assets/js/homepage.js
grep -q 'function bindPortalFieldScroll' assets/js/homepage.js
grep -q 'scrollIntoView' assets/js/homepage.js
grep -q 'function emitSweepWave' assets/js/homepage.js
grep -q 'strokeRect' assets/js/homepage.js
! grep -q 'const wakes = \[\];' assets/js/homepage.js
