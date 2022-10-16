version 1.0

# 纯三代
import './Isoseq/wf_isoseq.wdl' as wf_isoseq
import './CDhit/wf_cdhit.wdl' as wf_cdhit
import './Annotation/wf_annotation.wdl' as wf_annotation
import './SSR/wf_ssr.wdl' as wf_ssr
import './CDS/wf_cds.wdl' as wf_cds
import './LncRNA/wf_lncRNA.wdl' as wf_lncRNA
import './Saturation_curve/wf_saturation_curve.wdl' as wf_saturation_curve
import './AS/wf_as.wdl' as wf_as
import './TF/wf_tf.wdl' as wf_tf

# 三+二
import './QC/wf_qc.wdl' as wf_qc_ngs
import './NGS_correction/wf_NGScorrect.wdl' as wf_NGScorrect
import './RSEM/wf_rsem.wdl' as wf_rsem


workflow Run_PacBio_Noref{
	input {
		#File dockerImagesJson

		String project	# 合同编号
		String workdir	# 工作目录
		String subreads_info	# pbfile 三代数据，第一列为样品名 第二列为存放路径
		String species_type	# 物种 animal plant fungi
		String? sample_txt	# 【无二代数据，仅三代无参时不填】sample.txt二代测序数据信息 sample.txt第一列样品名，第二列组名，第三列存放路径（R1,R2用逗号隔开）
		String barcode	# barcode序列的fasta文件
		String? compare_txt 	# 【无二代数据，仅三代无参时不填,如果有重复组，需要做差异表达则有compare.txt文件】，第一列和第二列比较（第一列为实验组，第二列为对照组）；若无需做差异比较分析则忽略忽该参数（是否做看差异分析表）
		String? venn	# 【无韦恩分析不填】差异基因venn分析的文件信息venn_cluster.txt，放在项目路径下（是否做看差异分析表）
		String scriptDir	# 脚本路径
		Array[String] samples 


	}
	#Map[String, String] dockerImages = read_json(dockerImagesJson)


	
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