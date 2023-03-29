<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                version="2.0"
                exclude-result-prefixes="#all">

    <xsl:variable name="id.cover" select="'ID_COVER_00-0F-EA-40-0D-4D'"/>

    <xsl:template match="*[contains(@class, ' topic/topic ')]">
        <xsl:variable name="topicType" as="xs:string">
            <xsl:call-template name="determineTopicType"/>
        </xsl:variable>
        <xsl:variable name="mapTopicref" select="key('map-id', @id)[1]"/>
        <xsl:variable name="topic-lang" select="ancestor-or-self::*[@xml:lang][last()]/@xml:lang"/>
        <xsl:variable name="process-topic" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="normalize-space($mapTopicref/@audience)">
                    <xsl:choose>
                        <!-- multi language publication -->
                        <xsl:when test="$multilingual and contains($mapTopicref/@audience, $topic-lang)">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <xsl:when test="contains($mapTopicref/@audience, $language-combination)">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <!-- single language publication -->
                        <xsl:otherwise>
                            <xsl:sequence select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="true()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$process-topic">
            <xsl:choose>
                <xsl:when test="$multilingual and $topicType = ('topicChapter', 'topicAppendix', 'topicAppendices', 'topicPart')">
                    <xsl:call-template name="processTopicSimple">
                        <xsl:with-param name="topicType" select="'topicChapter'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$topicType = 'topicChapter'">
                    <xsl:call-template name="processTopicChapter"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicAppendix'">
                    <xsl:call-template name="processTopicAppendix"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicAppendices'">
                    <xsl:call-template name="processTopicAppendices"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicPart'">
                    <xsl:call-template name="processTopicPart"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicPreface'">
                    <xsl:call-template name="processTopicPreface"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicNotices'">
                    <xsl:if test="$retain-bookmap-order">
                        <xsl:call-template name="processTopicNotices"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$topicType = 'topicTocList'">
                    <xsl:call-template name="processTocList"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicIndexList'">
                    <xsl:call-template name="processIndexList"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicFrontMatter'">
                    <xsl:call-template name="processFrontMatterTopic"/>
                </xsl:when>
                <xsl:when test="$topicType = 'topicSimple'">
                    <xsl:call-template name="processTopicSimple"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="." mode="processUnknowTopic">
                        <xsl:with-param name="topicType" select="$topicType"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="processUnknowTopic"
                  name="processTopicSimple">
        <xsl:param name="topicType"/>
        <xsl:variable name="page-sequence-reference" select="if ($mapType = 'bookmap') then 'body-sequence' else 'ditamap-body-sequence'"/>
        <xsl:choose>
            <xsl:when test="empty(ancestor::*[contains(@class,' topic/topic ')]) and empty(ancestor::ot-placeholder:glossarylist)">
                <fo:page-sequence master-reference="{$page-sequence-reference}" xsl:use-attribute-sets="page-sequence.body">
                    <xsl:call-template name="startPageNumbering"/>
                    <xsl:call-template name="insertBodyStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:apply-templates select="." mode="processTopic"/>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$multilingual and ($topicType = 'topicChapter')">
                    <xsl:if test="ancestor-or-self::*[contains(@class, ' topic/topic ')][last()][preceding-sibling::*[contains(@class, ' topic/topic ')]]">
                        <fo:block xsl:use-attribute-sets="break.page"/>
                    </xsl:if>
                    <fo:wrapper id="{parent::node()/@id}"/>
                    <fo:wrapper>
                        <xsl:attribute name="id">
                            <xsl:call-template name="generate-toc-id">
                                <xsl:with-param name="element" select=".."/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </fo:wrapper>
                </xsl:if>
                <xsl:apply-templates select="." mode="processTopic"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/notices ')]/*" mode="determineTopicType" priority="10">
        <xsl:text>topicNotices</xsl:text>
    </xsl:template>

    <xsl:template name="processTopicNotices">
        <xsl:variable name="atts" as="element()">
            <xsl:choose>
                <xsl:when test="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)/ancestor::*[contains(@class,' bookmap/backmatter ')]">
                    <dummy xsl:use-attribute-sets="page-sequence.backmatter.notice"/>
                </xsl:when>
                <xsl:otherwise>
                    <dummy xsl:use-attribute-sets="page-sequence.notice"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="first-notices-topicref" select="*[1]"/>
        <xsl:variable name="first-notices-topic" select="/descendant::*[contains(@class, ' topic/topic ')][@id = $first-notices-topicref/@id][1]"/>
        <xsl:variable name="last-notices-topicref" select="*[preceding-sibling::*][last()]"/>
        <xsl:variable name="last-notices-topic" select="/descendant::*[contains(@class, ' topic/topic ')][@id = $last-notices-topicref/@id][1]"/>

        <fo:page-sequence master-reference="body-sequence-notice" xsl:use-attribute-sets="page-sequence.notice">
            <xsl:copy-of select="$atts/@*"/>
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertPrefaceStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:variable name="current-writing-mode" as="xs:string">
                    <xsl:variable name="current-locale" select="lower-case($first-notices-topic/descendant-or-self::*[normalize-space(@xml:lang)][1]/@xml:lang)"/>
                    <xsl:variable name="lang" select="if (contains($current-locale, '_')) then substring-before($current-locale, '_') else $current-locale"/>
                    <xsl:choose>
                        <xsl:when test="some $l in ('ar', 'ar-sa', 'fa', 'he', 'ps', 'ur') satisfies $l eq $lang">rl</xsl:when>
                        <xsl:otherwise>lr</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:if test="empty(ancestor::*[contains(@class, ' topic/topic ')])">
                        <fo:marker marker-class-name="current-topic-number">
                            <!--<xsl:variable name="topicref" select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>-->
                            <xsl:for-each select="$first-notices-topic">
                                <xsl:apply-templates select="." mode="topicTitleNumber"/>
                            </xsl:for-each>
                        </fo:marker>
                        <xsl:apply-templates select="." mode="insertTopicHeaderMarker"/>
                    </xsl:if>

                    <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>

                    <!--
                                        <xsl:apply-templates select="." mode="insertChapterFirstpageStaticContent">
                                            <xsl:with-param name="type" select="'notices'"/>
                                        </xsl:apply-templates>
                    -->
                    <fo:block-container writing-mode="{$current-writing-mode}">

                        <fo:block xsl:use-attribute-sets="topic.title_notice">
                            <!--<xsl:call-template name="pullPrologIndexTerms"/>-->
                            <xsl:for-each select="$first-notices-topic/*[contains(@class,' topic/title ')]">
                                <xsl:apply-templates select="." mode="getTitle"/>
                            </xsl:for-each>
                        </fo:block>

                        <xsl:apply-templates select="$first-notices-topic/*[contains(@class,' topic/body ')]"/>
                    </fo:block-container>
                    <!--
                                        <xsl:choose>
                                            <xsl:when test="$noticesLayout='BASIC'">
                                                <xsl:apply-templates select="*[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                                                                                 contains(@class, ' topic/prolog '))]"/>
                                                &lt;!&ndash;xsl:apply-templates select="." mode="buildRelationships"/&ndash;&gt;
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:apply-templates select="$first-notices-topicref" mode="createMiniToc"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                    -->
                    <fo:block-container writing-mode="{$current-writing-mode}" xsl:use-attribute-sets="notices-data_container">
                        <fo:block xsl:use-attribute-sets="notices-copyrights_content">
                            <xsl:apply-templates select="$last-notices-topic/*[contains(@class,' topic/body ')]"/>
                        </fo:block>
                        <fo:block xsl:use-attribute-sets="notices-data_content">
                            <xsl:value-of select="$release.date"/>
                        </fo:block>
                        <xsl:if test="normalize-space($book.revision)">
                            <fo:block xsl:use-attribute-sets="notices-data_content">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Technote Document Rev'"/>
                                </xsl:call-template>
                                <xsl:value-of select="$book.revision"/>
                            </fo:block>
                        </xsl:if>
                    </fo:block-container>

                    <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/note ')]">
        <xsl:apply-templates select="." mode="placeNoteContent"/>
    </xsl:template>

    <xsl:template match="*" mode="placeNoteContent">
        <xsl:variable name="note-type">
            <xsl:choose>
                <xsl:when test="(@type = 'other') and (lower-case(@othertype) = 'battery')">batterywarning</xsl:when>
                <xsl:when test="@type = ('warning', 'caution', 'danger')">
                    <xsl:value-of select="concat(@type, '-dell')"/>
                </xsl:when>
                <xsl:when test="@type = 'other'">
                    <xsl:text>warning-dell</xsl:text>
                </xsl:when>
                <xsl:otherwise>note-dell</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="image-type">
            <xsl:choose>
                <xsl:when test="@type = 'other'">warning</xsl:when>
                <xsl:when test="@type = ('warning', 'caution')">
                    <xsl:value-of select="lower-case(@type)"/>
                </xsl:when>
                <xsl:otherwise>note</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="note-prefix">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="$note-type"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>

        <fo:table xsl:use-attribute-sets="note_table">
            <fo:table-column column-width="14pt"/>
            <fo:table-column/>
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell xsl:use-attribute-sets="note_image_cell">
                        <xsl:call-template name="insert_admonition_image">
                            <xsl:with-param name="image-type" select="$image-type"/>
                        </xsl:call-template>
                    </fo:table-cell>
                    <fo:table-cell xsl:use-attribute-sets="note_body_cell">
                        <fo:block xsl:use-attribute-sets="note_body_cell_content">
                            <fo:inline xsl:use-attribute-sets="note_body_cell_type">
                                <xsl:value-of select="upper-case($note-prefix)"/>
                                <xsl:if test="not(contains($note-prefix, ':')) and not($lang = 'he')">
                                    <xsl:text>:</xsl:text>
                                </xsl:if>
                                <fo:inline><xsl:text> </xsl:text></fo:inline>
                            </fo:inline>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <xsl:template name="insert_admonition_image">
        <xsl:param name="image-type" select="'note'"/>

        <xsl:variable name="image-path" select="concat($artwork-dir, $image-type, '-black.svg')"/>

        <fo:block xsl:use-attribute-sets="note__image">
            <fo:external-graphic src="url({$image-path})" content-height="12px"/>
        </fo:block>
    </xsl:template>


    <xsl:template match="*" mode="insertChapterFirstpageStaticContent">
        <xsl:param name="type" as="xs:string"/>
        <fo:block>
            <xsl:attribute name="id">
                <xsl:call-template name="generate-toc-id"/>
            </xsl:attribute>
            <fo:marker marker-class-name="current-header">
                <fo:bidi-override>
                    <xsl:attribute name="direction">
                        <xsl:choose>
                            <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                            <xsl:otherwise>ltr</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:apply-templates select="key('map-id', @id)[1]" mode="topicTitleNumber"/>
                </fo:bidi-override>
            </fo:marker>
<!--
            <fo:block xsl:use-attribute-sets="chapter_header_number">
                <xsl:apply-templates select="key('map-id', @id)[1]" mode="topicTitleNumber"/>
            </fo:block>
-->
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/section ')]/*[contains(@class,' topic/title ')]">
        <xsl:variable name="level">
            <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])+1"/>
            <!--
                        <xsl:choose>
                            <xsl:when test="$multilingual = 'yes'">
                                <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/>
                            </xsl:when>
                            &lt;!&ndash; Balaji Mani 8-Sep-2014: add to reduce one level for part &ndash;&gt;
                            <xsl:when test="ancestor::*[@id=preceding::*[ancestor-or-self::part]/@id]">
                                <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="count(ancestor::*[contains(@class,' topic/topic ')])+1"/>
                            </xsl:otherwise>
                        </xsl:choose>
            -->
        </xsl:variable>

        <xsl:variable name="attrSet1">
            <xsl:apply-templates select="." mode="createTopicAttrsName">
                <xsl:with-param name="theCounter" select="$level"/>
            </xsl:apply-templates>
        </xsl:variable>
        <fo:block id="{@id}">
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="$attrSet1"/>
                <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
            </xsl:call-template>

            <fo:inline id="{concat('_OPENTOPIC_TOC_PROCESSING_', generate-id(parent::*))}"/>
            <xsl:apply-templates select="." mode="getTitle"/>
        </fo:block>
    </xsl:template>
	<xsl:template match="*" mode="commonTopicProcessing">
      <xsl:if test="empty(ancestor::*[contains(@class, ' topic/topic ')])">
        <fo:marker marker-class-name="current-topic-number">
          <xsl:variable name="topicref" select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
          <xsl:for-each select="$topicref">
            <xsl:apply-templates select="." mode="topicTitleNumber"/>
          </xsl:for-each>
        </fo:marker>
      </xsl:if>
      <fo:block>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="flag-attributes"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
		<xsl:if test="(lower-case($include-guids) = 'yes') and normalize-space(@oid)">
            <fo:block xsl:use-attribute-sets="topic_guid">
                <xsl:value-of select="@oid"/>
            </fo:block>
        </xsl:if>
        <xsl:apply-templates select="*[contains(@class, ' topic/prolog ')]"/>
        <xsl:apply-templates select="*[not(contains(@class, ' topic/title ')) and
                                       not(contains(@class, ' topic/prolog ')) and
                                       not(contains(@class, ' topic/topic '))]"/>
        <!--xsl:apply-templates select="." mode="buildRelationships"/-->
        <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
        <xsl:apply-templates select="." mode="topicEpilog"/>
      </fo:block>
    </xsl:template>
	<xsl:template name="processTopicAppendix">
        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="page-sequence.appendix">
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:variable name="level" as="xs:integer">
                      <xsl:apply-templates select="." mode="get-topic-level"/>
                    </xsl:variable>
                    <xsl:if test="$level eq 1">
                        <fo:marker marker-class-name="current-topic-number">
                            <xsl:variable name="topicref" select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                            <xsl:for-each select="$topicref">
                              <xsl:apply-templates select="." mode="topicTitleNumber"/>
                            </xsl:for-each>
                        </fo:marker>
                        <xsl:apply-templates select="." mode="insertTopicHeaderMarker"/>
                    </xsl:if>

                    <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>

                    <xsl:apply-templates select="." mode="insertChapterFirstpageStaticContent">
                        <xsl:with-param name="type" select="'appendix'"/>
                    </xsl:apply-templates>

                    <fo:block xsl:use-attribute-sets="topic.title">
                        <xsl:call-template name="pullPrologIndexTerms"/>
                        <xsl:for-each select="*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>
                    </fo:block>
					<xsl:if test="(lower-case($include-guids) = 'yes') and normalize-space(@oid)">
						<fo:block xsl:use-attribute-sets="topic_guid">
							<xsl:value-of select="@oid"/>
						</fo:block>
					</xsl:if>
                    <xsl:choose>
                      <xsl:when test="$appendixLayout='BASIC'">
                          <xsl:apply-templates select="*[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                                                             contains(@class, ' topic/prolog '))]"/>
                          <!--xsl:apply-templates select="." mode="buildRelationships"/-->
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:apply-templates select="." mode="createMiniToc"/>
                      </xsl:otherwise>
                    </xsl:choose>

                    <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
                    <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
	<xsl:template name="processTopicChapter">
        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="page-sequence.body">
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:variable name="level" as="xs:integer">
                      <xsl:apply-templates select="." mode="get-topic-level"/>
                    </xsl:variable>
                    <xsl:if test="$level eq 1">
                        <fo:marker marker-class-name="current-topic-number">
                          <xsl:variable name="topicref" select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                          <xsl:for-each select="$topicref">
                            <xsl:apply-templates select="." mode="topicTitleNumber"/>
                          </xsl:for-each>
                        </fo:marker>
                        <xsl:apply-templates select="." mode="insertTopicHeaderMarker"/>
                    </xsl:if>

                    <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>

                    <xsl:apply-templates select="." mode="insertChapterFirstpageStaticContent">
                        <xsl:with-param name="type" select="'chapter'"/>
                    </xsl:apply-templates>

                    <fo:block xsl:use-attribute-sets="topic.title">
                        <xsl:call-template name="pullPrologIndexTerms"/>
                        <xsl:for-each select="*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>
                    </fo:block>
						<xsl:if test="(lower-case($include-guids) = 'yes') and normalize-space(@oid)">
							<fo:block xsl:use-attribute-sets="topic_guid">
								<xsl:value-of select="@oid"/>
							</fo:block>
						</xsl:if>
                    <xsl:choose>
                      <xsl:when test="$chapterLayout='BASIC'">
                          <xsl:apply-templates select="*[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                                                             contains(@class, ' topic/prolog '))]"/>
                          <!--xsl:apply-templates select="." mode="buildRelationships"/-->
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:apply-templates select="." mode="createMiniToc"/>
                      </xsl:otherwise>
                    </xsl:choose>

                    <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
                    <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>
  <xsl:template name="processTopicPart">
        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="page-sequence.part">
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:if test="empty(ancestor::*[contains(@class, ' topic/topic ')])">
                        <fo:marker marker-class-name="current-topic-number">
                          <xsl:variable name="topicref" select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                          <xsl:for-each select="$topicref">
                            <xsl:apply-templates select="." mode="topicTitleNumber"/>
                          </xsl:for-each>
                        </fo:marker>
                        <xsl:apply-templates select="." mode="insertTopicHeaderMarker"/>
                    </xsl:if>

                    <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>

                    <xsl:apply-templates select="." mode="insertChapterFirstpageStaticContent">
                        <xsl:with-param name="type" select="'part'"/>
                    </xsl:apply-templates>

                    <fo:block xsl:use-attribute-sets="topic.title">
                        <xsl:call-template name="pullPrologIndexTerms"/>
                        <xsl:for-each select="*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>
                    </fo:block>
					<xsl:if test="(lower-case($include-guids) = 'yes') and normalize-space(@oid)">
						<fo:block xsl:use-attribute-sets="topic_guid">
								<xsl:value-of select="@oid"/>
						</fo:block>
					</xsl:if>
                    <xsl:choose>
                      <xsl:when test="$partLayout='BASIC'">
                          <xsl:apply-templates select="*[not(contains(@class, ' topic/topic ') or contains(@class, ' topic/title ') or
                                                             contains(@class, ' topic/prolog '))]"/>
                          <!--xsl:apply-templates select="." mode="buildRelationships"/-->
                      </xsl:when>
                      <xsl:otherwise>
                          <xsl:apply-templates select="." mode="createMiniToc"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:for-each select="*[contains(@class,' topic/topic ')]">
                        <xsl:variable name="topicType" as="xs:string">
                            <xsl:call-template name="determineTopicType"/>
                        </xsl:variable>
                        <xsl:if test="$topicType = 'topicSimple'">
                            <xsl:apply-templates select="."/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
        <xsl:for-each select="*[contains(@class,' topic/topic ')]">
            <xsl:variable name="topicType" as="xs:string">
                <xsl:call-template name="determineTopicType"/>
            </xsl:variable>
            <xsl:if test="not($topicType = 'topicSimple')">
                <xsl:apply-templates select="."/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>