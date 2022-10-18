version 1.0

import './tasks/collectResult.wdl' as collectresult

workflow RunCollectResult {
	input {
		String workdir
		String scriptDir
		String? sample_txt
		String? compare_txt
		String? RSEM_done
		#Map[String, String] dockerImages
	}

	call collectresult.CollectResultTask {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			sample_txt = sample_txt,
			compare_txt = compare_txt,
			RSEM_done = RSEM_done,
			enrich_go_done = enrich_go_done,
			enrich_kegg_done = enrich_kegg_done,
			#image = dockerImages
	}
	output {}

}