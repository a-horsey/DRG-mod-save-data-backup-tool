setlocal ENABLEDELAYEDEXPANSION ENABLEEXTENSIONS
@echo off
color E0
title DRG Mod Save Data Backup Tool
cls 

:set_script_location
set script_location=%~dp0
cd "%script_location%"
set "script_location=%cd%"

:make_dir_folder
cd "%script_location%"
IF NOT EXIST "_dev" mkdir "_dev"

:set_location
IF EXIST "C:\Program Files (x86)\Steam\steamapps\common\Deep Rock Galactic\FSD.exe" (
    set "save_location=C:\Program Files (x86)\Steam\steamapps\common\Deep Rock Galactic\FSD\Saved\SaveGames\Mods"
    goto :set_location_done )

::custom location
IF EXIST "%script_location%\_dev\custom_location.bat" call "%script_location%\_dev\custom_location.bat"
IF DEFINED save_location (
    CD "%save_location%"
    CD ../../../.. )
IF DEFINED save_location IF EXIST "%cd%\FSD.exe" goto :set_location_done

::location prompt
Echo.Please input your Deep Rock Galactic install's folder.
Echo.For example, the default location is: C:\Program Files (x86)\Steam\steamapps\common\Deep Rock Galactic
SET /P save_location_temp=Input here:

IF EXIST "%save_location_temp%" CD "%save_location_temp%"
IF NOT EXIST "%cd%\FSD.exe" (
    cls
    Echo.Invalid location.
    goto :set_location )
set "save_location=%cd%\FSD\Saved\SaveGames\Mods"
::store location
IF EXIST "%script_location%\_dev\custom_location.bat" del "%script_location%\_dev\custom_location.bat" >nul
echo set "save_location=%cd%\FSD\Saved\SaveGames\Mods" >> "%script_location%\_dev\custom_location.bat"
:set_location_done

:main_menu
cls
echo.                       ~~%%%%%%%%_,_,
echo.                  ~~%%%%%%%%%-"/./
echo.                 ~~%%%%%%%-'   /  `.
echo.               ~~%%%%%%%%'  .     ,__;
echo.             ~~%%%%%%%%'   :       \O\
echo.          ~~%%%%%%%%'    :          `.
echo.        ~~%%%%%%%%'       `. _,        '
echo.     ~~%%%%%%%%'          .'`-._        `.
echo.  ~~%%%%%%%%%'           :     `-.     (,;
echo. ~~%%%%%%%%'             :         `._\_.'
echo. ~~%%%%%%' Hello^^!
echo.
echo.Options:
echo.        1. Make a backup
echo.        2. Restore a backup
echo.        3. Delete a backup
echo.        4. Open DRG mod save data folder
echo.        0. Exit

SET /P M=Pick an option: 
IF NOT "%M%"=="1" IF NOT "%M%"=="2" IF NOT "%M%"=="3" IF NOT "%M%"=="4" IF NOT "%M%"=="0" goto :main_menu

IF "%M%"=="1" goto :make_backup
IF "%M%"=="2" goto :restore_backup
IF "%M%"=="3" goto :delete_backup
IF "%M%"=="4" %SystemRoot%\explorer.exe "%save_location%"
IF "%M%"=="0" goto :EOF
goto :main_menu

:make_backup
cd "%script_location%\_dev"
IF NOT EXIST "backups" mkdir "backups"
cd "%script_location%\_dev\backups"
set "backup_folder_name=Date=%Date% - Time=%time%"
::set name format here
set "backup_folder_name=%backup_folder_name::=.%"
IF NOT EXIST "%backup_folder_name%" mkdir "%backup_folder_name%"
::actual backup + message
xcopy /y "%save_location%" "%script_location%\_dev\backups\%backup_folder_name%" /e /q >nul
cls
echo.Backup made with the name: %backup_folder_name%
timeout /t 10
goto :main_menu

:restore_backup
cls
set /A "option_number=0"
echo.List of backups you can restore:
echo.    0. Go back
FOR /D %%i IN (%script_location%\_dev\backups\*) DO (
    set /A "option_number=option_number+1"
    set backup_name=%%i
    set backup_name=!backup_name:%script_location%\_dev\backups\=!
    echo.    !option_number!. !backup_name!
    set "option_!option_number!=%%i"
)

set N=none
SET /P N=Pick a backup to restore: 
IF "%N%"=="0" goto :main_menu
cd "%script_location%\_dev\backups"
IF NOT EXIST !option_%N%! goto :restore_backup

IF EXIST !option_%N%! goto :restore_backup_confirm
goto :restore_backup

:restore_backup_confirm
cls
echo.You're about to restore this backup: !option_%N%:%script_location%\_dev\backups\=!
echo.
SET /P A=Proceed? (y/n): 
IF NOT "%A%"=="y" IF NOT "%A%"=="n" IF NOT "%A%"=="Y" IF NOT "%A%"=="N" goto :restore_backup_confirm
IF /I "%A%"=="n" goto :restore_backup
::actual restore + message
xcopy /y "!option_%N%!" "%save_location%" /e /q >nul
cls
echo.Backup restored.
timeout /t 10
goto :main_menu

:delete_backup
cls
set /A "option_number=0"
echo.List of backups you can delete:
echo.    0. Go back
FOR /D %%i IN (%script_location%\_dev\backups\*) DO (
    set /A "option_number=option_number+1"
    set backup_name=%%i
    set backup_name=!backup_name:%script_location%\_dev\backups\=!
    echo.    !option_number!. !backup_name!
    set "option_!option_number!=%%i"
)
echo.    ALL. Delete all backups

set D=none
SET /P D=Pick a backup to delete: 
IF "%D%"=="0" goto :main_menu
IF "%D%"=="ALL" goto :delete_all_backups_confirm
cd "%script_location%\_dev\backups"
IF NOT EXIST !option_%D%! goto :delete_backup

IF EXIST !option_%D%! goto :delete_backup_confirm
goto :delete_backup

:delete_backup_confirm
cls
echo.You're about to delete this backup: !option_%D%:%script_location%\_dev\backups\=!
echo.
SET /P A=Proceed? (y/n): 
IF NOT "%A%"=="y" IF NOT "%A%"=="n" IF NOT "%A%"=="Y" IF NOT "%A%"=="N" goto :delete_backup_confirm
IF /I "%A%"=="n" goto :delete_backup
::actual delete + message
RMDIR /S /Q "!option_%D%!" >nul
cls
echo.Backup deleted.
timeout /t 10
goto :main_menu

:delete_all_backups_confirm
cls
echo.You're about to delete ALL of the backups you've made.
echo.
SET /P A=Proceed? (y/n): 
IF NOT "%A%"=="y" IF NOT "%A%"=="n" IF NOT "%A%"=="Y" IF NOT "%A%"=="N" goto :delete_all_backups_confirm
IF /I "%A%"=="n" goto :delete_backup
RMDIR /S /Q "%script_location%\_dev\backups" >nul
cls
echo.All backups deleted.
timeout /t 10
goto :main_menu