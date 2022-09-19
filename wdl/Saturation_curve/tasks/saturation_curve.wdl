version 1.0

task SaturationCurveTask {
	input {
		String workdir
		String scriptDir
		String NGS_corrected_fasta # /NGS_corrected/NGS_corrected.fasta
		String new_clstr_stat_xls  # /CDhit/new_clstr.stat.xls
		String new_cdhit1_fasta_clstr # /CDhit/new_cdhit1.fasta.clstr
	}

	String saturation_curve_dir = workdir + "/Saturation_curve"
	command <<<
		set -ex
		mkdir -p ~{saturation_curve_dir} && cd ~{saturation_curve_dir} 

		~{scriptDir}/Saturation_curve_Nonref.sh \
		~{NGS_corrected_fasta} \
		~{new_clstr_stat_xls} \
		~{new_cdhit1_fasta_clstr} Saturation_Curve

		touch saturation_curve_done
	>>>

	output {

	}
}