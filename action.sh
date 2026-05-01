MODDIR="$(dirname "${0}")"

main() {
  local log="${MODDIR}/dex2oat.log"
  rm -f -- "${log}"
  cmd package art cleanup
  rm -rf -- /data/dalvik-cache/arm*/*
  cmd package compile -p PRIORITY_BOOT --full -v -m speed-profile -f -a
  date > "${log}"
}

main
