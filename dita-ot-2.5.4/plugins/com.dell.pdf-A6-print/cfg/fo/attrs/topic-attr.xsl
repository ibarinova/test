<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="chapter_header_number">
        <xsl:attribute name="margin-top">16pt</xsl:attribute>
        <xsl:attribute name="font-size">18pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="color">grey</xsl:attribute>
        <xsl:attribute name="text-align">right</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.title" use-attribute-sets="common.title common.border__bottom">
        <xsl:attribute name="border-after-width">0pt</xsl:attribute>
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.title" use-attribute-sets="common.title common.border__bottom">
        <xsl:attribute name="border-after-width">0pt</xsl:attribute>
        <xsl:attribute name="space-before">12pt</xsl:attribute>
        <xsl:attribute name="space-after">8pt</xsl:attribute>
        <xsl:attribute name="font-size">14pt</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">10pt</xsl:attribute>
        <xsl:attribute name="space-after">8pt</xsl:attribute>
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.topic.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="space-before">10pt</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
        <xsl:attribute name="start-indent"><xsl:value-of select="$side-col-width"/></xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.topic.topic.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="space-before">8pt</xsl:attribute>
        <xsl:attribute name="space-after">4pt</xsl:attribute>
        <xsl:attribute name="start-indent"><xsl:value-of select="$side-col-width"/></xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.topic.topic.topic.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="space-before">6pt</xsl:attribute>
        <xsl:attribute name="space-after">4pt</xsl:attribute>
        <xsl:attribute name="start-indent"><xsl:value-of select="$side-col-width"/></xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section.title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">6pt</xsl:attribute>
        <xsl:attribute name="space-after">4pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="example.title" use-attribute-sets="common.title">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="space-before">6pt</xsl:attribute>
        <xsl:attribute name="space-after">4pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.title_notice" use-attribute-sets="common.title">
        <xsl:attribute name="padding-top">4mm</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-data_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="bottom">20pt</xsl:attribute>
        <xsl:attribute name="display-align">after</xsl:attribute>
        <xsl:attribute name="line-height">100%</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-copyrights_content">
        <xsl:attribute name="line-height">100%</xsl:attribute>
        <xsl:attribute name="font-size">5pt</xsl:attribute>
        <xsl:attribute name="color">rgb-icc(0,0,0,#CMYK,0, 0, 0, 1)</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-data_content">
        <xsl:attribute name="font-size">5pt</xsl:attribute>
        <xsl:attribute name="padding-top">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fig">
        <xsl:attribute name="text-align"><xsl:value-of select="$imageDefaultAlignment"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fig.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="font-weight">bold</xsl:attribute>
        <xsl:attribute name="font-family">sans-bold</xsl:attribute>
        <xsl:attribute name="font-size">5.5pt</xsl:attribute>
        <xsl:attribute name="space-before">4pt</xsl:attribute>
        <xsl:attribute name="space-after">12pt</xsl:attribute>
        <xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__body" use-attribute-sets="base-font">
        <xsl:attribute name="provisional-distance-between-starts">8mm</xsl:attribute>
        <xsl:attribute name="provisional-label-separation">2mm</xsl:attribute>
        <xsl:attribute name="line-height">1.2</xsl:attribute>
        <xsl:attribute name="start-indent">0pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__callout_ref">
        <xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
        <xsl:attribute name="baseline-shift">super</xsl:attribute>
        <xsl:attribute name="font-size">75%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn_container">
        <xsl:attribute name="font-size">inherit</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fig_callout_entry">
        <xsl:attribute name="border-spacing">0.15in</xsl:attribute>
        <xsl:attribute name="padding">1pt</xsl:attribute>
        <xsl:attribute name="writing-mode"><xsl:value-of select="$writing-mode"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__callout">
        <xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
        <xsl:attribute name="baseline-shift">5%</xsl:attribute>
        <xsl:attribute name="font-size">75%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__callout_sup">
        <xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
        <xsl:attribute name="baseline-shift">super</xsl:attribute>
        <xsl:attribute name="font-size">75%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="p" use-attribute-sets="common.block">
        <xsl:attribute name="text-indent">0em</xsl:attribute>
        <xsl:attribute name="padding-bottom">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/li ')] and not(following-sibling::*)">0.9em</xsl:when>
                <xsl:otherwise>0em</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="lq" use-attribute-sets="common.block">
        <xsl:attribute name="start-indent">5mm</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="lq_simple" use-attribute-sets="common.block">
        <xsl:attribute name="start-indent">5mm</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>