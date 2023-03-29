function TreeMarker() {
    this.appendTo = appendMarkers;

    function appendMarkers(svg) {
        var arrows = [
            {
                name: 'arrow-circle'
            },
            {
                name: 'arrow-square'
            },
            {
                name: 'arrow-triangle-up'
            },
            {
                name: 'arrow-diamond'
            }];

        svg.append("svg:defs").selectAll("marker")
            .data(arrows)
            .enter()
            .append("svg:marker")
            .attr({
                id: getID,
                viewBox: "0 -5 10 10",
                refX: getRefX,
                refY: getRefY,
                markerWidth: 6,
                markerHeight: 6,
                markerUnits: "userSpaceOnUse"
            })
            .classed("marker", true)
            .style("stroke-width", "0")/*For IE*/
            .append("svg:path")
            .attr("d", "M0,-5L10,0L0,5");
    }

    function getID(d) {
        var name = d.name;

        if (name == "arrow-square") {
            return "marker-arrow-square";
        } else if (name == "arrow-circle") {
            return "marker-arrow-circle";
        } else if (name == "arrow-diamond") {
            return "marker-arrow-diamond";
        } else {
            return "marker-arrow-triangle-up";
        }
    }

    function getRefX(d) {
        var name = d.name;
        if (name == "arrow-square") {
            return -55;
        } else if (name == "arrow-circle") {
            return -34;
        } else if (name == "arrow-diamond") {
            return -27;
        } else {
            return -30;
        }
    }

    function getRefY(d) {
        var name = d.name;
        if (name == "arrow-square" || name == "arrow-triangle-up") {
            return -24;
        } else if (name == "arrow-diamond") {
            return -34;
        } else {
            return 27;
        }
    }
}
