version 1.0

task AnnotPreTask {
	input {
		String unigene   # cdhit/unigene.fa
		String fa_prefix
		Int n_splits
		String species_type
		String workdir
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String annot_dir = workdir + "/Annotation"

	command <<<
		set -ex

		mkdir -p ~{annot_dir} && cd ~{annot_dir}

		if [ -f "annot_pre.done" ]; then
			exit 0
		fi

		ln -s ~{unigene} ~{fa_prefix}

		python3 ~{scriptDir}/Run_Annotation_with_diamond.py \
			-~{species_type} -k -i -n -s -cog \
			-c ~{n_splits} -f ~{fa_prefix}

		touch annot_pre.done
	>>>

	output {
		String split_sh_dir = annot_dir + "/~{fa_prefix}.function.work/Script"
		String fa_name = fa_prefix
		String dir = annot_dir
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

# task GOTask {
# 	input {
# 		String split_sh_dir
# 		String fa_name
# 		Int split_i

# 		Int cpu = 4
# 		String memgb = '16G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	String split_dir = split_sh_dir + "/GO"

# 	command<<<
# 		set -ex

# 		cd ~{split_dir}

# 		if [ -f "~{fa_name}.~{split_i}.DONE" ]; then
# 			exit 0
# 		fi

# 		bash go.~{fa_name}.~{split_i}.sh > ~{split_i}.stdout 2> ~{split_i}.stderr
# 	>>>
# 	output {
# 		String done_file = split_dir + "/~{fa_name}.~{split_i}.DONE"
# 	}
# 	runtime {
# 		#docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }
# task KEGGTask {
# 	input {
# 		String split_sh_dir
# 		String fa_name
# 		Int split_i

# 		Int cpu = 4
# 		String memgb = '16G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	String split_dir = split_sh_dir + "/KEGG"

# 	command<<<
# 		set -ex
# 		cd ~{split_dir}
# 		if [ -f "~{fa_name}.~{split_i}.DONE" ]; then
# 			exit 0
# 		fi
# 		bash kegg.~{fa_name}.~{split_i}.sh > ~{split_i}.stdout 2> ~{split_i}.stderr
# 	>>>
# 	output {
# 		String done_file = split_dir + "/~{fa_name}.~{split_i}.DONE"
# 	}
# 	runtime {
# 		#docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task NRTask {
# 	input {
# 		String split_sh_dir
# 		String fa_name
# 		Int split_i

# 		Int cpu = 4
# 		String memgb = '16G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	String split_dir = split_sh_dir + "/KOG"

# 	command<<<
# 		set -ex
# 		cd ~{split_dir}
# 		if [ -f "~{fa_name}.~{split_i}.DONE" ]; then
# 			exit 0
# 		fi
# 		bash kog.~{fa_name}.~{split_i}.sh > ~{split_i}.stdout 2> ~{split_i}.stderr
# 	>>>
# 	output {
# 		String done_file = split_dir + "/~{fa_name}.~{split_i}.DONE"
# 	}
# 	runtime {
# 		#docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task KOGTask {
# 	input {
# 		String split_sh_dir
# 		String fa_name
# 		Int split_i

# 		Int cpu = 4
# 		String memgb = '16G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	String split_dir = split_sh_dir + "/NR"

# 	command<<<
# 		set -ex
# 		cd ~{split_dir}
# 		if [ -f "~{fa_name}.~{split_i}.DONE" ]; then
# 			exit 0
# 		fi
# 		bash nr.~{fa_name}.~{split_i}.sh > ~{split_i}.stdout 2> ~{split_i}.stderr
# 	>>>
# 	output {
# 		String done_file = split_dir + "/~{fa_name}.~{split_i}.DONE"
# 	}
# 	runtime {
# 		#docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task SwissProtTask {
# 	input {
# 		String split_sh_dir
# 		String fa_name
# 		Int split_i

# 		Int cpu = 4
# 		String memgb = '16G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	String split_dir = split_sh_dir + "/Swissprot"

# 	command<<<
# 		set -ex
# 		cd ~{split_dir}
# 		if [ -f "~{fa_name}.~{split_i}.DONE" ]; then
# 			exit 0
# 		fi
# 		bash swissprot.~{fa_name}.~{split_i}.sh > ~{split_i}.stdout 2> ~{split_i}.stderr
# 	>>>
# 	output {
# 		String done_file = split_dir + "/~{fa_name}.~{split_i}.DONE"
# 	}
# 	runtime {
# 		#docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task CombineGOTask {
# 	input {
# 		Array[String] go_done_files
# 		String annot_dir
# 		String scriptDir
# 		Int n_splits
# 		String fa_name
# 		String prefix 

# 		Int cpu = 1
# 		String memgb = '2G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	Boolean DONE = length(go_done_files) == n_splits

# 	command<<<
# 		set -ex

# 		cd ~{annot_dir}
# 		if [ -f "go_stat_work_done" ]; then
# 			exit 0
# 		fi
# 		if [ ~{DONE} == 'false']; then
# 			exit 1
# 		fi
# 		cd ~{annot_dir}

# 		cat ~{fa_name}.function.work/*/*iprOut > ~{fa_name}.function.result/~{prefix}.iprOut

# 		python ~{scriptDir}/deal_ipr2go_V2.py --iprFile ~{prefix}.iprOut --goAnnot ~{prefix}.go.annot --gene
# 		python ~{scriptDir}/Annot_GO.py -a ~{prefix}.go.annot -p ~{prefix}
# 		#sh ~{scriptDir}/WEGO.sh Unigene Unigene.go.wego.txt
# 		#Rscript ~{scriptDir}/plot_GO.classification.R Unigene.go.level2.xls GO_classification
# 		Rscript ~{scriptDir}/go_annot_bar_plot.R ~{prefix}.go.classification.xls GO_classification

# 		touch ~{annot_dir}/go_stat_work_done
# 		date


# 		touch go_stat.done
# 	>>>

# 	output {
# 		String go_class_xls = annot_dir + "/${prefix}.go.classification.xls"
# 		String go_wego_txt = annot_dir + "/${prefix}.go.wego.txt"
# 		String go_annotation_xls = annot_dir + "/${prefix}.go.annotation.xls"
# 	}
# 	runtime {
# 		# docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task CombineKEGGTask {
# 	input {
# 		Array[String] kegg_done_files
# 		String annot_dir
# 		String scriptDir
# 		String species_type
# 		Int n_splits
# 		String fa_name
# 		String prefix 

# 		Int cpu = 1
# 		String memgb = '2G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	Boolean DONE = length(kegg_done_files) == n_splits

# 	command<<<
# 		set -ex

# 		cd ~{annot_dir}
# 		if [ -f "kegg_stat_work_done" ]; then
# 			exit 0
# 		fi
# 		if [ ~{DONE} == 'false']; then
# 			exit 1
# 		fi
# 		cat ~{fa_name}.function.work/*/*kegg.m8 > ~{fa_name}.function.work/~{prefix}.kegg.m8
# 		python ~{scriptDir}/m8tobesthit.py --m8file ~{fa_name}.function.work/~{prefix}.kegg.m8 --besthit ~{prefix}.kegg.m8.besthit

# 		python ~{scriptDir}/get_ko_from_blast.py ~{prefix}.kegg.m8.besthit ~{prefix}.ko ~{species_type}
# 		python ~{scriptDir}/ko2annot.py ~{prefix}.ko ~{scriptDir}/kegg.class.xls > ~{prefix}.kegg.annotation.xls
# 		python ~{scriptDir}/ko2map.py ~{prefix}.ko ~{prefix}.map ~{species_type}
# 		python ~{scriptDir}/stat_kegg_class.py -i ~{prefix}.ko -o ~{prefix}.kegg_class.xls -s ~{species_type}

# 		python ~{scriptDir}/rm_human_disease.py ~{prefix}.map ~{prefix}.kegg_class.xls ~{prefix}.No_HumanDisease.map ~{prefix}.No_HumanDisease.kegg_class.xls
# 		python ~{scriptDir}/rearrange_map.py ~{prefix}.No_HumanDisease.map ~{prefix}.No_HumanDisease.map.xls
# 		Rscript ~{scriptDir}/plot_KEGG.classification.R ~{prefix}.No_HumanDisease.kegg_class.xls KEGG_classification

# 		/export/pipeline/RNASeq/Database/KEGG/mark_genes/bin/mark_genes.py -a ~{prefix}.ko -o ~{prefix}.kegg.maps
# 		python /export/pipeline/RNASeq/Database/KEGG/visualization/Visualize_Kegg_Pathway.py -i ~{prefix}.kegg.maps -k ~{prefix}.No_HumanDisease.map -o kegg_pathway && zip -r -q kegg_pathway.zip kegg_pathway && rm -rf ~{prefix}.kegg.maps kegg_pathway

# 		touch ~{annot_dir}/kegg_stat_work_done
# 		date
# 	>>>

# 	output {
# 		String kegg_ko = annot_dir + "/${prefix}.ko"
# 		String kegg_annotation_xls = annot_dir + "/${prefix}.kegg.annotation.xls"
# 		String kegg_map = annot_dir + "/${prefix}.No_HumanDisease.map"
# 		String kegg_map_xls = annot_dir + "/${prefix}.No_HumanDisease.map.xls"
# 		String kegg_pic_html = annot_dir + "/kegg_pathway.zip"
# 	}
# 	runtime {
# 		# docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task CombineKOGTask {
# 	input {
# 		Array[String] kog_done_files
# 		String annot_dir
# 		String scriptDir
# 		Int n_splits
# 		String fa_name
# 		String prefix 

# 		Int cpu = 1
# 		String memgb = '2G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	Boolean DONE = length(kog_done_files) == n_splits

# 	command<<<
# 		set -ex

# 		cd ~{annot_dir}
# 		if [ -f "kog_stat_work_done" ]; then
# 			exit 0
# 		fi
# 		if [ ~{DONE} == 'false']; then
# 			exit 1
# 		fi
# 		cat ~{fa_name}.function.work/*/*kog.m8 > ~{prefix}.kog.m8
# 		python ~{scriptDir}/m8tobesthit.py --m8file ~{prefix}.kog.m8 --besthit ~{prefix}.kog.m8.besthit
# 		python ~{scriptDir}/Annot_COG.py -i ~{prefix}.kog.m8.besthit -o ~{prefix}.kog.annotation.xls -s ~{prefix} -c ~{prefix}.kog.classification.xls
# 		Rscript ~{scriptDir}/plot_KOG.classification.R ~{prefix}.kog.classification.xls KOG_classification
# 		touch ~{annot_dir}/kog_stat_work_done
# 		date
# 	>>>

# 	output {
# 	}
# 	runtime {
# 		# docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task CombineNRTask {
# 	input {
# 		Array[String] nr_done_files
# 		String annot_dir
# 		String scriptDir
# 		Int n_splits
# 		String fa_name
# 		String prefix 

# 		Int cpu = 1
# 		String memgb = '2G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}

# 	Boolean DONE = length(nr_done_files) == n_splits

# 	command<<<
# 		set -ex

# 		cd ~{annot_dir}
# 		if [ -f "nr_stat_work_done" ]; then
# 			exit 0
# 		fi
# 		if [ ~{DONE} == 'false']; then
# 			exit 1
# 		fi
		
# 		cat ~{fa_name}.function.work/*/*nr.m8 > ~{prefix}.nr.m8
# 		python ~{scriptDir}/m8tobesthit.py --m8file ~{prefix}.nr.m8 --besthit ~{prefix}.nr.m8.besthit
# 		cut -f 1-4,7-13 ~{prefix}.nr.m8.besthit | sed '1iGene_ID	NR_ID	Identity	Align Length	Q start	Q end	T start	T end	E value	Score	Function' > ~{prefix}.nr.annotation.xls
# 		python ~{scriptDir}/sum_species.py ~{prefix}.nr.annotation.xls species_classification.xls > species_unknown.list
# 		sh ~{scriptDir}/get_nr_pie.sh
# 		Rscript ~{scriptDir}/plot_Species.R
# 		touch ~{annot_dir}/nr_stat_work_done
# 		date
# 	>>>

# 	output {
# 	}
# 	runtime {
# 		# docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }

# task CombineSwissProtTask {
# 	input {
# 		Array[String] swissprot_done_files
# 		String annot_dir
# 		String scriptDir
# 		Int n_splits
# 		String fa_name
# 		String prefix 

# 		Int cpu = 1
# 		String memgb = '2G'
# 		# String image
# 		String? ROOTDIR = "/export/"
# 	}
# 	Boolean DONE = length(swissprot_done_files) == n_splits

# 	command<<<
# 		set -ex

# 		cd ~{annot_dir}
# 		if [ -f "swissprot_stat_work_done" ]; then
# 			exit 0
# 		fi
# 		if [ ~{DONE} == 'false']; then
# 			exit 1
# 		fi
# 		cat ~{fa_name}.function.work/*/*swissprot.m8 > ~{prefix}.swissprot.m8
# 		python ~{scriptDir}/m8tobesthit.py --m8file ~{prefix}.swissprot.m8 --besthit ~{prefix}.swissprot.m8.besthit
# 		python ~{scriptDir}/Annot_SwissProt.py -b ~{prefix}.swissprot.m8.besthit -o ~{prefix}.swissprot.annotation.xls

# 		touch ~{annot_dir}/swissprot_stat_work_done
# 		date
# 	>>>

# 	output {
# 	}
# 	runtime {
# 		# docker: image
# 		cpu: cpu
# 		memory: memgb
# 		root: ROOTDIR
# 	}
# }