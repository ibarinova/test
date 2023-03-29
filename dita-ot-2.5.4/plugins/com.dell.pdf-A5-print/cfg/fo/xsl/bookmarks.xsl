<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:template match="ot-placeholder:toc[$retain-bookmap-order]" mode="bookmark">
        <xsl:if test="$generate-toc">
            <fo:bookmark internal-destination="{$id.toc}">
                <xsl:if test="$bookmarkStyle!='EXPANDED'">
                    <xsl:attribute name="starting-state">hide</xsl:attribute>
                </xsl:if>
                <fo:bookmark-title>
                    <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]"/>
                </fo:bookmark-title>
            </fo:bookmark>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')][$multilingual][contains(@outputclass, 'notice')]" mode="bookmark" priority="5"/>

    <xsl:template name="createBookmarks">
        <xsl:variable name="bookmarks" as="element()*">
            <xsl:choose>
                <xsl:when test="$retain-bookmap-order">
                    <xsl:apply-templates select="/" mode="bookmark"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')]">
                        <xsl:variable name="topicType">
                            <xsl:call-template name="determineTopicType"/>
                        </xsl:variable>
                        <xsl:if test="$topicType = 'topicNotices'">
                            <!--<xsl:apply-templates select="." mode="bookmark"/>-->
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:choose>
                        <xsl:when test="$multilingual"/>
                        <xsl:when test="$map//*[contains(@class,' bookmap/toc ')][@href]"/>
                        <xsl:when test="$map//*[contains(@class,' bookmap/toc ')]
                              | /*[contains(@class,' map/map ')][not(contains(@class,' bookmap/bookmap '))]">
                            <fo:bookmark internal-destination="{$id.cover}">
                                <fo:bookmark-title>
                                    <xsl:value-of>
                                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                                    </xsl:value-of>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of>
                                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]" mode="dita-ot:text-only"/>
                                    </xsl:value-of>
                                </fo:bookmark-title>
                            </fo:bookmark>
                            <fo:bookmark internal-destination="{$id.toc}">
                                <fo:bookmark-title>
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Table of Contents'"/>
                                    </xsl:call-template>
                                </fo:bookmark-title>
                            </fo:bookmark>
                        </xsl:when>
                    </xsl:choose>
                    <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')] |
                                  /*/ot-placeholder:glossarylist |
                                  /*/ot-placeholder:tablelist |
                                  /*/ot-placeholder:figurelist">
                        <xsl:variable name="topicType">
                            <xsl:call-template name="determineTopicType"/>
                        </xsl:variable>
                        <xsl:if test="not($topicType = 'topicNotices') and not($topicType = 'topicFrontMatter')">
                            <xsl:apply-templates select="." mode="bookmark"/>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:apply-templates select="/*" mode="bookmark-index"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="exists($bookmarks)">
            <fo:bookmark-tree>
                <xsl:copy-of select="$bookmarks"/>
            </fo:bookmark-tree>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="bookmark">
        <xsl:variable name="mapTopicref" select="key('map-id', @id)[1]"/>
        <xsl:variable name="topicTitle">
            <xsl:call-template name="getNavTitle"/>
        </xsl:variable>
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
                <xsl:when test="$multilingual and $mapTopicref/ancestor::*[contains(@class, ' bookmap/notices ')]">
                    <xsl:sequence select="false()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="true()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:if test="$process-topic">
            <xsl:choose>
                <xsl:when test="$mapTopicref[@toc = 'yes' or not(@toc)] or
                          not($mapTopicref)">
                    <fo:bookmark>
                        <xsl:attribute name="internal-destination">
                            <xsl:call-template name="generate-toc-id"/>
                        </xsl:attribute>
                        <xsl:if test="$bookmarkStyle!='EXPANDED'">
                            <xsl:attribute name="starting-state">hide</xsl:attribute>
                        </xsl:if>
                        <fo:bookmark-title>
                            <xsl:value-of select="normalize-space($topicTitle)"/>
                        </fo:bookmark-title>
                        <xsl:apply-templates mode="bookmark"/>
                    </fo:bookmark>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="bookmark"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>