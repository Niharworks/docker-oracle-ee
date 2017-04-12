#!/bin/bash

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

PFILE=${ORACLE_HOME}/dbs/init${ORACLE_SID}.ora

# create a very minimal pfile
_create_pfile() {
    ${ORAINVDIR}/orainstRoot.sh
    ${ORACLE_HOME}/root.sh
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

_create_pfile
