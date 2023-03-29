function TreeLink() {
    this.render = render;

    var diagonal = d3.svg.diagonal()
            .projection(function (d) {
                return [d.y, d.x];
            }),
        duration = Shared.duration;

    function render(options) {
        var link = options.link,
            root = options.root;
        linkEnter(link, root);
        linkUpdate(link);
        linkExit(link, root);
    }

    function linkEnter(link, root) {
        // Enter any new links at the parent's previous position.

        link.enter()
            .insert("svg:path", "g")
            .attr("class", "js-link")
            .attr("stroke", getStroke)
            .attr("stroke-dasharray", getStrokeDasharray)
            .attr("d", function (d) {
                var o = {x: root.x0, y: root.y0};
                return diagonal({source: o, target: o});
            })
            .transition()
            .duration(duration)
            .attr("d", diagonal);

        function getStroke(d) {
            var ltype = d.target.ltype;
            if (ltype.indexOf("xref") >= 0) {
                return "#2C95DD";
            }
            else if (ltype == "conref") {
                return "green";
            } else {
                return "black"
            }
        }

        function getStrokeDasharray(d) {
            var ltype = d.target.ltype,
                solidPattern = "",
                dottedPattern = "3 3",
                dashedPattern = "8 8",
                dashDottedPattern = "8 3 3 3";

            if (ltype.indexOf("xref") >= 0) {
                return dottedPattern;
            }
            else if (ltype == "rel-topicref") {
                return dashedPattern;
            }
            else if (ltype == "conref") {
                return dashDottedPattern;
            } else {
                return solidPattern;
            }
        }
    }

    function linkUpdate(link) {
        // Transition links to their new position.
        link.transition()
            .duration(duration)
            .attr("d", diagonal);
    }

    function linkExit(link, root) {
        // Transition exiting nodes to the parent's new position.
        link.exit().transition()
            .duration(duration)
            .attr("d", function (d) {
                var o = {x: root.x, y: root.y};
                return diagonal({source: o, target: o});
            })
            .remove();
    }
}
