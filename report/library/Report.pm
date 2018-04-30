#############################################################
#Author: baekip
#Date: 2017.2.2
#############################################################
package Report;
our $b;
use Exporter qw(import);
our @EXPORT_OK = qw(TEMPL_HTML_HEAD TEMPL_HEADER TEMPL_MENU TEMPL_SIDEBAR TEMPL_TBI TEMPL_10X TEMPL_HELP TEMPL_FOOTER TEMPL_FOOTER_2 TEMPL_HTML_FOOTER);
#############################################################
##sub
##############################################################
#sub import {
#    $Report::b = 1;
#}


sub TEMPL_HTML_HEAD {
    my $local = shift;
<<EOT;
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>scRNA Report</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" href="$local/images/Envision.css" type="text/css" />
<script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
</head>
<body>
<div id="wrap">
EOT
}

sub TEMPL_HEADER {
    my $html_file = shift;
<<EOT;
    <div id="header">
        <h1 id="logo-text">Theragen Etex Inc.</h1>
        <h2 id="slogan">scRNA Analysis Report</h2>
        <div id="header-links">
            <p> <a href="$html_file">Home</a> | <a href="http://www.theragenetex.com/bio/company/contact-us/">Contact</a> | <a href="http://www.theragenetex.com" target="_blank">Site Map</a> </p>
        </div>
    </div>
EOT
}


sub TEMPL_TBI {
<<EOT;
        <a name="Theragen Etex Bio Institute"></a>
        <h1>Theragen Etex Bio Institute</h1>
        <p><strong><a href="http://www.theragenetex.com/" target="_blank">Theragen Etex Bio Institute</a></strong>  is specialized genomics company developing innovative diagnosis tools and new drugs using the genomics and bioinformatics technologies. Theragen Etex Bio Institute's world class analysis technologies are proven by number of high impact journal publications.</p>
        <p>Proudly, we are the fifth organization in the world, which completed sequencing and assembly of an entire Human genome. In June 2013, we were recognized as the first group to identify genes that are related to Korean gastric cancer. In January 2014, we have secured the cover of the Nature Genetics with our research on the world's first Minke Whale Genome.</p>
        <p>We are providing genome-based customized research service, such as Genome, Transcriptome and Epigenome. In addition, we have personal genome service <strong><a href="http://www.theragenetex.com/kr/bio/services/hellogene/" target="_blank">"HelloGene"</a></strong>, which is screening disease susceptibility, physical traits, drug sensitivity and so on.</p>
        <p>Internationally, the first step has been started in the overseas markets with personal  genome analysis service contract with UNIMEX, Philippines in 2011. And a joint venture for entry to the personal genome analysis service in Beijing, China named 'Beijing Theragen Etex & Deyi Tech Co.,Ltd.'' has been established . Based on it, Asian genetic information and network have been organizing and gaining a foothold to move forward to global markets.</p>
        <p>Based on these technologies and experiences, we are putting endless efforts to revolutionize personalized medicine and to become a global leader in human welfare and healthcare.</p>
EOT
}

sub TEMPL_10X{
<<EOT;
      <a name="10X Genomics Report Information"></a>
        <h1>10X Genomics Report Information</h1>
        <p>The Chromium Single Cell Gene Expression Solution provides high-throughput, single cell expression measurements that enable discovery of gene expression dynamics and molecular profiling of individual cell types. </p>
        <p> -<strong><a href="https://support.10xgenomics.com/single-cell-gene-expression/software/pipelines/latest/output/summary" target="_blank"> Introduction of 10X Genomics Report </a></strong></p>
        <li><p> What is Loupe Cell Browser? </p></li>
        <p> -<strong><a href="https://support.10xgenomics.com/single-cell-gene-expression/software/visualization/latest/what-is-loupe-cell-browser" target="_blank">  Introduction of Loupe Cell Browser </a></strong></p>
        <p> -<strong><a href="https://support.10xgenomics.com/single-cell-gene-expression/software/visualization/latest/installation" target="_blank">  Installation of Loupe Cell Browser </a></strong></p>
EOT
}

sub TEMPL_HELP{
<<EOT;
    <a name="Analysis Workflow"></a>
    <h1>Analysis Workflow</h1>
    <ul>
    <li><a href='../images/singlecell_workflow.pdf' target='_blank'>
        <img src='../images/singlecell_workflow.pdf' width='300px' height='500px' border=0>
    </li>
    </ul>
    
    <a name="Sequencing Quality"></a>
    <h1>Sequencing Quality Assessment</h1>
    <ul>
        <li><h3>Simon Andrews. FastQC: A quality control tool for high throughput sequence data.[<a href='http://www.bioinformatics.babraham.ac.uk/projects/fastqc/'>Journal</a>]</h3></li>
        <li><h3>Li, H. et al. The Sequence Alignment/Map format and SAMtools. Bioinformatics 25, 2078- 2079(2009). [<a href="./alignment.statstics.xls">pubmed</a>]</h3></li>
        <li><h3>Quinlan, A. R. & Hall, I. M. BEDTools: a flexible suite of utilities for comparing genomic features. Bioinfomatics 26, 841-842(2010). [<a href="./alignment.statstics.xls">pubmed</a>]</h3></li>
    </ul>
    
    <a name="Method"></a>
    <h1>Method</h1>
    <ul>
        <li><h3>DePristo, M.A. et al. A framework for variation discovery and genotyping using next- generation DNA sequencing data. Nature Genetics 43, 491-498(2011).[<a href="./Sequencing_Statistics_Result.xls">pubmed</a>]</h3></li>
        <li><h3> Cingolani, P. et al. A program for annotating and predicting the effects of single nucleotide polymorphisms, SnpEff: SNPs in the genome of Drosophila melanogaster strain w1118; iso- 2; iso-3. Fly (Austin) 6, 80-92(2012). [<a href="./alignment.statstics.xls">pubmed</a>]</h3></li>
        <li><h3>Garcia-Alcalde F. et al. Qualimap: evaluating next-generation sequencing alignment data. Bioinformatics.28, 2678-2679(2012). [<a href="./alignment.statstics.xls">pubmed</a>]</h3></li>
    </ul>
EOT
}

sub TEMPL_SIDEBAR {
<<EOT;
        <div id="sidebar">
            <h1>Search Box</h1>
            <form action="#" class="searchform">
            <p>
                <input name="search_query" class="textbox" type="text" />
                <input name="search" class="button" value="Search" type="submit" />
            </p>
        </form>
        <h1>Sidebar Menu</h1>
        <ul class="sidemenu">
        
        </ul>
        <h1>Our Vision</h1>
        <div class="left-box">
            <p>&quot;A global leader specializing in human welfare and healthcare through genome-based personalized medicine.&quot; </p>
            <p class="align-right">- Theragen Etex</p>
        </div>
    </div>
EOT
}


#            <li><a href="$local/post_processing/postprocessing_index.html">Post Processing</a></li>
sub TEMPL_MENU {
    my $local = shift;
<<EOF;
    <div id="menu">
        <ul>
            <li><a href="$local/index.html">Home</a></li>
            <li><a href="$local/overview/overview_index.html">Overview</a></li>
            <li><a href="$local/samples/samples_index.html">Samples</a></li>
            <li><a href="$local/mapping/mapping_index.html">Mapping</a></li>
            <li><a href="$local/10XGenomics_result/10XGenomics_index.html">10X Genomics Report</a></li>
            <li><a href="$local/scQC_result/scQC_index.html">SingleCell QC</a></li>
            <li><a href="$local/post_processing/postprocessing_index.html">Post Processing</a></li>
            <li class="last"><a href="$local/help/help_index.html">Help</a></li>
        </ul>
    </div>
    <div id="content-wrap">
EOF
}

sub TEMPL_FOOTER {
    my $local = shift;

<<EOT;
    <p><a href="http:www.theragenetex.com"><img src="$local/images/Theragene_CI.png" width="190" height="190" alt="firefox" class="float-left" /></a><blockquote><p><a href="http://www.theragenetex.com" target="_blank">Theragen Etex </a>is a drug development company that utilizes information from genome analysis. Our genome division identifies potential genetic markers of various diseases. Information regarding genetic markers is used by our pharmaceutical division to develop new personalized drugs. We are investing an extensive amount of effort and resources to revolutionize personalized medicine by constructing genomic information databases using accumulated bioinformatics analysis capability and drug development technologies.</p>
    </blockquote> </p>
    <br />
    </div>

    </div>
    <div id="footer">
        <p> &copy; 2006 <strong>Theragen Etex Bio Institute</strong> | Design by: <a href="www.theragenetex.com">styleshout</a> | Valid <a href="http://validator.w3.org/check?uri=referer">XHTML</a> | <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="#">Home</a>&nbsp;|&nbsp; <a href="#">Sitemap</a>&nbsp;|&nbsp; <a href="#">RSS Feed</a> </p>
    </div>
EOT
}

sub TEMPL_FOOTER_2 {
    my $local = shift;
<<EOT;
    <p><a href="http:www.theragenetex.com" target="_blank"><img src="$local/images/Theragene_low_CI.png" width="300" height="70" alt="firefox" class="float-right" /></a>
        <br/>
        </div>
    </div>
    <div id="footer">
        <p> &copy; 2006 <strong>Theragen Etex Bio Institute</strong> | Design by: <a href="www.theragenetex.com">styleshout</a> | Valid <a href="http://validator.w3.org/check?uri=referer">XHTML</a> | <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href="#">Home</a>&nbsp;|&nbsp; <a href="#">Sitemap</a>&nbsp;|&nbsp; <a href="#">RSS Feed</a> </p>
    </div>
EOT
}

sub TEMPL_HTML_FOOTER {
<<EOT;    
</div>
</body>
</html>
EOT
}

1;
