<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:opentopic-i18n="http://www.idiominc.com/opentopic/i18n"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
    xmlns:ss="http://www.suite-sol.com/functions"
    exclude-result-prefixes="opentopic-index opentopic opentopic-i18n opentopic-func dita-ot xs ot-placeholder ss"
    version="2.0">

    <xsl:variable name="productName">
        <xsl:variable name="mapProdname"
            select="(/*/opentopic:map//*[contains(@class, ' topic/prodname ')])[1]" as="element()?"/>
        <xsl:variable name="productNameTemp">
            <xsl:choose>
                <xsl:when test="$mapProdname">
                    <xsl:value-of select="$mapProdname"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Product Name'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <!-- Suite/EMC   SOW7    31-Dec-2012   hide copyright/trademarks from header and footer - END - rs -->
        <xsl:value-of select="ss:stripSymbols($productNameTemp)"/>
    </xsl:variable>

    <xsl:template match="/" name="rootTemplate">
        <xsl:call-template name="validateTopicRefs"/>
        <fo:root xsl:use-attribute-sets="__fo__root">
            <xsl:call-template name="createMetadata"/>
            <xsl:call-template name="createLayoutMasters"/>
            <xsl:call-template name="createBookmarks"/>
            <xsl:choose>
                <xsl:when test="$NOCHAP = 'yes'">
                    <xsl:call-template name="createFrontMatter"/>
                    <fo:page-sequence master-reference="body-sequence">
                        <xsl:call-template name="insertBodyStaticContents"/>
                        <fo:flow flow-name="xsl-region-body">
                            <fo:block>
                                <fo:marker marker-class-name="current-topic-number">
                                    <xsl:number format="1"/>
                                </fo:marker>
                                <fo:marker marker-class-name="current-header">
                                    <xsl:for-each select="//bookmap/*[contains(@class, ' topic/topic ')]">
                                        <xsl:if
                                            test="//*[contains(@class, ' bookmap/chapter ') or contains(@class, ' bookmap/appendix ') or contains(@class, ' bookmap/part ')][1][@id = current()/@id]">
                                            <xsl:choose>
                                                <!-- Suite/EMC  SOW7x    08-Aug-2013 - only use navtitle if locktitle is set -->
                                                <xsl:when test="@navtitle and @locktitle='yes'">
                                                    <xsl:apply-templates select="@navtitle"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:for-each select="child::*[contains(@class,' topic/title ')]">
                                                        <!-- Suite/EMC   SOW7  07-Apr-2013   Add parameter to prevent change-markup in header/footer - rs -->
                                                        <xsl:apply-templates select="." mode="getTitle">
                                                            <xsl:with-param name="change-markup">no</xsl:with-param>
                                                        </xsl:apply-templates>
                                                    </xsl:for-each>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:if>
                                    </xsl:for-each>
                                </fo:marker>
                            </fo:block>
                            <xsl:apply-templates select="." mode="processTopic"/>
                            <fo:block-container height="100%" display-align="after"
                                margin-bottom="0.63in" break-before="page">
                                <xsl:call-template name="inside_cover"/>
                            </fo:block-container>
                        </fo:flow>
                    </fo:page-sequence>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*" mode="generatePageSequences"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:root>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:title-metadata" as="xs:string?">
        <xsl:variable name="mainbooktitle">
            <xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/mainbooktitle ')][1]"/>
        </xsl:variable>
        <xsl:variable name="booktitlealt">
            <xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/booktitlealt ')][1]"/>
        </xsl:variable>
        <xsl:variable name="vrm" select="/descendant::*[contains(@class, ' topic/vrm ')][1]/@version"/>
        <xsl:variable name="full-title">
            <xsl:value-of select="$mainbooktitle"/>
<!--
            <xsl:if test="lower-case($NOCHAP) = 'yes' and normalize-space($vrm)">
                <xsl:text> </xsl:text>
                <xsl:value-of select="normalize-space($vrm)"/>
            </xsl:if>
-->
            <xsl:if test="normalize-space($booktitlealt)">
                <xsl:text> </xsl:text>
                <xsl:value-of select="$booktitlealt"/>
            </xsl:if>
        </xsl:variable>
        <xsl:value-of select="normalize-space($full-title)"/>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:author-metadata" as="xs:string?">
        <xsl:variable name="authorinformation"
            select="$map/*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' xnal-d/authorinformation ')]"
            as="element()*"/>
        <xsl:choose>
            <xsl:when
                test="exists($authorinformation/descendant::*[contains(@class, ' xnal-d/personname ')])">
                <xsl:for-each
                    select="$authorinformation/descendant::*[contains(@class, ' xnal-d/personname ')][1]">
                    <!-- Requires locale specific processing -->
                    <xsl:value-of>
                        <xsl:apply-templates
                            select="*[contains(@class, ' xnal-d/firstname ')]/node()"
                            mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates
                            select="*[contains(@class, ' xnal-d/lastname ')]/node()"
                            mode="dita-ot:text-only"/>
                    </xsl:value-of>
                </xsl:for-each>
            </xsl:when>
            <xsl:when
                test="exists($authorinformation/descendant::*[contains(@class, ' xnal-d/organizationname ')])">
                <xsl:value-of>
                    <xsl:apply-templates
                        select="$authorinformation/descendant::*[contains(@class, ' xnal-d/organizationname ')]"
                        mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when
                test="exists($map/*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' topic/author ')])">
                <xsl:value-of>
                    <xsl:apply-templates
                        select="$map/*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' topic/author ')]"
                        mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when
                test="exists($map//*[contains(@class, ' bookmap/bookmeta ')]//*[contains(@class, ' bookmap/publisherinformation ')]/*[contains(@class, ' bookmap/organization ')])">
                <xsl:value-of
                    select="normalize-space(string-join($map//*[contains(@class, ' bookmap/bookmeta ')]//*[contains(@class, ' bookmap/publisherinformation ')][1]/*[contains(@class, ' bookmap/organization ')][1]//text(), ''))"
                />
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- mckimn 22-Sept-2016: Remove notices from output content -->
    <xsl:template match="*[contains(@class, ' bookmap/notices ')]" mode="generatePageSequences"/>
    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="process-notices"/>


</xsl:stylesheet>
