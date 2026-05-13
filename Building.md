# Building XPTools / WorldEditor (WED)

This document covers **building** the X-Plane scenery tools from source. It also explains **this repository as a fork** of upstream [XPTools](https://github.com/X-Plane/xptools), with an optional WorldEditor build that can **skip airport and scenery validation** so you can export after small edits without fixing unrelated legacy errors.

Upstream reference: [Scenery Tools Bug Database](http://developer.x-plane.com/scenery-tools-bug-database/ "Scenery Tools Bug Database").

**Maintainer (this fork):** bigtajine (see `WED_MODS_CREDIT_STRING` in `src/WEDCore/WED_Version.h`). WorldEditor is branded **2.6.1-no-val** to distinguish it from stock WED.

---

## Contents

- [About this fork](#about-this-fork)
- [Why validation gets in the way (community context)](#why-validation-gets-in-the-way-community-context)
- [What "no validation" means and what you risk](#what-no-validation-means-and-what-you-risk)
- [Changelog (2.6.1-no-val fork)](#changelog-261-no-val-fork)
- [Setting Up Your Build Environment](#setting-up-your-build-environment)
  - [macOS](#macos)
  - [Windows](#windows)
  - [Linux](#linux)
- [Getting the Source Code](#getting-the-source-code)
- [Compiling the Program](#compiling-the-program)
  - [Prerequisites (all platforms)](#prerequisites-all-platforms)
  - [Windows](#windows-1)
  - [Linux and macOS](#linux-and-macos)
  - [Building the binaries](#building-the-binaries)
  - [CMake options (including validation)](#cmake-options-including-validation)

---

## About this fork

This tree is a **fork** of Laminar’s open-source scenery tools. The main goal is **not** to replace official WED for Gateway submissions or “first-class” airport work, but to support a practical workflow stock WED makes painful:

- You open **third-party or older** scenery that **used to export**, but under **today’s stricter rules** it fails validation (draped polygons, taxi network, winding, “airport impossibly large,” and dozens of other checks).
- You only want to do **small, local edits**—for example **delete or move a few objects**—and **re-export**, without spending hours fixing **unrelated** errors across the whole airport.

Stock WED intentionally ties **export** to passing validation, to keep scenery quality high in the ecosystem. This fork adds a **compile-time** escape hatch: build with **`WED_NO_VALIDATION=ON`** so `WED_ValidateApt` effectively **always succeeds** (see `src/WEDCore/WED_Validate.cpp`). You choose at **build** time whether your binary behaves like upstream or like this fork’s “no-val” variant.

---

## Why validation gets in the way (community context)

Designers have discussed this for years on X-Plane.org—for example [“Why do I always get Validation Errors when editing in WED?”](https://forums.x-plane.org/forums/topic/194923-wed-how-to-ignore-deal-with-warnings/) (Scenery Development Forum). Common themes from that thread and related posts:

- **Rules tightened over time.** An airport that exported in an older WED / older export target may **fail today** even if you change almost nothing.
- **Legitimate fixes exist** (splitting taxi crossings, merging nodes, fixing Bezier self-intersections near nodes, cleaning duplicate vertices, correcting hierarchy so items are not under the wrong airport, and so on). Those are still the **right** fix if you care about ATC/taxi behavior and Gateway acceptance.
- **There is no official “ignore all errors” export switch** in stock WED; frustration is especially high when your edit has **nothing to do** with the failing checks (e.g. you only removed an object or tweaked parking).

This fork’s **optional** no-validation build is aimed squarely at that last situation: **fast, surgical edits** on messy packages where you accept responsibility for the result.

---

## What "no validation" means and what you risk

With **`WED_NO_VALIDATION=ON`**:

- The **Validate** path and **pre-export validation** no longer block you with the full rule set; the tool behaves as if validation **passed cleanly**.
- You can still **break** taxi logic, draped meshes, or Gateway rules in the exported data—the checks simply are not run.

**You should still use stock WED** (or a build with validation **on**) when:

- Submitting to the **Airport Scenery Gateway**.
- You want WED to **catch mistakes** before they show up in the sim.
- You are doing serious **taxi / ATC** work and need the errors as guidance.

**This fork’s no-validation build** is for **personal workflows**, quick cleanup, overlays, or legacy packages where fixing every error is disproportionate to the change you are making.

---

## Changelog (2.6.1-no-val fork)

### Validation / packaging

- **Optional compile-time validation bypass:** CMake option **`WED_NO_VALIDATION`** in `cmake/WED.cmake`. When `ON`, `WED_ValidateApt` returns success immediately (`#if WED_NO_VALIDATION` in `src/WEDCore/WED_Validate.cpp`), so export is not held hostage by unrelated validation failures.
- **Versioning and credits:** `src/WEDCore/WED_Version.h` set to **2.6.1-no-val**; maintainer string **bigtajine** surfaced in About, startup, `WED.rc` (Windows Comments), and `WED_Info.plist` (macOS bundle text).

### Editor performance / responsiveness (optimizations)

- **`WED_Map` drawing:** Combined visualization + structure traversal (`DrawVisStrFor` in `src/WEDMap/WED_Map.cpp` / `WED_Map.h`) so layers that draw both paths do **one DFS** instead of effectively walking the same tree twice—less CPU work on large sceneries.
- **Mouse-move hover refresh:** Throttled hover updates (`kHoverMouseMoveRefreshMs`) to avoid excessive refresh work on every mouse move.
- **Cull threshold:** Slightly adjusted `TOO_SMALL_TO_GO_IN` behavior/comments so deep recursion into huge airports is skipped a bit more aggressively when zoomed out (less wasted iteration for off-screen detail).

### Other

- **Build scripts / docs:** `cmake.ps1`, `cmake.sh`, and this `Building.md` updated for Conan 2 + CMake workflow and fork documentation.
- **Misc. small edits** in the working tree (e.g. `GUI_Fonts`, `WED_VertexTool`) as part of local maintenance; see `git log` / `git diff` for exact line-level history.

---

## Setting Up Your Build Environment

The X-Plane scenery tools code (XPTools) can be compiled for Mac, Windows, or Linux. Before you can work on the tools, you may need to get/update your development environment.

You will need a command-line version of [CMake](http://www.cmake.org/) installed. On macOS it can be installed via [Homebrew](https://brew.sh): `brew install cmake`.

**Note:** Some third-party dependencies are picky about CMake versions. If configure fails in odd ways, try a current **3.x** release (the upstream wiki historically warned about early **4.0** behavior with older `cmake_minimum_required` in some deps).

### macOS

To build on macOS, you will need a recent Xcode ([Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12)) with the command-line tools installed.

### Windows

Building on Windows requires [Visual Studio](https://visualstudio.microsoft.com/vs/features/cplusplus/) 2017 or later (the free Build Tools or Community edition is fine). The provided `cmake.ps1` script targets **Visual Studio 17 2022** and **x64**.

You will also need **Conan 2** on your PATH (for example `pip install "conan>=2,<3"`). On first use, create a default profile: `conan profile detect`.

### Linux

You will need a C++20-capable compiler, CMake, Ninja (or another generator), and **Conan 2**. You will also need system packages used by the stack and by Conan recipes (for example OpenGL/GLU development headers, X11, and—on Linux—the FLTK and EGL packages pulled in via Conan as specified in `conanfile.py`).

---

## Getting the Source Code

Upstream lives at [https://github.com/X-Plane/xptools](https://github.com/X-Plane/xptools). This fork may live on another remote; clone whichever you use:

    git clone https://github.com/X-Plane/xptools.git

If you do not want a full clone, use GitHub to download a ZIP or check out a release tag that matches a binary tools release.

---

## Compiling the Program

The scenery tools depend on many third-party libraries. This repository uses **Conan 2** to fetch and build them, then **CMake** to generate a build system.

The helper scripts **`cmake.ps1`** (Windows) and **`cmake.sh`** (Linux/macOS) only:

1. Run `conan install` for **Debug**, **Release**, and **RelWithDebInfo** (so all configurations have dependencies available).
2. Run **CMake configure** to generate the project (Visual Studio solution, Ninja files, or Xcode project).

They do **not** compile the executables by themselves. After a successful run, build from the command line or open the IDE project (see below).

### Prerequisites (all platforms)

- **CMake** and **Conan 2** on your PATH (`conan --version` should report 2.x).
- First-time Conan: `conan profile detect` (or use a named profile and pass it to the script).

### Windows

From a PowerShell prompt in the repository root:

    .\cmake.ps1

Optional flags: `-Clean` (delete `vs_build` first), `-BuildType Release`, `-ConanProfile default`, `-Verbose`.

This creates the directory **`vs_build`** and Conan output under **`vs_build\build\generators\`**. Open **`vs_build\xptools.sln`** in Visual Studio, pick **Release** or **Debug**, and build—or from PowerShell:

    cmake --build vs_build --config Release

To build only WorldEditor:

    cmake --build vs_build --config Release --target WED

Release binaries are typically under **`vs_build\Release\`** (and Debug under **`vs_build\Debug\`**).

**Tip:** Close **WED.exe** before linking, or the linker may fail with `LNK1104` (file in use).

### Linux and macOS

From the repository root (make the script executable once if needed: `chmod +x cmake.sh`):

    ./cmake.sh

Optional environment variables: `BUILD_DIR` (default `build`), `CONAN_PROFILE` (default `default`), `BUILD_TYPE` (default `Release`), `GENERATOR` (default: **Xcode** on macOS, **Ninja** on Linux). You can pass a generator as the first argument instead, for example:

    ./cmake.sh Ninja

Then compile:

    cmake --build build --config Release

(On single-configuration generators like Ninja, the build type usually follows `-DCMAKE_BUILD_TYPE` from configure time; adjust `BUILD_TYPE` before `./cmake.sh` if needed.)

### Building the binaries

CMake targets match the tools, for example:

- `WED` — WorldEditor
- `DDSTool`, `DSFTool`, `ObjView`, `XGrinder`, `OneOffs`

Example:

    cmake --build vs_build --config Release --target WED DDSTool

### CMake options (including validation)

Pass these on the **first** CMake configure (or re-run CMake in your build directory with `-D...`):

- **`-DWED_NO_VALIDATION=OFF`** (default in this tree’s `cmake/WED.cmake`) — full airport/scenery validation in `WED_ValidateApt` (Validate menu and pre-export checks run like upstream).
- **`-DWED_NO_VALIDATION=ON`** — validation is compiled out; **use only when you understand the tradeoffs** ([What "no validation" means](#what-no-validation-means-and-what-you-risk)).

Example after `cmake.ps1` (reconfigure in place to disable validation):

    cmake -S . -B vs_build -DCMAKE_TOOLCHAIN_FILE=vs_build/build/generators/conan_toolchain.cmake -DWED_NO_VALIDATION=ON

Then build again as usual.

For a **side-by-side** setup, use two build directories (for example `vs_build` with validation on and `vs_build_novalid` with `WED_NO_VALIDATION=ON`) so you always know which binary you are launching.
