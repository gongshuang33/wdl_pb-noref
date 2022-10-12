version 1.0

import 'tasks/saturation_curve.wdl' as saturation_curve

workflow RunSaturationCurveTask {
	input {
		String workdir 
		String scriptDir 
		String polished_hq_fasta  #cluster.polished_hq_fasta
		String cds_dir		# cds.dir

		#Map[String, String] dockerImages
	}

	call saturation_curve.SaturationCurveTask as SaturationCurve {
		input:
			workdir = workdir,
			scriptDir = scriptDir,
			polished_hq_fasta = polished_hq_fasta,
			CDhit_dir = CDhit_dir,
			
			# image = dockerImages
	}

	output {

	}
}