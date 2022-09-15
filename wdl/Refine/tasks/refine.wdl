version 1.0

task RefineTask {
	input {
		String workdir
		String sample
		String barcodes = "/export/pipeline/RNASeq/Pipeline/pbbarcoding/scripts/Sequel2_isoseq_barcode.fa"
		String scriptDir

		Int cpu = 8
        String memgb = '16G'
        String image
        String? ROOTDIR = "/export/"
	}

	String refine_dir = workdir + "/Refine/"
	String refine_sample_dir = refine_dir + sample + "/"

	command <<<
		set -ex
		
		mkdir -p ~{refine_sample_dir} && cd ~{refine_sample_dir}

		isoseq3 refine --require-polya ~{sample}.fl.*_5p--*_3p.bam ~{barcodes} ~{sample}.flnc.bam
		samtools view ~{sample}.flnc.bam | awk '{printf ">"$1"\t"$13"\t"$14"\n"$10"\n"}' > ~{sample}.flnc.fasta

		touch run_refine_1_done
	>>>

	output {
		String refine_dir = refine_dir
		String flnc_bam = refine_sample_dir + "${sample}.flnc.bam"
		String flnc_fasta = refine_sample_dir + "${sample}.flnc.fasta"
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
		String roi_reads_summary_xls  # ccstask.roi_reads_summary_xls

		Int cpu = 1
        String memgb = '2G'
        String image
        String? ROOTDIR = "/export/"
	}
	command <<< 
		set -ex

		cd ~{refine_dir}

		ls ~{refine_dir}*/*.flnc.bam > flnc.fofn
		cat ~{refine_dir}*/*.flnc.fasta > total.flnc.fasta
		perl ~{scriptDir}/fastaDeal.pl -attr id:len total.flnc.fasta > total.flnc.fasta.len
		/export/pipeline/RNASeq/Software/R/R_3.5.1/bin/Rscript ~{scriptDir}/Cluster_Bar.R total.flnc.fasta.len total.flnc.fasta.length_distribution
		python /export/pipeline/RNASeq/Pipeline/DAG_workflow/Isoseq3_automation/scripts/refine_stat.py ~{roi_reads_summary_xls} > refine_stat.xls
		samtools merge -c -b flnc.fofn merged_flnc.bam

		touch run_refine_merge_done
	>>>
	output {
		
	}

	runtime {
        #docker: image
        cpu: cpu
        memory: memgb
        root: ROOTDIR
    }
}