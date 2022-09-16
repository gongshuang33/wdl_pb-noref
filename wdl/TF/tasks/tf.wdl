version 1.0

task TFTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta  #Unigene/Unigene.fasta路径 来自cdhit
		String species_type	#plant or animal
		String cds_dir

		Int cpu = 8
		String memgb = '16G'
		String image
		String? ROOTDIR = "/export/"
	}

	String tf_dir = workdir + '/TF'

	command <<<
		set -ex
		mkdir -p ~{tf_dir} && cd ~{tf_dir}
		ln -s ~{unigene_fasta} Unigene.fasta

		if [ ~{species_type} == "plant" ]; then
			export PERL5LIB=/export/software/Base/perl/Perl/perl-5.26.1/lib/site_perl/5.26.1/:/export/software/Base/perl/Perl/perl-5.26.1/lib/5.26.1:$PATH
			/export/software/Base/perl/Perl/perl-5.26.1/bin/perl /export/pipeline/RNASeq/Software/iTAK/iTAK-1.7/iTAK.pl Unigene.fasta
			awk '{print $1"\t"$2}' Unigene.fasta_output/tf_classification.txt | awk 'BEGIN{print "unigene_id TF_family"}{gsub("-[0-2][F,R]","",$1);print $1"\t"$2}'| sort -ur > transcription_factor.xls
			touch TF_plant_done
		fi

		if [ ~{species_type} == "animal" ]; then
			ln -s ~{cds_dir}/Final.predict.ANGEL.pep isoform.pep
			python ~{scriptDir}/choose_unigene.py Unigene.fasta isoform.pep
			export PATH=/export/personal/pengh/Software/hmmer-3.1b2-linux-intel-x86_64/bin/:$PATH
			python ~{scriptDir}/AnimalTF_noref_V2.py --pep unigene.pep --out ./
			touch TF_animal_done
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