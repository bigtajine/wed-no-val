# XPTools / WorldEditor (WED) — bigtajine fork (`2.6.1-no-val`)

This repository is the **X-Plane scenery tools (XPTools)** source tree: WorldEditor (WED), DSFTools, XGrinder, and related utilities. **This copy is a community fork** whose main practical goal is an **optional WorldEditor build that does not run airport/scenery validation**, so you can open messy third-party packages, make **small edits** (for example **delete objects**), and **export** without being forced to fix unrelated validation errors first.

Full build steps, CMake details, and a longer discussion of validation tradeoffs are in **[Building.md](Building.md)**.

---

## Fork status

| | |
| --- | --- |
| **Upstream project** | [X-Plane / xptools](https://github.com/X-Plane/xptools) — Laminar Research scenery tools (WorldEditor, DSF tools, etc.). |
| **This fork** | Maintained by **bigtajine**. Focus: **optional compile-time validation bypass** for WED (`WED_NO_VALIDATION`), **optional builds that omit Gateway export and pack-upload UI** (`WED_NO_GATEWAY` — import from Gateway unchanged), **map/editor performance** tweaks, **build/docs** (Conan 2 + CMake), and a clear **version label** so binaries are not confused with stock WED. |
| **Version label** | **2.6.1-no-val** (see `src/WEDCore/WED_Version.h`). The **`-no-val`** suffix flags that this tree is intended to support **no-validation** builds; it is **not** an official Laminar version number. |
| **Affiliation** | This fork is **community-maintained** and is **not** officially affiliated with **Laminar Research**, the **Airport Scenery Gateway**, or the owners of the upstream GitHub repository. |

Stock WED ties export to passing validation for good reasons (sim quality, Gateway rules). This fork adds a **deliberate escape hatch at build time** for workflows where that policy is disproportionate to the edit you are making.

---

## Why this fork exists (short)

Designers have discussed for years that **validation got stricter over time**, so airports that once exported can **fail today** with draped-polygon, taxi-network, winding, and other errors unrelated to a quick fix. There is **no** official “ignore validation and export anyway” switch in stock WED. Community thread (context and workarounds):  
[“Why do I always get Validation Errors when editing in WED?”](https://forums.x-plane.org/forums/topic/194923-wed-how-to-ignore-deal-with-warnings/) (X-Plane.org Scenery Development Forum).

**Typical use case here:** delete or adjust a few items in existing scenery and re-export **without** rework of the whole airport. For **serious airport work** where you want the full checker, use a **validation-enabled** build (see **Building.md**).

---

## Recent changes

### 2.6.1-no-val (fork)

- **Optional validation bypass (CMake):** `-DWED_NO_VALIDATION=ON` in `cmake/WED.cmake`. When enabled, `WED_ValidateApt` in `src/WEDCore/WED_Validate.cpp` returns **clean immediately** so the Validate menu path and pre-export validation do not block you with the full rule set.
- **Optional no-Gateway-export build (CMake):** `-DWED_NO_GATEWAY=ON` (see `cmake/WED.cmake`, `src/Obj/WED_NoGatewayOverrides.h`). Removes the **Airport Scenery Gateway** export target and the **pack-upload** UI path; **import from Gateway stays available**. **Slippy map / file cache / metadata CSV** still use HTTP via `curl_http` (not tied to `HAS_GATEWAY_EXPORT`).
- **Branding / credits:** Version string **2.6.1-no-val**; maintainer line **bigtajine** in About, startup screen, Windows `WED.rc` **Comments**, and macOS `WED_Info.plist`.
- **Editor performance (`WED_Map`):** Single combined DFS for layers that draw both structure and visualization (`DrawVisStrFor` in `src/WEDMap/WED_Map.cpp` / `WED_Map.h`) to avoid walking the same hierarchy twice on large sceneries.
- **UI responsiveness:** Throttled hover refresh on mouse move (`kHoverMouseMoveRefreshMs` in `WED_Map.cpp`).
- **Cull behavior:** Adjusted `TOO_SMALL_TO_GO_IN` handling so huge airports skip deeper recursion a bit more aggressively when zoomed out (less wasted work for off-screen detail).
- **Build system:** `cmake.ps1` / `cmake.sh` and documentation updated for **Conan 2** + **CMake** workflow (see Building.md).
- **Misc.:** Small local edits elsewhere in the tree (e.g. `GUI_Fonts`, `WED_VertexTool`); use `git log` / `git diff` against your base branch for line-by-line history.

---

## Building (quick)

Prerequisites: **CMake**, **Conan 2**, **Visual Studio 2022** (Windows) or Xcode / Ninja + compiler (macOS / Linux). See **[Building.md](Building.md)** for full environment notes.

**Important:** **`cmake.ps1` (or any `cmake -S -B …` configure) must run before `cmake --build`**, and you must **re-run configure** after changing `-NoValidation`, `-NoGateway`, or other `-D` flags. Otherwise the compiler still uses the old CMake cache and your new options will not appear in the binary.

### Fork CMake options (WED)

| Flag | Effect on WED |
| --- | --- |
| **`WED_NO_VALIDATION=ON`** | `WED_ValidateApt` succeeds immediately; Validate menu and pre-export checks do not run the full rule set. |
| **`WED_NO_GATEWAY=ON`** | **Export-side only:** removes the **Airport Scenery Gateway** export target and **pack-upload** UI; **`HAS_GATEWAY_EXPORT`** is forced off via `src/Obj/WED_NoGatewayOverrides.h`. **Import from Gateway stays on** (`HAS_GATEWAY` unchanged). |

Details and tradeoffs: **[Building.md](Building.md)**. Compile-time defaults and overrides: **`src/Obj/XDefs.h`**.

### Windows (from repo root)

**Recommended** WED profile for this fork (Conan + CMake generate, then build):

```powershell
.\cmake.ps1 -BuildType Release -NoValidation -NoGateway
cmake --build vs_build --config Release --target WED
```

`-NoValidation` maps to **`-DWED_NO_VALIDATION=ON`**; `-NoGateway` maps to **`-DWED_NO_GATEWAY=ON`** (see `cmake.ps1` and `cmake/WED.cmake`). Other configure combinations are **not** documented here; see **[Building.md](Building.md)** if you maintain a custom build matrix.

### Second build directory (side-by-side binaries)

After `.\cmake.ps1` has run once so Conan’s **`vs_build\build\generators\conan_toolchain.cmake`** exists, you can configure a **separate** tree (e.g. `vs_build_novalid`) if you want both a stock-like and a no-val binary:

```powershell
cmake -S . -B vs_build_novalid -DCMAKE_TOOLCHAIN_FILE=vs_build/build/generators/conan_toolchain.cmake -DWED_NO_VALIDATION=ON -DWED_NO_GATEWAY=ON
cmake --build vs_build_novalid --config Release --target WED
```

Release output (default layout): **`vs_build\Release\WED.exe`** (or your chosen build dir).

**macOS / Linux:** Use **`cmake.sh`** or the CMake commands in **[Building.md](Building.md)**; pass the same **`WED_NO_VALIDATION`** / **`WED_NO_GATEWAY`** defines on configure, then build your chosen target.

---

## Troubleshooting

| Problem | What to do |
| --- | --- |
| **Link error `LNK1104` / cannot open `WED.exe`** | Exit **WorldEditor** (and any duplicate `WED.exe` processes) so the linker can overwrite the executable. |
| **Wrong binary (validation on vs off)** | Use two directories (e.g. `vs_build` vs `vs_build_novalid`) and check which one you launch; the **no-val** label in About matches `WED_NO_VALIDATION` builds only if you built with that flag. |
| **Wrong WED.exe (feature mix)** | Match the folder you built from (`vs_build` vs `vs_build_novalid`, etc.); this fork’s **no-val** packages are intended to ship with **`WED_NO_GATEWAY=ON`**. |
| **CMake / Conan errors** | See **Building.md** (CMake 3.x vs 4.x note, `conan profile detect`, toolchain path). |

---

## Original upstream README (condensed)

The **X-Plane Scenery Tools** codebase is the source for Laminar’s scenery creation and editing tools. It does **not** include X-Plane, Plane Maker, or Airfoil Maker. It **does** include **WorldEditor (WED)** and other tools (e.g. DSFTools, XGrinder, packaging scripts).

Official clone (upstream):

```text
git clone https://github.com/X-Plane/xptools.git
```

Upstream generally aims for `master` to build; for stable binaries, prefer **release tags** on the official repo.

### Licensing and copyright

Code original to Laminar Research under `src/` is under the **MIT/X11** license (see per-file headers). Third-party code under `SDK/` and elsewhere keeps its own licenses. If you see missing or conflicting copyright notices in upstream files, that is worth reporting on the **official** project.

### Contributing (upstream workflow)

Contributions to **upstream** XPTools go via GitHub fork and pull request against [X-Plane/xptools](https://github.com/X-Plane/xptools). This **bigtajine** fork may or may not accept PRs depending on how you host it; for changes intended for everyone, upstream is the right destination.

### Top-level layout

| Path | Purpose |
| --- | --- |
| `cmake/` | CMake scripts for tools |
| `src/` | Main source (WED, DSF tools, GUI, etc.) |
| `test/` | Regression / test inputs |
| `scripts/` | Packaging and utility scripts |
| `SDK/` | Bundled SDK / third-party sources used by the build |

### Documentation / contact (upstream)

Additional developer documentation may live under `src/` (tool-specific READMEs). For upstream bug reports and discussion, use Laminar’s **Scenery Tools Bug Database** and channels linked from the [official developer site](http://developer.x-plane.com/).
