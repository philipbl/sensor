Chart.defaults.global.responsive = true;

queue()
    .defer(d3.json, "http://127.0.0.1:5000/sensor/status")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/summary")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/minute")
    .await(makeGraphs);


function makeGraphs(error, status, summary, last_hour) {
    makeUpdateText(status);
    makeSummaryBox(summary);
    makeLastHourBox(last_hour);
}

function makeUpdateText(status) {
    console.log(status.last_reading);
    $(".updated-time").text(status.last_reading);
    $(".updated").css("opacity", "1");
}

function makeSummaryBox(summary) {
    var format = d3.format(".1f");
    $(".temp-summary .temp").text(format(summary.temperature.mean));
    $(".temp-summary .temp-high").text(format(summary.temperature.max));
    $(".temp-summary .temp-low").text(format(summary.temperature.min));

    $(".humidity-summary .humidity").text(format(summary.humidity.mean));
    $(".humidity-summary .humidity-high").text(format(summary.humidity.max));
    $(".humidity-summary .humidity-low").text(format(summary.humidity.min));

    $(".summary").css("opacity", "1");
}

function makeLastHourBox(last_hour) {
    var temp_data = last_hour.temperature;
    var humidity_data = last_hour.humidity;

    var times = _.keys(temp_data);
    var temps = _.values(temp_data);
    var humidities = _.values(humidity_data);

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
            },
            {
                label: "Temperatures",
                fillColor: "rgba(151,187,205,0.2)",
                strokeColor: "rgba(151,187,205,1)",
                pointColor: "rgba(151,187,205,1)",
                pointStrokeColor: "#fff",
                pointHighlightFill: "#fff",
                pointHighlightStroke: "rgba(151,187,205,1)",
                data: humidities
            }

        ]
    };

    var ctx = document.getElementById("last-hour-chart").getContext("2d");
    var myNewChart = new Chart(ctx).Line(chart_data, {
        scaleShowGridLines : false,
        pointDot : false,
        bezierCurve: false,
    });
}
