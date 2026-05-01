main() {
  local apps
  apps='com.miui.analytics com.miui.msa.global com.facebook.services'
  apps="${apps} com.facebook.system com.facebook.appmanager"
  apps="${apps} com.android.traceur com.android.bookmarkprovider"
  apps="${apps} com.android.providers.partnerbookmarks com.xiaomi.joyose"
  apps="${apps} com.bsp.catchlog com.google.android.projection.gearhead"
  apps="${apps} com.google.android.onetimeinitializer"
  apps="${apps} com.miui.mishare.connectivity com.netflix.partner.activation"
  apps="${apps} com.xiaomi.midrop com.qti.xdivert com.android.emergency"
  apps="${apps} com.xiaomi.glgm com.mi.android.globalminusscreen"
  apps="${apps} com.android.stk com.google.android.partnersetup"
  apps="${apps} com.android.cellbroadcastreceiver com.miui.bugreport"
  apps="${apps} com.miui.touchassistant com.miui.miservice"
  apps="${apps} com.google.android.tts com.google.android.apps.wellbeing"
  apps="${apps} com.mi.globalbrowser com.miui.videoplayer com.miui.player"
  apps="${apps} com.miui.daemon com.google.android.printservice.recommendation"
  apps="${apps} com.android.bips com.android.printspooler com.qualcomm.atfwd"
  apps="${apps} com.android.wallpaperbackup com.google.android.marvin.talkback"
  apps="${apps} com.miui.android.fashiongallery com.my.games.vendorapp"
  apps="${apps} com.google.android.cellbroadcastservice"
  apps="${apps} com.google.android.cellbroadcastreceiver"
  apps="${apps} com.android.cellbroadcastreceiver.overlay.common"
  apps="${apps} com.google.android.cellbroadcastreceiver.overlay.miui"
  apps="${apps} com.google.android.cellbroadcastservice.overlay.miui"
  apps="${apps} com.miui.cloudbackup org.lineageos.jelly org.lineageos.etar"
  apps="${apps} org.lineageos.recorder com.samsung.android.bixby.voiceinput"
  apps="${apps} com.samsung.android.visionintelligence"
  apps="${apps} com.samsung.android.rubin.app flipboard.boxer.app"
  apps="${apps} com.facebook.katana com.microsoft.skydrive"
  apps="${apps} com.microsoft.office.officehubrow"
  apps="${apps} com.samsung.android.hmt.vrsvc com.sec.spp.push"
  apps="${apps} ru.yandex.searchplugin com.samsung.android.dhr"
  apps="${apps} com.google.android.apps.maps com.android.stk2"
  apps="${apps} com.google.android.feedback com.google.ar.core"
  apps="${apps} com.qualcomm.location com.miui.powerkeeper"
  apps="${apps} com.google.android.apps.safetyhub com.xiaomi.mircs"
  apps="${apps} com.qualcomm.qti.uceShimService"
  local app
  for app in ${apps}; do
    cmd package uninstall --user 0 "${app}"
  done
}

main
