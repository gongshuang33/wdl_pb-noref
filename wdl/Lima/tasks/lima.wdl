version 1.0

task LimaTask {
	input {
		String workdir
		String sample
		String barcodes = "/export/pipeline/RNASeq/Pipeline/pbbarcoding/scripts/Sequel2_isoseq_barcode.fa"

		Int cpu = 8
		String memgb = '16G'
		String image
		String? ROOTDIR = "/export/"
	}

	String lima_dir = workdir + "/Lima/"
	String lima_sample_dir = lima_dir + sample + "/"

	command <<<
		set -ex
		mkdir -p ~{lima_sample_dir} && cd ~{lima_sample_dir}
		lima ~{lima_sample_dir}~{sample}.ccs.bam ~{barcodes} ~{sample}.fl.bam --isoseq --peek-guess -j ~{cpu}
		touch run_lima_1_done
	>>>

	output {
		String dir = lima_dir
		String fl_bam = lima_sample_dir + "${sample}.fl.bam"
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
		String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		cd ~{lima_dir}
		python ~{scriptDir}/lima_stat.py lima_stat.xls
		touch run_lima_stat_done
	>>>

	output {
		String lima_stat_xls = "lima_stat.xls"
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}