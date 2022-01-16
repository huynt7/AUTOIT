#include <ButtonConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>

Local $Sec

#Region ### START Koda GUI section ###
$Form2 = GUICreate("Countdown", 207, 103, 192, 123)
GUISetIcon("AppManager.ico", -1)
;Các Label
$Label1 = GUICtrlCreateLabel("Giây", 64, 58, 33, 25, $SS_CENTER)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
$Label2 = GUICtrlCreateLabel("Phần mềm sẽ khởi động sau", 0, 16, 204, 25, $SS_CENTER)
GUICtrlSetFont(-1, 10, 800, 0, "Tahoma")
;các input
$Input1 = GUICtrlCreateInput("5", 32, 56, 25, 21, $ES_READONLY)
;các button
$Cancel = GUICtrlCreateButton("Cancel", 120, 56, 75, 25)
GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

_Countdown()

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $Cancel
			Exit
	EndSwitch
WEnd

func _Countdown()
    $Sec = GUICtrlRead($Input1)
	AdlibRegister("_Counter", 1000)
EndFunc

Func _Counter()
       if $Sec = 0 Then
		  AdlibUnRegister("_Counter")
		  Exit
		  ;Shutdown(1)
    Else
	   $Sec -= 1
	   GUICtrlSetData($Input1, $Sec)
    EndIf
EndFunc