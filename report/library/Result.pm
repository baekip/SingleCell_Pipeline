#############################################################
#Author: baekip
#Date: 2017.2.2
#############################################################
package Result;
use Exporter qw(import);
our @EXPORT_OK = qw (result_scatter_plot result_diagram_plot result_table SV_header TRA_result INV_result );
#############################################################
##sub
##############################################################

sub result_scatter_plot {
    my ($fh, $plot, $sample_id) = @_;
    print $fh "##$sample_id
###Profile Scatter Plot
  Plot bin-level log2 coverages and segmentation calls together. Without any further arguments, this plots the genome-wide copy number in a form familiar to those who have used array CGH.\n\n
[Download Result File](result/$sample_id/cnvkit_run/$sample_id-scatter.png)\n\n

\`\`\`{r scatter_plot_$sample_id, out.width = \"1000px\",out.heigh=\"800px\"}

S_scatter_plot = \'result/$sample_id/cnvkit_run/$sample_id-scatter.png\'

include_graphics(S_scatter_plot)

\`\`\`\n\n";
}

sub result_diagram_plot {
    my ($fh, $plot, $sample_id) = @_;
    print $fh "### Profile Diagram Plot
 Draw copy number on chromosomes as an ideogram. If both the bin-level log2 ratios and segmentation calls are given, show them side-by-side on each chromosome\n\n
[Download Result File](result/$sample_id/cnvkit_run/$sample_id-diagram.png) \n\n
\`\`\`{r diagram_plot_$sample_id, out.width = \"1000px\",out.heigh=\"800px\"}

S_diagram_plot = \'result/$sample_id/cnvkit_run/$sample_id-diagram.png\'

include_graphics(S_diagram_plot)

\`\`\`\n\n";
}
#read.table(file.path(project_path, "", "result/Blood/Blood.gene.gainloss"), header=T, sep= "    ", check.names = T)
sub result_table {
    my ($fh, $gainloss, $sample_id) = @_;
    print $fh "### Total Result Table

 The log2 ratio value reported for each gene will be the value of the segment covering the gene. Where more than one segment overlaps the gene, i.e. if the gene contains a breakpoint, each segment's value will be reported as a separate row for the same gene.\n\n

[Download Result File](result/$sample_id/cnvkit_run/$sample_id.gene.gainloss)\n\n

\`\`\`{r cnv_table_$sample_id, results=\'asis\',echo=FALSE}
S_cnv_result=read.table(file.path(project_path,\"\",\"result/$sample_id/cnvkit_run/$sample_id.gene.gainloss\"), header=T, sep=\"\\t\", check.names = T)
datatable(S_cnv_result)
\`\`\`\n\n

  column                         Description
--------------     ------------------------------------------------------
  chromosome          Chromosome or reference sequence name
  start               Start position
  gene                Gene name          
  log2                Log2 mean coverage depth      
  depth               Absolute-scale mean coverage depth
  probes              the number of bins covered by the segment
  weight              each bin's proportional weight or reliability
  cn                  copy number value\n\n


If log2 value is up to       Copy number
------------------------   ---------------
       -1.1                        0
       -0.4                        1
        0.3                        2
        0.7                        3
        ...                       ...
\n";
}
sub SV_header {
    my $fh = shift;
    print $fh "### Rearrangement 
 This helps to identify genes in which (a) an unbalanced fusion or other structural rearrangement breakpoint occured, or (b) CNV calling is simply difficult due to an inconsistent copy number signal \n\n\n";
}

sub TRA_result {
    my ($fh, $sample_id, $output) = @_;
    print $fh "#### Translocation Result
[Download Result File](result/$sample_id/delly_run/$sample_id.delly_INV_PASS_Table.txt)\n\n
\`\`\`{r $sample_id\_TRA, results=\'asis\',echo=FALSE}
tra_table=read.table(file.path(project_path,\"\",\"result/$sample_id/delly_run/$sample_id\.delly_TRA_PASS_Table.txt\"), header=T, sep= \"\\t\", check.names = T)
datatable(tra_table)
\`\`\`\n\n\n";
}

sub INV_result {
    my ($fh, $sample_id, $output) = @_;
    print $fh "#### Inversion Result
[Download Result File](result/$sample_id/delly_run/$sample_id.delly_INV_PASS_Table.txt)\n\n
\`\`\`{r $sample_id\_INV, results=\'asis\',echo=FALSE}
inv_table=read.table(file.path(project_path,\"\",\"result/$sample_id/delly_run/$sample_id\.delly_INV_PASS_Table.txt\"), header=T, sep= \"\\t\", check.names = T)
datatable(inv_table)
\`\`\`\n\n\n";
};
1;
