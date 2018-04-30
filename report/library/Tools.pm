#############################################################
#Author: baekip
#Date: 2018.3.4
#############################################################
package Report;
use Exporter qw(import);
our @EXPORT_OK = qw(report_header report_opt report_int report_info report_workflow);
#############################################################
##sub
##############################################################

sub HTML_TABLE_SEQ {"""
        <table>
            <tr>
                <th class="center"><strong>No.<strong></th>
                <th>Delivery ID<br>(TBI ID)</th>
                <th>Read<br>Information</th>
                <th>Total<br>Reads</th>
                <th>Total<br>Yield(Gbp)</th>
                <th>GC rate (%)</th>
                <th>Q30<br>MoreBases<br>Rate</th>
                <th>Q20<br>MoreBases<br>Rate</th>
            </tr>
""";
}

sub TEMPL_TABLE {
    my ($fh, $ver, $project_id) = @_;
    
    print $fh """<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
<title>[Institutue]</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link rel="stylesheet" href="images/Envision.css" type="text/css" />
</head>
<body>
<div id="wrap">
""";
}

sub TEMPL_HEADER {
    my ($fh, $work_path) = @_;
    print $fh """  
    <div id="header">
        <h1 id="logo-text">Theragenetex Inc.</h1>
        <h2 id="slogan">scRNA Analysis Report</h2>
        <div id="header-links">
            <p> <a href="index.html">Home</a> | <a href="http://www.theragenetex.com/bio/company/contact-us/">Contact</a> | <a href="http://www.theragenetex.com" target="_blank">Site Map</a> </p>
        </div>
    </div>
""";
}

sub TEMPL_FOOTER {
    my ($fh, $work_path) = @_;
    print $fh """  
    <div id="header">
        <h1 id="logo-text">Theragenetex Inc.</h1>
        <h2 id="slogan">scRNA Analysis Report</h2>
        <div id="header-links">
            <p> <a href="index.html">Home</a> | <a href="http://www.theragenetex.com/bio/company/contact-us/">Contact</a> | <a href="http://www.theragenetex.com" target="_blank">Site Map</a> </p>
        </div>
    </div>
""";
}

sub TEMPL_FOOTER {
    my ($fh, $work_path) = @_;
    print $fh """
      </div>
        <div id="footer">
            <p> &copy; 2006 <strong>Theragene Etex Bio Institute</strong> | Design by: <a href="www.theragenetex.com">styleshout</a> | Valid <a href="http://validator.w3.org/check?uri=referer">XHTML</a> | <a href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <a href=\"#\">Home</a>&nbsp;|&nbsp; <a href=\"#\">Sitemap</a>&nbsp;|&nbsp; <a href=\"#\">RSS Feed</a> </p>
        </div>
""";
}

sub TEMPL_HTML_FOOTER {
    """</div>
    </body>
    </html>
    """;
}

sub html_files {
    my ($fh, $work_path) = @_;
    print $fh """


""";
}

1;
