#!/usr/bin/env bash
set -euo pipefail

bundle exec jekyll build --config _config.yml >/tmp/homepage_smoke_test_jekyll.log 2>&1

grep -q 'page_class: home-immersive' index.html
! test -e _site/index.md
grep -q '<title>Vanishing Entropy</title>' _site/index.html
grep -q 'home-canvas' _site/index.html
grep -q 'portal-grid' _site/index.html
grep -q 'home-canvas' index.html
grep -q 'portal-grid' index.html
grep -q '<a class="post-portal" href="{{ post.url | prepend: site.baseurl }}" data-portal-index="{{ forloop.index0 }}">' index.html
! rg -U -q '<h2 class="post-portal__title">\s*<a href=' index.html
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
grep -q 'let animationProfile = null;' assets/js/homepage.js
grep -q 'function createAnimationProfile' assets/js/homepage.js
grep -q 'document.hidden' assets/js/homepage.js
grep -q 'if (!document.hidden) {' assets/js/homepage.js
grep -q 'drawFluid(time);' assets/js/homepage.js
! grep -q 'fluidFrameInterval:' assets/js/homepage.js
grep -q 'radius: 12 + speedBoost \* 0.35,' assets/js/homepage.js
grep -q '0.52,' assets/js/homepage.js
grep -q '1.4' assets/js/homepage.js
grep -q 'function emitWave(x, y, speedBoost, strength = 1, widthScale = 1) {' assets/js/homepage.js
grep -q 'width: (112 + speedBoost \* 2.4) \* widthScale,' assets/js/homepage.js
grep -q 'signal-hero__cluster' assets/js/homepage.js
grep -q 'function updateHeroCluster' assets/js/homepage.js
grep -q 'function updatePortalGrid' assets/js/homepage.js
grep -q 'portal-grid--revealed' assets/js/homepage.js
grep -q 'interactiveElements' assets/js/homepage.js
grep -q 'portalFieldLink' assets/js/homepage.js
grep -q 'function getPointerInfluence' assets/js/homepage.js
grep -q 'const portalDriftState = new WeakMap();' assets/js/homepage.js
grep -q 'const interactiveDriftState = new WeakMap();' assets/js/homepage.js
grep -q 'const portalDriftMaxSpeed = ' assets/js/homepage.js
grep -q 'const interactiveDriftMaxSpeed = ' assets/js/homepage.js
grep -q 'function clampDriftStep' assets/js/homepage.js
grep -q 'function stepDriftTowardsTarget' assets/js/homepage.js
grep -q 'const portalRects = new WeakMap();' assets/js/homepage.js
grep -q 'const interactiveRects = new WeakMap();' assets/js/homepage.js
grep -q 'let layoutDirty = true;' assets/js/homepage.js
grep -q 'function syncLayoutState' assets/js/homepage.js
grep -q 'window.addEventListener("scroll", () => {' assets/js/homepage.js
grep -q 'function updateInteractivePointerDrift' assets/js/homepage.js
grep -q 'function bindPortalFieldScroll' assets/js/homepage.js
grep -q 'root.addEventListener("pointerdown", (event) => {' assets/js/homepage.js
grep -q 'window.addEventListener("popstate"' assets/js/homepage.js
grep -q 'portalTop' assets/js/homepage.js
grep -q 'history.pushState' assets/js/homepage.js
grep -q 'window.scrollTo' assets/js/homepage.js
grep -q 'function emitSweepWave' assets/js/homepage.js
grep -q 'const bottomFadeStart = height \* 0.8;' assets/js/homepage.js
grep -q 'const bottomFadeRange = Math.max(height \* 0.2, 1);' assets/js/homepage.js
grep -q 'const bottomFade = square.y <= bottomFadeStart ? 1 : Math.max(0, 1 - (square.y - bottomFadeStart) / bottomFadeRange);' assets/js/homepage.js
grep -q 'strokeRect' assets/js/homepage.js
! grep -q 'portalGrid.style.opacity' assets/js/homepage.js
! grep -q 'const wakes = \[\];' assets/js/homepage.js
grep -q 'Return to home page' _layouts/post.html
grep -q 'padding: 0;' _sass/_immersive.scss
grep -q 'justify-content: flex-start;' _sass/_immersive.scss
grep -q 'background: transparent;' _sass/_immersive.scss
grep -q 'backdrop-filter: none;' _sass/_immersive.scss
grep -q 'width: fit-content;' _sass/_immersive.scss
grep -q 'border: 1px solid $signal-line-strong;' _sass/_immersive.scss
! rg -U -q '\.portal-grid \{[\s\S]*?opacity:' _sass/_immersive.scss
rg -U -q '\.portal-grid--revealed \.post-portal \{[\s\S]*?opacity: 1;' _sass/_immersive.scss
rg -U -q '\.post-portal \{[\s\S]*?opacity: 0\.28;' _sass/_immersive.scss
rg -U -q '\.post-portal:hover,\s*\.post-portal:focus,\s*\.post-portal:focus-visible,\s*\.post-portal:focus-within \{[\s\S]*?text-decoration: none;' _sass/_immersive.scss
grep -q 'opacity: 1;' _sass/_immersive.scss
! grep -q 'signal-post-rail' _layouts/post.html
grep -q 'grid-template-columns: minmax(0, 1fr);' _sass/_immersive.scss
! grep -q 'grid-template-columns: minmax(10rem, 14rem) minmax(0, 1fr);' _sass/_immersive.scss
grep -q 'background-color: transparent;' _sass/_base.scss
grep -q 'background: transparent;' _sass/_syntax-highlighting.scss
! rg -U -q '\.signal-post-content code,\s*\.signal-post-content pre \{[\s\S]*background:' _sass/_immersive.scss
! rg -U -q '\.signal-post-content code,\s*\.signal-post-content pre \{[\s\S]*border:' _sass/_immersive.scss
grep -q 'scrollbar-width: thin;' _sass/_base.scss
grep -q 'scrollbar-color:' _sass/_base.scss
grep -q '::-webkit-scrollbar' _sass/_base.scss
grep -q '::-webkit-scrollbar-thumb' _sass/_base.scss
