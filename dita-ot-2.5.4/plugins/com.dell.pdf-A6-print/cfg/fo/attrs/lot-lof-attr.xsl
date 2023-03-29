<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="__lotf__heading" use-attribute-sets="__toc__header">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="space-after">14pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">14pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name ="__lotf__content" use-attribute-sets="base-font __toc__topic__content__booklist">
        <xsl:attribute name="font-family">sans-serif</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>
