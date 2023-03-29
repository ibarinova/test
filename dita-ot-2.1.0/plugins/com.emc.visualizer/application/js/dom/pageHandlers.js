function Buttons() {
}

Buttons.registerHandlers = function () {
    var chartProxy = TreeProxy.getInstance(),
        resetButton = $("#resetBtn"),
        chartExpandBtn = $("#expandBtn"),
        chartCollapseBtn = $("#collapseBtn"),
        chartZoomOutBtn = d3.select("#zoomOutBtn"),
        chartZoomInBtn = d3.select("#zoomInBtn"),
        conditionCheckboxes = $("#conditions-container")
            .find(":checkbox");

    !function addChartHandlers() {
        chartExpandBtn.on("click", chartProxy.expandTree);
        chartCollapseBtn.on("click", chartProxy.collapseTree);
        chartZoomOutBtn.on("click", chartProxy.zoomOut);
        chartZoomInBtn.on("click", chartProxy.zoomIn);
    }();

    !function addIshconditionHandler() {
        conditionCheckboxes
            .change(function () {
                var checkbox = $(this),
                    currentCondition = checkbox.attr("id"),
                    conditions = Shared.ishconditions();

                conditions[currentCondition] = checkbox.prop("checked");
                chartProxy.onIshconditionChange(currentCondition);
            })
    }();

    !function initResetPageButton() {
        resetButton.on('click', function () {
            location.reload();
        })
    }();
};

function renderDataForInfoSection() {
    var container = $("#conditions-container"),
        singleIshconditions = _.keys(Shared.ishconditions()),
        template = getInfoSectionTemplate();
    container.append(template({collection: singleIshconditions}));


    function getInfoSectionTemplate() {
        return _.template(
            "<% _.each(collection, function(item) { %>" +
            "<div class='checkbox'>" +
            "<label>" +
            "<input type='checkbox' id='<%- item%>' checked><%= item%>" +
            "</label>" +
            "</div>" +
            "<% }) %>");
    }
}

function insertPublicationTitle() {
    $(".js-publication-title").html(publicationTitle);
}

function showEqualConrefsCount(count) {
    var attributeContainer = $("#attributes-panel");
    attributeContainer.find("#conrefCount").remove();
    attributeContainer.prepend("<div id = 'conrefCount' class='col-md-12'><b>Number of equal conrefs:</b> " + count + "</div>")
}

function removeConrefSection() {
    var attributeContainer = $("#attributes-panel");
    attributeContainer.find("#conrefCount").remove();
}

function showNodeInfo(d) {
    var attributeContainer = $("#attributes-panel"),
        metaData = d.meta,
        innerIshConditions = d["nested-ishconditions"],
        conditionTemplate = getInnerIshConditionTemplate();
    attributeContainer.find("#guid").html(d.id);
    attributeContainer.find("#ftitle").html(metaData.ftitle);
    attributeContainer.find("#topicTitle").html(d.title);
    attributeContainer.find("#shortDesc").html(metaData.shortdesc);
    attributeContainer.find("#lcaVersion").html(metaData.LCAversion);
    attributeContainer.find("#lcaRevision").html(metaData.LCArevision);
    attributeContainer.find("#lcaStatus").html(metaData.LCAstatus);
    attributeContainer.find("#ishcondition").html(d.ishcondition);
    attributeContainer.find("#reference").html(d.href);
    attributeContainer.find("#innerIshconditions").html(conditionTemplate({
        collection: innerIshConditions
    }));

    function getInnerIshConditionTemplate() {
        return _.template(
            "<ul>" +
            "<% _.each(collection, function(item) { %>" +
            "<li><%= item.ishcondition%></li>" +
            "<% }) %>" +
            "</ul>");
    }

}
