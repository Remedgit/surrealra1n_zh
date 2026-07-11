#!/bin/bash

echo "从Github镜像站下载所需依赖文件"

dist=0


DISTRO="Unsupported"
ARCH="$(uname -m)"

# macOS detection
if [[ "$(uname)" == "Darwin" ]]; then
    DISTRO="macOS"
    if [[ "$ARCH" == "arm64" ]]; then
        echo "你正在Apple芯片的Mac上运行本脚本"
        dist=3
        echo
    elif [[ "$ARCH" == "x86_64" ]]; then
        echo "你正在Intel芯片的Mac上运行本脚本"
        dist=4
        echo
    fi
# Linux detection
elif [[ -r /etc/os-release ]]; then
    . /etc/os-release

    if [[ "$ID" == "arch" || "${ID_LIKE:-}" == *arch* ]]; then
        DISTRO="Arch"
        dist=2
    elif [[ "$ID" == "debian" || "${ID_LIKE:-}" == *debian* ]]; then
        DISTRO="Debian"
        dist=1
        read -n 1 -s -r -p "Press any key to continue"
    elif [[ "$ID" == "fedora" || "${ID_LIKE:-}" == *fedora* || "${ID_LIKE:-}" == *rhel* ]]; then
        DISTRO="Fedora"
        dist=5
        read -n 1 -s -r -p "Press any key to continue"
    # generic Linux fallback
    elif command -v apt-get &>/dev/null; then
        DISTRO="Debian"
        dist=1
        echo "Unrecognized distro; treating as Debian-based (apt-get detected)."
        read -n 1 -s -r -p "Press any key to continue"
    elif command -v pacman &>/dev/null; then
        DISTRO="Arch"
        dist=2
        echo "Unrecognized distro; treating as Arch-based (pacman detected)."
    elif command -v dnf &>/dev/null; then
        DISTRO="Fedora"
        dist=5
        echo "Unrecognized distro; treating as Fedora-based (dnf detected)."
        read -n 1 -s -r -p "Press any key to continue"
    elif command -v zypper &>/dev/null; then
        DISTRO="Fedora"
        dist=5
        echo "Unrecognized distro; treating as Fedora-based (zypper detected, using dnf flow)."
        read -n 1 -s -r -p "Press any key to continue"
    fi
fi

if [[ $dist == 3 || $dist == 4 ]]; then
    # prevent finder from annoying you
    killall -STOP AMPDevicesAgent AMPDeviceDiscoveryAgent MobileDeviceUpdater 2>/dev/null
fi

# Run macOS version check only if you're on macOS, should fix Linux
if [[ $dist == 3 || $dist == 4 ]]; then
    macmodel=$(sysctl -n hw.model) 

    # Outdated macOS ver check
    macos_ver=$(sw_vers -productVersion) 
fi

if [[ $dist == 3 || $dist == 4 ]]; then
    if [[ "$(printf '%s\n' "10.15" "$macos_ver" | sort -V | head -n1)" == "10.15" ]]; then
        echo "你的 macOS 版本 $macos_ver 受支持"
    else
        echo "surrealra1n 只支持10.15及以后的macOS"
        exit 1
    fi
fi

if [[ $dist == 3 || $dist == 4 ]]; then
    # Check for Xcode Command Line Tools
    if ! xcode-select -p &>/dev/null; then
        echo "Xcode Command Line Tools are not installed. Installing..."
        xcode-select --install
        echo "Please re-run surrealra1n after the installation completes."
        exit 1
    else
        echo "Xcode Command Line Tools 已安装"
    fi

    # Check for Homebrew
    if ! command -v brew &>/dev/null; then
        echo "[!] Homebrew 未安装. 你需要先安装 Homebrew https://brew.sh"
        exit 1
    else
        echo "Homebrew 已安装."
    fi

    # Check for missing brew dependencies
    BREW_DEPS=("libimobiledevice" "libirecovery" "binutils")
    for dep in "${BREW_DEPS[@]}"; do
        if ! brew list "$dep" &>/dev/null; then
            echo "[$dep] 未安装，正在安装"
            brew install "$dep"
        else
            echo "[$dep] 已安装"
        fi
    done
fi

# Check for Rosetta 2 (Apple Silicon only)
if [[ $dist == 3 ]]; then
    if ! /usr/bin/pgrep -q oahd; then
        echo "Rosetta 2 未安装，正在安装"
        softwareupdate --install-rosetta --agree-to-license
    else
        echo "Rosetta 2 已安装"
    fi
fi

# Unsupported check
if [[ "$DISTRO" == "Unsupported" ]]; then
    echo "Unsupported Linux distribution."
    echo "Could not detect a compatible package manager (apt-get, pacman, dnf, or zypper)."
    echo "This script only supports Debian-based, Arch-based, Fedora-based and macOS systems."
    exit 1
fi

echo "当前系统: $DISTRO"

if [[ $dist == 3 || $dist == 4 ]]; then
    zenity="./bin/zenity"
else
    zenity="zenity"
fi

# Check if all required binaries exist
if [[ -f "./bin/img4" && \
      -f "./bin/img4tool" && \
      -f "./bin/irecovery" && \
      -f "./bin/kairos" && \
      -f "./bin/kerneldiff" && \
      -f "./bin/KPlooshFinder" && \
      -f "./bin/gaster" && \
      -f "./bin/Kernel64Patcher" && \
      -f "./bin/Kernel64Patcher2" && \
      -f "./bin/dmg" && \
      -f "./bin/pzb" && \
      -f "./bin/zenity" && \
      -f "./bin/iBoot64Patcher" && \
      -f "./bin/asr64_patcher" && \
      -f "./bin/ipx_restored_patcher" && \
      -f "./bin/restored_external64_patcher" && \
      -f "./bin/restoredpatcher" && \
      -f "./bin/hfsplus" && \
      -f "./bin/tsschecker" && \
      -f "./bin/ipatcher" && \
      -f "./bin/iproxy" && \
      -f "./bin/dtree_patcher" && \
      -f "./bin/sshpass" && \
      -f "./bin/dsc64patcher" && \
      -f "./bin/idevicerestore" && \
      -f "./bin/ldid" && \
      -f "./activate.sh" && \
      -f "./backup.sh" && \
      -f "./futurerestore/futurerestore" ]]; then
    echo "所需文件齐全."
elif [[ $dist == 3 ]]; then
    echo "bin文件不齐全"
    echo "即将从Github下载"

    mkdir -p bin futurerestore

    curl -L -o bin/img4 https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/img4
    curl -L -o bin/img4tool https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/img4tool
    curl -L -o bin/pzb https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/pzb
    curl -L -o bin/KPlooshFinder https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/KPlooshFinder
    curl -L -o bin/dsc64patcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/dsc64patcher
    curl -L -o bin/kerneldiff https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/kerneldiff
    curl -L -o bin/dtree_patcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/dtree_patcher
    curl -L -o bin/irecovery https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/irecovery
    curl -L -o bin/iBoot64Patcher https://gh-proxy.com/https://github.com/edwin170/downr1n/raw/refs/heads/main/binaries/Darwin/iBoot64Patcher
    curl -L -o bin/Kernel64Patcher2 https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/Kernel64Patcher
    curl -L -o bin/hfsplus https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/hfsplus
    curl -L -o bin/zenity https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/zenity
    # iboot patcher oops
    curl -L -o ibootpatch.c https://gist.githubusercontent.com/pwnerblu/c759c0060b5167a411b3b3adfcd07572/raw/fd2e870d832ea59c31a54377370ad469f70e6499/patch.c
    gcc ibootpatch.c -o bin/iBootPatch
    rm -rf ibootpatch.c
    # from spironolactone oops
    curl -L -o bin/trustcache https://gh-proxy.com/https://github.com/Orangera1n/spironolactone/raw/refs/heads/main/Darwin/trustcache
    # sshpass
    curl -L -o bin/sshpass https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/sshpass
    curl -L -o bin/iproxy https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/iproxy
    curl -L -o bin/dmg https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/dmg
    curl -L -o bin/ipatcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/iPatcher
    # install additional restored_external patcher (iPhone X only)
    curl -L -o bin/ipx_restored_patcher https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/arm64/ipx_restored_patcher
    # restored patcher for seprmvr64 A8+ restores, my fork of mineek's restored patcher but repurposed
    curl -L -o main.c https://gist.githubusercontent.com/pwnerblu/d2adc5adee74a679704577ddd64508bf/raw/991a74e2bbbdebdb1dd2d49d82f0829e7553f02f/main.c
    gcc main.c -o bin/restoredpatcher
    rm -rf main.c
    # install asr patcher for tethered restores
    git clone https://gh-proxy.com/https://github.com/iSuns9/asr64_patcher --recursive
    cd asr64_patcher
    make
    mv asr64_patcher ../bin/asr64_patcher
    cd ..
    rm -rf "asr64_patcher"
    # install restored_external patcher for tethered restores to iOS 14+
    git clone https://gh-proxy.com/https://github.com/iSuns9/restored_external64patcher --recursive
    cd restored_external64patcher
    make
    mv restored_external64_patcher ../bin/restored_external64_patcher
    cd ..
    rm -rf "restored_external64patcher"
    # install libimg4 patcher for tethered restores to iOS 14/15, primarily convert to localboot
    git clone https://gh-proxy.com/https://github.com/iSuns9/libimg4_patcher --recursive
    cd libimg4_patcher
    make
    mv libimg4_patcher ../bin/libimg4_patcher
    cd ..
    rm -rf "libimg4_patcher"
    # the favor goes to openra1n by Mineek (pongoOS on unsigned bootchains), uses Nick Chan fork of openra1n
    git clone https://gh-proxy.com/https://github.com/asdfugil/openra1n -b ipad6
    cd openra1n
    curl -L -o Makefile https://gh-proxy.com/https://github.com/mineek/openra1n/raw/refs/heads/sigcheck/Makefile
    make || true
    mv openra1n ../bin/openra1n || true
    cd ..
    rm -rf "openra1n"
    # palera1n macOS bin
    curl -L -o bin/palera1n https://gh-proxy.com/https://github.com/palera1n/palera1n/releases/download/v2.2.1/palera1n-macos-universal
    # install Kernel64Patcher for tether booting iOS 13+
    curl -L -o bin/Kernel64Patcher https://gh-proxy.com/https://github.com/edwin170/downr1n/raw/refs/heads/main/binaries/Darwin/Kernel64Patcher
    # fetch pwnerblu fork of Kernel64Patcher and iBootpatch2 for tether booting iOS 14.x on A12 device.
    git clone https://gh-proxy.com/https://github.com/pwnerblu/Kernel64Patcher --recursive
    cd Kernel64Patcher
    make
    cp Kernel64Patcher ../bin/Kernel64Patcher3
    cd ..
    rm -rf "Kernel64Patcher"
    git clone https://gh-proxy.com/https://github.com/pwnerblu/iBootpatch2 -b ipad6
    cd iBootpatch2
    make
    cp iBootpatch2 ../bin/iBootpatch2
    cd ..
    rm -rf "iBootpatch2"
    # done!
    curl -L -o bin/gaster https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/gaster
    curl -L -o bin/tsschecker https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/tsschecker
    curl -L -o bin/ldid https://gh-proxy.com/https://github.com/ProcursusTeam/ldid/releases/download/v2.1.5-procursus7/ldid_macosx_arm64
    curl -L -o bin/kairos https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/kairos
    # download activate.sh and backup.sh from hiylx's eclipsera1n, for backing up and restoring iOS 16+ activation files on 14.0-15.7(.2)
    curl -L -o activate.sh https://gh-proxy.com/https://github.com/hiylx/eclipsera1n/raw/refs/heads/main/activate.sh
    curl -L -o backup.sh https://gh-proxy.com/https://github.com/hiylx/eclipsera1n/raw/refs/heads/main/backup.sh
    curl -L -o futurerestore/futurerestore.zip https://gh-proxy.com/https://github.com/LukeeGD/futurerestore/releases/download/latest/futurerestore-macOS-RELEASE-main.zip
    # fetch idevicerestore for 7.0-9.3.5 restores 
    curl -L -o bin/idevicerestore https://gh-proxy.com/https://github.com/NyanSatan/SundanceInH2A/raw/refs/heads/master/executables/Darwin/idevicerestore
    # libs
    chmod +x bin/*
    chmod +x *.sh

    cd futurerestore || exit
    unzip -o futurerestore.zip
    tar -xf futurerestore-macOS-v2.0.0-Build_329-RELEASE.tar.xz
    cp futurerestore-macOS-v2.0.0-Build_329-RELEASE/* . || true
    chmod +x futurerestore
    rm -rf *.tar.xz
    rm -rf *.sh
    rm -rf *.zip
    rm -rf "futurerestore-macOS-v2.0.0-Build_329-RELEASE" 
    cd ..
    xattr -c bin/*
    xattr -c futurerestore/futurerestore
elif [[ $dist == 4 ]]; then
    echo "Binaries do not exist"
    echo "Downloading binaries..."

    mkdir -p bin futurerestore

    curl -L -o bin/img4 https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/img4
    curl -L -o bin/img4tool https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/img4tool
    curl -L -o bin/pzb https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/pzb
    curl -L -o bin/KPlooshFinder https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/KPlooshFinder
    curl -L -o bin/dsc64patcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/dsc64patcher
    curl -L -o bin/kerneldiff https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/kerneldiff
    curl -L -o bin/dtree_patcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/dtree_patcher
    curl -L -o bin/irecovery https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/irecovery
    curl -L -o bin/iBoot64Patcher https://gh-proxy.com/https://github.com/edwin170/downr1n/raw/refs/heads/main/binaries/Darwin/iBoot64Patcher
    curl -L -o bin/Kernel64Patcher2 https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/Kernel64Patcher
    curl -L -o bin/hfsplus https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/hfsplus
    curl -L -o bin/zenity https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/zenity
    # iboot patcher oops
    curl -L -o ibootpatch.c https://gist.githubusercontent.com/pwnerblu/c759c0060b5167a411b3b3adfcd07572/raw/fd2e870d832ea59c31a54377370ad469f70e6499/patch.c
    gcc ibootpatch.c -o bin/iBootPatch
    rm -rf ibootpatch.c
    # from spironolactone oops
    curl -L -o bin/trustcache https://gh-proxy.com/https://github.com/Orangera1n/spironolactone/raw/refs/heads/main/Darwin/trustcache
    # sshpass
    curl -L -o bin/sshpass https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/sshpass
    curl -L -o bin/iproxy https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/iproxy
    curl -L -o bin/dmg https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/dmg
    curl -L -o bin/ipatcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/iPatcher
    # install additional restored_external patcher (iPhone X only)
    curl -L -o bin/ipx_restored_patcher https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/ipx_restored_patcher
    # palera1n macOS bin
    curl -L -o bin/palera1n https://gh-proxy.com/https://github.com/palera1n/palera1n/releases/download/v2.2.1/palera1n-macos-universal
    # the favor goes to openra1n by Mineek (pongoOS on unsigned bootchains), uses Nick Chan fork of openra1n
    git clone https://gh-proxy.com/https://github.com/asdfugil/openra1n -b ipad6
    cd openra1n
    curl -L -o Makefile https://gh-proxy.com/https://github.com/mineek/openra1n/raw/refs/heads/sigcheck/Makefile
    make OBJCOPY=$(brew --prefix)/opt/binutils/bin/gobjcopy || true
    mv openra1n ../bin/openra1n || true
    cd ..
    rm -rf "openra1n" 
    # restored patcher for seprmvr64 A8+ restores, my fork of mineek's restored patcher but repurposed
    curl -L -o main.c https://gist.githubusercontent.com/pwnerblu/d2adc5adee74a679704577ddd64508bf/raw/991a74e2bbbdebdb1dd2d49d82f0829e7553f02f/main.c
    gcc main.c -o bin/restoredpatcher
    rm -rf main.c
    # install asr patcher for tethered restores
    git clone https://gh-proxy.com/https://github.com/iSuns9/asr64_patcher --recursive
    cd asr64_patcher
    make
    mv asr64_patcher ../bin/asr64_patcher
    cd ..
    rm -rf "asr64_patcher"
    # install restored_external patcher for tethered restores to iOS 14+
    git clone https://gh-proxy.com/https://github.com/iSuns9/restored_external64patcher --recursive
    cd restored_external64patcher
    make
    mv restored_external64_patcher ../bin/restored_external64_patcher
    cd ..
    rm -rf "restored_external64patcher"
    # install libimg4 patcher for tethered restores to iOS 14/15, primarily convert to localboot
    git clone https://gh-proxy.com/https://github.com/iSuns9/libimg4_patcher --recursive
    cd libimg4_patcher
    make
    mv libimg4_patcher ../bin/libimg4_patcher
    cd ..
    rm -rf "libimg4_patcher"
    # install Kernel64Patcher for tether booting iOS 13+
    curl -L -o bin/Kernel64Patcher https://gh-proxy.com/https://github.com/edwin170/downr1n/raw/refs/heads/main/binaries/Darwin/Kernel64Patcher
    # fetch pwnerblu fork of Kernel64Patcher and iBootpatch2 for tether booting iOS 14.x on A12 device.
    git clone https://gh-proxy.com/https://github.com/pwnerblu/Kernel64Patcher --recursive
    cd Kernel64Patcher
    make
    cp Kernel64Patcher ../bin/Kernel64Patcher3
    cd ..
    rm -rf "Kernel64Patcher"
    git clone https://gh-proxy.com/https://github.com/pwnerblu/iBootpatch2 -b ipad6
    cd iBootpatch2
    make
    cp iBootpatch2 ../bin/iBootpatch2
    cd ..
    rm -rf "iBootpatch2"
    # done!
    curl -L -o bin/gaster https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/gaster
    curl -L -o bin/tsschecker https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/macos/tsschecker
    curl -L -o bin/ldid https://gh-proxy.com/https://github.com/ProcursusTeam/ldid/releases/download/v2.1.5-procursus7/ldid_macosx_x86_64
    curl -L -o bin/kairos https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Darwin/kairos
    # download activate.sh and backup.sh from hiylx's eclipsera1n, for backing up and restoring iOS 16+ activation files on 14.0-15.7(.2)
    curl -L -o activate.sh https://gh-proxy.com/https://github.com/hiylx/eclipsera1n/raw/refs/heads/main/activate.sh
    curl -L -o backup.sh https://gh-proxy.com/https://github.com/hiylx/eclipsera1n/raw/refs/heads/main/backup.sh
    curl -L -o futurerestore/futurerestore.zip https://gh-proxy.com/https://github.com/LukeeGD/futurerestore/releases/download/latest/futurerestore-macOS-RELEASE-main.zip
    # fetch idevicerestore for 7.0-9.3.5 restores 
    curl -L -o bin/idevicerestore https://gh-proxy.com/https://github.com/NyanSatan/SundanceInH2A/raw/refs/heads/master/executables/Darwin/idevicerestore
    # libs
    chmod +x bin/*
    chmod +x *.sh

    cd futurerestore || exit
    unzip -o futurerestore.zip
    tar -xf futurerestore-macOS-v2.0.0-Build_329-RELEASE.tar.xz
    cp futurerestore-macOS-v2.0.0-Build_329-RELEASE/* . || true
    chmod +x futurerestore
    rm -rf *.tar.xz
    rm -rf *.sh
    rm -rf *.zip
    rm -rf "futurerestore-macOS-v2.0.0-Build_329-RELEASE" 
    cd ..
    xattr -c bin/*
    xattr -c futurerestore/futurerestore
else
    echo "Binaries do not exist"
    echo "Downloading binaries..."

    mkdir -p bin futurerestore

    curl -L -o bin/img4 https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/img4
    curl -L -o bin/img4tool https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/img4tool
    curl -L -o bin/KPlooshFinder https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/KPlooshFinder
    curl -L -o bin/pzb https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/pzb
    curl -L -o bin/dsc64patcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/dsc64patcher
    curl -L -o bin/kerneldiff https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/kerneldiff
    curl -L -o bin/dtree_patcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/dtree_patcher
    curl -L -o bin/irecovery https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/irecovery
    curl -L -o bin/iBoot64Patcher https://gh-proxy.com/https://github.com/edwin170/downr1n/raw/refs/heads/main/binaries/Linux/iBoot64Patcher
    curl -L -o bin/Kernel64Patcher2 https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/Kernel64Patcher
    curl -L -o bin/hfsplus https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/hfsplus
    # sshpass
    curl -L -o bin/sshpass https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/sshpass
    curl -L -o bin/iproxy https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/iproxy
    curl -L -o bin/zenity https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/zenity
    curl -L -o bin/dmg https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/dmg
    curl -L -o bin/ipatcher https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/ipatcher
    # install additional restored_external patcher (iPhone X only)
    curl -L -o bin/ipx_restored_patcher https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/ipx_restored_patcher
    # restored patcher for seprmvr64 A8+ restores, my fork of mineek's restored patcher but repurposed
    curl -L -o main.c https://gist.githubusercontent.com/pwnerblu/d2adc5adee74a679704577ddd64508bf/raw/991a74e2bbbdebdb1dd2d49d82f0829e7553f02f/main.c
    gcc main.c -o bin/restoredpatcher
    rm -rf main.c
    # install asr patcher for tethered restores
    git clone https://gh-proxy.com/https://github.com/iSuns9/asr64_patcher --recursive
    cd asr64_patcher
    make
    mv asr64_patcher ../bin/asr64_patcher
    cd ..
    rm -rf "asr64_patcher"
    # install restored_external patcher for tethered restores to iOS 14+
    git clone https://gh-proxy.com/https://github.com/iSuns9/restored_external64patcher --recursive
    cd restored_external64patcher
    make
    mv restored_external64_patcher ../bin/restored_external64_patcher
    cd ..
    rm -rf "restored_external64patcher"
    # install libimg4 patcher for tethered restores to iOS 14/15, primarily convert to localboot
    git clone https://gh-proxy.com/https://github.com/iSuns9/libimg4_patcher --recursive
    cd libimg4_patcher
    make
    mv libimg4_patcher ../bin/libimg4_patcher
    cd ..
    rm -rf "libimg4_patcher"
    # install Kernel64Patcher for tether booting iOS 13+
    curl -L -o bin/Kernel64Patcher https://gh-proxy.com/https://github.com/edwin170/downr1n/raw/refs/heads/main/binaries/Linux/Kernel64Patcher
    curl -L -o bin/gaster https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/gaster
    curl -L -o bin/tsschecker https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/tsschecker
    curl -L -o bin/ldid https://gh-proxy.com/https://github.com/ProcursusTeam/ldid/releases/download/v2.1.5-procursus7/ldid_linux_x86_64
    curl -L -o bin/kairos https://gh-proxy.com/https://github.com/LukeZGD/Semaphorin/raw/refs/heads/main/Linux/kairos
    # download activate.sh and backup.sh from hiylx's eclipsera1n, for backing up and restoring iOS 16+ activation files on 14.0-15.7(.2)
    curl -L -o activate.sh https://gh-proxy.com/https://github.com/hiylx/eclipsera1n/raw/refs/heads/main/activate.sh
    curl -L -o backup.sh https://gh-proxy.com/https://github.com/hiylx/eclipsera1n/raw/refs/heads/main/backup.sh
    curl -L -o futurerestore/futurerestore.zip https://gh-proxy.com/https://github.com/LukeeGD/futurerestore/releases/download/latest/futurerestore-Linux-x86_64-RELEASE-main.zip
    # fetch idevicerestore for 7.0-9.3.5 restores 
    curl -L -o bin/idevicerestore https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/idevicerestore2
    # libs
    rm -rf "lib"
    mkdir lib
    curl -L -o lib/libcrypto.so.35 https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/lib/libcrypto.so.35
    curl -L -o lib/libssl.so.35 https://gh-proxy.com/https://github.com/LukeZGD/Legacy-iOS-Kit/raw/refs/heads/main/bin/linux/x86_64/lib/libssl.so.35
    chmod +x bin/*
    chmod +x *.sh

    cd futurerestore || exit
    unzip -o futurerestore.zip
    tar -xf futurerestore-Linux-x86_64-v2.0.0-Build_329-RELEASE.tar.xz
    cp futurerestore-Linux-x86_64-v2.0.0-Build_329-RELEASE/* . || true
    chmod +x linux_fix.sh || true
    sudo ./linux_fix.sh || true
    rm -rf linux_fix.sh || true
    chmod +x futurerestore
    rm -rf *.tar.xz || true
    rm -rf *.sh || true
    rm -rf *.zip || true
    rm -rf "futurerestore-Linux-x86_64-v2.0.0-Build_329-RELEASE" 
    cd ..
fi

echo "检查usbliter8ctl所需的依赖"
# Check required packages
PACKAGES=("pyusb")
for pkg in "${PACKAGES[@]}"; do
    if pip3 show "$pkg" &>/dev/null; then
        version=$(pip3 show "$pkg" | grep Version | awk '{print $2}')
        echo "$pkg: $version"
    else
        echo "$pkg not installed"
        echo "Running: pip3 install $pkg"
        if pip3 install "$pkg" 2>&1 | grep -q "externally-managed"; then
            echo "Externally managed environment detected, retrying with --break-system-packages"
            pip3 install "$pkg" --break-system-packages
        fi
    fi
done
