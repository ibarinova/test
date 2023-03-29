<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="__index__label">
        <xsl:attribute name="space-before">10pt</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">14pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="space-after.conditionality">retain</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="span">all</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__index__letter-group">
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="space-before">8pt</xsl:attribute>
        <xsl:attribute name="space-after">4pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="index.entry">
        <xsl:attribute name="space-after">6pt</xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="index-indents">
        <xsl:attribute name="end-indent">5pt</xsl:attribute>
        <xsl:attribute name="last-line-end-indent">0pt</xsl:attribute>
        <xsl:attribute name="start-indent">
            <xsl:value-of select="$index.indent"/> * 2
        </xsl:attribute>
        <xsl:attribute name="text-indent">-<xsl:value-of select="$index.indent"/> * 2
        </xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="index.entry__content">
        <xsl:attribute name="start-indent" select="$index.indent"/>
    </xsl:attribute-set>

</xsl:stylesheet>