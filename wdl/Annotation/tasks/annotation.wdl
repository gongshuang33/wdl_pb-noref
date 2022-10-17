version 1.0

task LinkUnigeneTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta  #来自wf_cdhit.unigene_fasta
		String species_type

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String annotation_dir = workdir + '/Annotation'

	command <<<
		set -ex
		if [ -f 'link_unigene_done' ];then
			exit 0
		fi
		mkdir -p ~{annotation_dir} && cd ~{annotation_dir}
		ln -s ~{unigene_fasta} unigene.fa
		touch link_unigene_done
	>>>

	output {
		String unigene = annotation_dir + "/unigene.fa"
		String dir = annotation_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}

task AnnotationTask {
	input {
		String workdir
		String scriptDir
		String unigene  		# from LinkUnigeneTask.unigene
		String species_type
		Int split_num			# 拆成多少份
		String? name
		String annotation_dir	# from  LinkUnigeneTask.dir

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -vex
		if [ -f 'run_annot_done' ];then
			exit 0
		fi
		mkdir -p ~{annotation_dir} && cd ~{annotation_dir}
		# run_functional_annotation_cds.py 变成具体的命令
		python3 ~{scriptDir}/run_functional_annotation_cds.py --seq ~{unigene} --work_dir ~{annotation_dir} --name ~{name} --species_type ~{species_type} --split_num ~{split_num}
		touch run_annot_done
	>>>

	output {
		String dir = annotation_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}

task NRStatTask {
	input {
		String scriptDir
		String annotation_dir # from AnnotationTask.dir

		Int cpu = 2
		String memgb = '4G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		date
		cd ~{annotation_dir}
		if [ -f 'nr_stat_work_done' ];then
			exit 0
		fi
		cat ~{annotation_dir}/work/Functional_annotation/*/*nr.m8 > Unigene.nr.m8
		python ~{scriptDir}/m8tobesthit.py --m8file Unigene.nr.m8 --besthit Unigene.nr.m8.besthit
		cut -f 1-4,7-13 Unigene.nr.m8.besthit | sed '1iGene_ID	NR_ID	Identity	Align Length	Q start	Q end	T start	T end	E value	Score	Function' > Unigene.nr.annotation.xls
		python ~{scriptDir}/sum_species.py Unigene.nr.annotation.xls species_classification.xls > species_unknown.list
		sh ~{scriptDir}/get_nr_pie.sh
		Rscript ~{scriptDir}/plot_Species.R
		touch nr_stat_work_done
		date
	>>>

	output {
		String Unigene_nr_annotation_xls = annotation_dir + "/Unigene.nr.annotation.xls"
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}
task KEGGStatTask {
	input {
		String annotation_dir # from AnnotationTask.dir
		String scriptDir

		Int cpu = 2
		String memgb = '4G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		date
		cd ~{annotation_dir}
		if [ -f 'kegg_stat_work_done' ];then
			exit 0
		fi
		cat ~{annotation_dir}/work/Functional_annotation/*/*kegg.m8 > ~{annotation_dir}/work/Functional_annotation/shell/KEGG/Unigene.kegg.m8
		python ~{scriptDir}/m8tobesthit.py --m8file ~{annotation_dir}/work/Functional_annotation/shell/KEGG/Unigene.kegg.m8 --besthit Unigene.kegg.m8.besthit

		python ~{scriptDir}/get_ko_from_blast.py Unigene.kegg.m8.besthit Unigene.ko plant
		python ~{scriptDir}/ko2annot.py Unigene.ko ~{scriptDir}/kegg.class.xls > Unigene.kegg.annotation.xls
		python ~{scriptDir}/ko2map.py Unigene.ko Unigene.map plant
		python ~{scriptDir}/stat_kegg_class.py -i Unigene.ko -o Unigene.kegg_class.xls -s plant

		python ~{scriptDir}/rm_human_disease.py Unigene.map Unigene.kegg_class.xls Unigene.No_HumanDisease.map Unigene.No_HumanDisease.kegg_class.xls
		python ~{scriptDir}/rearrange_map.py Unigene.No_HumanDisease.map Unigene.No_HumanDisease.map.xls
		Rscript ~{scriptDir}/plot_KEGG.classification.R Unigene.No_HumanDisease.kegg_class.xls KEGG_classification

		~{scriptDir}/mark_genes.py -a Unigene.ko -o Unigene.kegg.maps
		python ~{scriptDir}/Visualize_Kegg_Pathway.py -i Unigene.kegg.maps -k Unigene.No_HumanDisease.map -o kegg_pathway && zip -r -q kegg_pathway.zip kegg_pathway && rm -rf Unigene.kegg.maps kegg_pathway

		touch kegg_stat_work_done
	>>>

	output {
		String Unigene_kegg_annotation_xls = annotation_dir + "/Unigene.kegg.annotation.xls"
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}
task GOStatTask {
	input {
		String annotation_dir # from AnnotationTask.dir
		String scriptDir

		Int cpu = 2
		String memgb = '4G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		cd ~{annotation_dir}
		if [ -f 'go_stat_work_done' ];then
			exit 0
		fi
		cat ~{annotation_dir}/work/Functional_annotation/*/*iprOut > Unigene.iprOut
		python ~{scriptDir}/deal_ipr2go_V2.py --iprFile Unigene.iprOut --goAnnot Unigene.go.annot --gene
		python ~{scriptDir}/Annot_GO.py -a Unigene.go.annot -p Unigene
		#sh ~{scriptDir}/WEGO.sh Unigene Unigene.go.wego.txt
		#Rscript ~{scriptDir}/plot_GO.classification.R Unigene.go.level2.xls GO_classification
		Rscript ~{scriptDir}/go_annot_bar_plot.R Unigene.go.classification.xls GO_classification

		touch go_stat_work_done
	>>>

	output {
		String Unigene_go_annotation_xls = annotation_dir + "/Unigene.go.annotation.xls"
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}
task SwissprotStatTask {
	input {
		String annotation_dir # from AnnotationTask.dir
		String scriptDir

		Int cpu = 2
		String memgb = '4G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		date
		cd ~{annotation_dir}
		if [ -f 'swissprot_stat_work_done' ];then
			exit 0
		fi
		cat ~{annotation_dir}/work/Functional_annotation/*/*swissprot.m8 > Unigene.swissprot.m8
		python ~{scriptDir}/m8tobesthit.py --m8file Unigene.swissprot.m8 --besthit Unigene.swissprot.m8.besthit
		python ~{scriptDir}/Annot_SwissProt.py -b Unigene.swissprot.m8.besthit -o Unigene.swissprot.annotation.xls

		touch swissprot_stat_work_done
	>>>

	output {
		String Unigene_swissprot_annotation_xls = annotation_dir + "/Unigene.swissprot.annotation.xls"
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}
task KOGStatTask {
	input {
		String annotation_dir # from AnnotationTask.dir
		String scriptDir

		Int cpu = 2
		String memgb = '4G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		cd ~{annotation_dir}
		if [ -f 'kog_stat_work_done' ];then
			exit 0
		fi
		cat ~{annotation_dir}/work/Functional_annotation/*/*kog.m8 > Unigene.kog.m8
		python ~{scriptDir}/m8tobesthit.py --m8file Unigene.kog.m8 --besthit Unigene.kog.m8.besthit
		python ~{scriptDir}/Annot_COG.py -i Unigene.kog.m8.besthit -o Unigene.kog.annotation.xls -s Unigene -c Unigene.kog.classification.xls
		Rscript ~{scriptDir}/plot_KOG.classification.R Unigene.kog.classification.xls KOG_classification

		touch kog_stat_work_done
	>>>

	output {
		String Unigene_kog_annotation_xls = annotation_dir + "/Unigene.kog.annotation.xls"
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}
task TotalStatTask {
	input {
		String annotation_dir
		String scriptDir
		String Unigene_kog_annotation_xls
		String Unigene_go_annotation_xls
		String Unigene_kegg_annotation_xls
		String Unigene_nr_annotation_xls 
		String Unigene_swissprot_annotation_xls

		Int cpu = 2
		String memgb = '4G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		date
		cd ~{annotation_dir}
		if [ -f 'total_stat_work_done' ];then
			exit 0
		fi
		python ~{scriptDir}/annotation_stat_cds.py ~{annotation_dir}/unigene.fa ~{annotation_dir}
		python ~{scriptDir}/get_gene_length.py ~{annotation_dir}/unigene.fa Unigene_length.txt
		python ~{scriptDir}/Sum_Annot.py --input Unigene_length.txt --kog ~{Unigene_kog_annotation_xls} --go ~{Unigene_go_annotation_xls} --kegg ~{Unigene_kegg_annotation_xls} --nr ~{Unigene_nr_annotation_xls} --swissprot ~{Unigene_swissprot_annotation_xls} --output Annotation_Summary.xls
		Rscript ~{scriptDir}/plot_Venn_cds.R Unigene ~{annotation_dir}/
		rm -r Unigene_length.txt VennDiagram*
		touch total_stat_work_done
		date
	>>>

	output {
		String dir = annotation_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	} 
} 
