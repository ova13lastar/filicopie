; #INDEX# =======================================================================================================================
; Title .........: select_cloe_printer
; AutoIt Version : 3.3.14.5
; Language ......: French
; Description ...: Script .au3
; Author(s) .....: yann.daniel@assurance-maladie.fr
; ===============================================================================================================================

; #ENVIRONMENT# =================================================================================================================
; AutoIt3Wrapper
#AutoIt3Wrapper_Res_ProductName=select_cloe_printer
#AutoIt3Wrapper_Res_Description=Permet de sélectionner automatiquement l imprimante CLOE dans la fenetre d impression
#AutoIt3Wrapper_Res_ProductVersion=1.0.0
#AutoIt3Wrapper_Res_FileVersion=1.0.0
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
; Options
AutoItSetOption("MustDeclareVars", 1)
AutoItSetOption("WinTitleMatchMode", 2)
AutoItSetOption("WinDetectHiddenText", 1)
AutoItSetOption("MouseCoordMode", 0)
AutoItSetOption("TrayMenuMode", 1)
; ===============================================================================================================================

; #MAIN SCRIPT# =================================================================================================================
WinActivate("Imprimer")
Global $hWindowPrint = WinWaitActive("Imprimer", "", 10)
If $hWindowPrint <> 0 Then
    Global $hComboBox = ControlGetHandle($hWindowPrint, "", "[CLASS:ComboBox; INSTANCE:1]")
    If IsHWnd($hComboBox) Then
        ControlFocus($hWindowPrint, "", $hComboBox)
        Send("C")
    EndIf
EndIf
; #MAIN SCRIPT# =================================================================================================================
