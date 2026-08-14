# Orbo Astrolabe — iOS wrapper (sideload to your own phone, no paid dev account)

This folder wraps the already-working standalone app (`www/index.html` — a full copy of
`Orbo Astrolabe Standalone.html`, fully self-contained, no network calls) in a native iOS
shell using **Capacitor**. Capacitor just puts your existing web app inside a real iOS app
container — you are not rewriting anything yet.

Free Apple ID (no $99/yr Developer Program) is enough for this: you can build and install
to your own iPhone from Xcode. The one limitation: the app's trust/signature expires after
**7 days**, so every week you'll reconnect your phone and hit Run again in Xcode (10 seconds).
There is no App Store step in this path.

## What you need
- A Mac (you have one) with **Xcode** installed (free, via the App Store) — first launch of
  Xcode will prompt to install additional components, let it.
- **Node.js** installed (if `node -v` fails in Terminal, get it from nodejs.org — the LTS installer).
- Your iPhone, a cable, and your regular Apple ID (the one you're signed into your Mac with is fine).

## One-time setup

Open Terminal, `cd` into this `ios-wrapper` folder, then:

```bash
npm install
npx cap add ios
npx cap copy ios
npx cap open ios
```

That last command opens the generated project in Xcode.

## In Xcode (one-time)

1. In the left sidebar, click the top-level **App** project, then the **App** target.
2. Go to the **Signing & Capabilities** tab.
3. Under **Team**, choose your Apple ID (if it's not listed, click "Add an Account…" and sign in
   with your regular Apple ID — no paid enrollment needed).
4. Xcode will likely complain the **Bundle Identifier** (`com.orbo.astrolabe`) is taken globally —
   change it to something unique, e.g. `com.yourname.orboastrolabe`, in the same tab.
5. Plug in your iPhone. Trust the computer if prompted (on the phone).
6. At the top of the Xcode window, pick your iPhone from the device dropdown (instead of a simulator).
7. Hit the ▶ Run button.

First time only, on the iPhone: **Settings → General → VPN & Device Management** → tap your
Apple ID under "Developer App" → **Trust**. Then relaunch the Orbo icon from your home screen.

## Every ~7 days

Free-account builds expire weekly. When the app won't open: plug the phone back in, hit
▶ Run in Xcode again (same project, no setup repeated). Takes seconds.

## Updating the app's content later

Whenever the design changes and you get a new `Orbo Astrolabe Standalone.html` from me:

1. Replace `ios-wrapper/www/index.html` with the new file's contents.
2. In Terminal, from `ios-wrapper/`: `npx cap copy ios`
3. Back in Xcode, hit ▶ Run again.

## Known rough edge to expect

The web app was designed to run inside Safari's browser chrome. Running natively in Capacitor,
the app gets the full screen with no Safari UI — on notched iPhones this means content near the
very top/bottom edges may sit slightly into the status bar / home-indicator area (no safe-area
padding yet). Cosmetic only; flag it and I'll add proper safe-area insets once you're testing the
native shell.
