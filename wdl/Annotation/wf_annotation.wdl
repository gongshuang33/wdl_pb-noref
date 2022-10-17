version 1.0

import 'tasks/annotation.wdl' as annot

workflow RunAnnotation {
	input {
		String workdir
		String scriptDir
		String unigene_fasta #来自wf_cdhit.unigene_fasta
		String species_type
		Int split_num
		String fa_prefix = "unigene.fasta"
		String name = "unigene"
		#Map[String, String] dockerImages
	}

	call annot.AnnotPreTask as AnnotPre {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			unigene = unigene_fasta,
			fa_prefix = fa_prefix,
			n_splits = split_num,
			species_type = species_type,
			# image = dockerImages[""]
	}

# 	scatter (i in range(split_num)) {
# 		Int split_i = i + 1
# 		call annot.GOTask as GO{
# 			input:
# 				split_sh_dir = AnnotPre.split_sh_dir,
# 				fa_name = AnnotPre.fa_name,
# 				split_i = split_i,
# 				# image = dockerImages[""]
# 		}

# 		call annot.KEGGTask as KEGG {
# 			input:
# 				split_sh_dir = AnnotPre.split_sh_dir,
# 				fa_name = AnnotPre.fa_name,
# 				split_i = split_i,
# 				# image = dockerImages[""]
# 		}

# 		call annot.NRTask as NR {
# 			input:
# 				split_sh_dir = AnnotPre.split_sh_dir,
# 				fa_name = AnnotPre.fa_name,
# 				split_i = split_i,
# 				# image = dockerImages[""]
# 		}

# 		call annot.KOGTask as KOG {
# 			input:
# 				split_sh_dir = AnnotPre.split_sh_dir,
# 				fa_name = AnnotPre.fa_name,
# 				split_i = split_i,
# 				# image = dockerImages[""]
# 		}

# 		call annot.SwissProtTask as SwissProt {
# 			input:
# 				split_sh_dir = AnnotPre.split_sh_dir,
# 				fa_name = AnnotPre.fa_name,
# 				split_i = split_i,
# 				# image = dockerImages[""]
# 		}
# 	}
  
# 	call annot.CombineGOTask as CombineGO {
# 		input:
# 			go_done_files = GO.done_file,
# 			annot_dir = AnnotPre.dir,
# 			scriptDir = scriptDir,
# 			n_splits = split_num,
# 			fa_name = fa_prefix,
# 			prefix = name,
# 			# image = dockerImages[""]
# 	}

# 	call annot.CombineKEGGTask as CombineKEGG {
# 		input:
# 			kegg_done_files = KEGG.done_file,
# 			annot_dir = AnnotPre.dir,
# 			scriptDir = scriptDir,
# 			n_splits = split_num,
# 			fa_name = fa_prefix,
# 			species_type = species_type,
# 			prefix = name,
# 			# image = dockerImages[""]
# 	}

# 	call annot.CombineKOGTask as CombineKOG {
# 		input:
# 			kog_done_files = KOG.done_file,
# 			annot_dir = AnnotPre.dir,
# 			scriptDir = scriptDir,
# 			n_splits = split_num,
# 			fa_name = fa_prefix,
# 			prefix = name,
# 			# image = dockerImages[""]
# 	}

# 	call annot.CombineNRTask as CombineNR {
# 		input:
# 			nr_done_files = NR.done_file,
# 			annot_dir = AnnotPre.dir,
# 			scriptDir = scriptDir,
# 			n_splits = split_num,
# 			fa_name = fa_prefix,
# 			prefix = name,
# 			# image = dockerImages[""]
# 	}

# 	call annot.CombineSwissProtTask as CombineSwissProt {
# 		input:
# 			swissprot_done_files = SwissProt.done_file,
# 			annot_dir = AnnotPre.dir,
# 			scriptDir = scriptDir,
# 			n_splits = split_num,
# 			fa_name = fa_prefix,
# 			prefix = name,
# 			# image = dockerImages[""]
# 	}

	output {
	}
}