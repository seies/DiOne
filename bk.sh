#!/bin/bash

cd ${BASH_SOURCE%/*} 2>/dev/null
# use bash to execute this script
echo $BASH | grep -q 'bash' || { exec bash "$0" "$@" || exit 1; }

# enable extended pattern matching operators
shopt -s extglob

# load variables definition
. env_var_definitions.sh
. bk.conf
. summary.fc

# port list for each module
declare -A PORTS
PORTS["PAAS"]="$NGINX_PORT 443 2181 2182 2183 3306 3888 3889 4888 5888 6379 8000 8001 8002 8003 8005 8009 8080 9000 10020 10020 10030 38186 38543 41628 42841 44418 48331 48533 48534 48671 49504 50002 52602 55375 58625 58817 58838 58930 59173 59313 60020"
PORTS["PAASAGENT"]="4245 8085"
PORTS["RABBITMQ"]="4369 5672 15672 25672"
PORTS["DATASVR"]="30011 9092 8081 8082 8083 8084 14721 10002 9300 8080 8833"
gse_port=(48533 48534 10020 58930 58625 50002 58838 58839)
export LC_ALL=en_US.UTF-8

ACTION='@(start|stop|restart|status|summary|reload|report|init)'
MODULE='@(all|redis-server|nginx|mysqld|zk1|zk2|zk3|gsedba|gsetask|gsebtfilesserver|yydba|gsedata|gsecacheapiserver|gseagent|cmdb|license|job|datasvr)'
GROUP='@(gse|zk)'

monit() { 
    local MONIT_DIR="$DIR_HOME/common/monit"
    local MONIT_BIN="$MONIT_DIR/bin/monit"
    local MONIT_RC="$MONIT_DIR/conf/monitrc"
    local MONIT_EXE="$MONIT_BIN -c $MONIT_RC"
    
    chmod 700 $MONIT_RC
    
    case "$1" in
        self_start)
            log "Info: monit self_start..."
            $MONIT_EXE &>/dev/null
            wait_check "$MONIT_EXE summary"
            log "Info: monit self_start, ok"
            ;;
        self_stop)
            $MONIT_EXE quit
            ;;
        self_reload) 
            $MONIT_EXE reload
            ;;
        self_restart)
            monit self_stop
            monit self_start
            ;;
        wait_stop)
            wait_check "$MONIT_EXE summary |grep -c monitored |grep -q 16"
            ;;  
        *)
            [[ $1 == "start" ]] && [[ $2 == "all" ]] && monit self_start
            [[ $1 == "start" ]] && [[ $2 == "nginx" ]] && monit self_start
            [[ $1 == "restart" ]] && [[ $2 == "nginx" ]] && monit self_start
            $MONIT_EXE "$@"
            [[ $1 == "start" ]] && [[ $2 == "all" ]] && writed_ip
            echo $1 |grep -Eq 'start|stop|restart' && { sleep 3;monit summary; }
            ;;
    esac
}

usage() {
    cat <<EOF
Usage: $0 : <action> <module>
action的取值为：(start|stop|restart|status|summary|reload|report|init|install)时，需要第二个参数module
module的取值为：(all|redis-server|nginx|mysqld|zk1|zk2|zk3|gsedba|gsetask|gsebtfilesserver|yydba|gsedata|gsecacheapiserver|gseagent|gseapiserver|cmdb|job|datasvr)

查看所有的进程状态: $0 status
查看服务部署情况: $0 summary
EOF
    exit 1 
}

echo -en "Current Version: $VERSION_BK \n"
source $FILE_CREATE || log_exit "Error: source $FILE_CREATE, failed"
[[ -f $FILE_FUNC ]] && { source $FILE_FUNC || log_exit "Error: source $FILE_FUNC, failed"; }

case "$1" in
    init)
        case "$2" in
            paas) init_paas ;;
            paasagent) init_paasagent ;;
			datasvr) init_datasvr ;;
            *) usage ;;
        esac
        exit $?
        ;;
    install)
        create_newfile
        case "$2" in
            paas) install_paas ;;
            paasagent) install_paasagent ;;
			datasvr) install_datasvr ;;
            rabbitmq) install_rabbitmq ;;
            *) usage ;;
        esac
        exit $?
        ;;
    summary)  
        if [ -z "$2" ]; then
            if [ -f $DIR_HOME/.installed_module ]; then
                while read module ignore; do
                    deploy_summary $module
                done < $DIR_HOME/.installed_module
            else

                # 根据机器上的进程列表推测当前机器安装的模块, 确认过的东西,放在CHECKED_MODULE 数组中
                guess_module
                
                for module in ${CHECKED_MODULE[@]}; do
                    deploy_summary $module
                done
            fi
        else
            if grep "$2$" $DIR_HOME/.install_module; then
                deploy_summary "$2"
            else
                echo "module $2 is not installed on this host"
            fi
        fi
        exit
        ;;
    status)
        if [ -z "$2" ]; then
            if [ -f $DIR_HOME/.installed_module ]; then
                while read module ignore; do
                    status_summary $module
                done < $DIR_HOME/.installed_module
            else

                # 根据机器上的进程列表推测当前机器安装的模块, 确认过的东西,放在CHECKED_MODULE 数组中
                guess_module
                
                for module in ${CHECKED_MODULE[@]}; do
                    status_summary $module
                done
            fi
        else
            if grep -q "$2$" $DIR_HOME/.installed_module; then
                status_summary "$2"
            else
                echo "module $2 is not installed on this host"
            fi
        fi
        exit
        ;;
    $ACTION) : ;;
    *) usage ;;
esac

case "$2" in 
    $MODULE) monit "$@" ;;
    $GROUP) monit -g $2 $1 ;;
    monit) monit self_$1 ;;
    *) usage ;;
esac

