# Param P Singh (Stanford University)
# Download all pathways and genes for a given organism from KEGG
# For API details see: http://www.genome.jp/kegg/rest/keggapi.html
# The log for getting file will be printed on terminal

use strict;
use warnings;


my $organism = $ARGV[0];

if (not defined $ARGV[0]){
	print 
"--------------------------------------------------------
Usage: perl getGenesInAllPathways.pl kegg-organism-code

kegg-organism-code for mouse: mmu
                   for human: hsa
                   for zebrafish: dre\n
For a complete list of organisms in KEGG, see: http://rest.kegg.jp/list/pathway

To run for mouse, enter on terminal: perl getGenesInAllPathways.pl mmu
The output files are: 
KEGG_Pathway-genes_Processed_mmu.txt: All pathways and the genes in them
mmu_all-genes.txt: List of all mouse genes in kegg

---------------------------------------------------------\n";
	die "Since you did not run me properly, I am dying";
}

# Uncomment one of these if you want
#my $organism = 'mmu';
#my $organism = 'dre';
#my $organism = 'hsa';

# Kegg version info for records
#print `wget http://rest.kegg.jp/info/$organism -O $organism\_kegg-info.txt`;

# For a particular organism - download all genes, all pathways and pathway to gene mapping
#print `wget http://rest.kegg.jp/list/pathway/$organism -O $organism\_all-pathways.txt`; # all pathways
#print `wget http://rest.kegg.jp/list/$organism -O $organism\_all-genes.txt`; # all genes
#print `wget http://rest.kegg.jp/link/$organism/pathway -O $organism\_pathway-to-gene-mapping.txt`; # pathway to gene maping

# Read and parse the pathway file and make a 2D hash with pahway id and gene ids -------------------------------------
my %Pathway2Genes;
open PATHGEN, "$organism\_pathway-to-gene-mapping.txt" or die $!;

foreach (<PATHGEN>){
	
	my @line = split "\t", $_;
	map {$_=~s/\n|\s+//g} @line;
	#print "$line[0]\t$line[1]\n";
	
	$Pathway2Genes{$line[0]}{$line[1]} = '';
}

print "Unique pathways in $organism: ", scalar keys %Pathway2Genes, "\n"; # print unique pathways

# Read gene ids file to get gene names -------------------------------------------------------------------------------
my %Genes;
open GENES, "$organism\_all-genes.txt" or die $!;

foreach (<GENES>){
	
	my @line = split "\t", $_;
	map {$_=~s/\n|^\s+|\s+$//g} @line;
	#print "$line[0]\t$line[1]\n";
	
	my @names = split /[\,\;]/, $line[1]; # The gene name can have a complicated pattern, but the fist element is the symbol. Use the entire line if you have doubts
	#print "$names[0]\n";
	
	$Genes{$line[0]} = $names[0];
}

print "Total unique genes in $organism: ", scalar keys %Genes, "\n"; # print unique pathways

# Read pathway file to get the names ---------------------------------------------------------------------------------
my %Pathways;
open PATH, "$organism\_all-pathways.txt" or die $!;

foreach (<PATH>){
	
	my @line = split "\t", $_;
	map {$_=~s/\n|^\s+|\s+$//g} @line;
	#print "$line[0]\t$line[1]\n";
	
	if ($organism eq 'mmu'){$line[1] =~s/ - Mus musculus \(mouse\)//g}
	if ($organism eq 'dre'){$line[1] =~s/ - Danio rerio \(zebrafish\)//g}
	if ($organism eq 'hsa'){$line[1] =~s/ - Homo sapiens \(human\)//g}
	
	$Pathways{$line[0]} = $line[1];
}
print "Total unique pathways in $organism from pathway file: ", scalar keys %Pathways, "\n"; # print unique pathways

# Get the Pathway to genes mapping in a file -------------------------------------------------------------------------
open OUT, ">KEGG_Pathway-genes_Processed_$organism\.txt" or die $!;

foreach my $pathid (keys %Pathway2Genes){
	
	print OUT "$pathid\t$Pathways{$pathid}\t";
	foreach (keys %{$Pathway2Genes{$pathid}}){
		
		if (exists $Genes{$_}) {print OUT "$Genes{$_} ";}
		else {print "ERROR: $_ is not found in $organism\'s genes\n";}
	}
	print OUT "\n";
}

print "Done";

