#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <UpdownConstants.au3>
#include <md5.au3>

Global Const $INSTANCE_NAME			=	'AppManager' ;<==Thay đổi tuỳ ý

Global Const $INI_CONFIG_PATH_LOCAL 		=		"setting.ini"
Global Const $REG_PATH 						=		"HKEY_CURRENT_USER\Software\" & $INSTANCE_NAME

Global $aProcess 		= StringSplit(RegRead($REG_PATH, "ListProcessToKill"), ',')	;get ListProcessToKill from registry
Global $aKeyWord 		= StringSplit(RegRead($REG_PATH, "ListKeywordInTitleToBlock"), ',')	;get ListProcessToKill from registry

Global Const $ListProcessToKill_Defaut 		= ""
Global $TimeSystemShutdown_Defaut			= ""
Global $ListKeywordInTitleToBlock_Defaut 	= ""

Global $TimeSystemShutdown =	StringStripWS(RegRead($REG_PATH, "TimeSystemShutdown"), 3)

;===========GIAO DIỆN==============

#Region ### START Koda GUI section ###
$AppManager = GUICreate("Quản lý người sử dụng", 475, 275, 192, 123)
GUISetIcon("AppManager.ico", -1)
GUISetBkColor(0xC0DCC0)
$Group1 = GUICtrlCreateGroup("ỨNG DỤNG QUẢN LÝ NGƯỜI SỬ DỤNG", 8, 8, 457, 257, BitOR($GUI_SS_DEFAULT_GROUP,$BS_CENTER))
GUICtrlSetFont(-1, 12, 800, 0, "Tahoma")
GUICtrlSetColor(-1, 0x008080)
;Các button
$btnInstall = GUICtrlCreateButton("Cài đặt", 312, 152, 140, 50)
GUICtrlSetFont(-1, 11, 400, 0, "Tahoma")
$btnUninstall = GUICtrlCreateButton("Gỡ bỏ", 312, 208, 140, 50)
GUICtrlSetFont(-1, 11, 400, 0, "Tahoma")
$btnKeyword = GUICtrlCreateButton("Chặn DS từ khoá", 312, 88, 140, 50)
GUICtrlSetFont(-1, 11, 400, 0, "Tahoma")
GUICtrlSetBkColor(-1, 0xF4F7FC)
$btnBlock = GUICtrlCreateButton("Chặn DS ứng dụng", 312, 32, 140, 50)
GUICtrlSetFont(-1, 11, 400, 0, "Tahoma")
GUICtrlSetBkColor(-1, 0xF4F7FC)
;Các list
$ListBlock = GUICtrlCreateEdit("", 16, 64, 140, 153)
GUICtrlSetData(-1, "DS ứng dụng")
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
$ListKeyword = GUICtrlCreateEdit("", 168, 64, 140, 153)
GUICtrlSetData(-1, "DS từ khoá")
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
;Các Label
$Label1 = GUICtrlCreateLabel("DS ứng dụng", 16, 40, 140, 22, $SS_CENTER)
GUICtrlSetFont(-1, 10, 800, 0, "Tahoma")
$Label2 = GUICtrlCreateLabel("DS từ khoá", 168, 40, 140, 22, $SS_CENTER)
GUICtrlSetFont(-1, 10, 800, 0, "Tahoma")
$Label3 = GUICtrlCreateLabel("Thời gian online (Giờ):", 16, 230, 204, 22, $SS_CENTER)
GUICtrlSetFont(-1, 10, 800, 0, "Tahoma")
;Các Input
$InputTime = GUICtrlCreateInput("2", 232, 228, 75, 27)
GUICtrlSetFont(-1, 10, 400, 0, "Tahoma")
$Updown1 = GUICtrlCreateUpdown($InputTime, BitOR($UDS_ALIGNRIGHT, $UDS_ARROWKEYS, $UDS_NOTHOUSANDS))

GUICtrlCreateGroup("", -99, -99, 1, 1)

_AddListBlock()
_AddListKeyword()
;_AddInputTime()

FileCreateShortcut(@ScriptFullPath,@DesktopDir & "\Phần Mềm Quản Lý.lnk",@ScriptDir,"","",@ScriptDir & "\" & "AppManager.ico")

GUISetState(@SW_SHOW)
#EndRegion ### END Koda GUI section ###

;==============MAIN===============

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $btnBlock
			_runBlock()
	    Case $btnKeyword
			_runKeyword()
		 Case $btnInstall
			_runInstall()
		 Case $btnUninstall
			_runUninstall()
	EndSwitch
 WEnd

;==============FUNCTION================

;Nhập mật khẩu khi cài đặt hoặc gỡ chương trình
func _PasswordProtect()
   $pass1 = "15073d52733c1841b9703c535e899c8a" ; <-- = "thcsnguyenhue" <==Thay đổi tuỳ ý
   $pass2 = "80241b142d1b505044f9c08cafd0ddee" ; <-- = "nguyenhue"
   $pass3 = "b79a050d5ad23828ed122d40eb8704c8" ; <-- = "huynt"

   $correctPassword = False
For $i = 0 To 2
   $password = InputBox("Access Protected",  "====VUI LÒNG NHẬP MẬT KHẨU===="&@CRLF&"-------------------------------------------------"&@CRLF&@CRLF&"Sai mật khẩu "&$i&"/3 lần ứng dụng tự động đóng",  "",  "*")
   If MD5($password) = $pass1 or MD5($password) = $pass2 or MD5($password) = $pass3 Then
	  $correctPassword = True
	  ExitLoop
   ElseIf $password = "" Then
	  MsgBox(0,"","Mật khẩu không được để trống.")
   Else
	  MsgBox(0,"","Sai mật khẩu!")
   EndIf
Next
If $correctPassword = False Then
   MsgBox(0,"","Bạn đã nhập sai mật khẩu."&@CRLF&"Chương trình sẽ tự động đóng.")
   Exit
EndIf
EndFunc

;Đưa list ListProcessToKill đã có trong .ini vào EditBox: ListBlock
Func _AddListBlock()
   $sRead = IniRead($INI_CONFIG_PATH_LOCAL, "General", "ListProcessToKill", $ListProcessToKill_Defaut)
   $aProcess = StringReplace($sRead,",",@CRLF)
   GUICtrlSetData($ListBlock, $aProcess)
EndFunc

;Đưa list ListKeywordInTitleToBlock trong .ini vào EditBox: ListKeyword
Func _AddListKeyword()
   $sRead = IniRead($INI_CONFIG_PATH_LOCAL, "General", "ListKeywordInTitleToBlock", $ListKeywordInTitleToBlock_Defaut)
   $aProcess = StringReplace($sRead,",",@CRLF)
   GUICtrlSetData($ListKeyword, $aProcess)
EndFunc

;Đưa TimeSystemShutdown trong .ini vào InputTime
Func _AddInputTime()
   $sRead = IniRead($INI_CONFIG_PATH_LOCAL, "General", "TimeSystemShutdown", $TimeSystemShutdown_Defaut)
   GUICtrlSetData($InputTime, $sRead)
EndFunc

;Đưa EditBox: ListBlock nhập vào file .ini
Func _runBlock()
   $aReadListBlock = StringReplace(GUICtrlRead ($ListBlock),@CRLF,",")
   IniWrite($INI_CONFIG_PATH_LOCAL, "General", "ListProcessToKill",StringReplace($aReadListBlock," ",""))
   MsgBox(0,"Add List Block","Add list [Block] successfully.")
EndFunc

;Đưa EditBox: ListKeyword nhập vào file .ini
Func _runKeyword()
   $aReadListKeyword = StringReplace(GUICtrlRead ($ListKeyword),@CRLF,",")
   IniWrite($INI_CONFIG_PATH_LOCAL, "General", "ListKeywordInTitleToBlock",StringReplace($aReadListKeyword," ",""))
   MsgBox(0,"Add List Keyword","Add list [Keyword] successfully.")
EndFunc

;Đưa Input: Time nhập vào file .ini
Func _runTime()
   $aReadTime = GUICtrlRead($InputTime)
   IniWrite($INI_CONFIG_PATH_LOCAL, "General", "TimeSystemShutdown",$aReadTime)
EndFunc

Func _runInstall()
   _runTime()
   ;Run("ChuongTrinh.exe")
   Exit
EndFunc

Func _runUninstall()
   _PasswordProtect()
   Run("ChuongTrinh.exe /uninstall")
   Exit
EndFunc