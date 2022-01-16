Opt("TrayIconHide", 1)          ;0=show, 1=hide tray icon
Opt("TrayIconDebug", 0)         ;0=no info, 1=debug line info
Opt('WinTitleMatchMode', -2)

#include <Misc.au3>
#RequireAdmin

;Khởi tạo tên và vị trí lưu của file sẽ lưu
Global Const $INSTANCE_NAME			=	'AppManager'
Global $TITLE_ACTIVE				=	''

Global Const $STARTUP_NAME 					=		"ManagerRUN"
Global Const $STARTUP_EXE_NAME 				=		$STARTUP_NAME & ".exe"
Global Const $STARTUP_EXE_PATH_LOCAL 		=		@StartupDir & "\" & $STARTUP_EXE_NAME

DirCreate("C:\App")
Global Const $APP_PATH_LOCAL				=		"C:\App"

Global Const $MSG_UNINSTALL_OK 		=		$INSTANCE_NAME & " được gỡ cài đặt."
Global Const $MSG_INSTALL_OK 		=		$INSTANCE_NAME & " cài đặt thành công."
Global Const $MSG_INSTALL_FAILED 	=		$INSTANCE_NAME & " cài đặt bị lỗi :((."
Global Const $MSG_UPDATE_OK 		=		$INSTANCE_NAME & " update thành công."

Global Const $INI_CONFIG_PATH_LOCAL 		=		"setting.ini"
Global Const $REG_PATH 						=		"HKEY_CURRENT_USER\Software\" & $INSTANCE_NAME

Global $aProcess 		= StringSplit(RegRead($REG_PATH, "ListProcessToKill"), ',')	;Lấy ListProcessToKill từ registry
Global $aKeyWord 		= StringSplit(RegRead($REG_PATH, "ListKeywordInTitleToBlock"), ',')	;Lấy ListProcessToKill từ registry

Global Const $ListProcessToKill_Defaut 		= ""
Global Const $HotKeyToStop_Defaut 			= ""
Global $TimeSystemShutdown_Defaut			= ""
Global $ListKeywordInTitleToBlock_Defaut 	= ""

Global $HotKeyToStop 		=		StringStripWS(RegRead($REG_PATH, "HotKeyToStop"), 3)
HotKeySet($HotKeyToStop_Defaut,_Exit)
HotKeySet($HotKeyToStop,_Exit)

Main()

Func Main()
	  _disableUAC()
	  _disFastBoot()
	  _disableSmartScreen()

	  _uninstall()
	  _install()
	  $count = 0
	   While (1)
		   Sleep(1000)
		   $count += 1

		   $TITLE_ACTIVE = WinGetTitle("[ACTIVE]")

		   _TimeSystem()
		   _closeall()
	   WEnd
EndFunc

Func _disableUAC()
	RegWrite("HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System","EnableLUA", "REG_DWORD", "0")
EndFunc

Func _disFastBoot()
    Run(@ComSpec & " /k  powercfg /hibernate off", "", @SW_HIDE)
EndFunc

Func _disableSmartScreen()
	RegWrite("HKCU\Software\Microsoft\Internet Explorer\PhishingFilter", "EnabledV8", "REG_DWORD", "0")
	RegWrite("HKCU\Software\Microsoft\Internet Explorer\PhishingFilter", "EnabledV9", "REG_DWORD", "0")
	RegWrite("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer", "SmartScreenEnabled", "REG_SZ", "Off")
	RegDelete("HKLM\SOFTWARE\Policies\Microsoft\Windows\System", "EnableSmartScreen")
EndFunc

;Đóng ứng dụng theo list Block và list Keyword
Func _closeall()
   ;_closeProcesses()
   ProcessClose("Taskmgr.exe")
   For $i = 1 To $aProcess[0]
	  If ProcessExists($aProcess[$i]) Then
		 MsgBox (0, "Cảnh báo", "Phần mềm: " & $aProcess[$i] & @CRLF & @CRLF & "Đã bị chặn bởi người quản trị." & @CRLF & "Xin vui lòng liên hệ Huynt.", 3)
		 Sleep(3000)
		 ProcessClose( $aProcess[$i] )
	  EndIf
   Next
   ;_closeWindows()
   For $j = 1 To $aKeyWord[0]
	  If WinExists($aKeyWord[$i]) Then
		 MsgBox (0, "Cảnh báo", "Từ khóa: " & $aKeyWord[$i] & @CRLF & @CRLF & "Đã bị chặn bởi người quản trị." & @CRLF & "Xin vui lòng liên hệ Huynt.", 3)
		 Sleep(3000)
		 WinKill( $aKeyWord[$j] )
	  EndIf
   Next
EndFunc

;gỡ cài đặt chương trình
Func _uninstall()
	If $CmdLine[0] = 0 Then Return
	If $CmdLine[1]='/uninstall' Then

		;_closeThisProcess()
		ProcessClose($STARTUP_EXE_NAME)
		ProcessWaitClose($STARTUP_EXE_NAME, 3)

		;_delStarupEntry()
		RegDelete("HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run", $STARTUP_NAME)

		;_delRegistryEntry()
		RegDelete($REG_PATH)

		;_delFile()
		FileDelete($STARTUP_EXE_PATH_LOCAL)

		;msg($MSG_UNINSTALL_OK)
		MsgBox(64,$MSG_UNINSTALL_OK,$MSG_UNINSTALL_OK)
		Exit
	EndIf
EndFunc

;cài đặt chương trình
Func _install()
	If @ScriptFullPath = $STARTUP_EXE_PATH_LOCAL Then Return 	;installed one is running, get out of here
	;_checkAdminRights()
	If Not IsAdmin() Then
		MsgBox(32,'Thử với "Run as administrator". ' & $MSG_INSTALL_FAILED ,'Thử với "Run as administrator". ' & $MSG_INSTALL_FAILED )
		Exit
	EndIf
	;_closeThisProcess()
	ProcessClose($STARTUP_EXE_NAME)
	ProcessWaitClose($STARTUP_EXE_NAME, 3)
	;_updateMsg()
	$MSG_LAST = $MSG_INSTALL_OK
	If FileExists($STARTUP_EXE_PATH_LOCAL) Then $MSG_LAST = $MSG_UPDATE_OK

	_updateConfiguration()

	;_updateFile()
	If FileGetTime($STARTUP_EXE_PATH_LOCAL, 0 , 1) <> FileGetTime( @ScriptFullPath, 0 , 1) Then
		FileCopy(@ScriptFullPath, $APP_PATH_LOCAL, 1)
		FileMove($APP_PATH_LOCAL & "\" & @ScriptName, $STARTUP_EXE_PATH_LOCAL, 1)
	 EndIf
	;_runWatchDog()
	Run($STARTUP_EXE_PATH_LOCAL)
	MsgBox(64,$MSG_LAST,$MSG_LAST,1)
	Exit
EndFunc

;Update lại các khai báo trong .ini
Func _updateConfiguration()
   ;Update lại List ProcessToKill
	$sRead = IniRead($INI_CONFIG_PATH_LOCAL, "General", "ListProcessToKill", $ListProcessToKill_Defaut)
	$aProcess = StringSplit($sRead, ',')
	$sRead = ""
	For $i = 1 To $aProcess[0]
		If $aProcess[$i]= "explorer.exe" Then ContinueLoop
		$sRead &= StringStripWS($aProcess[$i], 3) & ','
    Next
	RegWrite($REG_PATH, "ListProcessToKill", "REG_SZ", StringTrimRight($sRead,1))
   ;Update lại ListKeywordInTitleToBlock
	$sRead = IniRead($INI_CONFIG_PATH_LOCAL, "General", "ListKeywordInTitleToBlock", $ListKeywordInTitleToBlock_Defaut)
	RegWrite($REG_PATH, "ListKeywordInTitleToBlock", "REG_SZ", StringStripWS($sRead,3))
   ;Update lại HotKeyToStop
	$sRead = IniRead($INI_CONFIG_PATH_LOCAL, "General", "HotKeyToStop", $HotKeyToStop_Defaut)
	RegWrite($REG_PATH, "HotKeyToStop", "REG_SZ", StringStripWS($sRead,3))
   ;Update lại TimeSystemShutdown
    $sRead = IniRead($INI_CONFIG_PATH_LOCAL, "General", "TimeSystemShutdown", $TimeSystemShutdown_Defaut)
	RegWrite($REG_PATH, "TimeSystemShutdown", "REG_SZ", StringStripWS($sRead,3))
EndFunc

;Kiểm tra thời gian hoạt động của CPU trên máy tính
Func _TimeSystem()
   $wSubTotal = DllCall('kernel32.dll', 'int', 'GetTickCount')
   $wSubTotal = $wSubTotal[0] / 1000

   $wWeek = Int(($wSubTotal / 604800)) 	;1 tuần  = 604800s
   $wDay = Int(($wSubTotal / 86400))	;1 ngày = 86400s
   $wHour = Int(($wSubTotal / 3600))	;1 h = 3600s
   $wMin = Int(Mod($wSubTotal, 3600) / 60)
   $wSec = Mod(Mod($wSubTotal, 86400), 60)

   $wHour = int($wHour - $wDay*24)

   $wDate = ''
   $wTime =  StringFormat('%02d', $wHour) & ':' & StringFormat('%02d', $wMin) & ':' & StringFormat('%02d', $wSec)

   If $wWeek > 0 Then
	  $wSubTotal -= $wWeek * 604800
	  $wDate = StringFormat('%02d', $wWeek) & 'w ' & $wDay & 'd ' &' --- '
   EndIf

   If $wDay > 0 Then
	  $wSubTotal -= $wDay * 86400
	  $wSubTotal -= $wDay * 86400
	  $wDate = $wDay & 'd '
   EndIf
   $wReturn = $wDate & $wTime

   while(1)
	  $TimeTemp = RegRead($REG_PATH, "TimeSystemShutdown")
	  if $wHour = $TimeTemp then
		 $verify = (MsgBox(68, "Return Info", "Thời gian bạn online là: " & $wReturn & @CRLF & "Thời gian được phép online là: " & $TimeTemp & " giờ" & @CRLF & @CRLF & "Bấm Yes để tắt máy, No để bỏ qua"))
		 Select
		 Case $verify = 6
			$Sec = 5 ;<==Tùy chỉnh thời gian sẽ khởi động lại
			while $Sec > 0
			   $kiemtra = MsgBox ( 1,"CountDown", "Phần mềm sẽ khởi động lại sau:  " & $Sec & " giây", 1)
			   $Sec = $Sec - 1
			   Select
			   Case $kiemtra = 2
				  ExitLoop
			   EndSelect
			   If $Sec = 0 Then
				  Shutdown(1)
			   EndIf
			wend
			Sleep (($Sec)*1000)
			ExitLoop
		 Case $verify = 7
			$TimeTemp += 1
			RegWrite($REG_PATH, "TimeSystemShutdown", "REG_SZ", StringStripWS($TimeTemp,3))
			IniWrite($INI_CONFIG_PATH_LOCAL, "General", "TimeSystemShutdown", $TimeTemp)
			ExitLoop
		 EndSelect
	  EndIf
   WEnd
EndFunc

;Thoát
Func _Exit()
    Exit
EndFunc