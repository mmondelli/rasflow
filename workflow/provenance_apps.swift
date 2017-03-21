#Compressing
app (file o) bgzip (file i)
{
	bgzip filename(i);
}

app (file o) tabix (file i)
{
	tabix "-p" "vcf" filename(i);
}

app (file o) vcfMerge (file compressed[], file indexed[])
{
	"vcf-merge" filenames(compressed) stdout=filename(o);
}

app (file o) variantType (file i)
{
	VariantType filename(i) filename(o);
}

app (file o) extractFields (file i)
{
	ExtractFields filename(i) filename(o);
}
