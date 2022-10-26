## 1. 测试步骤
### 1.1 验证WDL 语法：
```shell
/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/womtool-80.jar validate PacBio_Noref_RNAseq.wdl
```
### 1.2 生成input文件
```shell
/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/womtool-80.jar inputs PacBio_Noref_RNAseq.wdl > input.json
```
### 1.3 编辑输入文件 input.json
### 1.4 运行workflow（测试时建议写进work.sh脚本,qsub投递）
```shell
# work.sh 
/usr/bin/time --verbose java -jar /export/pipeline/RNASeq/Software/Cromwell/cromwell-80.jar run PacBio_Noref_RNAseq.wdl -i input.json
```
hhh
 