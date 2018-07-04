# rasflow

Workflow for RASopathy analysis using the Swift parallel scripting system.

Requirements
============

This uses the tools:
- GATK: https://software.broadinstitute.org/gatk/
- Samtools: http://www.htslib.org/
- Swift: http://swift-lang.org/main/ (installation guide, documentation, downloads and general information about the Swift parallel scripting language)
- SQLite: https://www.sqlite.org/index.html

Workflow invocation
===================

To execute the workflow it is necessary that:
* The filenames of the sequences to be analyzed should be described in the input.csv file;
* The input files must be in the directory where the workflow will run: 
	* The reference genome file
	* GFF or GTF file
	* The input.csv metioned above
	* The sequence (forward and reverse) files

The workflow can be executed using the following command:

```
swift loss_all.swift -ref=<reference> -gtf=<gff or gtf file> -op=<1-samtools or 2-GATK> -p=<number of cores> -input=input.csv; 
```

Instead, if you want to run the workflow and import the provenance automatically, you can run:

```
rasflow <reference> <gtf> <number of cores> <option (1-samtools or 2-GATK)> <input.csv> <provenance database (ex.: ./swift_provenance.db)>
```

Note that the workflow aims to analyze the sequences in parallel. Thus, the number of processes defined with the -p parameter will be replicated for each sequence analysis.

Also, the GATK and Samtools applications used in the workflow and other scripts (e.g., for the collection of domain provenance) are placed in the /bin directory of this repository. It is necessary to add them to the system PATH so that Swift can recognize:

```
export PATH=<path to /bin>:$PATH
```

A sample of input data for RASflow can be downloaded [here](https://zenodo.org/record/1304274).


