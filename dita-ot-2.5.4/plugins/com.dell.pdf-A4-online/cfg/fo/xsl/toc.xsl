<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                exclude-result-prefixes="xs opentopic ot-placeholder opentopic-index"
                version="2.0">

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="toc">
        <xsl:param name="include"/>
        <xsl:variable name="topicLevel" as="xs:integer">
            <xsl:apply-templates select="." mode="get-topic-level"/>
        </xsl:variable>
        <xsl:if test="$topicLevel &lt; $tocMaximumLevel">
            <xsl:variable name="mapTopicref" select="key('map-id', @id)[1]"/>
            <xsl:choose>
                <!-- In a future version, suppressing Notices in the TOC should not be hard-coded. -->
                <xsl:when test="$retain-bookmap-order and $mapTopicref/self::*[contains(@class, ' bookmap/notices ')]"/>
                <xsl:when test="$mapTopicref/self::*[ancestor::*[contains(@class, ' bookmap/notices ')]]"/>
                <xsl:when test="following-sibling::ot-placeholder:toc and $mapTopicref/self::*[contains(@class, ' bookmap/preface ')]"/>
                <xsl:when test="$mapTopicref[@toc = 'yes' or not(@toc)] or
                              (not($mapTopicref) and $include = 'true')">
                    <fo:block xsl:use-attribute-sets="__toc__indent">
                        <xsl:call-template name="insertXmlLangAttr">
                            <xsl:with-param name="xml-lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
                        </xsl:call-template>
                        <xsl:variable name="tocItemContent">
                            <fo:basic-link xsl:use-attribute-sets="__toc__link">
                                <xsl:attribute name="internal-destination">
                                    <xsl:call-template name="generate-toc-id"/>
                                </xsl:attribute>
                                <xsl:variable name="topicType">
                                    <xsl:call-template name="determineTopicType"/>
                                </xsl:variable>

                                <xsl:if test="not($topicType = 'topicAppendix') and not($topicType = 'topicChapter') and not($topicType = 'topicPart')">
                                    <xsl:call-template name="getTopicNumbering"/>
                                </xsl:if>
                                <xsl:apply-templates select="$mapTopicref" mode="tocPrefix"/>
                                <fo:inline xsl:use-attribute-sets="__toc__title">
                                    <xsl:call-template name="getNavTitle"/>
                                </fo:inline>
                                <fo:inline xsl:use-attribute-sets="__toc__page-number">
                                    <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                                    <fo:page-number-citation>
                                        <xsl:attribute name="ref-id">
                                            <xsl:call-template name="generate-toc-id"/>
                                        </xsl:attribute>
                                    </fo:page-number-citation>
                                </fo:inline>
                            </fo:basic-link>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="not($mapTopicref)">
                                <xsl:apply-templates select="." mode="tocText">
                                    <xsl:with-param name="tocItemContent" select="$tocItemContent"/>
                                    <xsl:with-param name="currentNode" select="."/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="$mapTopicref" mode="tocText">
                                    <xsl:with-param name="tocItemContent" select="$tocItemContent"/>
                                    <xsl:with-param name="currentNode" select="."/>
                                </xsl:apply-templates>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <xsl:apply-templates mode="toc">
                        <xsl:with-param name="include" select="'true'"/>
                    </xsl:apply-templates>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="toc">
                        <xsl:with-param name="include" select="'true'"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="createTocHeader">
        <xsl:choose>
            <xsl:when test="$dell-brand = ('Non-brand', 'Alienware', 'RSA')">
                <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.toc}">
                    <fo:block xsl:use-attribute-sets="__toc__header_content">
                        <fo:bidi-override>
                            <xsl:attribute name="direction">
                                <xsl:choose>
                                    <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                    <xsl:otherwise>ltr</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Table of Contents'"/>
                            </xsl:call-template>
                        </fo:bidi-override>
                    </fo:block>
                    <fo:block>
                        <fo:marker marker-class-name="current-header">
                            <fo:bidi-override>
                                <xsl:attribute name="direction">
                                    <xsl:choose>
                                        <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                        <xsl:otherwise>ltr</xsl:otherwise>
                                    </xsl:choose>
                                </xsl:attribute>
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Table of Contents'"/>
                                </xsl:call-template>
                            </fo:bidi-override>
                        </fo:marker>
                    </fo:block>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.toc}">
                    <xsl:call-template name="insertBlueBarHeader">
                        <xsl:with-param name="content">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Table of Contents'"/>
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="type" select="'txt'"/>
                    </xsl:call-template>
                    <fo:block margin-top="20mm"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/preface ')]" mode="tocPrefix">
        <!--
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Table of Contents Preface'"/>
                </xsl:call-template>
        -->
    </xsl:template>

    <xsl:template match="ot-placeholder:tablelist" mode="toc">
        <xsl:if test="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ' )]">
            <fo:block xsl:use-attribute-sets="__lotf__indent">
                <fo:block xsl:use-attribute-sets="__toc__topic__content_loft">
                    <fo:basic-link internal-destination="{$id.lot}" xsl:use-attribute-sets="__toc__link">
                        <fo:inline xsl:use-attribute-sets="__toc__title">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'LOT-dell'"/>
                            </xsl:call-template>
                        </fo:inline>
                        <fo:inline xsl:use-attribute-sets="__toc__page-number">
                            <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                            <fo:page-number-citation ref-id="{$id.lot}"/>
                        </fo:inline>
                    </fo:basic-link>
                </fo:block>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ot-placeholder:figurelist" mode="toc">
        <xsl:if test="//*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ' )]">
            <fo:block xsl:use-attribute-sets="__lotf__indent">
                <fo:block xsl:use-attribute-sets="__toc__topic__content_loft">
                    <fo:basic-link internal-destination="{$id.lof}" xsl:use-attribute-sets="__toc__link">
                        <fo:inline xsl:use-attribute-sets="__toc__title">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'LOF-dell'"/>
                            </xsl:call-template>
                        </fo:inline>
                        <fo:inline xsl:use-attribute-sets="__toc__page-number">
                            <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                            <fo:page-number-citation ref-id="{$id.lof}"/>
                        </fo:inline>
                    </fo:basic-link>
                </fo:block>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ot-placeholder:indexlist" mode="toc" name="toc.index">
        <xsl:if test="(//opentopic-index:index.groups//opentopic-index:index.entry) and (exists($index-entries//opentopic-index:index.entry))">
            <fo:block xsl:use-attribute-sets="__lotf__indent">
                <fo:block xsl:use-attribute-sets="__toc__topic__content_loft">
                    <fo:basic-link internal-destination="{$id.index}" xsl:use-attribute-sets="__toc__link">
                        <fo:inline xsl:use-attribute-sets="__toc__title">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Index'"/>
                            </xsl:call-template>
                        </fo:inline>
                        <fo:inline xsl:use-attribute-sets="__toc__page-number">
                            <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                            <fo:page-number-citation ref-id="{$id.index}"/>
                        </fo:inline>
                    </fo:basic-link>
                </fo:block>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ot-placeholder:glossarylist" mode="toc">
        <fo:block xsl:use-attribute-sets="__lotf__indent">
            <fo:block xsl:use-attribute-sets="__toc__topic__content_loft">
                <fo:basic-link internal-destination="{$id.glossary}" xsl:use-attribute-sets="__toc__link">
                    <fo:inline xsl:use-attribute-sets="__toc__title">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Glossary'"/>
                        </xsl:call-template>
                    </fo:inline>
                    <fo:inline xsl:use-attribute-sets="__toc__page-number">
                        <fo:leader xsl:use-attribute-sets="__toc__leader"/>
                        <fo:page-number-citation ref-id="{$id.glossary}"/>
                    </fo:inline>
                </fo:basic-link>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/chapter ')]" mode="tocPrefix">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Chapter with number'"/>
            <xsl:with-param name="params">
                <number>
                    <xsl:apply-templates select="." mode="topicTitleNumber"/>
                    <xsl:text>: </xsl:text>
                </number>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/appendix ')]" mode="tocPrefix">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Table of Contents Appendix'"/>
            <xsl:with-param name="params">
                <number>
                    <xsl:apply-templates select="." mode="topicTitleNumber"/>
                </number>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/part ')]" mode="tocPrefix">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Table of Contents Part'"/>
            <xsl:with-param name="params">
                <number>
                    <xsl:apply-templates select="." mode="topicTitleNumber"/>
                </number>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>
</xsl:stylesheet>