version 1.0

import 'tasks/annotation.wdl' as annot

workflow RunAnnotationTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta
		String species_type
		Int split_num
		String name
		Array[String] dbname 	#[NRStatTask, KEGGStatTask, ...]
		#Map[String, String] dockerImages
	}

	call annot.LinkUnigeneTask as LinkUnigene{
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene_fasta = unigene_fasta,
			species_type = species_type,
			#image = dockerImages[""]
	}


	call annot.AnnotationTask as annotation {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene = LinkUnigene.unigene,
			species_type = species_type,
			split_num = split_num,
			name = name,
			#image = dockerImages[""]
	}

	scatter (i in dbname) {
		call annot.i {
			input:
				annotation_dir = annotation.dir,
				scriptDir = scriptDir,
				#image = dockerImages[""]

		}
	}

	output {
		String annot_dir = annotation.dir
	}
}