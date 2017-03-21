#nohup swift loss_all.swift -ref=hg38.fasta -gtf=genes.gff -op=2 -p=26 &

#op1 - "40.0", "30.0", "500"
#op4 - "20.0", "5", "80"

import "apps_optimized";
import "provenance_apps";

type file;

type input {
        file libF;
        file libR;
}

#Parâmetros Gerais
int op = toInt(arg("op","1"));
int t = toInt(arg("p","10"));
string b30op = arg("b30","n");
string ploidy = arg("ploidy", "2");
string spec = arg("s", "human");

file ref <single_file_mapper;file=arg("ref")>;
input seqInput[] <csv_mapper;file="input.csv">;
file gtf <single_file_mapper;file=arg("gtf")>;

#Parâmetros GATK
string MQ = arg("mq","40.0");
string DP = arg("dp","30.0");
string QUAL = arg("qual","500");

#Parâmetros SAMTOOLS
int D = toInt(arg("d","250"));
int L = toInt(arg("l","250"));
int Q = toInt(arg("q","13"));
int H = toInt(arg("h","100"));
int O = toInt(arg("o","40"));
int E = toInt(arg("e","20"));
int M = toInt(arg("m","1"));

file bt2[] <filesys_mapper;prefix=filename(ref), suffix="bt2">;
file bt2_1 <single_file_mapper;file=strcat(filename(ref), ".1.bt2")>;
file bt2_2 <single_file_mapper;file=strcat(filename(ref), ".2.bt2")>;
file bt2_3 <single_file_mapper;file=strcat(filename(ref), ".3.bt2")>;
file bt2_4 <single_file_mapper;file=strcat(filename(ref), ".4.bt2")>;
file rev1bt2 <single_file_mapper;file=strcat(filename(ref), ".rev.1.bt2")>;
file rev2bt2 <single_file_mapper;file=strcat(filename(ref), ".rev.2.bt2")>;

file fai <single_file_mapper;file=strcat(filename(ref), ".fai")>;
file dict <single_file_mapper;file=strcat(strcut(filename(ref), "([^/ ]*).fasta"), ".dict")>;

fai = faidx(ref);
dict = createDict(ref);

if (length(bt2) > 0)
{
	tracef("%s\n", "Indexed.");
}
else {
        tracef("%s\n", "Not indexed.");
        (bt2_1, bt2_2, bt2_3, bt2_4, rev1bt2, rev2bt2) = bowtie2Build(ref);
}

foreach l,k in seqInput
{  
        tracef("Fasta 1 [%d]: %s\n", k, filename(seqInput[k].libF));
        tracef("Fasta 2 [%d]: %s\n", k, filename(seqInput[k].libR));

	string libFname;
	string libRname;

	file sam <single_file_mapper;file=strcat(libFname, ".sam")>;
	file log <single_file_mapper;file=strcat(libFname, "_", strcut(filename(ref), "([^/ ]*).fasta"), ".log")>;
	file bam <single_file_mapper;file=strcat(libFname, ".bam")>;
	file sorted <single_file_mapper;file=strcat(libFname, ".sorted.bam")>;
	file bai <single_file_mapper;file=strcat(filename(sorted), ".bai")>;
	file q30 <single_file_mapper;file=strcat(libFname, ".q30.bam")>;
	file depth <single_file_mapper;file=strcat(libFname, ".depth")>;
	file depth30 <single_file_mapper;file=strcat(libFname, ".q30.depth")>;
	#file dict <single_file_mapper;file=strcat(libFname, filename(ref), ".dict")>;
	file groupBam <single_file_mapper;file=strcat(libFname, ".group.bam")>;
	file groupBai <single_file_mapper;file=strcat(filename(groupBam), ".bai")>;
	file intervals1 <single_file_mapper;file=strcat(libFname, ".realigner.intervals")>;
	file realignedBam <single_file_mapper;file=strcat(libFname, ".realigned.bai")>;
	file nodupBam <single_file_mapper;file=strcat(strcut(libFname, "([^/ ]*).fastq"), ".nodup.bam")>;
	file metrics <single_file_mapper;file=strcat(libFname, ".dedupped.metrics")>;
	file nodupBai <single_file_mapper;file=strcat(filename(nodupBam), ".bai")>;
	file rawVcf <single_file_mapper;file=strcat(libFname, ".raw.vcf")>;
	file rawVcfIdx <single_file_mapper;file=strcat(libFname, ".raw.vcf.idx")>;
	file filtered1Vcf <single_file_mapper;file=strcat(libFname, ".filtered1.vcf")>;
	file filtered1VcfIdx <single_file_mapper;file=strcat(libFname, ".filtered1.vcf.idx")>;
	file grp <single_file_mapper;file=strcat(libFname,"_recal.grp")>;
	file recalibrated1Bam <single_file_mapper;file=strcat(libFname, ".recalibrated1.bam")>;
	file recalibrated1Bai <single_file_mapper;file=strcat(libFname, ".recalibrated1.bai")>;
	file recalibrated1Vcf <single_file_mapper;file=strcat(libFname, ".recalibrated1.vcf")>;
	file recalibrated1VcfIdx <single_file_mapper;file=strcat(libFname, ".recalibrated1.vcf.idx")>;
	file filtered2Vcf <single_file_mapper;file=strcat(libFname, ".filtered2.vcf")>;
	file filtered2VcfIdx <single_file_mapper;file=strcat(libFname, ".filtered2.vcf.idx")>;
	file grp2 <single_file_mapper;file=strcat(libFname, "_recal2.grp")>;
	file recalibrated2Bam <single_file_mapper;file=strcat(libFname, ".recalibrated2.bam")>;
	file recalibrated2Bai <single_file_mapper;file=strcat(libFname, ".recalibrated2.bai")>;
	file recalibrated2Vcf <single_file_mapper;file=strcat(libFname, ".recalibrated2.vcf")>;
	file recalibrated2VcfIdx <single_file_mapper;file=strcat(libFname, ".recalibrated2.vcf.idx")>;

	file bcf <single_file_mapper;file=strcat(libFname, ".bcf")>;

	file vcf <single_file_mapper;file=strcat(libFname, ".vcf")>;
	file vcfIdx <single_file_mapper;file=strcat(libFname, ".vcf.idx")>;

	string dir;
	trace(dir);
	file originalConf <"../bin/snpEff.config">;
	file conf <single_file_mapper;file=strcat(libFname,"_snpEff.config")>;
	file bin <simple_mapper;location=dir,prefix="snpEffectPredictor", suffix=".bin">;
	file seq <simple_mapper;location=dir,prefix="sequences", suffix=".fa">;
	file gtf_genes <simple_mapper;location=dir,prefix="genes", suffix=strcut(filename(gtf), "(\\.[^.]+)$")>;
	file mvVcf <simple_mapper;location=dir,prefix=libFname, suffix=".vcf">;

	file annotatedVcf[] <simple_mapper;location=dir,prefix=strcat(libFname,"_annotated_"),suffix=".vcf", padding=1>;

	file annotatedHtml[] <simple_mapper;location=dir,prefix=strcat(libFname,"_annotated_"),suffix=".html", padding=1>;

	int nSeq = toInt(arg("n","4000000"));

	#Altera o conf com o diretorio onde ficam os resultados e .genome
	conf = alterConfig(originalConf, dir, spec);

	file finalF;
	file finalR;

	#Tipo de reads (illumina ou ion)
	if (b30op == "y")
	{
		tracef("%s\n", "IonTorrent - retrieving >= 30mer");

		file libF_splitted[] <filesys_mapper;pattern=strcat(filename(seqInput[k].libF), "*_splitted_*")>;
		file fastq30F[];
		file libR_splitted[] <filesys_mapper;pattern=strcat(filename(seqInput[k].libR), "*_splitted_*")>;
		file fastq30R[];
		file lib30F <simple_mapper;prefix=strcut(filename(seqInput[k].libF),"([^/ ]*).fastq"), suffix="_b30.fastq">;
		file lib30R <simple_mapper;prefix=strcut(filename(seqInput[k].libR),"([^/ ]*).fastq"), suffix="_b30.fastq">;	

		libF_splitted = split(seqInput[k].libF, nSeq, strcat(filename(seqInput[k].libF), "_splitted_"));	
		libR_splitted = split(seqInput[k].libR, nSeq, strcat(filename(seqInput[k].libR), "_splitted_"));

		foreach f,i in libF_splitted
		{
			string fname_f=strcat(filename(f), ".bigger30.fq");
		  	file b30f <single_file_mapper; file=fname_f>;
		 	b30f = bigger30(f);
			fastq30F[i] = b30f;
		}

		foreach g,j in libR_splitted
		{
		        string fname_r=strcat(filename(g), ".bigger30.fq");
		  	file b30r <single_file_mapper; file=fname_r>;
		        b30r = bigger30(g);
		        fastq30R[j] = b30r;
		}
	
		lib30F = cat(fastq30F);
		lib30R = cat(fastq30R);
		libFname = filename(lib30F);
		libRname = filename(lib30R);
	
		finalF = lib30F;
		finalR = lib30R;
	}

	else{
		tracef("%s\n", "Illumina");
		libFname = filename(seqInput[k].libF);
		libRname = filename(seqInput[k].libR);

		finalF = seqInput[k].libF;
		finalR = seqInput[k].libR;

	}

	if (length(bt2) > 0)
	{
		tracef("%s\n", "Indexed.");
		(sam, log) = bowtie2Align(ref, finalF, finalR, bt2[0], bt2[1], bt2[2], bt2[3], bt2[4], bt2[5], t);
	}
	else {
		tracef("%s\n", "Not indexed.");
		#(bt2_1, bt2_2, bt2_3, bt2_4, rev1bt2, rev2bt2) = bowtie2Build(ref);
		(sam, log) = bowtie2Align(ref, finalF, finalR, bt2_1, bt2_2, bt2_3, bt2_4, rev1bt2, rev2bt2, t);
	}

	bam = sam2bam(sam);
	sorted = sortBam(bam, strcat(libFname, ".sorted"));
	bai = indexBam(sorted);
	q30 = q30(sorted);
	depth = getDepth(sorted);
	depth30 = getDepth(q30);

	(gtf_genes) = cp(gtf);
	(seq) = cp(ref);

	switch (op)
	{
	case 1:
		tracef("%s\n", "Option 1");
		dir = strcat(strcut(libFname, "([^/ ]*).fastq"), "_in_", strcut(filename(ref), "([^/ ]*).fasta"), "_GATK");
		#dict = createDict(ref);
		groupBam = createGroup(q30, libFname);
		groupBai = indexBam(groupBam);
		intervals1 = createIntervals1(ref, groupBam, dict, fai, groupBai);
		realignedBam = realign(ref, groupBam, intervals1, dict, fai, groupBai);
		(nodupBam, metrics) = nodup(realignedBam);
		nodupBai = indexBam(nodupBam);
		(rawVcf, rawVcfIdx) = snpCall(ref, nodupBam, ploidy, fai, dict, nodupBai);
		(filtered1Vcf, filtered1VcfIdx) = vcfFilter(ref, rawVcf, fai, dict,  MQ, DP, QUAL);
		grp = recalibrator1(ref, nodupBam, filtered1Vcf, fai, dict, nodupBai);
		(recalibrated1Bam, recalibrated1Bai) = recalibrator2(ref, nodupBam, grp, fai, dict, nodupBai);
		(recalibrated1Vcf, recalibrated1VcfIdx) = snpCall(ref, recalibrated1Bam, ploidy, fai, dict, recalibrated1Bai);
		(filtered2Vcf, filtered2VcfIdx) = vcfFilter(ref, recalibrated1Vcf, fai, dict, MQ, DP, QUAL);
		grp2 = recalibrator1(ref, nodupBam, filtered2Vcf, fai, dict, nodupBai);
		(recalibrated2Bam, recalibrated2Bai) = recalibrator2(ref, nodupBam, grp2, fai, dict, nodupBai);
		(recalibrated2Vcf, recalibrated2VcfIdx) = snpCall(ref, recalibrated2Bam, ploidy, fai, dict, recalibrated2Bai);
		(vcf, vcfIdx) = vcfFilter(ref, recalibrated2Vcf, fai, dict,  MQ, DP, QUAL);
		mvVcf = cp(vcf);

	case 2:	
		tracef("%s\n", "Option 2");
		dir = strcat(strcut(libFname, "([^/ ]*).fastq"), "_in_", strcut(filename(ref), "([^/ ]*).fasta"), "_samtools");
		(nodupBam, metrics) = nodup(q30);
		bcf = mpileup(ref, nodupBam, D, L, Q, H, O, E, M);
		vcf = bcftools(bcf);
		mvVcf = cp(vcf);
	
	default:
		tracef("%s\n", "Invalid option.");
	}
		
	#Check extensão do arquivo gtf para executar build com opção correta
	string genes_extension = strcut(filename(gtf), "(\\.[^.]+)$");
	trace(genes_extension);	
	if (genes_extension == ".gff")
	{
		(bin) = snpBuild(conf, dir, gtf_genes, seq, "gff3");
	}
	else {
		(bin) = snpBuild(conf, dir, gtf_genes, seq, "gtf22");
	}

	#Se for humano, executa os 3 snpEff
	if (spec == "human")
	{
		(annotatedVcf[0],annotatedHtml[0]) = snpEff(seq, mvVcf, conf, dir, bin, "snp");
		(annotatedVcf[1],annotatedHtml[1]) = snpEff(seq, mvVcf, conf, dir, bin, "del");
		(annotatedVcf[2],annotatedHtml[2]) = snpEff(seq, mvVcf, conf, dir, bin, "ins");
		#vcfs[1] = delVcf; 
		#vcfs[2] = insVcf; 
	} 
	else {
		tracef("%s\n", "No need to execute snpEff ins/del.");
		(annotatedVcf[0],annotatedHtml[0]) = snpEff(seq, mvVcf, conf, dir, bin, "snp");
	}

	#Proveniência
	file compressedVcf[];
	file indexedVcf[];

	foreach v,i in annotatedVcf
	{
		string gzname=strcat(filename(v), ".gz");
		trace(gzname);
		file gz <single_file_mapper; file=gzname>;
		gz = bgzip(v);
		compressedVcf[i] = gz;

		string tbiname=strcat(gzname, ".tbi");
		file tbi <single_file_mapper; file=tbiname>;
		tbi = tabix(gz);
		indexedVcf[i] = tbi;
	}

	file mergedVcf <simple_mapper;location=dir, prefix=strcat(filename(seqInput[k].libF), "_MERGED"), suffix=".vcf">;
	file vartypeVcf <simple_mapper;location=dir, prefix=strcat(filename(seqInput[k].libF), "_VARTYPE"), suffix=".vcf">;
	file finalVcf <simple_mapper;location=dir, prefix=strcat(filename(seqInput[k].libF), "_FINAL"), suffix=".vcf">;

	mergedVcf = vcfMerge(compressedVcf, indexedVcf);
	vartypeVcf = variantType(mergedVcf);
	finalVcf = extractFields(vartypeVcf);
}


