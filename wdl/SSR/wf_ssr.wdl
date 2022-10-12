version 1.0

import "tasks/ssr.wdl" as ssr

workflow RunSSR{
	input {
		String workdir
		String scriptDir
		String unigene_fasta #cdhit.unigene_fasta

		#Map[String, String] dockerImages
	}

	call ssr.SSRTask as SSR {
			input :
				workdir = workdir,
				scriptDir = scriptDir,
				unigene_fasta = unigene_fasta,
				# image = dockerImages
	}
	output {

	}

}