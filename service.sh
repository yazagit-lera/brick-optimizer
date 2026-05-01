MODDIR="${0%/*}"

best_sysctl_value() {
  local key="${1}"
  local values="${2}"

  local value
  for value in ${values}; do
    sysctl -qw "${key}=${value}"
  done
}

best_zram_alg() {
  local sys_zram="${1}"
  local mem="${2}"

  local alg_file="${sys_zram}/comp_algorithm"
  if [[ "${mem}" < 6442450944 ]] && grep -qw 'zstd' "${alg_file}"; then
    echo 'zstd' > "${alg_file}"
    sysctl -qw vm.page-cluster=0
  else
    local alg
    for alg in lzo lzo-rle lz4; do
      echo "${alg}" > "${alg_file}"
    done
    sysctl -qw vm.page-cluster=1
  fi
}

set_zram_size() {
  local sys_zram="${1}"
  local mem="${2}"

  local half_mem="$((mem/2))"
  local zram_size="$((mem + half_mem))"
  local max_zram_size=8589934592
  [[ "${zram_size}" -gt "${max_zram_size}" ]] && zram_size="${max_zram_size}"
  echo "${zram_size}" > "${sys_zram}/disksize"
}

disable_zram() {
  local sys_zram="${1}"
  local dev_zram="${2}"

  swapoff "${dev_zram}"
  echo 1 > "${sys_zram}/reset"
}

enable_zram() {
  local dev_zram="${1}"

  mkswap "${dev_zram}"
  swapon "${dev_zram}"
}

create_zram_if_missing() {
  local dev_zram="${1}"

  [[ ! -b "${dev_zram}" ]] && cat /sys/class/zram-control/hot_add > /dev/null
}

setup_zram() {
  local dev_zram='/dev/block/zram0'
  local sys_zram='/sys/block/zram0'
  create_zram_if_missing "${dev_zram}"
  disable_zram "${sys_zram}" "${dev_zram}"
  local mem
  mem="$(free -b | awk '/^Mem:./ {print $2}')"
  best_zram_alg "${sys_zram}" "${mem}"
  set_zram_size "${sys_zram}" "${mem}"
  echo 'N' > /sys/module/zswap/parameters/enabled
  echo 1 > /sys/kernel/mm/swap/vma_ra_enabled
  enable_zram "${dev_zram}"
}

setup_dev() {
  local dev
  for dev in /sys/block/*/queue; do
    local scheduler="${dev}/scheduler"
    echo 'noop' > "${scheduler}"
    echo 'none' > "${scheduler}"
    echo 512 > "${dev}/read_ahead_kb"
    echo 128 > "${dev}/nr_requests"
    echo 2 > "${dev}/rq_affinity"
    echo 0 > "${dev}/rotational"
    echo 1 > "${dev}/add_random"
    echo 0 > "${dev}/nomerges"
    echo 1 > "${dev}/iostats"
  done
}

setup_network() {
  best_sysctl_value net.ipv4.tcp_available_congestion_control 'cubic bbr'
  best_sysctl_value net.core.default_qdisc 'sfq fq fq_codel cake'
}

set_mount_options() {
  local options
  options='remount,noatime,nodiscard,nobarrier,fsync_mode=nobarrier,lazytime'
  options="${options},atgc,flush_merge,checkpoint_merge,active_logs=6,rw"
  mount -o "${options}" /data
}

clear_disk() {
  cmd package art cleanup
  cmd package trim-caches 64G
  rm -rf -- /data/media/0/Android/data/*/cache/*
  rm -rf -- /data/system/dropbox/*
  rm -rf -- /data/tombstones/*
  rm -rf -- /data/anr/*
  fstrim /data
}

stop_services() {
  stop tombstoned android.thermal-hal vendor.thermal-engine \
    vendor.thermal_manager vendor.thermal-manager vendor.thermal-hal-2-0 \
    vendor.thermal-symlinks thermal_mnt_hal_service thermal mi_thermald \
    thermald thermalloadalgod thermalservice sec-thermal-1-0 \
    debug_pid.sec-thermal-1-0 thermal-engine vendor.thermal-hal-1-0 \
    vendor-thermal-1-0 thermal-hal logd
}

setup_battery() {
  cmd package disable \
    com.google.android.gms/.chimera.GmsIntentOperationService
  dumpsys battery reset
  dumpsys deviceidle disable
  echo 'N' > /sys/module/lpm_levels/parameters/sleep_disabled
  echo 1 > /sys/class/qcom-battery/pd_verifed
  echo 'deep' > /sys/power/mem_sleep
}

setup_cpu() {
  local policy
  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    # Set schedutil for little cores
    if [[ "${policy##*/}" == 'policy0' ]]; then
      echo 'schedutil' > "${policy}/scaling_governor"
      echo 1 > "${policy}/schedutil/pl"
    else
      echo 'performance' > "${policy}/scaling_governor"
    fi
  done
  local power_efficient='/sys/module/workqueue/parameters/power_efficient'
  chmod 644 "${power_efficient}"
  echo 'N' > "${power_efficient}"
}

setup_gpu() {
  local governor='performance'
  echo "${governor}" > /sys/class/kgsl/kgsl-3d0/devfreq/governor
  echo "${governor}" > /sys/kernel/gpu/gpu_governor
  echo 0 > "${sys_gpu}/throttling"
  service call SurfaceFlinger 1008 i32 1  # Disable HW overlays
}

set_settings() {
  settings put global ntp_server time.cloudflare.com
  settings put global transition_animation_scale 0.2
  settings put global animator_duration_scale 0.2
  settings put global window_animation_scale 0.2
  settings put secure location_mode 0
}

main() {
  until [[ -d /data/media/0/Android ]]; do
    sleep 1
  done
  sleep 30

  set_mount_options
  sysctl -p "${MODDIR}/sysctl.conf"
  setup_zram
  setup_dev
  set_settings
  setup_battery
  stop_services
  clear_disk
  setup_network
  setup_gpu
  setup_cpu
  cmd package compile -p PRIORITY_BACKGROUND --full -m speed-profile -a
}

main
