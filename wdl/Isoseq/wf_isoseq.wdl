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
		File subreads_info
		Array[String] samples
		#Map[String, String] dockerImages
	}

	call subreads.SubreadsTask as getSubreads {
		input:
			workdir = workdir,
			subreads_info = subreads_info ,
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}
	call subreads.SubreadsStatTask as statSubreads {
		input:
			subreads_dir = getSubreads.dir,
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}

	scatter (samp in samples) {
		call ccs.CCSTask as CCS {
			input:
				workdir = workdir,
				sample = samp,
				scriptDir = scriptDir,
				subreads_dir = getSubreads.dir,
				#image = dockerImages[""]
		}
	}

	call ccs.CCSStatTask as CCSStat {
		input:
			ccs_dir = CCS.dir[0],
			scriptDir = scriptDir
	}

	scatter (samp in samples) {
		call lima.LimaTask as Lima {
			input:
				workdir = workdir,
				sample = samp,
				ccs_dir = CCS.dir[0],
				#image = dockerImages[""]
		}
	}
	
	call lima.LimaStatTask as LimaStat {
		input:
			lima_dir = Lima.dir[0],
			scriptDir = scriptDir,
			#image = dockerImages[""]
	}

	scatter (samp in samples) {
		call refine.RefineTask as Refine {
			input:
				workdir = workdir,
				sample = samp,
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
	}


}