version 1.0

task LncRNATask {
	input {
		String workdir
		String scriptDir
		String species_type
		String cds_removed_isoform_fasta #/CDS/cds_removed_isoform.fasta

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"

	}

	String lncRNA_dir = workdir + '/LncRNA'

	command <<<
		set -ex
		mkdir -p ~{lncRNA_dir} && cd ~{lncRNA_dir}
		if [ -f 'run_lncrna_done' ];then
			exit 0
		fi
		# animal or plant
		if [[ ~{species_type} == "animal" || ~{species_type} == "plant" ]];then
			python3 ~{scriptDir}/run_lncrna_animal_plant.py --seq  ~{cds_removed_isoform_fasta} --work_dir ~{lncRNA_dir} --species_type ~{species_type}
			touch run_lncrna_done
		fi

		# fungi
		if [[ ~{species_type} =="fungi" ]];then
			python3 ~{scriptDir}/run_lncrna_fungi.py --seq  ~{cds_removed_isoform_fasta} --work_dir ~{lncRNA_dir} --species_type ~{species_type}
			touch run_lncrna_done
		fi

		
	>>>

	output {
		String dir = lncRNA_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task LncRNAStatTask {
	input {
		String workdir
		String scriptDir
		String species_type
		String cds_removed_isoform_fasta #/CDS/cds_removed_isoform.fasta
		String lncRNA_dir
		String cds_removed_isoform_fasta
		String cds_dir

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		date
		cd ~{lncRNA_dir}
		if [ -f 'total_stat_work_done' ];then
			exit 0
		fi

		export R_LIBS_USER=/export/pipeline/RNASeq/Software/R_library

		perl ~{scriptDir}/fastaDeal.pl -attr id:len ~{cds_removed_isoform_fasta} > ~{cds_dir}/cds_removed_isoform.fasta.len
		python ~{scriptDir}/lnc_stat_V2.py -len ~{cds_dir}/cds_removed_isoform.fasta.len -plek ~{lncRNA_dir}/work/shell/PLEK/cds_removed_plek.out -cpc ~{lncRNA_dir}/work/shell/CPC/cpc_lncRNA.txt -cnci ~{lncRNA_dir}/work/shell/CNCI/CNCI_out/CNCI.index -pfam ~{lncRNA_dir}/work/shell/Pfam/pfam.besthit -o1 lnc_stat.xls -o2 lncRNA.id.txt
		ln -s ~{lncRNA_dir}/work/shell/CPC/cpc.id.txt .
		ln -s ~{lncRNA_dir}/work/shell/PLEK/plek.id.txt .
		ln -s ~{lncRNA_dir}/work/shell/Pfam/pfam.id.txt .
		ln -s ~{lncRNA_dir}/work/shell/CNCI/cnci.id.txt .
		Rscript ~{scriptDir}/lnc_Venn_4.R ~{lncRNA_dir}/work/shell/CNCI/cnci.id.txt ~{lncRNA_dir}/work/shell/CPC/cpc.id.txt ~{lncRNA_dir}/work/shell/PLEK/plek.id.txt ~{lncRNA_dir}/work/shell/Pfam/pfam.id.txt
		python ~{scriptDir}/getname_from_lnc_stat.py lncRNA.id.txt ~{cds_removed_isoform_fasta} > LncRNA.fasta
		perl ~{scriptDir}/fastaDeal.pl -attr id:len LncRNA.fasta > LncRNA.fasta.len
		Rscript ~{scriptDir}/Cluster_Bar.R LncRNA.fasta.len LncRNA.length_distribution
		touch total_stat_work_done
		date
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