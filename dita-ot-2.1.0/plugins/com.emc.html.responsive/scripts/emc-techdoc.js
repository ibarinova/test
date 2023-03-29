$(function(){
// Copyright 2014-2015 Twitter, Inc.
// Licensed under MIT (https://github.com/twbs/bootstrap/blob/master/LICENSE)
    if (navigator.userAgent.match(/IEMobile\/10\.0/)) {
        var msViewportStyle = document.createElement('style');
        msViewportStyle.appendChild(
            document.createTextNode(
                '@-ms-viewport{width:auto!important}'
            )
        );
        document.querySelector('head').appendChild(msViewportStyle)
    }

    var isMobile = false;
    if (/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|ipad|iris|kindle|Android|Silk|lge |maemo|midp|mmp|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(navigator.userAgent)
        || /1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(navigator.userAgent.substr(0, 4))) {
        isMobile = true;
    }

    var windowWidth = $( window ).width();
    var windowHeight = $( window ).height();

    var body = $('body');
    var main = $('main');
    var contentWrapper = $('#content-wrapper');
    var contentCover = $('#content-cover');
    var hideNavigation = $('#hide-navigation');
    var showNavigation = $('#show-navigation');
    var pubNavigation = $('#pub-navigation');
    var navigationWrapper = $('#navigation-wrapper');
    var mainArticle = $('#mainArticle');
    var onThisPage = $('#onthispage');
    var onThisPageContainer = $('#onthispage-container');
    var onThisPageLinks = onThisPageContainer.find('a');
    var onThisPageIcon = $('#onthispage-icon');
    var dragging = false;
    var twisty = body.find('.twisty');

    var lastScreenSize;

    function windowIsSmall() {
        return windowWidth <= 980;
    }
    function windowIsMedium() {
        return windowWidth > 980 && windowWidth < 1262 ;
    }
    function windowIsLarge() {
        return windowWidth >= 1262;
    }

    function isContentPage() {
        return $("#mainArticle").length > 0;
    }

    body.removeClass('is-mobile').removeClass('is-desktop');
    if (isMobile) {
        body.addClass('is-mobile');
    } else {
        body.addClass('is-desktop');
    }

    if (isContentPage()) {
        processContentPage();
        var ext = document.location.pathname.match(/[^\/]+$/)[0].split('.').pop();
        var navPath = "toc." + ext + " #nav";
        pubNavigation.load(navPath, function() {
            var path = location.pathname;
            var fileNameIndex = path.lastIndexOf("/") + 1;
            var filename = path.substr(fileNameIndex);

            var navLink = $('#nav').find('a[href^="'+filename+'"]');
            navLink.parent().addClass('selected');
            correctNavigationWrapperHeight();
            }
        );

    }

    $( window ).resize(function() {
        windowWidth = $( window ).width();
        windowHeight = $( window ).height();

        if (isContentPage()) {
            processContentPage();
            correctNavigationWrapperHeight();
        }

    });

    function correctNavigationWrapperHeight () {
        navigationWrapper.css('height', '');

        var navWrapHeight = navigationWrapper.height();
        var navWrapMaxHeight = windowHeight / 4 * 3 - 80;

        if (navWrapHeight > navWrapMaxHeight) {
            navigationWrapper.css('height', navWrapMaxHeight);
        }

    }

    function processContentPage() {
        var mainFooter = $('#footerWrapper');

        onThisPageLinks.off('click touchend');
        twisty.off('click touchend');

        $(window).on("touchmove", function(){
            dragging = true;
            if (!windowIsSmall()) {
                positionOnThisPageSection();
            }
        }).on("onscroll scroll", function(){
            if (!windowIsSmall()) {
                positionOnThisPageSection();
            }
        });

        $('.collapsed').nextAll().addClass('hidden');

        twisty.on('touchend click', function(e) {
            e.preventDefault();
            var currentTarget = $(e.currentTarget);

            if (currentTarget.hasClass('collapsed')) {
                currentTarget.removeClass('collapsed');
                currentTarget.addClass('expanded');
                currentTarget.nextAll().removeClass('hidden');
            } else {
                currentTarget.removeClass('expanded');
                currentTarget.addClass('collapsed');
                currentTarget.nextAll().addClass('hidden');
            }
        });

        hideNavigation.on('touchend click', function(e) {
            if (dragging) {
                dragging = false;
                return;
            }

            e.preventDefault();

            hideNavigation.addClass("hidden");
            pubNavigation.addClass("hidden");
            showNavigation.removeClass("hidden");
            mainArticle.addClass("navigation-hidden");
            navigationWrapper.addClass("navigation-hidden");
            navigationWrapper.css('height', '');
        });

        showNavigation.on('touchend click', function(e) {
            if (dragging) {
                dragging = false;
                return;
            }

            e.preventDefault();

            showNavigation.addClass("hidden");
            hideNavigation.removeClass("hidden");
            pubNavigation.removeClass("hidden");
            mainArticle.removeClass("navigation-hidden");
            navigationWrapper.removeClass("navigation-hidden");
            correctNavigationWrapperHeight();
        });

        if (windowIsSmall()) {
            constructSmallWindowDesign();
            lastScreenSize = 'small';
        }
        if (windowIsMedium()) {
            constructLargeWindowDesign();
            lastScreenSize = 'medium';
        }
        if (windowIsLarge()) {
            constructLargeWindowDesign();
            lastScreenSize = 'large';
        }

        function scrollContent (e) {
            e.preventDefault();
            var currentTarget = $(e.currentTarget);
            var targetHref  = currentTarget.attr('href');
            var article = body.find(targetHref);

            var topPoint = 0;

            if (windowIsSmall()) {
                topPoint = 70;
            }
            body.scrollView(article.offset().top - topPoint);
        }

        $.fn.scrollView = function(directionPoint) {
            return this.each(function() {
                $('html, body').animate({
                    scrollTop: directionPoint
                }, 500);
            });
        };

        function getElemBottomPosition(elem){
            var offset = elem.offset();
            var top = offset.top;
            return top + elem.height() - $(window).scrollTop() ;
        }

        function isScrolledIntoView(elem) {
            var $elem = $(elem);
            var $window = $(window);

            var docViewTop = $window.scrollTop();
            var docViewBottom = docViewTop + $window.height();

            var elemTop = $elem.offset().top;
            var elemBottom = elemTop + $elem.height();

            return ((elemBottom <= docViewBottom) && (elemTop >= docViewTop)
                || (elemTop <= docViewBottom && elemBottom > docViewBottom)
                || (elemBottom >= docViewTop && elemTop < docViewTop));
        }

        function constructSmallWindowDesign() {
            if (lastScreenSize != 'small') {
                hideNavigation.trigger("click");
                onThisPage.css('left', '');
            }

            onThisPageIcon.on('touchend click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                onThisPage.addClass('visible');
                contentCover.addClass('visible');
            });

            contentCover.on('touchstart click', function(e) {
                e.preventDefault();
                e.stopPropagation();
                onThisPage.removeClass('visible');
                contentCover.removeClass('visible');
            });

            onThisPage.on("touchmove onscroll scroll", function(){
                dragging = true;
                e.stopPropagation();
            });

            onThisPageLinks.on('touchend click', function(e) {
                if (dragging) {
                    dragging = false;
                    return;
                }
                contentCover.trigger("click");
                scrollContent(e);
            });

        }

        function constructLargeWindowDesign() {
            positionOnThisPageSection();
            if (lastScreenSize == 'small') {
                contentCover.trigger("click");
            }
            if (windowIsMedium()) {
                hideNavigation.trigger("click");
            }
            if (windowIsLarge()) {
                showNavigation.trigger("click");
            }

            onThisPageLinks.on('touchend click', function(e) {
                scrollContent(e);
            });
        }

        function positionOnThisPageSection() {
            var contentLeftMargin = main.offset().left;
            var contentWidth = contentWrapper.width();
            var onthispageWidth = onThisPage.width();

            onThisPage.css('left', contentLeftMargin + contentWidth - onthispageWidth);

            if (mainFooter.length) {
                var mainArticleBottom = getElemBottomPosition(mainArticle);
                var footerIsVisible = isScrolledIntoView(mainFooter);
                if (footerIsVisible) {
                    onThisPage.css('bottom', windowHeight - mainArticleBottom);
                    onThisPage.css('top', 'auto');

                } else {
                    onThisPage.css('bottom', '');
                    onThisPage.css('top', '');
                }
            }
        }
    }
});

function registerArticleView() {
	var triggeredElements = ["mainArticle"];

	$('article').appear();

	$(document.body).on('appear', 'article', function (e, $affected) {
		$affected.each(function () {
			//check if we have already fired an event for this appearance
			if (triggeredElements.indexOf(this.getAttribute("id")) === -1) {
				//add Adobe Analytics trigger from Tyrone here and replace alert below
				//alert("Firing Adobe Analytics trigger for "+this.getAttribute("id")+" which is the @id for title: "+this.innerHTML);
				trackTechDoc(this.getAttribute("id"));
				//add this element to the triggered list so that we don't trigger it again on the page
				triggeredElements.push(this.getAttribute("id"));
			}

		})
	});
	$.force_appear();

};
