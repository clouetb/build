# Rockchip RK3588 octa core 8/16/32GB RAM SoC NVMe USB3 GbE
BOARD_NAME="Turing RK1"
BOARDFAMILY="rockchip-rk3588"
BOARD_MAINTAINER=""
BOOTCONFIG="turing-rk1-rk3588_defconfig"
KERNEL_TARGET="edge,legacy,collabora"
FULL_DESKTOP="yes"

BOOT_LOGO="desktop"
BOOT_FDT_FILE="rockchip/rk3588-turing-rk1.dtb"
BOOT_SOC="rk3588"
BOOT_SCENARIO="spl-blobs"
BOOT_SUPPORT_SPI="yes"
BOOT_SPI_RKSPI_LOADER="yes"
BOOTFS_TYPE="fat"
BOOTSCRIPT="boot-turing-rk1.cmd:boot.cmd"

IMAGE_PARTITION_TABLE="gpt"

DEFAULT_CONSOLE="ttyS9,115200 console=ttyS2,1500000"
OVERLAY_PREFIX="rk3588"

# The u-boot version in use needs pyelftools
function build_host_tools(){
	display_alert "$BOARD_NAME" "Installing required pyelftools" "info"
	pip install pyelftools
}

# Override family config for this board; let's avoid conditionals in family config.
function post_family_config() {
	display_alert "$BOARD" "mainline u-boot overrides" "info"

	BOOTSOURCE="https://github.com/u-boot/u-boot.git" #
	BOOTBRANCH="commit:cb493752394adec8db1d6f5e9b8fb3c43e13f10a" #
	BOOTPATCHDIR="u-boot-turing-rk1"
	BL31_BLOB="rk3588_bl31_v1.38.elf"
	DDR_BLOB="rk3588_ddr_lp4_2112MHz_lp5_2736MHz_uart9_115200_v1.11.bin"

	BOOTDELAY=1 # Wait for UART interrupt to enter UMS/RockUSB mode etc
	UBOOT_TARGET_MAP="BL31=${SRC}/packages/blobs/rockchip/${BL31_BLOB} ROCKCHIP_TPL=${SRC}/packages/blobs/rockchip//${DDR_BLOB};;u-boot-rockchip.bin u-boot-rockchip-spi.bin u-boot.itb idbloader.img idbloader-spi.img"
	unset uboot_custom_postprocess write_uboot_platform write_uboot_platform_mtd # disable stuff from rockchip64_common; we're using binman here which does all the work already

	KERNELSOURCE='https://github.com/Pelochus/linux-rockchip-npu-0.9.6'
	KERNEL_MAJOR_MINOR="6.1" # Major and minor versions of this kernel.
	KERNELBRANCH='branch:rk-6.1-rknpu-0.9.6'
	LINUXCONFIG='linux-rk35xx-vendor'
	KERNEL_DRIVERS_SKIP+=(driver_rtw88)
	# Just use the binman-provided u-boot-rockchip.bin, which is ready-to-go
	function write_uboot_platform() {
		dd if=${1}/u-boot-rockchip.bin of=${2} bs=32k seek=1 conv=fsync
	}

	# Smarter/faster/better to-spi writer using flashcp (hopefully with --partition), using the binman-provided 'u-boot-rockchip-spi.bin'
	function write_uboot_platform_mtd() {
		declare -a extra_opts_flashcp=("--verbose")
		if flashcp -h | grep -q -e '--partition'; then
			echo "Confirmed flashcp supports --partition -- read and write only changed blocks." >&2
			extra_opts_flashcp+=("--partition")
		else
			echo "flashcp does not support --partition, will write full SPI flash blocks." >&2
		fi
		flashcp "${extra_opts_flashcp[@]}" "${1}/u-boot-rockchip-spi.bin" /dev/mtd0
	}

}

function post_family_tweaks() {
    # Create udev audio rules
    echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-hdmi0-sound", ENV{SOUND_DESCRIPTION}="HDMI0 Audio"' > ${chroot_dir}/etc/udev/rules.d/90-naming-audios.rules
    echo 'SUBSYSTEM=="sound", ENV{ID_PATH}=="platform-dp0-sound", ENV{SOUND_DESCRIPTION}="DP0 Audio"' >> ${chroot_dir}/etc/udev/rules.d/90-naming-audios.rules

    return 0
}
