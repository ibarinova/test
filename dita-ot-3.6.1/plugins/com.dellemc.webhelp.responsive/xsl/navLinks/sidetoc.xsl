<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:toc="http://www.oxygenxml.com/ns/webhelp/toc" xmlns="http://www.w3.org/1999/xhtml"
		xmlns:xhtml="http://www.w3.org/1999/xhtml"
		xmlns:st="http://www.oxygenxml.com/ns/webhelp/side-toc"
		xmlns:t="http://www.oxygenxml.com/ns/webhelp/toc"
		exclude-result-prefixes="xs toc st xhtml" version="2.0">

	<xsl:template match="toc:topic" mode="topic2html">
		<xsl:param name="currentNode" as="xs:boolean" tunnel="yes"/>
		<xsl:param name="precedingSiblings" tunnel="yes" as="xs:integer" select="0"/>
		<xsl:param name="followingSiblings" tunnel="yes" as="xs:integer" select="0"/>
		<xsl:variable name="vPosition" select="position()" />
		<xsl:variable name="moreNext" select="$followingSiblings - $nodesVisible"/>
		<xsl:variable name="morePrev" select="$precedingSiblings - $nodesVisible"/>

		<!--
    WH-231
    Add the css selector for the side-toc compactation
-->
		<li>
			<xsl:if test="$currentNode"><xsl:attribute name="class" select="'active'"/> </xsl:if>
			<xsl:if test="$followingSiblings and ($vPosition &gt; $nodesVisible) and ($moreNext &gt; 1)"><xsl:attribute name="class" select="'hide-after'"/></xsl:if>
			<xsl:if test="$precedingSiblings and ((($precedingSiblings - $nodesVisible + 1) &gt; $vPosition ) and ($morePrev &gt; 1))"><xsl:attribute name="class" select="'hide-before'"/></xsl:if>
			<xsl:if test="$currentNode">
				<!--
                     The HTML content corresponding to the child topics will only be generated
                     if this node is the topic which the Publication TOC is being generated for.
                -->
				<xsl:attribute name="data-processing-mode" select="'linkPoint'"/>
			</xsl:if>
			<span data-tocid="{@wh-toc-id}">
				<xsl:attribute name="class">
					<xsl:value-of select="'topicref'"/>
					<xsl:if test="@outputclass">
						<xsl:value-of select="concat(' ', @outputclass)"/>
					</xsl:if>
				</xsl:attribute>
				<!-- WH-1820 Copy the Ditaval "pass through" attributes. -->
				<xsl:copy-of select="@*[starts-with(local-name(), 'data-')]"/>
				<xsl:variable name="hasChildren" as="xs:boolean">
					<xsl:choose>
						<xsl:when test="contains(ancestor-or-self::toc:topic[normalize-space(@chunk)][1]/@chunk, 'to-content') ">
							<xsl:sequence select="false()"/>
						</xsl:when>
						<xsl:when test="count(toc:topic) > 0">
							<xsl:sequence select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:attribute name="data-state">
					<xsl:choose>
						<xsl:when test="boolean($hasChildren)">
							<xsl:choose>
								<xsl:when test="$currentNode">expanded</xsl:when>
								<xsl:otherwise>not-ready</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
						<xsl:otherwise>leaf</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
				<xsl:variable name="hrefValue">
					<xsl:call-template name="computeHrefAttr"/>
				</xsl:variable>
				<span class="wh-expand-btn"/>

				<span class="title">
					<a href="{$hrefValue}" id="{@wh-toc-id}-link">
						<xsl:if test="@scope='external'">
							<!-- Mark the current link as being external to the DITA map. -->
							<xsl:attribute name="data-scope">external</xsl:attribute>
						</xsl:if>
						<xsl:copy-of select="toc:title/node()"/>
					</a>
					<xsl:apply-templates select="toc:shortdesc" mode="topic2html"/>
				</span>
			</span>
		</li>
	</xsl:template>

	<xsl:template match="toc:shortdesc" mode="topic2html">
		<xsl:if test="normalize-space(node())">
			<span class="wh-tooltip">
				<xsl:copy-of select="node()"/>
			</span>
		</xsl:if>
	</xsl:template>

	<xsl:template match="t:topic" mode="nav-json">
		<xsl:text disable-output-escaping="yes">{</xsl:text>

		<xsl:apply-templates select="t:title" mode="nav-json"/>
		<xsl:apply-templates select="t:shortdesc" mode="nav-json"/>

		<xsl:choose>
			<xsl:when test="@href = $VOID_HREF">
				<!-- WH-1781 Select the @href & @scope of the first descendant topic ref -->
				<xsl:variable name="topicRefDescendant" select="descendant::t:topic[@href and @href != $VOID_HREF][1]"/>
				<xsl:call-template name="string-property">
					<xsl:with-param name="name">href</xsl:with-param>
					<xsl:with-param name="value">
						<xsl:choose>
							<xsl:when test="$topicRefDescendant/@href">
								<xsl:value-of select="$topicRefDescendant/@href"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="@href"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
				<xsl:if test="$topicRefDescendant/@scope">
					<xsl:call-template name="string-property">
						<xsl:with-param name="name">scope</xsl:with-param>
						<xsl:with-param name="value" select="$topicRefDescendant/@scope"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="string-property">
					<xsl:with-param name="name">href</xsl:with-param>
					<xsl:with-param name="value" select="@href"/>
				</xsl:call-template>
				<xsl:if test="@scope">
					<xsl:call-template name="string-property">
						<xsl:with-param name="name">scope</xsl:with-param>
						<xsl:with-param name="value" select="@scope"/>
					</xsl:call-template>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:if test="@outputclass">
			<xsl:call-template name="string-property">
				<xsl:with-param name="name">outputclass</xsl:with-param>
				<xsl:with-param name="value" select="@outputclass"/>
			</xsl:call-template>
		</xsl:if>

		<!-- WH-1820 Copy the Ditaval "pass through" attributes. -->
		<xsl:variable name="dataAtts" select="@*[starts-with(local-name(), 'data-')]"/>
		<xsl:if test="$dataAtts">
			<xsl:call-template name="object-property">
				<xsl:with-param name="name">attributes</xsl:with-param>
				<xsl:with-param name="value">
					<xsl:for-each select="$dataAtts">
						<xsl:call-template name="string-property">
							<xsl:with-param name="name" select="local-name()"></xsl:with-param>
							<xsl:with-param name="value" select="."/>
						</xsl:call-template>
					</xsl:for-each>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:if>

		<xsl:call-template name="object-property">
			<xsl:with-param name="name">menu</xsl:with-param>
			<xsl:with-param name="value">
				<xsl:variable name="menuChildCount"
							  select="count(t:topic[not(t:topicmeta/t:data[@name='wh-menu']/t:data[@name='hide'][@value='yes'])])"/>

				<xsl:variable name="currentDepth" select="count(ancestor-or-self::t:topic)"/>
				<xsl:variable name="maxDepth" select="number($WEBHELP_TOP_MENU_DEPTH)"/>

				<!-- Decide if this topic has children for the menu component. -->
				<xsl:variable name="hasChildren" select="$menuChildCount > 0 and ($maxDepth le 0 or $maxDepth > $currentDepth) and not(contains(ancestor-or-self::*[@chunk][1]/@chunk, 'to-content'))"/>

				<xsl:call-template name="boolean-property">
					<xsl:with-param name="name">hasChildren</xsl:with-param>
					<xsl:with-param name="value" select="$hasChildren"/>
				</xsl:call-template>
				<xsl:apply-templates select="t:topicmeta/t:data[@name='wh-menu']" mode="nav-json"/>
			</xsl:with-param>
		</xsl:call-template>

		<xsl:variable name="tocID" select="@wh-toc-id"/>

		<xsl:call-template name="string-property">
			<xsl:with-param name="name">tocID</xsl:with-param>
			<xsl:with-param name="value" select="$tocID"/>
		</xsl:call-template>

		<xsl:choose>
			<xsl:when test="count(t:topic) = 0">
				<xsl:text disable-output-escaping="yes">"topics":[]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="string-property">
					<xsl:with-param name="name">next</xsl:with-param>
					<xsl:with-param name="value" select="$tocID"/>
				</xsl:call-template>

				<xsl:result-document href="{$JSON_OUTPUT_DIR_URI}/{$tocID}.{$EXT}" format="json">
					<xsl:text disable-output-escaping="yes">define({"topics" : [</xsl:text>
					<xsl:apply-templates select="t:topic" mode="nav-json"/>
					<xsl:text disable-output-escaping="yes">]});</xsl:text>
				</xsl:result-document>
			</xsl:otherwise>
		</xsl:choose>

		<xsl:text disable-output-escaping="yes">}</xsl:text>
		<xsl:if test="position() != last()">
			<xsl:text disable-output-escaping="yes">,</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="toc:topic" mode="menu">
		<xsl:variable name="isHidden" as="xs:boolean"
					  select="exists(toc:topicmeta/toc:data[@name='wh-menu']/toc:data[@name='hide'][@value='yes'])"/>

		<xsl:if test="not($isHidden)">
			<xsl:variable name="title">
				<xsl:call-template name="getTopicTitle">
					<xsl:with-param name="topic" select="."/>
				</xsl:call-template>
			</xsl:variable>

			<li>
				<xsl:variable name="menuChildCount" select="count(toc:topic[not(toc:topicmeta/toc:data[@name='wh-menu']/toc:data[@name='hide'][@value='yes'])])"/>

				<xsl:variable name="currentDepth" select="count(ancestor-or-self::toc:topic)"/>
				<xsl:variable name="maxDepth" select="number($WEBHELP_TOP_MENU_DEPTH)"/>

				<!-- Decide if this topic has children for the menu component. -->
<!--				<xsl:variable name="hasChildren" select="$menuChildCount > 0 and ($maxDepth le 0 or $maxDepth > $currentDepth)"/>-->
				<xsl:variable name="hasChildren" select="$menuChildCount > 0 and ($maxDepth le 0 or $maxDepth > $currentDepth) and not(contains(ancestor-or-self::*[@chunk][1]/@chunk, 'to-content'))"/>

				<!-- Class attribute: -->
				<!-- Mark the item as having children if this is the case. -->
				<xsl:if test="$hasChildren">
					<xsl:attribute name="class">has-children</xsl:attribute>
				</xsl:if>

				<!-- Set the menu item image -->
				<xsl:apply-templates mode="menu-item-image" select="toc:topicmeta/toc:data[@name='wh-menu']/toc:data[@name='image'][@href]">
					<xsl:with-param name="title" select="$title"/>
				</xsl:apply-templates>

				<xsl:call-template name="getTopicContent">
					<xsl:with-param name="title" select="$title"/>
					<xsl:with-param name="hasChildren" select="$hasChildren"/>
				</xsl:call-template>
			</li>
		</xsl:if>
	</xsl:template>

	<xsl:template match="toc:topic" mode="side-toc">
		<xsl:param name="parentHTML" tunnel="yes" as="node()*" select="()"/>

		<!--
            The HTML content for the level of the current node.
            It contains the current node and its siblings in document order.
        -->
		<xsl:variable name="currentLevelHTML" as="node()*">

			<!-- Do not include siblings for the topics on the first level if not all links should be generated. -->
			<xsl:variable name="includeSiblings" as="xs:boolean" >
				<xsl:choose>
					<xsl:when test="$WEBHELP_SIDE_TOC_LINKS != ''">
						<xsl:value-of select="($parentHTML and $WEBHELP_SIDE_TOC_LINKS = 'chapter') or $WEBHELP_SIDE_TOC_LINKS = 'all'"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="($parentHTML and $WEBHELP_PUBLICATION_TOC_LINKS = 'chapter') or $WEBHELP_PUBLICATION_TOC_LINKS = 'all'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>

			<xsl:if test="$includeSiblings">
				<!--
                    The HTML content for the previous siblings of the current node.
                    Only the top level nodes will be processed. No recursion is done.
                -->
				<xsl:variable name="countPrecedingSiblings" select="count(preceding-sibling::toc:topic)" as="xs:integer"/>
				<xsl:variable name="vPosition" select="position()" />

				<!--
                    WH-231
                    Compute the preceding siblings for side-toc compactation
                -->
				<xsl:variable name="more" select="$countPrecedingSiblings - $nodesVisible"/>
				<xsl:if test="($countPrecedingSiblings > $nodesVisible) and ($more > 1)" xml:space="preserve">
                    <li class="dots-before"><span><xsl:value-of select="$more"/> <xsl:call-template name="getWebhelpString"><xsl:with-param name="stringName" select="'more'"/></xsl:call-template></span></li>
                </xsl:if>

				<xsl:apply-templates select="preceding-sibling::toc:topic" mode="topic2html">
					<xsl:with-param name="currentNode" select="false()" tunnel="yes"/>
					<xsl:with-param name="precedingSiblings" select="$countPrecedingSiblings" tunnel="yes"/>
				</xsl:apply-templates>
			</xsl:if>

			<!--
                The HTML content for the current node, which is generated separately because,
                from all the nodes from the current level, only this node will have
                its direct children generated in the current Side TOC.
            -->
			<xsl:apply-templates select="." mode="topic2html">
				<xsl:with-param name="currentNode" select="true()" tunnel="yes"/>
			</xsl:apply-templates>

			<xsl:if test="$includeSiblings">
				<!--
                    The HTML content for the following siblings of the current node.
                    Only the top level nodes will be processed. No recursion is done.
                -->
				<xsl:variable name="countFollowingSiblings" select="count(following-sibling::toc:topic)" as="xs:integer"/>
				<xsl:variable name="xPosition" select="position()" />
				<xsl:apply-templates select="following-sibling::toc:topic" mode="topic2html">
					<xsl:with-param name="currentNode" select="false()" tunnel="yes"/>
					<xsl:with-param name="followingSiblings" select="$countFollowingSiblings" tunnel="yes"/>
				</xsl:apply-templates>

				<!--
                    WH-231
                    Compute the following siblings for side-toc compactation
                -->
				<xsl:variable name="more" select="$countFollowingSiblings - $nodesVisible"/>
				<xsl:if test="($countFollowingSiblings > $nodesVisible) and ($more > 1)" xml:space="preserve">
                    <li class="dots-after"><span><xsl:value-of select="$more"/> <xsl:call-template name="getWebhelpString"><xsl:with-param name="stringName" select="'more'"/></xsl:call-template></span></li>
                </xsl:if>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="getSideTocValue">
			<xsl:choose>
				<xsl:when test="$WEBHELP_SIDE_TOC_LINKS != ''">
					<xsl:value-of select="$WEBHELP_SIDE_TOC_LINKS"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$WEBHELP_PUBLICATION_TOC_LINKS"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!--
            Merge the HTML content generated for the current level with
            the HTML content of the current node's parent.

            A copy template from a specific mode will be applied on the parent HTML
            and the HTML of the current level. The current level HTML will be linked in the parent HTML
            when a certain marker attribute is encountered (i.e.: @data-processing-mode=linkPoint).
        -->
		<xsl:variable name="currentLevelHTMLWithParent" as="node()*">
			<xsl:choose>
				<xsl:when test="not(empty($parentHTML)) and $getSideTocValue != 'topic'">
					<xsl:apply-templates select="$parentHTML" mode="linkInParent">
						<xsl:with-param name="currentLevelHTML" select="$currentLevelHTML" tunnel="yes"/>
						<xsl:with-param name="linkCurrentNode" select="true()" tunnel="yes"/>
					</xsl:apply-templates>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$currentLevelHTML"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- Generate the HTML content for the direct children of the current node. -->
		<xsl:variable name="childrenHTML" as="node()*">
			<xsl:if test="$WEBHELP_PUBLICATION_TOC_HIDE_CHUNKED_TOPICS = 'no' or not(contains(@chunk, 'to-content'))">
				<xsl:variable name="countChilds" select="count(child::toc:topic)" as="xs:integer"/>

				<xsl:apply-templates select="toc:topic" mode="topic2html">
					<xsl:with-param name="currentNode" select="false()" tunnel="yes"/>
					<xsl:with-param name="followingSiblings" select="$countChilds" tunnel="yes"/>
				</xsl:apply-templates>

				<!--
                    WH-231
                    Compute the childrens for side-toc compactation
                -->
				<xsl:variable name="more" select="$countChilds - $nodesVisible"/>
				<xsl:if test="($countChilds > $nodesVisible) and ($more > 1)" xml:space="preserve">
                    <li class="dots-after"><span><xsl:value-of select="$more"/>
                    <xsl:call-template name="getWebhelpString"><xsl:with-param name="stringName" select="'more'"/></xsl:call-template>
                    </span></li>
                </xsl:if>
			</xsl:if>
		</xsl:variable>

		<!--
            Link the HTML of the child nodes in the HTML merged above in order to obtain the Side TOC
            for the current node.

            The SIDE TOC will contain:
                - the ancestors of the current node
                - the ancestors' siblings nodes
                - the siblings of the current node
                - the children of the current node
        -->
		<xsl:variable name="currentNodeSideToc" as="node()*">
			<xsl:apply-templates select="$currentLevelHTMLWithParent" mode="linkInParent">
				<xsl:with-param name="currentLevelHTML" select="$childrenHTML" tunnel="yes"/>
				<xsl:with-param name="linkCurrentNode" select="false()" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:variable>

		<!--
            Write the Side TOC for the current node in a temporary file
            next to file of its referenced target topic.
        -->
		<xsl:if test="not(@href = $VOID_HREF) and string-length(normalize-space(@href)) != 0 and not(@scope = 'external') and (not(@format) or @format = 'dita')">
			<!-- WH-1469: Handle the case when there are topicrefs with duplicate hrefs without @copy-to. -->
			<xsl:variable name="nodes" select="key('tocHrefs', tokenize(@href, '#')[1])"/>
			<xsl:if test="count($nodes) lt 2 or deep-equal(.,  $nodes[1])">
				<xsl:variable name="outputHref">
					<xsl:value-of select="$TEMP_DIR_URL"/>
					<xsl:call-template name="replace-extension">
						<xsl:with-param name="extension" select="'.sidetoc'"/>
						<xsl:with-param name="filename" select="@href"/>
						<xsl:with-param name="ignore-fragment" select="true()"/>
						<xsl:with-param name="forceReplace" select="true()"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:result-document format="html" href="{$outputHref}">
					<xsl:variable name="publicationToc">
						<div data-type="temporary">
							<span class="expand-button-action-labels">
								<span id="{$expandActionID}" role="button" aria-label="Expand" class="hidden">
								<!--	IB: Add support for TOC 'Expand all' / 'Collapse all' buttons. Add tooltips with localized value-->
									<span class="wh-tooltip">
										<xsl:call-template name="getVariable">
											<xsl:with-param name="id" select="'Expand all'"/>
											<xsl:with-param name="ctx" select="/descendant-or-self::*[@xml:lang][1]"/>
										</xsl:call-template>
									</span>
								</span>
								<span id="{$collapseActionID}" role="button" aria-label="Collapse" class="hidden">
								<!--	IB: Add support for TOC 'Expand all' / 'Collapse all' buttons. Add tooltips with localized value-->
									<span class="wh-tooltip">
										<xsl:call-template name="getVariable">
											<xsl:with-param name="id" select="'Collapse all'"/>
											<xsl:with-param name="ctx" select="/descendant-or-self::*[@xml:lang][1]"/>
										</xsl:call-template>
									</span>
								</span>
								<span id="{$pendingActionID}" role="button" aria-label="Pending"/>
							</span>
							<span class="tooltip-container"/>
							<ul>
								<xsl:copy-of select="$currentNodeSideToc"/>
							</ul>
						</div>
					</xsl:variable>
					<xsl:apply-templates select="$publicationToc" mode="toc-accessibility"/>
				</xsl:result-document>
			</xsl:if>
		</xsl:if>

		<!--
            Recursively generate the Side TOC for the child nodes only if this is not a chunked topic.
            Pass down the HTML content generated for the current node without its children.
        -->
		<xsl:if test="not(contains(@chunk, 'to-content'))">
			<xsl:apply-templates select="toc:topic" mode="side-toc">
				<xsl:with-param name="parentHTML" select="$currentLevelHTMLWithParent" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:if>

	</xsl:template>

	<xsl:template match="t:topic" mode="output-json">
<!--		<xsl:if test="(count(t:topic) > 0) or (t:shortdesc)">-->
			<xsl:variable name="tocID" select="@wh-toc-id"/>
			<xsl:result-document href="{$JSON_OUTPUT_DIR_URI}/{$tocID}.{$EXT}" format="json">
				<xsl:variable name="jsonXml">
					<xsl:call-template name="object-property">
						<xsl:with-param name="value">
							<xsl:apply-templates select="t:title" mode="build-json"/>
							<xsl:apply-templates select="t:shortdesc" mode="build-json"/>
							<xsl:call-template name="array-property">
								<xsl:with-param name="name">topics</xsl:with-param>
								<xsl:with-param name="value">
									<xsl:apply-templates select="t:topic" mode="build-json"/>
								</xsl:with-param>
							</xsl:call-template>
						</xsl:with-param>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="json">
					<xsl:call-template name="xml2Json">
						<xsl:with-param name="jsonXml" select="$jsonXml"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="concat('define(', $json, ');')"/>
			</xsl:result-document>
			<xsl:apply-templates select="t:topic" mode="output-json"/>
<!--		</xsl:if>-->
	</xsl:template>

</xsl:stylesheet>
