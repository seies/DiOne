#!/bin/bash

cd ${BASH_SOURCE%/*} 2>/dev/null
BKROOT=${PWD}
[ -f $BKROOT/common/function ] && source $BKROOT/common/function

bkdata_api_conf=$BKROOT/datasvr/bk_conf/bkdata/bk_bkdata_api.conf
bkdata_monitor_conf=$BKROOT/datasvr/bk_conf/bkdata/bk_bkdata_monitor.conf
cmd="$BKROOT/common/mysql/bin/mysql -u$DB_USER -p$DB_PASSWD -P$DB_PORT -h $DB_HOST"

app_id=${1:-bk_monitor}
app_token=$($cmd -e "use open_paas; select auth_token from paas_app where code = '$app_id'" | tail -n +2)

if [ "$app_token" == "" ]; then
    echo "监控app 未安装，请先在开发者中心进行监控 app 的上传及一键部署操作"
    exit 1
fi

set -e
echo "update configure...set app_token: $app_token"
sed -i "s,APP_ID=.*,APP_ID=$app_id," $bkdata_api_conf
sed -i "s,APP_TOKEN=.*,APP_TOKEN='$app_token'," $bkdata_api_conf

sed -i "s,APP_CODE=.*,APP_CODE='$app_id'," $bkdata_monitor_conf
sed -i "s,APP_SECRET_KEY=.*,APP_SECRET_KEY='$app_token'," $bkdata_monitor_conf

echo $bkdata_api_conf updated.
echo $bkdata_monitor_conf updated.

echo "add whitelist to esb_function_controller"
exists=$($cmd -e "use open_paas; select wlist from esb_function_controller where wlist like '%$app_id%'" | tail -n +2)

if [ "$exists" == "" ]; then
    $cmd -e "use open_paas;update esb_function_controller set wlist = concat(wlist, ',$app_id') where func_code='user_auth::skip_user_auth';"
fi

cd $BKROOT/datasvr/bkdata/bk_bkdata_monitor/bin/
./stop.sh
./start.sh

cd $BKROOT/datasvr/bkdata/bk_bkdata_api/bin/
./stop.sh
./start.sh
