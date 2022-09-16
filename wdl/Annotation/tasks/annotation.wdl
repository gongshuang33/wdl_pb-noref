version 1.0

task AnnotationPreTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta
		String species_type

		Int cpu = 8
		String memgb = '16G'
		String image
		String? ROOTDIR = "/export/"
	}

	String annotation_dir = workdir + '/Annotation'

	command <<<
		mkdir ~{annotation_dir} && cd ~{annotation_dir}
		ln -s ~{unigene_fasta} unigene.fa
		python ~{scriptDir}/Run_Annotation_with_diamond.py ~{species_type} -k -g -i -n -s -cog -c 20 --do -f unigene.fa
	>>>

	output {

	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}

task AnnotationTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta
		String species_type
		String annotation_dir

		Int cpu = 8
		String memgb = '16G'
		String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		set -ex
		cd ~{annotation_dir}
		### KEGG
		cat unigene.fa.function.work/*/*kegg.m8 > unigene.fa.function.result/Unigene.kegg.m8
		python ~{scriptDir}/m8tobesthit.py --m8file unigene.fa.function.result/Unigene.kegg.m8 --besthit Unigene.kegg.m8.besthit
		sh ~{scriptDir}/Annot_KEGG.sh Unigene Unigene.kegg.m8.besthit ~{species_type}

		### GO
		cat unigene.fa.function.work/*/*iprOut > unigene.fa.function.result/Unigene.iprOut
		python ~{scriptDir}/deal_ipr2go_V2.py --gene --goAnnot Unigene.go.annot --iprFile unigene.fa.function.result/Unigene.iprOut
		python ~{scriptDir}/Annot_GO.py -a Unigene.go.annot -p Unigene
		python ~{scriptDir}/new.get_GO.classify.py Unigene.go.wego.txt /export/pipeline/RNASeq/Database/GO/WEGO/GO_level4.deal.txt > Unigene.go.classify.xls
		Rscript ~{scriptDir}/get.level2_3.counts.R Unigene.go.classify.xls Unigene.go.level2.xls Unigene.go.level3.xls

		### NR
		cat unigene.fa.function.work/*/*nr.m8 > unigene.fa.function.result/Unigene.nr.m8
		python ~{scriptDir}/m8tobesthit.py --m8file unigene.fa.function.result/Unigene.nr.m8 --besthit Unigene.nr.m8.besthit
		cut -f 1-4,7-13 Unigene.nr.m8.besthit | sed '1iGene_ID	NR_ID	Identity	Align Length	Q start	Q end	T start	T end	E value	Score	Function' > Unigene.nr.annotation.xls

		##SwissProt
		cat unigene.fa.function.work/*/*swissprot.m8 > unigene.fa.function.result/Unigene.swissprot.m8
		python ~{scriptDir}/m8tobesthit.py --m8file unigene.fa.function.result/Unigene.swissprot.m8 --besthit Unigene.swissprot.m8.besthit
		python ~{scriptDir}/Annot_SwissProt.py -b Unigene.swissprot.m8.besthit -o Unigene.swissprot.annotation.xls

		##KOG
		cat unigene.fa.function.work/*/*kog.m8 > unigene.fa.function.result/Unigene.kog.m8
		python ~{scriptDir}/m8tobesthit.py --m8file unigene.fa.function.result/Unigene.kog.m8 --besthit Unigene.kog.m8.besthit
		python ~{scriptDir}/Annot_COG.py -i Unigene.kog.m8.besthit -o Unigene.kog.annotation.xls -s Unigene -c Unigene.kog.classification.xls
	>>>

	output {

	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}

task AnnotationSumTask {
	input {
		String workdir
		String scriptDir
		String unigene_fasta
		String species_type
		String annotation_dir

		Int cpu = 8
		String memgb = '16G'
		String image
		String? ROOTDIR = "/export/"
	}

	command <<<
		cd ~{annotation_dir}

		python ~{scriptDir}/annotation_stat.py ../Unigene/Unigene.fasta
		python ~{scriptDir}/get_gene_length.py ../Unigene/Unigene.fasta Unigene_length.txt
		python ~{scriptDir}/Sum_Annot.py --input Unigene_length.txt --kog Unigene.kog.annotation.xls --go Unigene.go.annotation.xls --kegg Unigene.kegg.annotation.xls --nr Unigene.nr.annotation.xls --swissprot Unigene.swissprot.annotation.xls --output Annotation_Summary.xls

		#VENN
		Rscript ~{scriptDir}/plot_Venn_V2.R Unigene
		#NR
		python ~{scriptDir}/sum_species.py Unigene.nr.annotation.xls species_classification.xls > species_unknown.list
		awk -F '\t' 'NR<7{{print $0}}NR>6{{sum+=$2}}END{{print "others\t"sum}}' species_classification.xls > species.pie.txt
		Rscript ~{scriptDir}/plot_Species_V2.R
		#KEGG
		Rscript ~{scriptDir}/plot_KEGG.classification.R Unigene.No_HumanDisease.kegg_class.xls KEGG_classification
		#KOG
		Rscript ~{scriptDir}/plot_KOG.classification.R Unigene.kog.classification.xls KOG_classification
		#GO
		Rscript ~{scriptDir}/plot_GO.classification.R Unigene.go.level2.xls GO_classification
	>>>

	output {

	}

	runtime {
		#docker: image
		cpu: cpu
		memgb: memgb
		root: ROOTDIR
	}
}