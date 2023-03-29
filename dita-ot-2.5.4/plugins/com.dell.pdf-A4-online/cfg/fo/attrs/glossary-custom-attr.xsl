<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="__glossary__letter-block">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="space-before">20pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__term">
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__def">
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
        <xsl:attribute name="start-indent" select="$side-col-width"/>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__synonym">
        <xsl:attribute name="space-before">5pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__bold">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__link">
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="$dell-brand = ('Non-brand', 'Alienware')">blue</xsl:when>
                <xsl:otherwise>#0076CE</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="text-decoration">
            <xsl:choose>
                <xsl:when test="$dell-brand = ('Non-brand', 'Alienware')">underline</xsl:when>
                <xsl:otherwise>none</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>
