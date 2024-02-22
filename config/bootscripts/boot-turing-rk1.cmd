# This is a boot script for U-Boot
#
# Recompile with:
# mkimage -A arm64 -O linux -T script -C none -n "Boot Script" -d boot.cmd boot.scr

setenv load_addr "0x7000000"
setenv overlay_error "false"

echo "Boot script loaded from ${devtype} ${devnum}"

if test -e ${devtype} ${devnum}:${distro_bootpart} /armbianEnv.txt; then
	load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} /armbianEnv.txt
	env import -t ${load_addr} ${filesize}
fi

load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} /dtb/rockchip/${fdtfile}
fdt addr ${fdt_addr_r} && fdt resize 0x10000

for overlay_file in ${overlays}; do
    for file in "${overlay_prefix}-${overlay_file}.dtbo ${overlay_prefix}-${overlay_file} ${overlay_file}.dtbo ${overlay_file}"; do
        test -e ${devtype} ${devnum}:${distro_bootpart} /dtb/rockchip/overlay/${file} \
        && load ${devtype} ${devnum}:${distro_bootpart} ${fdtoverlay_addr_r} /dtb/rockchip/overlay/${file} \
        && echo "Applying device tree overlay: /dtb/rockchip/overlay/${file}" \
        && fdt apply ${fdtoverlay_addr_r} || setenv overlay_error "true"
    done
done
if test "${overlay_error}" = "true"; then
    echo "Error applying device tree overlays, restoring original device tree"
    load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} /dtbs/rockchip/${fdtfile}
fi

load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} /Image
load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} /uInitrd

booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}