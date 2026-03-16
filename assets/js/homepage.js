(() => {
  const root = document.querySelector(".home-canvas");
  const canvas = document.getElementById("fluid-canvas");
  const heroCluster = document.querySelector(".signal-hero__cluster");
  const portalGrid = document.querySelector(".portal-grid");
  const portalFieldLink = document.querySelector('a[href="#portal-grid"]');
  const interactiveElements = Array.from(
    document.querySelectorAll(".home-canvas a[href], .home-canvas button, .home-canvas [role='button']")
  ).filter(
    (element) => !element.closest(".post-portal")
  );

  if (!root || !canvas) {
    return;
  }

  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const ctx = canvas.getContext("2d");
  const squares = [];
  const waves = [];
  const sweepWaves = [];
  let animationProfile = null;
  const portalRects = new WeakMap();
  const interactiveRects = new WeakMap();
  const portalDriftState = new WeakMap();
  const interactiveDriftState = new WeakMap();
  const portalDriftMaxSpeed = 240;
  const interactiveDriftMaxSpeed = 180;
  const pointer = {
    x: window.innerWidth * 0.5,
    y: window.innerHeight * 0.3,
    active: false,
    lastWaveAt: 0
  };
  let lastAmbientWaveAt = 0;
  let lastSweepWaveAt = 0;
  let lastFrameAt = 0;
  let layoutDirty = true;
  let animationFrameId = 0;
  let isPageActive = !document.hidden && document.hasFocus();
  const portals = Array.from(document.querySelectorAll(".post-portal"));

  function createAnimationProfile(width, height) {
    const area = width * height;
    const dpr = window.devicePixelRatio || 1;
    const largeViewport = area >= 1600000;
    const ratioCap = largeViewport ? 1.1 : area >= 1000000 ? 1.35 : 1.6;
    const ratio = Math.min(dpr, ratioCap);
    const step = Math.max(18, Math.min(36, Math.round(width / 34 + area / 360000)));

    return {
      ratio,
      step
    };
  }

  function resize() {
    const width = window.innerWidth;
    const height = window.innerHeight;
    animationProfile = createAnimationProfile(width, height);
    const { ratio, step } = animationProfile;
    canvas.width = Math.floor(window.innerWidth * ratio);
    canvas.height = Math.floor(window.innerHeight * ratio);
    canvas.style.width = `${window.innerWidth}px`;
    canvas.style.height = `${window.innerHeight}px`;
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    squares.length = 0;
    const offset = step * 0.5;

    for (let y = offset; y < height + step; y += step) {
      for (let x = offset; x < width + step; x += step) {
        const dormantFactor = Math.random() > 0.72 ? 0.22 : 1;

        squares.push({
          x,
          y,
          baseSize: 5,
          seed: Math.random() * Math.PI * 2,
          speed: 0.12 + Math.random() * 0.22,
          opacitySeed: Math.random() * Math.PI * 2,
          opacitySpeed: 0.314 + Math.random() * 0.314,
          hue: 92 + Math.random() * 22,
          alpha: (0.08 + Math.random() * 0.08) * dormantFactor,
          strokeAlpha: (0.12 + Math.random() * 0.15) * (0.4 + dormantFactor * 0.6)
        });
      }
    }

    layoutDirty = true;
  }

  function drawFluid(time) {
    const width = window.innerWidth;
    const height = window.innerHeight;
    const bottomFadeStart = height * 0.8;
    const bottomFadeRange = Math.max(height * 0.2, 1);

    ctx.clearRect(0, 0, width, height);
    ctx.fillStyle = "rgba(5, 8, 8, 0.18)";
    ctx.fillRect(0, 0, width, height);
    ctx.globalCompositeOperation = "lighter";

    for (let index = waves.length - 1; index >= 0; index -= 1) {
      const wave = waves[index];
      wave.radius += wave.speed;
      wave.life -= 0.0025;

      if (wave.life <= 0) {
        waves.splice(index, 1);
      }
    }

    for (let index = sweepWaves.length - 1; index >= 0; index -= 1) {
      const sweepWave = sweepWaves[index];
      sweepWave.y += sweepWave.speed;
      sweepWave.life -= sweepWave.decay;

      if (sweepWave.life <= 0 || sweepWave.y - sweepWave.width > height) {
        sweepWaves.splice(index, 1);
      }
    }

    squares.forEach((square) => {
      const pulse = (Math.sin(time * square.speed + square.seed) + 1) * 0.5;
      const driftPulse = (Math.sin(time * 0.12 + square.seed * 1.7) + 1) * 0.5;
      const opacityLoop = (Math.sin(time * square.opacitySpeed + square.opacitySeed) + 1) * 0.5;
      let waveInfluence = 0;
      let sweepInfluence = 0;

      waves.forEach((wave) => {
        const band = Math.max(16, wave.width);
        const maxDistance = wave.radius + band;
        const minDistance = Math.max(0, wave.radius - band);
        const deltaX = square.x - wave.x;
        const deltaY = square.y - wave.y;
        const distanceSquared = deltaX * deltaX + deltaY * deltaY;

        if (distanceSquared > maxDistance * maxDistance || distanceSquared < minDistance * minDistance) {
          return;
        }

        const distance = Math.sqrt(distanceSquared);
        const edgeDistance = Math.abs(distance - wave.radius);
        const bandInfluence = Math.max(0, 1 - edgeDistance / band) * wave.life * wave.strength;
        waveInfluence = Math.max(waveInfluence, bandInfluence);
      });

      sweepWaves.forEach((sweepWave) => {
        const bandDistance = Math.abs(square.y - sweepWave.y);
        const bandInfluence = Math.max(0, 1 - bandDistance / sweepWave.width) * sweepWave.life * sweepWave.strength;
        sweepInfluence = Math.max(sweepInfluence, bandInfluence);
      });

      const totalInfluence = Math.max(waveInfluence, sweepInfluence);
      const bottomFade = square.y <= bottomFadeStart ? 1 : Math.max(0, 1 - (square.y - bottomFadeStart) / bottomFadeRange);

      const size = square.baseSize * (1 + totalInfluence * 0.9);
      const fillOpacity = (square.alpha * (0.03 + opacityLoop * 0.18) + pulse * 0.012 + totalInfluence * 0.12) * bottomFade;
      const strokeOpacity = (square.strokeAlpha * (0.42 + opacityLoop * 1.1) + pulse * 0.028 + driftPulse * 0.02 + totalInfluence * 0.26) * bottomFade;
      const hue = square.hue + opacityLoop * 4 + pulse * 2 + totalInfluence * 10;
      const lightness = 46 + opacityLoop * 10 + pulse * 4 + driftPulse * 2 + totalInfluence * 12;

      ctx.fillStyle = `hsla(${hue}, 24%, ${lightness}%, ${Math.min(fillOpacity, 0.18)})`;
      ctx.fillRect(square.x - size * 0.5, square.y - size * 0.5, size, size);
      ctx.lineWidth = 0.6;
      ctx.strokeStyle = `hsla(${hue}, 34%, ${lightness + 8}%, ${Math.min(strokeOpacity, 0.5)})`;
      ctx.strokeRect(square.x - size * 0.5, square.y - size * 0.5, size, size);
    });

    ctx.globalCompositeOperation = "source-over";
    ctx.strokeStyle = "rgba(194, 235, 190, 0.04)";
    ctx.lineWidth = 1;

    for (let row = 0; row < height; row += 72) {
      ctx.beginPath();
      ctx.moveTo(0, row);
      ctx.lineTo(width, row);
      ctx.stroke();
    }
  }

  function getPointerInfluence(rect, maxOffset, activationPadding = 20) {
    if (!pointer.active) {
      return { x: 0, y: 0 };
    }

    const centerX = rect.left + rect.width * 0.5;
    const centerY = rect.top + rect.height * 0.5;
    const deltaX = pointer.x - centerX;
    const deltaY = pointer.y - centerY;
    const distance = Math.hypot(deltaX, deltaY) || 1;
    const outsideX = Math.max(rect.left - pointer.x, 0, pointer.x - rect.right);
    const outsideY = Math.max(rect.top - pointer.y, 0, pointer.y - rect.bottom);
    const borderDistance = Math.hypot(outsideX, outsideY);

    if (borderDistance > activationPadding) {
      return { x: 0, y: 0 };
    }

    const strength = 1 - borderDistance / activationPadding;

    return {
      x: (deltaX / distance) * maxOffset * strength,
      y: (deltaY / distance) * maxOffset * strength
    };
  }

  function clampDriftStep(current, target, maxDelta) {
    const delta = target - current;

    if (Math.abs(delta) <= maxDelta) {
      return target;
    }

    return current + Math.sign(delta) * maxDelta;
  }

  function stepDriftTowardsTarget(stateMap, element, target, maxSpeed, deltaSeconds) {
    const current = stateMap.get(element) || { x: 0, y: 0 };
    const maxDelta = maxSpeed * deltaSeconds;
    const next = {
      x: clampDriftStep(current.x, target.x, maxDelta),
      y: clampDriftStep(current.y, target.y, maxDelta)
    };

    stateMap.set(element, next);

    return next;
  }

  function updatePortals(time, deltaSeconds) {
    portals.forEach((portal, index) => {
      const portalRect = portalRects.get(portal);
      const influence = getPointerInfluence(portalRect || portal.getBoundingClientRect(), 7, 20);
      const ambientY = Math.sin(time + index * 0.7) * 1.25;
      const drift = stepDriftTowardsTarget(
        portalDriftState,
        portal,
        { x: influence.x, y: influence.y + ambientY },
        portalDriftMaxSpeed,
        deltaSeconds
      );
      portal.style.transform = `translate3d(${drift.x.toFixed(2)}px, ${drift.y.toFixed(2)}px, 0)`;
    });
  }

  function updateHeroCluster() {
    if (!heroCluster) {
      return;
    }

    const heroRect = interactiveRects.get(heroCluster) || heroCluster.getBoundingClientRect();
    const viewportHeight = window.innerHeight || 1;
    const startOffset = viewportHeight * 0.08;
    const distance = viewportHeight * 0.58;
    const rawProgress = (-heroRect.top - startOffset) / distance;
    const progress = Math.max(0, Math.min(rawProgress, 1));
    const eased = 1 - Math.pow(1 - progress, 3);
    const opacity = 1 - eased * 0.94;
    const yOffset = eased * -42;
    const scale = 1 - eased * 0.02;

    heroCluster.style.opacity = opacity.toFixed(3);
    heroCluster.style.transform = `translate3d(0, ${yOffset.toFixed(2)}px, 0) scale(${scale.toFixed(4)})`;
  }

  function updatePortalGrid() {
    if (!portalGrid) {
      return;
    }

    const viewportHeight = window.innerHeight || 1;
    const startOffset = viewportHeight * 0.08;
    const distance = viewportHeight * 0.58;
    const rawProgress = (window.scrollY - startOffset) / distance;
    const progress = Math.max(0, Math.min(rawProgress, 1));
    const eased = 1 - Math.pow(1 - progress, 3);
    const yOffset = (1 - eased) * 22;

    portalGrid.classList.toggle("portal-grid--revealed", progress >= 0.14);
    portalGrid.style.transform = `translate3d(0, ${yOffset.toFixed(2)}px, 0)`;
  }

  function updateInteractivePointerDrift(deltaSeconds) {
    interactiveElements.forEach((element) => {
      const interactiveRect = interactiveRects.get(element);
      const influence = getPointerInfluence(interactiveRect || element.getBoundingClientRect(), 3, 20);
      const drift = stepDriftTowardsTarget(
        interactiveDriftState,
        element,
        influence,
        interactiveDriftMaxSpeed,
        deltaSeconds
      );
      element.style.setProperty("--signal-pointer-x", `${drift.x.toFixed(2)}px`);
      element.style.setProperty("--signal-pointer-y", `${drift.y.toFixed(2)}px`);
    });
  }

  function syncLayoutState() {
    portals.forEach((portal) => {
      portalRects.set(portal, portal.getBoundingClientRect());
    });

    interactiveElements.forEach((element) => {
      interactiveRects.set(element, element.getBoundingClientRect());
    });

    if (heroCluster) {
      interactiveRects.set(heroCluster, heroCluster.getBoundingClientRect());
    }

    updateHeroCluster();
    updatePortalGrid();
    layoutDirty = false;
  }

  function bindPortalFieldScroll() {
    if (!portalFieldLink || !portalGrid) {
      return;
    }

    function scrollToPortalGrid() {
      const portalTop = window.scrollY + portalGrid.getBoundingClientRect().top - 60;

      window.scrollTo({
        top: Math.max(portalTop, 0),
        behavior: reducedMotion ? "auto" : "smooth"
      });
    }

    function syncScrollWithHistory() {
      if (window.location.hash === "#portal-grid") {
        scrollToPortalGrid();
        return;
      }

      window.scrollTo({
        top: 0,
        behavior: reducedMotion ? "auto" : "smooth"
      });
    }

    portalFieldLink.addEventListener("click", (event) => {
      event.preventDefault();
      const nextHash = "#portal-grid";

      if (window.location.hash !== nextHash) {
        window.history.pushState(null, "", nextHash);
      }

      scrollToPortalGrid();
    });

    window.addEventListener("popstate", syncScrollWithHistory);
  }

  function stopAnimationLoop() {
    if (!animationFrameId) {
      return;
    }

    window.cancelAnimationFrame(animationFrameId);
    animationFrameId = 0;
  }

  function startAnimationLoop() {
    if (animationFrameId || !isPageActive) {
      return;
    }

    lastFrameAt = 0;
    animationFrameId = window.requestAnimationFrame(frame);
  }

  function frame(now) {
    animationFrameId = 0;
    const time = now * 0.00018;
    const deltaSeconds = lastFrameAt ? Math.min((now - lastFrameAt) / 1000, 0.05) : 1 / 60;
    lastFrameAt = now;

    if (layoutDirty) {
      syncLayoutState();
    }

    if (now - lastAmbientWaveAt > 500 + Math.random() * 1500) {
      emitWave(
        Math.random() * window.innerWidth,
        Math.random() * window.innerHeight,
        5.0 + Math.random() * 3.0,
        0.52,
        1.4
      );
      lastAmbientWaveAt = now;
    }

    if (now - lastSweepWaveAt > 10000 + Math.random() * 5000) {
      emitSweepWave(0.76 + Math.random() * 0.18);
      lastSweepWaveAt = now;
    }

    if (!document.hidden) {
      drawFluid(time);
    }
    updateInteractivePointerDrift(deltaSeconds);
    updatePortals(time, deltaSeconds);

    if (isPageActive) {
      animationFrameId = window.requestAnimationFrame(frame);
    }
  }

  function syncPageActivity() {
    isPageActive = !document.hidden && document.hasFocus();

    if (isPageActive) {
      startAnimationLoop();
      return;
    }

    stopAnimationLoop();
  }

  resize();
  updateHeroCluster();
  updatePortalGrid();

  if (reducedMotion) {
    drawFluid(0);
    return;
  }

  interactiveElements.forEach((element) => {
    element.classList.add("signal-interactive");
  });

  updateInteractivePointerDrift();
  bindPortalFieldScroll();

  function emitWave(x, y, speedBoost, strength = 1, widthScale = 1) {
    waves.push({
      x,
      y,
      radius: 12 + speedBoost * 0.35,
      speed: (4 + speedBoost * 0.45) * (0.85 + strength * 0.15),
      width: (112 + speedBoost * 2.4) * widthScale,
      life: 0.55 + strength * 0.45,
      strength
    });

    if (waves.length > 6) {
      waves.shift();
    }
  }

  function emitSweepWave(strength = 0.82) {
    sweepWaves.push({
      y: -220,
      speed: 5.2,
      width: 340,
      life: 1,
      decay: 0.0024,
      strength
    });

    if (sweepWaves.length > 2) {
      sweepWaves.shift();
    }
  }

  root.addEventListener("pointermove", (event) => {
    const distance = Math.hypot(event.clientX - pointer.x, event.clientY - pointer.y);
    const now = performance.now();
    const sinceLastWave = now - pointer.lastWaveAt;
    pointer.x = event.clientX;
    pointer.y = event.clientY;
    pointer.active = true;

    if (sinceLastWave > 700 || (distance > 4 && sinceLastWave > 1000)) {
      emitWave(event.clientX, event.clientY, Math.min(distance * 0.28, 12));
      pointer.lastWaveAt = now;
    }
  });

  root.addEventListener("pointerdown", (event) => {
    emitWave(event.clientX, event.clientY, 7.5, 0.74, 1.2);
    pointer.lastWaveAt = performance.now();
  });

  root.addEventListener("pointerleave", () => {
    pointer.active = false;
  });

  document.addEventListener("visibilitychange", syncPageActivity);
  window.addEventListener("focus", syncPageActivity);
  window.addEventListener("blur", syncPageActivity);
  window.addEventListener("resize", resize);
  window.addEventListener("scroll", () => {
    layoutDirty = true;
  }, { passive: true });
  startAnimationLoop();
})();
