#!/bin/bash

# create new file with template file (xxx.tpl)
BKROOT=$(cd ${BASH_SOURCE%/init_data*} 2>/dev/null; pwd)
source $BKROOT/common/function
create_newfile() {
    log "Info: create new file with template file..."

    [[ $(id -u) -eq 0 ]] || log_exit "Error: this script must be run as root user"

    # check the config file of BK
    log "Info: check $FILE_CONF..."

    sed '/=/ s/[[:blank:]]+//g' $FILE_CONF |  grep -Ev '^#|^$' | awk -F'=' '{if(! $2){exit(1)}}'
    [[ $? -eq 0 ]] || log_exit "Error: check $FILE_CONF, failed"

    source $FILE_CONF
    log "Info: check $FILE_CONF, ok"

    while read tpl
    do
        dst=${tpl%.tpl};
        sed "s,__BKROOT__,$DIR_HOME,g
         s,__BASE_DNS__,$BASE_DNS,g
         s,__PAAS_DNS__,$PAAS_DNS_PREFIX.$BASE_DNS,g
         s,__CMDB_DNS__,$CMDB_DNS_PREFIX.$BASE_DNS,g
         s,__JOB_DNS__,$JOB_DNS_PREFIX.$BASE_DNS,g
         s,__PAAS_DNS_PREFIX__,$PAAS_DNS_PREFIX,g
         s,__CMDB_DNS_PREFIX__,$CMDB_DNS_PREFIX,g
         s,__JOB_DNS_PREFIX__,$JOB_DNS_PREFIX,g
         s,__DB_PASSWD__,$DB_PASSWD,g
         s,__DB_USER__,$DB_USER,g
         s,__DB_PORT__,$DB_PORT,g
         s,__INNERIP__,$INNERIP,g
         s,__OUTERIP__,$OUTERIP,g
         s,__PAAS_IP__,$PAAS_IP,g
         s,__NGINX_PORT__,$NGINX_PORT,g
         s,__PAASAGENT_MODE__,$PAASAGENT_MODE,g
         s,__PAASAGENT_TESTIP__,$PAASAGENT_TESTIP,g
         s,__PAASAGENT_PRODIP__,$PAASAGENT_PRODIP,g
         s,__ZK_IP__,$ZK_IP,g
         s,__MYSQL_IP__,$MYSQL_IP,g
         s,__CERTS_IP__,$CERTS_IP,g
         s,__ES_DATA__,$ES_DATA,g
         s,__ES_LOG__,$ES_LOG,g
         s,__DATASVR_IP__,$DATASVR_IP,g
        " $tpl > $dst
        chmod +x $dst

        if [ ${dst%monitrc*} != "$dst" ]; then
            chmod 600 $dst
        fi
    done < <(find $DIR_HOME -name "*.tpl")

    log "Info: create new file with template file, ok"
}

