#############################################################
#Author: baekip
#Date: 2017.2.2
#############################################################
package Report_Utils;
use Exporter qw(import);
our @EXPORT_OK = qw(templ_files templ_box_10X templ_sidebar table_header table_body table_fastqc table_scQC table_post_1 table_post_2 table_main);
#############################################################
##sub
##############################################################

sub templ_files {
    my ($fh_input, @value) = @_;
    print $fh_input "
    <a name=\"Files\"></a>
        <h1>Files</h1>
        <code><p>
            <ul>
            ";
            foreach my $id (@value) {
                my ($title, $file) = split /\:/, $id;
                print $fh_input "<li><h3> $title [<a href=\"$file\">File</a>]</h3></li>\n";
                }
     print $fh_input "
            </ul></p>
        </code>
        ";
}

sub templ_box_10X {
    my ($fh_input, @value) = @_;
    foreach my $id (@value){
        print $fh_input "
        <a name=\"$id\"></a>
            <h1>$id</h1>
            <code>
                <ul>
                <li><a href=\"./$id/web_summary.html\" target=\"_blank\"> 10X Genomics Report - $id </a></li> 
                <li><a href=\"./$id/cloupe.cloupe\" download> Loupe Cell File Download [$id.loupe] </a></li>
            </ul>
            </code>
        ";
    }
}

sub templ_sidebar {
    my ($fh_input, @value) = @_;
    print $fh_input "
        <div id=\"sidebar\">
            <h1>Search Box</h1>
            <form action=\"#\" class=\"searchform\">
            <p>
                <input name=\"search_query\" class=\"textbox\" type=\"text\" />
                <input name=\"search\" class=\"button\" value=\"Search\" type=\"submit\" />
            </p>
        </form>
        <h1>Sidebar Menu</h1>
        <ul class=\"sidemenu\">";
        
        foreach my $id (@value) {
            my ($ref, $title) = split /\:/, $id;
            print $fh_input "<li><a href=\"$ref\">$title</a></li>\n";
        }
        
        print $fh_input "</ul>
        <h1>Our Vision</h1>
        <div class=\"left-box\">
            <p>&quot;A global leader specializing in human welfare and healthcare through genome-based personalized medicine.&quot; </p>
            <p class=\"align-right\">- Theragen Etex</p>
        </div>
    </div>

    <div id = \"main\"> 
    ";
}

sub table_main {
    my ($fh_input, $id) = @_;
    print $fh_input "
        <a name=\"$id\"></a>
        <h1>$id</h1>
            <code><p>
                <ul>
                    <li><h3> gene expression file per cluster [<a href=\"./$id/expression.cluster.xls\">File</a>]</h3></li>
                    <li><h3> High Expression Top 10 Genes - gene expression file per cluster [ <a href=\"./$id/high.top10.gene.expression.cluster.xls\">File</a>]</h3></li>
                    <li><h3> Low Expression Top 10 Genes - gene expression file per cluster [ <a href=\"./$id/low.top10.gene.expression.cluster.xls\">File</a>]</h3></li>
                </ul></p>
            </code>
            
            <table>
                <tr>
                    <th class=\"center\"><strong>Cluster - tSNE</strong></th>
                    <th>Phylogenetic Tree</th>
                </tr>
                <tr>
                    <td height=\"250\"><a href='./$id/compare_plot.png' target='_blank'> <img src='./$id/compare_plot.png' width='500px' border=0></a> </td>
                    <td height=\"250\"><a href='./$id/Phylogenetic_Tree.png' target='_blank'> <img src='./$id/Phylogenetic_Tree.png' width='500px' border=0></a> </td>              
                </tr>
                <tr>
                    <th class=\"center\"><strong>High Expression Feature Plot - Top 2 Genes</strong></th>
                    <th class=\"center\"><strong>Low Expression Feature Plot - Top 2 Genes</strong></th>
                </tr>
                <tr>
                    <td height=\"250\"><a href='./$id/High_Top2Gene_FeaturePlot.png' target='_blank'> <img src='./$id/High_Top2Gene_FeaturePlot.png' width='500px' border=0></a> </td>
                    <td height=\"250\"><a href='./$id/Low_Top2Gene_FeaturePlot.png' target='_blank'> <img src='./$id/Low_Top2Gene_FeaturePlot.png' width='500px' border=0></a> </td>
                </tr>
                <tr>
                    <th class=\"center\"><strong>High Expression Heatmap - Top 10 Genes</strong></th>
                    <th class=\"center\"><strong>Low Expression Heatmap - Top 10 Genes</strong></th>
                </tr>
                <tr>
                    <td height=\"250\"><a href='./$id/High_Top10Gene_Heatmap.png' target='_blank'> <img src='./$id/High_Top10Gene_Heatmap.png' width='500px' border=0></a> </td>
                    <td height=\"250\"><a href='./$id/Low_Top10Gene_Heatmap.png' target='_blank'> <img src='./$id/Low_Top10Gene_Heatmap.png' width='500px' border=0></a> </td>
                </tr>
            </table>
            ";
}

sub table_header {
    my ($fh_input, $name, @value) = @_;
    print $fh_input "<a name=\"$name\"></a>\n";
    print $fh_input "<h1>$name</h1>\n";
    print $fh_input "<table>\n";
    print $fh_input "<tr>\n";
    
    for (my $i=0; $i<@value; $i++){
        my $j = $i + 1;
        if ($j == 1) {
            print $fh_input "\t<th class=\"first\"><strong>$value[$i]<strong></th>\n";
        }else{
            print $fh_input "\t<th>$value[$i]</th>\n";
        }
    }
}
#table body
sub table_body {
    my ($fh_input, @value) = @_;
    for (my $i=0; $i<@value; $i++){
        my $j = $i+1;
        my @tmp_value = split /\:/,$value[$i];
        print $fh_input "\t</tr>\n";
        if ($j % 2 == 1) {
            print $fh_input "\t<tr class=\"row-a\">\n";
        }elsif ($j % 2 == 0){
            print $fh_input "\t<tr class=\"row-b\">\n";
        }
        print $fh_input "\t<td class=\"first\">$j</td>\n";
        foreach my $sub_value (@tmp_value){
            print $fh_input "\t\t<td>$sub_value</td>\n";
        }
    }
    print $fh_input "\t</tr>\n";
    print $fh_input "</table>\n";
}

sub table_fastqc {
    my ($fh_input, $title, @value) = @_;
    print $fh_input "
        <h2>$title</h2>
        ";
        foreach (@value) {
            print $fh_input "
        <a href='$_' target='_blank'>
        <img src='$_' width='350px' border=0>
        </a>
        ";
    }
}

sub table_scQC {
    my ($fh_input, $id) = @_;
    print $fh_input "
        <h2>$id</h2>
        <table>
            <tr>
                <th class = \"center\"><strong>Distribution of detected genes</strong></th>
                <th>Expression sum per cell</th>
                <th>Violin Plot</th>
                <th>Correlation Plot</th>
            </tr>
            <tr>
                <td><a href='$id/Distribution_of_detected_genes.png' target='_blank'>
                    <img src='$id/Distribution_of_detected_genes.png' width='250px' border=0>
                    </a>
                </td>
                <td><a href='$id/Expression_sum_per_cell.png' target='_blank'>
                    <img src='$id/Expression_sum_per_cell.png' width='250px' border=0>
                    </a>
                </td>
                <td><a href='$id/vlnplot.png' target='_blank'>
                    <img src='$id/vlnplot.png' width='250px' border=0>
                    </a>
                </td>
                <td><a href='$id/Geneplot.png' target='_blank'>
                    <img src='$id/Geneplot.png' width='250px' border=0>
                    </a>
                </td>
            </tr>
        </table>
        ";
}

sub table_post_1 {
    my ($fh_input, $id) = @_;
    print $fh_input "
        <h1>$id</h1>
        <table>
            <tr>
                <th class = \"center\"><strong>Filtered Distribution of normalisation</th>
                <th>Filtered gene dispersion</th>
                <th>Filtered Violin Plot</th>
                <th>Filtered Correlation Plot</th>
            </tr>
            <tr>
                <td><a href='$id/Filtered_normalisation_distribution.png' target='_blank'>
                    <img src='$id/Filtered_normalisation_distribution.png' width='250px' border=0>
                    </a>
                </td>
                <td><a href='$id/Filtered_gene_dispersion.png' target='_blank'>
                    <img src='$id/Filtered_gene_dispersion.png' width='250px' border=0>
                    </a>
                <td><a href='$id/Filtered_vlnplot.png' target='_blank'>
                    <img src='$id/Filtered_vlnplot.png' width='250px' border=0>
                    </a>
                </td>
                <td><a href='$id/Filtered_Geneplot.png' target='_blank'>
                    <img src='$id/Filtered_Geneplot.png' width='250px' border=0>
                    </a>
                </td>
            </tr>
        ";
}

sub table_post_2 {
    my ($fh_input, $id) = @_;
    print $fh_input "
            <tr>
                <th class = \"center\"><strong>Filtered PCA Plot</th>
                <th>Filtered JackStraw Plot</th>
                <th>Filtered PCElbow Plot</th>
                <th>Filtered tSNE Plot</th>
            </tr>
            <tr>
                <td><a href='$id/PCA_plot.png' target='_blank'>
                    <img src='$id/PCA_plot.png' width='250px' border=0>
                    </a>
                </td>
                <td><a href='$id/JackStraw_plot.png' target='_blank'>
                    <img src='$id/JackStraw_plot.png' width='250px' border=0>
                    </a>
                <td><a href='$id/PCElbow_plot.png' target='_blank'>
                    <img src='$id/PCElbow_plot.png' width='250px' border=0>
                    </a>
                </td>
                <td><a href='$id/cluster_plot.png' target='_blank'>
                    <img src='$id/cluster_plot.png' width='250px' border=0>
                    </a>
                </td>
            </tr>
        </table>
        ";
}

1;
