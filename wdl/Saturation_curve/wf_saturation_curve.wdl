version 1.0

import 'tasks/saturation_curve.wdl' as saturation_curve

workflow RunSaturationCurve {
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
			cds_dir = cds_dir,
			
			# image = dockerImages
	}

	output {

	}
}