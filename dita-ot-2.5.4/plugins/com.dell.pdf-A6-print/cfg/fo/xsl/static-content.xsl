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
                <fo:table-column column-number="1" column-width="70%"/>
                <fo:table-column column-number="2" column-width="30%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell text-align="right">
                            <fo:block/>
                        </fo:table-cell>
                        <fo:table-cell text-align="right">
                            <fo:block xsl:use-attribute-sets="footer_pagenum">
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
                <fo:table-column column-number="1" column-width="30%"/>
                <fo:table-column column-number="2" column-width="70%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell text-align="left">
                            <fo:block xsl:use-attribute-sets="footer_pagenum">
                                <fo:inline>
                                    <fo:page-number/>
                                </fo:inline>
                            </fo:block>
                        </fo:table-cell>
                        <fo:table-cell text-align="left">
                            <fo:block/>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>