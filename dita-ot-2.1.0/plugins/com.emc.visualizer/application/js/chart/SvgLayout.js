function SvgLayout() {
    var windowHeight = $(window).outerHeight(true),
        chartInfoContainerHeight = $("#chartInfoContainer").outerHeight(true),
        defaultNodeSize = 30,
        svgContainerWidth = $("#svg-container").outerWidth(true),
        svgMargin = 5,
        svgContainerHeight = windowHeight - chartInfoContainerHeight,
        xTranslate = 50,
        svgHeight = svgContainerHeight - svgMargin,
        svgWidth = svgContainerWidth - svgMargin;

    this.getLayoutData = function () {
        return {
            svgContainerHeight: svgContainerHeight,
            svgContainerWidth: svgContainerWidth,
            defaultNodeSize: defaultNodeSize,
            xTranslate: xTranslate,
            svgMargin: svgMargin,
            svgWidth: svgWidth,
            svgHeight: svgHeight
        }
    };

}