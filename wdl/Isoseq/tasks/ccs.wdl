version 1.0

task CCSTask {
	input {
		String workdir
		String sample
		String scriptDir
		String subreads_dir

		Int cpu = 8
		String memgb = '16G'
		#String image
		String? ROOTDIR = "/export/"
	}
	
	String ccs_dir = workdir + "/CCS"

	command <<<
		set -ex
		mkdir -p ~{ccs_dir}/~{sample} && cd ~{ccs_dir}/~{sample}
		if [ -f "run_ccs_done" ]; then
			exit 0
		fi
		if [ ! -f  'ccs_done' ];then
			/export/pipeline/RNASeq/Software/Miniconda/bin/ccs --min-passes 1 --min-rq 0.9 --max-length 50000 --min-length 100	~{subreads_dir}/~{sample}.subreads.bam  ~{sample + ".ccs.bam"} -j ~{cpu}
			touch ccs_done
		fi
		python ~{scriptDir}/seq_np_rq.py ~{sample + ".ccs.bam"}
		Rscript ~{scriptDir}/plot_np_rq.r  ~{sample} 
		perl ~{scriptDir}/fastaDeal.pl -attr id:len ~{sample + ".ccs.fasta"} > ~{sample + ".ccs.fasta.len"}
		Rscript ~{scriptDir}/ccs_length_distribution.R ~{sample + ".ccs.fasta.len"} ~{sample}
		convert ~{sample + "_np_rq.png"} ~{sample + "_np_rq.pdf"}
		touch run_ccs_done
	>>>
	output {
		String dir = ccs_dir
		Array[String] ccs_fasta = [sample, ccs_dir + "/" + sample + "/${sample}.ccs.fasta"]
	}
	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}



task CCSStatTask {
	input {
		String ccs_dir
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		#String image
		String? ROOTDIR = "/export/"
	}


	command <<< 
		set -ex
		cd ~{ccs_dir}
		if [ -f 'run_ccs_stat_done' ]; then
			exit 0
		fi
		python ~{scriptDir}/ccs_stat.py > ROI_reads.summary.xls
		cat */*.ccs.fasta > total.ccs.fasta
		touch run_ccs_stat_done
	>>>
	output {
		String dir = ccs_dir
		String roi_reads_summary_xls = ccs_dir + "/ROI_reads.summary.xls"
	}
	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}
 