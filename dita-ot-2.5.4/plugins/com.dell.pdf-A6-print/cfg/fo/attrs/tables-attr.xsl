<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="table__container">
		<xsl:attribute name="reference-orientation" select="if (@orient eq 'land') then 90 else 0"/>
		<xsl:attribute name="start-indent">from-parent(start-indent)</xsl:attribute>
		<xsl:attribute name="space-before">1em</xsl:attribute>
		<xsl:attribute name="space-after">1em</xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:attribute-set name="common.table.head.entry">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="table.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="font-size">5.5pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="space-before">12pt</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="thead__tableframe__bottom" use-attribute-sets="common.border__bottom">
		<xsl:attribute name="border-bottom-style">
			<xsl:choose>
				<xsl:when test="ancestor::*[contains(@class, ' topic/table ')][@frame = 'all' or not(@frame)]">double</xsl:when>
				<xsl:otherwise>solid</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="border-bottom-color">black</xsl:attribute>
		<xsl:attribute name="border-bottom-width">2px</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="__tableframe__bottom" use-attribute-sets="common.border__bottom">
		<xsl:attribute name="border-after-width.conditionality">retain</xsl:attribute>
		<xsl:attribute name="border-bottom-color">black</xsl:attribute>
	</xsl:attribute-set>

	<xsl:attribute-set name="table__tableframe__top" use-attribute-sets="common.border__top">
		<xsl:attribute name="border-before-style">solid</xsl:attribute>
		<xsl:attribute name="border-before-width">
			<xsl:choose>
				<xsl:when test="parent::*[contains(@class, ' topic/table ')][@frame = 'all'][*[contains(@class, ' topic/tgroup ')]] and not(*[contains(@class, ' topic/thead ')])">0pt</xsl:when>
				<xsl:otherwise>1pt</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="border-before-color">black</xsl:attribute>
	</xsl:attribute-set>
	
    <xsl:attribute-set name="tbody.row">
        <xsl:attribute name="keep-together.within-page">auto</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="thead.row.entry">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="line-height">9pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="dl.dlhead">
        <xsl:attribute name="font-size">7pt</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="tablefootnote">
		<xsl:attribute name="padding-left">0in</xsl:attribute>
		<xsl:attribute name="padding-top">0.10in</xsl:attribute>
	</xsl:attribute-set>

</xsl:stylesheet>