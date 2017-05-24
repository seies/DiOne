DiOne 3.0 beta安装部署
----
[TOC]

## 模块说明
DiOne 3.0, 分为3个模块：

- 基础模块
    - `paas`
    - `gse`
    - `cmdb`
    - `job`
    - `gitserver`
- `PaasAgent`
    - 正式环境
    - 测试环境
- `datasvr` 
    - `api`
    - `monitor`
    - `databus`

> <font color="red" size="6px">**重要说明**:</font>

- 基于可靠性保障的原因，`3.0 beta` 版本中自带了`nginx`，`mysql`，`php` `redis` 等基础服务的软件包，安装脚本 `bk.sh` 也计划在未来的版本中丢弃，改用更友好的安装脚本。因此，`3.0 beta` 版本的安装脚本`bk.sh`与也仅限于全新安装。尽管如此，<font color="green">本文末尾提供了从`2.0`升级到`3.0 beta` 的手动操作方法, 以便老用户使用</font>
- <font color="red">安装前请认真阅读安装准备中的说明</font>

## 部署需求
1. `PaasAgent` 正式环境和测试环境必须分开部署。（若不需要`paasagent`测试环境, 则可以不部署)
2. 除说明1之外，从技术上来看，3个模块可以全部部署在同一台机器上，但不建议这么做
3. 建议机器数量及部署方式如下：
    
    | 机器数量 | 部署方式 | 备注 |
    | --- | --- | --- |
    | 1 | 全部模块部署在一台机器上 | 无app测试环境 |
    | 2 | 一台部署：基础模块 + `PaasAgent` 正式环境<br>一台部署：datasvr |  内存16G+, 生产环境不建议这么操作|
    | 3 | 一台部署：基础模块 + `PaasAgent` 正式环境<br>一台部署：datasvr <br>一台部署：`PaasAgent `测试环境 | 推荐的最小配置，datasvr<br>建议8G 以上内存 |
    | <font color="green">4 | <font color="green">一台部署：基础模块<br>一台部署：`PaasAgent` 正式环境<br>一台部署：datasvr<br>一台部署：`PaasAgent` 测试环境| <font color="green">每台4核8G 以上配置，生产环境<br>使用的最小化建议部署方式</font> |
    | 5+ | 目前安装脚本不支持。需要修改的配置较多，<br>会在后续的版本中优化，以增加扩展性和可用性 |  |
4. Server 服务器最低配置

    | 服务器数|    0-100台|    100-500台|    500-1000|  1000台以上|
| --- | --- | --- | ---| --- |
|CPU|    4核|    8核|    8核|    16核|
|内存|    8G|    8G|    16G    |32G|
|系统盘|    50G|    100G|    200G|    300G|
|/data盘|    50G|    100G|    200G|    300G|
注：如果是搭建测试环境，系统配置请至少是4核8G

5. 浏览器推荐使用 `chrome` 访问

## 各模块安装说明
<font color="red" size="3px">**重要**:</font>本节所示安装说明，仅限于在新的环境中安装。若机器曾安装过旧版本，请先把旧版本目录删除，并杀掉进程列表中匹配下列名称的进程。

```
    supervisor
    monit
    php-fpm
    mysql
    gse.conf
    java
    nginx
    bk_license
    redis-server
    paas_agent
    open_paas
    erlang
    python
```
    
### 1. 安装准备
- 准备安装目录，建议安装在系统中较大的分区中的公共目录。<font color="red">不能安装在用户家目录下</font>
- 下载安装包。并解压
    注意： 不能解压到旧版本的目录
- 生成证书文件。根据 paas 所在的 mac 地址生成 ssl 证书，并把证书文件包复制到解压后的目录
>Note： 目前3.0 beta 版的证书需要内部生成.请联系白杨。

    ```bash
    > tar xf bksuit-3.0.9-beta.tgz
    > cp ssl_certificates.tgz bksuite-3.0.9-beta/
    ```

- 同2.0的部署类似，基本配置信息在 `bk.conf` 文件中。所有服务器上根据实际情况修改3.0 版本中，增加了4个配置项。


        # 根域
        BASE_DNS=bking.com
        # PAAS平台的域名前缀
        PAAS_DNS_PREFIX=paas
        # 配置平台的域名前缀
        CMDB_DNS_PREFIX=cmdb
        # 作业平台的域名前缀
        JOB_DNS_PREFIX=job
        # Nginx的监听端口
        NGINX_PORT=80
        # 本机的内网IP：不支持0.0.0.0 (必须修改)
        INNERIP=x.x.x.x
        # 本机的外网IP：用于proxy跨云管理功能，如果不需要该功能，请设置为本机的内网IP。不支持0.0.0.0 (必须修改)
        OUTERIP=x.x.x.x
        # 基础模所在的服务器IP，本机安装基础模块则填写本机 IP, 若各。不支持0.0.0.0 (必须修改)
        PAAS_IP=x.x.x.x
        # PaasAgent的测试环境IP：如果不需要测试环境，请设置为本机的内网IP。不支持0.0.0.0 (必须修改)
        PAASAGENT_TESTIP=x.x.x.x
        # PaasAgent 的正式环境IP：不支持0.0.0.0 (必须修改)
        PAASAGENT_PRODIP=x.x.x.x
        # PaasAgent 的安装模式：如果本机要安装PAASAGENT，则要设置该选项。测试环境为 test，正式环境为 prod
        PAASAGENT_MODE=test
        # PAASAGENT是否独立部署：如果本机要安装PAASAGENT，则要设置该选项。如果本机要同时安装PAAS和PAASAGENT，请设置为 no，否则设置为 yes
        PAASAGENT_ONLY=yes
        # ---------- new add ----------------
        # zookeeper的IP地址，zookeeper 与基础模板安装在同一服务器上，填写所在基础模块服务器的内网IP地址
        ZK_IP=x.x.x.x
        # mysql数据库所在服务器IP，即基础模块所在服务器的内网IP地址
        MYSQL_IP=x.x.x.x
        # 证书鉴权服务器所在服务器IP，即基础模块(paas)所在服务器的内网IP地址
        CERTS_IP=x.x.x.x
        # datasvr的IP，建议单独一台服务器，不和基础模块共用
        DATASVR_IP=x.x.x.x

### 2. 基础模块安装
- 基础模块依赖如下服务：

    - `mysql`
    - `nginx`
    - `rabbitmq`
    - `tomcat`
    - `zookeeper`
 

- 基础模块，会安装 `cmdb`，`paas`，`job` 3个基础平台，`gse` 管控通道,  以及他们依赖的服务，**这些服务安装到同一台机器上**
在3.0 中，沿用了2.0的做法，依次执行如下操作， 操作前请确保已正确配置 `bk.conf`：

    ```bash
    $ cd bksuite-3.0.9-beta
    $ vi bk.conf     # 根据说明编辑好 bk.conf 文件
     $ ./bk.sh init paas
    $ ./bk.sh install paas
    ```
- 上述步骤操作完成之后，通过 `./bk.sh summary` 可以查看基础模块所有服务的运行状况

> Note: 
> 若执行`./bk.sh summary` 提示`Monit: the monit daemon is not running`, 可以通过命令手动执行启动：`./bk.sh start monit` 启动 `monit`，`5-10`分钟后，再执行`./bk.sh summary`查看状态

### 3. PaasAgent 安装
- `PaasAgent` 依赖如下服务：
    - `rabbitmq` ： `PaasAgent`正式环境和测试 环境共用一套 `rabbitmq` 服务，因此，仅需要在安装 `PaasAgent` 的<font color="red">正式环境机器上执行</font>
- `PaasAgent`的安装类似基础模块：依次执行如下操作， 操作前请确保已正确配置 `bk.conf` ,  
    - 如果是正式环境，`bk.conf` 中的 `PAASAGENT_MODE` 设置为 `prod`.
    - 如果是测试环境，`PAASAGENT_MODE` 设置为 `test`.
    
    ```bash
    $ cd bksuite-3.0.9-beta
    $ vi bk.conf    # 根据说明编辑好 bk.conf 文件
    $ ./bk.sh init paasagent
    $ ./bk.sh install paasagent
    $ ./bk.sh install rabbitmq
    ``` 

### 4. datasvr安装

- datasvr依赖如下服务
    - `Kafka`
    -  `zookeeper`

- 依次执行如下操作， 操作前请确保已正确配置 `bk.conf`, 确保，各项已正确配置
    **datasvr需要单独一台机器安装**。

    ```bash
    $ vi bk.conf    # 根据说明编辑好bk.conf
    $ ./bk.sh init datasvr
    $ ./bk.sh install datasvr
    ```
    以上步骤中包含了安装 `Kafka` 的步骤, 并自动配置了相关的服务
    正常启动的情况下，cd 到安装目录下，通过以下命令，看到的服务，应该都是在 `RUNNING` 状态
    `common/python/bin/supervisorctl -c datasvr/bk_conf/common/supervisord.conf status`
    
    > Note: datasvr 不能使用 ./bk.sh summary 来查看状态

### 5. App (SaaS应用)安装部署
- 安装 `agent_setup app`
     
     `agent安装`的安装包已经打包在完整包中，在开发者中心点击部署即可。
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 找到`bk_agent_setup` 所在的行，点击部署

- 安装DiOne监控`app`
    DiOne监控包含了一个纯后台的子模块，请求 `paas`接口 需要进行 `token` 认证的步骤。
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 点击一键部署应用
    - 3. 上传监控 `app` 的 `SaaS` 安装包，点击一键部署
    - <font color="red">4. 登陆 `datasvr` 所在机器，进入安装目录，执行脚本`./update_monitor_token.sh`</font>。

- 安装日志检索`app`
    
    与 App: `agent安装`不一样， 该包从 Smart 市场下载，通过上传的方式进行部署。多了一个上传步骤
    
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 点击一键部署应用
    - 3. 上传日志检索 `app` 的 `SaaS` 安装包，点击一键部署
    - 4. 日志检索 `app` 需要调用监控 `app` 后台的接口，因此<font color="red">在使用日志检索前, 确保已经按照安装监控`app`的步骤操正常安装了监控 `app`</font>
- 安装包管理`app`
    同DiOne监控一样，包管理 app 也是一个包含后台应用子模块。需要进行 `token` 认证。
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 点击一键部署应用
    - 3. 上传包管理 `app` 的 `SaaS` 安装包，点击一键部署
    - <font color="metagan">4. 登陆 `datasvr` 所在机器，进入安装目录，执行脚本`./add_wlist_cdman.sh`。</font>

## 各模块服务管理
各模块安装完成之后，通过`ps -ef` 可以看到多了不少进程。有`uwsgi`,`python`, `java`等等之类的。
这些程序基本都是通过 `supervirsord`, `monit`来管理的。因为下一个版本的服务管理方式会进行更多的优化，因此这个版本中，在本节主要简单阐述各模块下子模块的常用进程管理。

### 1. 服务配置
- 略。安装过程中已自动配置。我们不计划在`3.0 beta` 版中阐述如何通过修改配置进行服务的独立运行及部署。

### 2. 服务进程管理

#### 1. 基础模块管理
本节描述各个模块的子模块及依赖服务如何<font color="red">在不依靠`监管服务`的情况下进行启停操作</font>
基础服务均*安装^1*在`${install_path}/common`目录下。假设为 SERVICE_HOME
##### mysql
```bash
> cd ${SERVICE_HOME}/mysql
- 启动:  ./mysqld.sh start
- 停止:  ./mysqld.sh stop
- 重启:  ./mysqld.sh restart
```
##### nginx
```bash
cd ${SERVICE_HOME}/nginx/sbin
- 启动: sbin/nginx -c conf/nginx.conf -p ./
- 停止: sbin/nginx -c conf/nginx.conf -p ./ -s stop
- reload: sbin/nginx -c conf/nginx.conf -p ./ -s reload
```

##### redis
`3.0 beta` 版本的 `redis` 为单机模式。

    cd ${SERVICE_HOME}/redis
    - 启动: ./redis-server.sh start
    - 停止: ./redis-server.sh stop

##### zookeeper
单机上不同端口上部署的伪 `zookeeper `集群
```bash
cd ${SERVICE_HOME}/zookeeper
- 启动: ./script/zk1 start; ./script/zk2 start ; ./script/zk3 start
- 停止: ./script/zk1 stop; ./script/zk2 stop ; ./script/zk3 stop
```
##### gse
gse 有多个模块。启动时由顺序要求， 第一次启动时，顺序依次为：

1. `yydba`
2. `gsedba`
3. `gseagent`
3. `gsetask`
4. `gsedata`
5. `gseapiserver`
6. `gsebtfileserver`

> Note: 进程都正常启动之后，如果 `yydba` 进程挂了，直接启动它，不需要重启依赖它的其他进程。


如果需要跨云管理功能。还需要启动 `gsegsetransitserver`
下面以 `gsedba`, `gseagent` 为例说明如何启动和停止， 启动和停止脚本分别为各模块目录下的`start.sh`, `quit.sh`， （`yydba` 的管理脚本在 `yydba/gsedba` 目录下）

- gseagent
`gseagent` 安装在`/usr/local/gse/gseagent` 下面. 启动时需要注意一下。
启动命令如下：
`$ cd /usr/local/gse/gseagent `
`- 启动  ./start.sh`
`- 停止  ./quit.sh`

- gsedba

```
cd ${bksuite安装路径}/gse
- 启动: cd gsedba/; ./start.sh
- 停止: cd gsedba/; ./start.sh
```
##### paas
集成平台后台核心 `server`。安装完成后，模块目录位于：`${INSTALL_PATH}/paas/open_paas`
`paas`包含三个4个子服务：

- `login`: 统一登录服务, 提供DiOne用户统一的登录页面和鉴权接口
- `paas`: DiOne开发者中心/桌面, 开发者可以对应用进行新建/发布/下架等管理操作. 发布后的应用, DiOne会提供相应访问地址.
- `appengine`: 负责`paas`与后端`paasagent`的通信，提供app的部署和下架等api接口供paas调用, 托管应用.
- `esb`: 服务总线，简称`ESB`；集成各个系统，以统一的方式（`REST API`）为DiOne平台上的应用提供接口服务。 ESB提供了统一的用户认证、DiOne应用鉴权、请求转发、日志记录等功能，不仅降低了接口的维护成本，而且方便开发者使用。

    ```
    $ cd ${INSTALL_PATH}/paas/open_paas
    - 启动：$ bin/dashboard.sh start all
    - 启动单个服务appengine： $ bin/dashboard.sh start appengine
    - 停止：bin/dashboard.sh stop all
    - 停止单个服务 paas：bin/dashboard.sh stop paas
    - 状态查询：bin/dashboard.sh status
    - 其他：bin/dashboard.sh -h
    ```

##### cmdb
- `cmdb` 依赖于：
    - `nginx` (`nginx` 起停请查看基础模块管理中的说明）

        ```
        $ 启动： common/php/php-fpm.sh start
        $ 停止：common/php/php-fpm.sh stop
        ```
    
##### job
- `job` 平台依赖于 `tomcat`
    
    ```
    $ job/job.sh start
    $ job/job.sh stop
    ```
    
##### gitserver
- `gitserver` 是包管理 `App` 的后台程序, 在安装 `PaaS` 的时候，会自动启动.

    ```bash
    $ cd ${INSTALL_PATH}/common/gitserver; ./start.sh
    $ cd ${INSTALL_PATH}/common/gtiserver; ./stop.sh
    ```

#### 2. PaasAgent 管理
`PaasAgent`是一个编译好的二进制，由 `supervisor` 进行托管，`paasagent` 需要依赖 `nginx` 服务。
主要负责 App 的部署，代码更新，上线，下架等功能。是开发者中心关键的后台服务
##### paasagent
- `paasagent` 运行时所需要的 `nginx` 入口配置文件路径在`common/nginx/nginx_conf`,  应该与这个路径`paas/paasagent/etc/nginx/paasagent.conf` 时保持一致，是安装 paasagent 时生成的，

```
$ cd  ${INSTALL_PATH}
- 启动：paas/env/bin/supervisorctl -c paas/paasagent/etc/supervisord.conf start paasagent
- 停止：paas/env/bin/supervisorctl -c paas/paasagent/etc/supervisord.conf stop paasagent
- 状态查询：paas/env/bin/supervisorctl -c paas/paasagent/etc/supervisord.conf status
```    

##### SaaS app
- 内置应用的恢复
    在 app 无法访问时，可以通过这个方式进行恢复，进入安装目录执行：
    
    `$ paas/paas_agent/paasagent/bin/recover_apps.sh  paas/paas_agent/apps/`

#### 3. datasvr服务管理
- `datasvr` 依赖服务如下：
    - `kafka`
    - `elasticsearch`
    - `beanstalk`
这些依赖的服务以及监控服务都使用 supervisord 进行托管。因此启动 supervisord 就可以把 datasvr 所欲服务器启动起来：
DiOne 3.0 beta安装部署
----
[TOC]

## 模块说明
社区版3.0, 分为3个模块：

- 基础模块
    - `paas`
    - `gse`
    - `cmdb`
    - `job`
    - `gitserver`
- `PaasAgent`
    - 正式环境
    - 测试环境
- `datasvr` 
    - `api`
    - `monitor`
    - `databus`

> <font color="red" size="6px">**重要说明**:</font>

- 基于可靠性保障的原因，`3.0 beta` 版本中自带了`nginx`，`mysql`，`php` `redis` 等基础服务的软件包，安装脚本 `bk.sh` 也计划在未来的版本中丢弃，改用更友好的安装脚本。因此，`3.0 beta` 版本的安装脚本`bk.sh`与也仅限于全新安装。尽管如此，<font color="green">本文末尾提供了从`2.0`升级到`3.0 beta` 的手动操作方法, 以便老用户使用</font>
- <font color="red">安装前请认真阅读安装准备中的说明</font>

## 部署需求
1. `PaasAgent` 正式环境和测试环境必须分开部署。（若不需要`paasagent`测试环境, 则可以不部署)
2. 除说明1之外，从技术上来看，3个模块可以全部部署在同一台机器上，但不建议这么做
3. 建议机器数量及部署方式如下：
    
    | 机器数量 | 部署方式 | 备注 |
    | --- | --- | --- |
    | 1 | 全部模块部署在一台机器上 | 无app测试环境 |
    | 2 | 一台部署：基础模块 + `PaasAgent` 正式环境<br>一台部署：datasvr |  内存16G+, 生产环境不建议这么操作|
    | 3 | 一台部署：基础模块 + `PaasAgent` 正式环境<br>一台部署：datasvr <br>一台部署：`PaasAgent `测试环境 | 推荐的最小配置，datasvr<br>建议8G 以上内存 |
    | <font color="green">4 | <font color="green">一台部署：基础模块<br>一台部署：`PaasAgent` 正式环境<br>一台部署：datasvr<br>一台部署：`PaasAgent` 测试环境| <font color="green">每台4核8G 以上配置，生产环境<br>使用的最小化建议部署方式</font> |
    | 5+ | 目前安装脚本不支持。需要修改的配置较多，<br>会在后续的版本中优化，以增加扩展性和可用性 |  |
4. Server 服务器最低配置

    | 服务器数|    0-100台|    100-500台|    500-1000|  1000台以上|
| --- | --- | --- | ---| --- |
|CPU|    4核|    8核|    8核|    16核|
|内存|    8G|    8G|    16G    |32G|
|系统盘|    50G|    100G|    200G|    300G|
|/data盘|    50G|    100G|    200G|    300G|
注：如果是搭建测试环境，系统配置请至少是4核8G

5. 浏览器推荐使用 `chrome` 访问

## 各模块安装说明
<font color="red" size="3px">**重要**:</font>本节所示安装说明，仅限于在新的环境中安装。若机器曾安装过旧版本，请先把旧版本目录删除，并杀掉进程列表中匹配下列名称的进程。

```
    supervisor
    monit
    php-fpm
    mysql
    gse.conf
    java
    nginx
    bk_license
    redis-server
    paas_agent
    open_paas
    erlang
    python
```
    
### 1. 安装准备
- 准备安装目录，建议安装在系统中较大的分区中的公共目录。<font color="red">不能安装在用户家目录下</font>
- 下载安装包。并解压
    注意： 不能解压到旧版本的目录
- 生成证书文件。根据 paas 所在的 mac 地址生成 ssl 证书，并把证书文件包复制到解压后的目录
>Note： 目前3.0 beta 版的证书需要内部生成.请联系白杨。

    ```bash
    > tar xf bksuit-3.0.9-beta.tgz
    > cp ssl_certificates.tgz bksuite-3.0.9-beta/
    ```

- 同2.0的部署类似，基本配置信息在 `bk.conf` 文件中。所有服务器上根据实际情况修改3.0 版本中，增加了4个配置项。


        # 根域
        BASE_DNS=bking.com
        # PAAS平台的域名前缀
        PAAS_DNS_PREFIX=paas
        # 配置平台的域名前缀
        CMDB_DNS_PREFIX=cmdb
        # 作业平台的域名前缀
        JOB_DNS_PREFIX=job
        # Nginx的监听端口
        NGINX_PORT=80
        # 本机的内网IP：不支持0.0.0.0 (必须修改)
        INNERIP=x.x.x.x
        # 本机的外网IP：用于proxy跨云管理功能，如果不需要该功能，请设置为本机的内网IP。不支持0.0.0.0 (必须修改)
        OUTERIP=x.x.x.x
        # 基础模所在的服务器IP，本机安装基础模块则填写本机 IP, 若各。不支持0.0.0.0 (必须修改)
        PAAS_IP=x.x.x.x
        # PaasAgent的测试环境IP：如果不需要测试环境，请设置为本机的内网IP。不支持0.0.0.0 (必须修改)
        PAASAGENT_TESTIP=x.x.x.x
        # PaasAgent 的正式环境IP：不支持0.0.0.0 (必须修改)
        PAASAGENT_PRODIP=x.x.x.x
        # PaasAgent 的安装模式：如果本机要安装PAASAGENT，则要设置该选项。测试环境为 test，正式环境为 prod
        PAASAGENT_MODE=test
        # PAASAGENT是否独立部署：如果本机要安装PAASAGENT，则要设置该选项。如果本机要同时安装PAAS和PAASAGENT，请设置为 no，否则设置为 yes
        PAASAGENT_ONLY=yes
        # ---------- new add ----------------
        # zookeeper的IP地址，zookeeper 与基础模板安装在同一服务器上，填写所在基础模块服务器的内网IP地址
        ZK_IP=x.x.x.x
        # mysql数据库所在服务器IP，即基础模块所在服务器的内网IP地址
        MYSQL_IP=x.x.x.x
        # 证书鉴权服务器所在服务器IP，即基础模块(paas)所在服务器的内网IP地址
        CERTS_IP=x.x.x.x
        # datasvr的IP，建议单独一台服务器，不和基础模块共用
        DATASVR_IP=x.x.x.x

### 2. 基础模块安装
- 基础模块依赖如下服务：

    - `mysql`
    - `nginx`
    - `rabbitmq`
    - `tomcat`
    - `zookeeper`
 

- 基础模块，会安装 `cmdb`，`paas`，`job` 3个基础平台，`gse` 管控通道,  以及他们依赖的服务，**这些服务安装到同一台机器上**
在3.0 中，沿用了2.0的做法，依次执行如下操作， 操作前请确保已正确配置 `bk.conf`：

    ```bash
    $ cd bksuite-3.0.9-beta
    $ vi bk.conf     # 根据说明编辑好 bk.conf 文件
     $ ./bk.sh init paas
    $ ./bk.sh install paas
    ```
- 上述步骤操作完成之后，通过 `./bk.sh summary` 可以查看基础模块所有服务的运行状况

> Note: 
> 若执行`./bk.sh summary` 提示`Monit: the monit daemon is not running`, 可以通过命令手动执行启动：`./bk.sh start monit` 启动 `monit`，`5-10`分钟后，再执行`./bk.sh summary`查看状态

### 3. PaasAgent 安装
- `PaasAgent` 依赖如下服务：
    - `rabbitmq` ： `PaasAgent`正式环境和测试 环境共用一套 `rabbitmq` 服务，因此，仅需要在安装 `PaasAgent` 的<font color="red">正式环境机器上执行</font>
- `PaasAgent`的安装类似基础模块：依次执行如下操作， 操作前请确保已正确配置 `bk.conf` ,  
    - 如果是正式环境，`bk.conf` 中的 `PAASAGENT_MODE` 设置为 `prod`.
    - 如果是测试环境，`PAASAGENT_MODE` 设置为 `test`.
    
    ```bash
    $ cd bksuite-3.0.9-beta
    $ vi bk.conf    # 根据说明编辑好 bk.conf 文件
    $ ./bk.sh init paasagent
    $ ./bk.sh install paasagent
    $ ./bk.sh install rabbitmq
    ``` 

### 4. datasvr安装

- datasvr依赖如下服务
    - `Kafka`
    -  `zookeeper`

- 依次执行如下操作， 操作前请确保已正确配置 `bk.conf`, 确保，各项已正确配置
    **datasvr需要单独一台机器安装**。

    ```bash
    $ vi bk.conf    # 根据说明编辑好bk.conf
    $ ./bk.sh init datasvr
    $ ./bk.sh install datasvr
    ```
    以上步骤中包含了安装 `Kafka` 的步骤, 并自动配置了相关的服务
    正常启动的情况下，cd 到安装目录下，通过以下命令，看到的服务，应该都是在 `RUNNING` 状态
    `common/python/bin/supervisorctl -c datasvr/bk_conf/common/supervisord.conf status`
    
    > Note: datasvr 不能使用 ./bk.sh summary 来查看状态

### 5. App (SaaS应用)安装部署
- 安装 `agent_setup app`
     
     `agent安装`的安装包已经打包在完整包中，在开发者中心点击部署即可。
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 找到`bk_agent_setup` 所在的行，点击部署

- 安装DiOne监控`app`
    DiOne监控包含了一个纯后台的子模块，请求 `paas`接口 需要进行 `token` 认证的步骤。
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 点击一键部署应用
    - 3. 上传监控 `app` 的 `SaaS` 安装包，点击一键部署
    - <font color="red">4. 登陆 `datasvr` 所在机器，进入安装目录，执行脚本`./update_monitor_token.sh`</font>。

- 安装日志检索`app`
    
    与 App: `agent安装`不一样， 该包从 Smart 市场下载，通过上传的方式进行部署。多了一个上传步骤
    
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 点击一键部署应用
    - 3. 上传日志检索 `app` 的 `SaaS` 安装包，点击一键部署
    - 4. 日志检索 `app` 需要调用监控 `app` 后台的接口，因此<font color="red">在使用日志检索前, 确保已经按照安装监控`app`的步骤操正常安装了监控 `app`</font>
- 安装包管理`app`
    同DiOne监控一样，包管理 app 也是一个包含后台应用子模块。需要进行 `token` 认证。
    - 1. 打开`paas.bking.com` (`bk.conf`中配置的paas所在域名)
    - 2. 进入开发者中心 -> 内置应用， 点击一键部署应用
    - 3. 上传包管理 `app` 的 `SaaS` 安装包，点击一键部署
    - <font color="metagan">4. 登陆 `datasvr` 所在机器，进入安装目录，执行脚本`./add_wlist_cdman.sh`。</font>

## 各模块服务管理
各模块安装完成之后，通过`ps -ef` 可以看到多了不少进程。有`uwsgi`,`python`, `java`等等之类的。
这些程序基本都是通过 `supervirsord`, `monit`来管理的。因为下一个版本的服务管理方式会进行更多的优化，因此这个版本中，在本节主要简单阐述各模块下子模块的常用进程管理。

### 1. 服务配置
- 略。安装过程中已自动配置。我们不计划在`3.0 beta` 版中阐述如何通过修改配置进行服务的独立运行及部署。

### 2. 服务进程管理

#### 1. 基础模块管理
本节描述各个模块的子模块及依赖服务如何<font color="red">在不依靠`监管服务`的情况下进行启停操作</font>
基础服务均*安装^1*在`${install_path}/common`目录下。假设为 SERVICE_HOME
##### mysql
```bash
> cd ${SERVICE_HOME}/mysql
- 启动:  ./mysqld.sh start
- 停止:  ./mysqld.sh stop
- 重启:  ./mysqld.sh restart
```
##### nginx
```bash
cd ${SERVICE_HOME}/nginx/sbin
- 启动: sbin/nginx -c conf/nginx.conf -p ./
- 停止: sbin/nginx -c conf/nginx.conf -p ./ -s stop
- reload: sbin/nginx -c conf/nginx.conf -p ./ -s reload
```

##### redis
`3.0 beta` 版本的 `redis` 为单机模式。

    cd ${SERVICE_HOME}/redis
    - 启动: ./redis-server.sh start
    - 停止: ./redis-server.sh stop

##### zookeeper
单机上不同端口上部署的伪 `zookeeper `集群
```bash
cd ${SERVICE_HOME}/zookeeper
- 启动: ./script/zk1 start; ./script/zk2 start ; ./script/zk3 start
- 停止: ./script/zk1 stop; ./script/zk2 stop ; ./script/zk3 stop
```
##### gse
gse 有多个模块。启动时由顺序要求， 第一次启动时，顺序依次为：

1. `yydba`
2. `gsedba`
3. `gseagent`
3. `gsetask`
4. `gsedata`
5. `gseapiserver`
6. `gsebtfileserver`

> Note: 进程都正常启动之后，如果 `yydba` 进程挂了，直接启动它，不需要重启依赖它的其他进程。


如果需要跨云管理功能。还需要启动 `gsegsetransitserver`
下面以 `gsedba`, `gseagent` 为例说明如何启动和停止， 启动和停止脚本分别为各模块目录下的`start.sh`, `quit.sh`， （`yydba` 的管理脚本在 `yydba/gsedba` 目录下）

- gseagent
`gseagent` 安装在`/usr/local/gse/gseagent` 下面. 启动时需要注意一下。
启动命令如下：
`$ cd /usr/local/gse/gseagent `
`- 启动  ./start.sh`
`- 停止  ./quit.sh`

- gsedba

```
cd ${bksuite安装路径}/gse
- 启动: cd gsedba/; ./start.sh
- 停止: cd gsedba/; ./start.sh
```
##### paas
集成平台后台核心 `server`。安装完成后，模块目录位于：`${INSTALL_PATH}/paas/open_paas`
`paas`包含三个4个子服务：

- `login`: 统一登录服务, 提供DiOne用户统一的登录页面和鉴权接口
- `paas`: DiOne开发者中心/桌面, 开发者可以对应用进行新建/发布/下架等管理操作. 发布后的应用, DiOne会提供相应访问地址.
- `appengine`: 负责`paas`与后端`paasagent`的通信，提供app的部署和下架等api接口供paas调用, 托管应用.
- `esb`: 服务总线，简称`ESB`；集成各个系统，以统一的方式（`REST API`）为DiOne平台上的应用提供接口服务。 ESB提供了统一的用户认证、DiOne应用鉴权、请求转发、日志记录等功能，不仅降低了接口的维护成本，而且方便开发者使用。

    ```
    $ cd ${INSTALL_PATH}/paas/open_paas
    - 启动：$ bin/dashboard.sh start all
    - 启动单个服务appengine： $ bin/dashboard.sh start appengine
    - 停止：bin/dashboard.sh stop all
    - 停止单个服务 paas：bin/dashboard.sh stop paas
    - 状态查询：bin/dashboard.sh status
    - 其他：bin/dashboard.sh -h
    ```

##### cmdb
- `cmdb` 依赖于：
    - `nginx` (`nginx` 起停请查看基础模块管理中的说明）

        ```
        $ 启动： common/php/php-fpm.sh start
        $ 停止：common/php/php-fpm.sh stop
        ```
    
##### job
- `job` 平台依赖于 `tomcat`
    
    ```
    $ job/job.sh start
    $ job/job.sh stop
    ```
    
##### gitserver
- `gitserver` 是包管理 `App` 的后台程序, 在安装 `PaaS` 的时候，会自动启动.

    ```bash
    $ cd ${INSTALL_PATH}/common/gitserver; ./start.sh
    $ cd ${INSTALL_PATH}/common/gtiserver; ./stop.sh
    ```

#### 2. PaasAgent 管理
`PaasAgent`是一个编译好的二进制，由 `supervisor` 进行托管，`paasagent` 需要依赖 `nginx` 服务。
主要负责 App 的部署，代码更新，上线，下架等功能。是开发者中心关键的后台服务
##### paasagent
- `paasagent` 运行时所需要的 `nginx` 入口配置文件路径在`common/nginx/nginx_conf`,  应该与这个路径`paas/paasagent/etc/nginx/paasagent.conf` 时保持一致，是安装 paasagent 时生成的，

```
$ cd  ${INSTALL_PATH}
- 启动：paas/env/bin/supervisorctl -c paas/paasagent/etc/supervisord.conf start paasagent
- 停止：paas/env/bin/supervisorctl -c paas/paasagent/etc/supervisord.conf stop paasagent
- 状态查询：paas/env/bin/supervisorctl -c paas/paasagent/etc/supervisord.conf status
```    

##### SaaS app
- 内置应用的恢复
    在 `app` 无法访问时，可以通过这个方式进行恢复，进入安装目录执行：
    
    `$ paas/paas_agent/paasagent/bin/recover_apps.sh  paas/paas_agent/apps/`

#### 3. datasvr服务管理
- `datasvr` 依赖服务如下：
    - `kafka`
    - `elasticsearch`
    - `beanstalk`

- `cd` 到安装目录下，通过以下命令，看到的服务，应该都是在 `RUNNING` 状态
`common/python/bin/supervisord -c datasvr/bk_conf/common/supervisord.conf`

- 执行后，查看状态：
`common/python/bin/supervisorctl -c datasvr/bk_conf/common/supervisord.conf status`
 未处于 `RUNNING` 状态的服务，单独 `start` 或者 `restart`, 如：
`common/python/bin/supervisorctl -c datasvr/bk_conf/common/supervisord.conf  start common_kafka`

##### kafka
进入安装目录，

```
cd common/kafka/
- 启动： ./start.sh
- 停止： ./stop.sh
```

##### elasticsearch
进入安装目录，

```
cd common/elasticsearch/
- 启动： ./start.sh
- 停止： ./stop.sh
```

##### beanstalk
正常情况下由`monitor`模块的`supervisor`负责启动。
使用 `supervisorctl` 执行

假设安装目录为： `${INSTALL_PATH}`

```
$ cd ${INSTALL_PATH}
$ export PATH=${INSTALL_PATH}/common/python/bin:$PATH
$ supervisorctl -c datasvr/bk_conf/common/supervisord.conf restart bk_bkdata_monitor_thirdparty:bk_bkdata_monitor_beanstalkd
```

或者直接执行，进入安装目录：

```Supervisor
$ ./common/beanstalkd/bin/beanstalkd -p 14721 -b datasvr/bk_run_data/bkdata/bk_bkdata_monitor/ -l 10.135.98.198
```
##### 监控服务
- `api`

    ```
    cd datasvr/bkdata/bk_bkdata_api; ./bin/start.sh
    cd datasvr/bkdata/bk_bkdata_api; ./bin/stop.sh
    ```

- `databus`

    ```
    cd datasvr/bkdata/bk_bkdata_databus; ./bin/start.sh
    cd datasvr/bkdata/bk_bkdata_databus; ./bin/stop.sh
    ```

- `monitor`

    ```
    cd datasvr/bkdata/bk_bkdata_monitor; ./bin/start.sh
    cd datasvr/bkdata/bk_bkdata_monitor; ./bin/stop.sh
    ```

##### kafka
进入安装目录，

```
cd common/kafka/
- 启动： ./start.sh
- 停止： ./stop.sh
```

##### elasticsearch
进入安装目录，

```
cd common/elasticsearch/
- 启动： ./start.sh
- 停止： ./stop.sh
```

##### beanstalk
正常情况下由`monitor`模块的`supervisor`负责启动。
使用 `supervisorctl` 执行

假设安装目录为： `${INSTALL_PATH}`

```
$ cd ${INSTALL_PATH}
$ export PATH=${INSTALL_PATH}/common/python/bin:$PATH
$ supervisorctl -c datasvr/bk_conf/common/supervisord.conf restart bk_bkdata_monitor_thirdparty:bk_bkdata_monitor_beanstalkd
```

或者直接执行，进入安装目录：

```Supervisor
$ ./common/beanstalkd/bin/beanstalkd -p 14721 -b datasvr/bk_run_data/bkdata/bk_bkdata_monitor/ -l 10.135.98.198
```
##### 监控服务

- `api`

    ```
    cd datasvr/bkdata/bk_bkdata_api; ./bin/start.sh
    cd datasvr/bkdata/bk_bkdata_api; ./bin/stop.sh
    ```

- `databus`

    ```
    cd datasvr/bkdata/bk_bkdata_databus; ./bin/start.sh
    cd datasvr/bkdata/bk_bkdata_databus; ./bin/stop.sh
    ```

- `monitor`

    ```
    cd datasvr/bkdata/bk_bkdata_monitor; ./bin/start.sh
    cd datasvr/bkdata/bk_bkdata_monitor; ./bin/stop.sh
    ```


