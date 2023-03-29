<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="__glossary__label">
        <xsl:attribute name="space-before">10pt</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="space-after">14pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">14pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__block">
        <xsl:attribute name="margin-bottom">14pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__term">
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__glossary__def">
        <xsl:attribute name="start-indent" select="'8mm'"/>
        <xsl:attribute name="space-before">8pt</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>
