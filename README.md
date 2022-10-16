# wdl_pb-noref

#/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/womtool-80.jar validate helloworld.wdl

java -jar /export/pipeline/RNASeq/Software/Cromwell/womtool-80.jar validate helloworld.wdl

#/opt/jdk-11.0.6/bin/java -jar /export/pipeline/RNASeq/Software/Cromwell/womtool-80.jar inputs helloworld.wdl > input.json

	java -jar /export/pipeline/RNASeq/Software/Cromwell/cromwell-80.jar run helloworld.wdl -i input.json
