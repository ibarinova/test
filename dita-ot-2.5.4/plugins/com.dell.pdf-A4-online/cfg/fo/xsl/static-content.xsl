<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

    <xsl:template name="insertBodyStaticContents">
        <xsl:call-template name="insertBodyFootnoteSeparator"/>
        <xsl:call-template name="insertBodyOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertBodyEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertBodyFirstFooter"/>
        <xsl:call-template name="insertBodyLastFooter"/>

        <xsl:call-template name="insertRestrictionHeaderWatermark"/>
    </xsl:template>

    <xsl:template name="insertTocStaticContents">
        <xsl:call-template name="insertTocOddFooter"/>
        <xsl:call-template name="insertTocLastFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertTocEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertRestrictionHeaderWatermark"/>
    </xsl:template>

    <xsl:template name="insertIndexStaticContents">
        <xsl:call-template name="insertIndexOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertIndexEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertRestrictionHeaderWatermark"/>
    </xsl:template>

    <xsl:template name="insertPrefaceStaticContents">
        <xsl:call-template name="insertPrefaceFootnoteSeparator"/>
        <xsl:call-template name="insertPrefaceOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertPrefaceEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertPrefaceFirstFooter"/>
        <xsl:call-template name="insertRestrictionHeaderWatermark"/>
    </xsl:template>

    <xsl:template name="insertBackCoverStaticContents">
        <xsl:call-template name="insertBackCoverOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertBackCoverEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertRestrictionHeaderWatermark"/>
    </xsl:template>

    <xsl:template name="insertGlossaryStaticContents">
        <xsl:call-template name="insertGlossaryOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertGlossaryEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertGlossaryFirstFooter"/>
        <xsl:call-template name="insertRestrictionHeaderWatermark"/>
    </xsl:template>

    <xsl:template name="insertRestrictionHeaderWatermark">
        <fo:static-content flow-name="restriction-watermark">
            <fo:block-container xsl:use-attribute-sets="restriction.watermark_container">
                <fo:block>
                    <fo:table>
                        <fo:table-column column-number="1" column-width="15%"/>
                        <fo:table-column column-number="2" column-width="85%"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell>
                                    <xsl:if test="normalize-space($watermark-value)">
                                        <fo:block>
                                            <fo:inline xsl:use-attribute-sets="restriction.draft.watermark">
                                                <xsl:value-of select="$watermark-value"/>
                                            </fo:inline>
                                        </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:if test="normalize-space($restriction-value)">
                                        <fo:block text-align="right">
                                            <fo:inline xsl:use-attribute-sets="restriction.watermark">
                                                <xsl:value-of select="$restriction-value"/>
                                            </fo:inline>
                                        </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:block>
            </fo:block-container>
        </fo:static-content>

        <fo:static-content flow-name="restriction-watermark-first">
            <fo:block-container xsl:use-attribute-sets="restriction.watermark_container">
                <fo:block>
                    <fo:table>
                        <fo:table-column column-number="1" column-width="15%"/>
                        <fo:table-column column-number="2" column-width="85%"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell>
                                    <xsl:if test="normalize-space($watermark-value) and not($isTechnote)">
                                        <fo:block>
                                            <fo:inline xsl:use-attribute-sets="restriction.draft.watermark">
                                                <xsl:value-of select="$watermark-value"/>
                                            </fo:inline>
                                        </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:if test="normalize-space($restriction-value) and not($isTechnote)">
                                        <fo:block text-align="right">
                                            <fo:inline xsl:use-attribute-sets="restriction.watermark">
                                                <xsl:value-of select="$restriction-value"/>
                                            </fo:inline>
                                        </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:block>
            </fo:block-container>
        </fo:static-content>

        <fo:static-content flow-name="restriction-watermark-landscape">
            <fo:block-container xsl:use-attribute-sets="restriction.watermark_container_landscape">
                <fo:block>
                    <fo:table>
                        <fo:table-column column-number="1" column-width="15%"/>
                        <fo:table-column column-number="2" column-width="85%"/>
                        <fo:table-body>
                            <fo:table-row>
                                <fo:table-cell>
                                    <xsl:if test="normalize-space($watermark-value)">
                                        <fo:block>
                                            <fo:inline xsl:use-attribute-sets="restriction.draft.watermark">
                                                <xsl:value-of select="$watermark-value"/>
                                            </fo:inline>
                                        </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
                                <fo:table-cell>
                                    <xsl:if test="normalize-space($restriction-value)">
                                        <fo:block text-align="right">
                                            <fo:inline xsl:use-attribute-sets="restriction.watermark">
                                                <xsl:value-of select="$restriction-value"/>
                                            </fo:inline>
                                        </fo:block>
                                    </xsl:if>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:block>
            </fo:block-container>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyFirstFooter">
        <fo:static-content flow-name="first-body-footer">
            <xsl:if test="not($isNochap)">
                <xsl:call-template name="insertOddFooter_common"/>
            </xsl:if>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLastFooter">
        <fo:static-content flow-name="last-body-footer">
            <xsl:call-template name="insertEvenFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyOddFooter">
        <fo:static-content flow-name="odd-body-footer">
            <xsl:call-template name="insertOddFooter_common"/>
        </fo:static-content>

        <fo:static-content flow-name="odd-body-footer-landscape">
            <fo:block-container display-align="before" height="100%" reference-orientation="270">
                <xsl:call-template name="insertOddFooter_common"/>
            </fo:block-container>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyEvenFooter">
        <fo:static-content flow-name="even-body-footer">
            <xsl:call-template name="insertEvenFooter_common"/>
        </fo:static-content>

        <fo:static-content flow-name="even-body-footer-landscape">
            <fo:block-container display-align="before" height="100%" reference-orientation="270">
                <xsl:call-template name="insertEvenFooter_common"/>
            </fo:block-container>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocOddFooter">
        <fo:static-content flow-name="odd-toc-footer">
            <xsl:call-template name="insertOddFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocEvenFooter">
        <fo:static-content flow-name="even-toc-footer">
            <xsl:call-template name="insertEvenFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocLastFooter">
        <fo:static-content flow-name="even-toc-footer">
            <xsl:call-template name="insertEvenFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryFirstFooter">
        <fo:static-content flow-name="odd-glossary-footer">
            <xsl:call-template name="insertOddFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryOddFooter">
        <fo:static-content flow-name="odd-glossary-footer">
            <xsl:call-template name="insertOddFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryEvenFooter">
        <fo:static-content flow-name="even-glossary-footer">
            <xsl:call-template name="insertEvenFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertOddFooter_common">
        <fo:block xsl:use-attribute-sets="footer.text">
            <fo:table>
                <fo:table-column column-number="1" column-width="88%"/>
                <fo:table-column column-number="2" column-width="12%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell text-align="right">
                            <fo:block>
                                <xsl:if test="not(($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware'))">
                                    <fo:retrieve-marker retrieve-class-name="current-header"/>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell text-align="right" padding-right="{$page-margins}">
                            <fo:block>
                                <fo:inline xsl:use-attribute-sets="__body__odd__footer__pagenum">
                                    <fo:page-number/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template name="insertEvenFooter_common">
        <fo:block xsl:use-attribute-sets="footer.text">
            <fo:table>
                <fo:table-column column-number="1" column-width="12%"/>
                <fo:table-column column-number="2" column-width="88%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell text-align="left" padding-left="{$page-margins}">
                            <fo:block>
                                <fo:inline xsl:use-attribute-sets="__body__odd__footer__pagenum">
                                    <fo:page-number/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell text-align="left">
                            <fo:block>
                                <xsl:if test="not(($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware'))">
                                    <fo:retrieve-marker retrieve-class-name="current-header"/>
                                </xsl:if>
                            </fo:block>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>
</xsl:stylesheet>