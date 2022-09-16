version 1.0

task SubreadsTask {
	input {
		String workdir
		String bam	# bam文件的绝对路径
		String movie	# movie号
		String scriptDir

		Int cpu = 2
		String memgb = '4G'
		String image
		String? ROOTDIR = "/export/"

		
	}

	String subreads_dir = ~{workdir} + "/Subreads"

	command <<<
		set -ex
		mkdir -p ~{subreads_dir} && cd ~{subreads_dir}
		if [ -f "~{movie}.subreads.bam" ]; then
			exit 0
		fi
		ln -s ~{bam} ~{movie}.subreads.bam
		ln -s ~{bam}.pbi ~{movie}.subreads.bam.pbi
	>>>

	output {
		String dir = subreads_dir
		String subreads_bam = subreads_dir + "/${movie}.subreads.bam"
		String subreads_bam_pbi = subreads_dir + "/${movie}.subreads.bam.pbi"
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}

	
}

task SubreadsStatTask {
	input {
		String workdir
		Array[String] samples
		String subreads_dir
		String scriptDir

		Int cpu = 2
		String memgb = '4G'
		String image
		String? ROOTDIR = "/export/"
	}
	command <<<
		set -ex
		cd ~{subreads_dir}
		python ~{scriptDir}/stat_barcode.py -i ~{sep=" " samples} -o Post-Filter_Polymerase_reads.summary.xls
		touch stat_subreads_done
	>>>
	output {
		String summary_xls = "${workdir}/Subreads/Post-Filter_Polymerase_reads.summary.xls"
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

