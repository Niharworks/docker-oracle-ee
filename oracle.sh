#!/bin/bash

##################################################
#         CONFIGURATION SECTION                  #
##################################################

# ** location of the database source files
SOURCEPATH=/tmp
# ** name of the first source file
SOURCE1=linuxamd64_12102_database_1of2.zip
# ** name of the second source file
SOURCE2=linuxamd64_12102_database_2of2.zip
# ** working directory for extracting the source
WORKDIR=/opt/oracle/stage
# ** the oracle top directory
ORATOPDIR=/opt/oracle
# ** the oracle inventory
ORAINVDIR=${ORATOPDIR}/oraInventory
# ** the ORACLE_BASE to use
ORACLE_BASE=${ORATOPDIR}/product/base
# ** the ORACLE_HOME to use
ORACLE_HOME=${ORACLE_BASE}/12.1.0.1
# ** base directory for the oracle database files
ORABASEDIR=/oradata
# the ORACLE_SID to use
ORACLE_SID=orcl
# ** the owner of the oracle software
ORAOWNER=oracle
# ** the primary installation group
ORAINSTGROUP=oinstall
# ** the dba group
ORADBAGROUP=dba
# ** the oper group
ORAOPERGROUP=oper
# ** the backup dba group
ORABACKUPDBA=backupdba
# ** the dataguard dba group
ORADGBAGROUP=dgdba
# ** the transparent data encryption group
ORAKMBAGROUP=kmdba


##################################################
#        MAIN SECTION                            # 
##################################################

PFILE=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora

# print the header
_header() {
   echo "*** ---------------------------- ***"
   echo "*** -- starting oracle 12c setup ***"
   echo "*** ---------------------------- ***"
}

# print simple log messages to screen
_log() {
   echo "****** $1 "
}

# check for the current os user
_check_user() {
    if [ $(id -un) != "${1}" ]; then
        _log "you must run this as ${1}"
        exit 0
    fi

}

# create the user and the groups
_create_user_and_groups() {
    _log "*** checking for group: ${ORAINSTGROUP} "
    getent group ${ORAINSTGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORAINSTGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORADBAGROUP} "
    getent group ${ORADBAGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORADBAGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORAOPERGROUP} "
    getent group ${ORAOPERGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORAOPERGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORABACKUPDBA} "
    getent group ${ORABACKUPDBA}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORABACKUPDBA} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORADGBAGROUP} "
    getent group ${ORADGBAGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORADGBAGROUP} 2> /dev/null || :
    fi
    _log "*** checking for group: ${ORAKMBAGROUP} "
    getent group ${ORAKMBAGROUP}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/groupadd ${ORAKMBAGROUP} 2> /dev/null || :
    fi
    _log "*** checking for user: ${ORAOWNER} "
    getent passwd ${ORAOWNER}
    if [ "$?" -ne "0" ]; then
        /usr/sbin/useradd -g ${ORAINSTGROUP} -G ${ORADBAGROUP},${ORAOPERGROUP},${ORABACKUPDBA},${ORADGBAGROUP},${ORAKMBAGROUP} \
                          -c "oracle software owner" -m -d /home/${ORAOWNER} -s /bin/bash ${ORAOWNER}
    fi
}

# create the directories
_create_dirs() {
    _log "*** creating: ${WORKDIR} "
    mkdir -p ${WORKDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${WORKDIR}
    _log "*** creating: ${ORATOPDIR} "
    mkdir -p ${ORATOPDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORATOPDIR}
    _log "*** creating: ${ORACLE_BASE} "
    mkdir -p ${ORACLE_BASE}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORACLE_BASE}
    _log "*** creating: ${ORACLE_HOME} "
    mkdir -p ${ORACLE_HOME}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORACLE_HOME}
    _log "*** creating: ${ORABASEDIR} "
    mkdir -p ${ORABASEDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORABASEDIR}
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID} "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${ORABASEDIR}/${ORACLE_SID}
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/rdo1 "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/rdo1
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/rdo2 "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/rdo2
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/dbf "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/dbf
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/arch "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/arch
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/admin "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/admin
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/admin/adump "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/admin/adump
    _log "*** creating: ${ORABASEDIR}/${ORACLE_SID}/pdbseed "
    mkdir -p ${ORABASEDIR}/${ORACLE_SID}/pdbseed
    chown -R ${ORAOWNER}:${ORADBAGROUP} ${ORABASEDIR}/${ORACLE_SID}
}

# extract the source files
_extract_sources() {
    cp ${SOURCEPATH}/${SOURCE1} ${WORKDIR}
    cp ${SOURCEPATH}/${SOURCE2} ${WORKDIR}
    chown ${ORAOWNER}:${ORAINSTGROUP} ${WORKDIR}/*
    _log "*** extracting: ${SOURCE1} "
    su - ${ORAOWNER} -c "unzip -d ${WORKDIR} ${WORKDIR}/${SOURCE1}"
    _log "*** extracting: ${SOURCE2} "
    su - ${ORAOWNER} -c "unzip -d ${WORKDIR} ${WORKDIR}/${SOURCE2}"
}

# install required software
_install_required_software() {
    _log "*** installing required software "
    yum install -y binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel ksh \
                   libgcc libstdc++ libstdc++-devel libaio libaio-devel libXext libXtst libX11 libXau libxcb libXi make sysstat
}

# install oracle software
_install_oracle_software() {
    _log "*** installing oracle software"
    su -  ${ORAOWNER} -c "cd ${WORKDIR}/database; ./runInstaller oracle.install.option=INSTALL_DB_SWONLY \
    ORACLE_BASE=${ORACLE_BASE} \
    ORACLE_HOME=${ORACLE_HOME} \
    UNIX_GROUP_NAME=${ORAINSTGROUP}  \
    oracle.install.db.DBA_GROUP=${ORADBAGROUP} \
    oracle.install.db.OPER_GROUP=${ORAOPERGROUP} \
    oracle.install.db.BACKUPDBA_GROUP=${ORABACKUPDBA}  \
    oracle.install.db.DGDBA_GROUP=${ORADGBAGROUP}  \
    oracle.install.db.KMDBA_GROUP=${ORAKMBAGROUP}  \
    FROM_LOCATION=../stage/products.xml \
    INVENTORY_LOCATION=${ORAINVDIR} \
    SELECTED_LANGUAGES=en \
    oracle.install.db.InstallEdition=EE \
    DECLINE_SECURITY_UPDATES=true  -silent -ignoreSysPrereqs -ignorePrereq -waitForCompletion"
    ${ORAINVDIR}/orainstRoot.sh
    ${ORACLE_HOME}/root.sh
}

# create a very minimal pfile
_create_pfile() {
    _log "*** creating pfile "
    echo "instance_name=${ORACLE_SID}" > ${PFILE}
    echo "db_name=${ORACLE_SID}" >> ${PFILE}
    echo "db_block_size=8192" >> ${PFILE}
    echo "control_files=${ORABASEDIR}/${ORACLE_SID}/rdo1/control01.ctl,${ORABASEDIR}/${ORACLE_SID}/rdo2/control02.ctl" >> ${PFILE}
    echo "sga_max_size=512m" >> ${PFILE}
    echo "sga_target=512m" >> ${PFILE}
    echo "diagnostic_dest=${ORABASEDIR}/${ORACLE_SID}/admin" >> ${PFILE}
    echo "audit_file_dest=${ORABASEDIR}/${ORACLE_SID}/admin/adump" >> ${PFILE}
    echo "enable_pluggable_database=true" >> ${PFILE}
}

# create the database
_create_database() {
    _log "*** creating database "
    # escaping the dollar seems not to work in EOF
    echo "alter pluggable database pdb\$seed close;" > ${ORABASEDIR}/${ORACLE_SID}/admin/seedhack.sql
    echo "alter pluggable database pdb\$seed open;" >> ${ORABASEDIR}/${ORACLE_SID}/admin/seedhack.sql
    su - ${ORAOWNER} -c "export ORACLE_HOME=${ORACLE_HOME};export LD_LIBRARY_PATH=${LD_LIBRARY_PATH};export PATH=${ORACLE_HOME}/bin:${PATH};export ORACLE_SID=${ORACLE_SID};export PERL5LIB=${ORACLE_HOME}/rdbms/admin; sqlplus / as sysdba <<EOF 
shutdown abort
startup force nomount pfile=${PFILE} 
create spfile from pfile='${PFILE}';
startup force nomount
CREATE DATABASE \"${ORACLE_SID}\"
MAXINSTANCES 8
MAXLOGHISTORY 5
MAXLOGFILES 16
MAXLOGMEMBERS 5
MAXDATAFILES 1024
DATAFILE '${ORABASEDIR}/${ORACLE_SID}/dbf/system01.dbf' SIZE 1024m REUSE AUTOEXTEND ON NEXT 8m MAXSIZE 2g EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '${ORABASEDIR}/${ORACLE_SID}/dbf/sysaux01.dbf' SIZE 1024m REUSE AUTOEXTEND ON NEXT 8m MAXSIZE 2g
DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '${ORABASEDIR}/${ORACLE_SID}/dbf/temp01.dbf' SIZE 1024m REUSE AUTOEXTEND ON NEXT 8m MAXSIZE 2g
UNDO TABLESPACE \"UNDOTBS1\" DATAFILE  '${ORABASEDIR}/${ORACLE_SID}/undotbs01.dbf' SIZE 1024m REUSE AUTOEXTEND ON NEXT 8m MAXSIZE 2g
CHARACTER SET AL32UTF8
NATIONAL CHARACTER SET AL16UTF16
LOGFILE GROUP 1 ('${ORABASEDIR}/${ORACLE_SID}/rdo1/redo01_1.log', '${ORABASEDIR}/${ORACLE_SID}/rdo2/redo01_2.log') SIZE 64m,
        GROUP 2 ('${ORABASEDIR}/${ORACLE_SID}/rdo1/redo02_1.log', '${ORABASEDIR}/${ORACLE_SID}/rdo2/redo02_2.log') SIZE 64m,
        GROUP 3 ('${ORABASEDIR}/${ORACLE_SID}/rdo1/redo03_1.log', '${ORABASEDIR}/${ORACLE_SID}/rdo2/redo03_2.log') SIZE 64m
USER SYS IDENTIFIED BY \"sys\" USER SYSTEM IDENTIFIED BY \"system\"
enable pluggable database
seed file_name_convert=('${ORABASEDIR}/${ORACLE_SID}/dbf/system01.dbf', '${ORABASEDIR}/${ORACLE_SID}/pdbseed/system01.dbf'
                       ,'${ORABASEDIR}/${ORACLE_SID}/dbf/sysaux01.dbf', '${ORABASEDIR}/${ORACLE_SID}/pdbseed/sysaux01.dbf'
                       ,'${ORABASEDIR}/${ORACLE_SID}/dbf/temp01.dbf', '${ORABASEDIR}/${ORACLE_SID}/pdbseed/temp01.dbf'
                       ,'${ORABASEDIR}/${ORACLE_SID}/dbf/undotbs01.dbf', '${ORABASEDIR}/${ORACLE_SID}/pdbseed/undotbs01.dbf');
startup force
alter session set \"_oracle_script\"=true;
start ${ORABASEDIR}/${ORACLE_SID}/admin/seedhack.sql
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /home/${ORAOWNER} -b catalog $ORACLE_HOME/rdbms/admin/catalog.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /home/${ORAOWNER} -b catblock $ORACLE_HOME/rdbms/admin/catblock.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /home/${ORAOWNER} -b catproc $ORACLE_HOME/rdbms/admin/catproc.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /home/${ORAOWNER} -b catoctk $ORACLE_HOME/rdbms/admin/catoctk.sql;
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /home/${ORAOWNER} -b pupbld -u SYSTEM/system $ORACLE_HOME/sqlplus/admin/pupbld.sql;
connect "SYSTEM"/"system"
host perl $ORACLE_HOME/rdbms/admin/catcon.pl -n 1 -l /home/${ORAOWNER} -b hlpbld -u SYSTEM/system -a 1  $ORACLE_HOME/sqlplus/admin/help/hlpbld.sql 1helpus.sql;
connect / as sysdba
start $ORACLE_HOME/rdbms/admin/utlrp.sql
set lines 264 pages 9999
col owner for a30
col status for a10
col object_name for a30
col object_type for a30
col comp_name for a80
col PDB_NAME for a30
col PDB_ID for 999
select owner,object_name,object_type,status from dba_objects where status  'VALID';
select comp_name,status from dba_registry;
select pdb_id,pdb_name from dba_pdbs;
exit;
EOF"
}

# add oracle environment to .bash_profile
_create_env() {
    _log "*** adding environment to .bash_profile "
    echo "ORACLE_BASE=${ORACLE_BASE}" >> /home/${ORAOWNER}/.bash_profile
    echo "ORACLE_HOME=${ORACLE_HOME}" >> /home/${ORAOWNER}/.bash_profile
    echo "ORACLE_SID=${ORACLE_SID}" >> /home/${ORAOWNER}/.bash_profile
    echo "LD_LIBRARY_PATH=${ORACLE_HOME}/lib:${LD_LIBRARY_PATH}" >> /home/${ORAOWNER}/.bash_profile
    echo "PATH=${ORACLE_HOME}/bin:${PATH}" >> /home/${ORAOWNER}/.bash_profile
    echo "export ORACLE_BASE ORACLE_HOME ORACLE_SID LD_LIBRARY_PATH PATH" >> /home/${ORAOWNER}/.bash_profile
}

_header
_check_user "root"
_create_user_and_groups
_create_dirs
_install_required_software
_extract_sources
_install_oracle_software
_create_pfile
#_create_database
_create_env
