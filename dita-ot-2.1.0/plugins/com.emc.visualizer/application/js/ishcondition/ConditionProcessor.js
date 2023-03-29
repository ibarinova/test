function ConditionProcessor() {
    var conditionParser = ConditionParser.getInstance();

    this.updateNodes = function (condition) {
        var nodesWithCondition = conditionParser.getNodesWithCondition(Shared.ishConditionMap(), condition),
            nodesArray = _.flatten(nodesWithCondition, true);

        _.each(nodesArray, toggleNodes);
    };

    function toggleNodes(node) {
        var matchIshcondition = conditionParser.matchIshcondition(node.ishcondition);
        if (!matchIshcondition) {
            hideNode(node);
            markNodesAsBroken(node, _.compose(setBrokenType, stashChildren));
        } else {
            showNode(node);
            markNodesAsValid(node, _.compose(setInitialType, unStashChildren));
        }
    }

    function markNodesAsBroken(node, callback) {
        if (!node.id) {
            markNodesWithoutId(node, callback);
        } else {
            markNodesWithId(node, callback);
        }
    }

    function markNodesAsValid(node, callback) {
        if (!node.id) {
            markNodesWithoutId(node, callback);
        } else {
            markNodesWithId(node, callback);
        }
    }

    function markNodesWithoutId(node, callback) {
        var nestedIshconditionChildren = node.nestedIshconditionChildren;
        if (!_.isEmpty(nestedIshconditionChildren)) {
            _.each(nestedIshconditionChildren, function (obj) {
                markAllChildren(obj.ishconditionChild, callback);
            })
        }
    }

    function markNodesWithId(node, callback) {
        var ishNodes = node.ishconditionChild;
        _.each(ishNodes, function (ishNode) {
            var children = ishNode.children;
            if (!_.isEmpty(children)) {
                markAllChildren(children, callback)
            }
        });
    }

    function markAllChildren(nodes, callback) {
        _.each(nodes, function (node) {
            markNodeChildren(node, callback);

            var innerChildren = node.children;
            if (!_.isEmpty(innerChildren)) {
                markAllChildren(innerChildren, callback);
            }
        })
    }

    function markNodeChildren(node, callback) {
        var nodeIdMap = Shared.nodeIdMap(),
            innerNodes = nodeIdMap[node.id];

        if (!_.isEmpty(innerNodes)) {
            _.each(innerNodes, function (obj) {
                if (canMarkNode(obj, node)) {
                    callback(obj);
                }
            })
        }
    }

    function canMarkNode(obj, node) {
        return !isNodeHidden(obj) && obj.fullHref == node.fullHref && obj.ltype != "topicref";
    }

    function hideNode(node) {
        if (!isNodeHidden(node)) {
            var children = node.children || node._children;
            if (children) {
                _.each(children, hideNode);
            }
            hide(node);
        }
    }

    function showNode(node) {
        if (isNodeHidden(node)) {
            var children = node.children || node._children;
            if (children) {
                _.each(children, showNode);
            }
            show(node)
        }
    }

    function hide(node) {
        if (!isBroken(node)) {
            node.hidden = "hidden";
        }
    }

    function show(node) {
        node.hidden = "";
    }

    function isNodeHidden(node) {
        return node.hidden;
    }

    function isBroken(node) {
        return node._type;
    }

    function setBrokenType(node) {
        if (!isBroken(node)) {
            node._type = node.type;
            node.type = "broken";
        }
        return node;
    }

    function setInitialType(node) {
        if (isBroken(node)) {
            node.type = node._type;
            node._type = null;
        }
        return node;
    }

    function stashChildren(node) {
        if (!node.brokenChildren) {
            if (node.children) {
                node.brokenChildren = node.children;
                node.children = null;
            }
            else if (node._children) {
                node.brokenChildren = node._children;
                node._children = null;
            }
        }
        return node;

    }

    function unStashChildren(node) {
        if (node.brokenChildren) {
            node.children = node.brokenChildren;
            node.brokenChildren = null;
        }
        return node;
    }
}
