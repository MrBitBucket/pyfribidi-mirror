echo cleaning the source folder
rm -f "fribidi-0.19.6\bin\fribidi-benchmark.exe
rm -f "fribidi-0.19.6\bin\fribidi-benchmark.obj
rm -f "fribidi-0.19.6\bin\fribidi-bidi-types.exe
rm -f "fribidi-0.19.6\bin\fribidi-bidi-types.obj
rm -f "fribidi-0.19.6\bin\fribidi-caprtl2utf8.exe
rm -f "fribidi-0.19.6\bin\fribidi-caprtl2utf8.obj
rm -f "fribidi-0.19.6\bin\fribidi-main.obj
rm -f "fribidi-0.19.6\bin\fribidi.dll
rm -f "fribidi-0.19.6\bin\fribidi.exe
rm -f "fribidi-0.19.6\bin\fribidi.lib
rm -f "fribidi-0.19.6\bin\getopt.obj
rm -f "fribidi-0.19.6\bin\getopt1.obj
rm -f "fribidi-0.19.6\bin\vc70.idb
rm -f "fribidi-0.19.6\gen.tab\gen-arabic-shaping-tab.exe
rm -f "fribidi-0.19.6\gen.tab\gen-arabic-shaping-tab.obj
rm -f "fribidi-0.19.6\gen.tab\gen-bidi-type-tab.exe
rm -f "fribidi-0.19.6\gen.tab\gen-bidi-type-tab.obj
rm -f "fribidi-0.19.6\gen.tab\gen-joining-type-tab.exe
rm -f "fribidi-0.19.6\gen.tab\gen-joining-type-tab.obj
rm -f "fribidi-0.19.6\gen.tab\gen-mirroring-tab.exe
rm -f "fribidi-0.19.6\gen.tab\gen-mirroring-tab.obj
rm -f "fribidi-0.19.6\gen.tab\gen-unicode-version.exe
rm -f "fribidi-0.19.6\gen.tab\gen-unicode-version.obj
rm -f "fribidi-0.19.6\gen.tab\packtab.obj
rm -f "fribidi-0.19.6\gen.tab\vc70.idb
rm -f "fribidi-0.19.6\lib\fribidi-arabic.obj
rm -f "fribidi-0.19.6\lib\fribidi-bidi-types.obj
rm -f "fribidi-0.19.6\lib\fribidi-bidi.obj
rm -f "fribidi-0.19.6\lib\fribidi-char-sets-cap-rtl.obj
rm -f "fribidi-0.19.6\lib\fribidi-char-sets-cp1255.obj
rm -f "fribidi-0.19.6\lib\fribidi-char-sets-cp1256.obj
rm -f "fribidi-0.19.6\lib\fribidi-char-sets-iso8859-6.obj
rm -f "fribidi-0.19.6\lib\fribidi-char-sets-iso8859-8.obj
rm -f "fribidi-0.19.6\lib\fribidi-char-sets-utf8.obj
rm -f "fribidi-0.19.6\lib\fribidi-char-sets.obj
rm -f "fribidi-0.19.6\lib\fribidi-deprecated.obj
rm -f "fribidi-0.19.6\lib\fribidi-joining-types.obj
rm -f "fribidi-0.19.6\lib\fribidi-joining.obj
rm -f "fribidi-0.19.6\lib\fribidi-mem.obj
rm -f "fribidi-0.19.6\lib\fribidi-mirroring.obj
rm -f "fribidi-0.19.6\lib\fribidi-run.obj
rm -f "fribidi-0.19.6\lib\fribidi-shape.obj
rm -f "fribidi-0.19.6\lib\fribidi.dll
rm -f "fribidi-0.19.6\lib\fribidi.exp
rm -f "fribidi-0.19.6\lib\fribidi.lib
rm -f "fribidi-0.19.6\lib\fribidi.obj
rm -f "fribidi-0.19.6\lib\vc70.idb
rm -f "fribidi-0.19.6\test\test_CapRTL_explicit.output
rm -f "fribidi-0.19.6\test\test_CapRTL_implicit.output
rm -f "fribidi-0.19.6\test\test_ISO8859-8_hebrew.output
rm -f "fribidi-0.19.6\test\test_UTF-8_persian.output
rm -f "fribidi-0.19.6\test\test_UTF-8_reordernsm.output

cl.exe fribidi-0.19.6\gen.tab\packtab.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/gen.tab/" /Fd"fribidi-0.19.6\gen.tab\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\gen.tab\gen-unicode-version.c"
link.exe /OUT:"fribidi-0.19.6\gen.tab\gen-unicode-version.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\gen.tab\gen-unicode-version.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\gen.tab\gen-unicode-version.obj" "fribidi-0.19.6\gen.tab\packtab.obj"
fribidi-0.19.6\gen.tab\gen-unicode-version.exe "fribidi-0.19.6\gen.tab\unidata\ReadMe.txt" "fribidi-0.19.6\gen.tab\unidata\BidiMirroring.txt" > "fribidi-0.19.6\lib\fribidi-unicode-version.h"
cl.exe  fribidi-0.19.6\gen.tab\packtab.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/gen.tab/" /Fd"fribidi-0.19.6\gen.tab\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\gen.tab\gen-bidi-type-tab.c"
link.exe /OUT:"fribidi-0.19.6\gen.tab\gen-bidi-type-tab.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\gen.tab\gen-bidi-type-tab.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\gen.tab\gen-bidi-type-tab.obj" "fribidi-0.19.6\gen.tab\packtab.obj"
fribidi-0.19.6\gen.tab\gen-bidi-type-tab.exe 2 "fribidi-0.19.6\gen.tab\unidata\UnicodeData.txt" > "fribidi-0.19.6\lib\bidi-type.tab.i"
cl.exe fribidi-0.19.6\gen.tab\packtab.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/gen.tab/" /Fd"fribidi-0.19.6\gen.tab\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\gen.tab\gen-joining-type-tab.c"
link.exe /OUT:"fribidi-0.19.6\gen.tab\gen-joining-type-tab.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\gen.tab\gen-joining-type-tab.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\gen.tab\gen-joining-type-tab.obj" "fribidi-0.19.6\gen.tab\packtab.obj"
fribidi-0.19.6\gen.tab\gen-joining-type-tab.exe 2 "fribidi-0.19.6\gen.tab\unidata\UnicodeData.txt" "fribidi-0.19.6\gen.tab\unidata\ArabicShaping.txt" > "fribidi-0.19.6\lib\joining-type.tab.i"
cl.exe fribidi-0.19.6\gen.tab\packtab.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/gen.tab/" /Fd"fribidi-0.19.6\gen.tab\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\gen.tab\gen-arabic-shaping-tab.c"
link.exe /OUT:"fribidi-0.19.6\gen.tab\gen-arabic-shaping-tab.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\gen.tab\gen-arabic-shaping-tab.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\gen.tab\gen-arabic-shaping-tab.obj" "fribidi-0.19.6\gen.tab\packtab.obj"
fribidi-0.19.6\gen.tab\gen-arabic-shaping-tab.exe 2 "fribidi-0.19.6\gen.tab\unidata\UnicodeData.txt" > "fribidi-0.19.6\lib\arabic-shaping.tab.i"
cl.exe fribidi-0.19.6\gen.tab\packtab.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/gen.tab/" /Fd"fribidi-0.19.6\gen.tab\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\gen.tab\gen-mirroring-tab.c"
link.exe /OUT:"fribidi-0.19.6\gen.tab\gen-mirroring-tab.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\gen.tab\gen-mirroring-tab.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\gen.tab\gen-mirroring-tab.obj" "fribidi-0.19.6\gen.tab\packtab.obj"
fribidi-0.19.6\gen.tab\gen-mirroring-tab.exe 2 "fribidi-0.19.6\gen.tab\unidata\BidiMirroring.txt" > "fribidi-0.19.6\lib\mirroring.tab.i"
cl.exe fribidi-0.19.6\lib\fribidi.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /D "_WINDLL" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/lib/" /Fd"fribidi-0.19.6\lib\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\charset\fribidi-char-sets-cap-rtl.c" "fribidi-0.19.6\charset\fribidi-char-sets-cp1255.c" "fribidi-0.19.6\charset\fribidi-char-sets-cp1256.c" "fribidi-0.19.6\charset\fribidi-char-sets-iso8859-6.c" "fribidi-0.19.6\charset\fribidi-char-sets-iso8859-8.c" "fribidi-0.19.6\charset\fribidi-char-sets-utf8.c" "fribidi-0.19.6\charset\fribidi-char-sets.c" "fribidi-0.19.6\lib\fribidi-arabic.c" "fribidi-0.19.6\lib\fribidi-bidi-types.c" "fribidi-0.19.6\lib\fribidi-bidi.c" "fribidi-0.19.6\lib\fribidi-deprecated.c" "fribidi-0.19.6\lib\fribidi-joining-types.c" "fribidi-0.19.6\lib\fribidi-joining.c" "fribidi-0.19.6\lib\fribidi-mem.c" "fribidi-0.19.6\lib\fribidi-mirroring.c" "fribidi-0.19.6\lib\fribidi-run.c" "fribidi-0.19.6\lib\fribidi-shape.c"
link.exe /OUT:"fribidi-0.19.6\lib\fribidi.dll" /NOLOGO /DLL /DEF:"fribidi-0.19.6\lib\fribidi.def" /IMPLIB:"fribidi-0.19.6\lib\fribidi.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\lib\fribidi-char-sets-cap-rtl.obj" "fribidi-0.19.6\lib\fribidi-char-sets-cp1255.obj" "fribidi-0.19.6\lib\fribidi-char-sets-cp1256.obj" "fribidi-0.19.6\lib\fribidi-char-sets-iso8859-6.obj" "fribidi-0.19.6\lib\fribidi-char-sets-iso8859-8.obj" "fribidi-0.19.6\lib\fribidi-char-sets-utf8.obj" "fribidi-0.19.6\lib\fribidi-char-sets.obj" "fribidi-0.19.6\lib\fribidi-arabic.obj" "fribidi-0.19.6\lib\fribidi-bidi-types.obj" "fribidi-0.19.6\lib\fribidi-bidi.obj" "fribidi-0.19.6\lib\fribidi-deprecated.obj" "fribidi-0.19.6\lib\fribidi-joining-types.obj" "fribidi-0.19.6\lib\fribidi-joining.obj" "fribidi-0.19.6\lib\fribidi-mem.obj" "fribidi-0.19.6\lib\fribidi-mirroring.obj" "fribidi-0.19.6\lib\fribidi-run.obj" "fribidi-0.19.6\lib\fribidi-shape.obj" "fribidi-0.19.6\lib\fribidi.obj"
copy "fribidi-0.19.6\lib\fribidi.dll" "fribidi-0.19.6\bin"
copy "fribidi-0.19.6\lib\fribidi.lib" "fribidi-0.19.6\bin"
cl.exe fribidi-0.19.6\bin\getopt.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/bin/" /Fd"fribidi-0.19.6\bin\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\bin\fribidi-main.c" "fribidi-0.19.6\bin\getopt1.c"
link.exe /OUT:"fribidi-0.19.6\bin\fribidi.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\bin\fribidi.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\lib\fribidi.lib" "fribidi-0.19.6\bin\fribidi-main.obj" "fribidi-0.19.6\bin\getopt1.obj" "fribidi-0.19.6\bin\getopt.obj"
cl.exe fribidi-0.19.6\bin\getopt.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/bin/" /Fd"fribidi-0.19.6\bin\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\bin\fribidi-benchmark.c" "fribidi-0.19.6\bin\getopt1.c"
link.exe /OUT:"fribidi-0.19.6\bin\fribidi-benchmark.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\bin\fribidi-benchmark.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\lib\fribidi.lib" "fribidi-0.19.6\bin\fribidi-benchmark.obj" "fribidi-0.19.6\bin\getopt1.obj" "fribidi-0.19.6\bin\getopt.obj"
cl.exe fribidi-0.19.6\bin\getopt.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/bin/" /Fd"fribidi-0.19.6\bin\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\bin\fribidi-bidi-types.c" "fribidi-0.19.6\bin\getopt1.c"
link.exe /OUT:"fribidi-0.19.6\bin\fribidi-bidi-types.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\bin\fribidi-bidi-types.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\lib\fribidi.lib" "fribidi-0.19.6\bin\fribidi-bidi-types.obj" "fribidi-0.19.6\bin\getopt1.obj" "fribidi-0.19.6\bin\getopt.obj"
cl.exe fribidi-0.19.6\bin\getopt.c /nologo /Ox /Ob2 /Oi /Ot /Oy /GT /I "fribidi-0.19.6\charset" /I "fribidi-0.19.6\lib" /I "fribidi-0.19.6\win" /D "WIN32" /D "NDEBUG" /D "HAVE_CONFIG_H" /D "BUILDING_FRIBIDI" /FD /EHsc /MT /GS /Zc:wchar_t /Zc:forScope /GR /Fo"fribidi-0.19.6/bin/" /Fd"fribidi-0.19.6\bin\vc70.pdb" /W1 /c /TC "fribidi-0.19.6\bin\fribidi-caprtl2utf8.c" "fribidi-0.19.6\bin\getopt1.c"
link.exe /OUT:"fribidi-0.19.6\bin\fribidi-caprtl2utf8.exe" /NOLOGO /IMPLIB:"fribidi-0.19.6\bin\fribidi-caprtl2utf8.lib" kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib "fribidi-0.19.6\lib\fribidi.lib" "fribidi-0.19.6\bin\fribidi-caprtl2utf8.obj" "fribidi-0.19.6\bin\getopt1.obj" "fribidi-0.19.6\bin\getopt.obj"
fribidi-0.19.6\bin\fribidi.exe --test --charset "CapRTL" "fribidi-0.19.6\test\test_CapRTL_explicit.input" > "fribidi-0.19.6\test\test_CapRTL_explicit.output"
diff.exe -U 0 "fribidi-0.19.6\test\test_CapRTL_explicit.output" "fribidi-0.19.6\test\test_CapRTL_explicit.reference"
fribidi-0.19.6\bin\fribidi.exe --test --charset "CapRTL" "fribidi-0.19.6\test\test_CapRTL_implicit.input" > "fribidi-0.19.6\test\test_CapRTL_implicit.output"
diff.exe -U 0 "fribidi-0.19.6\test\test_CapRTL_implicit.output" "fribidi-0.19.6\test\test_CapRTL_implicit.reference"
fribidi-0.19.6\bin\fribidi.exe --test --charset "ISO8859-8" "fribidi-0.19.6\test\test_ISO8859-8_hebrew.input" > "fribidi-0.19.6\test\test_ISO8859-8_hebrew.output"
diff.exe -U 0 "fribidi-0.19.6\test\test_ISO8859-8_hebrew.output" "fribidi-0.19.6\test\test_ISO8859-8_hebrew.reference"
fribidi-0.19.6\bin\fribidi.exe --test --charset "UTF-8" "fribidi-0.19.6\test\test_UTF-8_persian.input" > "fribidi-0.19.6\test\test_UTF-8_persian.output"
diff.exe -U 0 "fribidi-0.19.6\test\test_UTF-8_persian.output" "fribidi-0.19.6\test\test_UTF-8_persian.reference"
fribidi-0.19.6\bin\fribidi.exe --test --charset "UTF-8" "fribidi-0.19.6\test\test_UTF-8_reordernsm.input" > "fribidi-0.19.6\test\test_UTF-8_reordernsm.output"
diff.exe -U 0 "fribidi-0.19.6\test\test_UTF-8_reordernsm.output" "fribidi-0.19.6\test\test_UTF-8_reordernsm.reference"
