version 1.0

task CDhitTask {
	input {
		String workdir
		String scriptDir
		String? NGS_corrected_fasta #二代
		String all_polished_fa  # cluster.

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String cdhit_dir = workdir + "/CDhit"
	String clean_fasta = select_first([NGS_corrected_fasta, all_polished_fa])

	command <<<
		set -ex
		mkdir -p ~{cdhit_dir} && cd ~{cdhit_dir}
		if [ -f "run_cdhit_done" ];then
			exit 0
		fi
		python ~{scriptDir}/sort_fa.py ~{clean_fasta} > sort.fasta
		/export/personal/pengh/Software/cdhit/cd-hit-est -i sort.fasta -o cdhit1.fasta -c 0.99 -T 10 -G 0 -aL 0.90 -AL 100 -aS 0.99 -AS 30 -M 80000
		/export/personal/pengh/Software/cdhit/cd-hit-est -i cdhit1.fasta -o cdhit2.fasta -T 10 -M 100000 -c 0.85
		python ~{scriptDir}/rename.stat.py cdhit1.fasta cdhit2.fasta cdhit2.fasta.clstr clstr.stat.xls cd-hit.Unigene.fasta cd-hit.isoforms.fasta > togene
		python ~{scriptDir}/rename_id.py id.change.info cdhit1.fasta.clstr new_cdhit1.fasta.clstr cdhit2.fasta.clstr new_cdhit2.fasta.clstr clstr.stat.xls new_clstr.stat.xls
		perl ~{scriptDir}/isoform_stat_length.pl  cd-hit.isoforms.fasta > non-redundant_isoforms_length_distribution.xls
		python ~{scriptDir}/seq_length_stat.py --fasta cd-hit.isoforms.fasta > cd-hit.isoforms.fasta.len.stat
		perl ~{scriptDir}/isoform_stat_length.pl cd-hit.Unigene.fasta > gene_level_cluster_length_distribution.xls
		python ~{scriptDir}/seq_length_stat.py --fasta cd-hit.Unigene.fasta > cd-hit.Unigene.fasta.len.stat
		perl ~{scriptDir}/fastaDeal.pl -attr id:len cd-hit.Unigene.fasta > cd-hit.Unigene.fasta.len
		perl ~{scriptDir}/fastaDeal.pl -attr id:len cd-hit.isoforms.fasta > cd-hit.isoforms.fasta.len
		Rscript ~{scriptDir}/Cluster_Bar.R cd-hit.Unigene.fasta.len cd-hit.Unigene.length_distribution
		Rscript ~{scriptDir}/Cluster_Bar.R cd-hit.isoforms.fasta.len cd-hit.isoforms.length_distribution

		mkdir -p ~{workdir}/Unigene 
		ln -s ~{cdhit_dir}/cd-hit.Unigene.fasta ~{workdir}/Unigene/Unigene.fasta
		ln -s ~{cdhit_dir}/cd-hit.isoforms.fasta ~{workdir}/Unigene/isoform.fasta
		touch ~{cdhit_dir}/run_cdhit_done
	>>>

	output {
		String dir = cdhit_dir
		String unigene_fasta = workdir + "/Unigene/Unigene.fasta"
		String isoform_fasta = workdir + "/Unigene/isoform.fasta"
		String cdhit_new_clstr_stat_xls = cdhit_dir + "/new_clstr.stat.xls"
		String cdhit_isoform_fa =  cdhit_dir + "/cd-hit.isoforms.fasta"
		String cdhit_togene = cdhit_dir + "/togene"
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}

