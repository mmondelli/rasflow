#Seq. Bigger than 30
app (file o) bigger30 (file lib)
{	
	bigger30 filename(lib);
}

#Index for the genome
app (file bt2_1, file bt2_2, file bt2_3, file bt2_4, file rev1bt2, file rev2bt2) bowtie2Build (file ref)
{
	"bowtie2-build" "-q" filename(ref) filename(ref);
	#check strcat(ref, ".*.bt2") filename(ref);
}

#Maps the reads
app (file sam, file log) bowtie2AlignI (file ref, file libF, file libR, file bt2[], int t)
{
	bowtieAlign filename(ref) filename(libF) filename(libR) filename(sam) filename(log) t;
}

app (file sam, file log) bowtie2Align (file ref, file libF, file libR, file bt2_1, file bt2_2, file bt2_3, file bt2_4, file rev1bt2, file rev2bt2, int t)
{
	bowtieAlign filename(ref) filename(libF) filename(libR) filename(sam) filename(log) t;
}

#Change sam to bam
app (file bam) sam2bam (file sam)
{
	samtools "view" "-bS" filename(sam) stdout=filename(bam);
}

#Sort sam
app (file sorted) sortBam (file bam, string prefix)
{
	samtools "sort" filename(bam) prefix;
}

#Index bam
app (file bai) indexBam (file bam)
{
	samtools "index" filename(bam);
}

#Quality filter
app (file q30Bam) q30 (file bam)
{
	samtools "view" "-q" "30" "-b" filename(bam) stdout=filename(q30Bam);
}

#Get depth of mapping
app (file depth) getDepth (file bam)
{
	samtools "depth" filename(bam) stdout=filename(depth); 
}

app (file fai) faidx (file ref)
{
	samtools "faidx" filename(ref);
}

#Create a dictionary for GATK
app (file dict) createDict (file ref)
{
	CreateSequenceDictionary filename(ref) filename(dict);
	#"CreateSequenceDictionary.jar" "R=" filename(ref) "O=" filename(dict);
}

#Group reads
app (file o) createGroup (file bam, string lib)
{
 	AddOrReplaceReadGroups filename(bam) filename(o) lib;
	#"AddOrReplaceReadGroups.jar" "INPUT=" filename(bam) "OUTPUT=" filename(o) "RGID=1" "RGLB=A" "RGPL=IONTORRENT" "RGPU=NA" "RGSM=" filename(lib);
}

#Create coordenates - intervals
app (file o) createIntervals1 (file ref, file bam, file dict, file fai, file bai)
{
	GenomeAnalysisTK strcat("-T RealignerTargetCreator -R ", filename(ref), " -I ", filename(bam), " -o ", filename(o), " -nt 24");
}

#Remap based on intervals
app (file o) realign (file ref, file bam, file intervals, file dict, file fai, file bai)
{
	GenomeAnalysisTK strcat("-T IndelRealigner -R ", filename(ref), " -I ", filename(bam), " -targetIntervals ", filename(intervals), " -o ", filename(o));
}

#Remove duplicates
app (file nodup, file metrics) nodup (file bam)
{
	MarkDuplicates filename(bam) filename(nodup) filename(metrics); 
	#"MarkDuplicates.jar" "INPUT=" filename(bam) "OUTPUT=" filename(nodup) "METRICS_FILE=" filename(metrics) "ASSUME_SORTED=true";
}

#Call SNPs
app (file vcf, file idx) snpCall (file ref, file bam, string ploidy, file fai, file dict, file bai)
{
	GenomeAnalysisTK strcat("-T UnifiedGenotyper -R ", filename(ref), " -I ", filename(bam), " -o ", filename(vcf), " -stand_call_conf 50.0 -stand_emit_conf 10.0 -dcov 200 -ploidy ", ploidy, " -nt 8 -nct 3");
}

#Filter of vcf
app (file vcf_o, file idx) vcfFilterOld (file ref, file vcf, file fai, file dict, int mq, int dp, int qual)
{
	GenomeAnalysisTK "-T" "VariantFiltration" "-R" filename(ref) "-V" filename(vcf) "--filterExpression" strcat("QD < 2.0 || FS > 60.0 || MQ <=", mq, " || DP <= ", dp, " || QUAL >= 1500 || QUAL <= ", qual, " || ReadPosRankSum < -8.0") "--filterName" "snp_filter" "-o" filename(vcf_o);
}


app (file vcf_o, file idx) vcfFilter (file ref, file vcf, file fai, file dict, string mq, string dp, string qual)
{
	GenomeAnalysisTKFilter filename(ref) filename(vcf) filename(vcf_o) mq dp qual;
}

#First step of recalibrator
app (file o) recalibrator1 (file ref, file bam, file vcf, file fai, file dict, file bai)
{
	GenomeAnalysisTK strcat("-T BaseRecalibrator -R ", filename(ref), " -I ", filename(bam), " -knownSites ", filename(vcf), " -o ", filename(o), " -nct 8"); 
}

#Second step of recalibrator
app (file rbam, file rbai) recalibrator2 (file ref, file bam, file grp, file fai, file dict, file bai)
{
	GenomeAnalysisTK strcat("-T PrintReads -R ", filename(ref), " -I ", filename(bam), " -BQSR ", filename(grp), " -o ", filename(rbam)); 
}

app (file bin) snpBuild (file conf, string dir, file genes, file ref, string op)
{
	snpEffbuild op filename(conf) dir;
}

app (file ovcf, file html) snpEff (file ref, file ivcf, file conf, string dir, file bin, string op)
{
	snpEff dir filename(ivcf) filename(html) filename(ovcf) op filename(conf);
}

app rm (file i)
{
	rm filename(i);
}

app (file o) cp (file i)
{
	cp filename(i) filename(o);
}

app (file bcf) mpileup_IT (file ref, file bam)
{
	samtools "mpileup" "-d" "10000" "-L" "1000" "-Q" "7" "-h" "50" "-o" "10" "-e" "17" "-m" "4" "-f" filename(ref) "-g" filename(bam) stdout=filename(bcf);
}

app (file bcf) mpileup_old (file ref, file bam)
{
	samtools "mpileup" "-f" filename(ref) "-g" filename(bam) stdout=filename(bcf);
}

#14/03/2017
app (file bcf) mpileup (file ref, file bam, int d, int l, int q, int h, int o, int e, int m)
{
	samtools "mpileup" "-d" d "-L" l "-Q" q "-h" h "-o" o "-e" e "-m" m "-f" filename(ref) "-g" filename(bam) stdout=filename(bcf);
}

app (file vcf) bcftools (file bcf)
{
	bcfPerl filename(bcf) filename(vcf);
}

#SPLIT ################################

app (file fq[]) split (file lib, int n, string name)
{
	split "-l" n filename(lib) name;
}

app (file o) cat (file fq30[])
{
	cat filenames(fq30) stdout=filename(o);
}

#CONFIG ###############################

app (file o) alterConfig (file i, string dir, string spec)
{
	echosnp filename(i) strcat(dir, ".genome: ", spec) filename(o);
}
