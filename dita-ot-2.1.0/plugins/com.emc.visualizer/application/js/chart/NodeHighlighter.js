function NodeHighlighter() {
    var lTypeMap = Shared.ltypeMap(),
        previousSelections = [],
        conrefLType = "conref",
        xrefLType = "xref-internal",
        topicrefLType = "topicref",
        relTopicrefLType = "rel-topicref",
        elementType = "E";

    this.markNodes = function (node) {
        clearPreviousSelection();
        removeConrefSection();
        markToSelected(node);
        previousSelections.push(node);
        if (hasNodeIDAndFullHref(node)) {
            markEqualNodes(node);
        }
        TreeProxy.getInstance().updateHighlighting();
    };

    this.markRootNode = function (node) {
        clearPreviousSelection();
        markToSelected(node);
        previousSelections.push(node);
    };

    function hasNodeIDAndFullHref(node) {
        return node.id && node.fullHref;
    }

    function clearPreviousSelection() {
        _.each(previousSelections, function (node) {
            node.selected = false;
        });
        previousSelections = [];
    }

    function markToSelected(node) {
        node.selected = true;
    }

    function markEqualNodes(node) {
        var lType = node.ltype,
            type = node.type,
            fullHref = node.fullHref;

        if ((lType == xrefLType || lType == conrefLType || lType == relTopicrefLType)) {
            if (type == elementType && lType == xrefLType) {
                markNodes(lTypeMap[topicrefLType], fullHref.match(/^(.*\..*#.*)\/.*$/)[1]);
            }
            else if (lType == conrefLType) {
                if (type == elementType) {
                    markNodes(lTypeMap[topicrefLType], fullHref.match(/^(.*\..*#.*)\/.*$/)[1]);
                    markNodes(lTypeMap[conrefLType], fullHref);
                } else {
                    markNodes(lTypeMap[conrefLType], fullHref);
                }
            } else {
                markNodes(lTypeMap[topicrefLType], fullHref);
            }

            if (type == elementType && lType == conrefLType) {
                displayNumberOfEqualConrefs(lTypeMap[lType], fullHref);
            }
        }

        function markNodes(nodes, fullHref) {
            if (!_.isEmpty(nodes)) {
                var nodesToHighlight = _.where(nodes, {fullHref: fullHref});
                _.each(nodesToHighlight, function (node) {
                    markToSelected(node);
                    expand(node);
                    previousSelections.push(node);
                });
            }
        }

        function expand(node) {
            var unStashedNode = getUnStashedNode(node),
                parent = unStashedNode.parent;
            if (parent) {
                if (parent._children) {
                    parent.children = parent._children;
                    parent._children = null;
                }
                expand(parent);
            }
        }

        function getUnStashedNode(node) {
            if (node._parent) {
                node.parent = node._parent;
                return node;
            }
            return node;
        }

        function displayNumberOfEqualConrefs(nodes, fullHref) {
            var count = _.where(nodes, {fullHref: fullHref}).length;
            showEqualConrefsCount(count);
        }
    }
}
