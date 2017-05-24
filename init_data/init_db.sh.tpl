#!/bin/bash
# vim:ft=sh

init_gse()
{
    #init zk nodes
    log 'Info: init zookeeper nodes...'   
    wait_check "$DIR_ZK/bin/zkServer.sh status $DIR_ZK/conf/zoo_1.cfg"
    wait_check "$DIR_ZK/bin/zkServer.sh status $DIR_ZK/conf/zoo_2.cfg"
    #wait_check "$DIR_ZK/bin/zkServer.sh status $DIR_ZK/conf/zoo_3.cfg"

    (
        cd $DIR_GSE
        python set_zk.py /gse '""'
        python set_zk.py /gse/config '""'
        python set_zk.py /gse/config/ip2city '""'
        python set_zk.py /gse/config/server/ '""'
        python set_zk.py /gse/config/server/dbproxy  '""'
        python set_zk.py /gse/config/server/task  '""'
        python set_zk.py /gse/config/server/task/all '""'
        python set_zk.py /gse/config/server/taskserver  '""'
        python set_zk.py /gse/config/server/taskserver/all '""'
        python set_zk.py /gse/config/etc 'etc'
        python set_zk.py /gse/config/etc/dataserver 'dataserver'
        python set_zk.py /gse/config/etc/dataserver/storage '""'
        python set_zk.py /gse/config/etc/dataserver/storage/all '""'
        python set_zk.py /gse/config/etc/dataserver/data '""'
        python set_zk.py /gse/config/etc/dataserver/all 'all'
        python set_zk.py /gse/config/etc/dataserver/all/balancecfg '{"cpuk":0.1,"cpur":0.1,"cpup":10,"memk":0.3,"memr":0.3,"memp":104857,"diskk":0,"diskr":0,"diskp":10,"netk":0.6,"netr":0.6,"netp":10,"netdev":"eth1","weightmax":0.6}'
        python set_zk.py /gse/config/etc/dataserver/all/basecfg '{"pid":"logs","log":"logs","runmode":1,"alliothread":30,"level":"info","enable_stream_local":true,"composeid":0,"enable_stream_remote":false,"datasvrip":"__PAAS_IP__","dataport":58625,"dftregid":"test","dftcityid":"test","basecfg":[{"type":2,"name":"arch"},{"type":3,"name":"cpu"},{"type":4,"name":"crond"},{"type":5,"name":"disk"},{"type":6,"name":"disk_used"},{"type":7,"name":"iptable"},{"type":8,"name":"mem"},{"type":9,"name":"net"},{"type":10,"name":"proc"},{"type":11,"name":"alarm"},{"type":12,"name":"allproc"},{"type":13,"name":"allport"},{"type":14,"name":"alert"},{"type":255,"name":"baseReport"}]}'
        python set_zk.py /gse/config/etc/dataserver/all/agentcfg '{"update_timeout":600,"probability_change":50,"probability_connect":0.5}' 
        python set_zk.py /gse/config/server/dbproxy/redisfordata '{"port":58838}'
        python set_zk.py /gse/config/server/cacheapi '""'
    )
    
    [[ $? -eq 0 ]] || log_exit "Error: init zookeeper nodes, failed"
    log "Info: init zookeeper nodes, ok"

    return 0
}

gen_certs()
{

    cd  $DIR_GENCRT/ && rm -f ./*

    #uncompress certs and generate another certs
    tar zxf $FILE_CRT -C $DIR_GENCRT
    [[ $? -eq 0 ]] || log_exit "tar zxf $FILE_CRT -C $DIR_GENCRT failed."

    cd  $DIR_GENCRT/../
    sh gen_certs.sh
    [[ $? -eq 0 ]] || log_exit "sh gen_certs.sh failed."

    # end
    # uncompress certs to job directory for setup correctly
    tar zxf $FILE_CRT -C $DIR_JOBCRT
    [[ $? -eq 0 ]] || log_exit " tar zxf $FILE_CRT -C $DIR_JOBCRT failed."
}

init_job()
{
    local SQL_INIT="${DIR_JOB}/job.sql"
    
    log  'Info: init job database...'
    
    [ -f $SQL_INIT ]  || log_exit "Error: $SQL_INIT not exists"
    
    wait_check "$MYSQL_EXE -e exit"

    $MYSQL_EXE < $SQL_INIT || log_exit "Error: $MYSQL_EXE < $SQL_INIT, failed"

    gen_certs
 
    log "Info: init job database, ok"
    return 0
}

grants_privileges()
{
    #grant privilegs..
    log 'Info: grants privileges...'
        
    wait_check "$MYSQL_BIN --socket=$MYSOCK -e exit"

    $MYSQL_BIN --socket=$MYSOCK -e "grant all privileges on *.* to \
    '$DB_USER'@'%' identified by '$DB_PASSWD'; flush privileges;"

    [ $? -eq 0 ] || log_exit "Error: grants privileges, failed"
    log 'Info: grants privileges, ok'
}

init_datasvr_db()
{
	log "init datasvr database..."
	cd $DIR_DATASVR/init_data/bkdata
	[[ -f bk_bkdata_api.sql ]] || log_exit "Error: bk_bkdata_api.sql not exists"
	[[ -f bk_bkdata_monitor.sql ]] || log_exit "Error: bk_bkdata_monitor.sql not exists"	
	
	$MYSQL_EXE < bk_bkdata_api.sql
	[[ $? -eq 0 ]] || log_exit "Error: init bk_bkdata_api.sql, failed"
	
    $MYSQL_EXE < bk_bkdata_monitor.sql
    [[ $? -eq 0 ]] || log_exit "Error: init bk_bkdata_monitor.sql, failed"

	log "init datasvr db OK."
}

init_cmdb()
{
    grants_privileges

    log 'Info: init session...'
    
    #for upload files
    chmod 777 "$DIR_CMDB/cc_openSource/application/resource/upload/importPrivateHostByExcel"
    
    #the directory for save session
    [[ ! -d $DIR_SESSION ]] && { mkdir $DIR_SESSION || log_exit "Error: mkdir $DIR_SESSION, failed"; }
    chmod 777 $DIR_SESSION
    
    log "Info: init session OK."

    log 'Info: init cmdb database...'
    
    cd $DIR_CMDB/cc_openSource/ || log_exit "Error: cd $DIR_CMDB/cc_openSource/, failed"
    
    wait_check "$MYSQL_EXE -e exit"		

    $MYSQL_EXE -e 'create database cmdb;'
    
    [ -f cc_openSource.sql ] || log_exit "Error: cc_openSource.sql not exists"
    $MYSQL_EXE cmdb < cc_openSource.sql
    [[ $? -eq 0 ]] || log_exit "Error: init cc_openSource.sql, failed"
    
    $PHP_EXE index.php /cli/Init/initUserData > /dev/null
    [[ $? -eq 0 ]] || log_exit "Error: php initUserData, failed"
		
    $PHP_EXE index.php /cli/Init/addBkApp > /dev/null
    [[ $? -eq 0 ]] || log_exit "Error: php addBkApp, failed"

    log "Info: init cmdb database, ok"
    return 0
}

