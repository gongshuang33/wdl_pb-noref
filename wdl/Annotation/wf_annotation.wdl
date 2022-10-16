version 1.0

import 'tasks/annotation.wdl' as annot

workflow RunAnnotation {
	input {
		String workdir
		String scriptDir
		String unigene_fasta #来自wf_cdhit.unigene_fasta
		String species_type
		Int split_num
		String? name = "Unigene"
		
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


	call annot.AnnotationTask as Annotation {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			annotation_dir = LinkUnigene.dir,
			unigene = LinkUnigene.unigene,
			species_type = species_type,
			split_num = split_num,
			name = name,
			#image = dockerImages[""]
	}

	call annot.NRStatTask as NRstat{
		input:
			scriptDir = scriptDir,
			annotation_dir = Annotation.dir,
			#image = dockerImages[""]
	}

	call annot.KEGGStatTask as KEGGstat{
		input:
			scriptDir = scriptDir,
			annotation_dir = Annotation.dir,
			#image = dockerImages[""]
	}

	call annot.GOStatTask as GOstat{
		input:
			scriptDir = scriptDir,
			annotation_dir = Annotation.dir,
			#image = dockerImages[""]
	}

	call annot.SwissprotStatTask as Swissprotstat{
		input:
			scriptDir = scriptDir,
			annotation_dir = Annotation.dir,
			#image = dockerImages[""]
	}

	call annot.KOGStatTask as KOGstat{
		input:
			scriptDir = scriptDir,
			annotation_dir = Annotation.dir,
			#image = dockerImages[""]
	}

	call annot.TotalStatTask as Totalstat {
		input:
			annotation_dir = Annotation.dir,
			scriptDir = scriptDir,
			Unigene_kog_annotation_xls = KOGstat.Unigene_kog_annotation_xls,
			Unigene_go_annotation_xls = GOstat.Unigene_go_annotation_xls,
			Unigene_kegg_annotation_xls = KEGGstat.Unigene_kegg_annotation_xls,
			Unigene_nr_annotation_xls = NRstat.Unigene_nr_annotation_xls,
			Unigene_swissprot_annotation_xls = Swissprotstat.Unigene_swissprot_annotation_xls,
			#image = dockerImages[""]
	}
	output {
		String annot_dir = Totalstat.dir
	}
}