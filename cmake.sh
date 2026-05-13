#!/usr/bin/env bash
set -euo pipefail

# Conan 2 + CMake setup (same flow as cmake.ps1 on Windows).
# Run from the repository root. This installs dependencies and generates
# build files; run cmake --build afterward (see Building.md).

BUILD_DIR="${BUILD_DIR:-build}"
CONAN_PROFILE="${CONAN_PROFILE:-default}"
BUILD_TYPE="${BUILD_TYPE:-Release}"

OS_NAME="$(uname -s)"
if [[ "$OS_NAME" == "Darwin" ]]; then
	DEFAULT_GENERATOR="Xcode"
elif [[ "$OS_NAME" == "Linux" ]]; then
	DEFAULT_GENERATOR="Ninja"
else
	echo "Unsupported OS: $OS_NAME" >&2
	exit 1
fi

GENERATOR="${GENERATOR:-${1:-$DEFAULT_GENERATOR}}"

command -v conan >/dev/null 2>&1 || { echo "Install Conan 2 (e.g. pip install 'conan>=2,<3') and ensure 'conan' is on PATH." >&2; exit 1; }
command -v cmake >/dev/null 2>&1 || { echo "Install CMake and ensure 'cmake' is on PATH." >&2; exit 1; }

echo "Using CMake generator: $GENERATOR"

mkdir -p "${BUILD_DIR}"
pushd "${BUILD_DIR}" >/dev/null

for bt in Debug Release RelWithDebInfo; do
	echo "Installing Conan dependencies (build_type=${bt})..."
	conan install .. \
		--build=missing \
		--profile:build="${CONAN_PROFILE}" \
		--profile:host="${CONAN_PROFILE}" \
		-s "build_type=${bt}" \
		--output-folder=.
done

if [[ ! -f build/generators/conan_toolchain.cmake ]]; then
	echo "Expected Conan toolchain at ${BUILD_DIR}/build/generators/conan_toolchain.cmake" >&2
	exit 1
fi

echo "Configuring CMake in ${BUILD_DIR}..."
cmake .. \
	-G "${GENERATOR}" \
	"-DCMAKE_BUILD_TYPE=${BUILD_TYPE}" \
	-DCMAKE_TOOLCHAIN_FILE=build/generators/conan_toolchain.cmake

popd >/dev/null

echo "Done. Build with:"
echo "  cmake --build ${BUILD_DIR} --config ${BUILD_TYPE}"
echo "(Use --config for multi-config generators like Xcode or Visual Studio.)"
