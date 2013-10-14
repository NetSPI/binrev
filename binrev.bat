@echo off

REM For exe, dll files:
	REM Detect and de-obfuscate for .NET libraries with de4dot https://bitbucket.org/0xd4d/de4dot
	REM Decompile .NET libraries with JustDecompile http://blogs.telerik.com/justteam/posts/11-10-20/command-line-support-and-more-in-justdecompile.aspx
	REM Zip decompiled source code to netresources.zip -> Code Review
	REM Run strings against native libraries
	REM Export calleable functions with dllexp http://www.nirsoft.net/utils/dll_export_viewer.html -> Rundll32 
    REM Export dependencies with depends http://www.dependencywalker.com/
	REM Extract native resources with resourcesextract http://www.nirsoft.net/utils/resources_extract.html
REM For jar files:
	REM Extract and combine java classes into javabins.jar
	REM Decompile with Procycon https://bitbucket.org/mstrobel/procyon/ --> javasources.zip for Code Review

setlocal enabledelayedexpansion

if [%1] equ [] goto :SYNTAX
if [%1] equ [-h] goto :SYNTAX
if [%1] equ [/?] goto :SYNTAX


:SYNTAX
echo ------------------------------------------------------------
echo             Binaries Reverser (binrev)
echo ------------------------------------------------------------
echo This script can be used to perform binary analysis and reversing of 
echo .NET, Java and native components
echo ------------------------------------------------------------
echo Syntax: 
echo binrev [Source] [Destination]
REM #######################################################



rem if %1=
set justdecompile="JustDecompile\JustDecompile"
set dllexp="dllexp\dllexp"
set peverify=peverify
set zip="7-Zip\7z"
set strings="strings"
set resextract="resourcesextract\ResourcesExtract"
set de4dot="D:\Security\Tools\Reversing Tools\de4dot-2.0.3\de4dot"
set java7="C:\Program Files (x86)\Java\jre7\bin\java"
set procyon="procyon-decompiler-0.5.7.jar"

mkdir %2\"net\decompiled"
mkdir %2\"net\bin"
mkdir %2\"net\deobs"
mkdir %2\"java\decompiled"
mkdir %2\"native\resextract"
mkdir %2\"other"
mkdir %2\"logs"

echo Parsing Windows binaries (exe, dll) ....

REM Export dependency with dpends
REM Check for .NET libraries with peverify
for /f   "delims=*" %%a in ('dir /s /b  %1\*.exe  %1\*.dll') do (
REM http://stackoverflow.com/questions/10393248/get-filename-from-string-path
for %%F in (%%a) do set fileName=%%~nxF
%depends% /c /oc:"%2\logs\!fileName!".csv "%%a"
%peverify% /MD /QUIET /IGNORE=0x80131b18 "%%a"  > nul
REM If .NET library
if errorlevel 0 if not errorlevel 1 (
REM Export .NET project with justdecompile
%justdecompile% /out "%2/net/decompiled" /target "%%a"
copy "%%a" "%2\net\bin" >nul
echo "%%a" >> %2\logs\decompiled_dlls.txt
) else (
copy "%%a" "%2\native" >nul
echo "%%a" >> %2\logs\native_dlls.txt
echo ===== "%%a" ====== >>%2\logs\strings.txt
strings %%a >>%2\logs\strings.txt
%resextract% /Source %%a  /DestFolder "%2\native\resextract"

)
)

REM Obfuscation detection
%de4dot%  -r %1 -ru -ro  %2\net\deobs | find /I /V "unknown" >%2\logs\de4dot.txt
for /f   "delims=*" %%a in ('dir /s /b  %2\net\deobs\*.exe  %2\net\deobs\*.dll') do (
%justdecompile% /out "%2/net/decompiled" /target "%%a"
)

%zip% a -r  "%2\netsources.zip" "%CD%\%2\net\decompiled" >nul 

REM Export calleable function with dllexp
echo Exporting native windows binaries calleable functions ...
%dllexp% /from_files "%2\native\*.*" /scomma "%2\logs\export_functions.csv"

REM Copy all jar files
REM Extract them all to .class files (warning: duplicates may get deleted)
REM Zip them back into a single archive. 
echo Copying jar files ...
copy "%1\*.jar" "%2\java" >nul
dir /s /b  %1\*.jar > %2\logs\jars.txt 
%zip% x -ry -o"%2\java\bin" "%2\java" >nul
%zip% a -r  "%2\java\javabins.jar" "%CD%\%2\java\bin" >nul 
%java7% -jar %procyon% -jar "%2\java\javabins.jar" -o "%2\java\decompiled" > nul
%zip% a -r  "%2\javasources.zip" "%CD%\%2\java\decompiled" >nul 
del /F /S /Q "%2\java\bin" > nul

