version 1.0

import "tasks/ccs.wdl" as ccs

workflow RunCCS{
	input {
		Array[String] samples
		String workdir
		String scriptDir

		#Map[String, String] dockerImages
	}

	scatter (smp in samples) {
		call ccs.CCSTask as CCS {
			input:
				workdir = workdir,
				sample = smp,
				scriptDir = scriptDir,
				#image = dockerImages["CCS"]
		}
	}

	call ccs.CCSStatTask as CCSStat {
		input:
			ccs_dir = CCS.dir[1],
			scriptDir = scriptDir,
			#image = dockerImages["CCS"]
	}

	output {
		String roi_reads_summary_xls = CCSStat.roi_reads_summary_xls
	}

}