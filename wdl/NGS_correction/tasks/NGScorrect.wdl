version 1.0

task NGScorrectTask {
	input {
        String workdir
        String scriptDir
		Array[String]? fq_lists
		String all_polished_fa

        Int cpu = 8
        String memgb = '16G'
        # String image

        String? ROOTDIR = "/export/"
	}

	String NGScorrectDir = workdir + '/NGS_correction'
	String fq_list = select_first([fq_lists])
	command <<<
		set -ex
		hostname
		date
		mkdir -p ~{NGScorrectDir} && cd ~{NGScorrectDir}
		if [ -f 'ngs_correction_done' ];then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{NGScorrectDir}
		/export/personal/pengh/Software/LoRDEC-0.5.3-Linux/bin/lordec-correct -2 ~{sep=', ' fq_list} -a 100000 -k 19 -s 3 -m 8000MB -T 10 -o NGS_corrected.fasta -i ~{all_polished_fa}
		perl ~{scriptDir}/fastaDeal.pl -attr id:len NGS_corrected.fasta > NGS_corrected.fasta.len
		/export/pipeline/RNASeq/Software/R/R_3.5.1/bin/Rscript ~{scriptDir}/Cluster_Bar.R NGS_corrected.fasta.len NGS_corrected.fasta.length_distribution
		rm *.h5
		touch ~{NGScorrectDir}/ngs_correction_done
		date
		" > run_ngs_correct.sh
		bash run_ngs_correct.sh > run_ngs_correct_STDOUT 2> run_ngs_correct_STDERR

	>>>

	output {
		String dir = NGScorrectDir
		String NGS_corrected_fasta = NGScorrectDir + "/NGS_corrected.fasta" #传给cdhit
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}