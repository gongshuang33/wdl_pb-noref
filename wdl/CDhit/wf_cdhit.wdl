version 1.0

import 'tasks/cdhit.wdl' as cdhit 

workflow RunCDhit {
	input {
		String workdir
		String scriptDir
		String NGS_corrected_fasta
		#Map[String, String] dockerImages
	}

	call cdhit.CDhitTask as CDhit{
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			NGS_corrected_fasta = NGS_corrected_fasta,
			#image = dockerImages[""]
	}

	output {
		String unigene_fasta = CDhit.unigene_fasta
	}
}
