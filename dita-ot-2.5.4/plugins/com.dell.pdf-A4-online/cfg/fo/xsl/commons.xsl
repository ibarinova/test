<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                version="2.0"
                exclude-result-prefixes="#all">

    <xsl:variable name="id.cover" select="'ID_COVER_00-0F-EA-40-0D-4D'"/>

    <xsl:template match="*[contains(@class, ' bookmap/notices ')]/*" mode="determineTopicType" priority="10">
        <xsl:text>topicNotices</xsl:text>
    </xsl:template>

    <xsl:template name="processTechnote">
        <xsl:variable name="topics">
            <xsl:copy-of select="/descendant::opentopic:map[1]"/>
            <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')]">
                <xsl:variable name="topicType">
                    <xsl:call-template name="determineTopicType"/>
                </xsl:variable>
                <xsl:if test="not($topicType = 'topicNotices')">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="page-sequence.body">
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:apply-templates select="$topics/*[contains(@class, ' topic/topic ')]" mode="processTopic"/>
            </fo:flow>
        </fo:page-sequence>


        <xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/notices ')]" mode="generatePageSequences"/>
    </xsl:template>

    <xsl:template name="processNochap">
        <xsl:variable name="topics">
            <xsl:copy-of select="/descendant::opentopic:map[1]"/>
            <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')]">
                <xsl:variable name="topicType">
                    <xsl:call-template name="determineTopicType"/>
                </xsl:variable>
                <xsl:if test="not($topicType = 'topicNotices')">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="page-sequence.body">
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertBodyStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <xsl:apply-templates select="$topics/*[contains(@class, ' topic/topic ')]" mode="processTopic"/>
            </fo:flow>
        </fo:page-sequence>


        <xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/notices ')]" mode="generatePageSequences"/>
    </xsl:template>

    <xsl:template match="*" mode="insertChapterFirstpageStaticContent">
        <xsl:param name="type" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">
                <fo:block>
                    <xsl:attribute name="id">
                        <xsl:call-template name="generate-toc-id"/>
                    </xsl:attribute>
                    <fo:block>
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
                    </fo:block>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block>
                    <xsl:attribute name="id">
                        <xsl:call-template name="generate-toc-id"/>
                    </xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$type = 'preface'">
                            <xsl:variable name="preface-title">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Preface title'"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <xsl:call-template name="insertBlueBarHeader">
                                <xsl:with-param name="content" select="$preface-title"/>
                                <xsl:with-param name="type" select="'txt'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$type = 'appendix'">
                            <xsl:call-template name="insertBlueBarHeader">
                                <xsl:with-param name="content">
                                    <xsl:apply-templates select="key('map-id', @id)[1]" mode="topicTitleNumber"/>
                                </xsl:with-param>
                                <xsl:with-param name="type" select="'number'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$type = 'chapter'">
                            <xsl:call-template name="insertBlueBarHeader">
                                <xsl:with-param name="content">
                                    <xsl:apply-templates select="key('map-id', @id)[1]" mode="topicTitleNumber"/>
                                </xsl:with-param>
                                <xsl:with-param name="type" select="'number'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="insertBlueBarHeader">
                                <xsl:with-param name="content">
                                    <xsl:apply-templates select="key('map-id', @id)[1]" mode="topicTitleNumber"/>
                                </xsl:with-param>
                                <xsl:with-param name="type" select="'number'"/>
                            </xsl:call-template>
                        </xsl:otherwise>
                    </xsl:choose>
                    <fo:block margin-top="16mm"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="lower-case($include-metadata) = 'yes'">
            <xsl:call-template name="insert-pubmeta-data"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="processTopicPreface">
        <fo:page-sequence master-reference="body-sequence" xsl:use-attribute-sets="page-sequence.preface">
            <xsl:choose>
                <xsl:when test="following-sibling::ot-placeholder:toc">
                    <xsl:call-template name="insertPrefaceStaticContents"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="insertBodyStaticContents"/>
                </xsl:otherwise>
            </xsl:choose>
            <fo:flow flow-name="xsl-region-body">
                <fo:block xsl:use-attribute-sets="topic">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:if test="not(ancestor::*[contains(@class, ' topic/topic ')])">
                        <fo:marker marker-class-name="current-topic-number">
                            <xsl:number format="1"/>
                        </fo:marker>
                        <xsl:apply-templates select="." mode="insertTopicHeaderMarker"/>
                    </xsl:if>
                    <xsl:apply-templates select="*[contains(@class,' topic/prolog ')]"/>
                    <xsl:apply-templates select="." mode="insertChapterFirstpageStaticContent">
                        <xsl:with-param name="type" select="'preface'"/>
                    </xsl:apply-templates>
                    <fo:block xsl:use-attribute-sets="topic.title">
                        <xsl:call-template name="pullPrologIndexTerms"/>
                        <!--<xsl:for-each select="child::*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>-->
                    </fo:block>
                    <xsl:call-template name="getTopicNumbering"/>
                    <xsl:apply-templates select="*[not(contains(@class,' topic/title '))]"/>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
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

        <fo:page-sequence master-reference="body-sequence">
            <xsl:copy-of select="$atts/@*"/>
            <xsl:call-template name="startPageNumbering"/>
            <xsl:call-template name="insertPrefaceStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
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
                    <xsl:if test="lower-case($include-metadata) = 'yes'">
                        <xsl:for-each select="$first-notices-topic">
                            <xsl:call-template name="insert-pubmeta-data"/>
                        </xsl:for-each>
                    </xsl:if>
                    <xsl:for-each select="$first-notices-topic">
                        <fo:block>
                            <xsl:call-template name="insertXmlLangAttr">
                                <xsl:with-param name="xml-lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                            </xsl:call-template>
                            <fo:block xsl:use-attribute-sets="topic.title_notice">
                                <xsl:for-each select="*[contains(@class,' topic/title ')]">
                                    <xsl:apply-templates select="." mode="getTitle"/>
                                </xsl:for-each>
                            </fo:block>

                            <xsl:apply-templates select="*[contains(@class,' topic/body ')]"/>
                        </fo:block>
                    </xsl:for-each>
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
                    <fo:block-container xsl:use-attribute-sets="notices-data_container">
                        <fo:block xsl:use-attribute-sets="notices-copyrights_content">
                            <xsl:apply-templates select="$last-notices-topic/*[contains(@class,' topic/body ')]"/>
                        </fo:block>
                        <!--<fo:block xsl:use-attribute-sets="notices-data_content">
                            <xsl:value-of select="$release.date"/>
                        </fo:block>
                        <xsl:if test="normalize-space($book.revision)">
                            <fo:block xsl:use-attribute-sets="notices-data_content">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Technote Document Rev'"/>
                                </xsl:call-template>
                                <xsl:value-of select="$book.revision"/>
                            </fo:block>
                        </xsl:if>-->
                    </fo:block-container>

                    <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                </fo:block>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <xsl:template name="insertBlueBarHeader">
        <xsl:param name="content"/>
        <xsl:param name="type" select="'number'"/>
        <fo:block-container xsl:use-attribute-sets="header_blue_bar_container">
            <xsl:attribute name="font-size">
                <xsl:choose>
                    <xsl:when test="$type = 'number'">28pt</xsl:when>
                    <xsl:when test="$lang = 'el'">23pt</xsl:when>
                    <xsl:otherwise>26pt</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <fo:block xsl:use-attribute-sets="header_blue_bar_content">
                <fo:bidi-override>
                    <xsl:attribute name="direction">
                        <xsl:choose>
                            <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                            <xsl:otherwise>ltr</xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:value-of select="$content"/>
                </fo:bidi-override>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template match="*" mode="createMiniToc">
        <xsl:choose>
            <xsl:when test="$isTechnote">
                <xsl:if test="*[contains(@class, ' topic/topic ')][not(contains(@outputclass, 'notice'))] and $mini-toc-required">
                    <fo:block xsl:use-attribute-sets="__toc__mini__header_technote">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'dsg topics'"/>
                        </xsl:call-template>
                    </fo:block>
                    <fo:list-block xsl:use-attribute-sets="__toc__mini__list">
                        <xsl:apply-templates select="*[contains(@class, ' topic/topic ')][not(contains(@outputclass, 'notice'))]" mode="in-this-chapter-list"/>
                    </fo:list-block>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$isNochap">
                <xsl:if test="*[contains(@class, ' topic/topic ')][not(contains(@outputclass, 'notice'))]  and $mini-toc-required">
                    <fo:list-block xsl:use-attribute-sets="__toc__mini__list">
                        <xsl:apply-templates select="*[contains(@class, ' topic/topic ')][not(contains(@outputclass, 'notice'))]" mode="in-this-chapter-list"/>
                    </fo:list-block>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
<!--                <fo:block>-->
                    <xsl:apply-templates select="*[contains(@class,' topic/titlealts ')]"/>

                    <xsl:if test="*[contains(@class,' topic/shortdesc ') or contains(@class, ' topic/abstract ')]/node()">
                        <fo:block xsl:use-attribute-sets="p">
                            <xsl:apply-templates select="*[contains(@class,' topic/shortdesc ') or contains(@class, ' topic/abstract ')]/node()"/>
                        </fo:block>
                    </xsl:if>

                    <xsl:apply-templates select="*[contains(@class,' topic/body ')]/*"/>

                    <xsl:if test="*[contains(@class,' topic/related-links ')]//*[contains(@class,' topic/link ')][not(@role) or @role!='child']">
                        <xsl:apply-templates select="*[contains(@class,' topic/related-links ')]"/>
                    </xsl:if>
<!--                </fo:block>-->

                <xsl:if test="*[contains(@class, ' topic/topic ')] and $mini-toc-required">
                    <fo:block xsl:use-attribute-sets="__toc__mini__header">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'dsg topics'"/>
                        </xsl:call-template>
                    </fo:block>
                    <fo:list-block xsl:use-attribute-sets="__toc__mini__list">
                        <xsl:apply-templates select="*[contains(@class, ' topic/topic ')]" mode="in-this-chapter-list"/>
                    </fo:list-block>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="in-this-chapter-list">
        <fo:list-item xsl:use-attribute-sets="ul.li">
            <fo:list-item-label xsl:use-attribute-sets="ul.li__label">
                <fo:block xsl:use-attribute-sets="ul.li__label__content">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Unordered List bullet'"/>
                    </xsl:call-template>
                </fo:block>
            </fo:list-item-label>

            <fo:list-item-body xsl:use-attribute-sets="ul.li__body">
                <xsl:choose>
                    <xsl:when test="$isNochap">
                        <fo:block xsl:use-attribute-sets="minitoc__ul.li__content">
                            <fo:basic-link internal-destination="{@id}" xsl:use-attribute-sets="__toc__link">
                                <fo:inline xsl:use-attribute-sets="xref">
                                    <xsl:call-template name="getTopicNumbering"/>
                                    <xsl:value-of select="*[contains(@class, ' topic/title ')]"/>
                                </fo:inline>
                                <fo:inline xsl:use-attribute-sets="__toc__page-number">
                                    <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                                    <fo:page-number-citation ref-id="{@id}"/>
                                </fo:inline>
                            </fo:basic-link>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block xsl:use-attribute-sets="ul.li__content">
                            <fo:basic-link internal-destination="{@id}" xsl:use-attribute-sets="xref">
                                <xsl:call-template name="getTopicNumbering"/>
                                <xsl:value-of select="*[contains(@class, ' topic/title ')]"/>
                            </fo:basic-link>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/note ')]">
        <xsl:apply-templates select="." mode="placeNoteContent"/>
    </xsl:template>

    <xsl:template match="*" mode="placeNoteContent">
        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="@type = ('warning', 'caution')">
                    <xsl:value-of select="@type"/>
                </xsl:when>
                <xsl:otherwise>note</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="image-type">
            <xsl:choose>
                <xsl:when test="$dell-brand = ('Non-brand', 'Alienware')">
                    <xsl:choose>
                        <xsl:when test="@type = 'warning'">warning-black</xsl:when>
                        <xsl:when test="@type = 'caution'">caution-black</xsl:when>
                        <xsl:otherwise>note-black</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="@type = 'warning'">warning</xsl:when>
                        <xsl:when test="@type = 'caution'">caution</xsl:when>
                        <xsl:otherwise>note</xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>

        <fo:table xsl:use-attribute-sets="note_table">
            <fo:table-column column-width="{if(ancestor::table) then('13pt') else('15pt')}"/>
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
                            <xsl:variable name="note-text">
                                <xsl:call-template name="insert_admonition_text">
                                    <xsl:with-param name="type" select="$type"/>
                                </xsl:call-template>
                            </xsl:variable>
                            <fo:inline xsl:use-attribute-sets="note_colored_text">
                                <xsl:value-of select="upper-case($note-text)"/>
                                <xsl:if test="not(contains($note-text, ':')) and not($lang = 'he')">
                                    <xsl:value-of select="':'"/>
                                </xsl:if>
                            </fo:inline>
                            <fo:inline><xsl:text> </xsl:text></fo:inline>
                            <xsl:apply-templates/>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <xsl:template name="insert_admonition_image">
        <xsl:param name="image-type" select="'note'"/>

        <xsl:variable name="image-path" select="concat($artwork-dir, $image-type, '.svg')"/>

        <xsl:choose>
            <xsl:when test="ancestor::table">
                <fo:block xsl:use-attribute-sets="note__image">
                    <fo:external-graphic src="url({$image-path})" content-height="14px"/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="note__image">
                    <fo:external-graphic src="url({$image-path})" content-height="16px"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="insert_admonition_text">
        <xsl:param name="type" select="'note'"/>
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="concat($type, '-dell')"/>
        </xsl:call-template>
    </xsl:template>

	<xsl:template match="*" mode="commonTopicProcessing">
        <xsl:variable name="mapTopicref" select="key('map-id', @id)[1]"/>

        <xsl:variable name="isChapter" select="contains($mapTopicref/@class, ' bookmap/chapter ')
                                            or contains($mapTopicref/@class, ' bookmap/appendix ')
                                            or contains($mapTopicref/@class, ' bookmap/part ')" as="xs:boolean"/>
        <xsl:variable name="currentChapterNumber" select="count($mapTopicref/preceding-sibling::*[contains(@class, ' bookmap/chapter ')]) + 1"/>

        <xsl:if test="empty(ancestor::*[contains(@class, ' topic/topic ')])">
            <fo:marker marker-class-name="current-topic-number">
                <xsl:variable name="topicref" select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
                <xsl:for-each select="$topicref">
                    <xsl:apply-templates select="." mode="topicTitleNumber"/>
                </xsl:for-each>
            </fo:marker>
            <xsl:choose>
                <xsl:when test="$isTechnote and $isChapter and $currentChapterNumber = 1">
                    <xsl:call-template name="insert-technote-main-bluebar-header"/>
                </xsl:when>
                <xsl:when test="$isTechnote and not($isChapter)">
                    <xsl:call-template name="insert-technote-main-bluebar-header"/>
                </xsl:when>
                <xsl:when test="$isNochap and $isChapter and $currentChapterNumber = 1">
                    <xsl:call-template name="insert-nochap-main-bluebar-header"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="flag-attributes"/>
        <xsl:choose>
            <xsl:when test="$isTechnote and $isChapter and $currentChapterNumber = 1">
                <xsl:variable name="mainBookTitle">
                    <xsl:value-of>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                    </xsl:value-of>
                    <xsl:text> </xsl:text>
                    <xsl:for-each select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                        <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:variable>
                <fo:marker marker-class-name="current-header">
                    <fo:bidi-override>
                        <xsl:attribute name="direction">
                            <xsl:choose>
                                <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                <xsl:otherwise>ltr</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$mainBookTitle"/>
                    </fo:bidi-override>
                </fo:marker>
                <!--added table format for draft/beta for technote-->
                <fo:block-container xsl:use-attribute-sets="restriction.watermark_container.technote">
                    <fo:block>
                        <fo:table>
                            <fo:table-column column-number="1" column-width="15%"/>
                            <fo:table-column column-number="2" column-width="85%"/>
                            <fo:table-body>
                                <fo:table-row>
                                    <fo:table-cell>
                                        <xsl:if test="normalize-space($watermark-value)">
                                            <fo:block>
                                                <fo:inline xsl:use-attribute-sets="restriction.draft.watermark">
                                                    <xsl:value-of select="$watermark-value"/>
                                                </fo:inline>
                                            </fo:block>
                                        </xsl:if>
                                    </fo:table-cell>
                                    <fo:table-cell>
                                        <xsl:if test="normalize-space($restriction-value)">
                                            <fo:block>
                                                <fo:inline xsl:use-attribute-sets="restriction.watermark">
                                                    <xsl:value-of select="$restriction-value"/>
                                                </fo:inline>
                                            </fo:block>
                                        </xsl:if>
                                    </fo:table-cell>
                                </fo:table-row>
                            </fo:table-body>
                        </fo:table>
                    </fo:block>
                </fo:block-container>
                <fo:block xsl:use-attribute-sets="topic.title_technote" id="{$id.cover}">
                    <xsl:value-of select="$mainBookTitle"/>
                </fo:block>
                <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
            </xsl:when>
            <xsl:when test="$isTechnote and not($isChapter) and empty(ancestor::*[contains(@class, ' topic/topic ')])">
                <xsl:variable name="mainBookTitle">
                    <xsl:value-of>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                    </xsl:value-of>
                    <xsl:text> </xsl:text>
                    <xsl:for-each select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                        <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:variable>
                <fo:marker marker-class-name="current-header">
                    <fo:bidi-override>
                        <xsl:attribute name="direction">
                            <xsl:choose>
                                <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                <xsl:otherwise>ltr</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$mainBookTitle"/>
                    </fo:bidi-override>
                </fo:marker>
                <xsl:if test="normalize-space($restriction-value)">
                    <fo:block-container xsl:use-attribute-sets="restriction.watermark_container.technote">
                        <fo:block>
                            <fo:inline xsl:use-attribute-sets="restriction.watermark">
                                <xsl:value-of select="$restriction-value"/>
                            </fo:inline>
                        </fo:block>
                    </fo:block-container>
                </xsl:if>
                <fo:block xsl:use-attribute-sets="topic.title_technote" id="{$id.cover}">
                    <xsl:value-of select="$mainBookTitle"/>
                </fo:block>
            </xsl:when>
            <xsl:when test="$isNochap and $isChapter and $currentChapterNumber = 1">
                <xsl:variable name="mainBookTitle">
                    <xsl:value-of>
                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                    </xsl:value-of>
                </xsl:variable>
                <xsl:variable name="bookTitleAlts">
                    <xsl:for-each select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                        <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="chapterTitle">
                    <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="dita-ot:text-only"/>
                </xsl:variable>
                <fo:marker marker-class-name="current-header">
                    <fo:bidi-override>
                        <xsl:attribute name="direction">
                            <xsl:choose>
                                <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                <xsl:otherwise>ltr</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:value-of select="$mainBookTitle"/>
                    </fo:bidi-override>
                </fo:marker>
                <fo:block-container xsl:use-attribute-sets="topic.titlealt_nochap_container">
                    <fo:block xsl:use-attribute-sets="topic.titlealt_nochap">
                        <xsl:value-of select="$bookTitleAlts"/>
                    </fo:block>
                </fo:block-container>
                <fo:block xsl:use-attribute-sets="topic.title_nochap" id="{$id.cover}">
                    <xsl:value-of select="$mainBookTitle"/>
                </fo:block>
                <fo:block xsl:use-attribute-sets="cover_vrm_nochap">
                    <xsl:if test="$book.vrm!='0' and $book.vrm!='0.0' and $book.vrm!=''">
                        <xsl:choose>
                            <xsl:when test="$use-vrm-string_ver">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Version'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$book.vrm"/>
                            </xsl:when>
                            <xsl:when test="$use-vrm-string_rel">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'release'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$book.vrm"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$book.vrm"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                </fo:block>
                <xsl:if test="normalize-space($chapterTitle)">
                    <fo:block xsl:use-attribute-sets="cover_chaptet.title_nochap">
                        <xsl:value-of select="$chapterTitle"/>
                    </fo:block>
                </xsl:if>
                <xsl:if test="normalize-space($book.revision)">
                    <fo:block xsl:use-attribute-sets="cover_rev_nochap">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Technote Document Rev'"/>
                        </xsl:call-template>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$book.revision"/>
                    </fo:block>
                </xsl:if>
                <xsl:if test="normalize-space($release.date)">
                    <fo:block xsl:use-attribute-sets="cover_rev_nochap">
                        <xsl:value-of select="$release.date"/>
                    </fo:block>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="(lower-case($include-guids) = 'yes') and normalize-space(@oid)">
            <fo:block xsl:use-attribute-sets="topic_guid">
                <xsl:value-of select="@oid"/>
            </fo:block>
        </xsl:if>
        <xsl:apply-templates select="*[contains(@class, ' topic/prolog ')]"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/shortdesc ')]"/>
        <xsl:choose>
            <xsl:when test="$isTechnote and $isChapter and $currentChapterNumber = 1">
                <xsl:call-template name="insert-technote-release-data"/>
                <xsl:apply-templates select="." mode="createMiniToc"/>
            </xsl:when>
            <xsl:when test="$isTechnote and empty(ancestor::*[contains(@class, ' topic/topic ')]) and not($isChapter)">
                <xsl:call-template name="insert-technote-release-data"/>
                <xsl:apply-templates select="." mode="createMiniToc"/>
            </xsl:when>
            <xsl:when test="$isNochap and $isChapter and $currentChapterNumber = 1">
                <xsl:call-template name="insert-solutions-abstract-frontmatter-block_nochap"/>
                <xsl:call-template name="insert-solutions-author-frontmatter-block_nochap"/>
                <fo:block xsl:use-attribute-sets="topic.body_nochap_1_chapter">
                    <xsl:apply-templates select="*[contains(@class,' topic/body ')]"/>
                </fo:block>
                <xsl:apply-templates select="." mode="createMiniToc"/>
                <fo:block xsl:use-attribute-sets="break.page.after"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="not($isNochap and $isChapter and $currentChapterNumber = 1)">
            <xsl:apply-templates select="*[not(contains(@class, ' topic/title ')) and
                                   not(contains(@class, ' topic/prolog ')) and
                                   not(contains(@class, ' topic/shortdesc ')) and
                                   not(contains(@class, ' topic/topic '))]"/>
        </xsl:if>
        <!--xsl:apply-templates select="." mode="buildRelationships"/-->
        <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
        <xsl:apply-templates select="." mode="topicEpilog"/>
    </xsl:template>

	<xsl:template name="insert-pubmeta-data">
        <xsl:variable name="topic-id" select="ancestor-or-self::*[contains(@class, ' topic/topic ')][normalize-space(@oid)][1]/@oid"/>
        <xsl:variable name="input-met-name" select="concat($topic-id, '.met')"/>
        <xsl:variable name="input-met-uri" select="concat($input-dir-location, $input-met-name)"/>
        <xsl:variable name="input-met-doc" select="if(doc-available($input-met-uri)) then(document($input-met-uri)) else('')"/>

        <xsl:if test="doc-available($input-met-uri)">
            <xsl:variable name="topic-status" select="$input-met-doc/descendant::*[@name='FSTATUS'][1]"/>
            <xsl:variable name="topic-version" select="$input-met-doc/descendant::*[@name='VERSION']"/>
            <fo:block xsl:use-attribute-sets="pubmeta_data_container">
                <fo:table table-layout="fixed" border-style="solid" border-width="thin">
                    <xsl:choose>
                        <xsl:when test="$topic-status='To be translated'">
                            <xsl:attribute name="border-color">red</xsl:attribute>
                            <xsl:attribute name="color">red</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$topic-status='In translation'">
                            <xsl:attribute name="border-color">#E6B406</xsl:attribute>
                            <xsl:attribute name="color">#E6B406</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$topic-status='Translated'">
                            <xsl:attribute name="border-color">#0000ff</xsl:attribute>
                            <xsl:attribute name="color">#0000ff</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$topic-status='Translation Validated'">
                            <xsl:attribute name="border-color">#006400</xsl:attribute>
                            <xsl:attribute name="color">#006400</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$topic-status='Translation Rejected'">
                            <xsl:attribute name="border-color">#A52A2A</xsl:attribute>
                            <xsl:attribute name="color">#A52A2A</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$topic-status='Released'">
                            <xsl:attribute name="border-color">#90EE90</xsl:attribute>
                            <xsl:attribute name="color">#90EE90</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$topic-status='To be deleted'">
                            <xsl:attribute name="border-color">black</xsl:attribute>
                            <xsl:attribute name="color">black</xsl:attribute>
                        </xsl:when>
                    </xsl:choose>

                    <fo:table-column column-width="25%"/>
                    <fo:table-column column-width="75%"/>
                    <fo:table-body>
                        <!-- Topic GUID-->
                        <fo:table-row keep-with-next.within-column='always'
                                      keep-with-previous.within-column='always'>
                            <fo:table-cell>
                                <fo:block start-indent="2pt">Identifier</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block start-indent="2pt">
                                    <xsl:value-of select="$topic-id"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                        <!-- Added topic version IDPL8034 Roopesh Dell -->
                        <fo:table-row keep-with-next.within-column='always'
                                      keep-with-previous.within-column='always'>
                            <fo:table-cell>
                                <fo:block start-indent="2pt">Version</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block start-indent="2pt">
                                    <xsl:value-of select="$topic-version"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                        <!-- Topic status-->
                        <fo:table-row keep-with-next.within-column='always'
                                      keep-with-previous.within-column='always'>
                            <fo:table-cell>
                                <fo:block start-indent="2pt">Status</fo:block>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block start-indent="2pt">
                                    <xsl:value-of select="$topic-status"/>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template name="insert-solutions-abstract-frontmatter-block_nochap">
        <xsl:variable name="shortdesc">
            <xsl:apply-templates select="/descendant::*[contains(@class,' bookmap/bookmeta ')][1]/descendant::*[contains(@class,' map/shortdesc ')][1][contains(@outputclass, 'abstract')][1]"/>
        </xsl:variable>
        <xsl:if test="normalize-space($shortdesc)">
            <fo:block xsl:use-attribute-sets="__frontmatter__solutions_abstrac_title">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Abstract'"/>
                </xsl:call-template>
            </fo:block>
            <fo:block xsl:use-attribute-sets="__frontmatter__solutions_shortdesc">
                <xsl:value-of select="$shortdesc"/>
            </fo:block>
        </xsl:if>
    </xsl:template>

	<xsl:template name="insert-solutions-author-frontmatter-block_nochap">
        <xsl:variable name="author" select="/descendant::*[contains(@class,' bookmap/bookmeta ')][1]/descendant::*[contains(@class,' topic/author ')][1]"/>
        <xsl:if test="normalize-space($author)">
            <fo:block xsl:use-attribute-sets="__frontmatter__author">
                <xsl:value-of select="$author"/>
            </fo:block>
        </xsl:if>
    </xsl:template>

	<xsl:template name="insert-technote-main-bluebar-header">
        <fo:block-container xsl:use-attribute-sets="technote-main-bluebar-header_container">
            <fo:block xsl:use-attribute-sets="technote-main-bluebar-header">
                <fo:table xsl:use-attribute-sets="__frontmatter_footer_table">
                    <fo:table-column column-width="60%"/>
                    <fo:table-column column-width="40%"/>
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell xsl:use-attribute-sets="__frontmatter_footer_content_cell">
                                <xsl:if test="normalize-space($book.docnumber)">
                                    <fo:block>
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'Technote Document Number'"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="$book.docnumber"/>
                                    </fo:block>
                                </xsl:if>
                                <xsl:if test="normalize-space($book.revision)">
                                    <fo:block>
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'Technote Document Rev'"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="$book.revision"/>
                                    </fo:block>
                                </xsl:if>
                                <xsl:if test="normalize-space($release.date)">
                                    <fo:block>
                                        <xsl:value-of select="$release.date"/>
                                    </fo:block>
                                </xsl:if>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block xsl:use-attribute-sets="__technote_header_logo">
                                    <xsl:variable name="logo-path">
                                        <xsl:choose>
                                            <xsl:when test="$dell-brand = 'Dell EMC'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'dellemc-white.svg')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'Alienware'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'White_Alienware-Logo.png')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'RSA'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'rsa-logo-white.png')"/>
                                            </xsl:when>
											<!--Added Dell technology logo-->
											<xsl:when test="$dell-brand = 'Dell Technologies'">
                                               <xsl:value-of select="concat($artwork-logo-dir, 'DellTech_Logo_Wht.svg')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="concat($artwork-logo-dir, 'dell-white.svg')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <xsl:variable name="logo-width">
                                        <xsl:choose>
                                            <xsl:when test="$dell-brand = 'Dell EMC'">1.7in</xsl:when>
                                            <xsl:when test="$dell-brand = 'Alienware'">1.7in</xsl:when>
                                            <xsl:when test="$dell-brand = 'RSA'">1in</xsl:when>
											<xsl:when test="$dell-brand = 'Dell Technologies'">2.623in</xsl:when>
                                            <xsl:otherwise>0.65in</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <xsl:if test="not($dell-brand = 'Non-brand')">
                                        <fo:external-graphic src="url('{$logo-path}')"
                                                             width="{$logo-width}"
                                                             content-width="{$logo-width}"
                                                             content-height="scale-to-fit"
                                                             scaling="uniform"/>
                                    </xsl:if>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <!--Changed regulatory and partnumber processing-->
    <xsl:template name="insert-nochap-main-bluebar-header">
        <fo:block-container xsl:use-attribute-sets="nochap-main-bluebar-header_container">
            <fo:block xsl:use-attribute-sets="nochap-main-bluebar-header">
                <fo:table xsl:use-attribute-sets="__frontmatter_footer_table">
                    <fo:table-column column-width="60%"/>
                    <fo:table-column column-width="40%"/>
                    <fo:table-body>
                        <fo:table-row>
                            <fo:table-cell xsl:use-attribute-sets="__frontmatter_footer_content_cell">
                                <xsl:if test="normalize-space($model.number)">
                                    <fo:block>
                                        <xsl:choose>
                                            <xsl:when test="$use-part-number">
                                                <xsl:call-template name="getVariable">
                                                    <xsl:with-param name="id" select="'dsg Part Number'"/>
                                                </xsl:call-template>
                                                <xsl:text>:</xsl:text>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="$model.number"/>
                                            </xsl:when>
                                            <xsl:when test="$use-regulatory-number">
                                                <xsl:call-template name="getVariable">
                                                    <xsl:with-param name="id" select="'Regulatory Model'"/>
                                                </xsl:call-template>
                                                <xsl:text>:</xsl:text>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="$model.number"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="getVariable">
                                                    <xsl:with-param name="id" select="'Regulatory Model'"/>
                                                </xsl:call-template>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="$model.number"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </fo:block>
                                </xsl:if>
                            </fo:table-cell>
                            <fo:table-cell>
                                <fo:block xsl:use-attribute-sets="__technote_header_logo">
                                    <xsl:variable name="logo-path">
                                        <xsl:choose>
                                            <xsl:when test="$dell-brand = 'Dell EMC'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'dellemc-white.svg')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'Alienware'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'Alienware-black.jpg')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'RSA'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'rsa-logo.png')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'Dell Technologies'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'DellTech_Logo_Wht.svg')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="concat($artwork-logo-dir, 'dell-white.svg')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <xsl:variable name="logo-width">
                                        <xsl:choose>
                                            <xsl:when test="$dell-brand = 'Dell EMC'">1.7in</xsl:when>
                                            <xsl:when test="$dell-brand = 'Alienware'">1.7in</xsl:when>
                                            <xsl:when test="$dell-brand = 'RSA'">1in</xsl:when>
                                            <xsl:when test="$dell-brand = 'Dell Technologies'">2.623in</xsl:when>
                                            <xsl:otherwise>0.65in</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <xsl:if test="not($dell-brand = 'Non-brand')">
                                        <fo:external-graphic src="url('{$logo-path}')"
                                                             width="{$logo-width}"
                                                             content-width="{$logo-width}"
                                                             content-height="scale-to-fit"
                                                             scaling="uniform"/>
                                    </xsl:if>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="insert-technote-release-data">
        <xsl:if test="normalize-space($book.currentversion)">
            <fo:block>
                <fo:inline xsl:use-attribute-sets="b">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Current Release Version'"/>
                    </xsl:call-template>
                </fo:inline>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$book.currentversion"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="normalize-space($book.releasedate)">
            <fo:block>
                <fo:inline xsl:use-attribute-sets="b">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Technote Release Date'"/>
                    </xsl:call-template>
                </fo:inline>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$book.releasedate"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="normalize-space($book.previousversion)">
            <fo:block>
                <fo:inline xsl:use-attribute-sets="b">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Previous Release Version'"/>
                    </xsl:call-template>
                </fo:inline>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$book.previousversion"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="normalize-space($release.type)">
            <xsl:variable name="release.type.str">
                <xsl:choose>
                    <xsl:when test="$release.type = 'ma'">Major</xsl:when>
                    <xsl:when test="$release.type = 'mi'">Minor</xsl:when>
                    <xsl:when test="$release.type = 'sr'">Service</xsl:when>
                    <xsl:otherwise>Patch</xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="release-type-value">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="$release.type.str"/>
                </xsl:call-template>
            </xsl:variable>
            <fo:block>
                <fo:inline xsl:use-attribute-sets="b">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Release Type'"/>
                    </xsl:call-template>
                </fo:inline>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$release-type-value"/>
            </fo:block>
        </xsl:if>

    </xsl:template>
    <!--Support for LEMC outputclass branded-->
    <xsl:template match="*[contains(@class,' topic/keyword ')][@outputclass='branded']">
        <fo:inline xsl:use-attribute-sets="ph">
            <xsl:call-template name="commonattributes"/>
            <xsl:value-of select="$BRAND-TEXT"/>
            <xsl:apply-templates/>
        </fo:inline>
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
                            <xsl:variable name="topicref"
                                          select="key('map-id', ancestor-or-self::*[contains(@class, ' topic/topic ')][1]/@id)"/>
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
                        <xsl:if test="$dell-brand = ('Non-brand', 'Alienware')">
                            <xsl:call-template name="getTopicNumbering"/>
                        </xsl:if>
                        <xsl:for-each select="*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>
                    </fo:block>


                </fo:block>
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
                        <xsl:if test="$dell-brand = ('Non-brand', 'Alienware')">
                            <xsl:call-template name="getTopicNumbering"/>
                        </xsl:if>
                        <xsl:for-each select="*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="." mode="getTitle"/>
                        </xsl:for-each>
                    </fo:block>

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

                    <xsl:call-template name="pullPrologIndexTerms.end-range"/>
                </fo:block>
                <xsl:apply-templates select="*[contains(@class,' topic/topic ')]"/>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

</xsl:stylesheet>