function IshNodeConditionProcessor() {
    var parser = ConditionParser.getInstance();

    this.updateNodes = function (condition) {
        var nodes = getNodesToCheck(condition),
            allNodes = _.flatten(nodes, true),
            groupedByChartNodeId = groupByChartNodeId(allNodes);

        _.each(groupedByChartNodeId, markNodes);
    };

    function getNodesToCheck(currentIshcondition) {
        var ishconditionMap = Shared.ishconditionIshNodesMap(),
            allIshconditions = Shared.ishconditions(),
            nodes = [];

        _.each(allIshconditions, function (isEnabled, ishcondition) {
            if (!isEnabled) {
                var nodesWithCondition = parser.getNodesWithCondition(ishconditionMap, ishcondition);
                nodes = _.union(nodes, nodesWithCondition);
            }
        });
        if (_.isEmpty(nodes)) {
            nodes = parser.getNodesWithCondition(ishconditionMap, currentIshcondition);
        }
        return nodes;
    }

    function groupByChartNodeId(nodes) {
        return _.groupBy(nodes, function (node) {
            return node.chartNodeId;
        });
    }

    function markNodes(nodes, chartNodeId) {
        var brokenIshNode = _.find(nodes, function (node) {
                return !parser.matchIshcondition(node.ishcondition);
            }),
            isBroken = !_.isEmpty(brokenIshNode);

        toggleBrokenIshNode(isBroken, chartNodeId);
    }

    function toggleBrokenIshNode(isBroken, chartNodeId) {
        var nodeIdMap = Shared.nodeIdMap(),
            nodes = nodeIdMap[chartNodeId];

        _.each(nodes, isBroken ? addBrokenIshNode : removeBrokenIshNode);
    }

    function addBrokenIshNode(node) {
        node.hasBrokenIshNode = true;
    }

    function removeBrokenIshNode(node) {
        if (node.hasBrokenIshNode) {
            node.hasBrokenIshNode = false;
        }
    }
}
