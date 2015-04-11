#RequireAdmin
#AutoIt3Wrapper_UseX64=n
#pragma compile(Icon, "Icons\cocbot.ico")
#pragma compile(FileDescription, Clash of Clans Bot - Modification of A Free/Open Sourced Clash of Clans bot - https://clashbot.org)
#pragma compile(ProductName, Clash of Clans Bot)
#pragma compile(ProductVersion, 1.0)
#pragma compile(FileVersion, 1.0)

$sBotVersion = "1.0"
$sBotTitle = "AutoIt Unbroken ClashBot v" & $sBotVersion

If _Singleton($sBotTitle, 1) = 0 Then
	MsgBox(0, "", "Bot is already running.")
	Exit
EndIf

If @AutoItX64 = 1 Then
	MsgBox(0, "", "Don't Run/Compile Script (x64)! try to Run/Compile Script (x86) to getting this bot work." & @CRLF & _
			"If this message still appear, try to re-install your AutoIt with newer version.")
	Exit
EndIf

If Not FileExists(@ScriptDir & "\License.txt") Then
	$license = InetGet("http://www.gnu.org/licenses/gpl-3.0.txt", @ScriptDir & "\License.txt")
	InetClose($license)
EndIf

#include "COCBot\Global Variables.au3"
#include "COCBot\GUI Design.au3"
#include "COCBot\GUI Control.au3"
#include "COCBot\Functions.au3"
#include-once

DirCreate($dirLogs)
DirCreate($dirLoots)
DirCreate($dirAllTowns)
DirCreate($dirDebug)
DirCreate($dirAttack)
DirCreate($dirConfigs)

$sTimer = TimerInit()
AdlibRegister("SetTime", 1000)

While 1
	Switch TrayGetMsg()
		Case $tiAbout
			MsgBox(64 + $MB_APPLMODAL + $MB_TOPMOST, $sBotTitle, "Clash of Clans Bot" & @CRLF & @CRLF & _
					"Version: " & $sBotVersion & @CRLF & _
					"Released under the GNU GPLv3 license.", 0, $frmBot)
		Case $tiExit
			SetLog("Exiting !!!", $COLOR_ORANGE)
			ExitLoop
	EndSwitch
WEnd

Func runBot() ;Bot that runs everything in order
	While 1
		SaveConfig()
		readConfig()
		applyConfig()
		Pause()
		chkNoAttack()
		$Restart = False
		$fullArmy = False
		$fullSpellFactory = False
		$spellsstarted = False
		If _Sleep(1000) Then Return
		checkMainScreen()
		Pause()
		If _Sleep(5000) Then Return
		VillageReport()
		If ZoomOut() = False Then ContinueLoop
		Pause()
		If $SearchCost = 0 And $CommandStop <> 0 And $CommandStop <> 3 Then
			$FirstAttack = 0  ;force it become first attack when check cost per search
			If _Sleep(1000) Then Return
			CheckArmyCamp()
			If $CurCamp > 0 Then
				If _Sleep(1000) Then Return
				CheckCostPerSearch()
			EndIf
		EndIf
		Pause()
		If _Sleep(1000) Then Return
		If ZoomOut() = False Then ContinueLoop
		Pause()
		If _Sleep(1000) Then Return
		checkMainScreen(False)
		Pause()
		If $Restart = True Then ContinueLoop
		If BotCommand() Then btnStop()
		If _Sleep(1000) Then Return
		checkMainScreen(False)
		Pause()
		If $Restart = True Then ContinueLoop
		If $Checkrearm = True Then
			ReArm()
			If _Sleep(2000) Then Return
			checkMainScreen(False)
			If $Restart = True Then ContinueLoop
			$Checkrearm = False
		EndIf
		Pause()
		DonateCC()
		Pause()
		If _Sleep(1000) Then Return
		If $CommandStop <> 0 And $CommandStop <> 3 Then
			CheckArmyCamp()
			If _Sleep(1000) Then Return
			If $ichkMakeSpells = 1 Then
				CheckSpellFactory()
			EndIf
			If _Sleep(1000) Then Return
		EndIf
		Pause()
		If $DCattack = 1 And $CommandStop <> 0 And $CommandStop <> 3 And $fullArmy Then
			If GUICtrlRead($chkAnyActivate) = $GUI_UNCHECKED And GUICtrlRead($chkDeadActivate) = $GUI_UNCHECKED Then
				SetLog("All search modes are deactivated, disabling PushBullet notification and switching to Donate/Train Only Mode !!!", $COLOR_ORANGE)
				GUICtrlSetState($lblpushbulletenabled, $GUI_UNCHECKED)
				GUICtrlSetState($lblpushbulletenabled, $GUI_DISABLE)
				GUICtrlSetState($chkNoAttack, $GUI_CHECKED)
				GUICtrlSetState($chkAnyActivate, $GUI_UNCHECKED)
				GUICtrlSetState($chkDeadActivate, $GUI_UNCHECKED)
				GUICtrlSetState($chkAnyActivate, $GUI_DISABLE)
				GUICtrlSetState($chkDeadActivate, $GUI_DISABLE)
				chkDeadActivate()
				chkAnyActivate()
				lblpushbulletenabled()
			Else
				checkMainScreen()
				Pause()
				If _Sleep(1000) Then Return
				If ZoomOut() = False Then ContinueLoop
				Pause()
				If _Sleep(1000) Then Return
				checkMainScreen(False)
				Pause()
				If _Sleep(1000) Then Return
				AttackMain()
				Pause()
				If _Sleep(1000) Then Return
				$fullArmy = False
			EndIf
		EndIf
		Pause()
		If $CommandStop <> 0 And $CommandStop <> 3 Then
			Train()
			If _Sleep(1000) Then Return
			TrainDark()
			If _Sleep(1000) Then Return
			If $needzoomout = True Then
				checkMainScreen(False)
				$needzoomout = False
				If ZoomOut() = False Then ContinueLoop
			EndIf
			If _Sleep(1000) Then Return
		EndIf
		Pause()
		checkMainScreen(False)
		Pause()
		If $Restart = True Then ContinueLoop
		If $needzoomout = True Then
			$needzoomout = False
			If ZoomOut() = False Then ContinueLoop
		EndIf
		BoostAllBuilding()
		Pause()
		If _Sleep(1000) Then Return
		RequestCC()
		Pause()
		If _Sleep(1000) Then Return
		checkMainScreen(False)
		Pause()
		If $Restart = True Then ContinueLoop
		Collect()
		If _Sleep(1000) Then Return
		checkMainScreen(False)
		Pause()
		If $Restart = True Then ContinueLoop
		UpgradeToBuilding1()
		UpgradeToBuilding2()
		UpgradeToBuilding3()
		UpgradeToBuilding4()
		UpgradeToBuilding5()
		UpgradeToBuilding6()
		If _Sleep(1000) Then Return
		checkMainScreen(False)
		If $Restart = True Then ContinueLoop
		UpgradeWall()
		Pause()
		If _Sleep(1000) Then Return
		Idle()
		If _Sleep(1000) Then Return
		If $Restart = True Then ContinueLoop
		If $CommandStop <> 0 And $CommandStop <> 3 Then
			If GUICtrlRead($chkAnyActivate) = $GUI_UNCHECKED And GUICtrlRead($chkDeadActivate) = $GUI_UNCHECKED Then
				SetLog("All search modes are deactivated, disabling PushBullet notification and switching to Donate/Train Only Mode !!!", $COLOR_ORANGE)
				GUICtrlSetState($lblpushbulletenabled, $GUI_UNCHECKED)
				GUICtrlSetState($lblpushbulletenabled, $GUI_DISABLE)
				GUICtrlSetState($chkNoAttack, $GUI_CHECKED)
				GUICtrlSetState($chkAnyActivate, $GUI_UNCHECKED)
				GUICtrlSetState($chkDeadActivate, $GUI_UNCHECKED)
				GUICtrlSetState($chkAnyActivate, $GUI_DISABLE)
				GUICtrlSetState($chkDeadActivate, $GUI_DISABLE)
				chkDeadActivate()
				chkAnyActivate()
				lblpushbulletenabled()
			Else
				checkMainScreen()
				Pause()
				If _Sleep(1000) Then Return
				If ZoomOut() = False Then ContinueLoop
				Pause()
				If _Sleep(1000) Then Return
				checkMainScreen(False)
				Pause()
				If _Sleep(1000) Then Return
				AttackMain()
				Pause()
				If _Sleep(1000) Then Return
				$fullArmy = False
			EndIf
		EndIf
		Pause()
	WEnd
EndFunc   ;==>runBot

Func Idle() ;Sequence that runs until Full Army
	Local $TimeIdle = 0 ;In Seconds
	While ($fullArmy = False) And (Not ( ($fullSpellFactory = True And $ichkNukeOnly = 1) AND $ichkNukeOnlyWithFullArmy <> 1))
		If $CommandStop = -1 Then SetLog("~~~Waiting for full army~~~", $COLOR_PURPLE)
		Pause()
		Local $hTimer = TimerInit(), $x = 30000
		If $CommandStop = 3 Then $x = 15000
		If _Sleep($x) Then ExitLoop
		checkMainScreen()
		If _Sleep(1000) Then ExitLoop
		If ZoomOut() = False Then ContinueLoop
		If _Sleep(1000) Then ExitLoop
		If $iCollectCounter > $COLLECTATCOUNT Then ; This is prevent from collecting all the time which isn't needed anyway
			Collect()
			If _Sleep(1000) Or $RunState = False Then ExitLoop
			$iCollectCounter = 0
		EndIf
		$iCollectCounter = $iCollectCounter + 1
		If $CommandStop <> 3 Then
			CheckArmyCamp()
			If _Sleep(1000) Then Return
			Train()
			If _Sleep(1000) Then Return
			TrainDark()
			If _Sleep(1000) Then Return
			If $needzoomout = True Then
				checkMainScreen(False)
				Pause()
				If $Restart = True Then ContinueLoop
				$needzoomout = False
				If ZoomOut() = False Then ContinueLoop
			EndIf
			If _Sleep(1000) Then Return
			If $ichkMakeSpells = 1 Then CheckSpellFactory()
			If _Sleep(1000) Then ExitLoop
		EndIf
		If $CommandStop = 0 And $fullArmy Then
			SetLog("Army Camp is Full, Stop Training...", $COLOR_ORANGE)
			$CommandStop = 3
			$fullArmy = False
		EndIf
		If $CommandStop = -1 Then
			If $fullArmy Then ExitLoop
			DropTrophy()
			If _Sleep(1000) Then ExitLoop
		EndIf
		DonateCC()
		$TimeIdle += Round(TimerDiff($hTimer) / 1000, 2) ;In Seconds
		SetLog("Time Idle: " & Floor(Floor($TimeIdle / 60) / 60) & " hours " & Floor(Mod(Floor($TimeIdle / 60), 60)) & " minutes " & Floor(Mod($TimeIdle, 60)) & " seconds", $COLOR_ORANGE)
	WEnd
EndFunc   ;==>Idle

Func AttackMain() ;Main control for attack functions
	checkMainScreen()
	If _Sleep(500) Then Return
	$DCattack = 1
	PrepareSearch()
	If _Sleep(1000) Then Return
	VillageSearch($TakeAllTownSnapShot)
	If $CommandStop = 0 Then Return
	If _Sleep(1000) Or $Restart = True Then Return
	PrepareAttack()
	If _Sleep(1000) Then Return
	Attack()
	$DCattack = 0
	If _Sleep(1000) Then Return
	ReturnHome($TakeLootSnapShot)
	If _Sleep(1000) Then Return
EndFunc   ;==>AttackMain

Func Attack() ;Selects which algorithm
	SetLog("======Beginning Attack======")
	;	Switch $attackpattern
	;		Case 0 ; v5.5
	;			SetLog("Attacking with v5.5 attacking Algorithm")
	;			algorithm_Troops()
	;		Case 1 ; v5.6
	;			SetLog("Attacking with v5.6 attacking Algorithm")
	algorithm_AllTroops()
	;	EndSwitch
EndFunc   ;==>Attack

Func Pause()
	While $PauseBot
		If _Sleep(1000) Then Return
	WEnd
EndFunc   ;==>Pause
