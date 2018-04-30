#############################################################
#Author: baekip
#Date: 2017.2.2
#############################################################
package Report_Graphics;
use Exporter qw(import);
our @EXPORT_OK = qw(graphics_stack_hist graphics_clumn_hist graphics_boxplot);
#############################################################
##sub
##############################################################

sub graphics_stack_hist {
    my ($fh_input, $title, $sub_title, @value) = @_;
    print $fh_input "
        <a name=\"$sub_title\"></a><h1>$sub_title</h1>
        <script type=\"text/javascript\">
        google.charts.load('current', {'packages':['bar']});
        google.charts.setOnLoadCallback(drawChart);
        function drawChart() {
          var $sub_title = google.visualization.arrayToDataTable([
          ";
        foreach (@value) {
            my @sub_value = split /\:/, $_;
            print $fh_input "\t\t[";
            foreach (@sub_value) {
                if ($_ =~ /_|[A-Za-z]/){
                    print $fh_input "\'$_\',";
                }elsif ($_ =~ /^\d+\.\d+/){
                    print $fh_input "$_,";
                }
            }
            print $fh_input "],\n";
        }
        print $fh_input "
        ]);
          var options = {
            chart: {
              title: '$title',
              subtitle: '$sub_title',
            },
            legend: { position: 'top', maxLines: 3 },
            bar: { groupWidth: '75%' },
            isStacked: true,
          };

            var chart = new google.charts.Bar(document.getElementById('$sub_title'));
            chart.draw($sub_title, google.charts.Bar.convertOptions(options));
          }

          </script>
          <div id=\"$sub_title\" style=\"width: 1200px; height: 450px;\"></div>
          ";
}

sub graphics_clumn_hist {
    my ($fh_input, $title, $sub_title, @value) = @_;
    print $fh_input "
        <a name=\"$sub_title\"></a><h1>$sub_title</h1>
        <script type=\"text/javascript\">
        google.charts.load('current', {'packages':['bar']});
        google.charts.setOnLoadCallback(drawChart);
        function drawChart() {
          var $sub_title = google.visualization.arrayToDataTable([";
          foreach (@value) {
            my @sub_value = split /\:/, $_;
            print $fh_input "\t\t[";
            foreach (@sub_value) {
                if ($_ =~ /_|[A-Za-z]/){
                    print $fh_input "\'$_\',";
                }elsif ($_ =~ /^\d+\.\d+/){
                    print $fh_input "$_,";
                }
            }
            print $fh_input "],\n";
        }
        print $fh_input "
        ]);
            var options = {
              chart: {
                title: '$title',
                subtitle: '$sub_title',
              },
              bars: 'vertical',
              vAxis: {format: 'decimal'},
              height: 400
            };
            var chart = new google.charts.Bar(document.getElementById('$sub_title'));
            chart.draw($sub_title, google.charts.Bar.convertOptions(options));
          }
          </script>
          <div id=\"$sub_title\" style=\"width: 1200px; height: 450px;\"></div>
";
}

sub graphics_boxplot {
    my ($fh_input, $title, $sub_title, $value, $sample_list) = @_;
    my $num = scalar @$sample_list + 1;
    my $num_1 = $num + 1; $num_2 = $num + 2; $num_3 = $num + 3; $num_4 = $num + 4;
    print $fh_input "
        <a name=\"$title\"></a><h1>$title</h1>
         
        <head>
        <script type=\"text/javascript\">
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawBoxPlot);
        function drawBoxPlot() {
            var array = [
            ";
        foreach (@$value) {
            my @sub_value = split /\:/, $_;
            print $fh_input "\t\t[";
            foreach (@sub_value) {
                if ($_ =~ /_|[A-Za-z]/){
                    print $fh_input "\'$_\',";
                }elsif ($_ =~ /^\d+/){
                    print $fh_input "$_,";
                }
            }
            print $fh_input "],\n";
        }
        print $fh_input "
        ];
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'x');
        ";
        foreach my $sample (@$sample_list){ 
            print $fh_input "\t\tdata.addColumn('number', '$sample');\n";;
        }
        
        print $fh_input "

        data.addColumn({id:'max', type:'number', role:'interval'});
        data.addColumn({id:'min', type:'number', role:'interval'});
        data.addColumn({id:'firstQuartile', type:'number', role:'interval'});
        data.addColumn({id:'median', type:'number', role:'interval'});
        data.addColumn({id:'thirdQuartile', type:'number', role:'interval'});

        data.addRows(getBoxPlotValues(array));

      /**
       * Takes an array of input data and returns an
       * array of the input data with the box plot
       * interval data appended to each row.
       */
      function getBoxPlotValues(array) {

        for (var i = 0; i < array.length; i++) {

          var arr = array[i].slice(1).sort(function (a, b) {
            return a - b;
          });

          var max = arr[arr.length - 1];
          var min = arr[0];
          var median = getMedian(arr);

          // First Quartile is the median from lowest to overall median.
          var firstQuartile = getMedian(arr.slice(0, 4));

          // Third Quartile is the median from the overall median to the highest.
          var thirdQuartile = getMedian(arr.slice(3));

          array[i][$num] = max;
          array[i][$num_1] = min
          array[i][$num_2] = firstQuartile;
          array[i][$num_3] = median;
          array[i][$num_4] = thirdQuartile;
        }
        return array;
      }

      /*
       * Takes an array and returns
       * the median value.
       */
      function getMedian(array) {
        var length = array.length;

        /* If the array is an even length the
         * median is the average of the two
         * middle-most values. Otherwise the
         * median is the middle-most value.
         */
        if (length % 2 === 0) {
          var midUpper = length / 2;
          var midLower = midUpper - 1;

          return (array[midUpper] + array[midLower]) / 2;
        } else {
          return array[Math.floor(length / 2)];
        }
      }

      var options = {
          title:'$title',
          height: 500,
          legend: {position: 'none'},
          hAxis: {
            gridlines: {color: '#fff'}
          },
          lineWidth: 0,
          series: [{'color': '#D3362D'}],
          intervals: {
            barWidth: 1,
            boxWidth: 1,
            lineWidth: 2,
            style: 'boxes'
          },
          interval: {
            max: {
              style: 'bars',
              fillOpacity: 1,
              color: '#777'
            },
            min: {
              style: 'bars',
              fillOpacity: 1,
              color: '#777'
            }
          }
      };

      var chart = new google.visualization.LineChart(document.getElementById('$sub_title'));

      chart.draw(data, options);
    }
    </script>
  </head>
  <body>
    <div id=\"$sub_title\" style=\"width: 900px; height: 500px;\"></div>
  </body>
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

1;
