# Building

Fork-specific context (why, what changed) is in [README.md](README.md). This is just environment setup and build steps.

## Environment

Needs command-line CMake and Conan 2 (`pip install "conan>=2,<3"`, then `conan profile detect` once). If configure fails oddly on a dependency, try a current CMake 3.x — some third-party recipes don't like 4.0 yet.

**macOS** — recent Xcode with command-line tools.

**Windows** — Visual Studio 2017+ (Build Tools or Community). `cmake.ps1` targets Visual Studio 17 2022 / x64.

**Linux** — C++20 compiler, CMake, Ninja (or another generator), Conan 2, plus the OpenGL/GLU/X11 dev headers and FLTK/EGL packages Conan pulls in via `conanfile.py`.

## Getting the source

```
git clone https://github.com/X-Plane/xptools.git
```

## Building

`cmake.ps1` / `cmake.sh` run `conan install` for Debug/Release/RelWithDebInfo and generate the CMake project — they don't compile anything themselves.

**Windows**, from the repo root:

```powershell
.\cmake.ps1
```

Flags: `-Clean` (wipe `vs_build` first), `-BuildType Release`, `-ConanProfile default`, `-NoValidation`, `-NoGateway`, `-Verbose`.

Then open `vs_build\xptools.sln`, or build from the command line:

```powershell
cmake --build vs_build --config Release --target WED
```

Binaries land under `vs_build\Release\` (or `Debug\`). Close `WED.exe` first or the linker fails with `LNK1104`.

**Linux/macOS**, from the repo root:

```
./cmake.sh
```

Env vars: `BUILD_DIR` (default `build`), `CONAN_PROFILE` (default `default`), `BUILD_TYPE` (default `Release`), `GENERATOR` (default Xcode on macOS, Ninja on Linux) — or pass a generator as the first arg, e.g. `./cmake.sh Ninja`. Then:

```
cmake --build build --config Release --target WED
```

Other targets: `DDSTool`, `DSFTool`, `ObjView`, `XGrinder`, `OneOffs`.

## Fork flags

`-DWED_NO_VALIDATION=ON` and `-DWED_NO_GATEWAY=ON` (see [README.md](README.md)) must be set at configure time, not build time:

```
cmake -S . -B vs_build -DCMAKE_TOOLCHAIN_FILE=vs_build/build/generators/conan_toolchain.cmake -DWED_NO_VALIDATION=ON -DWED_NO_GATEWAY=ON
```

For a side-by-side setup, point a second build dir (e.g. `vs_build_novalid`) at the same toolchain file with the flags on, so `vs_build` stays a normal validated build and you always know which `WED.exe` you're launching.
