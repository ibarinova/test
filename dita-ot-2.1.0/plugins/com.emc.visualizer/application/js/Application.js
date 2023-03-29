function Application() {
    this.run = function () {
        ConditionParser.setConfig(getParserConfig());
        window.Shared = Shared.getInstance();
        renderDataForInfoSection();
        insertPublicationTitle();
        var chartProxy = TreeProxy.getInstance();
        chartProxy.init();
        Buttons.registerHandlers();
    };

    function getParserConfig() {
        return {
            operators: {
                addBinary: ["and", "AND", "or", "OR", "in"],
                removeBinary: [">=", ">", "<=", "<", "==", "+", "-"]
            },
            customIdentifiers: ["<", ">", "=", "+", "-", ",", ".", ";", "&"]
        };
    }
}
