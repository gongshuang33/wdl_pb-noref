version 1.0

task SubreadsTask {
	input {
		String workdir
		String bam
		String movie

		
	}

	command <<<
		set -ex
		cd ~{workdir}
		mkdir -p Subreads && cd Subreads

		if [ -f "~{movie}.subreads.bam" ]; then
			exit 0
		fi

		ln -s ~{bam} ~{movie}.subreads.bam
		ln -s ~{bam}.pbi ~{movie}.subreads.bam.pbi
	>>>

	output {
		String movie = "${movie}.subreads.bam"
	}

	
}

task SubreadsStatTask {
	input {
		String workdir
		Array[String] sample
	}
	command <<<
		set -ex
		cd ~{workdir}/Subreads
		python /home/fengl/Scripts/personal_scripts/stat_barcode.py -i ~{sep=" " sample} -o Post-Filter_Polymerase_reads.summary.xls

		touch stat_subreads_done
	>>>
	output {
		String result = "${workdir}/Subreads/Post-Filter_Polymerase_reads.summary.xls"
	}
}

