#!/bin/bash
set -e

OSU_GIT="https://github.com/ppy/osu"
OSU_GIT_BRANCH="2024.906.2" # Replace with the latest version
BASS_URL="https://www.un4seen.com/files/bass24-linux.zip"
BASS_FX_URL="https://www.un4seen.com/files/z/0/bass_fx24-linux.zip"
BASSMIX_URL="https://www.un4seen.com/files/bassmix24-linux.zip"
VELDRID_SPIRV_GIT="https://github.com/veldrid/veldrid-spirv.git"

error() {
    echo -e "\033[0;31mERROR: $@" 1>&2
    exit 1
}

warn() {
    echo -e "\033[0;33m$@\033[0m"
}

info() {
    echo -e "\033[0;34m$@\033[0m"
}

if [[ $EUID -eq 0 ]]; then
    error "This script must not be run as root"
fi

if [ "$(uname -m)" != "aarch64" ]; then
    error "This script is meant or ARM64 devices. If you're on x86_64, just use the official builds please."
fi

info "osu! Asahi Installer\n"

if [ -f /etc/fedora-release ]; then
    info "Installing packages..."
    sudo dnf install dotnet-sdk-8.0 SDL2-devel cmake python3
else
    warn "Not using Fedora, skipping package installation. Please install these packages manually: dotnet-sdk-8.0 SDL2-dev cmake python3"
    echo "Press enter to continue..."
    read
fi

mkdir -p /tmp/osu-asahi
cd /tmp/osu-asahi

info "Cloning osu!..."
if ! [ -d /tmp/osu-asahi/osu ]; then
    git clone $OSU_GIT --branch $OSU_GIT_BRANCH /tmp/osu-asahi/osu
else
    warn "Using existing clone at /tmp/osu-asahi/osu"
fi

info "Building osu!..."
cd /tmp/osu-asahi/osu
git checkout $OSU_GIT_BRANCH
git submodule update --init --recursive
git pull origin $OSU_GIT_BRANCH

killall -KILL dotnet || true
DOTNET_CLI_TELEMETRY_OPTOUT="1" dotnet publish osu.Desktop \
    --configuration Release \
    --use-current-runtime \
    --output ~/.local/share/osu-asahi \
    /property:Version="$OSU_GIT_BRANCH"

info "Downloading/cloning dependencies..."
curl -s $BASS_URL -o /tmp/osu-asahi/bass.zip
curl -s $BASS_FX_URL -o /tmp/osu-asahi/bass_fx.zip
curl -s $BASSMIX_URL -o /tmp/osu-asahi/bassmix.zip

if ! [ -d /tmp/osu-asahi/veldrid-spirv ]; then
    git clone --recurse-submodules $VELDRID_SPIRV_GIT /tmp/osu-asahi/veldrid-spirv
else
    warn "Using existing clone at /tmp/osu-asahi/veldrid-spirv"
fi

cd /tmp/osu-asahi/veldrid-spirv
sed -i '37s/.*/std::wint_t IDs[2];/' src/libveldrid-spirv/libveldrid-spirv.cpp
./ext/sync-shaderc.sh

info "Building dependencies..."
sed -i 's/_CMakeExtraBuildArgs=.*/_CMakeExtraBuildArgs="-j$(getconf _NPROCESSORS_ONLN)"/g' ./build-native.sh # Use all the cores
./build-native.sh -release linux-x64

info "Installing dependencies..."
cp build/Release/linux-x64/libveldrid-spirv.so ~/.local/share/osu-asahi/libveldrid-spirv.so
rm -rf /tmp/osu-asahi/{bass,bass_fx,bassmix}
unzip /tmp/osu-asahi/bass.zip -d /tmp/osu-asahi/bass
unzip /tmp/osu-asahi/bass_fx.zip -d /tmp/osu-asahi/bass_fx
unzip /tmp/osu-asahi/bassmix.zip -d /tmp/osu-asahi/bassmix
cp /tmp/osu-asahi/bass/libs/aarch64/libbass.so ~/.local/share/osu-asahi/libbass.so
cp /tmp/osu-asahi/bass_fx/libs/aarch64/libbass_fx.so ~/.local/share/osu-asahi/libbass_fx.so
cp /tmp/osu-asahi/bassmix/libs/aarch64/libbassmix.so ~/.local/share/osu-asahi/libbassmix.so

info "Installing osu!..."

# Add .desktop file
cat <<EOF >$HOME/.local/share/applications/osu-asahi.desktop
[Desktop Entry]
Name=osu!
Comment=rhythm is just a *click* away!
Exec=${HOME}/.local/bin/osu
Icon=${HOME}/.local/share/osu-asahi/lazer.ico
Terminal=false
Type=Application
Categories=Game;ActionGame
MimeType=x-scheme-handler/osu
PrefersNonDefaultGPU=true
X-KDE-RunOnDiscreteGpu=true
EOF

if ! [ -L $HOME/.local/bin/osu ]; then
    ln -s $HOME/.local/share/osu-asahi/osu\! ~/.local/bin/osu
fi

echo ""
echo -e "\033[0;32mDone, you can now launch osu! from your application launcher or using the 'osu' command\033[0m"