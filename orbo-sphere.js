// Orbo — the sphere renderer. Self-registers window.__ORBO_SPHERE for the DC logic class to
// call into (a plain class can't `import` an ES module, so this global is the bridge).
//
// CLASSIC script on purpose (was `import * as THREE from 'three'` + an importmap). The
// standalone bundler only follows HTML src= attributes — an ES import specifier is invisible
// to it, so three never shipped in the export and Orbo degraded to a flat untextured disc.
// three arrives as window.THREE from vendor/three/three.global.js.
//
// THREE is read LAZILY, inside mount() — never captured at evaluation time. In the standalone
// bundle every script becomes a blob: URL and strict document order is NOT preserved, so this
// file can evaluate before three (the biggest file) has run. A top-level
// `var THREE = window.THREE` captured undefined permanently and mount() then died on
// `new THREE.WebGLRenderer`. Reading it per-mount means a late three still works.
function ready() { return !!window.THREE; }

function mount(canvas) {
  const THREE = window.THREE;
  if (!THREE) throw new Error('orbo-sphere: three.js not loaded yet');
  const rParams = {};
  rParams.canvas = canvas;
  rParams.alpha = true;
  rParams.antialias = true;
  rParams.preserveDrawingBuffer = true;
  const renderer = new THREE.WebGLRenderer(rParams);
  const baseDpr = Math.min(window.devicePixelRatio || 1, 1.5);
  let renderScale = 1; // oversample factor — pushed high during the tight onboarding zoom so the
                       // CSS-scaled canvas keeps its edges instead of pixelating up from 62px.
  renderer.setPixelRatio(baseDpr);
  renderer.setClearColor(0x000000, 0);

  const scene = new THREE.Scene();
  const camera = new THREE.PerspectiveCamera(28, 1, 0.1, 100);
  // Dead-on: Orbo is a character who looks AT the viewer. The eyes are baked at the +X
  // face of the texture (u≈0.5), so the camera sits on +Z and the mesh's base rotation
  // (BASE_Y = -90°) turns that eye-face toward the camera.
  camera.position.set(0, 0, 4.2);
  camera.lookAt(0, 0, 0);

  const geo = new THREE.SphereGeometry(1, 64, 64);
  const mat = new THREE.MeshStandardMaterial();
  mat.roughness = 0.92;
  mat.metalness = 0.04;
  const mesh = new THREE.Mesh(geo, mat);
  // Eyes are baked at the +X face; rotate -90° about Y to bring them to +Z, facing the camera.
  // The small extra term is the fine nudge that centres them exactly on the meridian.
  const BASE_Y = -Math.PI / 2 - 0.02;
  mesh.rotation.set(0, BASE_Y, 0);
  scene.add(mesh);

  // Declared BEFORE the texture load below, which reads `glow` from its callback — safe today
  // only because decode is async; hoisting removes the TDZ landmine entirely.
  let lightDirX = 0;
  let lightDirY = -1;
  let lightColor = null; // when set (by the astrolabe's emission tweak), the key light takes this hue
  let lightIntensity = 16;
  let lightSoft = 0.55;
  let glow = 0.22; // self-illumination off his own map — the floor that keeps him from ever being a black disc
  let gazeX = 0;
  let gazeY = 0;
  let gazeStrength = 0.6;
  let gazeSpeed = 1;
  let spin = false;
  let spinAngle = 0;
  let headTilt = 0; // pitch, radians — an axis of its own, independent of gaze and of the orbit
  let idlePhase = Math.random() * 10;
  let disposed = false;
  let raf = null;

  const texLoader = new THREE.TextureLoader();
  // The map's URL comes off the hidden #orbo-sphere-tex <img> in the document, not a string
  // literal: the bundler rewrites HTML src= attributes to data URIs, so this is what makes
  // Orbo's surface survive the standalone export. Literal path is the in-project fallback.
  const texEl = document.getElementById('orbo-sphere-tex');
  const texUrl = (texEl && (texEl.currentSrc || texEl.src)) || 'orbo-surface.png';
  texLoader.load(texUrl, function (tex) {
    tex.colorSpace = THREE.SRGBColorSpace;
    tex.anisotropy = 4;
    mat.map = tex;
    // Faint self-illumination off the same map so Orbo is never a black disc — the night
    // side still reads as his own surface, while the key light does the day-side relief.
    mat.emissiveMap = tex;
    mat.emissive = new THREE.Color(0xffffff);
    mat.emissiveIntensity = glow;
    mat.needsUpdate = true;
  });

  // Sun-law lighting: a distant directional "sun" gives a clean planetary terminator; its
  // direction is fed every frame from the astrolabe's plate-center vector (see _orboTick) —
  // Orbo doesn't have his own light, the instrument does.
  const key = new THREE.DirectionalLight(0xfff1dc, 3.4);
  key.position.set(0.6, 0.4, 1);
  scene.add(key);
  const ambient = new THREE.AmbientLight(0x8ea2ff, 0.6); // cool floor so the night side never goes pure black
  scene.add(ambient);
  const rim = new THREE.DirectionalLight(0x9fb4ff, 0.5); // faint back-rim for roundness
  rim.position.set(-0.7, 0.3, -0.8);
  scene.add(rim);

  function resize() {
    const w = canvas.clientWidth || 1;
    const h = canvas.clientHeight || 1;
    renderer.setPixelRatio(baseDpr * renderScale);
    renderer.setSize(w, h, false);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  const ro = new ResizeObserver(resize);
  ro.observe(canvas);
  resize();

  // ONE HEARTBEAT, NOT TWO. This used to own a `requestAnimationFrame(loop)` of its own, which
  // made Orbo's body a SECOND TIMELINE against the DC's `_tick` that writes his position — so his
  // sphere rendered on a different frame from the place it was rendered at, and every rate below
  // was a fixed increment PER FRAME rather than per second (at 40fps his gaze drifted at two thirds
  // of its intended speed, and changed speed whenever load did). `step(dt)` is now called from the
  // DC's one RAF, next to setLightDir, and every rate is per-second. dt is clamped by the caller.
  // `f` is the legacy per-frame increment restated as "what a 60fps frame was worth", so the tuned
  // feel of the gaze and the spin is preserved exactly at 60fps and merely CORRECT below it.
  function step(dt) {
    if (disposed) return;
    const f = (dt > 0 ? dt : 1 / 60) * 60;
    idlePhase += 0.008 * gazeSpeed * f;
    const idleY = Math.sin(idlePhase) * 0.05;
    const idleX = Math.cos(idlePhase * 0.7) * 0.025;
    const gx = gazeX * gazeStrength + idleX;
    const gy = gazeY * gazeStrength + idleY;
    // Planet law: Orbo only ever rotates ONE way. At rest he is tidally locked — eye-face on the
    // viewer (spinAngle 0). Spin on → he tumbles forward forever. Spin off → he does NOT reverse
    // or freeze mid-face; he coasts FORWARD to the next full turn and eases back onto the viewer.
    const spinRate = 0.0035 * gazeSpeed * f;
    const TWO_PI = Math.PI * 2;
    if (spin) {
      spinAngle = (spinAngle + spinRate) % TWO_PI;
    } else if (spinAngle > 0.0001) {
      const remain = TWO_PI - spinAngle;
      // ease-out with a floor so it always lands; the floor is per-second too, and the ease
      // constant is frame-rate corrected the same way a spring would be.
      spinAngle += Math.max(spinRate * 0.5, remain * Math.min(1, 0.06 * f));
      if (spinAngle >= TWO_PI - 0.002) spinAngle = 0; // hit his mark → locked on the viewer
    }
    mesh.rotation.y = BASE_Y + gx + spinAngle;
    mesh.rotation.x = gy + headTilt;

    // Point the directional sun along the plate-center angle. Kept toward +Z (in front) so
    // the lit face is always the one the camera sees; the angle sweeps the terminator across it.
    const ang = Math.atan2(lightDirY, lightDirX);
    key.position.set(Math.cos(ang) * 1.1, -Math.sin(ang) * 0.7 + 0.25, 0.85);
    if (lightColor != null) key.color.set(lightColor);
    key.intensity = 0.6 + (lightIntensity / 16) * 3.2;
    ambient.intensity = 0.35 + lightSoft * 0.55;
    if (mat.map) mat.emissiveIntensity = glow;

    renderer.render(scene, camera);
  }

  const api = {};
  // The one door in: the DC's single RAF advances him and renders him on the same frame that
  // writes his position. Never add a RAF back into this file.
  api.step = step;
  api.setLightDir = function (x, y) { lightDirX = x; lightDirY = y; };
  api.setLightColor = function (hex) { lightColor = hex || null; };
  api.setLightIntensity = function (v) { lightIntensity = v; };
  api.setLightSoft = function (v) { lightSoft = v; };
  api.setGaze = function (x, y) { gazeX = x; gazeY = y; };
  api.setGazeStrength = function (v) { gazeStrength = v; };
  api.setGazeSpeed = function (v) { gazeSpeed = v; };
  api.setSpin = function (v) { spin = v; };
  api.setHeadTilt = function (deg) { headTilt = (+deg || 0) * Math.PI / 180; };
  api.setGlow = function (v) { glow = v; };
  // Oversample the drawing buffer while the instrument is CSS-scaled up around Orbo, so his
  // sphere renders at the ON-SCREEN size, not his 62px layout box. Clamped to keep the buffer sane.
  api.setRenderScale = function (k) {
    k = Math.max(1, Math.min(10, k || 1));
    if (k !== renderScale) { renderScale = k; resize(); }
  };
  // Called from componentWillUnmount. Without this every remount leaked a live WebGL context
  // AND an orphaned RAF still rendering into it; browsers cap contexts (~16) and start killing
  // the oldest, which read as Orbo intermittently vanishing and the app slowing over a session.
  api.dispose = function () {
    disposed = true;
    if (raf) cancelAnimationFrame(raf); // kept: an older bundled copy may still have set one
    ro.disconnect();
    geo.dispose();
    if (mat.map) mat.map.dispose();
    mat.dispose();
    renderer.dispose();
    // drops the GL context immediately rather than waiting on GC
    try { renderer.forceContextLoss(); } catch (e) {}
  };
  return api;
}

window.__ORBO_SPHERE = { mount: mount, ready: ready };
