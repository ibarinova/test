document.addEventListener("DOMContentLoaded", () => {
    setTocHeight();

    $(window).resize(function () {
        setTocHeight();
    });

    removeTargetBlank($("#wh_publication_toc"));

    let topicRefExpandBtn = $(".wh_publication_toc .wh-expand-btn");

    let goToTopBttn = $("#go2top");
    goToTopBttn.on( "keypress", function () {
        $( this ).click();
    });

    handleImagesEvent();

    topicRefExpandBtn.on( "click", function() {
        let topicRef = $( this ).closest(".topicref");
        setTimeout(function () {
            let nestedUl = $(topicRef.parent().get(0)).find('ul')[0];
            if ($(nestedUl).length) {
                removeTargetBlank($(nestedUl));
            }
        }, 100)
    } );

    // Register the click handler for the TOC 'Expand All' button
    let expandAllBtn = $(".wh_publication_toc #button-expand-action");
    expandAllBtn.removeClass('hidden');
    expandAllBtn.click(function () {
        tocExpandCollapseAll($('#wh_publication_toc'), 'expand');
    });
    expandAllBtn.on( "keypress", function () {
        $( this ).click();
    });

    // Register the ckick handler for the TOC 'Collapse All' button
    let collapseAllBtn = $(".wh_publication_toc #button-collapse-action");
    collapseAllBtn.click(function () {
        tocExpandCollapseAll($('#wh_publication_toc'), 'collapse');
    });
    collapseAllBtn.on( "keypress", function () {
        $( this ).click();
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

    function tocExpandCollapseAll($root, action) {
        let tocExpandBtns = $root.find('.wh-expand-btn');

        let collapseAllBtn = $(".wh_publication_toc #button-collapse-action");
        let expandAllBtn = $(".wh_publication_toc #button-expand-action");

        removeTargetBlank($root);

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
            let state = topicRef.attr("data-state");

            if (action === 'collapse' && state === "expanded") {
                tocExpandBtn.click()
                let nestedUl = $(topicRef.parent().get(0)).find('ul')[0];
                if ($(nestedUl).length) {
                    tocExpandCollapseAll($(nestedUl), action);
                }
            } else if (action === 'expand' && state !== "expanded") {
                tocExpandBtn.click()
                setTimeout(function () {
                    let nestedUl = $(topicRef.parent().get(0)).find('ul')[0];
                    if ($(nestedUl).length) {
                        tocExpandCollapseAll($(nestedUl), action);
                    }
                }, 60)
            }
        }
    }

    // Remove target="_blank". Oxygen issue.
    function removeTargetBlank($root) {
        setTimeout(function () {
            $root.find('a[target="_blank"]').removeAttr('target');
        }, 100)
    }

    // Afind all zoom images
    // Add 'keypress' event
    // Add  tabindex="0"
    function handleImagesEvent() {
        setTimeout(function () {
            let zoomImages = $(".zoom");

            zoomImages.on( "keypress", function () {
                $( this ).click();
            });

            zoomImages.each(function() {
                $( this ).attr( "tabindex", "0" );
            });
        }, 50)
    }
});
