define(["options", "dom-sanitizer", "jquery", "nav"], function (options, domSanitizer, $, navConfig) {

    /**
     * The path of the output directory, relative to the current HTML file.
     * @type {String}
     */
    var path2root = null;

    $(document).ready ( function() {
		// $(".wh_publication_toc .title").mouseenter(showTocTooltip);
		// $(".wh_publication_toc .title").mouseleave(removeTocTooltip);

        setTocHeight();

        // [IB] - Load all nested TOC ULs. Added for 'ExpandAll/CollapseAll' functionality
        loadFullTocList($(".wh_publication_toc"));

        // Register the click handler for the TOC
        var topicRefExpandBtn = $(".wh_publication_toc .wh-expand-btn");
        topicRefExpandBtn.click(toggleTocExpand);

        // Register the ckick handler for the TOC 'Expand All' button
        var expandAllBtn = $(".wh_publication_toc #button-expand-action");
        expandAllBtn.removeClass('hidden');
        expandAllBtn.click(function () {
            tocExpandCollapseAll($('#wh_publication_toc'), 'expand');
        });

        // Register the ckick handler for the TOC 'Collapse All' button
        var collapseAllBtn = $(".wh_publication_toc #button-collapse-action");
        collapseAllBtn.click(function () {
            tocExpandCollapseAll($('#wh_publication_toc'), 'collapse');
        });

        /* Toggle expand/collapse on enter and space */
        topicRefExpandBtn.keypress(handleKeyEvent);

        $('.wh_publication_toc').scroll(function() {
            $('.wh_publication_toc .tooltip-container').find(".wh-tooltip").not(".hidden").addClass('hidden');
        });
        $(window).resize(function(){
            setTocHeight();
        });
    });

    function setTocHeight() {
        let tocContainer = $(".wh_publication_toc");
        let topicContainerHeight = $("#topic_content")[0].offsetHeight + 43;
        let contentRowViewHeight = $(window).height() - 90;

        if (topicContainerHeight > contentRowViewHeight) {
            tocContainer.height(topicContainerHeight);
        } else {
            tocContainer.height(contentRowViewHeight);
        }
    }
    /*
     * Display the tooltip for an element in the publication toc.
     */
    function showTocTooltip() {
        // Find the tooltip generated in the toc hierarchy
    	var originalTooltip = $(this).find(".wh-tooltip");
    	if(originalTooltip.length > 0) {
    		// Tooltip exists. Generate a container for the tooltip.
    	    var container = $("<div>",{
        	  class: "wh-tooltip-wrapper",
        	  "data-tooltip-position": $('.wh_publication_toc').attr("data-tooltip-position")
        	});
        	// Clone the tooltip so that when is removed from dom, the original tooltip will not.
        	var tooltip = originalTooltip.clone();
        	tooltip.removeClass("wh-tooltip");
        	tooltip.addClass("wh-toc-tooltip");
        	container.append(tooltip);
    		var top = $(this).offset().top - $("#wh_publication_toc").offset().top;
    		var left = $(this).offset().left - ($("#wh_publication_toc").offset().left + parseInt($("#wh_publication_toc").css("padding-left")));
    	    container.css("position", "absolute").css("top", top).css("left", left).css("width", $(this).width() + left).css("height", $(this).height()).css("float", "left");
    	    domSanitizer.appendHtmlNode(container, $("#wh_publication_toc"));

    	    setTimeout(function(){ $(".wh-toc-tooltip").addClass("wh-display-tooltip"); }, 50);
    	}
    }

    /*
     * Remove the tooltip for an element in the publication toc.
     */
    function removeTocTooltip(){
        $("#wh_publication_toc>.wh-tooltip-wrapper").remove();
    }

    /**
     * Retrieves the path of the output directory, relative to the current HTML file.
     *
     * @returns {*} the path of the output directory, relative to the current HTML file.
     */
    function getPathToRoot() {
        if (path2root == null) {
            path2root = $('meta[name="wh-path2root"]').attr("content");
            if (path2root == null || path2root == undefined) {
                path2root = "";
            }
        }
        return path2root;
    };

    /* 
     * Toggles expand/collapse on enter and space 
     */
    function handleKeyEvent(event) {
        // Enter & Spacebar events
        if (event.which === 13 || event.which === 32) {
            event.preventDefault();
            toggleTocExpand.call(this);
        }
    }

    // Loads all nested TOC ULs.
    function loadFullTocList($root) {
        let tocExpandBtns = $root.find('.wh-expand-btn');

        for (let index = 0; index < tocExpandBtns.length; ++index) {
            const tocExpandBtn = $(tocExpandBtns[index]);
            let topicRef = tocExpandBtn.closest(".topicref");
            var state = topicRef.attr(navConfig.attrs.state);

            loadTopicrefTooltip(topicRef);

            topicRef.hover(toggleTopicrefTooltipShow);
            topicRef.mouseleave(toggleTopicrefTooltipHide);

            if (state === navConfig.states.notReady) {
                retrieveChildNodes(topicRef, 'hide');
                setTimeout(function(){
                    let nestedUl = $(topicRef.parent().get(0)).find('ul')[0];
                    loadFullTocList($(nestedUl));
                },60)
            }
        }
    }

    function tocExpandCollapseAll($root, action) {
        let tocExpandBtns = $root.find('.wh-expand-btn');

        let collapseAllBtn = $(".wh_publication_toc #button-collapse-action");
        let expandAllBtn = $(".wh_publication_toc #button-expand-action");

        if (action === 'expand') {
            expandAllBtn.addClass('hidden');
            collapseAllBtn.removeClass('hidden');
        } else {
            collapseAllBtn.addClass('hidden');
            expandAllBtn.removeClass('hidden');
        }

        for (let index = 0; index < tocExpandBtns.length; ++index) {
            const tocExpandBtn = $(tocExpandBtns[index]);
            let topicRef = tocExpandBtn.closest(".topicref");
            let state = topicRef.attr(navConfig.attrs.state);

            if (action === 'collapse' && state === navConfig.states.expanded) {
                tocExpandBtn.click()
                let nestedUl = $(topicRef.parent().get(0)).find('ul')[0];
                if ($(nestedUl).length) {
                    tocExpandCollapseAll($(nestedUl), action);
                }
            } else if (action === 'expand' && state !== navConfig.states.expanded) {
                tocExpandBtn.click()
                let nestedUl = $(topicRef.parent().get(0)).find('ul')[0];
                if ($(nestedUl).length) {
                    tocExpandCollapseAll($(nestedUl), action);
                }
            }
        }
    }

    function loadTopicrefTooltip(topicRef) {
        let tocId = topicRef.attr(navConfig.attrs.tocID);

        if (tocId != null) {
            var jsonHref = navConfig.jsonBaseDir + "/" + tocId;
            require(
                [jsonHref],
                function(data) {
                    var tooltipContainer = $('.wh_publication_toc .tooltip-container');
                    var shortdescValue = data.shortdesc;

                    let topicTooltip = tooltipContainer.find("[data-toc-id='" + tocId + "']");

                    if (shortdescValue !== undefined && topicTooltip.length === 0) {
                        var tooltipSpan = $('<span class="wh-tooltip hidden"/>').append(shortdescValue);
                        tooltipSpan.attr('data-toc-id', tocId);
                        tooltipContainer.append(tooltipSpan);
                    }
                }
            );
        }
    }

    function toggleTopicrefTooltipShow() {
        let topicId = $(this).attr(navConfig.attrs.tocID);
        let tooltipContainer = $('#wh_publication_toc .tooltip-container');
        let topicTooltip = tooltipContainer.find("[data-toc-id='" + topicId + "']");

        let topicOffsetTop = $(this).offset().top;
        let topicOffsetLeft = $(this).offset().left;
        let topicTitleWidth = $(this).find('.title')[0].offsetWidth;

        if (topicTooltip.length === 1) {
            topicTooltip.removeClass('hidden');
            if ($('html').attr('dir') == 'rtl') {
                topicTooltip.offset({top : topicOffsetTop - 8, left : topicOffsetLeft - topicTooltip[0].offsetWidth});
            } else {
                topicTooltip.offset({top : topicOffsetTop - 8, left : topicOffsetLeft + topicTitleWidth + 30});
            }
        }
    }

    function toggleTopicrefTooltipHide() {
        let topicId = $(this).attr(navConfig.attrs.tocID);
        let tooltipContainer = $('#wh_publication_toc .tooltip-container');
        let topicTooltip = tooltipContainer.find("[data-toc-id='" + topicId + "']");
        if (topicTooltip.length === 1) {
            topicTooltip.addClass('hidden')
        }
    }

    function toggleTocExpand() {

        var topicRef = $(this).closest(".topicref");
        var state = topicRef.attr(navConfig.attrs.state);
        var parentLi = $(this).closest('li');
        var titleLink = $(this).siblings(".title").children("a");
        var titleLinkID = titleLink.attr("id");

        if (state == null) {
            // Do nothing
        } else if (state == navConfig.states.pending) {
            // Do nothing
        } else if (state == navConfig.states.notReady) {
            topicRef.attr(navConfig.attrs.state, navConfig.states.pending);
            parentLi.attr('aria-expanded', 'true');
            $(this).attr("aria-labelledby", navConfig.btnIds.pending + " " + titleLinkID);
            retrieveChildNodes(topicRef, 'show');
        } else if (state == navConfig.states.expanded) {
            topicRef.attr(navConfig.attrs.state, navConfig.states.collapsed);
            $(this).attr("aria-labelledby", navConfig.btnIds.expand + " " + titleLinkID);
            parentLi.attr('aria-expanded', 'false');
        } else if (state == navConfig.states.collapsed) {
            topicRef.attr(navConfig.attrs.state, navConfig.states.expanded);
            $(this).attr("aria-labelledby", navConfig.btnIds.collapse + " " + titleLinkID);
            parentLi.attr('aria-expanded', 'true');
        }
    };

    /**
     * Loads the JS file containing the list of child nodes for the current topic node.
     * Builds the list of child topics element nodes based on the retrieved data.
     *
     * @param topicRefSpan The topicref 'span' element of the current node from TOC / Menu.
     * @param action added in order to hide nested TOC ULs when page is ready.
     */
    function retrieveChildNodes(topicRefSpan, action) {
        var tocId = $(topicRefSpan).attr(navConfig.attrs.tocID);
        if (tocId != null) {
            var jsonHref = navConfig.jsonBaseDir + "/" + tocId;
            require(
                [jsonHref],
                function(data) {
                    if (data != null) {
                        var topics = data.topics;
                        var topicLi = topicRefSpan.closest('li');
                        var topicsUl = createTopicsList(topics);

                        var topicsUlParent = $('<ul role="group"/>');
                        topicsUl.forEach(function(topic){
                            topicsUlParent.append(topic);
                        });
                        if (action === 'hide') {
                            topicsUlParent.addClass('hidden')
                            topicLi.append(topicsUlParent);
                        } else {
                            let topicLiHidden = $(topicLi.find('ul.hidden')[0]);

                            if (topicLiHidden.length) {
                                topicLiHidden.removeClass('hidden');
                            } else {
                                topicLi.append(topicsUlParent);
                            }

                            var titleLink = topicRefSpan.find(".title > a");
                            var titleLinkID = titleLink.attr("id");

                            var expandBtn = topicRefSpan.children('.wh-expand-btn');
                            expandBtn.attr("aria-labelledby", navConfig.btnIds.collapse + " " + titleLinkID);

                            topicRefSpan.attr(navConfig.attrs.state, navConfig.states.expanded);
                        }
                    } else {
                        topicRefSpan.attr(navConfig.attrs.state, navConfig.states.leaf);
                    }
                }
            );
        }
    }

    /**
     * Creates the <code>ul</code> element containing the child topic nodes of the current topic.
     *
     * @param topics The array of containing info about the child topics.
     *
     * @returns {*|jQuery|HTMLElement} the <code>li</code> elements representing the child topic nodes of the current topic.
     */
    function createTopicsList(topics) {
        var topicsArray = [];
        topics.forEach(function(topic) {
            var topicLi = createTopicLi(topic);
            topicsArray.push(topicLi);
        });
        return topicsArray;
    };

    /**
     * Creates the <code>li</code> element containing a topic node.
     *
     * @param topic The info about the topic node.
     *
     * @returns {*|jQuery|HTMLElement} the <code>li</code> element containing a topic node.
     */
    function createTopicLi(topic) {
        var li = $("<li>");
        li.attr('role', 'treeitem');
        if (hasChildren(topic)) {
            li.attr('aria-expanded', 'false');
        }

        // .topicref span
        var topicRefSpan = createTopicRefSpan(topic);
        // append the topicref node in parent
        li.append(topicRefSpan);

        return li;
    };

    /**
     * Creates the <span> element containing the title and the link to the topic associated to a node in the menu or the TOC.
     *
     * @param topic The JSON object containing the info about the associated node.
     *
     * @returns {*|jQuery|HTMLElement} the topic title 'span' element.
     */
    function createTopicRefSpan(topic) {
        var isExternalReference = topic.scope == 'external';

        // .topicref span
        var topicRefSpan = $("<div>");
        topicRefSpan.addClass("topicref");
        if (topic.outputclass != null) {
            topicRefSpan.addClass(topic.outputclass);
        }

        // WH-1820 Copy the Ditaval "pass through" attributes.
        var dataAttributes = topic.attributes;
        if (typeof dataAttributes !== 'undefined') {
            var attrsNames = Object.keys(dataAttributes);
            attrsNames.forEach(function(attr) {
                topicRefSpan.attr(attr, dataAttributes[attr]);
            });
        }

        topicRefSpan.attr(navConfig.attrs.tocID, topic.tocID);

        // Current node state
        var containsChildren = hasChildren(topic);
        if (containsChildren) {
            // This state means that the child topics should be retrieved later.
            topicRefSpan.attr(navConfig.attrs.state, navConfig.states.notReady);
        } else {
            topicRefSpan.attr(navConfig.attrs.state, navConfig.states.leaf);
        }

        var expandBtn = $("<span>", {
            class: "wh-expand-btn",
            role: "button"
        });

        if(containsChildren) {
            expandBtn.attr("aria-labelledby", navConfig.btnIds.expand + " " + getTopicLinkID(topic));
            expandBtn.attr("tabindex", "0");
        }

        expandBtn.click(toggleTocExpand);
        expandBtn.keypress(handleKeyEvent);
        topicRefSpan.append(expandBtn);

        // Topic ref link
        var linkHref = '';
        if (topic.href != null && topic.href != 'javascript:void(0)') {
            if (!isExternalReference) {
                linkHref += getPathToRoot();
            }
            linkHref += topic.href;
        }
        var link = $("<a>", {
            href: linkHref,
            html: topic.title
        });
        // WH-2368 Update the relative links
        var pathToRoot = getPathToRoot();
        var linksInLink = link.find("a[href]");
        linksInLink.each(function () {
            var href = $(this).attr("href");
            if (!(href.startsWith("http:") || href.startsWith("https:"))) {
                $(this).attr("href", pathToRoot + href);
            }
        });
        var imgsInLink = link.find("img[src]");
        imgsInLink.each(function () {
            var src = $(this).attr("src");
            if (!(src.startsWith("http:") || src.startsWith("https:"))) {
                $(this).attr("src", pathToRoot + src);
            }
        });

        link.attr("id", getTopicLinkID(topic));

        if (isExternalReference) {
            link.attr("target", "_blank");
        }
        var titleSpan = $("<div>", {
           class: "title"
        });
        // titleSpan.mouseenter(showTocTooltip)
        // titleSpan.mouseleave(removeTocTooltip)
        domSanitizer.appendHtmlNode(link, titleSpan);

        // Topic ref short description
        if (topic.shortdesc != null) {
            var tooltipSpan = $("<div>", {
                class: "wh-tooltip",
                html: topic.shortdesc
            });

            /* WH-1518: Check if the tooltip has content. */
            if (tooltipSpan.find('.shortdesc:empty').length == 0) {
                // Update the relative links
                var links = tooltipSpan.find("a[href]");
                links.each(function () {
                    var href = $(this).attr("href");
                    if (!(href.startsWith("http:") || href.startsWith("https:"))) {
                        $(this).attr("href", pathToRoot + href);
                    }
                });
                var imgs = tooltipSpan.find("img[src]");
                imgs.each(function () {
                    var src = $(this).attr("src");
                    if (!(src.startsWith("http:") || src.startsWith("https:"))) {
                        $(this).attr("src", pathToRoot + src);
                    }
                });

                titleSpan.append(tooltipSpan);
            }
        }

        topicRefSpan.append(titleSpan);

        return topicRefSpan;
    }

    function getTopicLinkID(topic) {
        return topic.tocID + "-link";
    }

    function hasChildren(topic) {
        // If the "topics" property is not specified then it means that children should be loaded from the
        // module referenced in the "next" property
        var children = topic.topics;
        var hasChildren;
        if (children != null && children.length == 0) {
            hasChildren = false;
        } else {
            hasChildren = true;
        }
        return hasChildren;
    }
});
