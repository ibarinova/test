<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

    <xsl:attribute-set name="region-after">
        <xsl:attribute name="extent">
            <xsl:value-of select="$page-margin-bottom"/>
        </xsl:attribute>
        <xsl:attribute name="display-align">before</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="simple-page-master-landscape">
        <xsl:attribute name="page-width">
            <xsl:value-of select="$page-height"/>
        </xsl:attribute>
        <xsl:attribute name="page-height">
            <xsl:value-of select="$page-width"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-body.odd-landscape">
        <xsl:attribute name="margin-top">
            <xsl:value-of select="$page-margin-inside"/>
        </xsl:attribute>
        <xsl:attribute name="margin-bottom">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-left' else 'margin-right'}">
            <xsl:value-of select="$page-margin-top"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-right' else 'margin-left'}">
            <xsl:value-of select="$page-margin-bottom"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-body.even-landscape">
        <xsl:attribute name="margin-top">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
        <xsl:attribute name="margin-bottom">
            <xsl:value-of select="$page-margin-inside"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-left' else 'margin-right'}">
            <xsl:value-of select="$page-margin-top"/>
        </xsl:attribute>
        <xsl:attribute name="{if ($writing-mode = 'lr') then 'margin-right' else 'margin-left'}">
            <xsl:value-of select="$page-margin-bottom"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-before-landscape">
        <xsl:attribute name="extent">
            <xsl:value-of select="$page-margin-top"/>
        </xsl:attribute>
        <xsl:attribute name="display-align">before</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="region-after-landscape">
        <xsl:attribute name="extent">
            <xsl:value-of select="$page-margin-bottom"/>
        </xsl:attribute>
        <xsl:attribute name="display-align">after</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>