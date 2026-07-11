# WED No-Validation Fork

A fork of [X-Plane/xptools](https://github.com/X-Plane/xptools) with an optional WorldEditor (WED) build that skips airport/scenery validation on export.

## Overview

Stock WED refuses to export until an airport passes its full validation pass (draped polygons, taxi network, winding order, and more). That's fine for full airport work, but it also blocks trivial edits — like deleting a couple of objects in a legacy scenery — behind unrelated validation errors that have nothing to do with the change being made.

This fork adds two build-time CMake options:

| Flag | Effect |
| --- | --- |
| `WED_NO_VALIDATION=ON` | `WED_ValidateApt` (`src/WEDCore/WED_Validate.cpp`) returns clean immediately, so Validate and pre-export checks no longer block export. |
| `WED_NO_GATEWAY=ON` | Removes the Scenery Gateway export target and pack-upload UI (`src/Obj/WED_NoGatewayOverrides.h`). Gateway import is unaffected. |

The no-validation build is meant for small, local edits to existing scenery — not for airports headed to the Gateway. `WED_NO_GATEWAY=ON` exists specifically to keep unvalidated exports out of the Gateway pipeline; the two flags are intended to ship together.

Also included: native OS CA store for libcurl on Windows/macOS (`src/Network/curl_http.cpp`), fixing the common `SSL peer certificate not ok` error under Conan's OpenSSL when no CA bundle is present, plus minor `WED_Map` rendering/perf tweaks.

Version is labeled `2.6.1-no-val` (`src/WEDCore/WED_Version.h`) so binaries aren't mistaken for stock WED.

Background: [Why do I always get Validation Errors when editing in WED?](https://forums.x-plane.org/forums/topic/194923-wed-how-to-ignore-deal-with-warnings/)

## Building

See [Building.md](Building.md) for prerequisites. Quick path on Windows:

```powershell
.\cmake.ps1 -BuildType Release -NoValidation -NoGateway
cmake --build vs_build --config Release --target WED
```

`-NoValidation` / `-NoGateway` map to the CMake flags above. Re-run configure after changing any `-D` flag — `cmake --build` alone won't pick it up.

## Notes

Community fork, not affiliated with Laminar Research or the X-Plane Scenery Gateway. Upstream source, license (MIT/X11 for `src/`), and contribution workflow are unchanged — see the [upstream repo](https://github.com/X-Plane/xptools) for those.
