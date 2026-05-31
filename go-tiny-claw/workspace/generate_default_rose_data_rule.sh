#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"
#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"
#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"
#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"
#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"
#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"
#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"
#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"#!/bin/bash
# 此脚本默认产生Rose客户端需要同步的数据规则集集合文件,减少人工操作复制粘贴或者一个个选择带来的错误情况,脚本应用场景5.0.14.2发布框架版本 热备子系统版本为V1.000.0000000.5
# 用法: 把此脚本放置到指定目录下去执行,执行完毕后,产生一个文件data_rule.txt,下载下来,导入Rose客户端即可
workingDir="$( cd -P "$( dirname "$0"  )" && pwd  )"
data_rule_file=$workingDir/data_rule.txt
# 是否是加密库
is_using_nvxdb=`cat /bak/evo_files/deploy-infos/Evo-runs/runs_status.cfg | grep "is_using_nvxdb=" | awk -F '=' '{print $2}'`
if [[ -e "$data_rule_file" ]]; then
        rm -f $data_rule_file
        touch $data_rule_file
else
        touch $data_rule_file
fi

echo "generate rose syn data rule file begin"
# 默认包含的所有需要同步数据目录或者文件
include_paths[0]=/bis_data/mysql/data/
include_paths[1]=/opt/evo/evo-subsystem/Evo-video/VMS/XML_TV/
include_paths[2]=/opt/evo/evo-subsystem/Evo-video/SS/AlarmDB/
include_paths[3]=/bis_data/rabbitmq/RabbitMQ0/Config/management/var/lib/rabbitmq/mnesia/dahuacloud/
include_paths[4]=/staticpic/
include_paths[5]=/dycpic/
include_paths[6]=/opt/evoWpms/appConfig/
include_paths[7]=/opt/evoWpms/color_temp/
include_paths[8]=/opt/evoWpms/styles/
include_paths[9]=/opt/evoWpms/emap-titlecache
include_paths[10]=/opt/evoWpms/emapTitlecache
include_paths[11]=/opt/evoWpms/download/
include_paths[12]=/data/prometheus/
include_paths[13]=/opt/evo/evo-subsystem/oss-nms/ndfs/storage/data1/
include_paths[14]=/opt/evo/evo-subsystem/Evo-fdbu/redis/appendonly.aof
include_paths[15]=/opt/evo/evo-subsystem/Evo-fdbu/redis/dump.rdb
include_paths[16]=/opt/cloud/dahua/VCS/CameraNode
include_paths[17]=/opt/cloud/dahua/VCS/Camera
include_paths[18]=/opt/cloud/dahua/VCS/Programs/Camera0/
include_paths[19]=/opt/cloud/dahua/VCS/Programs/Camera1/
include_paths[20]=/opt/cloud/dahua/VCS/Programs/CameraNode0/
include_paths[21]=/opt/cloud/dahua/VCS/Programs/CameraNode1/
include_paths[22]=/opt/evo/evo-subsystem/Evo-escorthandover/evo-escorthandover/apkDownload/
include_paths[23]=/opt/evoWpms/dhdv/
include_paths[24]=/opt/evoWpms/docCustDataset/
include_paths[25]=/opt/evoWpms/doc/
include_paths[26]=/opt/evo/evo-subsystem/Evo-vims/VIDG/ServerList.xml
include_paths[27]=/opt/evo/evo-subsystem/Evo-accesscontrol/ACDG/ServerList.xml
include_paths[28]=/bis_data/mysql/nvx_data/
include_paths[29]=/pic/


echo "[include]" >> $data_rule_file
# 包含的文件目录同步写入 data_rule.txt 文件
for file_path in ${include_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
                  if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
         echo "include path $file_path not exists "
      fi
  fi
done
echo "[/include]" >> $data_rule_file
echo "==============================="
echo "[exclude]" >> $data_rule_file
# 默认需要排除的文件集合
exclude_paths[0]=/bis_data/mysql/data/mysql/user.frm
exclude_paths[1]=/bis_data/mysql/data/mysql/user.MYI
exclude_paths[2]=/bis_data/mysql/data/mysql/user.MYD
exclude_paths[3]=/data/prometheus/chunks_head/
exclude_paths[4]=/data/prometheus/wal/
exclude_paths[5]=/data/prometheus/queries.active
exclude_paths[6]=/data/prometheus/lock
exclude_paths[7]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/clusterConfig
exclude_paths[8]=/opt/cloud/dahua/VCS/Programs/CameraNode1/Config/DNCluster.reg
exclude_paths[9]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/Datanodes.list
exclude_paths[10]=/opt/cloud/dahua/VCS/Programs/Camera1/Config/CameraManager.conf
exclude_paths[11]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/CameraManager.conf
exclude_paths[12]=/opt/cloud/dahua/VCS/Programs/Camera0/Config/Datanodes.list
exclude_paths[13]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/DNCluster.reg
exclude_paths[14]=/opt/cloud/dahua/VCS/Programs/CameraNode0/Config/clusterConfig
exclude_paths[15]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.frm
exclude_paths[16]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYI
exclude_paths[17]=/bis_data/mysql/nvx_data/mysql_data3/mysql/user.MYD
# 排除的文件写入 data_rule.txt 文件
for file_path in ${exclude_paths[@]}; do
  file_path=$(echo $file_path |sed s/[[:space:]]//g | sed 's/\r//')
  if [[ -n $file_path ]]; then
      if [[ -e "$file_path" || -d "$file_path" ]]; then
          if [[ ! "$is_using_nvxdb" -eq 1 && "$file_path" =~ "nvx_data" ]]; then
                          echo "there is not nvxdb environment, filter path: $file_path"
                  else
                          echo "$file_path" >> $data_rule_file
                  fi
      else
        echo "exclude path $file_path not exists "
      fi
  fi
done
echo "[/exclude]" >> $data_rule_file
echo "generate rose syn data rule file success, please download file from path: $data_rule_file"