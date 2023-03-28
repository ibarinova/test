<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:output indent="no" encoding="UTF-8" method="text"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="filelist">
        <xsl:variable name="needless-files">
            <xsl:for-each select="/descendant::file[@exclude = 'true'
                                        or @file-type = 'map'
                                        or normalize-space(@new-name)
                                        or @topicref-type = 'keydef'
                                        or @bridge-topic = 'true'][not(@duplicate = 'true')]">
                <xsl:copy-of select="."/>
            </xsl:for-each>
            <xsl:for-each select="/descendant::conref">
                <xsl:variable name="currentName" select="@name"/>
                <xsl:if test="not(preceding-sibling::conref[@name = $currentName]) and not(preceding-sibling::file[@name = $currentName])">
                    <file name="{@name}"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$needless-files/descendant::file">
                <xsl:apply-templates select="$needless-files/descendant::file"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="/descendant::pub"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="file">
        <xsl:value-of select="@name"/>
        <xsl:value-of select="'&#10;'"/>
    </xsl:template>

    <xsl:template match="pub">
        <xsl:value-of select="'dummy.xml'"/>
        <xsl:value-of select="'&#10;'"/>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

</xsl:stylesheet>
