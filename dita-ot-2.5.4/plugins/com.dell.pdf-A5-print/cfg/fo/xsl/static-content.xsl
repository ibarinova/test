<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

    <xsl:template name="insertIndexStaticContents">
        <xsl:call-template name="insertBodyOddFooter"/>
        <xsl:call-template name="insertBodyEvenFooter"/>
    </xsl:template>

    <xsl:template name="insertGlossaryStaticContents">
        <xsl:call-template name="insertBodyOddFooter"/>
        <xsl:call-template name="insertBodyEvenFooter"/>
    </xsl:template>

    <xsl:template name="insertBodyStaticContents">
        <xsl:call-template name="insertBodyFootnoteSeparator"/>
        <xsl:call-template name="insertBodyOddFooter"/>
        <xsl:call-template name="insertBodyEvenFooter"/>
    </xsl:template>

    <xsl:template name="insertTocStaticContents">
        <xsl:call-template name="insertTocOddFooter"/>
        <xsl:call-template name="insertTocEvenFooter"/>
    </xsl:template>

    <xsl:template name="insertBodyOddFooter">
        <fo:static-content flow-name="odd-body-footer">
            <xsl:call-template name="insertOddFooter_common"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyEvenFooter">
        <fo:static-content flow-name="even-body-footer">
            <xsl:call-template name="insertEvenFooter_common"/>
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

    <xsl:template name="insertFrontMatterStaticContents">
        <xsl:call-template name="insertFrontMatterFootnoteSeparator"/>
        <xsl:if test="$multilingual">
            <fo:static-content flow-name="front-matter-footer_multilingual">
                <fo:block-container xsl:use-attribute-sets="__frontmatter_footer_container">
                    <xsl:call-template name="createFrontCoverContents_footer-multilingual"/>
                </fo:block-container>
            </fo:static-content>
        </xsl:if>
    </xsl:template>

    <xsl:template name="insertOddFooter_common">
        <fo:block xsl:use-attribute-sets="footer__text_block">
            <fo:table>
                <xsl:choose>
                    <xsl:when test="$isManual and not($multilingual)">
                        <fo:table-column column-number="1" column-width="30%"/>
                        <fo:table-column column-number="2" column-width="55%"/>
                        <fo:table-column column-number="3" column-width="15%"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:table-column column-number="1" column-width="30%"/>
                        <fo:table-column column-number="2" column-width="70%"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fo:table-body>
                    <fo:table-row>
					<!--Removed footer logo idpl 13018-->
                        <fo:table-cell text-align="left">
                           <!-- <xsl:choose>
                                <xsl:when test="not($dell-brand = 'Non-brand')">
                                    <fo:block xsl:use-attribute-sets="footer_logo_container">
                                        <xsl:variable name="logo-path">
                                            <xsl:choose>
                                                <xsl:when test="$dell-brand = 'Dell EMC'">
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'DELL_EMC_Logo_Gray.svg')"/>
                                                </xsl:when>
												<xsl:when test="$dell-brand = 'Dell'">
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'Dell_Logo_DarkGray.svg')"/>
                                                </xsl:when>
																															<xsl:when test="$dell-brand = 'Alienware'">
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'Alienware_logo_Black.jpg')"/>
                                        </xsl:when>
										<xsl:when test="$dell-brand = 'Dell Technologies'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'DellTech_Logo_Gry.svg')"/>
                                        </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'DELL_EMC_Logo_Gray.svg')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>

                                        <xsl:variable name="height">
                                            <xsl:choose>
                                                <xsl:when test="$dell-brand = 'Dell EMC'">5mm</xsl:when>
                                                <xsl:otherwise>8mm</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <fo:external-graphic content-height="{$height}" src="url('{$logo-path}')"/>
                                    </fo:block>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:block/>
                                </xsl:otherwise>
                            </xsl:choose>-->
                        </fo:table-cell>
                        <xsl:if test="$isManual and not($multilingual)">
                            <fo:table-cell text-align="right">
                                <fo:block>
                                    <fo:inline>
                                        <fo:retrieve-marker retrieve-class-name="current-header"/>
                                    </fo:inline>
                                </fo:block>
                            </fo:table-cell>
                        </xsl:if>
                        <fo:table-cell text-align="right">
                            <fo:block xsl:use-attribute-sets="footer_pagenum_odd">
                                <fo:inline>
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
        <fo:block xsl:use-attribute-sets="footer__text_block">
            <fo:table>
                <xsl:choose>
                    <xsl:when test="$isManual and not($multilingual)">
                        <fo:table-column column-number="1" column-width="15%"/>
                        <fo:table-column column-number="2" column-width="55%"/>
                        <fo:table-column column-number="3" column-width="30%"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:table-column column-number="1" column-width="70%"/>
                        <fo:table-column column-number="2" column-width="30%"/>
                    </xsl:otherwise>
                </xsl:choose>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell text-align="left">
                            <fo:block xsl:use-attribute-sets="footer_pagenum_even">
                                <fo:inline>
                                    <fo:page-number/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                        <xsl:if test="$isManual and not($multilingual)">
                            <fo:table-cell text-align="left">
                                <fo:block>
                                    <fo:inline>
                                        <fo:retrieve-marker retrieve-class-name="current-header"/>
                                    </fo:inline>
                                </fo:block>
                            </fo:table-cell>
                        </xsl:if>
						<!--Removed footer logo IDPL13018-->
                        <fo:table-cell text-align="right">
                            <!--<xsl:choose>
                                <xsl:when test="not($dell-brand = 'Non-brand')">
                                    <fo:block xsl:use-attribute-sets="footer_logo_container">
                                        <xsl:variable name="logo-path">
                                            <xsl:choose>
                                                <xsl:when test="$dell-brand = 'Dell EMC'">
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'DELL_EMC_Logo_Gray.svg')"/>
                                                </xsl:when>
																															<xsl:when test="$dell-brand = 'Dell'">
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'Dell_Logo_DarkGray.svg')"/>
                                                </xsl:when>
												<xsl:when test="$dell-brand = 'Alienware'">
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'Alienware_logo_Black.jpg')"/>
                                                </xsl:when>
												<xsl:when test="$dell-brand = 'Dell Technologies'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'DellTech_Logo_Gry.svg')"/>
												</xsl:when>    
                                                <xsl:otherwise>
                                                    <xsl:value-of select="concat($artwork-logo-dir, 'DELL_EMC_Logo_Gray.svg')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>

                                        <xsl:variable name="height">
                                            <xsl:choose>
                                                <xsl:when test="$dell-brand = 'Dell EMC'">5mm</xsl:when>
                                                <xsl:otherwise>8mm</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <fo:external-graphic content-height="{$height}" src="url('{$logo-path}')"/>
                                    </fo:block>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:block/>
                                </xsl:otherwise>
                            </xsl:choose>-->
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>