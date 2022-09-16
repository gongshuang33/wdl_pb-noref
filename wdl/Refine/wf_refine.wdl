version 1.0

import "tasks/refine.wdl" as refine

workflow RunRefine{
	input {
		Array[String] samples
		String workdir
		String barcodes
		String scriptDir
		String roi_reads_summary_xls # from wf_lima.wdl's output

		#Map[String, String] dockerImages
	}

	scatter (smp in samples) {
		call lima.RefineTask as Refine {
			input:
				workdir = workdir,
				sample = smp,
				#image = dockerImages["Refine"]
		}
	}

	call refine.RefineStatTask as RefineStat {
		input:
			refine_dir = Refine.refine_dir
			scriptDir = scriptDir,
			roi_reads_summary_xls = roi_reads_summary_xls
			#image = dockerImages["Refine"]
	}

	output {
		
	}

}