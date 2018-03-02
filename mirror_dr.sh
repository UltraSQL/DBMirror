#!/bin/sh

###### Make Database Mirror ######
# Desc: The file executes on dr.
# Step 1: Backup database and log.
# Step 2: Scp backup file to dr.
# Step 3: Restore backup file on dr.
# Step 4: Set database mirror.
##################################

#db first column,dr second column
cat >db_dr.txt<<EOF
10.132.65.82       10.132.65.111
10.132.65.213      10.132.65.81
10.132.65.214      10.132.65.215
10.132.65.220      10.132.68.140
10.132.70.101      10.132.70.102
10.132.70.115      10.132.70.116
10.132.65.216      10.132.65.219
10.132.65.212      10.132.65.218
10.160.138.60      10.160.138.61
10.160.140.58      10.160.140.59
10.160.140.125     10.160.140.126
10.160.136.248     10.160.141.10
10.164.41.102      10.164.41.103
10.164.42.142      10.160.140.119
10.164.42.143      10.164.42.144
10.164.42.145      10.164.42.184
10.164.42.185      10.164.42.186
172.17.156.74      172.17.156.75
172.17.157.250     172.17.157.251
172.17.157.254     172.17.158.10
172.17.158.11      172.17.158.12
172.28.41.201      172.28.43.234
172.28.44.16       172.28.43.235
172.28.44.22       172.28.44.23
172.28.44.91       172.28.44.90
EOF


if [ `grep -c $1 db_dr.txt` -eq 1 ] && [ `grep "\b$1$" db_dr.txt|awk '{print $1}'|wc -l` -eq 1 ];then
    vDB=`grep "\b$1$" db_dr.txt|awk '{print $1}'`
	if [ `grep -c $vDB db_dr.txt` -eq 1 ];then
    	"/cygdrive/c/Program Files/Microsoft SQL Server/90/Tools/Binn/SQLCMD.EXE" -S $vDB,48322 -U sa -P jkgz1sJ -d msdb -Q "IF NOT EXISTS (SELECT * FROM sys.endpoints WHERE name = N'endpoint_mirroring') CREATE ENDPOINT endpoint_mirroring STATE = STARTED AS TCP ( LISTENER_PORT = 37022 ) FOR DATABASE_MIRRORING (ROLE=PARTNER);ALTER DATABASE QWorld SET RECOVERY FULL WITH NO_WAIT;backup database QWorld TO DISK='D:\dbbak\qworld_mirror.bak' with format, init;backup log QWorld TO DISK='D:\dbbak\qworld_mirror.bak' with noformat, noinit;"
		/cygdrive/d/upload/winscp.exp $vDB Administrator ttKX@09f 36000 /cygdrive/d/dbbak/qworld_mirror.bak /cygdrive/d/dbbak pull 0 -1
    	"/cygdrive/c/Program Files/Microsoft SQL Server/90/Tools/Binn/SQLCMD.EXE" -d msdb -Q "IF NOT EXISTS (SELECT * FROM sys.endpoints WHERE name = N'endpoint_mirroring') CREATE ENDPOINT endpoint_mirroring STATE = STARTED AS TCP ( LISTENER_PORT = 37022 ) FOR DATABASE_MIRRORING (ROLE=PARTNER)"
    	"/cygdrive/c/Program Files/Microsoft SQL Server/90/Tools/Binn/SQLCMD.EXE" -d msdb -Q "restore database QWorld from DISK='D:\dbbak\qworld_mirror.bak' with file=1,replace,NORECOVERY;restore log QWorld from DISK='D:\dbbak\qworld_mirror.bak' with file=2,norecovery;"
    	"/cygdrive/c/Program Files/Microsoft SQL Server/90/Tools/Binn/SQLCMD.EXE" -d msdb -Q "ALTER DATABASE QWorld SET PARTNER = 'TCP://$vDB:37022'"
    	"/cygdrive/c/Program Files/Microsoft SQL Server/90/Tools/Binn/SQLCMD.EXE" -S $vDB,48322 -U sa -P jkgz1sJ -d msdb -Q "ALTER DATABASE QWorld SET PARTNER = 'TCP://$1:37022'"
    	"/cygdrive/c/Program Files/Microsoft SQL Server/90/Tools/Binn/SQLCMD.EXE" -S $vDB,48322 -U sa -P jkgz1sJ -d msdb -Q "ALTER DATABASE QWorld SET PARTNER SAFETY OFF"
	fi	
fi


rm -f db_dr.txt


rm -f $0;
