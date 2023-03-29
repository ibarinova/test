var Shared = (function () {
    var instance,
        ishconditionsCache,
        ishConditionMapCache,
        nodeIdMapCache,
        ltypeMapCache,
        ishconditionIshNodesMapCache;

    function Nested() {
        var parser = ConditionParser.getInstance(),
            cache = new CacheEngine({
                data: data,
                ishData: ishData,
                parser: parser
            });

        return {
            duration: d3.event && d3.event.altKey ? 5000 : 500,
            data: data,
            ishconditions: function () {
                if (!ishconditionsCache) {
                    ishconditionsCache = cache.getIshconditions();
                }
                return ishconditionsCache;
            },
            ishConditionMap: function () {
                if (!ishConditionMapCache) {
                    ishConditionMapCache = cache.getIshconditionMap();
                }
                return ishConditionMapCache;
            },
            nodeIdMap: function () {
                if (!nodeIdMapCache) {
                    nodeIdMapCache = cache.getNodeIdMap();
                }
                return nodeIdMapCache;
            },
            ltypeMap: function () {
                if (!ltypeMapCache) {
                    ltypeMapCache = cache.getLTypeMap();
                }
                return ltypeMapCache;
            },
            ishconditionIshNodesMap: function () {
                if (!ishconditionIshNodesMapCache) {
                    ishconditionIshNodesMapCache = cache.getIshconditionIshNodesMap();
                }
                return ishconditionIshNodesMapCache;
            }
        };
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
