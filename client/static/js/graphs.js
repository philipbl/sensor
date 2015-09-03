Chart.defaults.global.responsive = true;
// Chart.defaults.global.showTooltips = false;

temperature_color = "#F44336";
humidity_color = "#2196F3";
base_url = "https://still-sands-8003.herokuapp.com";
loader = '<div class="loader"> \
    <div class="sk-circle"> \
      <div class="sk-circle1 sk-child"></div> \
      <div class="sk-circle2 sk-child"></div> \
      <div class="sk-circle3 sk-child"></div> \
      <div class="sk-circle4 sk-child"></div> \
      <div class="sk-circle5 sk-child"></div> \
      <div class="sk-circle6 sk-child"></div> \
      <div class="sk-circle7 sk-child"></div> \
      <div class="sk-circle8 sk-child"></div> \
      <div class="sk-circle9 sk-child"></div> \
      <div class="sk-circle10 sk-child"></div> \
      <div class="sk-circle11 sk-child"></div> \
      <div class="sk-circle12 sk-child"></div> \
    </div> \
  </div>'


makeGraphs();
setTimeout(updateGraphs, 60000);

function makeGraphs() {
    addLoaders();
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
    makeAllChart();
}

function addLoaders() {
    var $this = $(".chart-stage");
    $this.append(loader);
}

function updateGraphs() {
    makeUpdateText();
    makeSummaryBox();

    setTimeout(updateGraphs, 60000);
}

function makeUpdateText() {
    $.ajax({
        url: base_url + "/sensor/status",
        dataType: "json"
    })
    .done(function (status) {
        var format = d3.time.format("%I:%M %p");
        $(".updated-time").text(format(new Date(status.last_reading)));
        $(".updated").css("opacity", "1");
    });
}

function makeSummaryBox() {
    $.ajax({
        url: base_url + "/sensor/summary?duration=1440",
        dataType: "json"
    })
    .done(function (summary) {
        var format = d3.format(".1f");
        $(".temp-summary .temp").text(format(summary.temperature.current) + "°");
        $(".temp-summary .temp-high").text(format(summary.temperature.max) + "°");
        $(".temp-summary .temp-low").text(format(summary.temperature.min) + "°");

        $(".humidity-summary .humidity").text(format(summary.humidity.current) + "%");
        $(".humidity-summary .humidity-high").text(format(summary.humidity.max) + "%");
        $(".humidity-summary .humidity-low").text(format(summary.humidity.min) + "%");

        // Remove loader
        $("#summary > .loader").remove();

        // Display results
        $(".summary").css("opacity", "1");
    });
}

function makeLastHourBox() {
    $.ajax({
        url: base_url + "/sensor/stats/minutes?duration=60",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#last-hour > .loader").remove();

        makeScatterPlot(data, "last-hour-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            scaleType: "date",
            pointDot : false,
            useUtc: false,
        });
    });
}

function makeTwelveHourBox() {
    $.ajax({
        url: base_url + "/sensor/stats/minutes?duration=720&interval=15",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#twelve-hour > .loader").remove();

        makeScatterPlot(data, "twelve-hour-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            scaleType: "date",
            pointDot : false,
            useUtc: false,
        });
    });
}

function makeTwentyFourHourBox() {
    $.ajax({
        url: base_url + "/sensor/stats/minutes?duration=1440&interval=30",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#twentyfour-hour > .loader").remove();

        makeScatterPlot(data, "twentyfour-hour-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            scaleType: "date",
            pointDot : false,
            useUtc: false,
        });
    });
}

function makeWeekBox() {
    $.ajax({
        url: base_url + "/sensor/stats/hours?duration=168&interval=3",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#week > .loader").remove();

        makeScatterPlot(data, "week-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            scaleType: "date",
            pointDot : false,
            useUtc: false,
        });
    });
}

function makeMonthBox() {
    $.ajax({
        url: base_url + "/sensor/stats/hours?duration=720&interval=12",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#month > .loader").remove();

        makeScatterPlot(data, "month-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            scaleType: "date",
            pointDot : false,
            useUtc: false,
        });
    });
}

function makeYearBox() {
    $.ajax({
        url: base_url + "/sensor/stats/days?duration=365&interval=1",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#year > .loader").remove();

        makeScatterPlot(data, "year-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            scaleType: "date",
            pointDot : false,
            useUtc: false,
        });
    });
}

function makeAverageDay() {
    $.ajax({
        url: base_url + "/sensor/average/day",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#average-day > .loader").remove();

        makeLineGraph(data, "average-day-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            pointDot : false,
        });
    });
}

function makeAverageWeek() {
    $.ajax({
        url: base_url + "/sensor/average/week",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#average-week > .loader").remove();

        makeLineGraph(data, "average-week-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            pointDot : false,
        });
    });
}

function makeAllChart() {
    $.ajax({
        url: base_url + "/sensor/stats/days",
        dataType: "json"
    })
    .done(function (data) {
        // Remove loader
        $("#all > .loader").remove();

        makeScatterPlot(data, "all-chart", temperature_color, humidity_color, {
            // scaleShowGridLines : false,
            scaleShowVerticalLines: false,
            scaleType: "date",
            pointDot : false,
            bezierCurve : false,
            useUtc: false,
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
