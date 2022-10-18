version 1.0

task CollectResultTask {
	input {
		String workdir
		String scriptDir
		String? sample_txt
		String? compare_txt
		String? RSEM_done
		String? enrich_go_done
		String? enrich_kegg_done

		Int cpu = 2
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String DIFF = 'no'
	String GO_ENRICH = 'no'
	String KEGG_ENRICH = 'no'
	if(defined(compare_txt)) {
		DIFF = 'yes'
		GO_ENRICH = 'yes'
		KEGG_ENRICH = 'yes'
	}

	String RSEM = 'no'
	if(defined(RSEM_done)) {
		RSEM = 'yes'
	}
	
	String QC = 'no'
	String NGS = 'no'
	if(defined(sample_txt)) {
		QC = 'yes'
		NGS = 'yes'
	}

	command <<<
		cd ~{workdir}
		if [ -d '~{project}_Result' ];then
			rm -rf ~{project}_Result
		fi
		python ~{scriptDir}/Isoseq3_noref_result.py --project ~{workdir}  --result ~{project}_Result --diff ~{DIFF} --goenrich ~{GO_ENRICH} --keggenrich ~{KEGG_ENRICH} --RSEM ~{RSEM}  --ngs_correct ~{NGS} --qc ~{QC}

		touch collect_result_done
	>>>

	output {}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}

}