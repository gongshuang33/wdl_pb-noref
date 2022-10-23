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
import './QC/wf_qc.wdl' as wf_qc
import './NGS_correction/wf_NGScorrect.wdl' as wf_NGScorrect
import './RSEM/wf_rsem.wdl' as wf_rsem
import "Diff/wf_DGE.wdl" as wf_DGE
import "Enrich/wf_func_enrich.wdl" as wf_func_enrich
import "common.wdl" as common


workflow Run_PacBio_Noref{
	input {
		#File dockerImagesJson

		String project	# 合同编号
		String workdir	# 工作目录(项目目录)
		String pbfile	# pbfile 三代数据，第一列为样品名 第二列为存放路径
		String species_type	# 物种 animal plant fungi
		File? sample_txt	# 【无二代数据，仅三代无参时不填】sample.txt二代测序数据信息 sample.txt第一列样品名，第二列组名，第三列存放路径（R1,R2用逗号隔开）
		String barcode	# barcode序列的fasta文件
		File? compare_txt 	# 【无二代数据，仅三代无参时不填,如果有重复组，需要做差异表达则有compare.txt文件】，第一列和第二列比较（第一列为实验组，第二列为对照组）；若无需做差异比较分析则忽略忽该参数（是否做看差异分析表）
		String? venn	# 【无韦恩分析不填】差异基因venn分析的文件信息venn_cluster.txt，放在项目路径下（是否做看差异分析表）
		String scriptDir	# 脚本路径
		String ccs_bam_txt

		Int split_num 	# 功能注释拆分数
		String name = "unigene"	# 功能注释NAME  default:Unigene
	}

	#Map[String, String] dockerImages = read_json(dockerImagesJson)
	
	# isoseq
	call wf_isoseq.RunIsoseq as Isoseq{
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			pbfile = pbfile,
			ccs_bam_txt = ccs_bam_txt,
			#dockerImages = dockerImages[]
	}

	# QC_ngs
	call wf_qc.RunQC as QC{
		input:
			workdir = workdir,
			scriptDir = scriptDir,	
			sample_txt = sample_txt,
			#dockerImages = dockerImages[]
	}

	# NGS_correction
	call wf_NGScorrect.RunNGScorrect as NGScorrect{
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			fq_lists = QC.fq_lists,
			all_polished_fa = Isoseq.polished_hq_fasta,
			#dockerImages = dockerImages[]
	}

	# CDhit
	call wf_cdhit.RunCDhit as CDhit {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			NGS_corrected_fasta = NGScorrect.NGS_corrected_fasta,
			all_polished_fa = Isoseq.all_polished_fa,
			#dockerImages = dockerImages[]
	}

	# RSEM
	call wf_rsem.RunRSEM as RSEM {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			cdhit_togene = CDhit.cdhit_togene,
			cdhit_isoforms_fasta = CDhit.cdhit_isoform_fa,
			sample_txt = sample_txt,
			sample_clean_fqs = QC.sample_clean_fqs,
			#dockerImages = dockerImages[]
	}

	# Annotation
	call wf_annotation.RunAnnotation as Annotation {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = CDhit.unigene_fasta,
			species_type = species_type,
			split_num = split_num,
			name = name,
			#dockerImages = dockerImages[]
	}

	# SSR
	call wf_ssr.RunSSR as SSR {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = CDhit.unigene_fasta,
			#dockerImages = dockerImages[]
	}

	# CDS
	call wf_cds.RunCDS as CDS {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = CDhit.unigene_fasta,
			polished_hq_fasta = Isoseq.polished_hq_fasta,
			cdhit_isoforms_fasta = CDhit.cdhit_isoform_fa,
			NGS_corrected_fasta = NGScorrect.NGS_corrected_fasta,
			#dockerImages = dockerImages[]
	}

	# LncRNA
	call wf_lncRNA.RunLncRNA as lncRNA {
		input:
			projectdir = workdir,
			ScriptDir = scriptDir,
			species_type = species_type,
			novel_cds_removed_fa = CDS.cds_removed_isoform_fasta,
			#dockerImages = dockerImages[]
	}

	# Saturation_curve
	call wf_saturation_curve.RunSaturationCurve as Saturation_curve {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			polished_hq_fasta = Isoseq.polished_hq_fasta,
			cds_dir = CDS.dir,
			#dockerImages = dockerImages[]
	}

	# AS
	call wf_as.RunAS as AS {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = CDhit.unigene_fasta,
			cdhit_dir = CDhit.dir,
			#dockerImages = dockerImages[]
	}

	# TF
	call wf_tf.RunTFTask as TF {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = CDhit.unigene_fasta,
			species_type = species_type,
			cds_dir = CDS.dir,
			#dockerImages = dockerImages[]
	}

	# Diff
	call wf_DGE.RunDGE as DEG {
		input:
			diff_dir = RSEM.diff_dir,
			sample_group = sample_txt,
			compare_txt = compare_txt,
			gene_count = select_first([RSEM.gene_count]),
			gene_fpkm = RSEM.gene_fpkm,
			# gene_tpm = RSEM.gene_tpm,
			scriptDir = scriptDir,
			# dockerImages = dockerImages[]
	}

	call wf_DGE.DgeAddAnnotTask {
		input:
			diff_dir_done = DEG.diff_dir_done,
			go_annotation_xls = Annotation.go_annotation_xls,
			kegg_annotation_xls = Annotation.kegg_annotation_xls,
			scriptDir = scriptDir,
			# image = dockerImages[]
	}

		call common.tsv_to_string as COMM_String{
			input:
				tsv_path = select_first([compare_txt])
		}

	# Enrichment
	call wf_func_enrich.RunGOEnrich {
		input:
			comp_strings = COMM_String.comp_strings,
			projectdir = workdir,
			diff_dir_done = DEG.diff_dir_done,
			go_annotation_xls = Annotation.go_annotation_xls,
			scriptDir = scriptDir,
			# dockerImages = dockerImages[]
	}

	call wf_func_enrich.RunKEGGEnrich {
		input:
			comp_strings = COMM_String.comp_strings,
			projectdir = workdir,
			diff_dir_done = DEG.diff_dir_done,
			No_HumanDisease_map = Annotation.kegg_map,
			scriptDir = scriptDir,
			# dockerImages = dockerImages[]
	}

	output {}


}