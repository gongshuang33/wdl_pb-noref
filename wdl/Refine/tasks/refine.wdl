version 1.0

task RefineTask {
	input {
		String workdir
		String sample
		String barcodes = "/export/pipeline/RNASeq/Pipeline/pbbarcoding/scripts/Sequel2_isoseq_barcode.fa"
	}
	command <<<
		set -ex
		
		mkdir -p ~{workdir}/Refine/~{sample} && cd ~{workdir}/Refine/~{sample}

		isoseq3 refine --require-polya ~{workdir}/Lima/~{sample}/~{sample}.fl.*_5p--*_3p.bam ~{barcodes} ~{sample}.flnc.bam
		samtools view ~{sample}.flnc.bam | awk '{printf ">"$1"\t"$13"\t"$14"\n"$10"\n"}' > ~{sample}.flnc.fasta

		touch run_refine_1_done
	>>>
	output {

	}
}

task RefineStatTask {
	input {
		String workdir
	}
	command <<< 
		set -ex

		cd ~{workdir}/Refine

		ls /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207335A-01_zhiwu_wangxinjing/Refine/*/*.flnc.bam > flnc.fofn
		cat /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207335A-01_zhiwu_wangxinjing/Refine/*/*.flnc.fasta > total.flnc.fasta
		perl /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/fastaDeal.pl -attr id:len total.flnc.fasta > total.flnc.fasta.len
		/export/pipeline/RNASeq/Software/R/R_3.5.1/bin/Rscript /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/Cluster_Bar.R total.flnc.fasta.len total.flnc.fasta.length_distribution
		python /export/pipeline/RNASeq/Pipeline/DAG_workflow/Isoseq3_automation/scripts/refine_stat.py /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207335A-01_zhiwu_wangxinjing/CCS/ROI_reads.summary.xls > refine_stat.xls
		/export/pipeline/RNASeq/Software/Samtools/samtools_v1.9/bin/samtools merge -c -b flnc.fofn merged_flnc.bam

		touch /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207335A-01_zhiwu_wangxinjing/Refine/run_refine_merge_done

	>>>
}