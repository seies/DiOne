# 3.0.20
## bug fix
    - 重新编译 php, 支持 CentOS 6
    - 使用 libxml2 2.7, glibc 2.14  重新编译 zookeeper.so
    - 修复升级 paasagent 后, paas 的 config.sh 中的 db 信息为空的问题
    - 清理掉安装包中的 zk 带有初始脏数据,会导致升级 zk 时失败.
    - 修复升级后, monit 二进制没有替换的问题
    - 修复升级 paasagent 后, paas下的4个模块状态异常的问题

# 3.0.19
## bug fix
    - 升级 zk 后, 用于支持 php 的 zookeeper 扩展未安装
    - 修改bk.conf 中的 nginx 端口后, 端口检查列表需要同步更新
    - 升级时,添加 zklib 到动态库查找路径后,未生效的问题
# 3.0.18
##  新增
    - bk.sh 增加 status, 查看当前主机上部署的模块运行状态
    - bk.sh summary 功能修改为查看当前模块部署的服务的基本信息.
    - 安装完成后,标记服务器所安装的模块
    - php 增加 zookeeper 的扩展支持
    - 安装完成后,自动添加开机启动项
    - 添加 crontab 任务, 检查 monit,supervisor 等进程管理器服务
    - 增加 $HOME/.bkrc, 登陆后自动加载环境 bksuite 相关的额环境变量

## bug fix
    - bk.conf 中修改了 NGINX_PORT , 部署后,访问不了saas

# 3.0.17
## bug fix
    - 监控databus 修复部分监控字段类型与上报长度不匹配的问题
    - 修复自带的 mysql 中，动态库软连接失效的问题
# 3.0.16
## bug fix
    - 修复 agent 安装后，各页面显示 agent 未安装的问题
    - 为 mysql 启动时添加LD_LIBRARY_PATH

# 3.0.15
## bug fix
    - 修复升级 rabbitmq 时目标目录未创建，配置文件未生成的问题
    - 修复安装 datasvr 后，kafka 和 es 没启动的问题。
    - 修复升级 paasagent 后进程状态异常的问题

# 3.0.14
## 新增
    - 增加 es_tool.py 工具
    - 增加通过 epel 库安装 monit
    - 修复 windows agent 执行脚本执行乱码的问题

## bug fix
    - 修复升级后无法回退的问题
    - 修复升级后paasagent 激活失败的问题
    - 修复upgrade_db 函数冲突的问题

# 3.0.13
## 新增
    - 增加 upgrade 功能，提供2.0-3.0的自动升级脚本
    - 增加升级回退功能(仅可回退到升级前的状态，升级后产生的数据，回退后不可用)。
    - job 支持下次登录时自动进入上一次切换的业务
    - job 增加人物强制终止功能
    - job 分发文件支持本机传本机
    - 监控采集器增加跨云支持

## 优化
    - 合并update_bkdata_token.sh, update_logsearch_token.sh脚本为update_bkdata_token.sh，同时支持日志检索 app, 监控 app 的 token 更新
    - 优化 agent 激活，rabbitmq 激活的代码
    - 优化多个管理脚本，取消多个脚本的模板
    - bk.sh 优化，玻璃环境变量的定义到单独的文件中
    - 更新监控平台的db 初始化文件。

## bugfix
    - 部署脚本check_port 中的bug
    - 单独部署 paasagent  时，function文件为根据实际情况生成
    - job UI 的一些 bug 修复
    - 集成平台paas前端面板展示的 bug
    - 增加组件通道管理初始化动作到安装脚本
    - 增加组件缺失的文档
    - 修复自定义日志清晰配置中的分隔符错误
    - 监控 api 修复跨云管理功能中访问接口通过 ip 改为通过域名访问

# 3.0.12
## bug fix:
    - 安装监控后台时，域名配置模板未更新

# 3.0.11
## bug fix:
    - 部署时初始化crontab，避免监控启动时部分模块报错
    - 监控平台请求esb 时，域名中的主机名hardcode 为paas,job,cmdb, 改为跟随用户配置
    - 因绑定 ip 错误导致的监控平台调用 ijobs 失败

# 3.0.10
## bug fix:
    - 修复采集器下发冲突的bug:监控平台 api: host-specific 引起的非法路径报错
## 优化
    - 恢复 monit 对 gse 的监控擦用 process 检测。

# 3.0.9
## bugfix
    - job平台更新默认的联系人为 admin

# 3.0.8
## 新增
    - 新增用于需要更新logsearch中需要的 app_token 的脚本
## 优化
    - 更新 bk_bkdata_monitor.sql

## bug fix
    - 修复common/checker中检查gse 存活情况异常的 bug


