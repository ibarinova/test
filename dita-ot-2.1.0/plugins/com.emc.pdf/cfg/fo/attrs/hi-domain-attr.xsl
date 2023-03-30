<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:attribute-set name="i">
        <xsl:attribute name="font-style">
            <xsl:choose>
                <xsl:when test="$locale = 'ja'">normal</xsl:when>
                <xsl:otherwise>italic</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>