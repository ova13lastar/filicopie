' filicopie.vbs script
' Part of PDFCreator
' License: GPL
' Homepage: http://www.pdfforge.org/products/pdfcreator
' Windows Scripting Host version: 5.1
' Version: 1.1.0.0
' Date: 15/11/2021
' Author: Yann DANIEL

Option Explicit

Const WshRunning = 0
Const WshFailed = 1
Const sGSPath = "C:\APPLINAT\CLOE\gsView\bin\gswin32c.exe"
Const sWatermarkPath = "C:\APPLILOC\FILICOPIE\vendor\watermark_copie_artois.ps"
Const sSelectCLOEPrinterPath = "C:\APPLILOC\FILICOPIE\vendor\select_cloe_printer.exe"
Const sPdfSuffix = "_filicopie"

Dim objArgs, sInputPdfName, sOutputPdfName, fso, i, AppTitle, Scriptname, ScriptBasename
Dim WshShell, oExec, sCommand

Set fso = CreateObject("Scripting.FileSystemObject")
Scriptname = fso.GetFileName(Wscript.ScriptFullname)
ScriptBasename = fso.GetFileName(Wscript.ScriptFullname)
AppTitle = "PDFCreator - " & ScriptBaseName

' On verifie que la version de Vbscript est compatible
If CDbl(Replace(WScript.Version,".",",")) < 5.1 then
  MsgBox "Vous devez utiliser ""Windows Scripting Host"" version 5.1 ou supérieure !", vbCritical + vbSystemModal, AppTitle
  Wscript.Quit
End if

' On verifie que PdfCreator (et Images2Pdfc) est bien installé
If Not FileExists(sGSPath) Then
 MsgBox "Ghostscript (CLOE) n'est pas correctement installé. Absence du fichier : " & Images2PdfC, vbExclamation + vbSystemModal, AppTitle
 WScript.Quit
End If

' On récupère les arguments
Set objArgs = WScript.Arguments

' On vérifie que l'argument est bien passé
If objArgs.Count <> 1 Then
  MsgBox "Ce script attend 1 et 1 seul argument : le path du .pdf à convertir", vbExclamation + vbSystemModal, AppTitle
  WScript.Quit
End If

Set WshShell = WScript.CreateObject("WScript.Shell")
For i = 0 to objArgs.Count - 1
    ' On recupere le path du fichier en entree
    sInputPdfName = objArgs(i)
    ' msgbox "sInputPdfName: " & sInputPdfName
    sOutputPdfName = GetFilenameWithoutExtension(sInputPdfName) & sPdfSuffix & ".pdf"
    ' msgbox "sOutputPdfName: " & sOutputPdfName
    ' On lance l ajout du Filigrane
    sCommand = """" & sGSPath & """ -q -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=""" & sOutputPdfName & """ """ & sWatermarkPath & """ """ & sInputPdfName & """"
    ' msgbox "sCommand: " & sCommand
    Set oExec = WshShell.Exec(sCommand)
    While oExec.Status = WshRunning
        WScript.Sleep 50
    Wend
    ' On lance l'impression du pdf aplati
    PrintPdf """" & sOutputPdfName & """"
    ' On choisi CLOE par defaut
    WScript.Sleep 2000
    Set oExec = WshShell.Exec("""" & sSelectCLOEPrinterPath & """")
    While oExec.Status = WshRunning
        WScript.Sleep 50
    Wend
    set WshShell = Nothing 
Next

' -----------------------------------------

Function GetFilenameWithoutExtension(ByVal FileName)
  Dim Result, i
  Result = FileName
  i = InStrRev(FileName, ".")
  If ( i > 0 ) Then
    Result = Mid(FileName, 1, i - 1)
  End If
  GetFilenameWithoutExtension = Result
End Function

Sub OpenPdf(filename, page)
    Dim AcobatReaderPath
    AcobatReaderPath = WshShell.Regread("HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\AcroRd32.exe\Path") & "\AcroRd32.exe"
    'msgbox "AcobatReaderPath: " & AcobatReaderPath
    Set wshShell = WScript.CreateObject("WSCript.shell")
    wshShell.Run """" & AcobatReaderPath & """ /A ""page=" & page & """ " & fileName
End Sub

Sub PrintPdf(filename)
    Dim AcobatReaderPath
    AcobatReaderPath = WshShell.Regread("HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\AcroRd32.exe\Path") & "\AcroRd32.exe"
    'msgbox "AcobatReaderPath: " & AcobatReaderPath
    Set wshShell = WScript.CreateObject("WSCript.shell")
    wshShell.run """" & AcobatReaderPath & """ /p " & fileName,,false
End Sub

Function FileExists(FilePath)
  Set fso = CreateObject("Scripting.FileSystemObject")
  If fso.FileExists(FilePath) Then
    FileExists=CBool(1)
  Else
    FileExists=CBool(0)
  End If
End Function