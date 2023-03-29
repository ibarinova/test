function TreeNode(callbacksObj) {
    var callbacks = callbacksObj,
        symbolSize = getSymbolSize,
        tooltip = new NodeTooltip(),
        nodeHighlighter = new NodeHighlighter(),
        duration = Shared.duration,
        nodeColorScale = d3.scale.ordinal()
            .domain(["B", "M", "C", "T", "R", "G", "CLI", "E", "I", "gT", "broken", "mail", "CH", "A", "P", "RT"])
            .range(["#ffff66", "#ffff66", "#6699ff", "#73c666", "#ffa956", "#d370d3", "#d3d3d3", "pink", "white", "#bd7e4a",
                "white", "white", "white", "white", "white", "#ffff66"]);

    this.render = render;
    this.onCollapse = function () {
        nodeHighlighter.markRootNode(Shared.data);
    };

    function render(options) {
        var node = options.node,
            root = options.root;

        nodeEnter(node, root);
        nodeUpdate(node);
        nodeExit(node, root);
    }

    function nodeEnter(node, root) {
        // Enter any new nodes at the parent's previous position.
        var nodeEnter = node.enter()
            .append("svg:g")
            .classed("js-node", true)
            .attr("transform", function () {
                return "translate(" + root.y0 + "," + root.x0 + ")";
            })
            .on("dblclick", function (d) {
                if (nodeHasChildren(d)) {
                    callbacks.enterCallback(d);
                }
            })
            .on("click", function (d) {
                nodeHighlighter.markNodes(d);
                showNodeInfo(d);
            })
            .on("mouseover", tooltip.init);

        nodeEnter.append("svg:path")
            .call(pathCreateBehaviour);

        nodeEnter.append("svg:text")
            .call(textCreateBehaviour);

        function nodeHasChildren(d) {
            return (d.children && d.children.length) || d._children;
        }
    }

    function nodeUpdate(node) {
        node
            .transition()
            .duration(duration)
            .attr("transform", function (d) {
                return "translate(" + d.y + "," + d.x + ")";
            });

        node.select("path.js-path")
            .call(addMarkerEnd)
            .filter(getNodesToUpdate)
            .call(pathUpdateBehaviour);

        node.select("text")
            .filter(getNodesToUpdate)
            .call(textUpdateBehaviour);

        function addMarkerEnd() {
            this.attr("marker-end", function (d) {
                if (isNodeCollapsed(d)) {
                    var type = d.type;
                    if (type == "M" || type == "B") {
                        return "url(#marker-arrow-square)";
                    } else if (type == "CH" || type == "A" || type == "P") {
                        return "url(#marker-arrow-triangle-up)";
                    } else if (type == "RT") {
                        return "url(#marker-arrow-diamond)";
                    } else {
                        return "url(#marker-arrow-circle)";
                    }
                }
                else {
                    return null;
                }
            });
        }

        function isNodeCollapsed(d) {
            return (!d.children || !d.children.length) && (d._children && d._children.length);
        }

        function getNodesToUpdate(node) {
            return node._type !== undefined || node.hidden !== undefined
                || node.selected !== undefined || node.hasBrokenIshNode !== undefined;
        }
    }

    function nodeExit(node, root) {
        var nodeExit = node.exit();

        nodeExit.transition()
            .duration(duration)
            .attr("transform", function () {
                return "translate(" + root.y + "," + root.x + ")";
            })
            .remove();

        nodeExit.select("text")
            .style("fill-opacity", 0);

        setTimeout(function () {
            nodeExit.forEach(function (value) {
                tooltip.destroy(value);
            })
        }, duration)

    }

    function pathCreateBehaviour() {
        this
            .attr("d", getSymbol(symbolSize))
            .classed("black-border", function (d) {
                return !hasNodeImage(d);
            })
            .classed("js-path", true)
            .style("fill", function (d) {
                return nodeColorScale(d.type);
            });
    }

    function pathUpdateBackgroundBehaviour() {
        this
            .attr("d", getSymbol(symbolSize))
            .attr("class", "background")
            .style("fill", "white");
    }

    function pathUpdateBehaviour() {
        this
            .attr("d", function (d) {
                var el = d3.select(this);
                el.attr("d", "");
                var parent = d3.select(this.parentNode);
                parent.selectAll("path.background, .minus-icon").remove();
                insertBackground(parent);
                if (d.hasBrokenIshNode) {
                    appendMinusIcon(parent, d.type);
                }
                return getSymbol(getSymbolSize)(d);
            })
            .classed("active-node", function (d) {
                return d.selected;
            })
            .classed("hidden-node", function (d) {
                return d.hidden == "hidden" && d.type != "broken";
            })
            .classed("black-border", function (d) {
                return !hasNodeImage(d);
            })
            .style("fill", function (d) {
                return nodeColorScale(d.type);
            })
            .style("opacity", function (d) {
                return d.hidden == "hidden" && d.type != "broken" ? 0.25 : 1;
            });
    }

    function textCreateBehaviour() {
        this.text(addSVGText)
            .attr("dy", getDy)
            .attr("y", function (d) {
                if (d.type == "broken") {
                    return 4;
                }
            })
            .style("fill-opacity", 1);

        function getDy(d) {
            var type = d.type;
            if (type == "CH" || type == "A" || type == "P") {
                return 10;
            } else {
                return 5;
            }
        }

    }

    function textUpdateBehaviour() {
        this
            .text(function (d) {
                var parent = d3.select(this.parentNode);

                if (needToRemoveImage(d)) {
                    parent.selectAll(".node-img").remove();
                }
                return addSVGText.call(this, d);

            })
            .attr("y", function (d) {
                if (d.type == "broken") {
                    return 4;
                }
            });

    }

    function insertBackground(parent) {
        parent.insert("svg:path", ":first-child")
            .call(pathUpdateBackgroundBehaviour);
    }

    function appendMinusIcon(parent, type) {
        parent.append("svg:image")
            .attr({
                "xlink:href": "css/images/minus.svg",
                x: (type == "CH" || type == "A" || type == "P") ? -4 : 0,
                y: -20,
                width: 25,
                height: 25,
                "class": "minus-icon"
            });
    }

    function needToRemoveImage(d) {
        return d._type === null;
    }

    function addSVGText(d) {
        var parent = d3.select(this.parentNode);
        if (hasNodeImage(d)) {
            if (noImageAdded(parent)) {
                parent
                    .insert("svg:image", "text")
                    .attr({
                        "xlink:href": getImageByType,
                        x: -18,
                        y: -18,
                        width: 36,
                        height: 36,
                        "class": "node-img"
                    });
            }
        } else {
            return d.type;
        }
    }

    function hasNodeImage(d) {
        var type = d.type;
        return type == "I" || type == "mail" || type == "broken";
    }

    function noImageAdded(parent) {
        return parent.select("image:not(.minus-icon)").empty();
    }

    function getImageByType(d) {
        var type = d.type;
        if (type == "I") {
            return "css/images/web.svg";
        }
        else if (type == "mail") {
            return "css/images/email.svg";
        }
        else if (type == "broken") {
            return "css/images/broken_link_icon.svg";
        }
    }

    function getSymbolSize(d) {
        var type = d.type;
        if (type == "CH" || type == "A" || type == "P" || type == "RT") {
            return 500;
        } else {
            return 800;
        }
    }

    function getSymbol(size) {
        return d3.svg.symbol()
            .size(size)
            .type(function (d) {
                var type = d.type;
                if (type == "M" || type == "B" || type == "mail") {
                    return "square";
                } else if (type == "CH" || type == "A" || type == "P") {
                    return "triangle-up";
                } else if (type == "RT") {
                    return "diamond";
                } else {
                    return "circle";
                }
            });
    }
}