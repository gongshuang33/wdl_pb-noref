version 1.0

import 'tasks/enrich_tasks.wdl' as enrich_tasks

workflow RunGOEnrich {
	input {
		Array[String] comp_strings
		String projectdir
		String diff_dir_done
		String go_annotation_xls
		String scriptDir
		# Map[String, String] dockerImages
	}

	call enrich_tasks.GoPreTask {
		input:
			projectdir = projectdir,
			go_annotation_xls = go_annotation_xls,
			scriptDir = scriptDir,
			# image = dockerImages["basic"]
	}

	scatter (comp_string in comp_strings) {
		call enrich_tasks.GoEnrichTask {
			input:
				go_dir_done = GoPreTask.go_dir_done,
				comp_string = comp_string,
				diff_dir_done = diff_dir_done,
				scriptDir = scriptDir,
				# image = dockerImages['enrich']
		}
	}

	output {
		String go_dir = GoPreTask.go_dir_done
	}
}


workflow RunKEGGEnrich {
	input {
		Array[String] comp_strings
		String projectdir
		String diff_dir_done
		String No_HumanDisease_map
		String scriptDir
		# Map[String, String] dockerImages
	}

	call enrich_tasks.KeggPreTask {
		input:
			projectdir = projectdir,
			No_HumanDisease_map = No_HumanDisease_map,
			scriptDir = scriptDir,
			# image = dockerImages['basic']
	}

	scatter (comp_string in comp_strings) {
		call enrich_tasks.KeggEnrichTask {
			input:
				kegg_dir_done = KeggPreTask.kegg_dir_done,
				comp_string = comp_string,
				diff_dir_done = diff_dir_done,
				scriptDir = scriptDir,
				# image = dockerImages['enrich']
		}
	}

	output {
		String kegg_dir = KeggPreTask.kegg_dir_done
	}
}