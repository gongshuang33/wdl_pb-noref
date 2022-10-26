version 1.0

task RefineTask {
	input {
		String workdir
		String sample
		String barcodes
		String scriptDir
		String lima_dir

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String refine_dir = workdir + "/Refine"
	String refine_sample_dir = refine_dir +"/" + sample

	command <<<
		set -ex
		mkdir -p ~{refine_sample_dir} && cd ~{refine_sample_dir}
		if [ -f "run_refine_done" ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{refine_sample_dir}
		isoseq3 refine --require-polya ~{lima_dir}/~{sample}/~{sample}.fl.*_5p--*_3p.bam ~{barcodes} ~{sample}.flnc.bam
		samtools view ~{sample}.flnc.bam | awk '{printf \">\"\$1\"\t\"\$13\"\t\"\$14\"\n\"\$10\"\n\"}' > ~{sample}.flnc.fasta
		touch run_refine_done
		date
		" > ~{sample}_refine.sh
		bash ~{sample}_refine.sh > ~{sample}_refine_stdout 2> ~{sample}_refine_stderr
	>>>

	output {
		String dir = refine_dir
		String flnc_bam = refine_sample_dir + '/' + sample + '.flnc.bam'
		String flnc_fasta = refine_sample_dir + '/' + sample + '.flnc.fasta'
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}



task RefineStatTask {
	input {
		String refine_dir
		String scriptDir
		String roi_reads_summary_xls

		Int cpu = 1
		String memgb = '2G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<< 
		set -ex
		cd ~{refine_dir}
		if [ -f "run_refine_merge_done" ]; then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{refine_dir}
		ls ~{refine_dir}/*/*.flnc.bam > flnc.fofn
		cat ~{refine_dir}/*/*.flnc.fasta > total.flnc.fasta
		perl ~{scriptDir}/fastaDeal.pl -attr id:len total.flnc.fasta > total.flnc.fasta.len
		Rscript ~{scriptDir}/Cluster_Bar.R total.flnc.fasta.len total.flnc.fasta.length_distribution
		python ~{scriptDir}/refine_stat.py ~{roi_reads_summary_xls} > refine_stat.xls
		samtools merge -c -b flnc.fofn merged_flnc.bam
		touch run_refine_merge_done
		date
		" > refine_stat.sh
		bash refine_stat.sh > refine_stat_stdout 2> refine_stat_stderr
	>>>

	output {
		String dir = refine_dir
		String merged_flnc_bam = refine_dir + "/merged_flnc.bam"
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}