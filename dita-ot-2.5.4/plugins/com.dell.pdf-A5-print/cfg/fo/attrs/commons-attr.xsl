<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:attribute-set name="__force__page__count">
        <xsl:attribute name="force-page-count">
            <xsl:choose>
                <xsl:when test="$multilingual and $isManual">
                    <xsl:value-of select="'end-on-even'"/>
                </xsl:when>
                <xsl:when test="$multilingual">
                    <xsl:value-of select="'even'"/>
                </xsl:when>
                <xsl:when test="/*[contains(@class, ' bookmap/bookmap ')]">
                    <xsl:value-of select="'auto'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'auto'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.cover-manual">
        <xsl:attribute name="force-page-count">odd</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="base-font">
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::*[contains(@outputclass, 'notice')]">8pt</xsl:when>
                <xsl:otherwise><xsl:value-of select="$default-font-size"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.block">
        <xsl:attribute name="space-before">0.9em</xsl:attribute>
        <xsl:attribute name="space-after">0.9em</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.link">
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="text-decoration">none</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="break.page">
        <xsl:attribute name="break-before">page</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="break.page.odd">
        <xsl:attribute name="break-before">odd-page</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.toc" use-attribute-sets="__force__page__count page-sequence.frontmatter">
        <xsl:attribute name="format">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.notice">
        <xsl:attribute name="force-page-count">auto</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.frontmatter" >
        <xsl:attribute name="format">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_table" use-attribute-sets="common.block">
        <xsl:attribute name="space-before">0em</xsl:attribute>
        <xsl:attribute name="space-after">6pt</xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
        <xsl:attribute name="line-height"><xsl:value-of select="$default-line-height"/></xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="inline-progression-dimension">100%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_image_cell">
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note__image">
        <xsl:attribute name="margin-top">0</xsl:attribute>
        <xsl:attribute name="space-after">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_body_cell_content">
        <xsl:attribute name="margin-left">2pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="(@type = 'other') and (lower-case(@othertype) = 'battery')">bold</xsl:when>
                <xsl:when test="@type = ('warning', 'caution', 'danger')">bold</xsl:when>
                <xsl:when test="@type = 'other'">bold</xsl:when>
                <xsl:otherwise>normal</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="(@type = 'other') and (lower-case(@othertype) = 'battery')">sans-bold</xsl:when>
                <xsl:when test="@type = ('warning', 'caution', 'danger')">sans-bold</xsl:when>
                <xsl:when test="@type = 'other'">sans-bold</xsl:when>
                <xsl:otherwise>serif</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_body_cell_type">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_body_cell">
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="display-align">center</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.border__top">
        <xsl:attribute name="border-before-style">solid</xsl:attribute>
        <xsl:attribute name="border-before-width">1pt</xsl:attribute>
        <xsl:attribute name="border-before-color">black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.border__bottom">
        <xsl:attribute name="border-after-style">solid</xsl:attribute>
        <xsl:attribute name="border-after-width">1pt</xsl:attribute>
        <xsl:attribute name="border-after-color">black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.border__right">
        <xsl:attribute name="border-end-style">solid</xsl:attribute>
        <xsl:attribute name="border-end-width">1pt</xsl:attribute>
        <xsl:attribute name="border-end-color">black</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.border__left">
        <xsl:attribute name="border-start-style">solid</xsl:attribute>
        <xsl:attribute name="border-start-width">1pt</xsl:attribute>
        <xsl:attribute name="border-start-color">black</xsl:attribute>
    </xsl:attribute-set>
	<xsl:attribute-set name="topic_guid">
        <xsl:attribute name="space-after">10pt</xsl:attribute>
    </xsl:attribute-set>
</xsl:stylesheet>