version 1.0

import 'tasks/subreads.wdl' as subreads
import 'tasks/ccs.wdl' as ccs
import 'tasks/lima.wdl' as lima
import 'tasks/refine.wdl' as refine
import 'tasks/cluster.wdl' as cluster

workflow RunIsoseq {
	input {
		String workdir
		String scriptDir
		String pbfile
		String? ccs_bam_txt
		String Sequel2_isoseq_barcode_fa = "/export/pipeline/RNASeq/Pipeline/pbbarcoding/scripts/Sequel2_isoseq_barcode.fa"				# 多个ccs.bam用samtools merge手动合并成一个传进来
		#Map[String, String] dockerImages
	}

	Array[Array[String]] pbfile_data = read_tsv(select_first([ccs_bam_txt,pbfile]))

	call subreads.SubreadsTask as Subreads {
		input:
			workdir = workdir,
			pbfile = pbfile ,
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}
	call subreads.SubreadsStatTask as statSubreads {
		input:
			subreads_dir = Subreads.dir,
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}

	if(!defined(ccs_bam_txt)) {
		scatter (line in pbfile_data) {
			call ccs.CCSTask as CCS {
				input:
					workdir = workdir,
					sample = line[0],
					ccs_bam_dir = line[1],
					scriptDir = scriptDir,
					subreads_dir = Subreads.dir,
					ccs_bam_txt = ccs_bam_txt,
					#image = dockerImages[""]
			}
		}
	}

	if(defined(ccs_bam_txt)) {
		scatter (line in pbfile_data) {
			call ccs.CCSBAMTask as CCS {
				input:
					workdir = workdir,
					sample = line[0],
					ccs_bam_dir = line[1],
					scriptDir = scriptDir,
					subreads_dir = Subreads.dir,
					ccs_bam_txt = ccs_bam_txt,
					#image = dockerImages[""]
			}
		}
	}
		
		call ccs.CCSStatTask as CCSStat {
			input:
				ccs_dir = select_first(CCS.dir),
				scriptDir = scriptDir,
				#image = dockerImages[""]
		}

		scatter (i in CCS.ccs_bam) {
			call lima.LimaTask as Lima {
				input:
					workdir = workdir,
					sample = i[0],
					ccs_bam = i[1],
					barcodes = Sequel2_isoseq_barcode_fa,
					#image = dockerImages[""]
			}
		}
	# }

	# if(defined(ccs_bam_txt)) {
	# 	Array[Array[String]] ccs_bams = read_tsv(ccs_bam_txt)

	# 	# scatter (i in range(length(ccs_bam[0]))) {
	# 	scatter (i in ccs_bams) {
	# 		call lima.LimaTask as Lima {
	# 			input:
	# 				workdir = workdir,
	# 				sample = i[0],
	# 				# ccs_dir = CCS.dir[0],
	# 				ccs_bam = i[1],
	# 				#image = dockerImages[""]
	# 		}
	# 	}
	# }
 
	call lima.LimaStatTask as LimaStat {
		input:
			lima_dir = Lima.dir[0],
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}

	scatter (line in pbfile_data) {
		call refine.RefineTask as Refine {
			input:
				workdir = workdir,
				sample = line[0],
				scriptDir = scriptDir,
				lima_dir = LimaStat.dir,
				barcodes = Sequel2_isoseq_barcode_fa,
				#image = dockerImages[""]
		}
	}
	call refine.RefineStatTask as RefineStat {
		input:
			refine_dir = select_first(Refine.dir),
			scriptDir = scriptDir,
			roi_reads_summary_xls = CCSStat.roi_reads_summary_xls,

			#image = dockerImages[""]
	}

	call cluster.ClusterTask as Cluster {
		input:
			workdir = workdir,
			merged_flnc_bam = RefineStat.merged_flnc_bam,
			#image = dockerImages[""]
	}
	call cluster.ClusterStatTask as ClusterStat {
		input:
			cluster_dir = Cluster.dir,
			scriptDir = scriptDir,
			ccs_dir = CCSStat.dir,
			refine_dir = RefineStat.dir,
			#image = dockerImages[""]
	}

	output {
		String polished_hq_fasta = Cluster.polished_hq_fasta
		String all_polished_fa = Cluster.all_polished_fa
	}
}