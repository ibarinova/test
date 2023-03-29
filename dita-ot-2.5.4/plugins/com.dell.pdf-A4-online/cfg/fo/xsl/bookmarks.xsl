<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:template match="ot-placeholder:toc[$retain-bookmap-order]" mode="bookmark">
        <fo:bookmark internal-destination="{$id.toc}">
            <xsl:if test="$bookmarkStyle!='EXPANDED'">
                <xsl:attribute name="starting-state">hide</xsl:attribute>
            </xsl:if>
            <fo:bookmark-title>
<!--                <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]"/>-->
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Table of Contents'"/>
                </xsl:call-template>
            </fo:bookmark-title>
        </fo:bookmark>
    </xsl:template>

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
                        <xsl:if test="($topicType = 'topicPreface') and following-sibling::ot-placeholder:toc">
                            <xsl:apply-templates select="." mode="bookmark"/>
                        </xsl:if>
                        <xsl:if test="$topicType = 'topicNotices'">
                            <!--<xsl:apply-templates select="." mode="bookmark"/>-->
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:choose>
                        <xsl:when test="$isTechnote">
                            <fo:bookmark internal-destination="{$id.cover}">
                                <fo:bookmark-title>
                                    <xsl:value-of>
                                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                                    </xsl:value-of>
                                    <xsl:text> </xsl:text>
                                    <xsl:for-each select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                                        <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </fo:bookmark-title>
                            </fo:bookmark>
                        </xsl:when>
                        <xsl:when test="$isNochap">
                            <fo:bookmark internal-destination="{$id.cover}">
                                <fo:bookmark-title>
                                    <xsl:value-of>
                                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                                    </xsl:value-of>
                                    <xsl:text> </xsl:text>
                                    <xsl:for-each select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                                        <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
                                </fo:bookmark-title>
                            </fo:bookmark>
                        </xsl:when>
                        <xsl:when test="$map//*[contains(@class,' bookmap/toc ')][@href]"/>
                        <xsl:when test="$map//*[contains(@class,' bookmap/toc ')]
                                        | /*[contains(@class,' map/map ')][not(contains(@class,' bookmap/bookmap '))]">
                            <fo:bookmark internal-destination="{$id.cover}">
                                <fo:bookmark-title>
                                    <xsl:value-of>
                                        <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                                    </xsl:value-of>
                                    <xsl:text> </xsl:text>
                                    <xsl:for-each select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                                        <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                                        <xsl:text> </xsl:text>
                                    </xsl:for-each>
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
                    <xsl:choose>
                        <xsl:when test="$isTechnote">
                            <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')]">
                                <xsl:apply-templates select="." mode="bookmark"/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$isNochap">
                            <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')]">
                                <xsl:apply-templates select="." mode="bookmark"/>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="/*/*[contains(@class, ' topic/topic ')] |
                                  /*/ot-placeholder:glossarylist |
                                  /*/ot-placeholder:tablelist |
                                  /*/ot-placeholder:figurelist">
                                <xsl:variable name="topicType">
                                    <xsl:call-template name="determineTopicType"/>
                                </xsl:variable>
                                <xsl:if test="($topicType = 'topicPreface') and preceding-sibling::ot-placeholder:toc">
                                    <xsl:apply-templates select="." mode="bookmark"/>
                                </xsl:if>
                                <xsl:if test="not($topicType = 'topicNotices') and not($topicType = 'topicFrontMatter') and not($topicType = 'topicPreface')">
                                    <xsl:apply-templates select="." mode="bookmark"/>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
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
        <xsl:variable name="notChapter" select="not(contains($mapTopicref/@class, ' bookmap/chapter ')
                                                or contains($mapTopicref/@class, ' bookmap/appendix ')
                                                or contains($mapTopicref/@class, ' bookmap/part '))" as="xs:boolean"/>

        <xsl:choose>
            <xsl:when test="$isTechnote and $notChapter and empty(ancestor::*[contains(@class, ' topic/topic ')])">
                <xsl:apply-templates mode="bookmark"/>
            </xsl:when>
            <xsl:when test="$isNochap and $notChapter and empty(ancestor::*[contains(@class, ' topic/topic ')])">
                <xsl:apply-templates mode="bookmark"/>
            </xsl:when>
            <xsl:when test="$isNochap and not($notChapter)">
                <xsl:apply-templates mode="bookmark"/>
            </xsl:when>
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
                        <xsl:call-template name="getTopicNumbering"/>
                        <xsl:value-of select="normalize-space($topicTitle)"/>
                    </fo:bookmark-title>
                    <xsl:apply-templates mode="bookmark"/>
                </fo:bookmark>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="bookmark"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')][contains(@outputclass, 'notice')][$isTechnote]" mode="bookmark" priority="5"/>
    <xsl:template match="*[contains(@class, ' topic/topic ')][contains(@outputclass, 'notice')][$isNochap]" mode="bookmark" priority="5"/>

    <xsl:template match="ot-placeholder:glossarylist" mode="bookmark">
        <fo:bookmark internal-destination="{$id.glossary}">
            <xsl:if test="$bookmarkStyle!='EXPANDED'">
                <xsl:attribute name="starting-state">hide</xsl:attribute>
            </xsl:if>
            <fo:bookmark-title>
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Glossary'"/>
                </xsl:call-template>
            </fo:bookmark-title>

<!--            <xsl:apply-templates mode="bookmark"/>-->
        </fo:bookmark>
    </xsl:template>

    <xsl:template match="ot-placeholder:tablelist" mode="bookmark">
        <xsl:if test="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ' )]">
            <fo:bookmark internal-destination="{$id.lot}">
                <xsl:if test="$bookmarkStyle!='EXPANDED'">
                    <xsl:attribute name="starting-state">hide</xsl:attribute>
                </xsl:if>
                <fo:bookmark-title>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'LOT-dell'"/>
                    </xsl:call-template>
                </fo:bookmark-title>

                <xsl:apply-templates mode="bookmark"/>
            </fo:bookmark>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ot-placeholder:figurelist" mode="bookmark">
        <xsl:if test="//*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ' )]">
            <fo:bookmark internal-destination="{$id.lof}">
                <xsl:if test="$bookmarkStyle!='EXPANDED'">
                    <xsl:attribute name="starting-state">hide</xsl:attribute>
                </xsl:if>
                <fo:bookmark-title>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'LOF-dell'"/>
                    </xsl:call-template>
                </fo:bookmark-title>

                <xsl:apply-templates mode="bookmark"/>
            </fo:bookmark>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>