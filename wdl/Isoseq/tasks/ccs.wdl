version 1.0

task CCSTask {
	input {
		String workdir
		String sample
		String scriptDir
		String subreads_dir
		String? ccs_bam_txt
		String ccs_bam_dir

		Int cpu = 8
		String memgb = '16G'
		#String image
		String? ROOTDIR = '/export/'
	}
	
	String ccs_dir = workdir + '/CCS'

	command <<<
		set -ex
		mkdir -p ~{ccs_dir}/~{sample} && cd ~{ccs_dir}/~{sample}
		if [ -f 'run_ccs_done' ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{ccs_dir}/~{sample}
		if [ ! -f  'ccs_done' ]; then
			ccs --min-passes 1 --min-rq 0.9 --max-length 50000 --min-length 100	~{subreads_dir}/~{sample}.subreads.bam  ~{sample + '.ccs.bam'} -j ~{cpu}
			touch ccs_done
		fi
		python ~{scriptDir}/seq_np_rq.py ~{sample + '.ccs.bam'}
		Rscript ~{scriptDir}/plot_np_rq.r  ~{sample} 
		perl ~{scriptDir}/fastaDeal.pl -attr id:len ~{sample + '.ccs.fasta'} > ~{sample + '.ccs.fasta.len'}
		Rscript ~{scriptDir}/ccs_length_distribution.R ~{sample + '.ccs.fasta.len'} ~{sample}
		convert ~{sample + '_np_rq.png'} ~{sample + '_np_rq.pdf'}
		touch run_ccs_done
		date
		" > ~{sample}_ccs.sh
		bash ~{sample}_ccs.sh > ~{sample}_ccs_stdout 2> ~{sample}_ccs_stderr
	>>>

	
	output {
		String dir = ccs_dir
		Array[String] ccs_bam = [sample, ccs_dir + '/' + sample + '/${sample}.ccs.bam']
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task CCSBAMTask {
	input {
		String workdir
		String sample
		String scriptDir
		String subreads_dir
		String? ccs_bam_txt
		String ccs_bam_dir

		Int cpu = 8
		String memgb = '16G'
		#String image
		String? ROOTDIR = '/export/'
	}
	
	String ccs_dir = workdir + '/CCS'

	command <<<
		set -ex
		mkdir -p ~{ccs_dir}/~{sample} && cd ~{ccs_dir}/~{sample}
		if [ -f 'run_ccs_done' ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{ccs_dir}/~{sample}
		if [ ! -f  'ccs_done' ]; then
			ln -s ~{ccs_bam_dir} ~{sample}.ccs.bam
			ln -s ~{ccs_bam_dir}.pbi ~{sample}.ccs.bam.pbi
			touch ccs_done
		fi
		python ~{scriptDir}/seq_np_rq.py ~{sample + '.ccs.bam'}
		Rscript ~{scriptDir}/plot_np_rq.r  ~{sample} 
		perl ~{scriptDir}/fastaDeal.pl -attr id:len ~{sample + '.ccs.fasta'} > ~{sample + '.ccs.fasta.len'}
		Rscript ~{scriptDir}/ccs_length_distribution.R ~{sample + '.ccs.fasta.len'} ~{sample}
		convert ~{sample + '_np_rq.png'} ~{sample + '_np_rq.pdf'}
		touch run_ccs_done
		date
		" > ~{sample}_ccs.sh
		bash ~{sample}_ccs.sh > ~{sample}_ccs_stdout 2> ~{sample}_ccs_stderr
	>>>

	
	output {
		String dir = ccs_dir
		Array[String] ccs_bam = [sample, ccs_dir + '/' + sample + '/${sample}.ccs.bam']
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
		String? ROOTDIR = '/export/'
	}

	command <<< 
		set -ex
		cd ~{ccs_dir}
		if [ -f 'run_ccs_stat_done' ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{ccs_dir}
		python ~{scriptDir}/ccs_stat.py > ROI_reads.summary.xls
		cat */*.ccs.fasta > total.ccs.fasta
		touch run_ccs_stat_done
		date
		" > ccs_stat.sh 
		bash ccs_stat.sh > ccs_stat_stdout 2> ccs_stat_stderr
	>>>

	output {
		String dir = ccs_dir
		String roi_reads_summary_xls = ccs_dir + '/ROI_reads.summary.xls'
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}
 