@echo off
setlocal enabledelayedexpansion

for %%I in (.) do set foldername=%%~nxI

if [%1]==[] (
	set /p mapname="Enter mapname: "
) else (
	set mapname=%1
)

set prefix=!mapname:~0,3!
set bspPath=..\raw\maps\!mapname!.d3dbsp
if !prefix! EQU mp_ set bspPath=..\raw\maps\mp\!mapname!.d3dbsp

if not exist !bspPath! (
	echo [91mERROR: Map BSP not found.[0m
	echo [91mMake sure you have a decompiled version of the map.[0m
	pause
	exit
)

set /A numCubemaps=-1
for /F %%n in ('find /C """classname"" ""reflection_probe""" ^< ..\map_source\!mapname!.map') do set /A numCubemaps=%%n
if !numCubemaps! EQU -1 (
	echo [96mCould not find the map's source file. This will require some manual cleanup later.[0m
)

del /s /f /q _result\*.*
mkdir _result
cd ..
if !prefix! EQU mp_ (
	%foldername%\apitrace\bin\apitrace.exe trace --api d3d9 --output "%foldername%\_result\reflectionbuild.trace" mp_tool.exe +set r_fullscreen 0 +set r_mode "256x256" +set loc_warnings 0 +set developer 1 +set logfile 2 +set thereisacow 1337 +set sv_pure 0 +set com_introplayed 1 +set useFastFile 0 +set ui_autoContinue 1 +set r_reflectionProbeGenerateExit 1+set com_hunkMegs 512 +set r_reflectionProbeRegenerateAll 1 +set r_dof_enable 0 +set r_zFeather 1 +set sys_smp_allowed 0 +set r_reflectionProbeGenerate 1 +devmap !mapname!
) else (
	%foldername%\apitrace\bin\apitrace.exe trace --api d3d9 --output "%foldername%\_result\reflectionbuild.trace" sp_tool.exe +set r_fullscreen 0 +set r_mode "256x256" +set loc_warnings 0 +set developer 1 +set logfile 2 +set thereisacow 1337 +set com_introplayed 1 +set useFastFile 0 +set ui_autoContinue 1 +set r_reflectionProbeGenerateExit 1+set com_hunkMegs 512 +set r_reflectionProbeRegenerateAll 1 +set r_dof_enable 0 +set r_zFeather 1 +set sys_smp_allowed 0 +set r_reflectionProbeGenerate 1 +devmap !mapname!
)
cd %foldername%
apitrace\bin\apitrace.exe dump-images --output _result\face_ _result\reflectionbuild.trace

cd _result
del reflectionbuild.trace

if !numCubemaps! EQU -1 (
	echo [97m[41m -------------------------------- [0m
	echo [97m[41m Delete all frames in "_result" before the first cubemap face is shown before continuing. [0m
	echo [97m[41m -------------------------------- [0m
	pause
)

set /A i=0
for /f "tokens=*" %%a in ('dir /b /O:-N') do (
	set /A numFacesTwice=numCubemaps*6*2
	set /A mod=!i! %% 2

	if !numCubemaps! EQU -1 (
		if !mod! EQU 0 del %%a
	) else (
		if !i! GEQ !numFacesTwice! (
			del %%a
		) else (
			if !mod! EQU 0 del %%a
		)
	)

	set /A i+=1
)

cd ..\convert
convert.exe
cd ..\_result
del *.png
