version 1.0

import "tasks/lima.wdl" as lima

workflow RunLima{
	input {
		Array[String] samples
		String workdir
		String barcodes
		String scriptDir

		#Map[String, String] dockerImages
	}

	scatter (smp in samples) {
		call lima.LimaTask as Lima {
			input:
				workdir = workdir,
				sample = smp,
				#image = dockerImages["Lima"]
		}
	}

	call lima.LimaStatTask as LimaStat {
		input:
			lima_dir = Lima.dir[1],
			scriptDir = scriptDir,
			#image = dockerImages["Lima"]
	}
}