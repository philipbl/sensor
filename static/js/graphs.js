Chart.defaults.global.responsive = true;
// Chart.defaults.global.showTooltips = false;

temperature_color = "#F44336";
humidity_color = "#2196F3";

queue()
    .defer(d3.json, "http://127.0.0.1:5000/sensor/status")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/summary")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/minute?duration=60")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/hour?duration=12")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/hour?duration=24")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/hour?duration=168&interval=3")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/hour?duration=720&interval=12")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/stats/day?duration=365&interval=1")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/average/day")
    .defer(d3.json, "http://127.0.0.1:5000/sensor/average/week")
    .await(makeGraphs);


function makeGraphs(error, status, summary, last_hour, twelve_hour, twentyfour_hour, week, month, year, average_day, average_week) {
    makeUpdateText(status);
    makeSummaryBox(summary);
    makeLastHourBox(last_hour);
    makeTwelveHourBox(twelve_hour);
    makeTwentyFourHourBox(twentyfour_hour);
    makeWeekBox(week);
    makeMonthBox(month);
    makeYearBox(year);
    makeAverageDay(average_day);
    makeAverageWeek(average_week);
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

function makeLastHourBox(data) {
    makeScatterPlot(data, "last-hour-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        // pointDot: false,
        pointDotRadius: 3,
        scaleType: "date",
    });
}

function makeTwelveHourBox(data) {
    makeScatterPlot(data, "twelve-hour-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        // pointDot: false,
        pointDotRadius: 3,
        scaleType: "date",
    });
}

function makeTwentyFourHourBox(data) {
    makeScatterPlot(data, "twentyfour-hour-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        // pointDot: false,
        pointDotRadius: 3,
        scaleType: "date",
    });
}

function makeWeekBox(data) {
    makeScatterPlot(data, "week-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        // pointDot: false,
        pointDotRadius: 3,
        scaleType: "date",
    });
}

function makeMonthBox(data) {
    makeScatterPlot(data, "month-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        // pointDot: false,
        pointDotRadius: 3,
        scaleType: "date",
    });
}

function makeYearBox(data) {
    console.log(data);
    makeScatterPlot(data, "year-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        // pointDot: false,
        pointDotRadius: 3,
        scaleType: "date",
    });
}

function makeAverageDay(data) {
    makeLineGraph(data, "average-day-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        pointDotRadius: 3,
    });
}

function makeAverageWeek(data) {
    makeLineGraph(data, "average-week-chart", temperature_color, humidity_color, {
        scaleShowGridLines : false,
        pointDotRadius: 3,
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
