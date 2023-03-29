<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                version="2.0">

    <xsl:attribute-set name="simple-page-master">
        <xsl:attribute name="page-width">
            <xsl:value-of select="$page-width"/>
        </xsl:attribute>
        <xsl:attribute name="page-height">
            <xsl:value-of select="$page-height"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-master-print.odd">
        <xsl:attribute name="axf:bleed">10pt</xsl:attribute>
        <xsl:attribute name="axf:printer-marks">crop cross</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-top">10mm</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-bottom">12mm</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-left">20mm</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-right">15mm</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-master-print.even">
        <xsl:attribute name="axf:bleed">10pt</xsl:attribute>
        <xsl:attribute name="axf:printer-marks">crop cross</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-top">10mm</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-bottom">12mm</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-right">20mm</xsl:attribute>
        <xsl:attribute name="axf:crop-offset-left">15mm</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-after">
        <xsl:attribute name="extent">0.6562in</xsl:attribute>
        <xsl:attribute name="display-align">before</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-body_toc.even">
        <xsl:attribute name="margin-top">
            <xsl:value-of select="$page-margin-top_toc"/>
        </xsl:attribute>
        <xsl:attribute name="margin-bottom">
            <xsl:value-of select="$page-margin-bottom"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-left' else 'margin-right'}">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-right' else 'margin-left'}">
            <xsl:value-of select="$page-margin-inside"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-body_toc.odd">
        <xsl:attribute name="margin-top">
            <xsl:value-of select="$page-margin-top_toc"/>
        </xsl:attribute>
        <xsl:attribute name="margin-bottom">
            <xsl:value-of select="$page-margin-bottom"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-left' else 'margin-right'}">
            <xsl:value-of select="$page-margin-inside"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-right' else 'margin-left'}">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-body_notice.even">
        <xsl:attribute name="margin-top">
            <xsl:value-of select="$page-margin-top"/>
        </xsl:attribute>
        <xsl:attribute name="margin-bottom">
            <xsl:value-of select="$page-margin-bottom"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-left' else 'margin-right'}">
            <xsl:value-of select="$page-margin-inside"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-right' else 'margin-left'}">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>
