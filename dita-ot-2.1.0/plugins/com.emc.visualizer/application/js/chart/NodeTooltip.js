function NodeTooltip() {
    var tooltip = $('body').tooltip({
        selector: '[rel=tooltip]',
        container: 'body',
        placement: 'top'
    });

    this.init = function (d) {
        $(this)
            .attr("rel", "tooltip")
            .attr("data-original-title", function () {
                return unescapeString(d.tooltip);
            });
    };

    this.destroy = function (element) {
        $(element).tooltip('destroy');
    }
}

function unescapeString(string) {
    return string.replace(/&amp;/g, '&')
        .replace(/&lt;/g, '<')
        .replace(/&gt;/g, '>')
        .replace(/&quot;/g, '"')
        .replace(/&#039;/g, "'");
}