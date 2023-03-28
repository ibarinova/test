<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:oxygen="http://www.oxygenxml.com/functions"
				xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
				xmlns="http://www.oxygenxml.com/ns/webhelp/toc"
				exclude-result-prefixes="oxygen dita-ot"
				version="2.0">


	<!-- check for node notices tag having topics with outputclass attribute value as printonly
		If node notices are found with topic references as the child elements 
		do not create links for the topics exclude the links generation for the topic references -->
	<xsl:template name="removeNotices" match="topic/topic[@outputclass='printonly']"/>
	<!-- code ends here -->
	
	<xsl:template
			match="
            *[contains(@class, ' map/topicref ')
            and not(@processing-role = 'resource-only')
            and not(@toc = 'no')
            and not(ancestor::*[contains(@class, ' map/reltable ')])]"
			mode="toc-webhelp">

		<xsl:variable name="title" as="node()*">
			<xsl:variable name="navTitleElem"
						  select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
			<xsl:choose>
				<xsl:when test="$navTitleElem">
					<!-- Fix the href attribute in the navtitle -->
					<xsl:variable name="navTitle_hrefFixed">
						<xsl:apply-templates select="$navTitleElem" mode="fixHRef">
							<xsl:with-param name="base-uri" select="base-uri()"/>
						</xsl:apply-templates>
					</xsl:variable>

					<xsl:apply-templates select="$navTitle_hrefFixed/*/node()"/>
					<!--<xsl:apply-templates select="$navTitleElem/node()"/>-->
				</xsl:when>
				<xsl:when test="@navtitle">
					<xsl:value-of select="@navtitle"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<xsl:choose>
			<xsl:when test="@href or @copy-to or not(empty($title))">
				<xsl:call-template name="removeNotices"/>
				<topic>
					<!-- WA-4052: Propagate source information so that we can add
                         edit links to side-toc.  -->
					<xsl:attribute name="xtrf" select="@xtrf"/>
					<xsl:attribute name="xtrc" select="@xtrc"/>

					<xsl:variable name="hrefNoIDs" select="if(contains(@href, '#')) then(substring-before(@href, '#')) else(@href)"/>

					<xsl:attribute name="href">
						<xsl:choose>
							<xsl:when
									test="@copy-to and not(ancestor-or-self::*[contains(@chunk, 'to-content')])">
								<xsl:call-template name="replace-extension">
									<xsl:with-param name="filename" select="@copy-to"/>
									<xsl:with-param name="extension" select="$OUT_EXT"/>
									<xsl:with-param name="forceReplace"
													select="not(@format) or @format = 'dita'"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="@href">
								<xsl:call-template name="replace-extension">
									<xsl:with-param name="filename" select="$hrefNoIDs"/>
									<xsl:with-param name="extension" select="$OUT_EXT"/>
									<xsl:with-param name="forceReplace"
													select="not(@format) or @format = 'dita'"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$VOID_HREF"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:if test="@collection-type">
						<xsl:attribute name="collection-type" select="@collection-type"/>
					</xsl:if>
					<xsl:if test="@outputclass">
						<xsl:attribute name="outputclass" select="@outputclass"/>
					</xsl:if>
					<xsl:if test="@scope and not(@scope = 'local')">
						<xsl:attribute name="scope" select="@scope"/>
					</xsl:if>
					<!-- WH-257: Copy "chunk" info. -->
					<xsl:copy-of select="@chunk"/>
					<!-- WH-257: Copy "format" attribute. -->
					<xsl:copy-of select="@format"/>
<!--
					<xsl:if test="contains(@class, ' bookmap/part ')">
						<xsl:attribute name="outputclass" select="concat(@outputclass, ' bookmap_part ')"/>
					</xsl:if>
-->
					<xsl:if test="exists($passthrough-attrs)">
						<xsl:for-each select="@*">
							<xsl:if
									test="
                                    $passthrough-attrs[@att = name(current()) and (empty(@val) or (some $v in tokenize(current(), '\s+')
                                        satisfies $v = @val))]">
								<xsl:attribute name="data-{name()}" select="."/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>

					<xsl:variable name="topicId">
						<xsl:choose>
							<!-- Pickup the ID from the topic file, that was set in the topicmeta by a previous processing (see "addResourceID.xsl").  -->
							<xsl:when test="*[contains(@class, ' map/topicmeta ')]/@data-topic-id">
								<xsl:variable name="data-topic-id" select="*[contains(@class, ' map/topicmeta ')]/@data-topic-id"/>
								<xsl:variable name="equal-topic-id-number" select="count(preceding::*[@data-topic-id = $data-topic-id]) + 1"/>
								<xsl:variable name="toc-id-number" select="if($equal-topic-id-number = 1) then('') else(concat('_', $equal-topic-id-number))"/>
								<xsl:value-of select="concat($data-topic-id, $toc-id-number)"/>
							</xsl:when>
							<!-- Fallback to the ID set on the topicref. For instance the topichead does not point to a topic
								file (that would have an ID inside), but can have an ID set on it directly in the map.-->
							<xsl:when test="@id">
								<xsl:variable name="id" select="@id"/>
								<xsl:variable name="equal-id-number" select="count(preceding::*[@id = $id]) + 1"/>
								<xsl:variable name="toc-id-number" select="if($equal-id-number = 1) then('') else(concat('_', $equal-id-number))"/>
								<xsl:value-of select="concat(@id, $toc-id-number)"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>

					<xsl:if test="string-length($topicId) > 0">
						<xsl:attribute name="data-id" select="$topicId"/>
					</xsl:if>

					<xsl:attribute name="wh-toc-id">
						<xsl:variable name="tocIdNew">
							<xsl:choose>
								<xsl:when test="string-length($topicId) > 0">
									<xsl:value-of select="$topicId"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('tocId', '-', generate-id(.))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="$tocIdNew"/>
					</xsl:attribute>

					<title>
						<xsl:choose>
							<xsl:when test="not(empty($title))">
								<xsl:choose>
									<xsl:when
											test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
										<xsl:apply-templates
												select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
												mode="dita-ot:text-only"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="$title"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>***</xsl:otherwise>
						</xsl:choose>
					</title>

					<xsl:variable name="shortDesc"
								  select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/shortdesc ')][1]"/>
					<xsl:if test="$shortDesc and normalize-space($shortDesc)">
						<xsl:variable name="shortDescFixed">
							<xsl:apply-templates select="$shortDesc" mode="fix-shortdesc">
								<xsl:with-param name="base-uri" select="base-uri()"/>
							</xsl:apply-templates>
						</xsl:variable>

						<shortdesc>
							<xsl:apply-templates select="$shortDescFixed/node()"/>
						</shortdesc>
					</xsl:if>
					<xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]"
										 mode="copy-topic-meta"/>
					<xsl:apply-templates mode="toc-webhelp"/>
				</topic>
			</xsl:when>
			<xsl:otherwise>
				<!-- Do not contribute a level in the TOC, but recurse in the child topicrefs -->
				<xsl:apply-templates mode="toc-webhelp"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match=" *[contains(@outputclass, 'bridge')]
							[contains(@class, ' map/topicref ')
							and not(@processing-role = 'resource-only')
							and not(@toc = 'no')
							and not(ancestor::*[contains(@class, ' map/reltable ')])]"
							mode="toc-webhelp" priority="10">

		<xsl:variable name="child-topicref" select="child::*[contains(@class, ' map/topicref ')][not(@processing-role = 'resource-only')][@format = 'dita']"/>
		<xsl:variable name="child-topicref-number" select="count(child::*[contains(@class, ' map/topicref ')][not(@processing-role = 'resource-only')][@format = 'dita'][normalize-space(@href) or normalize-space(@copy-to)])"/>

		<xsl:variable name="title" as="node()*">
			<xsl:variable name="navTitleElem"
						  select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
			<xsl:choose>
				<xsl:when test="$navTitleElem">
					<!-- Fix the href attribute in the navtitle -->
					<xsl:variable name="navTitle_hrefFixed">
						<xsl:apply-templates select="$navTitleElem" mode="fixHRef">
							<xsl:with-param name="base-uri" select="base-uri()"/>
						</xsl:apply-templates>/ </xsl:variable>

					<xsl:apply-templates select="$navTitle_hrefFixed/*/node()"/>
					<!--<xsl:apply-templates select="$navTitleElem/node()"/>-->
				</xsl:when>
				<xsl:when test="@navtitle">
					<xsl:value-of select="@navtitle"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:call-template name="removeNotices"/>
		
		<xsl:choose>
			<xsl:when test="$child-topicref[@href] or $child-topicref[@copy-to] or not(empty($title))">
				<topic>
					<xsl:attribute name="href">
						<xsl:choose>
							<xsl:when test="$child-topicref[1][@copy-to] and not($child-topicref/ancestor-or-self::*[contains(@chunk, 'to-content')])">
								<xsl:call-template name="replace-extension">
									<xsl:with-param name="filename" select="$child-topicref[1]/@copy-to"/>
									<xsl:with-param name="extension" select="$OUT_EXT"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test="$child-topicref[1][@href]">
								<xsl:call-template name="replace-extension">
									<xsl:with-param name="filename" select="$child-topicref[@href][1]/@href"/>
									<xsl:with-param name="extension" select="$OUT_EXT"/>
									<xsl:with-param name="forceReplace"
													select="not(@format) or @format = 'dita'"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$VOID_HREF"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:if test="@collection-type">
						<xsl:attribute name="collection-type" select="@collection-type"/>
					</xsl:if>
					<xsl:if test="@outputclass">
						<xsl:attribute name="outputclass" select="@outputclass"/>
					</xsl:if>
					<xsl:if test="@scope and not(@scope = 'local')">
						<xsl:attribute name="scope" select="@scope"/>
					</xsl:if>
					<!-- WH-257: Copy "chunk" info. -->
					<xsl:copy-of select="@chunk"/>
					<!-- WH-257: Copy "format" attribute. -->
					<xsl:copy-of select="@format"/>
<!--
					<xsl:if test="contains(@class, ' bookmap/part ')">
						<xsl:attribute name="outputclass" select="concat(@outputclass, ' bookmap_part ')"/>
					</xsl:if>
-->
					<xsl:if test="exists($passthrough-attrs)">
						<xsl:for-each select="@*">
							<xsl:if
									test="
                                    $passthrough-attrs[@att = name(current()) and (empty(@val) or (some $v in tokenize(current(), '\s+')
                                        satisfies $v = @val))]">
								<xsl:attribute name="data-{name()}" select="."/>
							</xsl:if>
						</xsl:for-each>
					</xsl:if>

					<xsl:variable name="topicId">
						<xsl:choose>
							<!-- Pickup the ID from the topic file, that was set in the topicmeta by a previous processing (see "addResourceID.xsl").  -->
							<xsl:when test="*[contains(@class, ' map/topicmeta ')]/@data-topic-id">
								<xsl:variable name="data-topic-id" select="*[contains(@class, ' map/topicmeta ')]/@data-topic-id"/>
								<xsl:variable name="equal-topic-id-number" select="count(preceding::*[@data-topic-id = $data-topic-id]) + 1"/>
								<xsl:variable name="toc-id-number" select="if($equal-topic-id-number = 1) then('') else(concat('_', $equal-topic-id-number))"/>
								<xsl:value-of select="concat($data-topic-id, $toc-id-number)"/>
							</xsl:when>
							<!-- Fallback to the ID set on the topicref. For instance the topichead does not point to a topic
								file (that would have an ID inside), but can have an ID set on it directly in the map.-->
							<xsl:when test="@id">
								<xsl:variable name="id" select="@id"/>
								<xsl:variable name="equal-id-number" select="count(preceding::*[@id = $id]) + 1"/>
								<xsl:variable name="toc-id-number" select="if($equal-id-number = 1) then('') else(concat('_', $equal-id-number))"/>
								<xsl:value-of select="concat(@id, $toc-id-number)"/>
							</xsl:when>
						</xsl:choose>
					</xsl:variable>
					<!--<xsl:message>Topic is :<xsl:value-of select="$topicId"/></xsl:message>-->
					<xsl:if test="string-length($topicId) > 0">
						<xsl:attribute name="data-id" select="$topicId"/>
					</xsl:if>

					<xsl:attribute name="wh-toc-id">
						<xsl:variable name="tocIdNew">
							<xsl:choose>
								<xsl:when test="string-length($topicId) > 0">
									<xsl:value-of select="$topicId"/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="concat('tocId', '-', generate-id(.))"/>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of select="$tocIdNew"/>
						<!--<xsl:message>Attribute wh-toc-id <xsl:value-of select="$tocIdNew"/></xsl:message>-->
					</xsl:attribute>
					
					<title>
						<xsl:choose>
							<xsl:when test="not(empty($title))">
								<xsl:choose>
									<xsl:when
											test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
										<xsl:apply-templates
												select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
												mode="dita-ot:text-only"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:copy-of select="$title"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>***</xsl:otherwise>
						</xsl:choose>
					</title>

					<xsl:variable name="shortDesc" select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/shortdesc ')][1]"/>
					<xsl:if test="$shortDesc and normalize-space($shortDesc)">
						<xsl:variable name="shortDescFixed">
							<xsl:apply-templates select="$shortDesc" mode="fix-shortdesc">
								<xsl:with-param name="base-uri" select="base-uri()"/>
							</xsl:apply-templates>
						</xsl:variable>

						<shortdesc>
							<xsl:apply-templates select="$shortDescFixed/node()"/>
						</shortdesc>
					</xsl:if>
					<xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]"
										 mode="copy-topic-meta"/>
					<xsl:apply-templates mode="toc-webhelp"/>
				</topic>
			</xsl:when>
			<xsl:otherwise>
				<!-- Do not contribute a level in the TOC, but recurse in the child topicrefs -->
				<xsl:apply-templates mode="toc-webhelp"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="/">
		<xsl:variable name="toc">
			<toc>
				<!--	IB: Add support for TOC 'Expand all' / 'Collapse all' buttons. Copy bookmap @xml:lang to the toc.xml root element.-->
				<xsl:copy-of select="/*[contains(@class, ' map/map ')]/@xml:lang"/>
				<!-- WH-257: Copy "chunk" info. -->
				<xsl:copy-of select="/*[contains(@class, ' map/map ')]/@chunk"/>
				<title>
					<xsl:variable name="topicTitle"
								  select="/*[contains(@class, ' map/map ')]/*[contains(@class, ' topic/title ')][1]"/>
					<xsl:choose>
						<xsl:when test="exists($topicTitle)">
							<xsl:element name="span" exclude-result-prefixes="#all"
										 namespace="http://www.w3.org/1999/xhtml">
								<xsl:attribute name="class"
											   select="oxygen:extractLastClassValue($topicTitle/@class)"/>
								<xsl:apply-templates select="$topicTitle/node()"/>
							</xsl:element>
						</xsl:when>

						<xsl:when test="/*[contains(@class, ' map/map ')]/@title">
							<xsl:value-of select="/*[contains(@class, ' map/map ')]/@title"/>
						</xsl:when>
					</xsl:choose>
				</title>
				<!-- Copy meta information from DITA map -->
				<xsl:apply-templates select="/*[contains(@class, ' map/map ')]/*[contains(@class, ' map/topicmeta ')]" mode="copy-topic-meta"/>

				<xsl:apply-templates mode="toc-webhelp"/>
			</toc>
		</xsl:variable>

		<!-- Fixup the namespace to be HTML -->
		<xsl:apply-templates select="$toc" mode="fixup_XHTML_NS"/>

		<!-- Write the TOC IDs to temporary files, next to each topic -->
		<xsl:apply-templates select="$toc" mode="writeTocId"/>
	</xsl:template>

</xsl:stylesheet>
