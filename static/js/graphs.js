Chart.defaults.global.responsive = true;
Chart.defaults.global.showTooltips = false;

queue()
    .defer(d3.json, "http://127.0.0.1:5000/sensor/status")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/summary")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/minute?duration=60")
    .await(makeGraphs);


function makeGraphs(error, status, summary, last_hour) {
    makeUpdateText(status);
    makeSummaryBox(summary);
    makeLastHourBox(last_hour);
}

function makeUpdateText(status) {
    var format = d3.time.format.utc("%I:%M %p");
    $(".updated-time").text(format(new Date(status.last_reading)));
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

    var chart_data = [
        {
          label: 'My First dataset',
          strokeColor: '#F16220',
          pointColor: '#F16220',
          pointStrokeColor: '#fff',
          data: temp_data
        },
        {
          label: 'My First dataset',
          strokeColor: '#F16220',
          pointColor: '#F16220',
          pointStrokeColor: '#fff',
          data: humidity_data
        },

      ];

    var ctx = document.getElementById("last-hour-chart").getContext("2d");
    var myNewChart = new Chart(ctx).Scatter(chart_data, {
        scaleShowGridLines : false,
        pointDot: false,
        scaleType: "date",
    });
}
