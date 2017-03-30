var w = 1300;  //1100
var h = 900;  //700

var color = d3.scale.ordinal()
              .domain([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17])
              .range([ "#FFFFFF", // 1-Wht     Default/ Cube Structure
                       "#00FF00", // 2-BrGre   Atributes
                       "#99FF99", // 3-LtGre   Atribute link
                       "#FF0000", // 4-BrRed   Measure
                       "#FA7D7D", // 5-LtRed   Measure link
                       "#0000FF", // 6-BrBlu   Dimension
                       "#8080FF", // 7-LtBlu   Dimension link
                       "#FF6600", // 8-BrOr    CodeLists
                       "#FFB280", // 9-LtOr    CodeLists link
                       "#CC00FF", // 10-BrPur  CDISC
                       "#EB99FF", // 11-LtPur  CDISC link
                       "#FFFF00", // 12-BrYel  Observations
                       "#FFFF80", // 13-LtYel  Observations link
                       "#006666", // 14-SlGre   Cube Struct
                       "#99C2C2", // 15-LtSlGre Cube Struct Link
                       "#666699", // 16-BlGry  SKOS
                       "#A3A3C2"  // 17-LtBlGr SKOS Link
                       
                       ]);

//Width and height for SVG area
var svg = d3.select("body").append("svg")
            .attr("width", w)
            .attr("height", h)
            //.attr("viewBox", "0 0 2500 2500")
            .style("background-color", '#002b36');


  // Double click to 'unfix' the node and have forces start to act on it again.
  function dblclick(d) {
    d3.select(this).classed("fixed", d.fixed = false);
  }
  // Set the "fixed" property of the dragged node to TRUE when a dragstart event is initiated,
  //   - removes "forces" from acting on that node and changing its position.
  function dragstart(d) {
    d3.select(this).classed("fixed", d.fixed = true);
  }
