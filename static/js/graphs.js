Chart.defaults.global.responsive = true;

var jqXHR = $.ajax({
    url: "http://127.0.0.1:5000/sensor/readings/minute",
    dataType: "json"
});

jqXHR.done(function(data) {
    var times = _.keys(data);
    var temps = _.values(data);

    var chart_data = {
        labels: times,
        datasets: [
            {
                label: "Temperatures",
                fillColor: "rgba(151,187,205,0.2)",
                strokeColor: "rgba(151,187,205,1)",
                pointColor: "rgba(151,187,205,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(151,187,205,1)",
                data: temps
            }
        ]
    };

    var ctx = document.getElementById("realtimeChart").getContext("2d");
    var myNewChart = new Chart(ctx).Line(chart_data, {
        scaleShowGridLines : false,
        pointDot : false,
        bezierCurve: false,
    });
});
