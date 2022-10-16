version 1.0

task SubreadsTask {
	input{
		String workdir
		String scriptDir
		String pbfile

		Int cpu = 1
		String memgb = '2G'
		# String image
		String? ROOTDIR = "/export/"
	}
		
	String subreads_dir = workdir + "/Subreads"

	command <<<
		set -ex
		mkdir -p ~{subreads_dir} && cd ~{subreads_dir}
		if [ -f "get_subreads_done" ]; then
			exit 0
		fi
		python <<EOF
			import os
			subreads_file = ~{pbfile}
			work_dir = ~{subreads_dir}
			with open(subreads_file) as f:
				sample = []
				for line in f.readlines():
					movie = line.strip().split()[0]
					bam = line.strip().split()[1]
					sample.append(movie)
					if not os.path.exists('%s/%s.subreads.bam' % (work_dir, movie)):
						os.system("ln -s %s %s/%s.subreads.bam" % (bam, work_dir, movie))
						os.system("ln -s %s.pbi %s/%s.subreads.bam.pbi" % (bam, work_dir, movie))
		EOF
		touch get_subreads_done		
	>>>
		
	output {
		String dir = subreads_dir
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
		String subreads_dir
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image
		String? ROOTDIR = "/export/"
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
	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}