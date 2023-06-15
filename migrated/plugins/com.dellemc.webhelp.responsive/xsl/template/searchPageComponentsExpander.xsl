<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc"
				xmlns:index="http://www.oxygenxml.com/ns/webhelp/index"
				xmlns:oxygen="http://www.oxygenxml.com/functions" xmlns:d="http://docbook.org/ns/docbook"
				xmlns:whc="http://www.oxygenxml.com/webhelp/components"
				xmlns:oxy="http://www.oxygenxml.com/functions"
				xmlns="http://www.w3.org/1999/xhtml"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:html="http://www.w3.org/1999/xhtml"
				exclude-result-prefixes="#all" version="2.0">

	<xsl:import href="commonComponentsExpander.xsl"/>

	<xsl:param name="TEMPDIR"/>
	<xsl:param name="MAP_NAME"/>
	<xsl:variable name="map-path" select="concat('file:///', translate($TEMPDIR, '\', '/'), '/', $MAP_NAME)"/>

	<xsl:template match="html:html" mode="copy_template">
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:attribute name="lang" select="oxygen:getParameter('webhelp.language')"/>
			<xsl:attribute name="dir" select="oxygen:getParameter('webhelp.page.direction')"/>
			<xsl:if test="doc-available($map-path) and contains(document($map-path)/descendant::*[contains(@class, ' bookmap/bookmap ')]/@outputclass, 'no_stars')">
				<xsl:attribute name="class" select="'no_stars'"/>
			</xsl:if>
			<!-- Copy elements -->
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="whc:webhelp_breadcrumb" mode="copy_template">
		<xsl:param name="ditaot_topicContent" tunnel="yes"/>
		<xsl:param name="i18n_context" tunnel="yes" as="element()*"/>

		<xsl:if test="oxy:getParameter('webhelp.show.breadcrumb') = 'yes'">
			<div data-tooltip-position="bottom" class=" wh_breadcrumb ">
				<xsl:variable name="homeText">
					<xsl:choose>
						<xsl:when test="exists($i18n_context)">
							<xsl:for-each select="$i18n_context[1]">
								<xsl:call-template name="getWebhelpString">
									<xsl:with-param name="stringName" select="'label.home'"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Home</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="SearchResults">
					<xsl:choose>
						<xsl:when test="exists($i18n_context)">
							<xsl:for-each select="$i18n_context[1]">
								<xsl:call-template name="getWebhelpString">
									<xsl:with-param name="stringName" select="'Search results'"/>
								</xsl:call-template>
							</xsl:for-each>
						</xsl:when>
						<xsl:otherwise>Search results</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<span class="home">
					<a href="{concat($PATH2PROJ, 'index', $OUTEXT)}">
						<span>
							<xsl:value-of select="$homeText"/>
						</span>
					</a>
					<span> / </span>
					<span class="searchResults">
						<xsl:value-of select="$SearchResults"/>
					</span>
				</span>
			</div>

		</xsl:if>
	</xsl:template>

</xsl:stylesheet>