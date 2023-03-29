function Loader() {
    var fullScreenContainer = $("#wait-div-container"),
        chartContainer = $("#chart-wait-container");

    this.wait = function (func, duration) {
        before();
        _.delay(func, 0);
        _.delay(after, duration);
    };

    function before() {
        fullScreenContainer.css("display", "block");
        chartContainer.css("display", "block");
    }

    function after() {
        fullScreenContainer.css("display", "none");
        chartContainer.css("display", "none");
    }

}