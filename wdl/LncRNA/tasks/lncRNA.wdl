version 1.0

task SplitTask {
	input {
		String ScriptDir
		String projectdir
		String novel_cds_removed_fa
		Int split_num = 20

		Int cpu = 1
		String memgb = "2G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String lncdir = projectdir + "/LncRNA/work" 

	command <<<
		set -vex
		hostname
		date

		mkdir -p ~{lncdir} && cd ~{lncdir}
		if [ -f "run_split_done" ]; then
			exit 0
		fi

		python ~{ScriptDir}/seq_split.py -seq ~{novel_cds_removed_fa} -num ~{split_num}

		touch run_split_done
		date 
	>>>

	output {
		String workdir = lncdir
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}   

task CPCTask {
	input { 
		String ScriptDir
		String workdir
		String species_type
		String novel_cds_removed_fa
		Int split_i

		Int cpu = 10
		String memgb = "20G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String name = basename(novel_cds_removed_fa)
	String split_dir = workdir + "/" + name + "." + split_i
	String split_fa = split_dir + "/" + name + "." + split_i

	command <<<
		set -vex
		hostname
		date

		cd ~{split_dir}
		if [ -f "run_cpc_work_done" ]; then
			exit 0
		fi

		export PATH=/home/tiany/software/align/NCBIblast/latest/bin/:$PATH

		if [ ~{species_type} = "plant" ]; then
			sh ~{ScriptDir}/run_plant_predict_local.sh ~{split_fa} cpc_lncRNA.txt ./ result_evidence
			python ~{ScriptDir}/get_LncRNA_from_cpc.py cpc_lncRNA.txt > cpc.id.txt 
			touch run_cpc_work_done
		fi

		if [ ~{species_type} = "animal" ]; then
			sh ~{ScriptDir}/run_animal_predict_local.sh ~{split_fa} cpc_lncRNA.txt ./ result_evidence
			python ~{ScriptDir}/get_LncRNA_from_cpc.py cpc_lncRNA.txt > cpc.id.txt 
			touch run_cpc_work_done
		fi

		if [ ~{species_type} = "fungi" ]; then
			sh ~{ScriptDir}/run_fungi_predict_local.sh ~{split_fa} cpc_lncRNA.txt ./ result_evidence
			python ~{ScriptDir}/get_LncRNA_from_cpc.py cpc_lncRNA.txt > cpc.id.txt 
			touch run_cpc_work_done
		fi

		date
	>>>

	output {
		String split_name = name
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task CPCStatTask {
	input {
		String workdir
		String ScriptDir

		Int cpu = 1
		String memgb = "2G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String cpcdir = workdir + "/CPC"

	command <<<
		set -vex 
		hostname
		date

		mkdir -p ~{cpcdir} && cd ~{cpcdir}
		if [ -f "run_cpc_stat_work_done" ]; then
			exit 0
		fi

		cat ~{workdir}/*/cpc.id.txt > cpc.id.txt
		cat ~{workdir}/*/cpc_lncRNA.txt > cpc_lncRNA.txt

		touch run_cpc_stat_work_done
		date
	>>>

	output {
		File cpc_lncRNA = cpcdir + "/cpc_lncRNA.txt"
		File cpc_id = cpcdir + "/cpc.id.txt"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task CNCITask {
	input {
		String ScriptDir
		String workdir
		String novel_cds_removed_fa

		Int cpu = 10
		String memgb = "20G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String cncidir = workdir + "/CNCI"

	command <<<
		set -vex
		hostname
		date

		mkdir -p ~{cncidir} && cd ~{cncidir}
		if [ -f "run_cnci_work_done" ]; then
			exit 0
		fi

		python ~{ScriptDir}/CNCI.py -f ~{novel_cds_removed_fa} -o CNCI_out -m ve -p ~{cpu}
		python ~{ScriptDir}/get_LncRNA_from_cnci.py ~{cncidir}/CNCI_out/CNCI.index cnci.id.txt

		touch run_cnci_work_done
		date
	>>>

	output {
		File cnci_index = cncidir + "/CNCI_out/CNCI.index"
		File cnci_id = cncidir + "/cnci.id.txt"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task PlekTask {
	input {
		String ScriptDir
		String workdir
		String novel_cds_removed_fa

		Int cpu = 10
		String memgb = "20G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String plekdir = workdir + "/PLEK"

	command <<<
		set -vex
		hostname
		date

		mkdir -p ~{plekdir} && cd ~{plekdir}
		if [ -f "run_plek_work_done" ]; then
			exit 0
		fi

		export PATH=$PATH:/export/personal/pengh/Software/iso_lncRNA_pipeline/PLEK.1.2/
		export PATH=$PATH:/export/personal/pengh/Software/iso_lncRNA_pipeline/arrigonialberto-lncrnas-pipeline-984a37019773/

		ln -s ~{novel_cds_removed_fa} cds_removed.fasta
		ncrna_pipeline -f cds_removed.fasta -p ~{cpu} -c plek

		touch run_plek_work_done
		date
	>>>

	output {
		File plek_out = plekdir + "/cds_removed_plek.out"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task PlekStatTask {
	input {
		String ScriptDir
		String workdir

		Int cpu = 1
		String memgb = "2G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String plekdir = workdir + "/PLEK"

	command <<<
		set -vex
		hostname
		date

		cd ~{plekdir}
		if [ -f "run_plek_stat_work_done" ]; then
			exit 0
		fi

		perl ~{ScriptDir}/fastaDeal.pl -attr id:len ~{plekdir}/cds_removed_ncrna.fa > plek_lncRNA.fasta.len
		sh ~{ScriptDir}/get_plek_id.sh

		touch run_plek_stat_work_done
	>>>

	output {
		File plek_id = plekdir + "plek.id.txt"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task PfamTask {
	input {
		String ScriptDir
		String split_i
		String workdir
		String name

		Int cpu = 10
		String memgb = "20G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String split_dir = workdir + "/" + name + "." + split_i
	String split_fa = split_dir + "/" + name + "." + split_i

	command <<<
		set -vex
		hostname
		date

		cd ~{split_dir}
		if [ -f "run_pfam_work_done" ]; then
			exit 0
		fi

		export PERL5LIB=$PERL5LIB:/export/pipeline/RNASeq/Software/Pfam/PfamScan

		perl ~{ScriptDir}/cds2aa.pl ~{split_fa} > pfam.fa
		perl ~{ScriptDir}/pfam_scan.pl -fasta pfam.fa -dir /export/pipeline/RNASeq/Software/Pfam -out pfam.m8 -cpu ~{cpu}
		python ~{ScriptDir}/lncrna_m8tobesthit.py --m8file pfam.m8 --besthit pfam.besthit

		touch run_pfam_work_done
		date
	>>>

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task PfamStatTask {
	input {
		String ScriptDir
		String workdir
		String novel_cds_removed_fa

		Int cpu = 1
		String memgb = "2G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String pfamdir = workdir + "/Pfam"

	command <<<
		set -vex
		hostname
		date

		mkdir -p ~{pfamdir} && cd ~{pfamdir}
		if [ -f "run_pfam_stat_work_done" ]; then
			exit 0
		fi

		cat ~{workdir}/*/pfam.besthit > pfam.besthit
		perl ~{ScriptDir}fastaDeal.pl -attr id:len ~{novel_cds_removed_fa} > ~{novel_cds_removed_fa}.len
		python ~{ScriptDir}/get_id_from_pfam.py pfam.besthit ~{novel_cds_removed_fa}.len > pfam.id.txt

		touch run_pfam_stat_work_done
		date
	>>>

	output {
		File pfam_id = pfamdir + "/pfam.id.txt"
		File pfam_besthit = pfamdir + "/pfam.besthit"
		File novel_cds_removed_fa_len = novel_cds_removed_fa + ".len"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task TotalStatTask {
	input {
		String ScriptDir
		String projectdir
		String novel_cds_removed_fa
		String novel_cds_removed_fa_len
		String pfam_besthit
		String cnci_index
		String cpc_lncRNA
		String plek_out
		String cpc_id
		String plek_id
		String pfam_id
		String cnci_id

		Int cpu = 1
		String memgb = "2G"
		# String image
		String? ROOTDIR = "/export/"
	}

	String workdir = projectdir + "/LncRNA"

	command <<<
		set -vex
		hostname
		date

		cd ~{workdir}
		if [ -f "run_total_stat_work_done" ]; then
			exit 0
		fi

		export R_LIBS_USER=/export/pipeline/RNASeq/Software/R_library

		python ~{ScriptDir}/lnc_stat_V2.py -len ~{novel_cds_removed_fa_len} -plek ~{plek_out} -cpc ~{cpc_lncRNA} -cnci ~{cnci_index} -pfam ~{pfam_besthit} -o1 lnc_stat.xls -o2 lncRNA.id.txt
		
		ln -s ~{cpc_id} .
		ln -s ~{plek_id} .
		ln -s ~{pfam_id} .
		ln -s ~{cnci_id} .

		Rscript ~{ScriptDir}/lnc_Venn_4.R ~{cnci_id} ~{cpc_id} ~{plek_id} ~{pfam_id}
		python ~{ScriptDir}/getname_from_lnc_stat.py lncRNA.id.txt ~{novel_cds_removed_fa} > LncRNA.fasta

		perl ~{ScriptDir}/fastaDeal.pl -attr id:len LncRNA.fasta > LncRNA.fasta.len
		Rscript ~{ScriptDir}/Cluster_Bar.R LncRNA.fasta.len LncRNA.length_distribution

		touch run_total_stat_work_done
		date
		
	>>>

	output {
		File lncrna_venn_png = workdir + "/LncRNA_venn.png"
		File lncrna_venn_pdf = workdir + "/LncRNA_venn.pdf"
		File lncrna_len_png = workdir + "/LncRNA.length_distribution.png"
		File lncrna_len_pdf = workdir + "/LncRNA.length_distribution.pdf"
		File lncrna_fa = workdir + "/LncRNA.fasta"
		File lncrna_stat = workdir + "/lnc_stat.xls"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}



