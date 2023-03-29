<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:attribute-set name="option">
		<xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="parmname">
    <xsl:attribute name="font-family">Monospaced</xsl:attribute>
	<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
	</xsl:attribute-set>

    <xsl:attribute-set name="synph">
		<xsl:attribute name="font-family">Monospaced</xsl:attribute>
		<xsl:attribute name="font-size">inherited-property-value(&apos;font-size&apos;)</xsl:attribute> 
    </xsl:attribute-set>

    <xsl:attribute-set name="pd">
        <xsl:attribute name="space-before">0.3em</xsl:attribute>
        <xsl:attribute name="space-after">0.5em</xsl:attribute>
        <xsl:attribute name="end-indent">24pt</xsl:attribute>
		<xsl:attribute name="start-indent">
			<xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' pr-d/parml ')])"/>
			<xsl:if test="$level = 1">1in</xsl:if>
			<xsl:if test="$level = 2">1.5in</xsl:if>
			<xsl:if test="$level = 3">2in</xsl:if>
		</xsl:attribute>
	</xsl:attribute-set>

</xsl:stylesheet>