<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all"
				xmlns:oxy="http://www.oxygenxml.com/functions"
				xmlns:relpath="http://dita2indesign/functions/relpath"
				xmlns:whc="http://www.oxygenxml.com/webhelp/components"
				xmlns:html="http://www.w3.org/1999/xhtml"
				xmlns:oxygen="http://www.oxygenxml.com/functions"
				xpath-default-namespace="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml"
				version="2.0">

	<xsl:import href="commonComponentsExpander.xsl"/>

	<xsl:param name="TRANSTYPE"/>

	<xsl:template match="div[@id='wh_topic_body'][contains(@class, 'col-')]" mode="fix-content-width">
		<xsl:param name="contentArea" tunnel="yes"/>
		<xsl:variable name="publicationToc" select="$contentArea//div[contains(@class, 'wh_publication_toc')]"/>
		<xsl:variable name="topicToc" select="$contentArea//div[contains(@class, 'wh_topic_toc')]"/>

		<xsl:variable name="newClassValue">
			<xsl:choose>
				<xsl:when test="exists($publicationToc)">
					<xsl:value-of select="@class"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="nonBootstrapClassValues">
						<xsl:for-each select="tokenize(@class, ' ')">
							<xsl:if test="not(starts-with(.,'col-'))">
								<xsl:value-of select="concat(' ', .)"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="concat('col-lg-12 col-md-12 col-sm-12 col-xs-12', $nonBootstrapClassValues)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:copy>
			<xsl:attribute name="class" select="$newClassValue"/>
			<xsl:apply-templates select="@* except @class" mode="#current"/>
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="div[@id='topic_content'][contains(@class, 'col-')]" mode="fix-content-width">
		<xsl:param name="contentArea" tunnel="yes"/>
		<xsl:variable name="topicToc" select="$contentArea//div[contains(@class, 'wh_topic_toc')]"/>

		<xsl:variable name="newClassValue">
			<xsl:choose>
				<xsl:when test="exists($topicToc)">
					<xsl:value-of select="@class"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="nonBootstrapClassValues">
						<xsl:for-each select="tokenize(@class, ' ')">
							<xsl:if test="not(starts-with(.,'col-'))">
								<xsl:value-of select="concat(' ', .)"/>
							</xsl:if>
						</xsl:for-each>
					</xsl:variable>
					<xsl:value-of select="concat('col-lg-12 col-md-12 col-sm-12 col-xs-12', $nonBootstrapClassValues)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:copy>
			<xsl:attribute name="class" select="$newClassValue"/>
			<xsl:apply-templates select="@* except @class" mode="#current"/>
			<xsl:apply-templates select="node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="*[contains(@class, 'sectiontitle')]" mode="generate-topic-toc" priority="8">
		<!--<li class="section-title">-->
			<xsl:variable name="nodeId" select="ancestor-or-self::*[@id][1]/@id"/>
			<!--<xsl:variable name="parrentId" select="../@id"/>-->
			<a href="#{$nodeId}" data-tocid="{$nodeId}">
				<xsl:apply-templates mode="copy-topic-title"/>
			</a>
		<!--</li>-->
	</xsl:template>

	<xsl:template match="*[contains(@class, 'sectiontitle')][contains(@class, 'tasklabel')]" mode="generate-topic-toc" priority="9">
		<li class="section-title">
			<xsl:variable name="nodeId" select="ancestor-or-self::*[@id][1]/@id"/>
			<!--<xsl:variable name="parrentId" select="../@id"/>-->
			<a href="#{$nodeId}" data-tocid="{$nodeId}">
				<xsl:apply-templates mode="copy-topic-title"/>
			</a>
		</li>
	</xsl:template>

	<xsl:template match="*[contains(@class, 'nested') and not(contains(@class, 'nested0'))]"
				  priority="10" mode="generate-topic-toc">
		<!--<li class="topic-item">-->
		<xsl:apply-templates mode="generate-topic-toc"
							 select="*[contains(@class, 'topictitle')]"/>
		<!--</li>-->
		<xsl:variable name="children">
			<!--<ul>-->
			<xsl:apply-templates mode="generate-topic-toc"
								 select="*[not(contains(@class, 'topictitle'))]"/>
			<!--</ul>-->
		</xsl:variable>
		<xsl:if test="count($children//li) &gt; 0">
			<xsl:copy-of select="$children"/>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[@class = 'section']" priority="12" mode="generate-topic-toc">
		<li class="section-item">
			<xsl:apply-templates mode="generate-topic-toc"
								 select="*[contains(@class, 'sectiontitle')]"/>
		</li>
		<xsl:variable name="children">
			<!--<ul>-->
			<xsl:apply-templates mode="generate-topic-toc"
								 select="*[not(contains(@class, 'sectiontitle'))]"/>
			<!--</ul>-->
		</xsl:variable>
		<xsl:if test="count($children//li) &gt; 0">
			<xsl:copy-of select="$children"/>
		</xsl:if>
	</xsl:template>

	<xsl:template name="groupRelatedLinks">
		<xsl:param name="relLinks" as="node()*"/>
		<xsl:if test="exists($relLinks)">
			<xsl:element name="{node-name($relLinks[1])}"
						 namespace="{namespace-uri($relLinks[1])}">
				<xsl:copy-of select="$relLinks[1]/@*"/>
				<xsl:for-each-group
						select="$relLinks/div[contains(@class, 'linklist') or contains(@class, 'relinfo')]"
						group-by="
                        (: Group by the link list's title heading (e.g. Related information, Related tasks, etc) :)
                        if (strong) then
                            (string-join(strong//text(), ''))
                        (: If the links list does not have a title, then consider an empty key for grouping the links. :)
                        else
                            ('')">
					<!-- Sort the links by the links list's title heading -->
					<xsl:variable name="firstItem" select="current-group()[1]"/>
					<!-- Merge links lists having the same title in a single list. -->
					<xsl:if test="current-grouping-key() != ''">
						<!-- The links list title heading -->
						<h3 class="related_link-header">
							<xsl:copy-of select="$firstItem/strong/node()"/>
						</h3>
					</xsl:if>
					<xsl:element name="{node-name($firstItem)}"
								 namespace="{namespace-uri($firstItem)}">
						<xsl:copy-of select="$firstItem/@*"/>
						<!-- Copy the related links for the current group -->
						<xsl:copy-of
								select="current-group()//*[contains(@class, 'related_link')]"/>
					</xsl:element>
				</xsl:for-each-group>
			</xsl:element>
		</xsl:if>
	</xsl:template>

	<xsl:template match="@href" mode="copyNavigationLinks">
		<xsl:attribute name="href" select="if(contains(., '#')) then(substring-before(., '#')) else(.)"/>
	</xsl:template>

	<xsl:template
			match="span[contains(@class, 'navprev')]/a/@class"
			mode="copyNavigationLinks">
		<xsl:attribute name="class" select="concat(., ' oxy-icon-arrow-left')"/>
	</xsl:template>
	<xsl:template
			match="span[contains(@class, 'navnext')]/a/@class"
			mode="copyNavigationLinks">
		<xsl:attribute name="class" select="concat(., ' oxy-icon-arrow-right')"/>
	</xsl:template>

	<xsl:template match="whc:webhelp_navigation_links" mode="copy_template">
		<xsl:param name="ditaot_topicContent" tunnel="yes"/>

		<xsl:if test="oxy:getParameter('webhelp.show.navigation.links') = 'yes'">
			<xsl:choose>
				<xsl:when test="exists($ditaot_topicContent)">
					<xsl:variable name="navLinks"
								  select="$ditaot_topicContent//*[@id = 'topic_navigation_links']"/>
					<xsl:if test="not(exists($navLinks))">
						<xsl:message>Warn: Cannot find the 'topic_navigation_links' component in the DITA-OT
							output.</xsl:message>
					</xsl:if>
					<!-- Generate the component only if Next or Previous link is found -->
					<xsl:choose>
						<xsl:when test="$navLinks//*[contains(@class, 'navprev')][1]">
							<div>
								<xsl:call-template name="generateComponentClassAttribute">
									<xsl:with-param name="compClass">wh_navigation_links_dell</xsl:with-param>
								</xsl:call-template>
								<!-- Copy attributes -->
								<xsl:copy-of select="@* except @class"/>
								<xsl:apply-templates select="$navLinks//*[contains(@class, 'navprev')][1]" mode="copyNavigationLinks"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div>
								<xsl:call-template name="generateComponentClassAttribute">
									<xsl:with-param name="compClass">wh_navigation_links_dell</xsl:with-param>
								</xsl:call-template>
							</div>
						</xsl:otherwise>
					</xsl:choose>
					<xsl:choose>
						<xsl:when test="$navLinks//*[contains(@class, 'navnext')][1]">
							<div>
								<xsl:call-template name="generateComponentClassAttribute">
									<xsl:with-param name="compClass">wh_navigation_links_dell</xsl:with-param>
								</xsl:call-template>
								<!-- Copy attributes -->
								<xsl:copy-of select="@* except @class"/>
								<xsl:apply-templates select="$navLinks//*[contains(@class, 'navnext')][1]" mode="copyNavigationLinks"/>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div>
								<xsl:call-template name="generateComponentClassAttribute">
									<xsl:with-param name="compClass">wh_navigation_links_dell</xsl:with-param>
								</xsl:call-template>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>Error: Cannot expand the 'webhelp_navigation_links' component</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
