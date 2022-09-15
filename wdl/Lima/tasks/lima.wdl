version 1.0

task LimaTask {
	input {
		String workdir
		String sample
		String barcodes = "/export/pipeline/RNASeq/Pipeline/pbbarcoding/scripts/Sequel2_isoseq_barcode.fa"
	}
	command <<<
		set -ex

		mkdir -p ~{workdir}/Lima/~{sample} && cd ~{workdir}/Lima/~{sample}
		lima ~{workdir}/CCS/~{sample}/~{sample}.ccs.bam ~{barcodes} ~{sample}.fl.bam --isoseq --peek-guess -j 2
		touch run_lima_1_done
	>>>
	output {
		String lima_path = "${workdir}/Lima/"
	}
}

task LimaStatTask {
	input {
		String lima_path
	}
	command <<<
		set -ex
		cd ~{lima_path}
		python /export/pipeline/RNASeq/Pipeline/Ref_Isoseq/automation/scripts/lima_stat.py lima_stat.xls
		touch run_lima_stat_done
	>>>
}