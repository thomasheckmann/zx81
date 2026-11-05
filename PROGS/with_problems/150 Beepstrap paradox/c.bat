@echo @c.bat %%1>compile.bat
@del *.lst
@del *.p
@..\sjasm\sjasm %1 > info.txt
@ren *.out *.p
@ren *.lst list.lst

@for /f %%A in ("info.txt") do @set size=%%~zA

@echo ------------
@if %size% GTR 42 @( 
	echo.
	echo ------ list of errors -----
	echo.
	setlocal enabledelayedexpansion
	set /A i=1
	for /f delims^=^" %%G in (list.lst) do @(
   		IF /I "!i!" EQU "2" ECHO %%G
   		set  var1=%%G
   		set /A i=1
   		set var2=!var1:asm(=!
   		if not !var1!==!var2! (
			set /A i=2
			echo !var1!
   		)
	)
	echo.
	echo.
)
@del info.txt
:eind
@pause
