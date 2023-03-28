<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:oxy="http://www.oxygenxml.com/functions"
				xmlns:relpath="http://dita2indesign/functions/relpath"
				xmlns:whc="http://www.oxygenxml.com/webhelp/components"
				xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
				xmlns:oxygen="http://www.oxygenxml.com/functions"
				xmlns="http://www.w3.org/1999/xhtml"
				xmlns:html="http://www.w3.org/1999/xhtml"
				xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
				xmlns:mcr="http://www.oxygenxml.com/ns/webhelp/macro"
				exclude-result-prefixes="#all"
				version="2.0">

	<xsl:param name="ARGS.BU" select="''"/>
	<xsl:param name="DRAFT" select="''"/>
	<xsl:param name="LANGUAGE" select="''"/>
	<xsl:param name="dell-brand"/>

	<xsl:import href="../common/relpath_util.xsl"/>

	<xsl:template name="generateCustomCSSLink">
		<xsl:if test="string-length($CSS) > 0">
			<xsl:variable name="urltest">
				<!-- test for URL -->
				<xsl:call-template name="url-string-oxy-internal">
					<xsl:with-param name="urltext">
						<xsl:value-of select="concat($CSSPATH, $CSS)"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="$urltest = 'url'">
					<link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}?buildId={$WEBHELP_BUILD_NUMBER}"
						  data-css-role="args.css">
						<xsl:comment/>
					</link>
				</xsl:when>
				<xsl:otherwise>
					<link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}?buildId={$WEBHELP_BUILD_NUMBER}"
						  data-css-role="args.css">
						<xsl:comment/>
					</link>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<xsl:template match="html:head" mode="copy_template">
		<xsl:param name="ditaot_topicContent" tunnel="yes" as="node()*"/>
		<xsl:param name="i18n_context" tunnel="yes" as="node()*"/>
		<xsl:copy copy-namespaces="no">
			<!-- EXM-36084 generate linkf for favicon -->
			<xsl:call-template name="generateFaviconLink"/>

			<xsl:choose>
				<xsl:when test="exists($ditaot_topicContent)">

					<!-- head element from dita-ot document -->
					<xsl:variable name="ditaot_head" select="$ditaot_topicContent//html:head"/>

					<!-- Merge the attributes from the template head element with attributes from the head element produced by DITA-OT-->
					<xsl:variable name="mergedAttributes"
								  select="oxy:mergeHTMLAttributes('head', @*, $ditaot_head/@*)"/>
					<xsl:apply-templates select="$mergedAttributes" mode="copy_template"/>

					<!-- WH-149 - Copy template head/meta content -->
					<xsl:apply-templates select="*[local-name() eq 'meta']" mode="#current"/>
					<!-- WH-149 - Copy meta generated by DITA-OT -->
					<xsl:copy-of select="$ditaot_head/node()[local-name() eq 'meta']"/>

					<!-- EXM-36084 - Move the custom CSS at end -->
					<xsl:variable name="customCssLink" as="element()?">
						<xsl:if test="string-length($CSS) > 0">
							<xsl:variable name="cssFileName" select="relpath:getName($CSS)"/>
							<xsl:copy-of select="$ditaot_head/html:link[contains(@href, $cssFileName)]"/>
						</xsl:if>
					</xsl:variable>


					<!-- Copy all node from the head element generated by DITA-OT except custom CSS-->
					<xsl:copy-of select="$ditaot_head/node()[local-name() ne 'link'][local-name() ne 'script'][local-name() ne 'meta']"/>

					<xsl:call-template name="generatePathToRootMeta"/>
					<xsl:call-template name="add-toc-id"/>

					<!--
                    WH-2432 - Generate in the output file a meta element containing the relative path to the topic.
                    -->
					<xsl:call-template name="generateSourceRelpathMeta">
						<xsl:with-param name="i18n_context" select="$i18n_context"/>
					</xsl:call-template>

					<!-- Copy template head content -->
					<xsl:apply-templates select="*[local-name() ne 'meta']" mode="#current"/>

					<!--
                        EXM-37429 - Maintain backwards compatibility: Generate links to skin resources
                        for older templates that do not include the dedicated component.
                    -->
					<xsl:if test="not(whc:webhelp_skin_resources)">
						<xsl:call-template name="addLinksToSkinResources"/>
					</xsl:if>

					<!-- EXM-36084 - Move custom CSS at end -->
					<xsl:if test="exists($customCssLink)">
						<xsl:copy-of select="$customCssLink"/>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="@*" mode="#current"/>

					<!-- WH-149 - Copy template meta -->
					<xsl:apply-templates select="*[local-name() eq 'meta']" mode="#current"/>

					<xsl:call-template name="generatePathToRootMeta"/>

					<!-- Page title -->
                    <title>
                        <xsl:variable name="templateTitle" select="*[local-name() eq 'title']"/>
                        <xsl:if test="exists($templateTitle)">
                            <xsl:value-of select="concat($templateTitle, ' - ')"/>
                        </xsl:if>
                        <xsl:variable
                            name="mainBookTitle"
                            select="$mapTitle[contains(@class, 'booktitle')]/*[contains(@class, 'mainbooktitle')]"/>
								<xsl:choose>
                            <xsl:when test="exists($mainBookTitle)">
                                <xsl:value-of select="$mainBookTitle"/>
							</xsl:when>
							<xsl:otherwise>
                                <xsl:value-of select="$mapTitle"/>
							</xsl:otherwise>
						</xsl:choose>
					</title>

					<!-- Copy template head content -->
					<xsl:apply-templates select="node()[local-name() ne 'meta'][local-name() ne 'title']" mode="#current"/>

					<!--
                        EXM-37429 - Maintain backwards compatibility: Generate links to skin resources
                        for older templates that do not include the dedicated component.
                    -->
					<xsl:if test="not(whc:webhelp_skin_resources)">
						<xsl:call-template name="addLinksToSkinResources"/>
					</xsl:if>

					<!-- EXM-36084 generate user custom CSS for main page  -->
					<xsl:call-template name="generateCustomCSSLink"/>
				</xsl:otherwise>
			</xsl:choose>
			<script type="text/javascript" src="./oxygen-webhelp/app/topic-input-sanitizer.js"><!----></script>
			<script type="text/javascript" src="./oxygen-webhelp/app/topic-loader.js"><!----></script>
			<!-- IDPL -15117 CSP Violation fix done by 986204 = codes not allowed under script tag in the html files under CSP 1.0 -->
			<script type="text/javascript" src="./oxygen-webhelp/app/topic-title-meta.js"><!----></script>
			<!-- IDPL-15171 Client DOC XSS & Open Redirect issue fix added by 986204 by Dell -->
		</xsl:copy>
	</xsl:template>

	<xsl:template match="html:body" mode="copy_template">
		<xsl:copy>
			<xsl:attribute name="data-lang" select="lower-case($LANGUAGE)"/>
			<xsl:apply-templates select="@* | node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:variable name="mapTitle" as="item()*">
		<xsl:choose>
			<xsl:when test="normalize-space($toc/toc:title)">
				<xsl:apply-templates select="$toc/toc:title/node()" mode="copy-xhtml-without-links"/>
			</xsl:when>
			<xsl:when test="normalize-space($toc/@title)">
				<xsl:value-of select="$toc/@title"/>
			</xsl:when>
			<xsl:when test="normalize-space($toc/toc:topicmeta/toc:prodinfo/toc:series)">
				<xsl:value-of
						select="concat($toc/toc:topicmeta/toc:prodinfo/toc:series,' ', $toc/toc:topicmeta/toc:prodinfo/toc:prodname, ' Help')"/>
			</xsl:when>
			<xsl:otherwise>*** Unable to determine the map title</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:template match="whc:webhelp_publication_title" mode="copy_template">
		<!-- If true then generate link to main page when generate the product title -->
		<xsl:variable name="publication_title">
			<div>
				<xsl:call-template name="generateComponentClassAttribute">
					<xsl:with-param name="compClass">wh_publication_title</xsl:with-param>
				</xsl:call-template>
				<!-- Copy attributes -->
				<xsl:copy-of select="@* except @class"/>

				<xsl:call-template name="publication-title-prefix"/>

				<xsl:choose>
					<xsl:when test="exists($mapTitle) and normalize-space($mapTitle/descendant::*[contains(@class, 'mainbooktitle')])">
						<span class="booktitle">
							<span class="mainbooktitle">
								<xsl:value-of select="normalize-space($mapTitle/descendant::*[contains(@class, 'mainbooktitle')][1])"/>
								<xsl:if test="normalize-space($mapTitle/descendant::*[contains(@class, 'booktitlealt')][1])">
									<span class="pipe-separator"/>
								</xsl:if>
							</span>
							<xsl:if test="normalize-space($mapTitle/descendant::*[contains(@class, 'booktitlealt')][1])">
								<span class="booktitlealt">
									<xsl:value-of select="normalize-space($mapTitle/descendant::*[contains(@class, 'booktitlealt')][1])"/>
								</span>
							</xsl:if>
						</span>
					</xsl:when>
					<xsl:when test="exists($mapTitle)">
						<xsl:copy-of select="normalize-space($mapTitle)"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>Warn: Cannot get the map title.</xsl:message>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:variable>

		<xsl:call-template name="outputComponentContent">
			<xsl:with-param name="compContent" select="$publication_title"/>
			<xsl:with-param name="compName" select="local-name()"/>
		</xsl:call-template>
	</xsl:template>

	<xsl:template name="publication-title-prefix">
		<xsl:choose>
			<xsl:when test="(lower-case($DRAFT) eq 'yes') and (lower-case($ARGS.BU) eq 'rsa')">
				<span class="draft_rsa_prefix">
					<xsl:call-template name="getWebhelpString">
						<xsl:with-param name="stringName" select="'DraftRSA'"/>
					</xsl:call-template>
				</span>
			</xsl:when>
			<xsl:when test="lower-case($DRAFT) eq 'yes'">
				<span class="draft_prefix">
					<xsl:call-template name="getWebhelpString">
						<xsl:with-param name="stringName" select="'Draft'"/>
					</xsl:call-template>
				</span>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="whc:webhelp_search_input" mode="copy_template">
		<!-- EXM-36737 - Context node used for messages localization -->
		<xsl:param name="i18n_context" tunnel="yes" as="element()*"/>
		<xsl:variable name="rev-number" select="$toc/descendant::*[contains(@class, ' bookmap/bookid ')][1]/descendant::*[contains(@class, ' bookmap/volume ')][1]"/>
		<xsl:variable name="year" select="$toc/descendant::*[contains(@class, ' bookmap/completed ')][1]/descendant::*[contains(@class, ' bookmap/year ')][1]"/>
		<xsl:variable name="month" select="$toc/descendant::*[contains(@class, ' bookmap/completed ')][1]/descendant::*[contains(@class, ' bookmap/month ')][1]"/>
		<xsl:variable name="month-number">
			<xsl:choose>
				<xsl:when test="$month = ('January', 'Jan')">01</xsl:when>
				<xsl:when test="$month = ('February', 'Feb')">02</xsl:when>
				<xsl:when test="$month = ('March', 'Mar')">03</xsl:when>
				<xsl:when test="$month = ('April', 'Apr')">04</xsl:when>
				<xsl:when test="$month = 'May'">05</xsl:when>
				<xsl:when test="$month = 'June'">06</xsl:when>
				<xsl:when test="$month = 'July'">07</xsl:when>
				<xsl:when test="$month = ('August', 'Aug')">08</xsl:when>
				<xsl:when test="$month = ('September', 'Sept')">09</xsl:when>
				<xsl:when test="$month = ('October', 'Oct')">10</xsl:when>
				<xsl:when test="$month = ('November', 'Nov')">11</xsl:when>
				<xsl:when test="$month = ('December', 'Dec')">12</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$month"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<div class="revision-date-container">
			<div class="revision-date-box">
				<div class="revision-date">
					<xsl:if test="normalize-space($rev-number)">
						<span class="rev-number">
							<xsl:if test="not(contains(lower-case($rev-number), 'rev'))">
								<xsl:value-of select="'Rev. '"/>
							</xsl:if>
							<xsl:value-of select="$rev-number"/>
						</span>
					</xsl:if>
				</div>
			</div>
		</div>
		<div>
			<xsl:call-template name="generateComponentClassAttribute">
				<!--<xsl:with-param name="compClass">wh_search_input</xsl:with-param>-->
				<xsl:with-param name="compClass" select="concat('wh_search_input', ' rsa'[$ARGS.BU eq 'rsa'])"/>
			</xsl:call-template>
			<!-- Copy attributes -->
			<xsl:copy-of select="@* except @class"/>

			<xsl:variable name="localizedSearch">
				<xsl:choose>
					<xsl:when test="exists($i18n_context)">
						<xsl:for-each select="$i18n_context[1]">
							<xsl:call-template name="getWebhelpString">
								<xsl:with-param name="stringName" select="'webhelp.search'"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Search</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="localizedSearchQuery">
				<xsl:choose>
					<xsl:when test="exists($i18n_context)">
						<xsl:for-each select="$i18n_context[1]">
							<xsl:call-template name="getWebhelpString">
								<xsl:with-param name="stringName" select="'search.query'"/>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>Search query</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:variable name="search_comp_output">
				<form id="searchForm"
					  method="get"
					  role="search"
					  action="{concat($PATH2PROJ, 'search', $OUTEXT)}">
					<div>
						<input type="search" placeholder="{$localizedSearch} " class="wh_search_textfield"
							   id="textToSearch" name="searchQuery" aria-label="{$localizedSearchQuery}"/>
						<button type="submit" class="wh_search_button" aria-label="{$localizedSearch}"><span><xsl:value-of select="$localizedSearch"/></span></button>
					</div>

					<!-- WH-1456 - Prevent search action if there is no text to search -->
					<!-- IDPL-15117 CSP Violation source code under script tag is not allowed -->
					<!--<xsl:comment>
						<script>
							$(document).ready(function () {
							$('#searchForm').submit(function (e) {
							if ($('.wh_search_textfield').val().length &lt; 1) {
							e.preventDefault();
							}
							});
							});
						</script>
					</xsl:comment>-->
				</form>
			</xsl:variable>

			<xsl:call-template name="outputComponentContent">
				<xsl:with-param name="compContent" select="$search_comp_output"/>
				<xsl:with-param name="compName" select="local-name()"/>
			</xsl:call-template>
		</div>
	</xsl:template>

	<xsl:template name="add-toc-id"/>

	<xsl:template match="whc:webhelp_logo" mode="copy_template">
		<xsl:if test="string-length($WEBHELP_LOGO_IMAGE) > 0">

			<!-- If the target of the logo is not specified, use the relative path to the index.html page. -->
			<xsl:variable name="href">
				<xsl:choose>
					<xsl:when test="$WEBHELP_LOGO_IMAGE_TARGET_URL"><xsl:value-of select="$WEBHELP_LOGO_IMAGE_TARGET_URL"/></xsl:when>
					<xsl:otherwise><xsl:value-of select="concat($PATH2PROJ, 'index', $OUTEXT)"/></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="altText">
				<xsl:variable name="logoAltParam" select="oxygen:getParameter('webhelp.logo.image.alt')"/>
				<xsl:choose>
					<xsl:when test="string-length($logoAltParam) > 0">
						<xsl:value-of select="$logoAltParam"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$mapTitle"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="logoComp">
				<a href="{$href}">
					<xsl:call-template name="generateComponentClassAttribute">
						<xsl:with-param name="compClass">wh_logo</xsl:with-param>
					</xsl:call-template>
					<!-- Copy attributes -->
					<xsl:copy-of select="@* except @class"/>

					<xsl:choose>
						<xsl:when test="string-length($WEBHELP_LOGO_IMAGE) > 0
                           and contains($WEBHELP_LOGO_IMAGE, ':/')">
							<img src="{$WEBHELP_LOGO_IMAGE}" alt="{$altText}"/>
						</xsl:when>

						<xsl:when
								test="string-length($WEBHELP_LOGO_IMAGE) > 0">
							<img src="{concat($PATH2PROJ, $WEBHELP_LOGO_IMAGE)}" alt="{$altText}"/>
						</xsl:when>
					</xsl:choose>
				</a>
			</xsl:variable>

			<xsl:call-template name="outputComponentContent">
				<xsl:with-param name="compContent" select="$logoComp"/>
				<xsl:with-param name="compName" select="local-name()"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>