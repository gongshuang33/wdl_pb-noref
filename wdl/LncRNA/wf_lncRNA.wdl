version 1.0

import "./tasks/lncRNA.wdl" as LncRNA

workflow RunLncRNA {
	input {
		String ScriptDir
		String projectdir
		String novel_cds_removed_fa
		String species_type
		Int split_num = 20
		# Map[String, String] dockerImages
	}

	call LncRNA.SplitTask as split {
		input:
			ScriptDir = ScriptDir,
			projectdir = projectdir,
			novel_cds_removed_fa = novel_cds_removed_fa,
			split_num = split_num,
			# image = dockerImages[""]
	}

	scatter (i in range(split_num)) {
		Int split_i = i + 1
		call LncRNA.CPCTask as cpc {
			input:
				ScriptDir = ScriptDir,
				workdir = split.workdir,
				species_type = species_type,
				novel_cds_removed_fa = novel_cds_removed_fa,
				split_i = split_i,
				# image = dockerImages[""]
		}

		call LncRNA.PfamTask as pfam {
			input:
				ScriptDir = ScriptDir,
				split_i = split_i,
				name = cpc.split_name,
				workdir = split.workdir,
				# image = dockerImages[""]
		}
	}

	call LncRNA.CNCITask as cnci {
		input:
			ScriptDir = ScriptDir,
			workdir = split.workdir,
			novel_cds_removed_fa = novel_cds_removed_fa,
			species_type = species_type,
			# image = dockerImages[""]
	}

	call LncRNA.PlekTask as plek {
		input:
			ScriptDir = ScriptDir,
			workdir = split.workdir,
			novel_cds_removed_fa = novel_cds_removed_fa,
			# image = dockerImages[""]
	}

	call LncRNA.CPCStatTask as cpcstat {
		input:
			workdir = split.workdir,
			ScriptDir = ScriptDir,
			# image = dockerImages[""]
	}

	call LncRNA.PlekStatTask as plekstat {
		input:
			ScriptDir = ScriptDir,
			workdir = split.workdir,
			# image = dockerImages[""]
	}

	call LncRNA.PfamStatTask as pfamstat {
		input:
			ScriptDir = ScriptDir,
			workdir = split.workdir,
			novel_cds_removed_fa = novel_cds_removed_fa,
			# image = dockerImages[""]
	}

	call LncRNA.TotalStatTask as total {
		input:
			ScriptDir = ScriptDir,
			projectdir = projectdir,
			novel_cds_removed_fa = novel_cds_removed_fa,
			novel_cds_removed_fa_len = pfamstat.novel_cds_removed_fa_len,
			pfam_besthit = pfamstat.pfam_besthit,
			cnci_index = cnci.cnci_index,
			cpc_lncRNA = cpcstat.cpc_lncRNA,
			plek_out = plek.plek_out,
			cpc_id = cpcstat.cpc_id,
			plek_id = plekstat.plek_id,
			pfam_id = pfamstat.pfam_id,
			# image = dockerImages[""]
	}

	output {
		File lncrna_venn_png = total.lncrna_venn_png
		File lncrna_venn_pdf = total.lncrna_venn_pdf
		File lncrna_len_png = total.lncrna_len_png
		File lncrna_len_pdf = total.lncrna_len_pdf
		File lncrna_fa = total.lncrna_fa
		File lncrna_stat = total.lncrna_stat
	}
}