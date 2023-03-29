<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">

    <xsl:attribute-set name="__frontmatter">
        <xsl:attribute name="text-align">left</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">43mm</xsl:attribute>
        <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        <xsl:attribute name="font-size">20pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
        <xsl:attribute name="color">#808080</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__title-multilingual" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">15mm</xsl:attribute>
        <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        <xsl:attribute name="font-size">20pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
        <xsl:attribute name="color">#808080</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__subtitle" use-attribute-sets="common.title">
        <xsl:attribute name="font-size">20pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
        <xsl:attribute name="color">#808080</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__subtitle-multilingual" use-attribute-sets="common.title">
        <xsl:attribute name="font-size">15pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
        <xsl:attribute name="space-before">2mm</xsl:attribute>
        <xsl:attribute name="color">#808080</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_container">
        <xsl:attribute name="position">fixed</xsl:attribute>
        <xsl:attribute name="left"><xsl:value-of select="$page-margin-inside"/></xsl:attribute>
        <xsl:attribute name="right"><xsl:value-of select="$page-margin-outside"/></xsl:attribute>
        <xsl:attribute name="bottom">0.25in</xsl:attribute>
        <xsl:attribute name="height">33mm</xsl:attribute>
        <xsl:attribute name="display-align">after</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
        <xsl:attribute name="font-size">6pt</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="line-height">7pt</xsl:attribute>
        <xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer-multilingual">
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="font-family">serif</xsl:attribute>
        <xsl:attribute name="line-height">10pt</xsl:attribute>
        <xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_table">
        <xsl:attribute name="margin-left">0</xsl:attribute>
        <xsl:attribute name="margin-right">0</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_content">
        <xsl:attribute name="margin-left">0</xsl:attribute>
        <xsl:attribute name="margin-right">0</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_logo">
        <xsl:attribute name="margin-bottom">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'Dell EMC'">-1pt</xsl:when>
				<xsl:when test="$dell-brand = 'Dell Technologies'">-40pt</xsl:when>
                <xsl:otherwise>-9pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="back-cover">
        <xsl:attribute name="force-page-count">auto</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__back-cover.footer.container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="top">0in</xsl:attribute>
        <xsl:attribute name="bottom">0.65in</xsl:attribute>
        <xsl:attribute name="left">0in</xsl:attribute>
        <xsl:attribute name="width">100%</xsl:attribute>
        <xsl:attribute name="display-align">after</xsl:attribute>
        <xsl:attribute name="break-before">even-page</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__back-cover.footer.text">
        <xsl:attribute name="text-align-last">center</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__back-cover.url">
        <xsl:attribute name="space-after">0.375in</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__back-cover.barcode.image">
        <xsl:attribute name="width">100%</xsl:attribute>
        <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
        <xsl:attribute name="scaling">uniform</xsl:attribute>
        <xsl:attribute name="content-height">100%</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>