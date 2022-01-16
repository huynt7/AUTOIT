#NoTrayIcon
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <UpdownConstants.au3>


Global $Time, $Paused = 1, $sum, $display = 1

HotKeySet("{PAUSE}", "TogglePause")

$Form2 = GUICreate("Shutdown Menu", 413, 179, 192, 123)
$Input1 = GUICtrlCreateInput("0", 76, 128, 73, 21)
$Updown1 = GUICtrlCreateUpdown($Input1, BitOR($UDS_ALIGNRIGHT, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 168, 0)
$Label1 = GUICtrlCreateLabel("Seconds:", 264, 104, 49, 17)
GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
$Input2 = GUICtrlCreateInput("0", 168, 128, 73, 21)
$Updown2 = GUICtrlCreateUpdown($Input2, BitOR($UDS_ALIGNRIGHT, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 59, 0)
$Label2 = GUICtrlCreateLabel("Minutes:", 168, 104, 44, 17)
GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
$Input3 = GUICtrlCreateInput("0", 264, 128, 73, 21)
$Updown3 = GUICtrlCreateUpdown($Input3, BitOR($UDS_ALIGNRIGHT, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))
GUICtrlSetLimit(-1, 59, 0)
$Label3 = GUICtrlCreateLabel("Hours:", 74, 104, 35, 17)
GUICtrlSetFont(-1, 9, 400, 0, "MS Sans Serif")
$Button1 = GUICtrlCreateButton("Hibernate", 16, 16, 89, 33, $WS_GROUP)
$Button2 = GUICtrlCreateButton("Stand By", 112, 16, 89, 33, $WS_GROUP)
$Button3 = GUICtrlCreateButton("Shutdown", 208, 16, 89, 33, $WS_GROUP)
$Button4 = GUICtrlCreateButton("Restart", 304, 16, 89, 33, $WS_GROUP)
$Button5 = GUICtrlCreateButton("Log Off", 160, 51, 89, 33, $WS_GROUP)
GUISetState(@SW_SHOW)


While 1
    $nMsg = GUIGetMsg()
    Switch $nMsg
        Case $GUI_EVENT_CLOSE
            Exit
         Case $Button1
            Global $type="Hibernate"
            Countdown()
         Case $Button2
            Global $type="Stand By"
            Countdown()
         Case $Button3
            Global $type="Shutdown"
            Countdown()
         Case $Button4
            Global $type="Restart"
            Countdown()
         Case $Button5
            Global $type="Log Off"
            Countdown()
    EndSwitch
    If $Paused = -1 And $display Then
        ToolTip('Script is "Paused"', 0, 0)
        $display = 0
    EndIf
    If $Paused = 1 Then ToolTip("")

WEnd

Func Countdown()
    $Sec = GUICtrlRead($Input3)
    $Min = GUICtrlRead($Input2)
    $Hour = GUICtrlRead($Input1)
    $sum = $Sec + 60 * $Min + 3600 * $Hour
    AdlibRegister("Counter", 1000)
EndFunc   ;==>Timer

Func Counter()
    Local $s, $m, $Hour
    If $sum = 0 Then
        AdlibUnRegister("Counter")
        $display = 1
    Else
        $sum -= 1
        $s = Mod($sum, 60)
        $m = Mod(Int($sum / 60), 60)
        $h = Int($sum / 60 ^ 2)
        GUICtrlSetData($Input3, $s)
        GUICtrlSetData($Input2, $m)
        GUICtrlSetData($Input1, $h)

         If $h=0 Then
           If $m=0 Then
              If $s=0 Then

                 if $type="Hibernate" Then
                     Shutdown(64)
                 EndIf

                 if $type="Stand By" Then
                     Shutdown(32)
                 EndIf

                 if $type="Shutdown" Then
                     Shutdown(1)
                 EndIf

                 if $type="Restart" Then
                     Shutdown(6)
                 EndIf

                 if $type="Log Off" Then
                     Shutdown(0)
                 EndIf

                 EndIf
              EndIf
           EndIf

    EndIf
EndFunc


Func TogglePause()
    $Paused *= -1
    If $Paused -1 Then
        AdlibUnRegister("Counter")
    Else
        AdlibRegister("Counter", 1000)
    EndIf
EndFunc   ;==>TogglePause