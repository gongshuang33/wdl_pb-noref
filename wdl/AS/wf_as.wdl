version 1.0

import 'tasks/as.wdl' as AS

workflow RunASTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta 
		String cdhit_dir
		#Map[String, String] dockerImages
	}

	call AS.ASTask as As {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = unigene_fasta,
			cdhit_dir = cdhit_dir
			#image = dockerImages[""]
	}
}