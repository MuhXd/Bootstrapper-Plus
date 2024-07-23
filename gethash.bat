@echo off
setlocal
set "script_dir=%~dp0"
set "root_dir=%LocalAppData%\Bloxstrap\Versions"
set "temp_hash_file=%script_dir%save\temp_hash.txt"
set "final_hash_file=%script_dir%save\final_hash.txt"

:: Find the directory containing RobloxPlayerBeta.exe
for /d %%d in ("%root_dir%\*") do (
    if exist "%%d\RobloxPlayerBeta.exe" (
        set "version_dir=%%d"
        goto :found
    )
)

echo RobloxPlayerBeta.exe not found in any version directory.
exit /b 1

:found
echo Found RobloxPlayerBeta.exe in %version_dir%

:: Empty the temporary files
echo. 2> "%temp_hash_file%"
echo. 2> "%final_hash_file%"

:: List of specific files to hash in order
set "files_to_hash=WebView2Loader.dll RobloxPlayerBeta.exe RobloxPlayerBeta.dll RobloxCrashHandler.exe"

:: Hash specific files in order if they exist
for %%f in (%files_to_hash%) do (
    if exist "%version_dir%\%%f" (
        certutil -hashfile "%version_dir%\%%f" SHA256 | find /v "CertUtil" | find /v "hash of" >> "%temp_hash_file%"
    )
)

:: Hash any other .exe or .dll files in the directory
for /r "%version_dir%" %%f in (*.exe *.dll) do (
    if "%%f" neq "%version_dir%\WebView2Loader.dll" if "%%f" neq "%version_dir%\RobloxPlayerBeta.exe" if "%%f" neq "%version_dir%\RobloxPlayerBeta.dll" if "%%f" neq "%version_dir%\RobloxCrashHandler.exe" (
        certutil -hashfile "%%f" SHA256 | find /v "CertUtil" | find /v "hash of" >> "%temp_hash_file%"
    )
)

:: Generate a single hash for all the combined hashes
certutil -hashfile "%temp_hash_file%" SHA256 | find /v "CertUtil" | find /v "hash of" > "%final_hash_file%"

:: Read the computed final hash
set /p local_hash=<"%final_hash_file%"

:: Remove any extra spaces or newlines
set "local_hash=%local_hash: =%"
set "local_hash=%local_hash:~0,64%"  :: Ensure only the first 64 characters are used for comparison

:: Write version directory and hash to the version label file
echo Hash: %local_hash% >> "%version_dir%"


:: Remove any extra spaces or newlines
set "reference_hash=%reference_hash: =%"
set "reference_hash=%reference_hash:~0,64%"  :: Ensure only the first 64 characters are used for comparison

:cleanup
del "%temp_hash_file%"

endlocal
exit /b 0
