version 1.0

task RefineTask {
	input {
		String projectdir
		String sampleName = 'bc1001'
    
	}

	String workdir = projectdir + "/Refine/${sampleName}"

	command <<<
		set -vex
		hostname
		date
		mkdir -p ~{workdir} && cd ~{workdir}

		/export/pipeline/RNASeq/Software/Miniconda/bin/isoseq3 refine --require-polya /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207335A-01_zhiwu_wangxinjing/Lima/bc1001/bc1001.fl.*_5p--*_3p.bam /export/pipeline/RNASeq/Pipeline/pbbarcoding/scripts/Sequel2_isoseq_barcode.fa bc1001.flnc.bam
		/export/pipeline/RNASeq/Software/Samtools/samtools_v1.9/bin/samtools view bc1001.flnc.bam | awk '{printf ">"$1"\t"$13"\t"$14"\n"$10"\n"}' > bc1001.flnc.fasta

		touch /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207335A-01_zhiwu_wangxinjing/Refine/bc1001/run_refine_1_done
		date
	>>>
}

task RefineStatTask {
	input {}
}