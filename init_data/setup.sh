#!/bin/bash

source $FILE_TPL || { echo "`date +%F\ %T`, Error: source $FILE_TPL, failed";exit 1; }

# this script must be run as root user
[[ $(id -u) -eq 0 ]] || log_exit "Error: this script must be run as root user"

# create group and user
log "Info: groupadd cmdb/mysql, useradd cmdb/mysql..."
getent group cmdb &> /dev/null || groupadd cmdb
getent passwd cmdb &> /dev/null || useradd -s /sbin/nologin cmdb -g cmdb
getent group mysql &> /dev/null || groupadd mysql
getent passwd mysql &> /dev/null || useradd -s /sbin/nologin mysql -g mysql
log "Info: groupadd cmdb/mysql, useradd cmdb/mysql, ok"

# check the permission of mysql user
log "Info: check the permission of mysql user..."
check_permission
log "Info: check the permission of mysql user, ok"

# create new file with template file (xxx.tpl)
create_newfile

log "Info: chmod file grants..."
find $DIR_HOME -type d | xargs chmod 755 || log_exit "Error: chmod 755 $DIR_HOME directory, failed"
find $DIR_HOME -name "*.sh" | xargs chmod 755 || log_exit "Error: chmod 755 $DIR_HOME/*.sh, failed" 
log "Info: chmod file grants,ok"

log "Info: create new file with template file, ok"

source $FILE_FUNC || log_exit "Error: source $FILE_FUNC, failed"

# append DNS record to /etc/hosts
modify_hosts

[[ -d $NGINX_LOGS ]] || { mkdir $NGINX_LOGS || log_exit "Error: mkdir $NGINX_LOGS, failed"; }
[[ -d $TOMCAT_LOGS ]] || { mkdir $TOMCAT_LOGS || log_exit "Error: mkdir $TOMCAT_LOGS, failed"; }
[[ -f $SO_libaio ]] || { ln -s "$MYSQL_HOME/lib/libaio.so.1.0.1" $SO_libaio || log_exit "Error: ln -s $MYSQL_HOME/lib/libaio.so.1 $SO_libaio, failed";log "Info: create the link file $SO_libaio, ok"; }

# check and extract certificate file
log "Info: check and extract certificate file..."

check_crt
extract_crt

log "Info: check and extract certificate file, ok"

# package the agent file, client host will download and install it
log "Info: package the agent file..."

package_agent

log "Info: package the agent file, ok"

# init agent of server,we will puts agent file in /usr/loca/ directory defaults
log "init agent of server..."

init_agent

log "info: init agent of server, ok"
