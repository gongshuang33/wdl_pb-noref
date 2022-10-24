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
		String? ccs_bam_txt   				# 多个ccs.bam用samtools merge手动合并成一个传进来


		#Map[String, String] dockerImages
	}

	Array[Array[String]] pbfile_data = read_tsv(pbfile)

	call subreads.SubreadsTask as getSubreads {
		input:
			workdir = workdir,
			pbfile = pbfile ,
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}
	call subreads.SubreadsStatTask as statSubreads {
		input:
			subreads_dir = getSubreads.dir,
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}

	if(!defined(ccs_bam_txt)) {
		scatter (line in pbfile_data) {
			call ccs.CCSTask as CCS {
				input:
					workdir = workdir,
					sample = line[0],
					scriptDir = scriptDir,
					subreads_dir = getSubreads.dir,
					#image = dockerImages[""]
			}
		}
		call ccs.CCSStatTask as CCSStat {
			input:
				ccs_dir = select_first(CCS.dir),
				scriptDir = scriptDir
		}

		scatter (i in CCS.ccs_fasta) {
			String sample = i[0]
			String ccs_bam = i[1]
			call lima.LimaTask as Lima {
				input:
					workdir = workdir,
					sample = sample,
					ccs_dir = select_first(CCS.dir),
					ccs_dir = ccs_bam,
					#image = dockerImages[""]
			}
		}

		
	}

	if(defined(ccs_bam_txt)) {
		Array[Array[String]] ccs_bam = read_tsv(ccs_bam_txt)
	
		# scatter (i in range(length(ccs_bam[0]))) {
		scatter (i in ccs_bam) {
			String sample = i[0]
			String ccs_bam = i[1]
			call lima.LimaTask as Lima {
				input:
					workdir = workdir,
					sample = sample,
					# ccs_dir = CCS.dir[0],
					ccs_dir = ccs_bam,
					#image = dockerImages[""]
			}
		}
	}

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
				#image = dockerImages[""]
		}
	}
	call refine.RefineStatTask as RefineStat {
		input:
			refine_dir = Refine.dir[0],
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