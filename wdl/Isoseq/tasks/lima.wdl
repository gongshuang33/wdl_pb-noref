version 1.0

task LimaTask {
	input {
		String workdir
		String sample
		String ccs_bam
		String barcodes

		Int cpu = 2
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String lima_dir = workdir + "/Lima"
	String lima_sample_dir = lima_dir + '/' + sample 

	command <<<
		set -ex
		mkdir -p ~{lima_sample_dir} && cd ~{lima_sample_dir}
		if [ -f 'run_lima_1_done' ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{lima_sample_dir}
		lima ~{ccs_bam} ~{barcodes} ~{sample}.fl.bam --isoseq --peek-guess -j ~{cpu}
		touch run_lima_1_done
		date
		" > ~{sample}_lima.sh
		bash ~{sample}_lima.sh > ~{sample}_lima_stdout 2> ~{sample}_lima_stderr
	>>>

	output {
		String dir = lima_dir
		String fl_bam = lima_sample_dir + '/' +  sample + '.fl.bam'
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task LimaStatTask {
	input {
		String lima_dir
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		cd ~{lima_dir}
		if [ -f 'run_lima_stat_done' ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		python ~{scriptDir}/lima_stat.py lima_stat.xls
		touch run_lima_stat_done
		date
		" > lima_stat.sh
		bash lima_stat.sh > lima_stat_stdout 2> lima_stat_stderr
	>>>

	output {
		String lima_stat_xls = lima_dir + "/lima_stat.xls"
		String dir = lima_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}