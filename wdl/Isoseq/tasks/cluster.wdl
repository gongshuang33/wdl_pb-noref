version 1.0

task ClusterTask {
	input {
		String workdir
		String merged_flnc_bam
		Int cpu = 8
		String memgb = '16G'
		#String image
		String? ROOTDIR = "/export/"
	}

	String cluster_dir = workdir + "/Cluster"

	command <<<
		set -ex

		mkdir -p ~{cluster_dir} && cd ~{cluster_dir}

		isoseq3 cluster ~{merged_flnc_bam} polished.bam --verbose --use-qvs -j ~{cpu} --singletons

		touch run_cluster_done
	>>>

	output {
		File polished_bam = cluster_dir + "/polished.bam"
		String dir = cluster_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}



task ClusterStatTask {
	input {
		String cluster_dir
		String scriptDir
		String ccs_dir
		String refine_dir

		Int cpu = 1
		String memgb = '2G'
		# String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -vex

		cd ~{cluster_dir}

		gunzip polished.hq.fasta.gz
		gunzip polished.lq.fasta.gz
		gunzip polished.singletons.fasta.gz
		perl ~{scriptDir}/fastaDeal.pl -attr id:len polished.hq.fasta > polished.hq.fasta.len
		perl ~{scriptDir}/fastaDeal.pl -attr id:len polished.lq.fasta > polished.lq.fasta.len
		python ~{scriptDir}/filter_singletons.py ~{ccs_dir}/total.ccs.fasta polished.singletons.fasta > filtered.singletons.fasta
		cat polished.hq.fasta filtered.singletons.fasta > all.polished.fa
		perl ~{scriptDir}/fastaDeal.pl -attr id:len polished.singletons.fasta > polished.singletons.fasta.len
		perl ~{scriptDir}/fastaDeal.pl -attr id:len filtered.singletons.fasta > filtered.singletons.fasta.len
		perl ~{scriptDir}/fastaDeal.pl -attr id:len all.polished.fa > all.polished.fa.len
		Rscript ~{scriptDir}/Cluster_Bar.R all.polished.fa.len all.polished.fa.length_distribution
		python ~{scriptDir}/isoseq_stat.py -hq polished.hq.fasta.len -lq polished.lq.fasta.len -s polished.singletons.fasta.len -fs filtered.singletons.fasta.len \
		-refine ~{refine_dir}/refine_stat.xls -o isoseq_stat.xls

		touch run_cluster_stat_done
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