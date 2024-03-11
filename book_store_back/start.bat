@echo off
setlocal
start "Front server" "dhttpd.exe" "--path" "web"

start "API server" "server.exe"
timeout 1
start http://localhost:8080