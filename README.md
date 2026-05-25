<h1 align="center">
  <br>
  What To Do
  <br>
</h1>

<p align="center">
  <b>Make your MacBook's notch the star of the show.</b>
</p>

> **Note:** This project is adapted from [Boring Notch](https://github.com/TheBoredTeam/boring.notch) by [TheBoredTeam](https://github.com/TheBoredTeam). All credit for the original concept and core implementation goes to the original authors. This fork is maintained by [SapientialM](https://github.com/SapientialM).

Say hello to **What To Do** — your MacBook's notch transforms into a dynamic music control center, complete with a vibrant visualizer and all the essential music controls you need. But that's just the start! It also offers calendar integration, a handy file shelf with AirDrop support, a complete macOS HUD replacement and more!

---

## Features

- **Music Playback** — Live activity with visualizer and full music controls
- **Calendar Integration** — See your upcoming events at a glance
- **Reminders** — Track your to-dos right from the notch
- **Shelf with AirDrop** — Drag and drop files for quick sharing
- **System HUD** — Volume, brightness, and backlight replacements
- **Battery & Charging** — Live charging indicator and percentage
- **Mirror** — Quick access to your webcam
- **Customizable Gestures** — Control the notch your way

---

## Installation

**System Requirements:**
- macOS **14 Sonoma** or later
- Apple Silicon or Intel Mac

---

### Download and Install Manually

Download the latest `.dmg` from the [Releases](https://github.com/SapientialM/What-To-Do/releases) page.

Once downloaded, open the `.dmg` and move **What To Do** to your `/Applications` folder.

> [!IMPORTANT]
> We don't have an Apple Developer account (yet), so macOS will warn you that What To Do is from an unidentified developer on first launch. This is expected behavior.
>
> You'll need to bypass this before the app will open. You only need to do this once.

#### Recommended: Terminal (Always Works)

After moving What To Do to your Applications folder, run:

```bash
xattr -dr com.apple.quarantine /Applications/WhatToDo.app
```

Then open the app normally.

---

## Usage

- Launch the app, and voila — your notch is now the coolest part of your screen.
- Hover over the notch to see it expand and reveal all its secrets.
- Use the controls to manage your music like a rockstar.
- Click the star in your menu bar to customize your notch to your heart's content.

## Roadmap

- [ ] Refined notification system
- [ ] Weather integration
- [ ] Customizable layout options
- [ ] Lock Screen widgets
- [ ] Extension system
- [ ] Bluetooth device live activity
- [ ] Multi-language support improvements
- [ ] Performance optimizations for Apple Silicon

## Building from Source

### Prerequisites

- **macOS 14 or later**
- **Xcode 16 or later**

### Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/SapientialM/What-To-Do.git
   cd What-To-Do
   ```

2. **Open the Project in Xcode**:
   ```bash
   open boringNotch.xcodeproj
   ```

3. **Build and Run**:
    - Click the "Run" button or press `Cmd + R`.

## Contributing

We welcome contributions! Read [CONTRIBUTING.md](CONTRIBUTING.md) to learn how you can join in.

## Acknowledgments

This project is adapted from **[Boring Notch](https://github.com/TheBoredTeam/boring.notch)** by [TheBoredTeam](https://github.com/TheBoredTeam). Huge thanks to the original authors for building such an amazing open-source project.

For a full list of licenses and attributions, please see the [Third-Party Licenses](./THIRD_PARTY_LICENSES.md) file.

### Notable Projects
- **[MediaRemoteAdapter](https://github.com/ungive/mediaremote-adapter)** — Enabled Now Playing source support in macOS 15.4+
- **[NotchDrop](https://github.com/Lakr233/NotchDrop)** — Instrumental in developing the first version of the "Shelf" feature.

### Icon credits: [@maxtron95](https://github.com/maxtron95)
### Website credits: [@himanshhhhuv](https://github.com/himanshhhhuv)

## License

This project is licensed under the **GNU General Public License v3.0** (GPLv3), the same license used by the original Boring Notch project. See [LICENSE](./LICENSE) for the full text.

> Copyright (C) 2024-2025 [TheBoredTeam](https://github.com/TheBoredTeam)
> Copyright (C) 2026 [SapientialM](https://github.com/SapientialM)
