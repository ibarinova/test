<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia"
                version="2.0">

    <xsl:output indent="no" encoding="UTF-8" method="text"/>

    <xsl:param name="dell-brand" select="'Dell'"/>

    <xsl:template match="/">
        <xsl:variable name="names">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:for-each select="$names/name">
            <xsl:variable name="current-value" select="normalize-space(.)"/>
            <xsl:if test="not(preceding-sibling::*[normalize-space(.) = $current-value])">
                <xsl:value-of select="$current-value"/>
                <xsl:value-of select="'&#10;'"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="file">
        <xsl:if test="normalize-space(@new-name)">
            <name>
                <xsl:value-of select="concat(substring-before(@new-name, '.'), '.xml')"/>
            </name>
            <name>
                <xsl:value-of select="concat(substring-before(@new-name, '.'), '.html')"/>
            </name>
        </xsl:if>
        <name>
            <xsl:value-of select="@name"/>
        </name>
    </xsl:template>

    <xsl:template match="conref">
        <name>
            <xsl:value-of select="@name"/>
        </name>
    </xsl:template>

    <xsl:template match="file[@type = 'map']"/>

    <xsl:template match="file[@topicref-type = 'keydef']"/>

    <xsl:template match="pub"/>

    <xsl:template match="@*|node()">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

</xsl:stylesheet>
