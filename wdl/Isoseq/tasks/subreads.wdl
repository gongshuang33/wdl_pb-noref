version 1.0

task SubreadsTask {
	input{
		String workdir
		String scriptDir
		String subreads_info
	}
	
	String subreads_dir = workdir + "/Subreads"

	command <<<
		set -ex
		mkdir -p ~{subreads_dir} && cd ~{subreads_dir}
		if [ -f "get_subreads_done" ]; then
			exit 0
		fi
		python3 ~{scriptDir}/getSubreads.py ~{subreads_info} ~{subreads_dir}
		touch get_subreads_done		
	>>>
	
	output {
		String dir = subreads_dir
	}

}

task SubreadsStatTask {
	input {
		String subreads_dir
		String scriptDir
	}
	command <<<
		set -ex
		if [ -f 'stat_subreads_done' ]; then
			exit 0
		fi

		cd ~{subreads_dir}
		python ~{scriptDir}/stat_barcode.py -i *.subreads.bam -o Post-Filter_Polymerase_reads.summary.xls
		touch stat_subreads_done
	>>>
	
	output {
		String summary_xls = subreads_dir + "/Post-Filter_Polymerase_reads.summary.xls"
	}
}