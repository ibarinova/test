function CacheEngine(options) {
    var data = options.data,
        ishData = options.ishData,
        parser = options.parser,
        cacheData = getDataArray(data, byIshconditionAndBrokenTypeQuery),
        allNodesWithId = getDataArray(data, withNotEmptyId);

    this.getIshconditions = function () {
        return parser.getIshconditions();
    };

    this.getIshconditionMap = function () {
        var nodesWithIshcondition = _.filter(cacheData, function (item) {
                return item.ishcondition != "";
            }),
            nodesWithEmptyIds = _.where(nodesWithIshcondition, {id: ""}),
            childrenIdsOfNodesWithEmptyId = getNodesIdsArray(nodesWithEmptyIds),
            nodeIds = getAllIshconditionNodesIds(),
            cachedDataFromIshConditionJson = getDataArray(ishData, byRefIDQuery.bind(null, nodeIds));

        function getNodesIdsArray(nodes) {
            var ids = [];
            _.each(nodes, function (node) {
                ids = _.union(ids, _.pluck(node.children || node._children, "id"));
            });
            return ids;
        }

        function getAllIshconditionNodesIds() {
            return _.union(_.pluck(nodesWithIshcondition, "id"), childrenIdsOfNodesWithEmptyId);
        }

        return _.chain(nodesWithIshcondition)
            .each(function (node) {
                if (node.id) {
                    node.ishconditionChild = _.where(cachedDataFromIshConditionJson, {refId: node.id})
                } else {
                    node.nestedIshconditionChildren = node.children || node._children;
                    _.each(node.nestedIshconditionChildren, function (obj) {
                        obj.ishconditionChild = _.where(cachedDataFromIshConditionJson, {refId: obj.id})
                    });
                }
            })
            .groupBy(function (node) {
                return node.ishcondition;
            })
            .value();
    };

    this.getNodeIdMap = function () {
        return _.groupBy(allNodesWithId, function (node) {
            return node.id;
        });
    };

    this.getLTypeMap = function () {
        var ltypes = ["conref", "xref-internal", "topicref"],
            nodes = getDataArray(data, byLType.bind(null, ltypes));

        return _.groupBy(nodes, function (node) {
            return node.ltype;
        });
    };

    this.getIshconditionIshNodesMap = function () {
        var types = ["B", "M", "RT", "E"],
            nodes = getDataArray(data, topicrefsWithoutTypes.bind(null, types)),
            hrefGroupedNodes = groupByHref(nodes),
            ishNodesWithHref = getDataArray(ishData, withChildrenAndNotEmptyHref);

        return _.chain(ishNodesWithHref)
            .filter(function (node) {
                return !_.isEmpty(hrefGroupedNodes[node.href]);
            })
            .map(function (node) {
                var chartNode = hrefGroupedNodes[node.href],
                    id = _.pluck(chartNode, "id")[0];
                return getDataArray(node, insertChartNodeIds.bind(null, id));
            })
            .flatten(true)
            .filter(function (node) {
                return node.ishcondition;
            })
            .groupBy(function (node) {
                return node.ishcondition;
            })
            .value();
    };

    function getDataArray(data, criteriaFn) {
        return getArray(data.children);

        function getArray(data) {
            var result = [];

            !function getArrayOfObjects(data) {
                result = _.union(result, _.isFunction(criteriaFn) ? criteriaFn(data) : data);
                _.each(data, function (child) {
                    var nestedChildren = child.children || child._children;
                    if (!_.isEmpty(nestedChildren)) {
                        getArrayOfObjects(nestedChildren);
                    }
                })
            }(data);

            return result
        }
    }

    function groupByHref(nodes) {
        return _.groupBy(nodes, function (node) {
            return node.href;
        });
    }

    function byIshconditionAndBrokenTypeQuery(nodes) {
        return _.filter(nodes, function (node) {
            return $.trim(node.ishcondition) != "" || node.type == "broken";
        });
    }

    function byRefIDQuery(ids, nodes) {
        return _.filter(nodes, function (node) {
            var refId = node.refId;
            return refId != "" && ids.indexOf(refId) != -1;
        });
    }

    function withNotEmptyId(nodes) {
        return _.filter(nodes, function (node) {
            return node.id != "";
        });
    }

    function byLType(ltypes, nodes) {
        return _.filter(nodes, function (node) {
            var ltype = node.ltype;
            return ltype != "" && ltypes.indexOf(ltype) != -1;
        })
    }

    function topicrefsWithoutTypes(types, nodes) {
        return _.filter(nodes, function (node) {
            return node.ltype == "topicref" && types.indexOf(node.type) == -1;
        });
    }

    function withChildrenAndNotEmptyHref(nodes) {
        return _.filter(nodes, function (node) {
            return node.href && node.href != "" && !_.isEmpty(node.children);
        });
    }

    function insertChartNodeIds(id, nodes) {
        return _.map(nodes, function (node) {
            node.chartNodeId = id;
            return node;
        });
    }
}
