@echo off
start "qx" /d \kdb \q\w32\q.exe qx/qx.q -p 2009
ping 127.0.0.1 -n 2 -w 5000 > nul
start "market maker" /d \kdb \q\w32\q.exe qx/marketmaker.q  -p 2010
#ping 127.0.0.1 -n 2 -w 5000 > nul
#start "user" /d \kdb \q\w32\q.exe qx/user.q
ping 127.0.0.1 -n 2 -w 5000 > nul
start "noise" /d \kdb \q\w32\q.exe qx/noise.q
ping 127.0.0.1 -n 2 -w 5000 > nul
start "timer" /d \kdb \q\w32\q.exe algo/timer.q -p 2012 -t 1000
ping 127.0.0.1 -n 2 -w 5000 > nul
start "participation" /d \kdb \q\w32\q.exe algo/trials.q -p 2011 -qx 2009
#start "participation" /d \kdb \q\w32\q.exe algo/testparticipation.q -p 2011 -qx 2009
