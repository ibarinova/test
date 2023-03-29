<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

    <xsl:attribute-set name="footer__text_block">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
        <xsl:attribute name="line-height">11pt</xsl:attribute>
        <xsl:attribute name="padding-top">12pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="footer_pagenum_odd">
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
        <xsl:attribute name="end-indent">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="footer_pagenum_even">
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
        <xsl:attribute name="start-indent">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="footer_logo_container">
        <xsl:attribute name="margin-top">-1mm</xsl:attribute>
        <xsl:attribute name="start-indent">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
        <xsl:attribute name="end-indent">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>