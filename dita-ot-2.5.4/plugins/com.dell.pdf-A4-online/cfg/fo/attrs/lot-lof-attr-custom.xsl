<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="__lotf__heading" use-attribute-sets="__toc__header">
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__indent">
        <xsl:attribute name="start-indent">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">
                    <xsl:value-of select="concat($side-col-width, ' + ', $toc.text-indent)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($page-margins, ' + ', $side-col-width, ' + ', $toc.text-indent)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__table_left_indent">
        <xsl:attribute name="column-width">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">0pt</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$page-margins"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__content" use-attribute-sets="base-font __toc__topic__content__booklist">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="space-before">5pt</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__leader">
        <xsl:attribute name="leader-pattern">dots</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__title" use-attribute-sets="__lotf__content">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__number">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-font-family"/></xsl:attribute>
        <xsl:attribute name="line-height">15pt</xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__page-number">
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="keep-together.within-line">always</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__lotf__topic__content">
        <xsl:attribute name="line-height">15pt</xsl:attribute>
        <xsl:attribute name="last-line-end-indent">-22pt</xsl:attribute>
        <xsl:attribute name="end-indent">22pt</xsl:attribute>
        <xsl:attribute name="text-indent">0pt</xsl:attribute>
        <xsl:attribute name="text-align">start</xsl:attribute>
        <xsl:attribute name="text-align-last">justify</xsl:attribute>
    </xsl:attribute-set>
</xsl:stylesheet>
