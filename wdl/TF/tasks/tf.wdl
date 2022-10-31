version 1.0

task TFTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta  	#Unigene/Unigene.fasta路径 来自cdhit
		String species_type		#plant or animal 
		String cds_dir

		Int cpu = 8
		String memgb = '16G'
		# String image
		String? ROOTDIR = "/export/"
	}

	String tf_dir = workdir + '/TF'

	command <<<
		set -ex
		mkdir -p ~{tf_dir} && cd ~{tf_dir}
		if [[ -f 'TF_plant_done' || -f 'TF_animal_done' ]];then
			exit 0
		fi
		if [[ ~{species_type} == "plant" ]]; then
			echo "
			set -vex
			hostname
			date
			cd ~{tf_dir}
			if [ ! -f 'Unigene.fasta' ];then
				ln -s ~{unigene_fasta} Unigene.fasta
			fi
			export PERL5LIB=/export/software/Base/perl/Perl/perl-5.26.1/lib/site_perl/5.26.1/:/export/software/Base/perl/Perl/perl-5.26.1/lib/5.26.1:$PATH
			perl /export/pipeline/RNASeq/Software/iTAK/iTAK-1.7/iTAK.pl Unigene.fasta
			awk '{print $1\"\t\"$2}' Unigene.fasta_output/tf_classification.txt | awk 'BEGIN{print \"unigene_id TF_family\"}{gsub(\"-[0-2][F,R]\",\"\",$1);print $1\"\t\"$2}'| sort -ur > transcription_factor.xls
			touch TF_plant_done
			date
			" > run_tf_plant.sh 
			bash run_tf_plant.sh > run_tf_plant_STDOUT 2> run_tf_plant_STDERR
		fi

		if [[ ~{species_type} == "animal" ]]; then
			echo "
			set -vex
			hostname
			date
			cd ~{tf_dir}
			if [ ! -f 'Unigene.fasta' ];then
				ln -s ~{unigene_fasta} Unigene.fasta
			fi
			if [ ! -f 'isoform.pep' ];then
				ln -s ~{cds_dir}/Final.predict.ANGEL.pep isoform.pep
			fi
			python ~{scriptDir}/choose_unigene.py Unigene.fasta isoform.pep
			export PATH=/export/personal/pengh/Software/hmmer-3.1b2-linux-intel-x86_64/bin/:$PATH
			python ~{scriptDir}/AnimalTF_noref_V2.py --pep unigene.pep --out ./
			touch TF_animal_done
			date
			" > run_tf_animal.sh 
			bash run_tf_animal.sh > run_tf_animal_STDOUT 2> run_tf_animal_STDERR
		fi
	>>>

	output {
		String dir = tf_dir
	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}