version 1.0

import './Isoseq/wf_isoseq.wdl' as wf_isoseq
import './QC/wf_qc.wdl' as wf_qc_ngs


workflow Run_PacBio_Noref{
	input {
		#File dockerImagesJson

		String project	# 合同编号
		String workdir	# 工作目录
		String subreads_info	# pbfile 三代测序数据subreads信息pbfile文件第一列为样品名第二列为存放路径
		String pipline_type		# 纯三代无参【pipline_type = 3】还是3+2无参【pipline_type = 3+2】
		String species_type	# 物种 animal plant fungi
		String sample_txt	# 【无二代数据，仅三代无参时不填】sample.txt二代测序数据信息 sample.txt第一列样品名，第二列组名，第三列存放路径（R1,R2用逗号隔开）
		String barcode	# barcode序列的fasta文件
		File compare_txt 	# 【无二代数据，仅三代无参时不填】如果有重复组，需要做差异分析则有compare.txt文件，第一列和第二列比较（第一列为实验组，第二列为对照组）；若无需做差异比较分析则忽略忽该参数（是否做看差异分析表）
		String venn	# 【无韦恩分析不填】差异基因venn分析的文件信息venn_cluster.txt，放在项目路径下（是否做看差异分析表）
		String scriptDir	# 脚本路径
		Array[String] samples 


	}
	#Map[String, String] dockerImages = read_json(dockerImagesJson)

	if(pipline_type == '3') {

		##纯三代流程

	}

	if(pipline_type == '3+2') {

		##三+二流程

	}

	
	# isoseq
	call wf_isoseq.RunIsoseq {
        input:
            workdir = workdir,
            scriptDir = scriptDir,
            subreads_info = subreads_info,
            projectdir = projectdir,
            samples = samples
            #dockerImages = dockerImages[]
    }

	# QC_ngs
	call wf_qc_ngs.RunQC {
		input:

	}
}