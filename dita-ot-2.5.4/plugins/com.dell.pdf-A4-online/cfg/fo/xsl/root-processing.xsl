<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                version="2.0"
                exclude-result-prefixes="dita-ot xs">

    <xsl:template match="/" name="rootTemplate">
        <xsl:call-template name="validateTopicRefs"/>
        <fo:root xsl:use-attribute-sets="__fo__root">
            <xsl:call-template name="createMetadata"/>
            <xsl:call-template name="createLayoutMasters"/>
            <xsl:call-template name="createBookmarks"/>
            <xsl:choose>
                <xsl:when test="$isTechnote">
                    <xsl:call-template name="processTechnote"/>
                </xsl:when>
                <xsl:when test="$isNochap">
                    <xsl:call-template name="processNochap"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="*" mode="generatePageSequences"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:root>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/notices ')]" mode="generatePageSequences">
        <xsl:if test="*[contains(@class, ' map/topicref ')]">
            <xsl:call-template name="processTopicNotices"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="createMetadata">
        <xsl:variable name="title" as="xs:string?">
            <xsl:apply-templates select="." mode="dita-ot:title-metadata"/>
        </xsl:variable>
        <xsl:if test="exists($title)">
            <axf:document-info name="document-title" value="{$title}"/>
            <axf:document-info name="displaydoctitle" value="true"/>
            <axf:document-info name="title" value="{$title}"/>
        </xsl:if>
        <!--axf:document-info name="subject" value="The document subject"/-->
        <xsl:variable name="author" as="xs:string?">
            <xsl:apply-templates select="." mode="dita-ot:author-metadata"/>
        </xsl:variable>
        <xsl:if test="exists($author)">
            <axf:document-info name="author" value="{$author}"/>
        </xsl:if>
        <xsl:variable name="keywords" as="xs:string*">
            <xsl:apply-templates select="." mode="dita-ot:keywords-metadata"/>
        </xsl:variable>
        <xsl:if test="exists($keywords)">
            <axf:document-info name="keywords">
                <xsl:attribute name="value">
                    <xsl:value-of select="$keywords" separator=", "/>
                </xsl:attribute>
            </axf:document-info>
        </xsl:if>
        <xsl:variable name="subject" as="xs:string?">
            <xsl:apply-templates select="." mode="dita-ot:subject-metadata"/>
        </xsl:variable>
        <xsl:if test="exists($subject)">
            <axf:document-info name="subject" value="{$subject}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:title-metadata" as="xs:string?">
        <xsl:choose>
            <xsl:when test="exists($map/*[contains(@class, ' bookmap/booktitle ')]/*[contains(@class,' bookmap/mainbooktitle ')])">
                <xsl:variable name="mainbooktitle">
                    <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/mainbooktitle ')][1]" mode="dita-ot:text-only"/>
                </xsl:variable>
                <xsl:variable name="booktitlealt">
                    <xsl:for-each select="$map/*[contains(@class, ' bookmap/booktitle ')][1]/*[contains(@class,' bookmap/booktitlealt ')]">
                        <xsl:apply-templates select="." mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="title">
                    <xsl:value-of select="$mainbooktitle"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="$booktitlealt"/>
                </xsl:variable>
                <xsl:value-of select="normalize-space($title)"/>
            </xsl:when>
            <xsl:when test="exists($map/*[contains(@class,' topic/title ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$map/*[contains(@class,' topic/title ')][1]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists(//*[contains(@class, ' map/map ')]/@title)">
                <xsl:value-of select="//*[contains(@class, ' map/map ')]/@title"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of>
                    <xsl:apply-templates select="descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="/" mode="dita-ot:author-metadata" as="xs:string?">
        <xsl:variable name="authorinformation" select="$map/*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' xnal-d/authorinformation ')]" as="element()*"/>
        <xsl:choose>
            <xsl:when test="exists($map/descendant::*[contains(@class, ' bookmap/organization ')][ancestor::*[contains(@class, ' bookmap/bookrights ')]])">
                <xsl:value-of select="$map/descendant::*[contains(@class, ' bookmap/organization ')][ancestor::*[contains(@class, ' bookmap/bookrights ')]][1]"/>
            </xsl:when>
            <xsl:when test="exists($authorinformation/descendant::*[contains(@class, ' xnal-d/personname ')])">
                <xsl:for-each select="$authorinformation/descendant::*[contains(@class, ' xnal-d/personname ')][1]">
                    <!-- Requires locale specific processing -->
                    <xsl:value-of>
                        <xsl:apply-templates select="*[contains(@class, ' xnal-d/firstname ')]/node()" mode="dita-ot:text-only"/>
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates select="*[contains(@class, ' xnal-d/lastname ')]/node()" mode="dita-ot:text-only"/>
                    </xsl:value-of>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="exists($authorinformation/descendant::*[contains(@class, ' xnal-d/organizationname ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$authorinformation/descendant::*[contains(@class, ' xnal-d/organizationname ')]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
            <xsl:when test="exists($map/*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' topic/author ')])">
                <xsl:value-of>
                    <xsl:apply-templates select="$map/*[contains(@class, ' bookmap/bookmeta ')]/*[contains(@class, ' topic/author ')]" mode="dita-ot:text-only"/>
                </xsl:value-of>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>