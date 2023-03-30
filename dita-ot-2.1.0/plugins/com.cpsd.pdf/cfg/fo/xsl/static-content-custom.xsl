<?xml version='1.0'?>

<!--
Copyright © 2004-2006 by Idiom Technologies, Inc. All rights reserved.
IDIOM is a registered trademark of Idiom Technologies, Inc. and WORLDSERVER
and WORLDSTART are trademarks of Idiom Technologies, Inc. All other
trademarks are the property of their respective owners.

IDIOM TECHNOLOGIES, INC. IS DELIVERING THE SOFTWARE "AS IS," WITH
ABSOLUTELY NO WARRANTIES WHATSOEVER, WHETHER EXPRESS OR IMPLIED,  AND IDIOM
TECHNOLOGIES, INC. DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING
BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE AND WARRANTY OF NON-INFRINGEMENT. IDIOM TECHNOLOGIES, INC. SHALL NOT
BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, COVER, PUNITIVE, EXEMPLARY,
RELIANCE, OR CONSEQUENTIAL DAMAGES (INCLUDING BUT NOT LIMITED TO LOSS OF
ANTICIPATED PROFIT), ARISING FROM ANY CAUSE UNDER OR RELATED TO  OR ARISING
OUT OF THE USE OF OR INABILITY TO USE THE SOFTWARE, EVEN IF IDIOM
TECHNOLOGIES, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.

Idiom Technologies, Inc. and its licensors shall not be liable for any
damages suffered by any person as a result of using and/or modifying the
Software or its derivatives. In no event shall Idiom Technologies, Inc.'s
liability for any damages hereunder exceed the amounts received by Idiom
Technologies, Inc. as a result of this transaction.

These terms and conditions supersede the terms and conditions in any
licensing agreement to the extent that such terms and conditions conflict
with those set forth herein.

This file is part of the DITA Open Toolkit project hosted on Sourceforge.net.
See the accompanying license.txt file for applicable licenses.
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ss="http://www.suite-sol.com/functions"
                exclude-result-prefixes="ss"
                version="2.0">

    <!-- IA   Tridion upgrade    Jan-2019  IDPL-4691 - PDF footer only displays <booktitlealt>. Should display <mainbooktitle> + <booktitlealt>. - IB-->
    <xsl:variable name="mainbooktitle">
        <xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/mainbooktitle ')][1]"/>
    </xsl:variable>
    <xsl:variable name="booktitlealt">
        <xsl:apply-templates select="/descendant::*[contains(@class, ' bookmap/booktitlealt ')][1]"/>
    </xsl:variable>
    <xsl:variable name="vrm" select="/descendant::*[contains(@class, ' topic/vrm ')][1]/@version"/>
    <!-- Dimitri: Variable for the version prefix. -->
	<xsl:variable name="vrm_prefix">
		<xsl:choose>
			<xsl:when test="contains(/*/@outputclass, 'vrm_prefix_ver') or not(contains(/*/@outputclass, 'vrm_prefix_'))">Version</xsl:when>
			<xsl:when test="contains(/*/@outputclass, 'vrm_prefix_rel')">Release</xsl:when>
			<xsl:when test="contains(/*/@outputclass, 'vrm_prefix_rev')">Revision</xsl:when>
			<xsl:when test="contains(/*/@outputclass, 'vrm_prefix_none')"></xsl:when>
			<!--xsl:otherwise>Version</xsl:otherwise-->
		</xsl:choose>
	</xsl:variable>
    <xsl:variable name="shorttitle" select="/descendant::*[contains(@class, 'topic/othermeta')][@name = 'shorttitle'][last()]/@content"/>
    <!-- Dimitri: Revised the $full-title variable to include the version prefix. -->
    <!--xsl:variable name="full-title">
        <xsl:value-of select="$mainbooktitle"/>
        <xsl:if test="lower-case($NOCHAP) = 'yes' and normalize-space($vrm)">
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space($vrm)"/>
        </xsl:if>
        <xsl:if test="normalize-space($booktitlealt)">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$booktitlealt"/>
        </xsl:if>
    </xsl:variable-->
	<xsl:variable name="full-title">
		<xsl:value-of select="$mainbooktitle"/>
		<xsl:if test="$vrm!='0' and $vrm!='0.0' and $vrm!=''">
			<xsl:text> </xsl:text>
			<xsl:value-of select="$vrm_prefix"/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="normalize-space($vrm)"/>
		</xsl:if>
		<xsl:if test="normalize-space($booktitlealt)">
			<xsl:text> </xsl:text>
			<xsl:value-of select="$booktitlealt"/>
		</xsl:if>
	</xsl:variable>
    <xsl:variable name="footer-title">
        <xsl:choose>
            <xsl:when test="$SOLUTIONS = 'yes'">
                <!-- Intelliarts Consulting   SolutionsPDF    16-Mar-2017   Use <mainbooktitle> for Solutions PDF even page footer  - IB-->
                <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                    <fo:inline xsl:use-attribute-sets="__body__odd__footer__heading">
                        <xsl:value-of select="$mainbooktitle"/>
                    </fo:inline>
                </fo:block>
            </xsl:when>
            <xsl:when test="normalize-space($shorttitle)">
                <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                    <fo:inline xsl:use-attribute-sets="__body__odd__footer__heading">
                        <xsl:value-of select="normalize-space($shorttitle)"/>
                    </fo:inline>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <!-- IA   Tridion upgrade    Oct-2018   Use <booktitlealt> value in footer instead of <category> value or current topic header. - IB-->
                <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                    <fo:inline xsl:use-attribute-sets="__body__odd__footer__heading">
                        <xsl:value-of select="normalize-space($full-title)"/>
                    </fo:inline>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template name="insertFrontMatterStaticContents">
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertFrontMatterEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertFrontMatterOddHeader"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertFrontMatterEvenHeader"/>
        </xsl:if>
    </xsl:template>


    <!-- Suite Dec-2011: add call to insert landscape static contents - rs -->
    <xsl:template name="insertBodyStaticContents">
        <xsl:call-template name="insertBodyFootnoteSeparator"/>
        <xsl:call-template name="insertBodyOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertBodyEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertBodyOddHeader"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertBodyEvenHeader"/>
        </xsl:if>
        <xsl:call-template name="insertBodyFirstHeader"/>
        <xsl:call-template name="insertBodyFirstFooter"/>
        <xsl:call-template name="insertBodyLastHeader"/>
        <xsl:call-template name="insertBodyLastFooter"/>
        <xsl:call-template name="insertBodyLandscapeOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertBodyLandscapeEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertBodyLandscapeOddHeader"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertBodyLandscapeEvenHeader"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="insertPrefaceStaticContents">
        <xsl:call-template name="insertPrefaceOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertPrefaceEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertPrefaceOddHeader"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertPrefaceEvenHeader"/>
        </xsl:if>
        <xsl:call-template name="insertBodyFirstHeader"/>
        <xsl:call-template name="insertPrefaceFirstFooter"/>
    </xsl:template>

    <xsl:template name="insertTocStaticContents">
        <xsl:call-template name="insertTocOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertTocEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertTocFirstFooter"/>
        <xsl:call-template name="insertTocOddHeader"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertTocEvenHeader"/>
        </xsl:if>
        <xsl:call-template name="insertTocFirstHeader"/>
    </xsl:template>

    <xsl:template name="insertGlossaryStaticContents">
        <xsl:call-template name="insertGlossaryOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertGlossaryEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertGlossaryOddHeader"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertGlossaryEvenHeader"/>
        </xsl:if>
        <xsl:call-template name="insertBodyFirstHeader"/>
    </xsl:template>

    <xsl:template name="insertIndexStaticContents">
        <xsl:call-template name="insertIndexOddFooter"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertIndexEvenFooter"/>
        </xsl:if>
        <xsl:call-template name="insertIndexFirstFooter"/>
        <xsl:call-template name="insertIndexOddHeader"/>
        <xsl:if test="$mirror-page-margins">
            <xsl:call-template name="insertIndexEvenHeader"/>
        </xsl:if>
        <xsl:call-template name="insertBodyFirstHeader"/>
    </xsl:template>

    <!-- Suite Dec-2011: add frontmatter headers -->
    <xsl:template name="insertFrontMatterOddHeader">
        <fo:static-content flow-name="odd-frontmatter-header">
            <xsl:call-template name="insertDraftHeading"/>
            <xsl:call-template name="insertBetaHeading"/>
            <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
            <xsl:call-template name="insertConfidentialOddHeading"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertFrontMatterEvenHeader">
        <fo:static-content flow-name="even-frontmatter-header">
            <xsl:call-template name="insertDraftHeading"/>
            <!-- Suite/EMC Nochap  13-Aug-2012  Add beta parameter based on value of outputformat - AW-->
            <xsl:call-template name="insertBetaHeading"/>
            <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
            <xsl:call-template name="insertConfidentialEvenHeading"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertFrontMatterEvenFooter">
        <fo:static-content flow-name="even-frontmatter-footer">
            <xsl:call-template name="insertBodyEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyOddHeader">
        <fo:static-content flow-name="odd-body-header">
            <xsl:call-template name="insertBodyOddHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyEvenHeader">
        <fo:static-content flow-name="even-body-header">
            <xsl:call-template name="insertBodyEvenHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyOddFooter">
        <fo:static-content flow-name="odd-body-footer">
            <xsl:call-template name="insertBodyOddFooterContent"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyEvenFooter">
        <fo:static-content flow-name="even-body-footer">
            <xsl:call-template name="insertBodyEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyFirstHeader">
        <fo:static-content flow-name="first-body-header">
            <xsl:call-template name="insertDraftHeading"/>
            <xsl:call-template name="insertBetaHeading"/>
            <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
            <xsl:call-template name="insertConfidentialOddHeading"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyFirstFooter">
        <fo:static-content flow-name="first-body-footer">
            <xsl:call-template name="insertBodyFirstFooterContent"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLastHeader">
        <fo:static-content flow-name="last-body-header">
            <fo:block xsl:use-attribute-sets="__body__last__header">
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLastFooter">
        <fo:static-content flow-name="last-body-footer">
            <fo:block xsl:use-attribute-sets="__body__last__footer">
            </fo:block>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocOddFooter">
        <fo:static-content flow-name="odd-toc-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocEvenFooter">
        <fo:static-content flow-name="even-toc-footer">
            <xsl:call-template name="insertBodyEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocFirstFooter">
        <fo:static-content flow-name="first-toc-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocOddHeader">
        <fo:static-content flow-name="odd-toc-header">
            <xsl:call-template name="insertBodyOddHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertTocEvenHeader">
        <fo:static-content flow-name="even-toc-header">
            <xsl:call-template name="insertBodyEvenHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <!-- Suite/EMC   SOW5  07-Feb-2012   Add first toc header START - ck -->
    <xsl:template name="insertTocFirstHeader">
        <fo:static-content flow-name="first-toc-header">
            <xsl:choose>
                <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Add using of RSA BRAND value from BRAND list instead of @outputclass with 'rsa' value - IB-->
                <xsl:when test="$BRAND-IS-RSA">
                    <fo:block xsl:use-attribute-sets="__toc__header__rsa">
                        <fo:retrieve-marker retrieve-class-name="current-header"/>
                    </fo:block>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block xsl:use-attribute-sets="__toc__header">
                        <fo:retrieve-marker retrieve-class-name="current-header"/>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="insertDraftHeading"/>
            <xsl:call-template name="insertBetaHeading"/>
            <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
            <xsl:call-template name="insertConfidentialOddHeading"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceOddHeader">
        <fo:static-content flow-name="odd-body-header">
            <xsl:call-template name="insertBodyOddHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceEvenHeader">
        <fo:static-content flow-name="even-body-header">
            <xsl:call-template name="insertBodyEvenHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceFirstFooter">
        <fo:static-content flow-name="first-body-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceOddFooter">
        <fo:static-content flow-name="odd-body-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertPrefaceEvenFooter">
        <fo:static-content flow-name="even-body-footer">
            <xsl:call-template name="insertBodyEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyOddFooterContent">
        <!-- Suite/EMC   SOW5  07-Feb-2012   Update footer layout - ck -->
        <fo:block-container height="100%" display-align="before">
            <fo:block xsl:use-attribute-sets="__body__odd__footer">
                <fo:table xsl:use-attribute-sets="__body__footer.table">
                    <!-- Dimitri: Increase footer width. -->
                    <!--fo:table-column column-width="6.5in"></fo:table-column-->
                    <fo:table-column column-width="6.75in"></fo:table-column>
                    <fo:table-column column-width="0.5in"></fo:table-column>
                    <fo:table-body start-indent="0pt" end-indent="0pt">
                        <fo:table-row>
                            <fo:table-cell text-align="right">
                                <xsl:copy-of select="$footer-title"/>
                            </fo:table-cell>
                            <fo:table-cell text-align="right">
                                <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                                    <fo:inline xsl:use-attribute-sets="__body__odd__footer__pagenum">
                                        <fo:page-number/>
                                    </fo:inline>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:block-container>
        <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property.
                                            Add specific watermark at the footer   - IB-->
        <xsl:call-template name="insert-dellrestricted-footer-container_odd"/>
    </xsl:template>

    <xsl:template name="insertBodyEvenFooterContent">
        <fo:block-container height="100%" display-align="before">
            <fo:block xsl:use-attribute-sets="__body__even__footer">
                <fo:table xsl:use-attribute-sets="__body__footer.table">
                    <fo:table-column column-width="0.5in"></fo:table-column>
                    <!-- Dimitri: Increase footer width. -->
                    <!--fo:table-column column-width="6.5in"></fo:table-column-->
                    <fo:table-column column-width="6.75in"></fo:table-column>
                    <fo:table-body start-indent="0pt">
                        <fo:table-row>
                            <fo:table-cell text-align="left">
                                <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                                    <fo:inline xsl:use-attribute-sets="__body__even__footer__pagenum">
                                        <fo:page-number/>
                                    </fo:inline>
                                </fo:block>
                            </fo:table-cell>
                            <fo:table-cell text-align="left">
                                <xsl:copy-of select="$footer-title"/>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:block-container>
        <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property.
                                       Add specific watermark at the footer   - IB-->
        <xsl:call-template name="insert-dellrestricted-footer-container_even"/>
    </xsl:template>

    <xsl:template name="insertBodyOddHeaderContent">
        <fo:block xsl:use-attribute-sets="__body__odd__header">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Body odd header'"/>
                <xsl:with-param name="params" as="element()*">
                    <heading>
                        <fo:inline xsl:use-attribute-sets="__body__odd__header__heading">
                            <fo:retrieve-marker retrieve-class-name="current-header"/>
                        </fo:inline>
                    </heading>
                </xsl:with-param>
            </xsl:call-template>
        </fo:block>
        <!-- Suite Dec-2011: add draft heading when relevant -->
        <xsl:call-template name="insertDraftHeading"/>
        <xsl:call-template name="insertBetaHeading"/>
        <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
        <xsl:call-template name="insertConfidentialOddHeading"/>
    </xsl:template>

    <xsl:template name="insertBodyEvenHeaderContent">
        <fo:block xsl:use-attribute-sets="__body__even__header">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'Body even header'"/>
                <xsl:with-param name="params" as="element()*">
                    <prodname>
                        <xsl:value-of select="$productName"/>
                    </prodname>
                    <!-- EMC	 IB3	15-Nov-2013   Nochap PDF header should display category not current-header -->
                    <heading>
                        <fo:inline xsl:use-attribute-sets="__body__even__header__heading">
                            <xsl:choose>
                                <xsl:when test="$NOCHAP = 'no'">
                                    <fo:retrieve-marker retrieve-class-name="current-header"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of
                                            select="ss:stripSymbols(//*[contains(@class, ' topic/category ')][1])"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:inline>
                    </heading>
                </xsl:with-param>
            </xsl:call-template>
        </fo:block>
        <!-- Suite Dec-2011: add draft heading when relevant -->
        <xsl:call-template name="insertDraftHeading"/>
        <xsl:call-template name="insertBetaHeading"/>
        <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
        <xsl:call-template name="insertConfidentialEvenHeading"/>
    </xsl:template>

    <xsl:template name="insertBodyFirstFooterContent">
        <!-- Suite/EMC   SOW5  07-Feb-2012   Update footer layout - ck -->
        <fo:block-container height="100%" display-align="before">
            <fo:block xsl:use-attribute-sets="__body__odd__footer">
                <fo:table xsl:use-attribute-sets="__body__footer.table">
                    <fo:table-column column-width="6.5in"></fo:table-column>
                    <fo:table-column column-width="0.5in"></fo:table-column>
                    <fo:table-body start-indent="0pt" end-indent="0pt">
                        <fo:table-row>
                            <fo:table-cell text-align="right">
                                <xsl:copy-of select="$footer-title"/>
                            </fo:table-cell>
                            <fo:table-cell text-align="right">
                                <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                                    <fo:inline xsl:use-attribute-sets="__body__odd__footer__pagenum">
                                        <fo:page-number/>
                                    </fo:inline>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:block-container>
        <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property.
                                        Add specific watermark at the footer   - IB-->
        <xsl:call-template name="insert-dellrestricted-footer-container_odd"/>
    </xsl:template>

    <xsl:template name="insertBodyLandscapeOddFooter">
        <fo:static-content flow-name="odd-body-landscape-footer">
            <!-- Suite/EMC   SOW5  07-Feb-2012   Update footer layout - ck -->
            <fo:block-container reference-orientation="270" height="100%" display-align="before">
                <fo:block xsl:use-attribute-sets="__body__odd__footer">
                    <fo:table xsl:use-attribute-sets="__body__footer.table">
                        <fo:table-column column-width="6.5in"></fo:table-column>
                        <fo:table-column column-width="0.5in"></fo:table-column>
                        <fo:table-body start-indent="0pt" end-indent="0pt">
                            <fo:table-row>
                                <fo:table-cell text-align="right">
                                    <xsl:copy-of select="$footer-title"/>
                                </fo:table-cell>
                                <fo:table-cell text-align="right">
                                    <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                                        <fo:inline xsl:use-attribute-sets="__body__odd__footer__pagenum">
                                            <fo:page-number/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:block>
            </fo:block-container>
            <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property.
                                            Add specific watermark at the footer   - IB-->
            <xsl:call-template name="insert-dellrestricted-footer-container_odd"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLandscapeEvenFooter">
        <fo:static-content flow-name="even-body-landscape-footer">
            <fo:block-container reference-orientation="270" height="100%" display-align="before">
                <fo:block xsl:use-attribute-sets="__body__even__footer">
                    <fo:table xsl:use-attribute-sets="__body__footer.table">
                        <fo:table-column column-width="0.5in"></fo:table-column>
                        <fo:table-column column-width="6.5in"></fo:table-column>
                        <fo:table-body start-indent="0pt">
                            <fo:table-row>
                                <fo:table-cell text-align="left">
                                    <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                                        <fo:inline xsl:use-attribute-sets="__body__even__footer__pagenum">
                                            <fo:page-number/>
                                        </fo:inline>
                                    </fo:block>
                                </fo:table-cell>
                                <fo:table-cell text-align="left">
                                    <xsl:copy-of select="$footer-title"/>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-body>
                    </fo:table>
                </fo:block>
            </fo:block-container>
            <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property.
                                         Add specific watermark at the footer   - IB-->
            <xsl:call-template name="insert-dellrestricted-footer-container_even"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLandscapeOddHeader">
        <fo:static-content flow-name="odd-body-landscape-header">
            <fo:block-container reference-orientation="270" width="{$page-width}">
                <fo:block xsl:use-attribute-sets="__body__odd__header">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Body odd header'"/>
                        <xsl:with-param name="params" as="element()*">
                            <heading>
                                <fo:inline xsl:use-attribute-sets="__body__odd__header__heading">
                                    <fo:retrieve-marker retrieve-class-name="current-header"/>
                                </fo:inline>
                            </heading>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:block>
            </fo:block-container>
            <xsl:call-template name="insertDraftHeading">
                <xsl:with-param name="landscape">yes</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="insertBetaHeading">
                <xsl:with-param name="landscape">yes</xsl:with-param>
            </xsl:call-template>
            <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
            <xsl:call-template name="insertConfidentialOddHeading">
                <xsl:with-param name="landscape">yes</xsl:with-param>
            </xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertBodyLandscapeEvenHeader">
        <fo:static-content flow-name="even-body-landscape-header">
            <fo:block-container reference-orientation="270">
                <fo:block xsl:use-attribute-sets="__body__even__header">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Body even header'"/>
                        <xsl:with-param name="params" as="element()*">
                            <prodname>
                                <xsl:value-of select="$productName"/>
                            </prodname>
                            <heading>
                                <fo:inline xsl:use-attribute-sets="__body__even__header__heading">
                                    <fo:retrieve-marker retrieve-class-name="current-header"/>
                                </fo:inline>
                            </heading>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:block>
            </fo:block-container>
            <xsl:call-template name="insertDraftHeading">
                <xsl:with-param name="landscape">yes</xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="insertBetaHeading">
                <xsl:with-param name="landscape">yes</xsl:with-param>
            </xsl:call-template>
            <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
            <xsl:call-template name="insertConfidentialEvenHeading">
                <xsl:with-param name="landscape">yes</xsl:with-param>
            </xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryOddHeader">
        <fo:static-content flow-name="odd-glossary-header">
            <xsl:call-template name="insertBodyOddHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryEvenHeader">
        <fo:static-content flow-name="even-glossary-header">
            <xsl:call-template name="insertBodyEvenHeaderContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryOddFooter">
        <fo:static-content flow-name="odd-glossary-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryEvenFooter">
        <fo:static-content flow-name="even-glossary-footer">
            <xsl:call-template name="insertBodyEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertGlossaryFirstFooter">
        <fo:static-content flow-name="first-glossary-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertIndexOddFooter">
        <fo:static-content flow-name="odd-index-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertIndexEvenFooter">
        <fo:static-content flow-name="even-index-footer">
            <xsl:call-template name="insertBodyEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertIndexFirstFooter">
        <fo:static-content flow-name="first-index-footer">
            <xsl:call-template name="insertOddLikeEvenFooterContent"></xsl:call-template>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertIndexOddHeader">
        <fo:static-content flow-name="odd-index-header">
            <fo:block xsl:use-attribute-sets="__body__odd__header">
                <fo:inline xsl:use-attribute-sets="__body__odd__header__heading">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Index'"/>
                    </xsl:call-template>
                </fo:inline>
            </fo:block>
            <!-- Suite Dec-2011: add draft heading when relevant -->
            <xsl:call-template name="insertDraftHeading"/>
            <xsl:call-template name="insertBetaHeading"/>
            <!-- Suite/EMC   SOW5  07-Feb-2012   confidential heading - ck -->
            <xsl:call-template name="insertConfidentialOddHeading"/>
        </fo:static-content>
    </xsl:template>

    <xsl:template name="insertIndexEvenHeader">
        <fo:static-content flow-name="even-index-header">
            <fo:block xsl:use-attribute-sets="__body__even__header">
                <fo:inline xsl:use-attribute-sets="__body__even__header__heading">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Index'"/>
                    </xsl:call-template>
                </fo:inline>
            </fo:block>
            <!-- Suite Dec-2011: add draft heading when relevant -->
            <xsl:call-template name="insertDraftHeading"/>
            <xsl:call-template name="insertBetaHeading"/>
            <!-- Suite/EMC   SOW5  07-Feb-2012   EMC/RSA confidential heading - ck -->
            <xsl:call-template name="insertConfidentialEvenHeading"/>
        </fo:static-content>
    </xsl:template>

    <!--The following template is used for odd (but not first) pages in toc, preface, glossary, index-->
    <xsl:template name="insertOddLikeEvenFooterContent">
        <fo:block-container height="100%" display-align="before">
            <fo:block xsl:use-attribute-sets="__body__odd__footer">
                <fo:table xsl:use-attribute-sets="__body__footer.table">
					<!-- Dimitri: Increase TOC, Figures, Tables footer width. -->
                    <!--fo:table-column column-width="6.5in"></fo:table-column-->
                    <fo:table-column column-width="6.75in"></fo:table-column>
                    <!--<fo:table-column column-width="0.247in"></fo:table-column>-->
                    <fo:table-column column-width="0.5in"></fo:table-column>
                    <fo:table-body start-indent="0pt" end-indent="0pt">
                        <fo:table-row>
                            <fo:table-cell text-align="right">
                                <xsl:copy-of select="$footer-title"/>
                            </fo:table-cell>
                            <fo:table-cell text-align="right">
                                <fo:block xsl:use-attribute-sets="__body__footer.table.block">
                                    <fo:inline xsl:use-attribute-sets="__body__odd__footer__pagenum">
                                        <fo:page-number/>
                                    </fo:inline>
                                </fo:block>
                            </fo:table-cell>
                        </fo:table-row>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </fo:block-container>
        <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property.
                                          Add specific watermark at the footer   - IB-->
        <xsl:call-template name="insert-dellrestricted-footer-container_odd"/>
    </xsl:template>

    <!-- Suite Dec-2011: Insert draft heading when relevant -->
    <xsl:template name="insertDraftHeading">
        <xsl:param name="landscape">no</xsl:param>
        <xsl:if test="$DRAFT-PDF = 'yes'">
            <fo:block-container position="absolute">
                <xsl:attribute name="reference-orientation">
                    <xsl:choose>
                        <xsl:when test="$landscape = 'yes'">270</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="display-align">before</xsl:attribute>
                <fo:block xsl:use-attribute-sets="__body__draft__header">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'draft'"/>
                    </xsl:call-template>
                </fo:block>
            </fo:block-container>
        </xsl:if>
    </xsl:template>

    <!-- Suite/EMC Nochap  13-Aug-2012  Add beta parameter based on value of outputformat - AW-->
    <xsl:template name="insertBetaHeading">
        <xsl:param name="landscape">no</xsl:param>
        <xsl:if test="$BETA = 'yes'">
            <fo:block-container position="absolute">
                <xsl:attribute name="reference-orientation">
                    <xsl:choose>
                        <xsl:when test="$landscape = 'yes'">270</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="display-align">before</xsl:attribute>
                <fo:block xsl:use-attribute-sets="__body__draft__header">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'beta'"/>
                    </xsl:call-template>
                </fo:block>
            </fo:block-container>
        </xsl:if>
    </xsl:template>

    <!-- Suite/EMC   SOW5  07-Feb-2012   EMC/RSA confidential for odd headers - ck -->
    <xsl:template name="insertConfidentialOddHeading">
        <xsl:param name="landscape">no</xsl:param>
        <xsl:variable name="confidentialString">
            <xsl:choose>
                <xsl:when test=" //bookmap[contains(@outputclass,'confidential')]">
                    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Code refactoring. Move duplicated code to named template - IB-->
                    <xsl:call-template name="insertConfidentialVariable"/>
                </xsl:when>
                <xsl:when test="$DRAFT-PDF = 'yes'">
                    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Code refactoring. Move duplicated code to named template - IB-->
                    <xsl:call-template name="insertConfidentialVariable"/>
                </xsl:when>
                <xsl:when test="$BETA = 'yes'">
                    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Code refactoring. Move duplicated code to named template - IB-->
                    <xsl:call-template name="insertConfidentialVariable"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <fo:block-container position="absolute">
            <xsl:attribute name="reference-orientation">
                <xsl:choose>
                    <xsl:when test="$landscape = 'yes'">270</xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- Natasha IB2 8-Jul-21013 Special formatting for EMC Confidential string for RU -->
            <xsl:choose>
                <xsl:when test=" //bookmap[contains(lower-case(@xml:lang),'ru')]">
                    <fo:block xsl:use-attribute-sets="__body__confidential__header_RU_odd">
                        <xsl:value-of select="$confidentialString"/>
                    </fo:block>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block xsl:use-attribute-sets="__body__confidential__header_odd">
                        <xsl:value-of select="$confidentialString"/>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block-container>
    </xsl:template>

    <!-- Suite/EMC   SOW5  07-Feb-2012   EMC/RSA confidential for even headers START - ck -->
    <xsl:template name="insertConfidentialEvenHeading">
        <xsl:param name="landscape">no</xsl:param>
        <xsl:variable name="confidentialString">
            <xsl:choose>
                <xsl:when test=" //bookmap[contains(@outputclass,'confidential')]">
                    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Code refactoring. Move duplicated code to named template - IB-->
                    <xsl:call-template name="insertConfidentialVariable"/>
                </xsl:when>
                <xsl:when test="$DRAFT-PDF = 'yes'">
                    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Code refactoring. Move duplicated code to named template - IB-->
                    <xsl:call-template name="insertConfidentialVariable"/>
                </xsl:when>
                <xsl:when test="$BETA = 'yes'">
                    <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Code refactoring. Move duplicated code to named template - IB-->
                    <xsl:call-template name="insertConfidentialVariable"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>
        <fo:block-container position="absolute">
            <xsl:attribute name="reference-orientation">
                <xsl:choose>
                    <xsl:when test="$landscape = 'yes'">270</xsl:when>
                    <xsl:otherwise>0</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <!-- Natasha IB2 8-Jul-21013 Special formatting for EMC Confidential string for RU -->
            <xsl:choose>
                <xsl:when test=" //bookmap[contains(lower-case(@xml:lang),'ru')]">
                    <fo:block xsl:use-attribute-sets="__body__confidential__header_RU_even">
                        <xsl:value-of select="$confidentialString"/>
                    </fo:block>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block xsl:use-attribute-sets="__body__confidential__header_even">
                        <xsl:value-of select="$confidentialString"/>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="insertConfidentialVariable">
        <xsl:choose>
            <xsl:when test="$BRAND-IS-RSA">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'RSA Confidential'"/>
                </xsl:call-template>
            </xsl:when>
            <!-- IA   Tridion upgrade    Oct-2018   Remove using of 'EMC' brand. Use instead DellEMC - IB-->
            <!--
                        <xsl:when test= "$BRAND-IS-EMC">
                          <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'EMC Confidential'"/>
                          </xsl:call-template>
                        </xsl:when>
                  -->
            <xsl:otherwise>
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'DELL EMC Confidential'"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Suite/EMC   Nochap 15-Aug-2012  insert backmatter footer for  for nochap  - START - AW -->
    <xsl:template name="backmatterStaticContent">
        <fo:static-content flow-name="back-matter-last-footer">
        </fo:static-content>
    </xsl:template>

    <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property STARTS HERE. - IB-->
    <xsl:template name="insert-dellrestricted-footer-container_odd">
        <xsl:choose>
            <xsl:when test="$DECR">
                <fo:block-container xsl:use-attribute-sets="footer__dellrestricted_container_odd">
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_watermark">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential Restricted footer watermark'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential Restricted footer watermark'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_description">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential Restricted footer desc'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential Restricted footer desc'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
            <xsl:when test="$DEC">
                <fo:block-container xsl:use-attribute-sets="footer__dellrestricted_container_odd">
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_watermark">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_description">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential footer desc'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential footer desc'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
            <xsl:when test="$DEI">
                <fo:block-container xsl:use-attribute-sets="footer__dellrestricted_container_odd">
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_watermark">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_description">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Internal footer desc'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Internal footer desc'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="insert-dellrestricted-footer-container_even">
        <xsl:choose>
            <xsl:when test="$DECR">
                <fo:block-container xsl:use-attribute-sets="footer__dellrestricted_container_even">
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_watermark">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential Restricted footer watermark'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential Restricted footer watermark'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_description">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential Restricted footer desc'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential Restricted footer desc'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
            <xsl:when test="$DEC">
                <fo:block-container xsl:use-attribute-sets="footer__dellrestricted_container_even">
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_watermark">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_description">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential footer desc'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential footer desc'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
            <xsl:when test="$DEI">
                <fo:block-container xsl:use-attribute-sets="footer__dellrestricted_container_even">
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_watermark">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Confidential footer watermark'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                    <fo:block xsl:use-attribute-sets="footer__dellrestricted_description">
                        <xsl:choose>
                            <xsl:when test="$BRAND-IS-RSA">
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell RSA Internal footer desc'"/>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="insertVariable">
                                    <xsl:with-param name="theVariableID" select="'Dell EMC Internal footer desc'"/>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:block>
                </fo:block-container>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property ENDS HERE. - IB-->

    <!-- Suite/EMC   SOW7    31-Dec-2012   Add function to hide copyright/trademarks from header and footer - rs -->
    <xsl:function name="ss:stripSymbols">
        <xsl:param name="text"/>
        <xsl:variable name="temp1">
            <xsl:value-of select="translate($text[1],'&#x2122;&#x00AE;&#x2120;&#x00A9;','')"/>
        </xsl:variable>
        <xsl:value-of select="normalize-space($temp1)"/>
    </xsl:function>

</xsl:stylesheet>