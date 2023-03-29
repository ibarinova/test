var TreeChart = (function () {
    var instance;

    function Nested() {

        var json = Shared.data,
            i = 0,
            svg,
            svgGroup,
            treeChart,
            treeNode = new TreeNode({
                enterCallback: function (d) {
                    toggle(d);
                    update(d);
                    centerNode(d);
                }
            }),
            treeLink = new TreeLink(),
            treeMarkers = new TreeMarker(),
            svgLayout = new SvgLayout(),
            conditionProcessor = new ConditionProcessor(),
            isNodeConditionProcessor = new IshNodeConditionProcessor(),
            zoomListener = getZoomListener(),
            zoomOutFactor = 1.2,
            zoomInFactor = 1 / zoomOutFactor,
            layoutData;

        this.init = function () {
            layoutData = svgLayout.getLayoutData();
            svg = appendSVG();
            svgGroup = svg.append("svg:g");
            treeMarkers.appendTo(svg);
            treeChart = buildThree();
            stashParentNodes(treeChart);
            json.children.forEach(toggleAll);

            json.x0 = layoutData.svgHeight / 2;
            json.y0 = 0;

            showNodeInfo(json);
            update(json);
            centerNode(json);
        };

        this.expandTree = function () {
            expandAll(json);
            update(json);
        };

        this.collapseTree = function () {
            collapseAll(json);
            treeNode.onCollapse();
            update(json);
            showNodeInfo(json);
            centerNode(json);
        };

        this.onIshconditionChange = function (condition) {
            conditionProcessor.updateNodes(condition);
            isNodeConditionProcessor.updateNodes(condition);
            update(json);
        };

        this.updateHighlighting = function () {
            update(json);
        };

        this.zoomOut = function () {
            zoomWithButtons(zoomOutFactor);
        };

        this.zoomIn = function () {
            zoomWithButtons(zoomInFactor);
        };

        function zoomWithButtons(factor) {
            d3.event.preventDefault();

            var scale = zoomListener.scale(),
                scaleExtent = zoomListener.scaleExtent(),
                minScale = scaleExtent[0],
                maxScale = scaleExtent[1],
                translate = zoomListener.translate(),
                x = translate[0],
                y = translate[1],
                resultScale = scale * factor,
                boundedResultScale = Math.max(minScale, Math.min(maxScale, resultScale)),
                svgHeight = layoutData.svgHeight,
                svgWidth = layoutData.svgWidth;

            if (isFactorAtLimits()) {
                return false;
            }

            if (boundedResultScale != resultScale) {
                resultScale = boundedResultScale;
                factor = resultScale / scale;
            }

            x = (x - svgWidth / 2) * factor + svgWidth / 2;
            y = (y - svgHeight / 2) * factor + svgHeight / 2;

            zoomListener
                .scale(resultScale)
                .translate([x, y]);

            zoomListener.event(svg);

            function isFactorAtLimits() {
                return resultScale == minScale || resultScale == maxScale;
            }
        }

        function getZoomListener() {
            return d3.behavior.zoom().scaleExtent([0.1, 3]).on("zoom", zoom);
        }

        function appendSVG() {
            var svgHeight = layoutData.svgHeight,
                svgWidth = layoutData.svgWidth;
            return d3.select("#svg-container")
                .style("height", layoutData.svgContainerHeight + "px")
                .append("svg:svg")
                .attr("width", svgWidth + "px")
                .attr("height", svgHeight + "px")
                .attr("viewBox", "0 0 " + svgWidth + " " + svgHeight)
                .attr("preserveAspectRatio", "xMinYMin meet")
                .call(zoomListener)
                .on("dblclick.zoom", null);
        }

        function buildThree() {
            var defaultNodeSize = layoutData.defaultNodeSize;
            return d3.layout
                .tree()
                .nodeSize([defaultNodeSize, defaultNodeSize])
                .separation(function separation(a, b) {
                    return 1.5;
                });
        }

        function zoom() {
            svgGroup.attr("transform", "translate(" + d3.event.translate + ")scale(" + d3.event.scale + ")");
        }

        function update(root) {
            // Compute the new tree layout.
            var nodes = treeChart
                .nodes(json);

            // Normalize for fixed-depth.
            nodes.forEach(function (d) {
                d.y = d.depth * 200;
            });

            var node = svgGroup.selectAll("g.js-node")
                .data(nodes, function (d) {
                    return d.uuID || (d.uuID = ++i)
                });

            treeNode.render({
                node: node,
                root: root
            });

            // Update the links…
            var links = treeChart.links(nodes);

            var link = svgGroup.selectAll("path.js-link")
                .data(links, function (d) {
                    return d.target.uuID;
                });

            treeLink.render({
                link: link,
                root: root
            });

            // Stash the old positions for transition.
            nodes.forEach(function (d) {
                d.x0 = d.x;
                d.y0 = d.y;
            });

        }

        function toggle(d) {
            if (d.children) {
                d._children = d.children;
                d.children = null;
            } else {
                d.children = d._children;
                d._children = null;
            }
        }

        function stashParentNodes() {
            var nodes = treeChart.nodes(json);
            _.each(nodes, function (node) {
                node._parent = node.parent
            });
        }

        function toggleAll(d) {
            if (d.children) {
                d.children.forEach(toggleAll);
                toggle(d);
            }
        }

        function expand(d) {
            if (d._children) {
                toggle(d);
            }
        }

        function expandAll(d) {
            expand(d);
            if (d._children) {
                d._children.forEach(expandAll);
            }
            else if (d.children) {
                d.children.forEach(expandAll);
            }
        }

        function collapse(d) {
            if (d.children) {
                toggle(d);
            }
        }

        function collapseAll(d) {
            if (d.children) {
                d.children.forEach(collapseAll);
                collapse(d);
            }
        }

        function centerNode(node) {
            var scale = zoomListener.scale(),
                x = layoutData.xTranslate,
                y = -node.x0;

            y = y * scale + layoutData.svgHeight / 2;
            svgGroup.transition()
                .duration(Shared.duration)
                .attr("transform", "translate(" + x + "," + y + ")scale(" + scale + ")");
            zoomListener.translate([x, y]);
        }
    }

    return {
        getInstance: function () {
            if (!instance) {
                instance = new Nested();
            }
            return instance;
        }
    }
})();

