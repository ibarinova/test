<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:variable name="toc.text-indent" select="'10pt'"/>
    <xsl:variable name="toc.toc-indent" select="'14pt'"/>

    <xsl:attribute-set name="__glossary__label">
        <xsl:attribute name="space-before">20pt</xsl:attribute>
        <xsl:attribute name="space-after">20pt</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">22pt</xsl:when>
                <xsl:otherwise>24pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__index__label">
        <xsl:attribute name="space-before">20pt</xsl:attribute>
        <xsl:attribute name="space-after">20pt</xsl:attribute>
        <xsl:attribute name="space-after.conditionality">retain</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="span">all</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">22pt</xsl:when>
                <xsl:otherwise>24pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__header" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__header_content">
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="padding-top">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">0</xsl:when>
                <xsl:otherwise>20pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="margin-bottom">20pt</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">22pt</xsl:when>
                <xsl:otherwise>24pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__indent">
        <xsl:attribute name="start-indent">
            <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">
                    <xsl:value-of select="concat($side-col-width, ' + (', string($level - 1), ' * ', $toc.toc-indent, ') + ', $toc.text-indent)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($page-margins, ' + ', $side-col-width, ' + (', string($level - 1), ' * ', $toc.toc-indent, ') + ', $toc.text-indent)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="padding-bottom">2pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__link">
        <xsl:attribute name="line-height">15pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__topic__content">
        <xsl:attribute name="last-line-end-indent">-22pt</xsl:attribute>
        <xsl:attribute name="end-indent">22pt</xsl:attribute>
        <xsl:attribute name="text-indent">-<xsl:value-of select="$toc.text-indent"/></xsl:attribute>
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="text-align-last">justify</xsl:attribute>
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__chapter__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">11.5pt</xsl:when>
                <xsl:otherwise>10pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="padding-top">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__appendix__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="padding-top">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__part__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="padding-top">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__preface__content" use-attribute-sets="__toc__topic__content">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="padding-top">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="minitoc__ul.li__content">
        <xsl:attribute name="text-align-last">justify</xsl:attribute>
        <xsl:attribute name="line-height">12pt</xsl:attribute>
    </xsl:attribute-set>
   <xsl:attribute-set name ="__toc__topic__content_loft">
    <xsl:attribute name="last-line-end-indent">-22pt</xsl:attribute>
        <xsl:attribute name="end-indent">22pt</xsl:attribute>
        <xsl:attribute name="text-indent">-<xsl:value-of select="$toc.text-indent"/></xsl:attribute>
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="text-align-last">justify</xsl:attribute>
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
		<xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    
	<xsl:attribute name="space-before">5pt</xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
  </xsl:attribute-set>
</xsl:stylesheet>