# vim: ft=sh

DIR_HOME="$(cd ${BASH_SOURCE%/*} 2>/dev/null; pwd)"
VERSION_DIR=${DIR_HOME##*/}
VERSION_BK=${VERSION_DIR#*-}

if [ -z "$VERSION_BK" ]; then
    read VERSION_BK ignore $DIR_HOME/VERSION
fi

export VERSION_BK
TARGET_VERSION_PATH=$DIR_HOME
DIR_LICENSE="$DIR_HOME/license"
DIR_CMDB="$DIR_HOME/cmdb"
DIR_JOB="$DIR_HOME/job"
DIR_GENCRT="$DIR_JOB/certs"
DIR_JOBCRT="$DIR_JOB/apache-tomcat-7.0.19/webapps/ROOT/WEB-INF/classes"
DIR_GSE="$DIR_HOME/gse"
DIR_ZK="$DIR_HOME/common/zookeeper/zookeeper-3.4.6"
DIR_DOWN="$DIR_HOME/index/download"
DIR_SESSION="$DIR_HOME/.session"

FILE_CONF="$DIR_HOME/bk.conf"
FILE_LOG="$DIR_HOME/bk.log"

FILE_TPL="$DIR_HOME/common/function"
FILE_FUNC="$DIR_HOME/common/function"

FILE_SETUP="$DIR_HOME/init_data/setup.sh"
FILE_INITDB="$DIR_HOME/init_data/init_db.sh"
FILE_CREATE="$DIR_HOME/init_data/create_newfile.sh"

FILE_CRT="$DIR_HOME/ssl_certificates.tar.gz"
FILE_INIT="$DIR_HOME/.bkallowinit"
SO_libaio="/lib64/libaio.so.1"

NGINX_LOGS="$DIR_HOME/common/nginx/logs"

PHP_EXE="$DIR_HOME/common/php/bin/php"

MYSQL_HOME="$DIR_HOME/common/mysql"
MYSQL_DATA="$MYSQL_HOME/data/"
MYSQL_BIN="$MYSQL_HOME/bin/mysql"
MYSOCK="$MYSQL_HOME/data/mysql.sock"

TOMCAT_DIR="$DIR_JOB/apache-tomcat-7.0.19"
TOMCAT_LOGS="$TOMCAT_DIR/logs"
TOMCAT_BIN="$TOMCAT_DIR/bin/catalina.sh"

JAVA_HOME="$DIR_HOME/common/java"
JAVA_BIN="$JAVA_HOME/bin"
PATH="$JAVA_BIN:$PATH"
CLASSPATH="$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar"

# for PaaS
DIR_PAAS="/$DIR_HOME/paas"
SSL_ROOT_DIR="$DIR_HOME/paas/ssl_dir"
PKG_PAAS="paas_ce"
#PKG_EXTRAS="extras_V3.0.3"
#PKG_OPENPAAS="open_paas_V3.0.3"
#PKG_PAASAGENT="paas_agent_V3.0.3"
PKG_PYTHONPAAS="$SRC_OPENPAAS/bin/rpms/python27-2.7.9-1.x86_64.rpm"
SRC_OPENPAAS="$DIR_HOME/$PKG_PAAS/open_paas"
RPM_PYTHON="python27-2.7.9-1"
MQ_USER="admin"
MQ_PWD="blueking"
MQ_CTL="$DIR_PAAS/service/rabbitmq/sbin/rabbitmqctl"

# for PaaSAgent
DIR_PAASAGENT="$DIR_PAAS/paas_agent"
SRC_PAASAGENT="$DIR_HOME/$PKG_PAAS/paas_agent"
PKG_PYTHONPAASAGENT="$DIR_PAASAGENT/pkg/python27-2.7.9-1.x86_64.rpm"
LICENSE_PAASAGENT="$DIR_HOME/paas_agent.license"

# for datasvr
DIR_DATASVR="$DIR_HOME/datasvr"
DATA_CERTS="$DIR_DATASVR/bk_conf"
ES_DATA="$DIR_DATASVR/bk_run_data/es"
ES_LOG="/$DIR_DATASVR/logs/common/es"

# port list for each module
declare -A PORTS
PORTS["PAAS"]="80 443 2181 2182 2183 3306 3888 3889 4888 5888 6379 8000 8001 8002 8003 8005 8009 8080 9000 10020 10020 10030 38186 38543 41628 42841 44418 48331 48533 48534 48671 49504 50002 52602 55375 58625 58817 58838 58930 59173 59313 60020"
PORTS["PAASAGENT"]="4245 8085"
PORTS["RABBITMQ"]="4369 5672 15672 25672"
PORTS["DATASVR"]="30011 9092 8081 8082 8083 8084 14721 10002 9300 8080 8833"
gse_port=(48533 48534 10020 58930 58625 50002 58838 58839)
