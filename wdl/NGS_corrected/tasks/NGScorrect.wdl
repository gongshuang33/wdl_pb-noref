version 1.0

task NGScorrectTask {
	input {
        String workdir
        String sampleName
        Array[Array[String]] sample_clean_fqs
        String scriptDir

        # Int cpu = 8
        # String memgb = '16G'
        # String image

        String? ROOTDIR = "/export/"
	}

	String NGScorrectDir = workdir + '/NGS_corrected'

	command <<<
		set -vex
		hostname
		date
		mkdir -p ~{NGScorrectDir} && cd ~{NGScorrectDir}
		if [ -f 'ngs_correction_done' ];then
			exit 0
		fi
		/export/personal/pengh/Software/LoRDEC-0.5.3-Linux/bin/lordec-correct -2 /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-C-3/Dc-C-3.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-C-3/Dc-C-3.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-B-2/Dc-B-2.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-B-2/Dc-B-2.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-B-1/Dc-B-1.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-B-1/Dc-B-1.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-A-2/Dc-A-2.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-A-2/Dc-A-2.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-A-1/Dc-A-1.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-A-1/Dc-A-1.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-A-3/Dc-A-3.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-A-3/Dc-A-3.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-C-2/Dc-C-2.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-C-2/Dc-C-2.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-C-1/Dc-C-1.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-C-1/Dc-C-1.clean.R1.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-B-3/Dc-B-3.clean.R2.fq.gz,/export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/QC/Dc-B-3/Dc-B-3.clean.R1.fq.gz -a 100000 -k 19 -s 3 -m 8000MB -T 10 -o NGS_corrected.fasta -i /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207631A-01_yanzhichong_gongshuang/Cluster/all.polished.fa
		perl ~{scriptDir}/fastaDeal.pl -attr id:len NGS_corrected.fasta > NGS_corrected.fasta.len
		/export/pipeline/RNASeq/Software/R/R_3.5.1/bin/Rscript ~{scriptDir}/Cluster_Bar.R NGS_corrected.fasta.len NGS_corrected.fasta.length_distribution
		rm *.h5

		touch ~{NGScorrectDir}/ngs_correction_done
		date
	>>>

	output {

	}
}