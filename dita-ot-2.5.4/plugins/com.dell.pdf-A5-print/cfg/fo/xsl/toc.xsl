<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:opentopic="http://www.idiominc.com/opentopic"
                xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
                xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                exclude-result-prefixes="xs opentopic opentopic-func ot-placeholder opentopic-index"
                version="2.0">

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="toc">
        <xsl:param name="include"/>
        <xsl:variable name="topicLevel" as="xs:integer">
            <xsl:apply-templates select="." mode="get-topic-level"/>
        </xsl:variable>
        <xsl:if test="$topicLevel &lt; $tocMaximumLevel">
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
                    <!-- In a future version, suppressing Notices in the TOC should not be hard-coded. -->
                    <xsl:when test="$retain-bookmap-order and $mapTopicref/self::*[contains(@class, ' bookmap/notices ')]"/>
                    <xsl:when test="$mapTopicref/self::*[ancestor::*[contains(@class, ' bookmap/notices ')]]"/>
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
                                    <xsl:apply-templates select="$mapTopicref" mode="tocPrefix"/>
                                    <fo:inline xsl:use-attribute-sets="__toc__title">
                                        <xsl:call-template name="getNavTitle" />
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
        </xsl:if>
    </xsl:template>

    <xsl:template name="createTocHeader">
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
                        <xsl:with-param name="id" select="'Table of Contents'" />
                    </xsl:call-template>
                </fo:bidi-override>
            </fo:block>
            <fo:block>
<!--
                <fo:marker marker-class-name="current-header">
                    <fo:bidi-override>
                        <xsl:attribute name="direction">
                            <xsl:choose>
                                <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                <xsl:otherwise>ltr</xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Table of Contents'" />
                        </xsl:call-template>
                    </fo:bidi-override>
                </fo:marker>
-->
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template name="createToc">
        <xsl:if test="$generate-toc">
            <xsl:variable name="toc">
                <xsl:choose>
                    <xsl:when test="$map//*[contains(@class,' bookmap/toc ')][@href]"/>
                    <xsl:when test="$map//*[contains(@class,' bookmap/toc ')]">
                        <xsl:apply-templates select="/" mode="toc"/>
                    </xsl:when>
                    <xsl:when test="/*[contains(@class,' map/map ')][not(contains(@class,' bookmap/bookmap '))]">
                        <xsl:apply-templates select="/" mode="toc"/>
                        <xsl:call-template name="toc.index"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:if test="count($toc/*) > 0">
                <fo:page-sequence master-reference="toc-sequence" xsl:use-attribute-sets="page-sequence.toc">
                    <xsl:call-template name="insertTocStaticContents"/>
                    <fo:flow flow-name="xsl-region-body">
                        <xsl:call-template name="createTocHeader"/>
                        <fo:block>
<!--
                            <fo:marker marker-class-name="current-header">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Table of Contents'"/>
                                </xsl:call-template>
                            </fo:marker>
-->
                            <xsl:copy-of select="$toc"/>
                        </fo:block>
                    </fo:flow>
                </fo:page-sequence>
            </xsl:if>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>