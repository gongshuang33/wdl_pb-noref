# 三代无参WDL
## 1、测试步骤
### 验证WDL合法性：
```shell
/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/womtool-80.jar validate wf_isoseq.wdl
```
### 生成input文件
```shell
/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/womtool-80.jar inputs wf_isoseq.wdl > input.json
```
### 运行workflow（测试时建议写进work.sh脚本投递）
```shell
/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/cromwell-80.jar run wf_isoseq.wdl -i input.json
```
### work.sh 
```shell
set -vex
cd /export/personal1/gongshuang/ceshi/Isoseq03/Isoseq [wf_isoseq.wdl脚本目录]
/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/cromwell-80.jar run wf_isoseq.wdl -i input.json
touch wf_isoseq_done
```

## 2、wf_isoseq.wdl input参数：（路径用绝对路径）

- scriptDir	**String**	脚本路径	示例："/export/personal1/gongshuang/ceshi/scripts"
- subreads_info	 **File**	subreads路径文件，文件第一列为样本名，第二列为对应的subreads.bam
- samples	**Array[String]**	样本名列表，如["bc1001"]
- workdir	**String**	工作目录
