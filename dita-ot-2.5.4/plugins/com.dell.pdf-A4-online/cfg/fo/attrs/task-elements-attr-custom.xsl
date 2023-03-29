<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">

    <xsl:attribute-set name="info">
        <xsl:attribute name="space-before">3pt</xsl:attribute>
        <xsl:attribute name="space-after">3pt</xsl:attribute>
		<xsl:attribute name="padding-bottom">1pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="stepsection__body" use-attribute-sets="ul.li__body">
        <xsl:attribute name="start-indent" select="$side-col-width"/>
    </xsl:attribute-set>

</xsl:stylesheet>