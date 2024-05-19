#!/usr/bin/env bash

# Konfigurasikan 
git config --global user.name "user.build"
          git config --global user.email "user@soulvibe.atlassian.net"
          df -h
          ld --version
          gcc -v
          ar --version
          sudo apt update
          sudo apt install -y bc bison build-essential ccache curl flex glibc-source g++-multilib gcc-multilib binutils-aarch64-linux-gnu git gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev liblz4-tool libncurses5 libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-gtk3-dev libxml2 libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc zip zlib1g-dev python2 tmate ssh neofetch
          neofetch

# Dependencies
if [ ! -d "kernel" ]; then # Cek apakah folder "kernel" sudah ada
  git clone https://github.com/Soulvibe-Stuff/android_kernel_xiaomi_mt6768 -b Paradox-ALMK kernel
fi
cd kernel 

clang() {
    echo "Cloning clang"
    if [ ! -d "clang" ]; then # Cek apakah folder "kernel" sudah ada
        git clone -q https://gitlab.com/PixelOS-Devices/playgroundtc.git --depth=1 -b 17 clang
        KBUILD_COMPILER_STRING="Cosmic clang 17.0"
        PATH="${PWD}/clang/bin:${PATH}"
    fi
    sudo apt install -y ccache
    echo "Done"
}

IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
IMAGE2=$(pwd)/out/arch/arm64/boot/dtbo.img
DATE=$(date +"%Y%m%d-%H%M")
START=$(date +"%s")
KERNEL_DIR=$(pwd)
CACHE=1
token=6410284454:AAFHrE_XZtikh0v8L7IoDVr1RAMuno3LjeI
chat_id=-1002088104319
export token
export chat_id
RELEASE_VER=ALMK
export RELEASE_VER
export CACHE
export KBUILD_COMPILER_STRING
ARCH=arm64
export ARCH
KBUILD_BUILD_HOST="user"
export KBUILD_BUILD_HOST
KBUILD_BUILD_USER="soulvibe-atlassian"
export KBUILD_BUILD_USER
DEVICE="Redmi 9"
export DEVICE
CODENAME="lancelot"
export CODENAME
DEFCONFIG="lancelot_defconfig"
export DEFCONFIG
COMMIT_HASH=$(git rev-parse --short HEAD)
export COMMIT_HASH
PROCS=$(nproc --all)
export PROCS
STATUS=TEST
export STATUS
source "$HOME"/.bashrc && source "$HOME"/.profile
if [[ $CACHE -eq 1 ]]; then
    ccache -M 100G
    export USE_CCACHE=1
fi
LC_ALL=C
export LC_ALL

tg() {
    curl -sX POST https://api.telegram.org/bot"${token}"/sendMessage -d chat_id="${chat_id}" -d parse_mode=Markdown -d disable_web_page_preview=true -d text="$1" &>/dev/null
}

tgs() {
    MD5=$(md5sum "$1" | cut -d' ' -f1)
    curl -fsSL -X POST -F document=@"$1" https://api.telegram.org/bot"${token}"/sendDocument \
        -F "chat_id=${chat_id}" \
        -F "parse_mode=Markdown" \
        -F "caption=$2 | *MD5*: \`$MD5\`"
}

# Send Build Info
sendinfo() {
    tg "
• SOULVIBE BUILDER BOT •

*Building on*: \`Soulvibe Server\`
*Date*: \`${DATE}\`
*Device*: \`${DEVICE} (${CODENAME})\`
*Branch*: \`$(git rev-parse --abbrev-ref HEAD)\`
*Last Commit*: [${COMMIT_HASH}](${REPO}/commit/${COMMIT_HASH})
*Compiler*: \`${KBUILD_COMPILER_STRING}\`
*Build Status*: \`${STATUS}\`"
}

# Push kernel to channel
push() {
    cd AnyKernel || exit 1
    ZIP=$(echo *.zip)
    tgs "${ZIP}" "Build took $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s). | For *${DEVICE} (${CODENAME})* | ${KBUILD_COMPILER_STRING}"
}

# Catch Error
finderr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d sticker="CAACAgIAAxkBAAED3JViAplqY4fom_JEexpe31DcwVZ4ogAC1BAAAiHvsEs7bOVKQsl_OiME" \
        -d text="Build throw an error(s)"
    error_sticker
    exit 1
}

# Compile
compile() {

    if [ -d "out" ]; then
        rm -rf out && mkdir -p out
    fi

    make O=out ARCH="${ARCH}" "${DEFCONFIG}"
    make -j"${PROCS}" O=out \
        ARCH=arm64 \
        LLVM=1 \
        LLVM_IAS=1 \
        AR=llvm-ar \
        NM=llvm-nm \
        LD=ld.lld \
        OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
        CC=clang \
        CROSS_COMPILE=aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=arm-linux-gnueabi

    if ! [ -a "$IMAGE" ]; then
        finderr
        exit 1
    fi

    git clone --depth=1 -b master https://github.com/Soulvibe-Stuff/Anykernel3.git -b lancelot AnyKernel
    cp $(pwd)/out/arch/arm64/boot/Image.gz-dtb AnyKernel
    cp $(pwd/out/arch/arm64/boot/dtbo.img AnyKernel
    cp $(pwd)out/arch/arm64/boot/dtb.img AnyKernel
}
# Zipping
zipping() {
    cd AnyKernel || exit 1
    zip -r9 ParadoX:[Zeus]-"${RELEASE_VER}"-"${CODENAME}"-"${DATE}".zip ./*
    cd ..
}

clang
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$((END - START))
push
