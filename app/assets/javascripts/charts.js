//$(function() {
//    $.getJSON('http://localhost:3000/visualise.json', function(data) {
//
//        // Create the chart
//        window.chart = new Highcharts.StockChart({
//            chart: {
//                renderTo: 'container'
//            },
//
//            rangeSelector: {
//                selected: 1
//            },
//
//            title: {
//                text: 'Your Twitter Activity'
//            },
//
//            series: [{
//                name: 'Tweets',
//                data: data,
//                type: 'spline',
//                tooltip: {
//                    valueDecimals: 2
//                }
//            }]
//        });
//    });
//});