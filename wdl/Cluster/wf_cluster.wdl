version 1.0

import "tasks/cluster.wdl" as cluster

workflow RunCluster{
	input {
		String workdir
		String scriptDir
		String refine_dir # from wf_refine.wdl
		String ccs_dir	  # from wf_ccs.wdl

		#Map[String, String] dockerImages
	}

	
	call cluster.ClusterTask as Cluster {
		input:
			workdir = workdir,
			refine_dir = refine_dir,
			#image = dockerImages["Cluster"]
	}
		

	call cluster.ClusterStatTask as ClusterStat {
		input:
			cluster_dir = Cluster.dir,
			scriptDir = scriptDir,
			ccs_dir = ccs_dir,
			refine_dir = refine_dir,
			#image = dockerImages["Cluster"]
	}

	output {
		String polished_hq_fa = 
	}

}