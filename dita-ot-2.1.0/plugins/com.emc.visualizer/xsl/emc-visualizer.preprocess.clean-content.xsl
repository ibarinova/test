<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:output indent="yes"/>

    <xsl:template match="@* | node()" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@ishlabelxpath"/>
    <xsl:template match="@ishlinkxpath"/>

    <xsl:template match="@href" priority="10">
        <xsl:variable name="href-new" select="replace(replace(., '\s', ''), '%20', '')"/>

        <xsl:attribute name="href" select="$href-new"/>

        <xsl:choose>
            <xsl:when test="parent::xref and (matches(lower-case($href-new), '^((https?|HTTPS?|ftp|sftp)://)?([\da-zA-Z\.-]+)\.([\da-zA-Z\.]{2,6})([/\w \.-]*)*/?.*$')
                            or matches(lower-case($href-new), '^mailto:.*')
                            or matches(lower-case($href-new), '^.*\.doc$'))">
                <xsl:attribute name="scope">external</xsl:attribute>
            </xsl:when>
            <xsl:when test="normalize-space(parent::*/@scope)">
                <xsl:attribute name="scope" select="normalize-space(parent::*/@scope)"/>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="parent::xref and (matches(lower-case($href-new), '^((https?|HTTPS?|ftp|sftp)://)?([\da-zA-Z\.-]+)\.([\da-zA-Z\.]{2,6})([/\w \.-]*)*/?.*$')
                            or matches(lower-case($href-new), '^mailto:.*')
                            or matches(lower-case($href-new), '^.*\.doc$'))">
                <xsl:attribute name="format">html</xsl:attribute>
            </xsl:when>
            <xsl:when test="normalize-space(parent::*/@format)">
                <xsl:attribute name="format" select="normalize-space(parent::*/@format)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="@scope[parent::*[@href]]" priority="10"/>
    <xsl:template match="@format[parent::*[@href]]" priority="10"/>

</xsl:stylesheet>
