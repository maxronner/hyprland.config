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
| Revert state | Stores `_originalWallpaper` (from `WallpaperService.current`) when the panel opens. On dismiss without commit, restores it via `WallpaperService._writeAtomic()`. |

### WallpaperFilmstrip.qml (content)

Horizontal thumbnail strip, bottom-anchored, horizontally centered.

**File scanning:**

- Single `Process` on creation: `find -L <dir> -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.bmp" \)`.
- Wallpaper directory: `$WALLPAPER_DIR` env var, fallback `~/.local/share/wallpapers`.
- Stdout lines parsed into a `ListModel` of `{ path: string }`.
- On populate, `currentIndex` set to the entry matching `WallpaperService.current`.
- No re-scan while open.

**Thumbnail rendering:**

- Horizontal `ListView` with fixed-aspect-ratio delegate containers.
- `Image` with `sourceSize.height: ~180`, `asynchronous: true`,
  `fillMode: Image.PreserveAspectCrop`.
- Active thumbnail gets an M3 `m3primary` highlight border.
- ListView virtualization keeps memory bounded.

**Navigation:**

- Left / Right / h / l keys move `currentIndex`.
- Enter or click commits.
- Escape dismisses (reverts).

## Preview vs Commit

Two distinct levels of wallpaper application:

### Preview (on navigate)

- `WallpaperService._writeAtomic(path)` — atomic symlink swap + resolve.
- Triggers crossfade behind the panel via existing `Wallpaper.qml` dual-image system.
- No thememanager. Color scheme stays stable during browsing.

### Commit (Enter / click)

- Runs `wl-set-wallpaper <path>` via `Process`.
- This triggers: symlink write, `thememanager auto --wallpaper`, QuickShell IPC reload.
- Panel dismisses after process exits.

### Revert (Escape / scrim click)

- `WallpaperService._writeAtomic(_originalWallpaper)` restores previous symlink.
- Crossfade reverts behind panel.
- Panel dismisses.

## Files Changed

| File | Change |
|------|--------|
| `shell.qml` | New visibility state, IPC handler, PanelWindow for picker |
| `hyprland.conf` | `$mod+O` keybind → `quickshell msg toggle-wallpaper-picker toggle` |
| `modules/wallpaperpicker/WallpaperPicker.qml` | New — wrapper with slide animation, scrim, revert logic |
| `modules/wallpaperpicker/WallpaperFilmstrip.qml` | New — filmstrip ListView, file scanning, navigation, commit |

## Performance

- `sourceSize.height` caps decode resolution — 4K images load as ~180px tall thumbnails.
- `asynchronous: true` decodes off the main thread.
- `ListView` virtualizes delegates — only visible + buffer items are instantiated.
- Single `find` call, no polling or re-scanning.
