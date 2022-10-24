version 1.0

task write_diff_script {
	input {
		String? diff_dir
		String? sample_group
		String? compare_txt
		String? gene_count
		String? gene_fpkm
		# String gene_tpm
		String scriptDir

		Int cpu = 1
		String memgb = '2G'
		# String image

		String? ROOTDIR = "/export/"
	}

	String script_rep = scriptDir + "/DESeq2_V5.pl"
	String script_single = scriptDir + "/edgeR_v5.pl"

	command <<<
		python <<EOF
		from collections import defaultdict

		out = open("~{diff_dir}/diff.sh", 'w')
		groups = defaultdict(list)

		for line in open("~{sample_group}"):
			if line.startswith('#') or line.strip() == '':
				continue
			sample, group = line.strip().split('\t')[:2]
			groups[group].append(sample)

		for line in open("~{compare_txt}"):
			if line.startswith('#') or line.strip() == '':
				continue
			control, treat = line.strip().split('\t')
			comp_string = "{}_vs_{}".format(control, treat)

			if len(groups[control]) > 1 and len(groups[treat]) > 1:
				cmd = "mkdir -p {0}\nperl {1} -p 0.05 -ty padj -f 2 -i {2} -fpkm {3} -n1 {4} -n2 {5} -a {6} -b {7} -op {8}/{0} >{0}/stdout 2>{0}/stderr\n".format(
					comp_string, "~{script_rep}",
					"~{gene_count}", "~{gene_fpkm}",
					control, treat,
					':'.join(groups[control]), ':'.join(groups[treat]),
					"~{diff_dir}"
				)
			else:
				cmd = "mkdir -p {0}\nperl {1} -p 0.005 -ty padj -f 2 -i {2} -fpkm {3} -n1 {4} -n2 {5} -a {6} -b {7} -op {8}/{0} >{0}/stdout 2>{0}/stderr\n".format(
					comp_string, "~{script_single}",
					"~{gene_count}", "~{gene_fpkm}",
					control, treat,
					':'.join(groups[control]), ':'.join(groups[treat]),
					"~{diff_dir}"
				)
			out.write(cmd)
		out.close()
		EOF
	>>>

	output {
		String diff_script = diff_dir + "/diff.sh"
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}

task DGETask {
	input {
		String? diff_dir
		String diff_script
		String scriptDir
		Int cpu = 1
		String memgb = '2G'
		# String image

		String? ROOTDIR = "/export/"	   
	}

	command {
		set -ex

		mkdir -p ${diff_dir} && cd ${diff_dir}

		if [ -f "diff.done" ]; then
			exit 0
		fi

		bash ${diff_script}

		python3 ${scriptDir + "/DEG_stat.py"} ${diff_dir} > DEG_stat.xls

		touch diff.done 
	}

	output {
		String diff_dir_done = diff_dir
	}

	runtime {
		# docker: image
		cpu: cpu
		memory: memgb
		root: ROOTDIR
	}
}
