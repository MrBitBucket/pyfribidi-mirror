' $Id: build.vbs 1 2010-07-11 20:47:52Z yoann $

'*************************************************************************
'* Copyright (c) 2010 Yoann Roman
'* 
'* Permission is hereby granted, free of charge, to any person obtaining
'* a copy of this software and associated documentation files (the
'* "Software"), to deal in the Software without restriction, including
'* without limitation the rights to use, copy, modify, merge, publish,
'* distribute, sublicense, and/or sell copies of the Software, and to
'* permit persons to whom the Software is furnished to do so, subject to
'* the following conditions:
'* 
'* The above copyright notice and this permission notice shall be included
'* in all copies or substantial portions of the Software.
'* 
'* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
'* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
'* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
'* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
'* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
'* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
'* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
'*************************************************************************

Option Explicit

' Script configuration flags
Private Const blDebug = False
Private Const blKeepFiles = False

' Build flags and paths
Private Const blRunTests = True
Private Const intCompression = 2
Private Const strUnicodeData = "gen.tab\unidata\"
Private Const strBaseDirectory = "fribidi-0.19.6"

' Fribidi CVS repository location
Private Const strCVSRepository = "pserver:anoncvs@anoncvs.freedesktop.org:/cvs/fribidi"
Private Const strCVSModule = "fribidi2"

' Paths to the various build tools used
Private Const strCVSPath = "cvs.exe"
Private Const strCompilerPath = "cl.exe"
Private Const strLinkerPath = "link.exe"
Private Const strDiffPath = "diff.exe"
Private Const strLogPath = "build.out"
Private Const popupMessages = False


' Run make
Make

Private Sub Make

    '*****************************************************
    '* Makes Fribidi. This is intended to mirror what a 
	'* Windows Makefile would do without the need for any 
	'* *nix tools. This method will do the following:
    '*
    '* - Delete any existing output files
    '* - Checkout the code if not available
    '* - Patch all files for use on Windows
    '* - Build and run all Unicode generators
    '* - Build the Fribidi library
    '* - Build all Fribidi bin\ tools
    '* - Run the Fribidi tests, if requested
    '*
    '* If any step fails, the script will error out with 
	'* an exit code of 1.
    '*****************************************************
	DeleteFile strLogPath

    Dim arSources

    ' Clean up the build
    If Not Clean(False) Then
        LogError "Unable to clean environment for building", True
    End If

    ' Setup the environment
    If Not SetupEnvironment(strCVSRepository, strCVSModule, "win", _
        False, "") Then
        LogError "Unable to setup environment for building", True
    End If

    ' Start by replacing all "pow" references in packtab.c
    If Not ReplaceInFile("gen.tab\packtab.c", "pow[", "pow_tab[") Then
        LogError "Unable to update gen.tab\packtab.c", True
    End If

    ' Make sure the UTF-8 methods are exported
    If Not ReplaceInFile("charset\fribidi-char-sets-utf8.h", vbCrLf & _
        "FriBidiStrIndex fribidi_", vbCrLf & "FRIBIDI_ENTRY FriBidiStrIndex fribidi_") Then
        LogError "Unable to update charset\fribidi-char-sets-utf8.h", True
    End If

    ' Patch the DLL export for Windows
    If Not PatchDLLExport("lib\fribidi-common.h") Then
        LogError "Unable to update lib\fribid-common.h", True
    End If

    ' Patch the toupper redefinition for Windows
    If Not PatchToUpper("charset\fribidi-char-sets.c") Then
        LogError "Unable to update charset\fribidi-char-sets.h", True
    End If

    ' Fix the exports file for Visual Studio
    If Not PatchExportDefinitionFile("lib\fribidi.def") Then
        LogError "Unable to update lib\fribidi.def", True
    End If

    ' Patch the benchmark file for Windows
    If Not PatchBenchmark("bin\fribidi-benchmark.c") Then
        LogError "Unable to update bin\fribidi-benchmark.c", True
    End If

    ' Build and run gen-unicode-version
    If Not Build("gen.tab", Array("gen.tab\gen-unicode-version.c", _
        "gen.tab\packtab.c"), "gen-unicode-version.exe", True) Then
        LogError "Unable to build gen-unicode-version.exe", True
    End If
    If Not RunGenerator("gen.tab\gen-unicode-version.exe", Array("ReadMe.txt", _
        "BidiMirroring.txt"), "lib\fribidi-unicode-version.h", False) Then
        LogError "Unable to generate fribidi-unicode-version.h", True
    End If

    ' Build and run gen-bidi-type-tab
    If Not Build("gen.tab", Array("gen.tab\gen-bidi-type-tab.c", _
        "gen.tab\packtab.c"), "gen-bidi-type-tab.exe", Not blKeepFiles) Then
        LogError "Unable to build gen-bidi-type-tab.exe", True
    End If
    If Not RunGenerator("gen.tab\gen-bidi-type-tab.exe", _
        Array("UnicodeData.txt"), "lib\bidi-type.tab.i", True) Then
        LogError "Unable to generate bidi-type.tab.i", True
    End If

    ' Build and run gen-joining-type-tab
    If Not Build("gen.tab", Array("gen.tab\gen-joining-type-tab.c", _
        "gen.tab\packtab.c"), "gen-joining-type-tab.exe", Not blKeepFiles) Then
        LogError "Unable to build gen-joining-type-tab.exe", True
    End If
    If Not RunGenerator("gen.tab\gen-joining-type-tab.exe", _
        Array("UnicodeData.txt", "ArabicShaping.txt"), _
        "lib\joining-type.tab.i", True) Then
        LogError "Unable to generate joining-type.tab.i", True
    End If

    ' Build and run gen-bidi-type-tab
    If Not Build("gen.tab", Array("gen.tab\gen-arabic-shaping-tab.c", _
        "gen.tab\packtab.c"), "gen-arabic-shaping-tab.exe", Not blKeepFiles) Then
        LogError "Unable to build gen-arabic-shaping-tab.exe", True
    End If
    If Not RunGenerator("gen.tab\gen-arabic-shaping-tab.exe", _
        Array("UnicodeData.txt"), "lib\arabic-shaping.tab.i", True) Then
        LogError "Unable to generate arabic-shaping.tab.i", True
    End If

    ' Build and run gen-bidi-type-tab
    If Not Build("gen.tab", Array("gen.tab\gen-mirroring-tab.c", _
        "gen.tab\packtab.c"), "gen-mirroring-tab.exe", Not blKeepFiles) Then
        LogError "Unable to build gen-mirroring-tab.exe", True
    End If
    If Not RunGenerator("gen.tab\gen-mirroring-tab.exe", _
        Array("BidiMirroring.txt"), "lib\mirroring.tab.i", True) Then
        LogError "Unable to generate mirroring.tab.i", True
    End If

    ' Build fribidi DLL
    arSources = GetFiles(Array("charset", "lib"), "*.c")
    If Not Build("lib", arSources, "fribidi.dll", Not blKeepFiles) Then
        LogError "Unable to build fribidi.dll", True
    End If

    ' Copy fribidi DLL to the bin directory
    If Not CopyFile(ExpandPath("lib\fribidi.dll"), ExpandPath("bin")) Then
        LogError "Unable to copy lib\fribidi.dll to bin", True
    End If

    ' Build fribidi
    If Not Build("bin", Array("bin\fribidi-main.c", "bin\getopt1.c", _
        "bin\getopt.c"), "fribidi.exe", Not blKeepFiles) Then
        LogError "Unable to build fribidi.exe", True
    End If

    ' Build fribidi-benchmark
    If Not Build("bin", Array("bin\fribidi-benchmark.c", "bin\getopt1.c", _
        "bin\getopt.c"), "fribidi-benchmark.exe", Not blKeepFiles) Then
        LogError "Unable to build fribidi-benchmark.exe", True
    End If

    ' Build fribidi-bidi-types
    If Not Build("bin", Array("bin\fribidi-bidi-types.c", "bin\getopt1.c", _
        "bin\getopt.c"), "fribidi-bidi-types.exe", Not blKeepFiles) Then
        LogError "Unable to build fribidi-bidi-types.exe", True
    End If

    ' Build fribidi-caprtl2utf8
    If Not Build("bin", Array("bin\fribidi-caprtl2utf8.c", "bin\getopt1.c", _
        "bin\getopt.c"), "fribidi-caprtl2utf8.exe", Not blKeepFiles) Then
        LogError "Unable to build fribidi-caprtl2utf8.exe", True
    End If

    ' Run the tests, if requested
    If blRunTests Then
        If Not RunTests("bin\fribidi.exe", "test") Then
            LogError "Tests failed to run for fribidi.exe", True
        End If
    End If

End Sub

Private Function Clean(bBuildPyfribidi)

    '*****************************************************
    '* Deletes all output files from the Fribidi build.
	'* bBuildPyfribidi is true, also deletes the build\ 
	'* Always returns
    '*****************************************************

    ' Delete all output files
    LogInfo "Cleaning environment"
    DeleteFile ExpandPath("gen.tab\gen-unicode-version.exe")
    DeleteFile ExpandPath("lib\fribidi-unicode-version.h")
    DeleteFile ExpandPath("gen.tab\gen-bidi-type-tab.exe")
    DeleteFile ExpandPath("lib\bidi-type.tab.i")
    DeleteFile ExpandPath("gen.tab\gen-joining-type-tab.exe")
    DeleteFile ExpandPath("lib\joining-type.tab.i")
    DeleteFile ExpandPath("gen.tab\gen-arabic-shaping-tab.exe")
    DeleteFile ExpandPath("lib\arabic-shaping.tab.i")
    DeleteFile ExpandPath("gen.tab\gen-mirroring-tab.exe")
    DeleteFile ExpandPath("lib\mirroring.tab.i")
    DeleteFile ExpandPath("lib\fribidi.dll")
    DeleteFile ExpandPath("lib\fribidi.exp")
    DeleteFile ExpandPath("lib\fribidi.lib")
    DeleteFile ExpandPath("bin\fribidi.dll")
    DeleteFile ExpandPath("bin\fribidi.exe")
    DeleteFile ExpandPath("bin\fribidi-benchmark.exe")
    DeleteFile ExpandPath("bin\fribidi-bidi-types.exe")
    DeleteFile ExpandPath("bin\fribidi-caprtl2utf8.exe")

    ' Regardless of the deletes, return success
    Clean = True
    LogInfo ""

End Function

Private Function CheckoutCVS(sRepository, sModule)

    '*****************************************************
    '* Checks out the specified module from the given 
    '* repository. If a folder with the module name 
    '* already exists, this will return false. If a base 
    '* directory is configured and does not already exist, 
    '* the checked out module folder will be renamed to 
    '* match the base directory. Returns true if 
    '* successful, false otherwise.
    '*****************************************************

    Dim objFSO, strCommand, fld

    ' If the target folder exists, can't checkout
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FolderExists(sModule) Then
        LogDebug "Checkout directory already exists, not checking out"
        Set objFSO = Nothing
        Exit Function
    End If

    ' Create and run the command
    strCommand = strCVSPath & " -Q -d:" & strCVSRepository & " co " & sModule
    If Not Run(strCommand, Null) Then
        LogError "Unable to checkout repository " & sModule, False
        Set objFSO = Nothing
        Exit Function
    End If

    ' Rename the directory if necessary
    If StrComp(sModule, strBaseDirectory, 1) <> 0 Then
        LogDebug "Renaming repository to " & strBaseDirectory
        If objFSO.FolderExists(strBaseDirectory) Then
            LogError "Unable to rename repository to " & strBaseDirectory, False
            Set objFSO = Nothing
            Exit Function
        End If
        Set fld = objFSO.GetFolder(sModule)
        fld.Name = strBaseDirectory
        Set fld = Nothing
    End If

    ' Cleanup and return
    Set objFSO = Nothing
    CheckoutCVS = True

End Function

Private Function SetupEnvironment(sRepository, sModule, sWinFolder, _
    bBuildPyfribidi, sPyfribidiFolder)

    '*****************************************************
    '* Sets up the environment for building Fribidi. This 
	'* involves checking out the code from CVS if not 
	'* already available, copying the config files to a 
	'* win\ directory, and copying the Pyfribidi source 
	'* files if building it. Returns true if successful, 
	'* false otherwise.
    '*****************************************************

    Dim objFSO, strTarget

    ' Checkout the code, if necessary
    LogInfo "Setting up environment for build"
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If Not objFSO.FolderExists(strBaseDirectory) Then
        LogInfo "Checking out repository"
        If Not CheckoutCVS(sRepository, sModule) Then
            LogError "Unable to setup repository " & sModule, False
            Set objFSO = Nothing
            Exit Function
        End If
    End If

    ' Make sure the target exists
    strTarget = ExpandPath(sWinFolder)
    If Not objFSO.FolderExists(strTarget) Then
        LogDebug "Creating folder " & strTarget
        objFSO.CreateFolder strTarget
    End If

    ' Add a trailing slash to make FSO happy
    If Right(strTarget, 1) <> "\" Then
        strTarget = strTarget & "\"
    End If

    ' Copy the config files to their folder
    LogDebug "Copying config files"
    objFSO.CopyFile "config.h", strTarget, True
    objFSO.CopyFile "fribidi-config.h", strTarget, True

    ' Return success
    Set objFSO = Nothing
    SetupEnvironment = True
    LogInfo ""

End Function

Private Function PatchDLLExport(sFilename)

    '*****************************************************
    '* Patches Fribidi's UTF-8 character set header to 
	'* export the functions previously exported in Fribidi 
	'* 0.10.9. If the patch is already applied, this does 
	'* not re-apply it. Returns true if successful or the 
	'* patch was already applied, false otherwise.
    '*****************************************************

    Dim objFSO, strFilename, ts, strLine, strContents, blHasPatch

    ' Make sure the file exists
    LogDebug "Checking " & sFilename & " for DLL export patch"
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFilename = ExpandPath(sFilename)
    If Not objFSO.FileExists(strFilename) Then
        LogError "Unable to open filename " & sFilename, False
        Set objFSO = Nothing
        Exit Function
    End If

    ' Loop through the file line by line
    Set ts = objFSO.OpenTextFile(strFilename, 1)
    Do While Not ts.AtEndOfStream

        ' Read in and append the line
        strLine = ts.ReadLine
        strContents = strContents & strLine & vbCrLf

        ' Is this the start of the FRIBIDI_ENTRY definition?
        If Left(strLine, 21) = "#ifndef FRIBIDI_ENTRY" Then

            ' Make sure the patch hasn't already been applied
            strLine = ts.ReadLine
            If InStr(strLine, "FRIBIDI_STATICLIB") > 0 Then
                Exit Do
            End If
            
            ' Apply the patch for the DLL export
            strContents = strContents & "# if (defined(WIN32)) || " & _
                "(defined(_WIN32_WCE)) && !defined(FRIBIDI_STATICLIB)" & vbCrLf & _
                "#  ifdef BUILDING_FRIBIDI" & vbCrLf & _
                "#   define FRIBIDI_ENTRY __declspec(dllexport)" & vbCrLf & _
                "#  else" & vbCrLf & _
                "#   define FRIBIDI_ENTRY __declspec(dllimport)" & vbCrLf & _
                "#  endif" & vbCrLf & _
                "# else /* !WIN32 */" & vbCrLf & _
                "#  define FRIBIDI_ENTRY        /* empty */" & vbCrLf & _
                "# endif    /* !WIN32 */" & vbCrLf & _
                "#endif /* !FRIBIDI_ENTRY */" & vbCrLf & vbCrLf
            blHasPatch = True

            ' Skip to the end of the definition
            While Len(Trim(strLine)) <> 0
                strLine = ts.ReadLine
            Wend

        End If
    Loop

    ' Close the file
    ts.Close
    Set ts = Nothing
    Set objFSO = Nothing

    ' If the patch was applied, write it back out
    If blHasPatch Then
        LogInfo "Patching " & sFilename
        If Not WriteFile(strFilename, strContents, False) Then
            LogError "Unable to write filename " & sFilename, False
            Exit Function
        End If
    End If

    ' Return success
    PatchDLLExport = True

End Function

Private Function PatchToUpper(sFilename)

    '*****************************************************
    '* Patches Fribidi's to_upper definition for exclusion 
	'* on Windows, which already has it as part of its 
	'* standard includes. If the patch is already applied, 
	'* this does not re-apply it. Returns true if 
	'* successful or the patch was already applied, false 
	'* otherwise.
    '*****************************************************

    Dim objFSO, strFilename, ts, strLine, strContents, blHasPatch

    ' Make sure the file exists
    LogDebug "Checking " & sFilename & " for to_upper patch"
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFilename = ExpandPath(sFilename)
    If Not objFSO.FileExists(strFilename) Then
        LogError "Unable to open filename " & sFilename, False
        Set objFSO = Nothing
        Exit Function
    End If

    ' Loop through the file line by line
    Set ts = objFSO.OpenTextFile(strFilename, 1)
    Do While Not ts.AtEndOfStream

        ' Read in and append the line
        strLine = ts.ReadLine
        strContents = strContents & strLine & vbCrLf

        ' Is this the start of the FRIBIDI_ENTRY definition?
        If Left(strLine, 29) = "#else /* !FRIBIDI_USE_GLIB */" Then

            ' Make sure the patch hasn't already been applied
            strLine = ts.ReadLine
            If InStr(strLine, "WIN32") > 0 Then
                Exit Do
            End If
            
            ' Apply the patch for the DLL export
            strContents = strContents & _
                "#if !(defined(HAVE_STDLIB_H) && defined(WIN32))" & vbCrLf & _
                "static char" & vbCrLf & _
                "toupper (" & vbCrLf & _
                "  /* input */" & vbCrLf & _
                "  char c" & vbCrLf & _
                ")" & vbCrLf & _
                "{" & vbCrLf & _
                "  return c < 'a' || c > 'z' ? c : c + 'A' - 'a';" & vbCrLf & _
                "}" & vbCrLf & _
                "#endif" & vbCrLf & vbCrLf
            blHasPatch = True

            ' Skip to the end of the definition
            While Len(Trim(strLine)) <> 0
                strLine = ts.ReadLine
            Wend

        End If
    Loop

    ' Close the file
    ts.Close
    Set ts = Nothing
    Set objFSO = Nothing

    ' If the patch was applied, write it back out
    If blHasPatch Then
        LogInfo "Patching " & sFilename
        If Not WriteFile(strFilename, strContents, False) Then
            LogError "Unable to write filename " & sFilename, False
            Exit Function
        End If
    End If

    ' Return success
    PatchToUpper = True

End Function

Private Function PatchExportDefinitionFile(sFilename)

    '*****************************************************
    '* Patches the export definition file for Fribidi for 
	'* use with VS 2003's linker. If the patch is already 
	'* applied, this does not re-apply it. Returns true if 
    '* successful or the patch was already applied, false 
	'* otherwise.
    '*****************************************************

    Dim objFSO, strFilename, ts, strLine, strContents, blHasPatch

    ' Make sure the file exists
    LogDebug "Checking " & sFilename & " for export definition patch"
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFilename = ExpandPath(sFilename)
    If Not objFSO.FileExists(strFilename) Then
        LogError "Unable to open filename " & sFilename, False
        Set objFSO = Nothing
        Exit Function
    End If

    ' Loop through the file line by line
    Set ts = objFSO.OpenTextFile(strFilename, 1)
    Do While Not ts.AtEndOfStream

        ' Read in the line
        strLine = ts.ReadLine

        ' If the first line and not "EXPORTS", patch the file
        If ts.Line - 1 = 1 Then
            If strLine <> "EXPORTS" Then
                strContents = strContents & "EXPORTS" & vbCrLf
                blHasPatch = True
            Else
                Exit Do
            End If
        End If
        
        ' Append the line
        strContents = strContents & strLine & vbCrLf

    Loop

    ' Close the file
    ts.Close
    Set ts = Nothing
    Set objFSO = Nothing

    ' If the patch was applied, write it back out
    If blHasPatch Then
        LogInfo "Patching " & sFilename
        If Not WriteFile(strFilename, strContents, False) Then
            LogError "Unable to write filename " & sFilename, False
            Exit Function
        End If
    End If

    ' Return success
    PatchExportDefinitionFile = True

End Function

Private Function PatchBenchmark(sFilename)

    '*****************************************************
    '* Patches the benchmark C source file for Fribidi so 
	'* that it has the proper Windows definitions/code for 
	'* obtaining user time. If the patch is already 
	'* applied, this does not re-apply it. Returns true if 
    '* successful or the patch was already applied, false 
	'* otherwise.
    '*****************************************************

    Dim objFSO, strFilename, ts, strLine, strContents, blHasPatch

    ' Make sure the file exists
    LogDebug "Checking " & sFilename & " for benchmark patch"
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFilename = ExpandPath(sFilename)
    If Not objFSO.FileExists(strFilename) Then
        LogError "Unable to open filename " & sFilename, False
        Set objFSO = Nothing
        Exit Function
    End If

    ' Loop through the file line by line
    Set ts = objFSO.OpenTextFile(strFilename, 1)
    Do While Not ts.AtEndOfStream

        ' Read in and append the line
        strLine = ts.ReadLine

        ' Is this the times.h include?
        If InStr(strLine, "<sys/times.h>") > 0 Then

            ' Append the line
            strContents = strContents & strLine & vbCrLf

            ' Make sure the patch hasn't already been applied
            strLine = ts.ReadLine
            If InStr(strLine, "WIN32") > 0 Then
                Exit Do
            End If
            
            ' Add the additional include
            strContents = strContents & "#elif WIN32" & vbCrLf & _
                "# include <windows.h>" & vbCrLf & _
                strLine & vbCrLf
            blHasPatch = True

        ' Is this the struct tms definition?
        ElseIf InStr(strLine, "struct tms") > 0 Then

            ' Move up the HAVE_SYS_TIMES_H check
            strContents = strContents & ts.ReadLine & vbCrLf & strLine & vbCrLf

        ' Is this the times.h warning?
        ElseIf InStr(strLine, "#warning") > 0 Then

            ' Trim the previous line to add the macro check
            strContents = Left(strContents, Len(strContents) - 4)

            ' Add the Windows-specific code (based on Python's posixmodule.c)
            strContents = strContents & "if WIN32" & vbCrLf & _
                "  FILETIME creation, exit, kernel, user;" & vbCrLf & _
                "  GetProcessTimes(GetCurrentProcess(), &creation, &exit, " & _
                "&kernel, &user);" & vbCrLf & _
                "  return 0.01 * (user.dwHighDateTime*429.4967296 + " & _
                "user.dwLowDateTime*1e-7);" & vbCrLf & _
                "#else" & vbCrLf & _
                "  return 0.0;" & vbCrLf
        
        ' Otherwise, append the line as is
        Else
            strContents = strContents & strLine & vbCrLf
        End If

    Loop

    ' Close the file
    ts.Close
    Set ts = Nothing
    Set objFSO = Nothing

    ' If the patch was applied, write it back out
    If blHasPatch Then
        LogDebug "Patching " & sFilename
        If Not WriteFile(strFilename, strContents, False) Then
            LogError "Unable to write filename " & sFilename, False
            Exit Function
        End If
    End If

    ' Return success
    PatchBenchmark = True

End Function

Private Function ReplaceInFile(sFilename, sSearch, sReplace)

    '*****************************************************
    '* Replaces the search string with the specified 
	'* replacement in the given file. If no replacements 
	'* are made, the file is not written back out. Returns 
	'* true if successful, false otherwise. If the file 
    '* does not exist, no error is thrown.
    '*****************************************************

    Dim strFilename, strContents, strNewContents

    ' Get the contents of the file
    LogDebug "Checking " & sFilename & " for replacements"
    strFilename = ExpandPath(sFilename)
    strContents = ReadFile(strFilename)
    If Len(strContents) = 0 Then
        ReplaceInFile = True
        Exit Function
    End If

    ' Perform the replacement
    strNewContents = Replace(strContents, sSearch, sReplace)
    If strContents <> strNewContents Then
        LogInfo "Updating " & sFilename
        ReplaceInFile = WriteFile(strFilename, strNewContents, False)
    Else
        ReplaceInFile = True
    End If

End Function

Private Function ReadFile(sFilename)

    '*****************************************************
    '* Reads the contents of the given file. Returns the 
	'* contents or a zero-length string if the file was 
	'* empty or did not exist.
    '*****************************************************

    Dim objFSO, ts

    ' Read the contents of the file in, if it exists
    LogDebug "Reading file " & sFilename
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FileExists(sFilename) Then
        Set ts = objFSO.OpenTextFile(sFilename, 1)
        If Not ts.AtEndOfStream Then
            ReadFile = ts.ReadAll
        End If
        ts.Close
        Set ts = Nothing
    End If

    ' Cleanup
    Set objFSO = Nothing

End Function

Private Function WriteFile(sFilename, sContents, bAppend)

    '*****************************************************
    '* Writes the given contents to the file. If bAppend 
	'* is true, appends the contents. This method will 
	'* create the file if it does not already exists, but 
	'* it will not create its containing folder. Returns 
    '* true if successful, false otherwise.
    '*****************************************************

    Dim intMode, intFormat, objFSO, ts

    ' Determine the output mode
    If bAppend Then
        intMode = 8
    Else
        intMode = 2
    End If

    ' Write the contents of the file out
    LogDebug "Writing file " & sFilename
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set ts = objFSO.OpenTextFile(sFilename, intMode, True)
    ts.Write sContents
    ts.Close
    Set ts = Nothing
    Set objFSO = Nothing

    ' Indicate success
    WriteFile = True

End Function

Private Function CopyFile(sFilename, sTarget)

    '*****************************************************
    '* Copies a file to the given folder. Returns true if 
	'* successful, false otherwise.
    '*****************************************************

    Dim objFSO, strTarget

    ' Make sure the source file exists
    LogDebug "Copying " & sFilename & " to " & sTarget
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If Not objFSO.FileExists(sFilename) Then
        Set objFSO = Nothing
        Exit Function
    End If

    ' Add a trailing slash, if there is none
    strTarget = sTarget
    If Right(strTarget, 1) <> "\" Then
        strTarget = strTarget & "\"
    End If

    ' Make sure the target directory exists
    If Not objFSO.FolderExists(strTarget) Then
        Set objFSO = Nothing
        Exit Function
    End If

    ' Copy the file to the destination
    objFSO.CopyFile sFilename, strTarget, True
    Set objFSO = Nothing
    CopyFile = True

End Function

Private Function DeleteFile(sFilename)

    '*****************************************************
    '* Deletes the specified file. Returns true if 
	'* successful or the file did not exist, false 
	'* otherwise.
    '*****************************************************

    On Error Resume Next

    Dim objFSO

    ' Delete the file, if it exists
    LogDebug "Deleting file " & sFilename
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FileExists(sFilename) Then
        objFSO.DeleteFile sFilename, True
    End If
    Set objFSO = Nothing

    ' Check for success
    If Err.Number <> 0 Then
        LogError "Unable to delete file " & sFilename, False
        DeleteFile = False
        Err.Clear
    Else
        DeleteFile = True
    End If

End Function

Private Function DeleteFolder(sPath)

    '*****************************************************
    '* Deletes the specified folder. Returns true if 
	'* successful or the folder did not exist, false 
	'* otherwise.
    '*****************************************************

    On Error Resume Next

    Dim objFSO

    ' Delete the folder, if it exists
    LogDebug "Deleting folder " & sPath
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If objFSO.FolderExists(sPath) Then
        objFSO.DeleteFolder sPath, True
    End If
    Set objFSO = Nothing

    ' Check for success
    If Err.Number <> 0 Then
        LogError "Unable to delete folder " & sPath, False
        DeleteFolder = False
        Err.Clear
    Else
        DeleteFolder = True
    End If

End Function

Private Function DeleteFiles(sFolder, sFiles)

    '*****************************************************
    '* Deletes all files with the given file extension 
	'* list in the specified folder. The extension list is 
	'* a semi-colon-delimited list of wildcard extensions 
    '* (e.g., *.c). If the folder does not exist, returns 
	'* false. Returns true if all files were successfully 
	'* deleted or no matching files were found, false 
    '* otherwise.
    '*****************************************************

    On Error Resume Next

    Dim objFSO, arFiles, strFile, strFilename

    ' Make sure the folder exists
    LogDebug "Deleting files from " & sFolder
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    If Not objFSO.FolderExists(sFolder) Then
        Set objFSO = Nothing
        Exit Function
    End If

    ' Loop through the files, deleting any matches
    arFiles = Split(sFiles, ";")
    For Each strFile In arFiles
        strFilename = objFSO.BuildPath(sFolder, strFile)
        LogDebug "Deleting " & strFilename
        objFSO.DeleteFile strFilename, True
        If Err.Number = 53 Then
            Err.Clear
        ElseIf Err.Number <> 0 Then
            LogError "Unable to delete file " & strFilename & ": " & _
                Err.Description & " (" & Err.Number & ")", False
            Set objFSO = Nothing
            Exit Function
        End If
    Next
    Set objFSO = Nothing

    ' Indicate success
    DeleteFiles = True

End Function

Private Function FileExists(sPath)

    '*****************************************************
    '* Returns true if the given file path exists, false 
	'* otherwise.
    '*****************************************************

    Dim objFSO

    ' Check if a file exists
    LogDebug "Checking for file " & sPath
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    FileExists = objFSO.FileExists(sPath)
    Set objFSO = Nothing

End Function

Private Function ReplaceExtension(sFilename, sExtension, bStripPath)

    '*****************************************************
    '* Replaces the filename's extension with the given 
	'* extension. If the filename had no extension, 
	'* appends the extension to it. The extension should 
	'* not contain a leading dot. If bStripPath is true, 
    '* returns the base name with the extension, removing 
	'* any leading folder paths.
    '*****************************************************

    Dim objFSO, strExtension, strFilename

    ' Find and replace the extension
    LogDebug "Replacing extension on " & sFilename
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strExtension = objFSO.GetExtensionName(sFilename)
    strFilename = sFilename
    If Len(strExtension) > 0 Then
        strFilename = Left(strFilename, Len(strFilename) - Len(strExtension) - 1)
    End If
    strFilename = strFilename & "." & sExtension
    If bStripPath Then
        strFilename = objFSO.GetFilename(strFilename)
    End If
    ReplaceExtension = strFilename
    Set objFSO = Nothing

End Function

Private Function BuildPath(sFolder, sFilename, bExpand)

    '*****************************************************
    '* Builds a path by combining the folder and filename. 
	'* If bExpand is true, appends the base directory, if 
	'* configured.
    '*****************************************************

    Dim objFSO

    ' Build and return the path
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    BuildPath = objFSO.BuildPath(sFolder, sFilename)
    If bExpand And Len(strBaseDirectory) > 0 Then
        BuildPath = objFSO.BuildPath(strBaseDirectory, BuildPath)
    End If
    Set objFSO = Nothing

End Function

Private Function BuildPaths(sFolder, aFilenames, sSeparator, bExpand)

    '*****************************************************
    '* Builds a path list. This method appends the folder 
	'* name, if not null, to each filename in aFilenames. 
	'* If bExpand is true, each resulting path is also 
    '* expanded with the base directory, if configured. 
	'* The resulting path list is joined with sSeparator. 
	'* Returns the resulting string.
    '*****************************************************

    Dim objFSO, strFilename, strPath, strPaths

    ' Loop through each filename, adding it to the paths
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    For Each strFilename In aFilenames
        If IsNull(sFolder) Then
            strPath = strFilename
        Else
            strPath = objFSO.BuildPath(sFolder, strFilename)
        End If
        If bExpand And Len(strBaseDirectory) Then
            strPath = objFSO.BuildPath(strBaseDirectory, strPath)
        End If
        strFilename = """" & strPath & """"
        strPaths = strPaths & strFilename & sSeparator
    Next

    ' Trim off the trailing separator
    If Len(sSeparator) > 0 And Len(strPaths) > 0 Then
        strPaths = Left(strPaths, Len(strPaths) - Len(sSeparator))
    End If

    ' Return the final paths
    BuildPaths = strPaths
    Set objFSO = Nothing

End Function

Private Function ExpandPath(sPath)

    '*****************************************************
    '* Expands a path with the base directory if 
	'* configured.
    '*****************************************************

    Dim objFSO

    ' Expand and return the path
    ExpandPath = sPath
    If Len(strBaseDirectory) > 0 Then
        Set objFSO = CreateObject("Scripting.FileSystemObject")
        ExpandPath = objFSO.BuildPath(strBaseDirectory, sPath)
        Set objFSO = Nothing
    End If

End Function

Private Function GetFiles(aFolders, sExtensions)

    '*****************************************************
    '* Returns an array of all files in the given array of 
	'* folders that match the semi-colon delimited list of 
	'* extensions. Extensions should be specified as 
	'* wildcards (e.g, *.c). If a specified folder does not 
	'* exist, it is skipped.
    '*****************************************************

    Dim objFSO, objFiles, strFolder, strPath, fld, fl, strExtension, strFile

    ' Prepare for the indexing
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    Set objFiles = CreateObject("Scripting.Dictionary")
    sExtensions = sExtensions & ";"

    ' Loop through each folder
    For Each strFolder In aFolders

        ' Check if the folder exists
        strPath = ExpandPath(strFolder)
        If objFSO.FolderExists(strPath) Then

            ' Loop through each file in the folder
            Set fld = objFSO.GetFolder(strPath)
            For Each fl In fld.Files

                ' Add the file if it matches one of the extensions
                strExtension = "*." & objFSO.GetExtensionName(fl.Name)
                If InStr(1, sExtensions, strExtension, 1) > 0 Then
                    strFile = fld.Name & "\" & fl.Name
                    objFiles.Add objFiles.Count, strFile
                End If

            Next

            ' Cleanup
            Set fl = Nothing
            Set fld = Nothing

        End If

    Next

    ' Return the array of files
    GetFiles = objFiles.Items()
    Set objFiles = Nothing
    Set objFSO = Nothing

End Function

Private Function Run(sCommand, sOutputFilename)

    '*****************************************************
    '* Runs the specified command. If sOutputFilename is 
	'* null, StdOut is discarded. If zero-length, StdOut 
	'* is sent to the screen. Otherwise, it's assumed to 
    '* be a filename to redirect StdOut to. This method 
	'* won't return until the process completes. Returns 
	'* true if the process exited with a status code of 0 
	'* and there were no errors redirecting StdOut, false 
    '* otherwise.
    '*****************************************************

    Dim objShell, objExec, blStreamError, dumb

    ' Delete the output file, if specified
    If Not IsNull(sOutputFilename) Then
        If Len(sOutputFilename) > 0 Then
            DeleteFile sOutputFilename
        End If
    End If

    ' Enable error handling to handle missing commands
    On Error Resume Next
	dumb = WriteFile(strLogPath, sCommand & vbCrLf, True)

    ' Run the specified command
    LogDebug "Running " & sCommand
    Set objShell = CreateObject("WScript.Shell")
    Set objExec = objShell.Exec(sCommand)
    If Err.Number <> 0 Then
        LogError "Unable to launch command " & GetProcessName(sCommand), False
        Set objExec = Nothing
        Set objShell = Nothing
        Exit Function
    End If

    ' Clear the error handling
    On Error GoTo 0

    ' Wait until the application finishes
    While objExec.Status = 0
        If Not ProcessStreams(objExec, sOutputFilename) Then
            blStreamError = True
        End If
        WScript.Sleep 100
    Wend

    ' Check for any remaining output
    If Not ProcessStreams(objExec, sOutputFilename) Then    
        blStreamError = True
    End If

    ' Check the exit code
    If objExec.ExitCode <> 0 Then
        LogError GetProcessName(sCommand) & " exited with status " & _
            objExec.ExitCode, False
        If Not IsNull(sOutputFilename) Then
            If Len(sOutputFilename) > 0 Then
                DeleteFile sOutputFilename
            End If
        End If
    Else
        Run = Not blStreamError
    End If

    ' Cleanup
    Set objExec = Nothing
    Set objShell = Nothing

End Function

Private Function ProcessStreams(oExec, sOutputFilename)

    '*****************************************************
    '* Processes the output and error streams for a 
	'* process. If sOutputFilename is null, StdOut is 
	'* ignored. If it's a zero-length string, StdOut is 
	'* sent to the screen. Otherwise, it's assumed to be a 
    '* filename to redirect StdOut to. Output is append to 
	'* the file. If an error occurs writing to the file, 
	'* this method returns false. All StdErr output is 
    '* always sent to the screen.
    '*****************************************************

    ' Assume success
    ProcessStreams = True

    ' Check for contents on standard out
    If Not oExec.StdOut.AtEndOfStream Then
        If Not IsNull(sOutputFilename) Then
            If Len(sOutputFilename) > 0 Then
                If Not WriteFile(sOutputFilename, oExec.StdOut.ReadAll, True) Then
                    LogError "Unable to append output to " & sOutputFilename, False
                    ProcessStreams = False
                End If
            Else
                LogInfo oExec.StdOut.ReadAll
            End If
        End If
    End If

    ' Check for contents on the error stream
    If Not oExec.StdErr.AtEndOfStream Then
        LogError oExec.StdErr.ReadAll, False
    End If

End Function

Private Function GetProcessName(sCommand)

    '*****************************************************
    '* Gets the process name from a command. The process 
	'* name is anything up to the first space. This 
	'* doesn't handle the case where the process name is 
	'* enclosed in quotes and contains spaces.
    '*****************************************************

    Dim strProcessName, intIndex

    ' Get the process name from the command
    strProcessName = sCommand
    intIndex = InStr(strProcessName, " ")
    If intIndex > 0 Then
        strProcessName = Left(strProcessName, intIndex - 1)
    End If

    ' Return the final name
    GetProcessName = strProcessName

End Function

Private Function RunGenerator(sPath, aInputs, sOutput, bUseCompression)

    '*****************************************************
    '* Runs a generator. sPath is the path to the 
	'* generator executable, aInputs is an an array of 
	'* input files, and sOutput is the output file. If 
	'* bCompression is true, the generator will use 
	'* compression. Returns true if successful, false 
    '* otherwise.
    '*****************************************************

    Dim strCommand

    ' Build the command
    LogInfo "Generating " & sOutput
    strCommand = ExpandPath(sPath)
    If bUseCompression Then
        strCommand = strCommand & " " & intCompression
    End If
    If Not IsNull(aInputs) Then
        strCommand = strCommand & " " & _
            BuildPaths(strUnicodeData, aInputs, " ", True)
    End If

    ' Run and return
    RunGenerator = Run(strCommand, ExpandPath(sOutput))

End Function

Private Function RunTests(sPath, sFolder)

    '*****************************************************
    '* Runs all tests in the given folder. sPath is the 
	'* path to the fribidi.exe file. A test file is 
	'* expected to have the form test_....input. Returns 
	'* true if successful, false otherwise.
    '*****************************************************

    Dim objReg, objFSO, strPath, fl, blError

    ' Create the RegEx to check the test files
    LogDebug "Running tests on " & sPath
    Set objReg = New RegExp
    objReg.Global = True
    objReg.IgnoreCase = True
    objReg.Pattern = "test_[^\.]+.input"

    ' Make sure the test directory exists
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strPath = ExpandPath(sFolder)
    If Not objFSO.FolderExists(strPath) Then
        LogError "Unable to locate test directory " & sFolder, False
        Set objFSO = Nothing
        Exit Function
    End If

    ' Run the tests
    For Each fl In objFSO.GetFolder(strPath).Files
        If objReg.Test(fl.Name) Then
            If Not RunTest(sPath, sFolder, objFSO.GetBaseName(fl.Name)) Then
                blError = True
            End If
        End If
    Next

    ' Cleanup and return
    Set fl = Nothing
    Set objFSO = Nothing
    Set objReg = Nothing
    RunTests = Not blError

End Function

Private Function RunTest(sPath, sFolder, sTest)

    '*****************************************************
    '* Runs the specified test. sPath is the path to the 
	'* fribidi.exe file, sFolder is the folder containing 
	'* the test files, and sTest is the test to run, minus 
	'* any extension. Returns true if successful, false 
	'* otherwise.
    '*****************************************************

    Dim objReg, objMatches, strCharacterSet, strInput, strOutput, strReference
    Dim strCommand

    ' Log that the test is starting
    LogDebug "Running test " & sTest

    ' Determine the character set from the test
    Set objReg = New RegExp
    objReg.Global = True
    objReg.IgnoreCase = True
    objReg.Pattern = "^[^\_]+_([^_]+)_.*"
    Set objMatches = objReg.Execute(sTest)
    If objMatches.Count > 0 Then
        strCharacterSet = objMatches(0).SubMatches(0)
        LogDebug "Character set for test " & sTest & " is " & strCharacterSet
    End If
    Set objMatches = Nothing
    Set objReg = Nothing

    ' If no character set, abort the test
    If Len(strCharacterSet) = 0 Then
        LogError "Unable to determine character set for test " & sTest, False
        Exit Function
    End If

    ' Determine the filenames
    strInput = BuildPath(sFolder, sTest & ".input", True)
    strOutput = BuildPath(sFolder, sTest & ".output", True)
    strReference = BuildPath(sFolder, sTest & ".reference", True)

    ' Run the test
    strCommand = ExpandPath(sPath) & " --test --charset """ & _
        strCharacterSet & """ """ & strInput & """"
    If Not Run(strCommand, strOutput) Then
        LogError "Character set " & strCharacterSet & " not supported", False
        DeleteFile strOutput
        Exit Function
    End If

    ' Check the files
    LogDebug "Checking output for test " & sTest
    strCommand = strDiffPath & " -U 0 """ & strOutput & """ """ & _
        strReference & """"
    If Not Run(strCommand, Null) Then
        LogError "Test " & sTest & " failed", False
    Else
        LogInfo "Test " & sTest & " passed"
        RunTest = True
    End If

    ' Delete the output file
    If Not blKeepFiles Then
        DeleteFile strOutput
    End If

End Function

Private Function Compile(sFolder, aSources, sOutput, bClean)

    '*****************************************************
    '* Compiles C source files. sFolder is the output 
	'* folder, aSource is an array of C source files, and 
	'* sOutput is the final name of the application/
	'* library. If bClean is true, deletes the command 
	'* file used. Returns true if successful, false 
    '* otherwise.
    '*****************************************************

    Dim arSources, strOptional, strContents, strFilename, strCommand, dumb

    ' Compiler wants at least one source file; grab the last one
    LogDebug "Compiling " & sOutput
    ReDim arSources(UBound(aSources) - 1)
    CopyArray aSources, arSources, 0, UBound(arSources)

    ' Determine the optional flags
    If LCase(Right(sOutput, 3)) = "dll" Then
        strOptional = "/D ""_WINDLL"" "
    End If

    ' Create the command file contents
    strContents = "/Ox /Ob2 /Oi /Ot /Oy /GT /I """ & ExpandPath("charset") & _
        """ /I """ & ExpandPath("lib") & """ /I """ & ExpandPath("win") & _
        """ /D ""WIN32"" /D ""NDEBUG"" /D ""HAVE_CONFIG_H"" /D " & _
        """BUILDING_FRIBIDI"" " & strOptional & "/FD /EHsc /MT /GS /Zc:wchar_t " & _
        "/Zc:forScope /GR /Fo""" & Replace(sFolder, "\", "/") & """ /Fd""" & _
        BuildPath(sFolder, "vc70.pdb", False) & """ /W1 /c /TC" & vbCrLf & _
        BuildPaths(Null, arSources, vbCrLf, True)
    
    ' Write out the command file contents
    strFilename = GetTempFilename(sFolder)
    LogDebug "Writing contents to " & strFilename & ": [" & strContents & "]"
    If Not WriteFile(strFilename, strContents, False) Then
        LogError "Unable to write temporary file " & strFilename, False
        Exit Function
    End If

    ' Build & run the command
    strCommand = strCompilerPath & " @""" & strFilename & """ " & _
        ExpandPath(aSources(UBound(aSources))) & " /nologo"
    Compile = Run(strCommand, "")
    dumb = WriteFile(strLogPath, "==================" & vbCrLf, True)
    dumb = WriteFile(strLogPath, strFileName & vbCrLf, True)
    dumb = WriteFile(strLogPath, strContents & vbCrLf, True)
    dumb = WriteFile(strLogPath, "==================" & vbCrLf & vbCrLf, True)

    ' Delete the temporary file
    If bClean Then
        DeleteFile strFilename
    End If

End Function

Private Function Link(sFolder, aSources, sOutput, bClean)

    '*****************************************************
    '* Links a C application/library. sFolder is the 
	'* output folder, aSources is an array of object 
	'* files, and sOutput is the name of the output. If 
	'* bClean is true, deletes the command file used. 
	'* Returns true if successful, false otherwise.
    '*****************************************************

    Dim strOptional, strPath, strLibraries, strContents, strFilename
    Dim strLibrary, strCommand, dumb

    ' Determine the optional flags
    LogDebug "Linking " & sOutput
    If LCase(Right(sOutput, 3)) = "dll" Then
        strOptional = "/DLL "
    End If

    ' Check for an export definition file
    strPath = BuildPath(sFolder, ReplaceExtension(sOutput, "def", False), False)
    If FileExists(strPath) Then
        strOptional = strOptional & "/DEF:""" & strPath & """ "
    End If

    ' Determine the additional libraries to use
    strPath = ExpandPath("lib\fribidi.lib")
    If FileExists(strPath) Then
        strLibraries = " """ & strPath & """"
    End If

    ' Create the command file contents
    strLibrary = ReplaceExtension(sOutput, "lib", False)
    strContents = "/OUT:""" & BuildPath(sFolder, sOutput, False) & """ /NOLOGO " & _
        strOptional & "/IMPLIB:""" & BuildPath(sFolder, strLibrary, False) & _
        """ kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib " & _
        "advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib " & _
        "odbccp32.lib" & strLibraries & vbCrLf & _
        BuildPaths(Null, aSources, vbCrLf, False)
    
    ' Write out the command file contents
    strFilename = GetTempFilename(sFolder)
    LogDebug "Writing contents to " & strFilename & ": [" & strContents & "]"
    If Not WriteFile(strFilename, strContents, False) Then
        LogError "Unable to write temporary file " & strFilename, False
        Exit Function
    End If

    ' Build & run the command
    strCommand = strLinkerPath & " @""" & strFilename & """"
    Link = Run(strCommand, "")
    dumb = WriteFile(strLogPath, "==================" & vbCrLf, True)
    dumb = WriteFile(strLogPath, strFileName & vbCrLf, True)
    dumb = WriteFile(strLogPath, strContents & vbCrLf, True)
    dumb = WriteFile(strLogPath, "==================" & vbCrLf & vbCrLf, True)

    ' Delete the temporary file
    If bClean Then
        DeleteFile strFilename
    End If

End Function

Private Function Build(sFolder, aSources, sOutput, bClean)

    '*****************************************************
    '* Builds a C application/library. sFolder is the 
	'* folder to use for the build process and to save the 
	'* output to, aSources is an array of C source files, 
    '* and sOutput is the name of the output. If bClean is 
	'* true, all temporary files used for the build will 
	'* be deleted upon a successful build. Returns true if 
    '* successful, false otherwise.
    '*****************************************************

    Dim strFolder, arObjects, intCount

    ' Add a trailing slash to the folder, if necessary
    LogInfo "Building " & sOutput
    strFolder = ExpandPath(sFolder)
    If Right(strFolder, 1) <> "\" Then
        strFolder = strFolder & "\"
    End If

    ' Compile the application
    If Not Compile(strFolder, aSources, sOutput, bClean) Then
        LogError "Unable to compile " & sOutput, False
        Exit Function
    End If

    ' Update the extension for the objects
    ReDim arObjects(UBound(aSources))
    For intCount = 0 To UBound(arObjects)
        arObjects(intCount) = strFolder & ReplaceExtension( _
            aSources(intCount), "obj", True)
    Next

    ' Link the application
    If Not Link(strFolder, arObjects, sOutput, bClean) Then
        LogError "Unable to link " & sOutput, False
        Exit Function
    End If

    ' Clean up if requested
    If bClean Then
        DeleteFiles strFolder, "*.obj;*.ilk;*.pdb;*.tlb;*.tli;*.tlh;*.tmp;" & _
            "*.rsp;*.bat;*.idb"
    End If

    ' Return success
    Build = True

End Function

Private Function GetTempFilename(sFolder)

    '*****************************************************
    '* Returns an available temporary filename in the 
	'* given folder. This does not create the file.
    '*****************************************************

    Dim objFSO, strFilename

    ' Generate a temporary filename that does not exist
    Set objFSO = CreateObject("Scripting.FileSystemObject")
    strFilename = objFSO.BuildPath(sFolder, objFSO.GetTempName)
    While objFSO.FileExists(strFilename)
        strFilename = objFSO.GetTempName
    Wend
    
    ' Return & cleanup
    GetTempFilename = strFilename
    Set objFSO = Nothing

End Function

Private Sub CopyArray(aSource, aTarget, iStart, iStop)

    '*****************************************************
    '* Copies the specified range of the source array to 
	'* the target array. The target array must already be 
	'* the correct size.
    '*****************************************************

    Dim intCount, intItem

    ' Copy the requested elements to the target
    For intCount = iStart To iStop
        aTarget(intItem) = aSource(intCount)
        intItem = intItem + 1
    Next

End Sub

Private Sub LogDebug(sMessage)

    '*****************************************************
    '* Writes out the message to standard out if debugging 
	'* is enabled.
    '*****************************************************

    ' Write out the debug message, if debugging
    If blDebug Then
		Dim dumb
		If popupMessages then
			WScript.Echo "DBG: " & sMessage
		Else
			dumb = WriteFile(strLogPath, "DBG: " & sMessage & vbCrLf, True)
		End If
    End If

End Sub

Private Sub LogInfo(sMessage)

    '*****************************************************
    '* Writes out the message to standard out.
    '*****************************************************

    ' Write out the info message
	Dim dumb
    If popupMessages then
		WScript.Echo sMessage
	Else
		dumb = WriteFile(strLogPath, sMessage & vbCrLf, True)
	End If

End Sub

Private Sub LogError(sMessage, bQuit)

    '*****************************************************
    '* Writes out the error message to standard out and 
	'* quits with exit code 1 if bQuit is true.
    '*****************************************************

    ' Write out the error message
	Dim dumb
    If popupMessages then
		WScript.Echo "ERR: " & sMessage
	Else
		dumb = WriteFile(strLogPath, "ERR: " & sMessage & vbCrLf, True)
	End If

    ' Quit if requested
    If bQuit Then
        WScript.Quit 1
    End If

End Sub
