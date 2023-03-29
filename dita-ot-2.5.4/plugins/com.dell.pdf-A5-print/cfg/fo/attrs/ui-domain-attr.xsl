<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:attribute-set name="uicontrol">
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="$locale = 'ja'">normal</xsl:when>
                <xsl:otherwise>bold</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="$locale = 'ja'">serif</xsl:when>
                <xsl:otherwise>sans-bold</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="line-height">100%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="wintitle">
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="$locale = 'ja'">normal</xsl:when>
                <xsl:otherwise>bold</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="$locale = 'ja'">serif</xsl:when>
                <xsl:otherwise>sans-bold</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>