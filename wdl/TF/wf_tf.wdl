version 1.0

import 'tasks/tf.wdl' as tf

workflow RunTFTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta
		String species_type
		String cds_dir	# from CDS
		#Map[String, String] dockerImages
	}

	call tf.TFTask as TF{
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = unigene_fasta,
			species_type = species_type,
			cds_dir = cds_dir,
			#image = dockerImages[""]
	}

	output {
		String tf_dir = TF.dir
	}
}