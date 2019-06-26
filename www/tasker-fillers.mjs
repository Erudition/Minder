// make module: just add "export" in front of every function and rename to .mjs
// then call from another .mjs with something like
// import * as taskerFillers from "./tasker-fillers.mjs";
// try {
//     var inTasker = ( tk.global( 'sdk' ) > 0 );
// } catch (e) {
//     var tk = taskerFillers;
//     var inTasker = ( tk.global( 'sdk' ) > 0 );
// }
//
// Then, run the script that imports this module, in Node:
// node --experimental-modules calls-tasker.mjs



// v1 tv5.6
export function alarmVol(a1,a2,a3){return true;}
export function audioRecord(a1,a2,a3,a4){return true;}
export function audioRecordStop(){return true;}
export function btVoiceVol(a1,a2,a3){return true;}
export function browseURL(a1){return true;}
export function button(a1){return true;}
export function call(a1,a2){return true;}
export function callBlock(a1,a2){return true;}
export function callDivert(a1,a2,a3){return true;}
export function callRevert(a1){return true;}
export function callVol(a1,a2,a3){return true;}
export function carMode(a1){return true;}
export function clearKey(a1){return true;}
export function composeEmail(a1,a2,a3){return true;}
export function composeMMS(a1,a2,a3,a4){return true;}
export function composeSMS(a1,a2){return true;}
export function convert(a1,a2){return ' ';}
export function createDir(a1,a2,a3){return true;}
export function createScene(a1){return true;}
export function cropImage(a1,a2,a3,a4){return true;}
export function decryptDir(a1,a2,a3){return true;}
export function decryptFile(a1,a2,a3){return true;}
export function deleteDir(a1,a2,a3){return true;}
export function deleteFile(a1,a2,a3){return true;}
export function destroyScene(a1){return true;}
export function disable(){return true;}
export function displayAutoBright(a1){return true;}
export function displayAutoRotate(a1){return true;}
export function displayTimeout(a1,a2,a3){return true;}
export function dpad(a1,a2){return true;}
export function dtmfVol(a1,a2,a3){return true;}
export function elemBackColour(a1,a2,a3,a4){return true;}
export function elemBorder(a1,a2,a3,a4){return true;}
export function elemPosition(a1,a2,a3,a4,a5,a6){return true;}
export function elemText(a1,a2,a3,a4){return true;}
export function elemTextColour(a1,a2,a3){return true;}
export function elemTextSize(a1,a2,a3){return true;}
export function elemVisibility(a1,a2,a3,a4){return true;}
export function endCall(){return true;}
export function enableProfile(a1,a2){return true;}
export function encryptDir(a1,a2,a3,a4){return true;}
export function encryptFile(a1,a2,a3,a4){return true;}
export function enterKey(a1,a2,a3,a4,a5,a6,a7){return true;}
export function exit(){console.log("Tasker would have exit here!: ")}
export function flash(a1){console.log("Tasker would have flashed: "+a1);}
export function flashLong(a1){}
export function filterImage(a1,a2){return true;}
export function flipImage(a1){return true;}
export function getLocation(a1,a2,a3){return true;}
export function getVoice(a1,a2,a3){return ' ';}
export function global(a1){if(a1=='SDK'||a1=='%SDK'){return '0';}else{return ' ';}}
export function goHome(a1){}
export function haptics(a1){return true;}
export function hideScene(a1){return true;}
export function listFiles(a1,a2){return ' ';}
export function loadApp(a1,a2,a3){return true;}
export function loadImage(a1){return true;}
export function local(a1){return ' ';}
export function lock(a1,a2,a3,a4,a5,a6,a7){return true;}
export function mediaControl(a1){return true;}
export function mediaVol(a1,a2,a3){return true;}
export function micMute(a1){return true;}
export function mobileData(a1){return true;}
export function musicBack(a1){return true;}
export function musicPlay(a1,a2,a3,a4){return true;}
export function musicSkip(a1){return true;}
export function musicStop(){return true;}
export function nightMode(a1){return true;}
export function notificationVol(a1,a2,a3){return true;}
export function performTask(a1,a2,a3,a4){return true;}
export function popup(a1,a2,a3,a4,a5,a6){return true;}
export function profileActive(a1){return true;}
export function pulse(a1){return true;}
export function readFile(a1){return ' ';}
export function reboot(a1){return true;}
export function resizeImage(a1,a2){return true;}
export function ringerVol(a1,a2,a3){return true;}
export function rotateImage(a1,a2){return true;}
export function saveImage(a1,a2,a3){return true;}
export function say(a1,a2,a3,a4,a5,a6,a7,a8){return true;}
export function scanCard(a1){return true;}
export function sendIntent(a1,a2,a3,a4,a5,a6,a7,a8){return true;}
export function sendSMS(a1,a2,a3){return true;}
export function setClip(a1,a2){return true;}
export function settings(a1){return true;}
export function setAirplaneMode(a1){return true;}
export function setAirplaneRadios(a1){return true;}
export function setAlarm(a1,a2,a3,a4){return true;}
export function setAutoSync(a1){return true;}
export function setBT(a1){return true;}
export function setBTID(a1){return true;}
export function setGlobal(a1,a2){}
export function setKey(a1,a2){return true;}
export function setLocal(a1,a2){}
export function setWallpaper(a1){return true;}
export function setWifi(a1){return true;}
export function shell(a1,a2,a3){return ' ';}
export function showScene(a1,a2,a3,a4,a5,a6){return true;}
export function shutdown(){return true;}
export function silentMode(a1){return true;}
export function sl4a(a1,a2){return true;}
export function soundEffects(a1){return true;}
export function speakerphone(a1){return true;}
export function statusBar(a1){return true;}
export function stayOn(a1){return true;}
export function stopLocation(a1){return true;}
export function systemLock(){return true;}
export function systemVol(a1,a2,a3){return true;}
export function takeCall(){return true;}
export function takePhoto(a1,a2,a3,a4){return true;}
export function taskRunning(a1){return true;}
export function type(a1,a2){return true;}
export function unzip(a1,a2){return true;}
export function usbTether(a1){return true;}
export function vibrate(a1){}
export function vibratePattern(a1){return true;}
export function wait(a1){return true;}
export function wifiTether(a1){return true;}
export function writeFile(a1,a2,a3){return true;}
export function zip(a1,a2,a3){return true;}
