version 1.0


task CcsTask {
	input {
		String projectdir
		String sampleName
		String filename = 'bc1001.ccs.bam'
		String barcode = 'bc1001'

	}

	String workdir = projectdir + "/CCS/${sampleName}"

	command <<<
		set -vex
		hostname
		date
		cd ~{workdir}
		if [ -f "run_ccs_done" ]; then
            exit 0
        fi

		/export/pipeline/RNASeq/Software/Miniconda/bin/ccs --min-passes 1 --min-rq 0.9 --max-length 50000 --min-length 100 /export/Project/PAG/RNA-seq/pacbio_noref/WHXWZKY-202207335A-01_zhiwu_wangxinjing/Subreads/bc1001.subreads.bam bc1001.ccs.bam -j 20
		python /export/pipeline/RNASeq/Pipeline/noRef_Isoseq/seq_np_rq.py ~{filename}
		Rscript /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/plot_np_rq.r ~{barcode} 
		perl /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/fastaDeal.pl -attr id:len ~{barcode}.ccs.fasta > bc1001.ccs.fasta.len
		/export/pipeline/RNASeq/Software/R/R_3.5.1/bin/Rscript /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/ccs_length_distribution.R bc1001.ccs.fasta.len bc1001
		convert bc1001_np_rq.png ~{barcode}_np_rq.pdf

		touch run_ccs_done
		date	
	>>>

}

task CcsStatTask {
	input {
		String workdir
	}

	command <<< 
		set -vex
		hostname
		date
		cd ~{workdir}/CCS

		python /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/ccs_stat.py > ROI_reads.summary.xls
		cat */*.ccs.fasta > total.ccs.fasta

		touch ~{workdir}/CCS/run_ccs_stat_done
		date
	>>>
}