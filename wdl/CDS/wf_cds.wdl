version 1.0

import 'tasks/cds.wdl' as cds

workflow RunCDS {
	input {
		String workdir 
		String scriptDir 
		String unigene_fasta 			# cdhit.unigene_fasta
		String cdhit_isoforms_fasta		# cdhit.cdhit_isoform_fa
		String? NGS_corrected_fasta		# ngs 二代
		String polished_hq_fasta		# isoseq.polished_hq_fasta
		#Map[String, String] dockerImages
	}

	String good_fasta = select_first([NGS_corrected_fasta, polished_hq_fasta])

	call cds.CDSTask as CDS {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = unigene_fasta,
			polished_hq_fasta = polished_hq_fasta,
			cdhit_isoforms_fasta = cdhit_isoforms_fasta,
			good_fasta = good_fasta,
			#image = dockerImages
	}

	output {
		String cds_removed_isoform_fasta = CDS.cds_removed_isoform_fasta
		String dir = CDS.dir
	}
}