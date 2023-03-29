<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="__frontmatter">
        <xsl:attribute name="text-align">left</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">48mm</xsl:when>
                <xsl:otherwise>68mm</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">20pt</xsl:when>
                <xsl:otherwise>24pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">#808080</xsl:when>
                <xsl:when test="$dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__subtitle" use-attribute-sets="common.title">
        <xsl:attribute name="font-size">
            <xsl:attribute name="font-size">
                <xsl:choose>
                    <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">20pt</xsl:when>
                    <xsl:otherwise>22pt</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">#808080</xsl:when>
                <xsl:otherwise>black</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="line-height">140%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="technote-main-bluebar-header_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="left">-<xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="right">-<xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="top">-<xsl:value-of select="$page-margin-top"/></xsl:attribute>
        <xsl:attribute name="height">1in</xsl:attribute>
        <xsl:attribute name="background-color">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:when test="$dell-brand = 'Non-brand'"><xsl:value-of select="$dell_gray"/></xsl:when>
                <xsl:when test="$dell-brand = 'Alienware'">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="display-align">center</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="technote-main-bluebar-header">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="margin-left"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="margin-right"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="color">white</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="nochap-main-bluebar-header_container" use-attribute-sets="technote-main-bluebar-header_container">
        <xsl:attribute name="top">auto</xsl:attribute>
        <xsl:attribute name="bottom">-<xsl:value-of select="$page-margin-bottom"/></xsl:attribute>
        <xsl:attribute name="background-color">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'RSA'">none</xsl:when>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">none</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="nochap-main-bluebar-header" use-attribute-sets="technote-main-bluebar-header">
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'RSA'">inherit</xsl:when>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">inherit</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell-bold-font-weight"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'RSA'">black</xsl:when>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">black</xsl:when>
                <xsl:otherwise>white</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="left">-<xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="right">-<xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="bottom">-<xsl:value-of select="$page-margin-bottom"/></xsl:attribute>
        <xsl:attribute name="height">33mm</xsl:attribute>
        <xsl:attribute name="background-color">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">none</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="display-align">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'Alienware'">center</xsl:when>
                <xsl:otherwise>after</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="margin-left"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="margin-right"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="margin-bottom"><xsl:value-of select="$page-margins"/></xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">black</xsl:when>
                <xsl:otherwise>white</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-size">7pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_table">
        <xsl:attribute name="margin-left">0</xsl:attribute>
        <xsl:attribute name="margin-right">0</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_content_cell">
        <xsl:attribute name="margin-left">0</xsl:attribute>
        <xsl:attribute name="margin-right">0</xsl:attribute>
        <xsl:attribute name="start-indent">0</xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_content_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="bottom">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'Dell'">-20.5pt</xsl:when>
                <xsl:when test="$dell-brand = 'Dell Technologies'">-0.5pt</xsl:when>
                <xsl:when test="$dell-brand = 'Dell EMC'">-5.5pt</xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="top">auto</xsl:attribute>
        <xsl:attribute name="right">auto</xsl:attribute>
        <xsl:attribute name="left">0pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter_footer_logo">
        <xsl:attribute name="margin-bottom">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'Alienware'">0</xsl:when>
                <xsl:when test="$dell-brand = 'Dell EMC'">-7pt</xsl:when>
                <xsl:when test="$dell-brand = 'RSA'">-18pt</xsl:when>
				<xsl:when test="$dell-brand = 'Dell Technologies'">-40pt</xsl:when>
                <xsl:otherwise>-23pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__technote_header_logo">
        <xsl:attribute name="text-align">right</xsl:attribute>
        <xsl:attribute name="end-indent">0</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__solutions_abstract_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="top">5.31in</xsl:attribute>
        <xsl:attribute name="left">0.5in</xsl:attribute>
        <xsl:attribute name="right">0.7in</xsl:attribute>
        <xsl:attribute name="bottom">3.5in</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="__frontmatter__solutions_shortdesc" use-attribute-sets="__frontmatter__solutions">
        <xsl:attribute name="space-after">
            <xsl:choose>
                <xsl:when test="$isNochap">4pt</xsl:when>
                <xsl:otherwise>8pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="__frontmatter__solutions_author_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="top">7.11in</xsl:attribute>
        <xsl:attribute name="left">0in</xsl:attribute>
        <xsl:attribute name="right">0in</xsl:attribute>
        <xsl:attribute name="bottom">2.7in</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="__frontmatter__solutions_abstrac_title" use-attribute-sets="__frontmatter__solutions">
        <xsl:attribute name="space-before">
            <xsl:choose>
                <xsl:when test="$isNochap">10pt</xsl:when>
            </xsl:choose>
        </xsl:attribute>
		<xsl:attribute name="space-after">
            <xsl:choose>
                <xsl:when test="$isNochap">4pt</xsl:when>
                <xsl:otherwise>8pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="$isNochap">inherit</xsl:when>
                <xsl:otherwise>12pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
		<xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
		<xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__author" use-attribute-sets="__frontmatter__solutions">
		<xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
		<xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
		<xsl:attribute name="space-before">
            <xsl:choose>
                <xsl:when test="$isNochap">30pt</xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="space-after">
            <xsl:choose>
                <xsl:when test="$isNochap">30pt</xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="$dell-brand = 'RSA'">black</xsl:when>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__solutions">
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="$isNochap">inherit</xsl:when>
                <xsl:otherwise>11pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="line-height">11pt</xsl:attribute>
        <xsl:attribute name="color"><xsl:value-of select="$dell_gray"/></xsl:attribute>
        <xsl:attribute name="space-before">
            <xsl:choose>
                <xsl:when test="$isNochap">4pt</xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

	<!--For release date and revision content in front matter footer-->
	<xsl:attribute-set name="release-revision">
		<xsl:attribute name="margin-bottom">
		<xsl:choose>
                <xsl:when test="$dell-brand = 'Alienware'">-3pt</xsl:when>
                <xsl:when test="$dell-brand = 'Dell EMC'">-5pt</xsl:when>
                <xsl:otherwise>-22pt</xsl:otherwise>
            </xsl:choose>
		</xsl:attribute>
		<xsl:attribute name="padding-top">15pt</xsl:attribute>
    </xsl:attribute-set>
	<xsl:attribute-set name="vrm-cover-page">
        <xsl:attribute name="margin-top">-20pt</xsl:attribute>
		<xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">#808080</xsl:when>
                <xsl:when test="$dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
			</xsl:attribute>
			<xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
			<xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
    </xsl:attribute-set>
	<xsl:attribute-set name="draft.watermark.cover">
        <xsl:attribute name="font-size">24pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:value-of select="$dell-bold-font-weight"/>
        </xsl:attribute>
		<xsl:attribute name="color">
            <xsl:value-of select="$dell_blue"/>
        </xsl:attribute>
		<xsl:attribute name="text-align">center</xsl:attribute>
     </xsl:attribute-set>
	  <xsl:attribute-set name="restriction.watermark.cover">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">inherit</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell-bold-font-weight"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="padding-top">8pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">8pt</xsl:attribute>
        <xsl:attribute name="padding-left">12pt</xsl:attribute>
        <xsl:attribute name="padding-right">12pt</xsl:attribute>
		<xsl:attribute name="border">1pt solid black</xsl:attribute>
    </xsl:attribute-set>
</xsl:stylesheet>