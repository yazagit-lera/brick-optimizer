delete_conflicting_props() {
  resetprop --delete debug.sf.high_fps_early_gl_phase_offset_ns
  resetprop --delete debug.sf.high_fps_early_phase_offset_ns
  resetprop --delete debug.sf.high_fps_late_sf_phase_offset_ns
  resetprop --delete debug.sf.high_fps_late_app_phase_offset_ns
}

optimize_boot() {
  local policy
  for policy in /sys/devices/system/cpu/cpufreq/policy*; do
    echo 'performance' > "${policy}/scaling_governor"
  done
  local dev
  for dev in /sys/block/*/queue; do
    local scheduler="${dev}/scheduler"
    echo 'noop' > "${scheduler}"
    echo 'none' > "${scheduler}"
    echo 1024 > "${dev}/read_ahead_kb"
    echo 128 > "${dev}/nr_requests"
    echo 2 > "${dev}/rq_affinity"
    echo 0 > "${dev}/rotational"
    echo 1 > "${dev}/add_random"
    echo 0 > "${dev}/nomerges"
    echo 0 > "${dev}/iostats"
  done
  local power_efficient='/sys/module/workqueue/parameters/power_efficient'
  echo 'Y' > /sys/module/lpm_levels/parameters/sleep_disabled
  chmod 644 "${power_efficient}"
  echo 'N' > "${power_efficient}"
}

main() {
  delete_conflicting_props
  optimize_boot
}

main
