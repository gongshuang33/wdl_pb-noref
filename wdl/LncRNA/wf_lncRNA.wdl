version 1.0

import 'tasks/lncRNA.wdl' as lncRNA {
	input {
		String workdir 
		String species_type 
		String scriptDir 
		String cds_removed_isoform_fasta  #/CDS/cds_removed_isoform.fasta

		#Map[String, String] dockerImages
	}

	call lncRNA.LncRNATask as LncRNA {
		input:
			workdir = workdir,
			species_type = species_type,
			scriptDir = scriptDir,
			cds_removed_isoform_fasta =  cds_removed_isoform_fasta
			# image = dockerImages
	}

	output {

	}
}