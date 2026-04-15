# Wallpaper Picker — QuickShell Native

Replace the external `tofi`-based wallpaper selector (`wl-select-wallpaper`) with a
built-in QuickShell panel. Keyboard-driven horizontal filmstrip at the bottom of the
screen with live wallpaper preview on navigation.

## Shell Integration

Same overlay pattern as Dashboard and ControlCenter in `shell.qml`:

- New `wallpaperPickerVisible` boolean, mutually exclusive with `dashboardVisible`
  and `controlCenterVisible`.
- IPC handler `toggle-wallpaper-picker` with a `toggle()` function.
- Full-screen `PanelWindow` at `WlrLayer.Overlay`, focusable, visible while
  `wallpaperPickerVisible || picker.offsetScale < 1.0`.
- Hyprland keybind `$mod+O` changes from `exec wl-select-wallpaper` to
  `exec quickshell msg toggle-wallpaper-picker toggle`.

## Module Structure

New module: `modules/wallpaperpicker/`.

### WallpaperPicker.qml (wrapper)

Follows the DashWrapper / ControlCenter pattern:

| Concern | Detail |
|---------|--------|
| `offsetScale` | `0` = visible, `1` = hidden. Driven by `shell.qml`. |
| Animation | `Behavior on offsetScale` — expressive spatial curve, same duration as other overlays. |
| Slide direction | Up from bottom: `Translate { y: containerHeight * offsetScale }`. |
| Scrim | Click-outside dismisses via `dismissed()` signal. |
| Focus / keys | `focus: offsetScale < 1.0`, Escape fires `dismissed()`. |
| Session state | Delegates to internal `PickerSession` QtObject (see below). |

### PickerSession (internal QtObject)

Separates session state from animation/layout concerns. Created when the panel opens,
holds all mutable state for one picker interaction:

- `originalWallpaper: string` — snapshot of `WallpaperService.current` on open.
- `committed: bool` — set true when Enter/click fires the commit process.
- `commitProcess: Process` — runs `wl-set-wallpaper <path>`.
- `revert()` — if `!committed`, restores `originalWallpaper` via
  `WallpaperService._writeAtomic()`.
- On commit process `onFinished`: if exit code != 0, reverts to `originalWallpaper`
  and surfaces a warning (console or notification). Panel is already visually gone at
  this point — the session object stays alive until the process completes.

### WallpaperFilmstrip.qml (content)

Horizontal thumbnail strip, bottom-anchored, horizontally centered.

**File scanning:**

- Single `Process` on creation: `find -L <dir> -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \)`.
- Wallpaper directory: `$WALLPAPER_DIR` env var, fallback `~/.local/share/wallpapers`.
- Buffer stdout in a string accumulator. Parse into `ListModel` only on `onFinished`
  (not `onReadyRead`) to avoid partial-line splits at buffer boundaries.
- On populate, `currentIndex` set to the entry matching `WallpaperService.current`.
  If no match (wallpaper was set from outside the directory), default to index 0
  without triggering a preview — the current wallpaper is already displayed.
- No re-scan while open.

**Empty state:**

- If the model is empty after scanning (directory missing or no image files),
  show a centered message: "No wallpapers found" on the filmstrip area.
  Panel still opens and can be dismissed normally.

**Thumbnail rendering:**

- Horizontal `ListView` with fixed-aspect-ratio delegate containers.
- `Image` with `sourceSize.height: ~180`, `asynchronous: true`,
  `fillMode: Image.PreserveAspectCrop`.
- Active thumbnail gets an M3 `m3primary` highlight border.
- ListView virtualization keeps memory bounded.

**Navigation:**

- Left / Right / h / l keys move `currentIndex`. Wraps around (last→first, first→last).
- `positionViewAtIndex(currentIndex, ListView.Center)` on every index change to keep
  the highlight visible.
- Enter or click commits.
- Escape dismisses (reverts).

## Preview vs Commit

Two distinct levels of wallpaper application:

### Preview (on navigate)

- `WallpaperService._writeAtomic(path)` — atomic symlink swap + resolve.
- Triggers crossfade behind the panel via existing `Wallpaper.qml` dual-image system.
- No thememanager. Color scheme stays stable during browsing.

### Commit (Enter / click)

- Sets `PickerSession.committed = true`.
- Runs `wl-set-wallpaper <path>` via `PickerSession.commitProcess`.
- This triggers: symlink write, `thememanager auto --wallpaper`, QuickShell IPC reload.
- Panel dismisses immediately (feels snappy). Session object stays alive until
  process completes.
- On commit process failure (non-zero exit): reverts to `_originalWallpaper` via
  `WallpaperService._writeAtomic()`, logs warning to console.

### Revert (Escape / scrim click)

- Calls `PickerSession.revert()` — restores `_originalWallpaper` if `!committed`.
- Crossfade reverts behind panel.
- Panel dismisses.

## Files Changed

| File | Change |
|------|--------|
| `shell.qml` | New visibility state, IPC handler, PanelWindow for picker |
| `hyprland.conf` | `$mod+O` keybind → `quickshell msg toggle-wallpaper-picker toggle` |
| `modules/wallpaperpicker/WallpaperPicker.qml` | New — wrapper with slide animation, scrim, PickerSession for state/revert/commit |
| `modules/wallpaperpicker/WallpaperFilmstrip.qml` | New — filmstrip ListView, file scanning, navigation, commit |

## Performance

- `sourceSize.height` caps decode resolution — 4K images load as ~180px tall thumbnails.
- `asynchronous: true` decodes off the main thread.
- `ListView` virtualizes delegates — only visible + buffer items are instantiated.
- Single `find` call, no polling or re-scanning.
