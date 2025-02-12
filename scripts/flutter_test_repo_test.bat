@echo off

set "root_dir=%CD%"

for %%d in (
    "packages\patrol_finders"
    "packages\patrol_cli"
) do (
    echo Processing %%d
    cd "%%d"
    
    call flutter analyze --no-fatal-infos
    if errorlevel 1 exit /b 1
    
    call flutter test
    if errorlevel 1 exit /b 1
    
    cd "%root_dir%"
) 
