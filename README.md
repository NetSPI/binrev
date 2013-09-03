Binrev- Automate reversing Windows binaries for pentesters
============

Here is a rough description of what it does, and what tools it is using:

For exe, dll files:
-------------
1.	Detect and de-obfuscate for .NET libraries with de4dot 
2.	Decompile .NET libraries with JustDecompile 
3.	Zip decompiled source code to netsources.zip 
4.	Run strings against native libraries
5.	Export calleable functions with dllexp. You can then try to run those functions with command Rundll32 <dll>,<function name> 
6.	Export dependencies with depends 
7.	Extract native resources with resourcesextract 

For jar files: 
-------------
1.	Extract and combine java classes into a single zip file
2.	Decompile java sources with procyon 
3.	Zip decompiled source code to javasources.zip


Requirement
============

* .NET framework: http://www.microsoft.com/en-us/download/details.aspx?id=17851
* Peverify: http://msdn.microsoft.com/en-us/library/62bwd2yd.aspx
* Java 7: http://java.com/en/download/index.jsp
* 7zip: http://www.7-zip.org/
* De4dot: https://bitbucket.org/0xd4d/de4dot
* JustDecompile: http://www.telerik.com/products/decompiler.aspx
* Dll Export Viewer: http://www.nirsoft.net/utils/dll_export_viewer.html
* Depends: http://www.dependencywalker.com/
* Resources Extract: http://www.nirsoft.net/utils/resources_extract.html
* Procyon https://bitbucket.org/mstrobel/procyon/wiki/Java%20Decompiler


Usage
============

1.	Configure correct path to installed tools in the script:
```
set justdecompile="JustDecompile\JustDecompile"
set dllexp="dllexp\dllexp"
set peverify=peverify
set zip="7-Zip\7z"
set strings="strings"
set de4dot=" de4dot-2.0.3\de4dot"
set java7="C:\Program Files (x86)\Java\jre7\bin\java"
set procyon="procyon-decompiler-0.5.7.jar"
```

2.	Run

```
Binrev [Source folder] [Output folder]
```

Output
============
* /java/decompiled: decompiled Java class files
* /native: native win32 libraries
* /native/resextract: native win32 resource files
* /net/decompiled: decompiled .NET projects
* /net/bin: .NET libraries and executables
* /net/deobs: deobfuscated .NET libraries
* /logs: strings on native libraries, exportable functions, dependencies, list of decompiled and native dlls
* /other: unhandled file extensions