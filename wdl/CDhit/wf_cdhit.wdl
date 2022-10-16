version 1.0

import 'tasks/cdhit.wdl' as cdhit

workflow RunCDhit {
	input {
		String workdir
		String scriptDir
		String? NGS_corrected_fasta		# 二代
		String all_polished_fa 		# cluster.
		#Map[String, String] dockerImages
	}

	call cdhit.CDhitTask as CDhit{
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			all_polished_fa = all_polished_fa,
			NGS_corrected_fasta = NGS_corrected_fasta,
			#image = dockerImages[""]
	}

	output {
		String unigene_fasta = CDhit.unigene_fasta
		String cdhit_isoform_fa = CDhit.cdhit_isoform_fa
		String cdhit_togene = CDhit.cdhit_togene
		String dir = CDhit.dir
	}
}



