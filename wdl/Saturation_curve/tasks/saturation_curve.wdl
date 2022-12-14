version 1.0

task SaturationCurveTask {
	input {
		String workdir
		String scriptDir
		String polished_hq_fasta
		String cds_dir

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String saturation_curve_dir = workdir + "/Saturation_curve"
	command <<<
		set -ex
		mkdir -p ~{saturation_curve_dir} && cd ~{saturation_curve_dir}
		if [ -f 'saturation_curve_done' ];then
			exit 0
		fi
		echo "
		set -vex
		hostname
		date
		cd ~{saturation_curve_dir}
		~{scriptDir}/Saturation_curve_Nonref.sh ~{polished_hq_fasta} ~{cds_dir}/new_clstr.stat.xls ~{cds_dir}/new_cdhit1.fasta.clstr Saturation_Curve
		touch saturation_curve_done
		date
		" > run_SaturationCurve.sh
		bash run_SaturationCurve.sh > run_SaturationCurve_STDOUT 2> run_SaturationCurve_STDERR
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