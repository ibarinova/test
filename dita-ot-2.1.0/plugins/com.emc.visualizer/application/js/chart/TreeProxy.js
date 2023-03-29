var TreeProxy = (function () {
    var instance;

    function Nested() {
        var loader = new Loader(),
            tree = TreeChart.getInstance();

        this.zoomOut = tree.zoomOut;
        this.zoomIn = tree.zoomIn;
        this.updateHighlighting = tree.updateHighlighting;

        this.init = tree.init;

        this.onIshconditionChange = function (condition) {
            var fn = tree.onIshconditionChange.bind(null, condition);
            loader.wait(fn, Shared.duration);
        };

        this.expandTree = function () {
            loader.wait(tree.expandTree, Shared.duration);
        };

        this.collapseTree = function () {
            loader.wait(tree.collapseTree, Shared.duration);
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

