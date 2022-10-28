version 1.0


task GoPreTask {
	input {
		String projectdir
		String go_annotation_xls
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image

		String? ROOTDIR = "/export/"
	}

	String go_dir = projectdir + "/Enrichment/GO"

	command {
		set -ex

		mkdir -p ${go_dir} && cd ${go_dir}
		if [ -f "go_pre.done" ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ${go_dir}
		python3 ${scriptDir}/prepare_GO.py \
			--goMap ${go_annotation_xls} 

		touch go_pre.done
		date
		" > go_pre.sh
		bash go_pre.sh > go_pre_STDOUT 2> go_pre_STDERR
	}

	output {
		String GO_term2gene = go_dir + "/GO_term2gene.txt"
		String GO_term2name = go_dir + "/GO_term2name.txt"
		String go_dir_done = go_dir
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task GoEnrichTask {
	input {
		String go_dir_done
		String comp_string
		String diff_dir_done
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image

		String? ROOTDIR = "/export/"
	}

	String comp_dir = go_dir_done + "/${comp_string}"
	String dge_all_list = diff_dir_done + "/${comp_string}/${comp_string}.DEGlist.txt"
	String dge_up_list = diff_dir_done + "/${comp_string}/${comp_string}.DEGlist_up.txt"
	String dge_down_list = diff_dir_done + "/${comp_string}/${comp_string}.DEGlist_down.txt"

	command {
		set -x

		mkdir -p ${comp_dir} && cd ${comp_dir}
		if [ -f "go_enrich.done" ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ${comp_dir} 
		sh ${scriptDir}/ClusterProfiler.sh GO \
			${dge_all_list} ${comp_string}
		sh ${scriptDir}/ClusterProfiler.sh GO \
			${dge_up_list} ${comp_string}
		sh ${scriptDir}/ClusterProfiler.sh GO \
			${dge_down_list} ${comp_string}

		touch go_enrich.done
		date
		" > go_enrich.sh
		bash go_enrich.sh > go_enrich_STDOUT 2> go_enrich_STDERR
	}

	output {
		String comp_dir_done = comp_dir
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task KeggPreTask {
	input {
		String projectdir
		String No_HumanDisease_map
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image

		String? ROOTDIR = "/export/"		
	}

	String kegg_dir = projectdir + "/Enrichment/KEGG"

	command {
		set -ex

		mkdir -p ${kegg_dir} && cd ${kegg_dir}
		if [ -f "kegg_pre.done" ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ${kegg_dir}
		python3 ${scriptDir}/prepare_KEGG.py \
			--keggMap ${No_HumanDisease_map}

		touch kegg_pre.done
		date
		" > kegg_pre.sh
		bash kegg_pre.sh > kegg_pre_STDOUT 2> kegg_pre_STDERR
	}

	output {
		String KEGG_term2gene = kegg_dir + "/KEGG_term2gene.txt"
		String KEGG_term2name = kegg_dir + "/KEGG_term2name.txt"
		String kegg_dir_done = kegg_dir
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task KeggEnrichTask {
	input {
		String kegg_dir_done
		String comp_string
		String diff_dir_done
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image

		String? ROOTDIR = "/export/"
	}

	String comp_dir = kegg_dir_done + "/${comp_string}"
	String dge_all_list = diff_dir_done + "/${comp_string}/${comp_string}.DEGlist.txt"
	String dge_up_list = diff_dir_done + "/${comp_string}/${comp_string}.DEGlist_up.txt"
	String dge_down_list = diff_dir_done + "/${comp_string}/${comp_string}.DEGlist_down.txt"

	command {
		set -x

		mkdir -p ${comp_dir} && cd ${comp_dir}
		if [ -f "kegg_enrich.done" ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ${comp_dir}
		sh ${scriptDir}/ClusterProfiler.sh KEGG \
			${dge_all_list} ${comp_string}
		sh ${scriptDir}/ClusterProfiler.sh KEGG \
			${dge_up_list} ${comp_string}
		sh ${scriptDir}/ClusterProfiler.sh KEGG \
			${dge_down_list} ${comp_string}

		touch kegg_enrich.done
		date
		" > kegg_enrich.sh
		bash kegg_enrich.sh > kegg_enrich_STDOUT 2> kegg_enrich_STDERR
	}

	output {
		String comp_dir_done = comp_dir
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}   
}