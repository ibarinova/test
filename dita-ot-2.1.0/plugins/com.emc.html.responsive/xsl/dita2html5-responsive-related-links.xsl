<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:output indent="yes" encoding="UTF-8"/>

    <xsl:param name="propertiesXml"/>
    <xsl:variable name="properties-doc" select="document(concat('file:/', translate($propertiesXml, '\', '/')))"/>

    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:variable name="base-name" select="tokenize($base-uri,'/')[last()]"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/related-links ')]"/>

    <xsl:template match="dita/*[contains(@class, ' topic/topic ')]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
            <xsl:call-template name="insertRelatedLinks"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="insertRelatedLinks">
        <xsl:variable name="relatedLinks">
            <xsl:for-each select="/descendant::*[contains(@class, ' topic/related-links ')]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="outOfTopic-relLinks" >
            <xsl:apply-templates select="$relatedLinks/*[contains(@class, ' topic/related-links ')][1]" mode="remove-needless-links"/>
        </xsl:variable>
        <xsl:if test="$outOfTopic-relLinks/descendant::*[contains(@class, ' topic/link ')]">
            <xsl:copy-of select="$outOfTopic-relLinks"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/related-links ')]" mode="remove-needless-links">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="*[contains(@class, ' topic/linkpool ')][1]" mode="remove-needless-links"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/linkpool ')]" mode="remove-needless-links">
        <xsl:variable name="links">
            <xsl:copy-of select="descendant::*[contains(@class, ' topic/link ')]"/>
            <xsl:copy-of select="following::*[contains(@class, ' topic/link ')]"/>
        </xsl:variable>
        <xsl:variable name="filtered-links">
            <xsl:for-each select="$links/*[contains(@class, ' topic/link ')]">
                <xsl:if test="not(starts-with(@href, $base-name)) and
                            not(@href = preceding-sibling::*[contains(@class, ' topic/link ')]/@href)">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:copy-of select="$filtered-links"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
