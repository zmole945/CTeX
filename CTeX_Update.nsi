;Not now
disbled

Unicode true

; Use compression
SetCompressor /FINAL /SOLID LZMA
SetCompressorDictSize 32

!include "libs\CTeX_Version.nsh"

; Functions and Macros
!include "libs\CTeX_Macros.nsh"

!define Base_Version "2.9.2.164"

; Variables

; Main Install settings
Name "${APP_NAME} ${APP_VERSION} Update"
BrandingText "${APP_NAME} ${APP_BUILD} (C) ${APP_COMPANY}"
InstallDir "C:\CTEX"
OutFile "output\CTeX_${APP_BUILD}_Update.exe"

; Other settings
RequestExecutionLevel admin

; Modern interface settings
!include "MUI2.nsh"

!define MUI_ABORTWARNING
!define MUI_ICON "images\Install.ico"
!define MUI_UNICON "images\Uninstall.ico"
!define MUI_HEADERIMAGE
!define MUI_HEADERIMAGE_RIGHT
!define MUI_HEADERIMAGE_BITMAP "images\install_header.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "images\install_welcome.bmp"
!define MUI_CUSTOMFUNCTION_GUIINIT onMUIInit
!define MUI_FINISHPAGE_SHOWREADME "$INSTDIR\Changes.txt"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

; Set languages (first is default language)
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"
!insertmacro MUI_RESERVEFILE_LANGDLL

Section

	!insertmacro Get_StartMenu_Dir
	!insertmacro Get_Uninstall_Information
	!insertmacro Update_Uninstall_Information

	SetOverwrite on

	${If} $Addons != ""
		SetOutPath "$INSTDIR\${Addons_Dir}"
		${Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_addons.log"
		${Install_Files} "install\Addons\*.*" "install_addons.log"
	${EndIf}
	
;	${If} $GSview != ""
;		!insertmacro Uninstall_Config_GSview ""
;		SetOutPath "$INSTDIR\${GSview_Dir}"
;		${Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_gsview.log"
;		${Install_Files} "install\GSview\*.*" "install_gsview.log"
;	${EndIf}
	
	${If} $Ghostscript != ""
		!insertmacro Uninstall_Config_Ghostscript ""
		SetOutPath "$INSTDIR\${Ghostscript_Dir}"
		${Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_ghostscript.log"
		${Install_Files} "install\Ghostscript\*.*" "install_ghostscript.log"
	${EndIf}

	${If} $WinEdt != ""
		!insertmacro Uninstall_Config_WinEdt ""
		SetOutPath "$INSTDIR\${WinEdt_Dir}"
		${Uninstall_Files} "$UN_INSTDIR\${Logs_Dir}\install_winedt.log"
		${Install_Files} "install\WinEdt\*.*" "install_winedt.log"
	${EndIf}

; Always do update
	SetOutPath $INSTDIR
	File "texts\Readme.txt"
	File "texts\Changes.txt"
	File "output\Repair.exe"

; Update configs
	DetailPrint "Update configs"
	StrCpy $Version ${APP_BUILD}
	${If} $MiKTeX != ""
		StrCpy $MiKTeX ${MiKTeX_Version}
	${EndIf}
	${If} $Addons != ""
		StrCpy $Addons ${MiKTeX_Version}
	${EndIf}
	${If} $Ghostscript != ""
		StrCpy $Ghostscript ${Ghostscript_Version}
	${EndIf}
	${If} $GSview != ""
		StrCpy $GSview ${GSview_Version}
	${EndIf}
	${If} $WinEdt != ""
		StrCpy $WinEdt ${WinEdt_Version}
	${EndIf}

	!insertmacro Save_Install_Information
	
	nsExec::Exec "$INSTDIR\Repair.exe /S"

; Update MiKTeX
	DetailPrint "Update MiKTeX"
	${If} $MiKTeX != ""
		!insertmacro Uninstall_Config_MiKTeX ""
		${Uninstall_Files} "$INSTDIR\${Logs_Dir}\install_miktex.log"
		RMDir "$UN_INSTDIR\${MiKTeX_Dir}"
		SetOutPath "$INSTDIR\${MiKTeX_Dir}"
		${Install_Files} "install\MiKTeX\*.*" "install_miktex.log"
		!insertmacro Install_Config_MiKTeX
	${EndIf}
		

SectionEnd

; On initialization
Function .onInit

	!insertmacro MUI_LANGDLL_DISPLAY

	ReadRegStr $INSTDIR HKLM "Software\${APP_NAME}" "Install"
	ReadRegStr $Version HKLM "Software\${APP_NAME}" "Version"

	${If} ${Silent}
		Call onMUIInit
	${EndIf}

FunctionEnd

Function onMUIInit

	${If} $INSTDIR != ""
	${AndIf} $Version != ""
		${VersionCompare} $Version ${APP_BUILD} $1
		${If} $1 == "1"
			MessageBox MB_OK|MB_ICONSTOP "$(Msg_NewVer)"
			Abort
		${ElseIf} $1 == "0"
			MessageBox MB_OK|MB_ICONSTOP "$(Msg_SameVer)"
			Abort
		${EndIf}

		${VersionCompare} $Version ${Base_Version} $1
		${If} $1 == "2"
			MessageBox MB_OK|MB_ICONSTOP "$(Msg_OldVer) ${Base_Version}"
			Abort
		${EndIf}
	${Else}
		MessageBox MB_OK|MB_ICONSTOP "$(Msg_NotInst)"
		Abort
	${EndIf}
	
	!insertmacro Restore_Install_Information

FunctionEnd

!insertmacro Set_Version_Information

; Language strings

LangString Msg_NewVer ${LANG_SIMPCHINESE} "系统中安装了更高版本的CTeX！"
LangString Msg_NewVer ${LANG_ENGLISH} "Newer version of CTeX is found in the system!"
LangString Msg_SameVer ${LANG_SIMPCHINESE} "系统中已经安装了最新版本的CTeX！"
LangString Msg_SameVer ${LANG_ENGLISH} "Latest version of CTeX is found in the system!"
LangString Msg_OldVer ${LANG_SIMPCHINESE} "系统中安装的CTeX版本太旧，请先更新到版本："
LangString Msg_OldVer ${LANG_ENGLISH} "The installed CTeX is too old, please update to version: "
LangString Msg_NotInst ${LANG_SIMPCHINESE} "系统中没有安装CTeX！"
LangString Msg_NotInst ${LANG_ENGLISH} "Not found CTeX in the system!"
LangString Msg_FontSetup ${LANG_SIMPCHINESE} "必须重新生成中文Type1字库！运行FontSetup？"
LangString Msg_FontSetup ${LANG_ENGLISH} "Must re-generate Chinese Type1 fonts! Run FontSetup?"
LangString Msg_UpdateMiKTeX ${LANG_SIMPCHINESE} "是否在线更新MiKTeX？"
LangString Msg_UpdateMiKTeX ${LANG_ENGLISH} "Update MiKTeX through Internet?"

; eof