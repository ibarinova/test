<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:attribute-set name="topic.title" use-attribute-sets="common.title common.border__bottom">
        <xsl:attribute name="border-after-width">0pt</xsl:attribute>
        <xsl:attribute name="space-before">
            <xsl:choose>
                <xsl:when test="$isTechnote">0.4in</xsl:when>
                <xsl:otherwise>0pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="space-after">16.8pt</xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">22pt</xsl:when>
                <xsl:otherwise>24pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="$isNochap and (($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware'))"><xsl:value-of select="$dell_gray"/></xsl:when>
                <xsl:when test="$isNochap and $dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="text-align">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">left</xsl:when>
                <xsl:when test="$isTechnote">left</xsl:when>
                <xsl:when test="$isNochap">left</xsl:when>
                <xsl:otherwise>right</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.title_technote" use-attribute-sets="topic.title">
        <xsl:attribute name="margin-top">0.9in</xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="$isNochap and (($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware'))"><xsl:value-of select="$dell_gray"/></xsl:when>
                <xsl:when test="$isNochap and $dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:when test="$isTechnote and $dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.title_nochap" use-attribute-sets="topic.title">
        <xsl:attribute name="margin-top">1.5in</xsl:attribute>
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="space-after">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="cover_chaptet.title_nochap" use-attribute-sets="topic.title">
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
        <xsl:attribute name="color"><xsl:value-of select="$dell_gray"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.titlealt_nochap_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="top">0in</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.titlealt_nochap">
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">22pt</xsl:when>
                <xsl:otherwise>24pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="color"><xsl:value-of select="$dell_gray"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.title" use-attribute-sets="common.title common.border__bottom">
        <xsl:attribute name="border-after-width">0pt</xsl:attribute>
        <xsl:attribute name="space-before">6mm</xsl:attribute>
        <xsl:attribute name="space-after">4mm</xsl:attribute>
        <xsl:attribute name="font-size">20pt</xsl:attribute>
        <xsl:attribute name="padding-top">0pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">normal</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-weight"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">
                    <xsl:value-of select="$dell-font-family"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-family"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">6mm</xsl:attribute>
        <xsl:attribute name="space-after">4mm</xsl:attribute>
        <xsl:attribute name="font-size">16pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">normal</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-weight"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">
                    <xsl:value-of select="$dell-font-family"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-family"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.topic.title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">6mm</xsl:attribute>
        <xsl:attribute name="space-after">4mm</xsl:attribute>
        <xsl:attribute name="font-size">14pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">normal</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-weight"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">
                    <xsl:value-of select="$dell-font-family"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-family"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.topic.topic.title" use-attribute-sets="common.title">
        <xsl:attribute name="space-before">6mm</xsl:attribute>
        <xsl:attribute name="space-after">4mm</xsl:attribute>
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">normal</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-weight"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">
                    <xsl:value-of select="$dell-font-family"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-family"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.topic.topic.topic.topic.topic.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="start-indent"><xsl:value-of select="$side-col-width"/></xsl:attribute>
        <xsl:attribute name="font-style">normal</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="space-before">6mm</xsl:attribute>
        <xsl:attribute name="space-after">0.6em</xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">normal</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-weight"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-family">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/section ')]">
                    <xsl:value-of select="$dell-font-family"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$dell-bold-font-family"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="topic.title_notice" use-attribute-sets="common.title">
        <xsl:attribute name="padding-top">0</xsl:attribute>
        <xsl:attribute name="space-after">16.8pt</xsl:attribute>
        <xsl:attribute name="font-size">11.5pt</xsl:attribute>
        <xsl:attribute name="font-weight">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">
                    <xsl:value-of select="$dell-bold-font-weight"/>
                </xsl:when>
                <xsl:otherwise>inherit</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">black</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="linklist.title" use-attribute-sets="common.title">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="space-before">15pt</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="section.title" use-attribute-sets="common.title">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="space-before">15pt</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="example.title" use-attribute-sets="common.title">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
        <xsl:attribute name="space-after">5pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-data_container">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="bottom">-10mm</xsl:attribute>
        <xsl:attribute name="display-align">after</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-data_container_technote">
        <xsl:attribute name="position">absolute</xsl:attribute>
        <xsl:attribute name="bottom">0mm</xsl:attribute>
        <xsl:attribute name="display-align">after</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-copyrights_content">
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">
            <xsl:choose>
                <xsl:when test="$isTechnote">0mm</xsl:when>
                <xsl:when test="$isNochap">0mm</xsl:when>
                <xsl:when test="$isTechnote">0mm</xsl:when>
                <xsl:otherwise>22mm</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-copyrights_content_technote">
        <xsl:attribute name="font-size">8pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="notices-data_content">
        <xsl:attribute name="font-size">8pt</xsl:attribute>
        <xsl:attribute name="padding-top">16pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="cover_vrm_nochap">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="padding-bottom">12pt</xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')"><xsl:value-of select="$dell_gray"/></xsl:when>
                <xsl:when test="$dell-brand = 'RSA'"><xsl:value-of select="$rsa_red"/></xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="cover_rev_nochap">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="font-size">11pt</xsl:attribute>
        <xsl:attribute name="color"><xsl:value-of select="$dell_gray"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fig.title" use-attribute-sets="base-font common.title">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="color">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware') or ($dell-brand = 'RSA')">#808080</xsl:when>
                <xsl:otherwise><xsl:value-of select="$dell_blue"/></xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="space-before">5pt</xsl:attribute>
        <xsl:attribute name="space-after">
            <xsl:choose>
                <xsl:when test="following-sibling::*[contains(@class, ' topic/ol ')]">5pt</xsl:when>
                <xsl:otherwise>16pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="keep-with-previous.within-page">always</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fig">
        <xsl:attribute name="text-align"><xsl:value-of select="$imageDefaultAlignment"/></xsl:attribute>
        <xsl:attribute name="space-before">4pt</xsl:attribute>
        <xsl:attribute name="space-after">4pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="draft-comment" use-attribute-sets="common.border">
        <xsl:attribute name="background-color">#99FF99</xsl:attribute>
        <xsl:attribute name="color">black</xsl:attribute>
        <xsl:attribute name="border-after-color">#63d663</xsl:attribute>
        <xsl:attribute name="border-before-color">#63d663</xsl:attribute>
        <xsl:attribute name="border-start-color">#63d663</xsl:attribute>
        <xsl:attribute name="border-end-color">#63d663</xsl:attribute>
        <xsl:attribute name="padding">4pt</xsl:attribute>
        <xsl:attribute name="space-after">6pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="draft-comment__label">
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="topic.body_nochap_1_chapter">
        <xsl:attribute name="margin-top">40pt</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="term">
        <xsl:attribute name="border-start-width">0pt</xsl:attribute>
        <xsl:attribute name="border-end-width">0pt</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="topic.titlealt_nochap">
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware')">22pt</xsl:when>
                <xsl:otherwise>22pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="font-weight"><xsl:value-of select="$dell-bold-font-weight"/></xsl:attribute>
        <xsl:attribute name="font-family"><xsl:value-of select="$dell-bold-font-family"/></xsl:attribute>
        <xsl:attribute name="color"><xsl:value-of select="$dell_gray"/></xsl:attribute>
    </xsl:attribute-set>

	<xsl:attribute-set name="cover_chaptet.title_nochap" use-attribute-sets="topic.title">
        <xsl:attribute name="space-before">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
		<xsl:attribute name="font-size">20pt</xsl:attribute>
        <xsl:attribute name="color"><xsl:value-of select="$dell_gray"/></xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="fn__callout">
        <xsl:attribute name="keep-with-previous.within-line">always</xsl:attribute>
        <xsl:attribute name="baseline-shift">5%</xsl:attribute>
        <xsl:attribute name="font-size">6.75pt</xsl:attribute>
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
                <xsl:when test="parent::*[contains(@class, ' topic/li ')] and not(following-sibling::*)">0.6em</xsl:when>
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