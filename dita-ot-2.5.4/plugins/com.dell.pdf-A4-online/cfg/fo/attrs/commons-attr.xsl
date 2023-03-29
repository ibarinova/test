<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">
    <xsl:attribute-set name="__force__page__count">
        <xsl:attribute name="force-page-count">
            <xsl:choose>
                <xsl:when test="/*[contains(@class, ' bookmap/bookmap ')]">
                    <xsl:value-of select="'auto'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'auto'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="break.page">
        <xsl:attribute name="break-before">page</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="break.page.after">
        <xsl:attribute name="break-after">page</xsl:attribute>
        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.toc" use-attribute-sets="__force__page__count page-sequence.frontmatter">
        <xsl:attribute name="format">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="page-sequence.frontmatter" >
        <xsl:attribute name="format">1</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="chapter__header_content">
        <xsl:attribute name="font-size">22pt</xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
        <xsl:attribute name="padding-top">20pt</xsl:attribute>
        <xsl:attribute name="margin-bottom">20pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="header_blue_bar_container">
        <xsl:attribute name="display-align">center</xsl:attribute>
        <xsl:attribute name="height">14.5mm</xsl:attribute>
        <xsl:attribute name="width">4.1in</xsl:attribute>
        <xsl:attribute name="top">-4mm</xsl:attribute>
        <xsl:attribute name="right">0pt</xsl:attribute>
        <xsl:attribute name="left">3.65in</xsl:attribute>
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="text-align">
            <xsl:choose>
                <xsl:when test="$writing-mode='rl-tb'">left</xsl:when>
                <xsl:otherwise>right</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="background-color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
        <xsl:attribute name="color">white</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="header_blue_bar_content">
        <xsl:attribute name="padding-top">3pt</xsl:attribute>
        <xsl:attribute name="margin-right"><xsl:value-of select="$page-margins"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__mini__header_technote" use-attribute-sets="__toc__mini common.title">
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="space-before">12pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="keep-with-previous.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__toc__mini__header" use-attribute-sets="__toc__mini common.title">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="footer.text">
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="$isTechnote">normal</xsl:when>
                <xsl:when test="$isNochap">normal</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell-bold-font-weight"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="$isTechnote"><xsl:value-of select="$dell-font-family"/></xsl:when>
                <xsl:when test="$isNochap"><xsl:value-of select="$dell-font-family"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell-bold-font-family"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
        <xsl:attribute name="line-height">11pt</xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">black</xsl:when>
                <xsl:when test="$isTechnote">#AAAAAA</xsl:when>
                <xsl:when test="$isNochap">#AAAAAA</xsl:when>
                <xsl:otherwise>#808080</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="margin-top">10mm</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__fo__root" use-attribute-sets="base-font">
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-font-family"/></xsl:attribute>
        <!-- TODO: https://issues.apache.org/jira/browse/FOP-2409 -->
        <xsl:attribute name="xml:lang" select="translate($locale, '_', '-')"/>
        <xsl:attribute name="writing-mode" select="$writing-mode"/>
        <xsl:attribute name="letter-spacing">
            <xsl:choose>
                <xsl:when test="(lower-case($locale) = ('en-us', 'en', 'en_us')) and not($dell-brand = ('Alienware', 'Non-brand'))">0.3pt</xsl:when>
                <xsl:otherwise>inherit</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.title">
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="common.link">
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">blue</xsl:when>
                <xsl:otherwise>#006bbd</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="text-decoration">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">underline</xsl:when>
                <xsl:otherwise>none</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_table" use-attribute-sets="common.block">
        <xsl:attribute name="space-before">0em</xsl:attribute>
        <xsl:attribute name="space-after">6pt</xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-font-family"/></xsl:attribute>
        <xsl:attribute name="font-size"><xsl:value-of select="$default-font-size"/></xsl:attribute>
        <xsl:attribute name="line-height">
            <xsl:choose>
                <xsl:when test="ancestor::table">12pt</xsl:when>
                <xsl:otherwise>13pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
        <xsl:attribute name="table-layout">fixed</xsl:attribute>
        <xsl:attribute name="inline-progression-dimension">100%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_image_cell">
        <xsl:attribute name="border-end-color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">black</xsl:when>
                <xsl:when test="@type = 'warning'">rgb(206,17,38)</xsl:when>
                <xsl:when test="@type = 'caution'">rgb(242,175,0)</xsl:when>
                <xsl:otherwise>rgb(0,118,206)</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="border-end-width">1pt</xsl:attribute>
        <xsl:attribute name="border-end-style">solid</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note__image">
        <xsl:attribute name="space-after">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_body_cell_content">
        <xsl:attribute name="margin-left">2pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="@type = ('warning', 'caution')">
                    <xsl:value-of select="$dell-bold-font-weight"/>
                </xsl:when>
                <xsl:otherwise>normal</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="@type = ('warning', 'caution')">
                    <xsl:value-of select="$dell-bold-font-family"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-font-family"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_body_cell">
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="display-align">center</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="note_colored_text">
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">black</xsl:when>
                <xsl:when test="@type = 'warning'">rgb(206,17,38)</xsl:when>
                <xsl:when test="@type = 'caution'">rgb(242,175,0)</xsl:when>
                <xsl:otherwise>rgb(0,118,206)</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic_guid">
        <xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
        <xsl:attribute name="space-after">10pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="pubmeta_data_container">
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-font-family"/></xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="space-before">10pt</xsl:attribute>
        <xsl:attribute name="space-after">3pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="related-links">
        <xsl:attribute name="space-after">10pt</xsl:attribute>
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
        <xsl:attribute name="font-size">6.75pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn_container">
        <xsl:attribute name="font-size">inherit</xsl:attribute>
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

</xsl:stylesheet>