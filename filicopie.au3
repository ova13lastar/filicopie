; #INDEX# =======================================================================================================================
; Title .........: filiecopie
; AutoIt Version : 3.3.14.5
; Language ......: French
; Description ...: Script .au3
; Author(s) .....: yann.daniel@assurance-maladie.fr
; ===============================================================================================================================

; #ENVIRONMENT# =================================================================================================================
; AutoIt3Wrapper
#AutoIt3Wrapper_Res_ProductName=filiecopie
#AutoIt3Wrapper_Res_Description=Permet d'installer l'imprimante virtuelle PDFCreator : FILICOPIE
#AutoIt3Wrapper_Res_ProductVersion=1.2.0
#AutoIt3Wrapper_Res_FileVersion=1.2.0
#AutoIt3Wrapper_Res_CompanyName=CNAMTS/CPAM_ARTOIS/APPLINAT
#AutoIt3Wrapper_Res_LegalCopyright=yann.daniel@assurance-maladie.fr
#AutoIt3Wrapper_Res_Language=1036
#AutoIt3Wrapper_Res_Compatibility=Win7
#AutoIt3Wrapper_Res_Field=AutoIt Version|%AutoItVer%
#AutoIt3Wrapper_Icon="static\icon.ico"
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Run_AU3Check=Y
#AutoIt3Wrapper_Run_Au3Stripper=N
#Au3Stripper_Parameters=/MO /RSLN
#AutoIt3Wrapper_AU3Check_Parameters=-q -d -w 1 -w 2 -w 3 -w 4 -w 5 -w 6 -w 7
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=Y
; Includes YD
#include "C:\Users\DANIEL-03598\Autoit_dev\Include\YDGVars.au3"
#include "C:\Users\DANIEL-03598\Autoit_dev\Include\YDLogger.au3"
#include "C:\Users\DANIEL-03598\Autoit_dev\Include\YDTool.au3"
; Includes Constants
#include <StaticConstants.au3>
#Include <WindowsConstants.au3>
#include <TrayConstants.au3>
; Includes
#include <String.au3>
; Options
AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("WinTitleMatchMode", 2)
AutoItSetOption("WinDetectHiddenText", 1)
AutoItSetOption("MouseCoordMode", 0)
AutoItSetOption("TrayMenuMode", 3)
OnAutoItExitRegister("_YDTool_ExitApp")
; ===============================================================================================================================

; #VARIABLES# ===================================================================================================================
_YDGVars_Set("sAppName", _YDTool_GetAppWrapperRes("ProductName"))
_YDGVars_Set("sAppDesc", _YDTool_GetAppWrapperRes("Description"))
_YDGVars_Set("sAppVersion", _YDTool_GetAppWrapperRes("FileVersion"))
_YDGVars_Set("sAppContact", _YDTool_GetAppWrapperRes("LegalCopyright"))
_YDGVars_Set("sAppVersionV", "v" & _YDGVars_Get("sAppVersion"))
_YDGVars_Set("sAppTitle", _YDGVars_Get("sAppName") & " - " & _YDGVars_Get("sAppVersionV"))
_YDGVars_Set("sAppDirDataPath", @ScriptDir & "\data")
_YDGVars_Set("sAppDirStaticPath", @ScriptDir & "\static")
_YDGVars_Set("sAppDirLogsPath", @ScriptDir & "\logs")
_YDGVars_Set("sAppDirVendorPath", @ScriptDir & "\vendor")
_YDGVars_Set("sAppIconPath", @ScriptDir & "\static\icon.ico")
_YDGVars_Set("sAppConfFile", @ScriptDir & "\conf.ini")
_YDGVars_Set("iAppNbDaysToKeepLogFiles", 15)
_YDGVars_Set("iAppNbDaysToKeepDataFiles", 15)

_YDLogger_Init()
_YDLogger_LogAllGVars()
; ===============================================================================================================================

; #MAIN SCRIPT# =================================================================================================================
If Not _YDTool_IsSingleton() Then Exit
;------------------------------
; On supprime les anciens fichiers de log
_YDTool_DeleteOldFiles(_YDGVars_Get("sAppDirLogsPath"), _YDGVars_Get("iAppNbDaysToKeepLogFiles"))
;------------------------------
; On supprime les anciens fichiers tif et pdf
_YDTool_DeleteOldFiles(_YDGVars_Get("sAppDirDataPath"), _YDGVars_Get("iAppNbDaysToKeepDataFiles"))
;------------------------------
; On gere l'affichage de l'icone dans le tray
TraySetIcon(_YDGVars_Get("sAppIconPath"))
TraySetToolTip(_YDGVars_Get("sAppTitle"))
Global $idTrayAbout = TrayCreateItem("A propos", -1, -1, -1)
Global $idTrayExit = TrayCreateItem("Quitter", -1, -1, -1)
TraySetState($TRAY_ICONSTATE_SHOW)
;------------------------------
Global $g_sSiteNetworkPath = ""
;------------------------------
; On recupere les valeurs de conf.ini
Global $g_sPdfCreatorPrinter = _YDTool_GetAppConfValue("general", "printer")
Global $g_sUncPath = _YDTool_GetAppConfValue("general", "uncpath")
Global $g_sVbsPath = _YDTool_GetAppConfValue("general", "vbspath")
;------------------------------
; On recupere d autres variables globales
Global $g_sLoggerUserName = _YDTool_GetHostLoggedUserName(@ComputerName)
_YDLogger_Var("$g_sLoggerUserName", $g_sLoggerUserName)
Global $g_sOldPdfCreatorPrinter = "filiecopie"
_YDLogger_Var("$g_sOldPdfCreatorPrinter", $g_sOldPdfCreatorPrinter)
Global $g_sOSArchitecture = (@OSVersion = "WIN_7") ? "X86" : "X64"
_YDLogger_Var("$g_sOSArchitecture", $g_sOSArchitecture)
;------------------------------
_Main()
; #MAIN SCRIPT# =================================================================================================================

; #FUNCTION# ====================================================================================================================
; Description ...: Traitement principal
; Syntax ........: _Main()
; Parameters ....:
; Return values .:
; Author ........: yann.daniel@assurance-maladie.fr
; Last Modified .: 15/11/2021
; Notes .........:
;================================================================================================================================
Func _Main()
	Local $sFuncName = "_Main"
	;------------------------------
	; On supprime l'ancienne imprimante PDFCreator si installee precedemment
	If _DeleteOldPdfCreatorPrinterIfInstalled($g_sOldPdfCreatorPrinter) Then
		_YDLogger_Log("Suppression ancienne imprimante " & $g_sOldPdfCreatorPrinter, $sFuncName)
	Else
		_YDLogger_Log("Ancienne imprimante " & $g_sOldPdfCreatorPrinter & " non trouvee", $sFuncName)
	EndIf
	;------------------------------
	; On installe l'imprimante PDFCreator
	If Not _IsPdfCreatorPrinterInstalled($g_sPdfCreatorPrinter) And $g_sLoggerUserName <> "" Then
		_YDLogger_Log("Imprimante " & $g_sPdfCreatorPrinter & " non installee !", $sFuncName)
		_InstallPdfCreatorPrinter()
	Else
		_YDLogger_Log("Imprimante " & $g_sPdfCreatorPrinter & " deja installee : Suppression ...", $sFuncName)
		_DeleteOldPdfCreatorPrinterIfInstalled($g_sPdfCreatorPrinter)
		_YDLogger_Log("Imprimante " & $g_sPdfCreatorPrinter & " deja installee : Réinstallation ...", $sFuncName)
		_InstallPdfCreatorPrinter()
	EndIf
	;------------------------------
	; On verifie que l'imprimante PDFCreator s'est correctement installee
	If _IsPdfCreatorPrinterInstalled($g_sPdfCreatorPrinter) Then
		_YDLogger_Log("Imprimante " & $g_sPdfCreatorPrinter & " installee pour utilisateur : " & $g_sLoggerUserName, $sFuncName)
	Else
		_YDLogger_Error("Imprimante " & $g_sPdfCreatorPrinter & " non installee malgre la tentative d'installation !", $sFuncName)
	EndIf
	Exit
EndFunc

; #FUNCTION# ====================================================================================================================
; Description ...: Permet de supprimer une ancienne imprimante PDFCreator IRIS_IMPRESSION (IRIS_ARRAS, etc..) si elle est encore installee
; Syntax.........: _DeleteOldPdfCreatorPrinterIfInstalled()
; Parameters ....: $_sPrinterVal 	- Nom de l'imprimante PDFCreator IRIS_IMPRESSION (IRIS_ARRAS, etc..)
; Return values .: Success      - True
;                  Failure      - False
; Author ........: yann.daniel@assurance-maladie.fr
; Last Modified .: 15/11/2021
; Notes .........:
;================================================================================================================================
Func _DeleteOldPdfCreatorPrinterIfInstalled($_sPrinterVal)
	Local $sFuncName = "_DeleteOldPdfCreatorPrinterIfInstalled"
	_YDLogger_Var("$_sPrinterVal", $_sPrinterVal, $sFuncName, 2)
	Local $sRegKey = "HKEY_CURRENT_USER\Software\PDFCreator\Printers"
	Local $sRegVal = $_sPrinterVal
	Local $sRegKeyVal = $sRegKey & "\" & $sRegVal
	_YDLogger_Var("$sRegKeyVal", $sRegKeyVal, $sFuncName, 2)
	Local $sRegValReturn = RegRead($sRegKey, $sRegVal)
	_YDLogger_Var("$sRegValReturn", $sRegValReturn, $sFuncName, 2)
	If $sRegValReturn == $_sPrinterVal Then
		_YDLogger_Log("Valeur [" & $_sPrinterVal & "] trouvee dans la cle [" & $sRegKeyVal & "]", $sFuncName, 2)
		;-- Cle principale
		If RegDelete($sRegKey, $sRegVal) = 1 Then
			_YDLogger_Log("Suppression OK de la cle [" & $sRegKeyVal & "]", $sFuncName)
		Else
			_YDLogger_Error("Suppression de la cle [" & $sRegKeyVal & "] impossible", $sFuncName, 2)
		EndIf
		;-- Cle profil
		$sRegKeyVal = "HKEY_CURRENT_USER\Software\PDFCreator\Profiles\" & $_sPrinterVal
		If RegDelete($sRegKeyVal) = 1 Then
			_YDLogger_Log("Suppression OK de la cle [" & $sRegKeyVal & "]", $sFuncName)
		Else
			_YDLogger_Log("Suppression de la cle [" & $sRegKeyVal & "] impossible", $sFuncName)
		EndIf
		Return True
	Else
		_YDLogger_Log("Valeur [" & $_sPrinterVal & "] introuvable dans la cle [" & $sRegKeyVal & "] !", $sFuncName, 2)
		Return False
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Description ...: Permet de vérifier si une imprimante PDFCreator est bien installee sur le HKCU
; Syntax.........: _IsPdfCreatorPrinterInstalled()
; Parameters ....: $_sPrinterName 	- Nom de l'imprimante PDFCreator
; Return values .: Success      - True
;                  Failure      - False
; Author ........: yann.daniel@assurance-maladie.fr
; Last Modified .: 15/11/2021
; Notes .........:
;================================================================================================================================
Func _IsPdfCreatorPrinterInstalled($_sPrinterName)
	Local $sFuncName = "_IsPdfCreatorPrinterInstalled"
	Local $sRegKey = "HKEY_CURRENT_USER\Software\PDFCreator\Printers"
	Local $sRegVal = $_sPrinterName
	Local $sRegKeyVal = $sRegKey & "\" & $sRegVal
	If RegRead($sRegKey, $sRegVal) <> "" Then
		_YDLogger_Log("Cle [" & $sRegKeyVal & "] trouvee", $sFuncName, 2)
		Return True
	Else
		_YDLogger_Error("Cle [" & $sRegKeyVal & "] introuvable !", $sFuncName)
		Return False
	EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Description ...: Permet d'installer l'imprimante g_sPdfCreatorPrinter
; Syntax.........: _InstallPdfCreatorPrinter()
; Parameters ....:
; Return values .: Success      - True
;                  Failure      - False
; Author ........: yann.daniel@assurance-maladie.fr
; Last Modified .: 15/11/2021
; Notes .........:
;================================================================================================================================
Func _InstallPdfCreatorPrinter()
	Local $sFuncName = "_InstallPdfCreatorPrinter"
	Local $iRegError
	Local $sRegName
	Local $sProgramFiles
	;---------------------------------------
	$sRegName = 'HKCU_add_printer'
	$iRegError = 0
	If RegWrite('HKCU\Software\PDFCreator\Printers', $g_sPdfCreatorPrinter, 'REG_SZ', $g_sPdfCreatorPrinter) <> 1 Then $iRegError += 1
	If $iRegError = 0 Then
		_YDLogger_Log("Inscriptions registre " & $sRegName & " : OK", $sFuncName)
	Else
		_YDLogger_Error("Inscriptions registre " & $sRegName & " : NOK !", $sFuncName)
	EndIf
	;---------------------------------------
	$sProgramFiles = ($g_sOSArchitecture = "X64") ? "Program Files (x86)" : "Program Files"
	;---------------------------------------
	$sRegName = 'HKCU_add_profile'
	$iRegError = 0
	Local $sRegData = 'Microsoft Word - |\.docx|\.doc|\Microsoft Excel - |\.xlsx|\.xls|\Microsoft PowerPoint - |\.pptx|\.ppt|'
	If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Ghostscript', 'DirectoryGhostscriptBinaries','REG_SZ','C:\' & $sProgramFiles & '\PDFCreator\GS9.05\gs9.05\Bin\') <> 1 Then $iRegError += 1
	If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Ghostscript', 'DirectoryGhostscriptFonts','REG_SZ','') <> 1 Then $iRegError += 1
	If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Ghostscript', 'DirectoryGhostscriptLibraries','REG_SZ','C:\' & $sProgramFiles & '\PDFCreator\GS9.05\gs9.05\Lib\') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Ghostscript', 'DirectoryGhostscriptResource','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'Counter','REG_SZ','74') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'DeviceHeightPoints','REG_SZ','842') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'DeviceWidthPoints','REG_SZ','595') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'OneFilePerPage','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'Papersize','REG_SZ','a4') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StampFontColor','REG_SZ','#FF0000') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StampFontname','REG_SZ','Arial') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StampFontsize','REG_SZ','48') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StampOutlineFontthickness','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StampString','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StampUseOutlineFont','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardAuthor','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardCreationdate','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardDateformat','REG_SZ','YYYYMMDDHHNNSS') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardKeywords','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardMailDomain','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardModifydate','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardSaveformat','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardSubject','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'StandardTitle','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'UseCreationDateNow','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'UseCustomPaperSize','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'UseFixPapersize','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing', 'UseStandardAuthor','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'BMPColorscount','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'BMPResolution','REG_SZ','150') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'JPEGColorscount','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'JPEGQuality','REG_SZ','75') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'JPEGResolution','REG_SZ','150') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PCLColorsCount','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PCLResolution','REG_SZ','150') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PCXColorscount','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PCXResolution','REG_SZ','150') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PNGColorscount','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PNGResolution','REG_SZ','150') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PSDColorsCount','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'PSDResolution','REG_SZ','150') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'RAWColorsCount','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'RAWResolution','REG_SZ','150') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'SVGResolution','REG_SZ','72') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'TIFFColorscount','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\Bitmap\Colors', 'TIFFResolution','REG_SZ','300') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Colors', 'PDFColorsCMYKToRGB','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Colors', 'PDFColorsColorModel','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Colors', 'PDFColorsPreserveHalftone','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Colors', 'PDFColorsPreserveOverprint','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Colors', 'PDFColorsPreserveTransfer','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompression','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompressionChoice','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompressionJPEGHighFactor','REG_SZ','0.9') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompressionJPEGLowFactor','REG_SZ','0.25') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompressionJPEGManualFactor','REG_SZ','3') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompressionJPEGMaximumFactor','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompressionJPEGMediumFactor','REG_SZ','0.5') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorCompressionJPEGMinimumFactor','REG_SZ','0.1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorResample','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorResampleChoice','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionColorResolution','REG_SZ','300') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompression','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompressionChoice','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompressionJPEGHighFactor','REG_SZ','0.9') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompressionJPEGLowFactor','REG_SZ','0.25') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompressionJPEGManualFactor','REG_SZ','3') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompressionJPEGMaximumFactor','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompressionJPEGMediumFactor','REG_SZ','0.5') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyCompressionJPEGMinimumFactor','REG_SZ','0.1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyResample','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyResampleChoice','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionGreyResolution','REG_SZ','300') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionMonoCompression','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionMonoCompressionChoice','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionMonoResample','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionMonoResampleChoice','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionMonoResolution','REG_SZ','300') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Compression', 'PDFCompressionTextCompression','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Fonts', 'PDFFontsEmbedAll','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Fonts', 'PDFFontsSubSetFonts','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Fonts', 'PDFFontsSubSetFontsPercent','REG_SZ','100') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFGeneralASCII85','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFGeneralAutorotate','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFGeneralCompatibility','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFGeneralDefault','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFGeneralOverprint','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFOptimize','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFPageLayout','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFPageMode','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFStartPage','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\General', 'PDFUpdateMetadata','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFAes128Encryption','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFAllowAssembly','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFAllowDegradedPrinting','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFAllowFillIn','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFAllowScreenReaders','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFDisallowCopy','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFDisallowModifyAnnotations','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFDisallowModifyContents','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFDisallowPrinting','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFEncryptor','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFHighEncryption','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFLowEncryption','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFOwnerPass','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFOwnerPasswordString','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFUserPass','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFUserPasswordString','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Security', 'PDFUseSecurity','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningMultiSignature','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningPFXFile','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningPFXFilePassword','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureContact','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureLeftX','REG_SZ','100') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureLeftY','REG_SZ','100') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureLocation','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureOnPage','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureReason','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureRightX','REG_SZ','200') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureRightY','REG_SZ','200') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignatureVisible','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningSignPDF','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PDF\Signing', 'PDFSigningTimeServerUrl','REG_SZ','http://timestamp.globalsign.com/scripts/timstamp.dll') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PS\LanguageLevel', 'EPSLanguageLevel','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Printing\Formats\PS\LanguageLevel', 'PSLanguageLevel','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AdditionalGhostscriptParameters','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AdditionalGhostscriptSearchpath','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AddWindowsFontpath','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AllowSpecialGSCharsInFilenames','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AutosaveDirectory','REG_SZ',$g_sUncPath) <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AutosaveFilename','REG_SZ','<DocumentFilename>') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AutosaveFormat','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'AutosaveStartStandardProgram','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'ClientComputerResolveIPAddress','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'DisableEmail','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'DisableUpdateCheck','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'DontUseDocumentSettings','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'EditWithPDFArchitect','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'FilenameSubstitutions','REG_SZ', $sRegData) <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'FilenameSubstitutionsOnlyInTitle','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'Language','REG_SZ','french') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'LastSaveDirectory','REG_SZ',$g_sUncPath) <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'LastUpdateCheck','REG_SZ','20211112') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'Logging','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'LogLines','REG_SZ','100') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'MaximumCountOfPDFArchitectToolTip','REG_SZ','5') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'NoConfirmMessageSwitchingDefaultprinter','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'NoProcessingAtStartup','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'NoPSCheck','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'OpenOutputFile','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'OptionsDesign','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'OptionsEnabled','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'OptionsVisible','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSaving','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingBitsPerPixel','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingDuplex','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingMaxResolution','REG_SZ','600') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingMaxResolutionEnabled','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingNoCancel','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingPrinter','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingQueryUser','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrintAfterSavingTumble','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'PrinterStop','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'ProcessPriority','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'ProgramFont','REG_SZ','MS Sans Serif') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'ProgramFontCharset','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'ProgramFontSize','REG_SZ','8') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RemoveAllKnownFileExtensions','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RemoveSpaces','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramAfterSaving','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramAfterSavingProgramname','REG_SZ',$g_sVbsPath) <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramAfterSavingProgramParameters','REG_SZ','"<OutputFilename>"') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramAfterSavingWaitUntilReady','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramAfterSavingWindowstyle','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramBeforeSaving','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramBeforeSavingProgramname','REG_SZ','') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramBeforeSavingProgramParameters','REG_SZ','"<TempFilename>"') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'RunProgramBeforeSavingWindowstyle','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'SaveFilename','REG_SZ','<DocumentFilename>') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'SendEmailAfterAutoSaving','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'SendMailMethod','REG_SZ','0') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'ShowAnimation','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'Toolbars','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'UpdateInterval','REG_SZ','2') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'UseAutosave','REG_SZ','1') <> 1 Then $iRegError += 1
    If RegWrite('HKCU\SOFTWARE\PDFCreator\Profiles\' & $g_sPdfCreatorPrinter & '\Program', 'UseAutosaveDirectory','REG_SZ','1') <> 1 Then $iRegError += 1
	If $iRegError = 0 Then
		_YDLogger_Log("Inscriptions registre " & $sRegName & " : OK", $sFuncName)
	Else
		_YDLogger_Error("Inscriptions registre " & $sRegName & " : NOK !", $sFuncName)
	EndIf
EndFunc
