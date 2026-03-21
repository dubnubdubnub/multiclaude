@echo off
REM Drop-in replacement for `claude` that runs inside the Docker sandbox.
REM Automatically maps the current directory to a container path under /workspace.

setlocal enabledelayedexpansion

REM ── Find the docker directory (where this script and docker-compose.yml live)
set "DOCKER_DIR=%~dp0"

REM ── Map current host directory to container path
REM    D:\gehub\dubIS-coordinator  ->  /workspace/dubIS-coordinator
for %%I in ("%CD%") do set "DIR_NAME=%%~nxI"
for %%I in ("%CD%\..") do set "HOST_PARENT=%%~fI"

set "MULTICLAUDE_HOST_DIR=%HOST_PARENT%"
set "MULTICLAUDE_WORKDIR=/workspace/%DIR_NAME%"
set "USERPROFILE=%USERPROFILE%"

REM ── Extract gh token if not set
if "%GH_TOKEN%"=="" (
    for /f "delims=" %%t in ('gh auth token 2^>nul') do set "GH_TOKEN=%%t"
)

REM ── Run Claude inside Docker
docker compose -f "%DOCKER_DIR%docker-compose.yml" run --rm -w "/workspace/%DIR_NAME%" claude claude %*
