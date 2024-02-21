# Rockchip RK3588 octa core 8/16/32GB RAM SoC NVMe USB3 GbE
BOARD_NAME="Turing RK1"
BOARDFAMILY="rockchip-rk3588"
BOARD_MAINTAINER=""
BOOTCONFIG="turing-rk1-rk3588_defconfig"
KERNEL_TARGET="collabora"
FULL_DESKTOP="yes"

BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3588-turing-rk1.dtb"
BOOT_SOC="rk3588"
BOOT_SCENARIO="spl-blobs"
BOOT_SUPPORT_SPI="yes"
BOOT_SPI_RKSPI_LOADER="yes"

IMAGE_PARTITION_TABLE="gpt"

SRC_CMDLINE="console=ttyS9,115200 console=ttyS2,1500000"
OVERLAY_PREFIX="rk3588"

function post_family_tweaks__turing-rk1() {
    # Create udev audio rules
    echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-hdmi0-sound", ENV{SOUND_DESCRIPTION}="HDMI0 Audio"' > ${chroot_dir}/etc/udev/rules.d/90-naming-audios.rules
    echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-dp0-sound", ENV{SOUND_DESCRIPTION}="DP0 Audio"' >> ${chroot_dir}/etc/udev/rules.d/90-naming-audios.rules

    return 0
}

