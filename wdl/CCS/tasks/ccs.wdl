version 1.0


task GetSubreadsTask {
	
}

task StatSubreadsTask {

}


task CcsTask {
	input {
		String projectdir
		String sampleName
	}

	String workdir = "${projectdir}/CCS/${sampleName}"
	String subreadspath = "${projectdir}/Subreads"

	command <<<
		set -vex
		hostname
		date
		cd ~{workdir}
		if [ -f "run_ccs_done" ]; then
            exit 0
        fi

		/export/pipeline/RNASeq/Software/Miniconda/bin/ccs \
		--min-passes 1 --min-rq 0.9 --max-length 50000 --min-length 100 \
		~{projectdir + "Subreads/"}~{sampleName + ".subreads.bam"}  ~{sampleName + ".ccs.bam"} -j 20

		python /export/pipeline/RNASeq/Pipeline/noRef_Isoseq/seq_np_rq.py ~{sampleName + ".ccs.bam"}

		Rscript /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/plot_np_rq.r  ~{sampleName} 

		perl /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/fastaDeal.pl -attr id:len ~{sampleName + ".ccs.fasta"} > ~{sampleName + ".ccs.fasta.len"}

		/export/pipeline/RNASeq/Software/R/R_3.5.1/bin/Rscript /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/ccs_length_distribution.R ~{sampleName + ".ccs.fasta.len"} ~{sampleName}
		
		convert ~{sampleName + "_np_rq.png"} ~{sampleName + "_np_rq.pdf"}

		touch ~{workdir + "/run_ccs_done"}
		date	
	>>>
	output {
		String wkdir = ${projectdir + "/CCS"}
	}

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