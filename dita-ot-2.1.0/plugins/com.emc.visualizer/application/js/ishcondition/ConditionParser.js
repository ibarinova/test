var ConditionParser = (function () {
    var instance,
        config;

    function Nested(config) {

        this.matchIshcondition = function (condition) {
            var expression = parseIshcondition(condition);
            return eval(expression);
        };

        this.getIshconditions = function () {
            var array = getArrayWithSingleIshconditions(setOfIshconditions);

            return array.reduce(function (obj, field) {
                obj[field] = true;
                return obj;
            }, {});
        };

        this.getNodesWithCondition = function (nodes, condition) {
            return _.filter(nodes, function (obj, ishcondition) {
                var regExp = new RegExp("(\\(|^|\\s)(" + condition + ")(\\)|$|\\s)", "g"),
                    inCauseRegExp = /\Win\W/g;
                return regExp.test(ishcondition) || inCauseRegExp.test(ishcondition);
            });
        };

        function getArrayWithSingleIshconditions(array) {
            return $.map(array, function (value) {
                var ishcondition = value.ishcondition,
                    parsedIshconditions = replaceInOperators(ishcondition),
                    expression = jsep(parsedIshconditions);

                return getIshconditionArray(expression);
            });
        }

        function getIshconditionArray(expression) {
            var array = [];

            !function parseExpression(expression) {
                var type = expression.type;
                if (type == "BinaryExpression") {

                    parseExpression(expression.left);
                    parseExpression(expression.right);
                } else {
                    array.push(expression.name);
                }
            }(expression);
            return array;
        }

        function parseIshcondition(ishcondition) {
            ishcondition = replaceInOperators(ishcondition);

            _.each(Shared.ishconditions(), function (key, value) {
                if (ishcondition.indexOf(value) >= 0) {
                    var regExp = new RegExp("(\\(|^|\\s)(" + value + ")(\\)|$|\\s)", "g");
                    ishcondition = ishcondition.replace(regExp, "$1" + key + "$3");
                }
            });
            ishcondition = ishcondition.replace(/or/gi, "||");
            ishcondition = ishcondition.replace(/and/gi, "&&");
            return ishcondition;
        }

        function replaceInOperators(ishcondition) {
            var inCauseRegExp = /\Win\W/g;
            if (!inCauseRegExp.test(ishcondition)) {
                return ishcondition;
            }
            var inExpressionRegExp = /(\w+)\s(\bin\b)\s+\(([\w,&;]+)\)/g;
            return ishcondition.replace(inExpressionRegExp, function (match, g1, g2, g3) {
                var result = "",
                    rightConditionArray = g3.split(",");

                _.each(rightConditionArray, function (condition) {
                    if (result) {
                        result += " or ";
                    }
                    result += g1 + "=" + condition;
                });

                return "(" + result + ")";
            });
        }

        !function addOperatorsToJSEP(operators) {
            _.each(operators, function (operator) {
                jsep.addBinaryOp(operator, 10);
            });
        }(config.operators.addBinary);

        !function removeOperatorsFromJSEP(operators) {
            _.each(operators, function (operator) {
                jsep.removeBinaryOp(operator);
            });
        }(config.operators.removeBinary);


        !function addCustomIdentifiersToJSEP(identifiers) {
            _.each(identifiers, function (identifier) {
                jsep.addCustomIdentifierPart(identifier.charCodeAt(0));
            });
        }(config.customIdentifiers);

    }

    return {
        getInstance: function () {
            if (!instance) {
                instance = new Nested(config);
            }
            return instance;
        },
        setConfig: function (conf) {
            config = conf;
        }
    }
})();

