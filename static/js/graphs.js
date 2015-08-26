Chart.defaults.global.responsive = true;
// Chart.defaults.global.showTooltips = false;

temperature_color = "#F44336";
humidity_color = "#2196F3";

makeGraphs();

function makeGraphs() {
    makeUpdateText();
    makeSummaryBox();
    makeLastHourBox();
    makeTwelveHourBox();
    makeTwentyFourHourBox();
    makeWeekBox();
    makeMonthBox();
    makeYearBox();
    makeAverageDay();
    makeAverageWeek();
}

function makeUpdateText() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/status",
        dataType: "json"
    })
    .done(function (status) {
        var format = d3.time.format.utc("%I:%M %p");
        $(".updated-time").text(format(new Date(status.last_reading)));
        $(".updated").css("opacity", "1");
    });
}

function makeSummaryBox() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/summary",
        dataType: "json"
    })
    .done(function (summary) {
        var format = d3.format(".1f");
        $(".temp-summary .temp").text(format(summary.temperature.mean));
        $(".temp-summary .temp-high").text(format(summary.temperature.max));
        $(".temp-summary .temp-low").text(format(summary.temperature.min));

        $(".humidity-summary .humidity").text(format(summary.humidity.mean));
        $(".humidity-summary .humidity-high").text(format(summary.humidity.max));
        $(".humidity-summary .humidity-low").text(format(summary.humidity.min));

        $(".summary").css("opacity", "1");
    });
}

function makeLastHourBox() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/stats/minute?duration=60",
        dataType: "json"
    })
    .done(function (data) {
        makeScatterPlot(data, "last-hour-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            pointDotRadius: 3,
            scaleType: "date",
        });
    });
}

function makeTwelveHourBox() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/stats/hour?duration=12",
        dataType: "json"
    })
    .done(function (data) {
        makeScatterPlot(data, "twelve-hour-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            pointDotRadius: 3,
            scaleType: "date",
        });
    });
}

function makeTwentyFourHourBox() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/stats/hour?duration=24",
        dataType: "json"
    })
    .done(function (data) {
        makeScatterPlot(data, "twentyfour-hour-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            pointDotRadius: 3,
            scaleType: "date",
        });
    });
}

function makeWeekBox() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/stats/hour?duration=168&interval=3",
        dataType: "json"
    })
    .done(function (data) {
        makeScatterPlot(data, "week-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            // pointDot: false,
            pointDotRadius: 3,
            scaleType: "date",
        });
    });
}

function makeMonthBox() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/stats/hour?duration=720&interval=12",
        dataType: "json"
    })
    .done(function (data) {
        makeScatterPlot(data, "month-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            // pointDot: false,
            pointDotRadius: 3,
            scaleType: "date",
        });
    });
}

function makeYearBox() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/stats/day?duration=365&interval=1",
        dataType: "json"
    })
    .done(function (data) {
        makeScatterPlot(data, "year-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            pointDotRadius: 3,
            scaleType: "date",
        });
    });
}

function makeAverageDay() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/average/day",
        dataType: "json"
    })
    .done(function (data) {
        makeLineGraph(data, "average-day-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            pointDotRadius: 3,
        });
    });
}

function makeAverageWeek() {
    $.ajax({
        url: "http://127.0.0.1:5000/sensor/average/week",
        dataType: "json"
    })
    .done(function (data) {
        makeLineGraph(data, "average-week-chart", temperature_color, humidity_color, {
            scaleShowGridLines : false,
            pointDotRadius: 3,
        });
    });
}

function makeScatterPlot(data, id, temp_color, humidity_color, chart_options) {
    var temp_data = data.temperature;
    var humidity_data = data.humidity;

    var chart_data = [
        {
          label: 'Temperature',
          strokeColor: temp_color,
          pointColor: temp_color,
          pointStrokeColor: '#fff',
          data: temp_data
        },
        {
          label: 'Humidity',
          strokeColor: humidity_color,
          pointColor: humidity_color,
          pointStrokeColor: '#fff',
          data: humidity_data
        },

      ];

    var ctx = document.getElementById(id).getContext("2d");
    var myNewChart = new Chart(ctx).Scatter(chart_data, chart_options);
}

function makeLineGraph(data, id, temp_color, humidity_color, chart_options) {
   var temp_data = data.temperature;
   var humidity_data = data.humidity;
   var labels = data.labels;

   var chart_data = {
       labels: labels,
       datasets: [
           {
               label: 'Temperature',
               fillColor: "rgba(0,0,0,0)",
               strokeColor: temp_color,
               pointColor: temp_color,
               pointStrokeColor: '#fff',
               data: temp_data
           },
           {
               label: 'Humidity',
               fillColor: "rgba(0,0,0,0)",
               strokeColor: humidity_color,
               pointColor: humidity_color,
               pointStrokeColor: '#fff',
               data: humidity_data
           }
       ]
   };

   var ctx = document.getElementById(id).getContext("2d");
   var myNewChart = new Chart(ctx).Line(chart_data, chart_options);
}
