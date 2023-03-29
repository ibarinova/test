<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="ol_fig">
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="space-after">16pt</xsl:attribute>
        <xsl:attribute name="space-before">5pt</xsl:attribute>
    </xsl:attribute-set>
	<!--Reduced space before and after IDPL-13021-->
	<xsl:attribute-set name="ul">
    <xsl:attribute name="space-before">1.5pt</xsl:attribute>
    <xsl:attribute name="space-after">1.5pt</xsl:attribute>
        <xsl:attribute name="provisional-distance-between-starts">5mm</xsl:attribute>
        <xsl:attribute name="provisional-label-separation">1mm</xsl:attribute>
    </xsl:attribute-set>
	<xsl:attribute-set name="ol">
    <xsl:attribute name="space-before">1.5pt</xsl:attribute>
    <xsl:attribute name="space-after">1.5pt</xsl:attribute>
        <xsl:attribute name="provisional-distance-between-starts">5mm</xsl:attribute>
        <xsl:attribute name="provisional-label-separation">1mm</xsl:attribute>
    </xsl:attribute-set>
    <xsl:attribute-set name="ol_li_fig">
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
        <xsl:attribute name="space-after.conditionality">retain</xsl:attribute>
        <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="ul.li__label__content">
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="font-family">Arial</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>