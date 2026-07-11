# WED No-Validation Fork

Fork of [X-Plane/xptools](https://github.com/X-Plane/xptools) adding an optional WorldEditor (WED) build that skips export validation.

## Why

Stock WED refuses to export until an airport passes its full validation pass — draped polygons, taxi network, winding order, dozens of other checks. That's the right call for airports headed to the Gateway, but it also blocks trivial edits (deleting a couple of objects in an old scenery) behind unrelated errors that have nothing to do with the change being made, and there's no built-in way to skip it.

Background: [Why do I always get Validation Errors when editing in WED?](https://forums.x-plane.org/forums/topic/194923-wed-how-to-ignore-deal-with-warnings/)

## What changed

Two CMake options, off by default:

- `WED_NO_VALIDATION=ON` — `WED_ValidateApt` (`src/WEDCore/WED_Validate.cpp`) returns clean immediately, so Validate and pre-export checks stop blocking export.
- `WED_NO_GATEWAY=ON` — removes the Scenery Gateway export target and pack-upload UI (`src/Obj/WED_NoGatewayOverrides.h`). Gateway import still works. Ship this alongside `WED_NO_VALIDATION` so unvalidated exports can't end up on the Gateway.

Also: native OS CA store for libcurl on Windows/macOS (`src/Network/curl_http.cpp`), which fixes the `SSL peer certificate not ok` error Conan's OpenSSL throws when there's no bundled CA file. Plus a couple of `WED_Map` rendering/perf tweaks.

Version string is `2.6.1-no-val` (`src/WEDCore/WED_Version.h`) so builds aren't mistaken for stock WED.

## Building

```powershell
.\cmake.ps1 -BuildType Release -NoValidation -NoGateway
cmake --build vs_build --config Release --target WED
```

Re-run configure after changing any `-D` flag — `cmake --build` alone reuses the old cache. Full environment setup in [Building.md](Building.md).

Not affiliated with Laminar Research or the X-Plane Scenery Gateway. Everything outside the two flags above (source, license, contribution flow) is unchanged from upstream.
