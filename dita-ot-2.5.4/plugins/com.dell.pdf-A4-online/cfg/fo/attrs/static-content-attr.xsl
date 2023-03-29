<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="pagenum">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="restriction.watermark_container">
        <xsl:attribute name="position">fixed</xsl:attribute>
        <xsl:attribute name="top">10mm</xsl:attribute>
        <xsl:attribute name="left"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="right"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="height">7mm</xsl:attribute>
        <xsl:attribute name="text-align">center</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="restriction.watermark_container_landscape" use-attribute-sets="restriction.watermark_container">
        <xsl:attribute name="right">10mm</xsl:attribute>
        <xsl:attribute name="left">auto</xsl:attribute>
        <xsl:attribute name="top"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="bottom"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="reference-orientation">270</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="restriction.watermark_container.technote" use-attribute-sets="restriction.watermark_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="left">0mm</xsl:attribute>
        <xsl:attribute name="right">0mm</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="restriction.draft.watermark">
        <xsl:attribute name="font-size">24pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">inherit</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell-bold-font-weight"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
		<xsl:attribute name="color">
            <xsl:value-of select="$dell_blue"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="restriction.watermark">
        <xsl:attribute name="font-size">11.5pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">inherit</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell-bold-font-weight"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="padding-top">8pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">8pt</xsl:attribute>
    </xsl:attribute-set>
</xsl:stylesheet>