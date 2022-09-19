version 1.0

import 'tasks/cds.wdl' as cds

workflow RunCDS {
	input {
		String workdir 
		String scriptDir 
		String unigene_fasta
		String polished_hq_fa
		String cdhit_isoforms_fasta
		String NGS_corrected_fasta
		#Map[String, String] dockerImages
	}

	call cds.CDSTask as CDS {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = unigene_fasta,
			polished_hq_fa = polished_hq_fa,
			cdhit_isoforms_fasta = cdhit_isoforms_fasta,
			NGS_corrected_fasta = NGS_corrected_fasta,
			#image = dockerImages
	}

	output {

	}
}