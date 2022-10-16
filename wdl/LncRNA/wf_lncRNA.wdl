version 1.0

import 'tasks/lncRNA.wdl' as lncRNA

workflow RunLncRNA {
	input {
		String workdir 
		String species_type 
		String scriptDir 
		String cds_removed_isoform_fasta  #/CDS/cds_removed_isoform.fasta
		String cds_dir

		#Map[String, String] dockerImages
	}

	call lncRNA.LncRNATask as LncRNA {
		input:
			workdir = workdir,
			species_type = species_type,
			scriptDir = scriptDir,
			cds_removed_isoform_fasta =  cds_removed_isoform_fasta,
			# image = dockerImages
	}

	call lncRNA.LncRNAStatTask as LncRNAStat {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			species_type = species_type,
			cds_removed_isoform_fasta =  cds_removed_isoform_fasta,
			lncRNA_dir = LncRNA.dir,
			cds_removed_isoform_fasta = cds_removed_isoform_fasta,
			cds_dir = cds_dir,
			# image = dockerImages
	}

	output {

	}
}