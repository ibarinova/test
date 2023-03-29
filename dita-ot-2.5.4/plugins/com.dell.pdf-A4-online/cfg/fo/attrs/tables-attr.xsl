<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                version="2.0">

    <xsl:attribute-set name="table__container">
        <xsl:attribute name="reference-orientation" select="if (@orient eq 'land') then 90 else 0"/>
        <xsl:attribute name="start-indent">from-parent(start-indent)</xsl:attribute>
        <xsl:attribute name="space-before">1em</xsl:attribute>
        <xsl:attribute name="space-after">1em</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="tbody.row.entry__firstcol" use-attribute-sets="tbody.row.entry">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="table.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
		<xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="space-before">16pt</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
		<xsl:attribute name="padding-bottom">
            <xsl:choose>
                <xsl:when test="following-sibling::*[contains(@class, ' topic/desc ')]">4px</xsl:when>
                <xsl:otherwise>5px</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="thead__tableframe__bottom_blue">
        <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
        <xsl:attribute name="border-bottom-color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="border-bottom-width">1pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="thead__tableframe__bottom" use-attribute-sets="common.border__bottom">
        <xsl:attribute name="border-bottom-style"><xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/table ')][@frame = 'all' or not(@frame)]">double</xsl:when>
                <xsl:otherwise>solid</xsl:otherwise>
            </xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="border-bottom-color">black</xsl:attribute>
        <xsl:attribute name="border-bottom-width">2px</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__tableframe__bottom" use-attribute-sets="common.border__bottom">
        <xsl:attribute name="border-after-width.conditionality">retain</xsl:attribute>
        <xsl:attribute name="border-bottom-color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">black</xsl:when>
                <xsl:otherwise>gray</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="__tableframe__bottom_Pagebreak" use-attribute-sets="common.border__bottom">
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

    <xsl:attribute-set name="__tableframe__right" use-attribute-sets="common.border__right">
        <xsl:attribute name="border-end-style">
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/table ')][1]/@rowheader = 'firstcol'
                        and empty(preceding-sibling::*[contains(@class, ' topic/entry ')])">double</xsl:when>
                <xsl:otherwise>solid</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="border-end-width">
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/table ')][1]/@rowheader = 'firstcol'
                        and empty(preceding-sibling::*[contains(@class, ' topic/entry ')])">2px</xsl:when>
                <xsl:otherwise>1pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="thead.row.entry">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="line-height">9pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="tbody.row">
        <!--Table body row-->
        <xsl:attribute name="keep-together.within-page">auto</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="chhead.choptionhd">
        <xsl:attribute name="border">1pt solid black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="chhead.chdeschd">
        <xsl:attribute name="border">1pt solid black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="chrow.choption">
        <xsl:attribute name="border">1pt solid black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="chrow.chdesc">
        <xsl:attribute name="border">1pt solid black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="dl.dlhead">
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="dlentry.dt__content">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="tablefootnote">
		<xsl:attribute name="padding-left">0in</xsl:attribute>
		<xsl:attribute name="padding-top">0.10in</xsl:attribute>
  </xsl:attribute-set>

   <xsl:attribute-set name="tbody.row.entry__content" use-attribute-sets="common.table.body.entry">
  </xsl:attribute-set>
</xsl:stylesheet>