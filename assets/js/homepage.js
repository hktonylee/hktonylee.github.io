(() => {
  const root = document.querySelector(".home-canvas");
  const canvas = document.getElementById("fluid-canvas");

  if (!root || !canvas) {
    return;
  }

  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  const ctx = canvas.getContext("2d");
  const squares = [];
  const waves = [];
  const sweepWaves = [];
  const pointer = {
    x: window.innerWidth * 0.5,
    y: window.innerHeight * 0.3,
    active: false,
    lastWaveAt: 0
  };
  let lastAmbientWaveAt = 0;
  let lastSweepWaveAt = 0;
  const portals = Array.from(document.querySelectorAll(".post-portal"));

  function resize() {
    const ratio = Math.min(window.devicePixelRatio || 1, 2);
    const width = window.innerWidth;
    const height = window.innerHeight;
    canvas.width = Math.floor(window.innerWidth * ratio);
    canvas.height = Math.floor(window.innerHeight * ratio);
    canvas.style.width = `${window.innerWidth}px`;
    canvas.style.height = `${window.innerHeight}px`;
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    squares.length = 0;

    const step = Math.max(18, Math.min(32, Math.round(width / 36)));
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
  }

  function drawFluid(time) {
    const width = window.innerWidth;
    const height = window.innerHeight;

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
        const distance = Math.hypot(square.x - wave.x, square.y - wave.y);
        const edgeDistance = Math.abs(distance - wave.radius);
        const band = Math.max(16, wave.width);
        const bandInfluence = Math.max(0, 1 - edgeDistance / band) * wave.life * wave.strength;
        waveInfluence = Math.max(waveInfluence, bandInfluence);
      });

      sweepWaves.forEach((sweepWave) => {
        const bandDistance = Math.abs(square.y - sweepWave.y);
        const bandInfluence = Math.max(0, 1 - bandDistance / sweepWave.width) * sweepWave.life * sweepWave.strength;
        sweepInfluence = Math.max(sweepInfluence, bandInfluence);
      });

      const totalInfluence = Math.max(waveInfluence, sweepInfluence);

      const size = square.baseSize * (1 + totalInfluence * 0.9);
      const fillOpacity = square.alpha * (0.03 + opacityLoop * 0.18) + pulse * 0.012 + totalInfluence * 0.12;
      const strokeOpacity = square.strokeAlpha * (0.42 + opacityLoop * 1.1) + pulse * 0.028 + driftPulse * 0.02 + totalInfluence * 0.26;
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

  function updatePortals(time) {
    portals.forEach((portal, index) => {
      const xShift = pointer.active ? (pointer.x / window.innerWidth - 0.5) * (index % 3 === 0 ? 18 : 12) : 0;
      const yShift = Math.sin(time + index * 0.7) * 6;
      portal.style.transform = `translate3d(${xShift}px, ${yShift}px, 0)`;
    });
  }

  function frame(now) {
    const time = now * 0.00018;

    if (now - lastAmbientWaveAt > 500 + Math.random() * 1500) {
      emitWave(
        Math.random() * window.innerWidth,
        Math.random() * window.innerHeight,
        5.0 + Math.random() * 3.0,
        0.62
      );
      lastAmbientWaveAt = now;
    }

    if (now - lastSweepWaveAt > 10000 + Math.random() * 5000) {
      emitSweepWave(0.76 + Math.random() * 0.18);
      lastSweepWaveAt = now;
    }

    drawFluid(time);
    updatePortals(time);
    window.requestAnimationFrame(frame);
  }

  resize();

  if (reducedMotion) {
    drawFluid(0);
    return;
  }

  function emitWave(x, y, speedBoost, strength = 1) {
    waves.push({
      x,
      y,
      radius: 0,
      speed: (4 + speedBoost * 0.45) * (0.85 + strength * 0.15),
      width: 240 + speedBoost * 4.4,
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

  root.addEventListener("pointerleave", () => {
    pointer.active = false;
  });

  window.addEventListener("resize", resize);
  window.requestAnimationFrame(frame);
})();
