version 1.0

task LncRNATask {
	input {
		String workdir
		String species_type
		String scriptDir
		String cds_removed_isoform_fasta #/CDS/cds_removed_isoform.fasta

		Int cpu = 8
		String memgb = '16G'
		String image
		String? ROOTDIR = "/export/"

	}

	String lncRNA_dir = workdir + '/LncRNA'

	command <<<
		set -ex
		mkdir -p ~{lncRNA_dir} && cd ~{lncRNA_dir}

		/export/software/Base/python/Python/Python-3.6.3/bin/python3 ~{scriptDir}/run_lncrna_animal_plant.py \
		--seq ~{cds_removed_isoform_fasta} \
		--work_dir ~{lncRNA_dir} \
		--species_type ~{species_type}
		touch run_lncrna_done
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