<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:template name="createFrontMatter">
        <xsl:if test="$generate-front-cover">
            <fo:page-sequence master-reference="front-matter" xsl:use-attribute-sets="page-sequence.cover">
                <xsl:call-template name="insertFrontMatterStaticContents"/>
                <xsl:choose>
                    <xsl:when test="$multilingual">
                        <fo:flow flow-name="xsl-region-body">
                            <fo:block-container xsl:use-attribute-sets="__frontmatter" id="{$id.cover}">
                                <xsl:call-template name="createFrontCoverContents-multilingual"/>
                            </fo:block-container>
                        </fo:flow>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:flow flow-name="xsl-region-body">
                            <fo:block-container xsl:use-attribute-sets="__frontmatter" id="{$id.cover}">
                                <xsl:call-template name="createFrontCoverContents"/>
                            </fo:block-container>
                            <fo:block-container xsl:use-attribute-sets="__frontmatter_footer_container">
                                <xsl:call-template name="createFrontCoverContents_footer"/>
                            </fo:block-container>
                        </fo:flow>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <xsl:template name="createFrontCoverContents-multilingual">
        <!-- set the title -->
        <fo:block xsl:use-attribute-sets="__frontmatter__title-multilingual">
            <xsl:choose>
                <xsl:when test="$firstPublicationDitamap-map/*[contains(@class,' topic/title ')][1]">
                    <xsl:apply-templates select="$firstPublicationDitamap-map/*[contains(@class,' topic/title ')][1]"/>
                </xsl:when>
                <xsl:when test="$firstPublicationDitamap-map//*[contains(@class,' bookmap/mainbooktitle ')][1]">
                    <xsl:apply-templates select="$firstPublicationDitamap-map//*[contains(@class,' bookmap/mainbooktitle ')][1]"/>
                </xsl:when>
                <xsl:when test="$firstPublicationDitamap-map/@title">
                    <xsl:value-of select="$firstPublicationDitamap-map/@title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="/descendant::*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
        <!-- set the subtitle -->
        <xsl:apply-templates select="$firstPublicationDitamap-map/descendant::*[contains(@class, ' bookmap/booktitle ')][1]/descendant::*[contains(@class,' bookmap/booktitlealt ')]"/>

        <xsl:for-each select="$all-merged-ditamaps[preceding::*[contains(@class, ' map/topicref ')][normalize-space(@href)][@format = 'ditamap']]">
            <xsl:variable name="current-uri" select="concat($temp-dir-location, @href)"/>
            <xsl:variable name="current-doc" select="document($current-uri)"/>
            <xsl:apply-templates select="$current-doc/descendant::*[contains(@class, ' bookmap/booktitle ')][1]/descendant::*[contains(@class,' bookmap/booktitlealt ')]" mode="multilingual"/>
        </xsl:for-each>

    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/booktitlealt ')]" priority="2" mode="multilingual">
        <xsl:variable name="current-locale" select="lower-case(ancestor-or-self::*[normalize-space(@xml:lang)][1]/@xml:lang)"/>
        <fo:block xsl:use-attribute-sets="__frontmatter__subtitle-multilingual" xml:lang="{$current-locale}">
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template name="createFrontMatterMultilingualInside-manual">
        <xsl:variable name="current-topicref" select="key('map-id', @id)"/>
        <fo:page-sequence master-reference="front-matter" xsl:use-attribute-sets="page-sequence.cover-manual">
            <xsl:call-template name="insertFrontMatterStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:block-container xsl:use-attribute-sets="__frontmatter">
                    <xsl:call-template name="processFrontmatterMultilingualInside-manual"/>
                </fo:block-container>
                <fo:block-container xsl:use-attribute-sets="__frontmatter_footer_container">
                    <xsl:call-template name="createFrontCoverContents_footer-multilingual"/>
                </fo:block-container>
            </fo:flow>
        </fo:page-sequence>
        <xsl:for-each select="$current-topicref/descendant::*[contains(@class, ' bookmap/notices ')][1]">
            <xsl:call-template name="processTopicNotices"/>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="processFrontmatterMultilingualInside-manual">
        <xsl:variable name="current-lang" select="ancestor-or-self::*[normalize-space(@xml:lang)][1]/@xml:lang"/>
        <xsl:variable name="current-bookmap-uri" select="concat($temp-dir-location, $current-lang, '/', $export-start-document, '.ditamap')"/>
        <xsl:variable name="current-bookmap-doc" select="document($current-bookmap-uri)"/>
        <fo:wrapper id="{@id}"/>
        <fo:wrapper>
            <xsl:attribute name="id">
                <xsl:call-template name="generate-toc-id">
                    <xsl:with-param name="element" select="."/>
                </xsl:call-template>
            </xsl:attribute>
        </fo:wrapper>
        <xsl:variable name="current-locale" select="lower-case(ancestor-or-self::*[normalize-space(@xml:lang)][1]/@xml:lang)"/>
        <xsl:variable name="current-writing-mode" as="xs:string">
            <xsl:variable name="lang" select="if (contains($current-locale, '_')) then substring-before($current-locale, '_') else $current-locale"/>
            <xsl:choose>
                <xsl:when test="some $l in ('ar', 'ar-sa', 'fa', 'he', 'ps', 'ur') satisfies $l eq $lang">rl</xsl:when>
                <xsl:otherwise>lr</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fo:block-container writing-mode="{$current-writing-mode}" xml:lang="{$current-locale}">
            <fo:block xsl:use-attribute-sets="__frontmatter__title-multilingual">
                <xsl:choose>
                    <xsl:when test="$current-bookmap-doc/descendant::*[contains(@class,' bookmap/mainbooktitle ')][1]">
                        <xsl:apply-templates
                                select="$current-bookmap-doc/descendant::*[contains(@class,' bookmap/mainbooktitle ')][1]"/>
                    </xsl:when>
                    <xsl:when test="$current-bookmap-doc/@title">
                        <xsl:value-of select="$current-bookmap-doc/@title"/>
                    </xsl:when>
                </xsl:choose>
            </fo:block>
            <xsl:apply-templates select="$current-bookmap-doc/descendant::*[contains(@class, ' bookmap/booktitle ')][1]/descendant::*[contains(@class,' bookmap/booktitlealt ')]"/>
        </fo:block-container>
    </xsl:template>

    <xsl:template name="createFrontCoverContents_footer-multilingual">
        <fo:block xsl:use-attribute-sets="__frontmatter_footer-multilingual">
            <fo:table xsl:use-attribute-sets="__frontmatter_footer_table">
                <fo:table-column column-width="65%"/>
                <fo:table-column column-width="35%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="__frontmatter_footer_content">
                            <xsl:if test="not($isManual)">
                                <xsl:variable name="notice-topic" select="/descendant::*[contains(@class, ' topic/topic ')][contains(@outputclass, 'notice')]"/>
                                <xsl:if test="exists($notice-topic)">
                                    <xsl:apply-templates select="$notice-topic[1]/*[contains(@class, ' topic/body ')]"/>
                                </xsl:if>
                                <fo:block xsl:use-attribute-sets="common.block">
                                    <fo:table>
                                        <fo:table-column column-width="30%"/>
                                        <fo:table-column column-width="30%"/>
                                        <fo:table-column column-width="30%"/>
                                        <fo:table-body>
                                            <fo:table-row>
                                                <xsl:if test="normalize-space($release.date)">
                                                    <fo:table-cell>
                                                        <fo:block>
                                                            <xsl:value-of select="$release.date"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                </xsl:if>
                                                <xsl:if test="normalize-space($book.partnumber)">
                                                    <fo:table-cell>
                                                        <fo:block>
                                                            <xsl:call-template name="getVariable">
                                                                <xsl:with-param name="id" select="'part number'"/>
                                                            </xsl:call-template>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$book.partnumber"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                </xsl:if>
                                                <xsl:if test="normalize-space($book.revision)">
                                                    <fo:table-cell>
                                                        <fo:block>
                                                            <xsl:call-template name="getVariable">
                                                                <xsl:with-param name="id" select="'Technote Document Rev'"/>
                                                            </xsl:call-template>
                                                            <xsl:text> </xsl:text>
                                                            <xsl:value-of select="$book.revision"/>
                                                        </fo:block>
                                                    </fo:table-cell>
                                                </xsl:if>
                                            </fo:table-row>
                                        </fo:table-body>
                                    </fo:table>
                                </fo:block>
                            </xsl:if>
                        </fo:table-cell>
                        <fo:table-cell>
                            <xsl:if test="not($dell-brand = 'Non-brand')">
                                <fo:block xsl:use-attribute-sets="__frontmatter_footer_logo" text-align="right">
                                    <xsl:variable name="logo-path">
                                        <xsl:choose>
                                            <xsl:when test="$dell-brand = 'Dell EMC'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'DELL_EMC_Logo_Gray.svg')"/>
                                            </xsl:when>
											<xsl:when test="$dell-brand = 'Alienware'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'Alienware_logo_Black.jpg')"/>
                                            </xsl:when>
											<xsl:when test="$dell-brand = 'Dell'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'Dell_Logo_DarkGray.svg')"/>
                                            </xsl:when>
											<xsl:when test="$dell-brand = 'Dell Technologies'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'DellTech_Logo_Gry.svg')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="concat($artwork-logo-dir, 'DELL_EMC_Logo_Gray.svg')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
																														<fo:external-graphic src="url('{$logo-path}')">
										<xsl:if test="$dell-brand = 'Dell Technologies'">
                                            <xsl:attribute name="content-width">1.717in</xsl:attribute>
                                        </xsl:if>
									</fo:external-graphic>
                                </fo:block>
                            </xsl:if>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template name="createFrontCoverContents_footer">
        <fo:block xsl:use-attribute-sets="__frontmatter_footer">
            <fo:table xsl:use-attribute-sets="__frontmatter_footer_table">
                <fo:table-column column-width="60%"/>
                <fo:table-column column-width="40%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="__frontmatter_footer_content">
                            <xsl:if test="normalize-space($computer.model)">
                                <fo:block>
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Computer Model'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$computer.model"/>
                                </fo:block>
                            </xsl:if>
                            <xsl:if test="normalize-space($model.number)">
                                <fo:block>
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Regulatory Model'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$model.number"/>
                                </fo:block>
                            </xsl:if>
                            <xsl:if test="normalize-space($type.number)">
                                <fo:block>
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Regulatory Type'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$type.number"/>
                                </fo:block>
                            </xsl:if>
                        </fo:table-cell>
                        <fo:table-cell>
                            <xsl:if test="not($dell-brand = 'Non-brand')">
                                <fo:block xsl:use-attribute-sets="__frontmatter_footer_logo" text-align="right">
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
									<fo:external-graphic src="url('{$logo-path}')">
										<xsl:if test="$dell-brand = 'Dell Technologies'">
                                            <xsl:attribute name="content-width">1.717in</xsl:attribute>
                                        </xsl:if>
									</fo:external-graphic>
                                </fo:block>
                            </xsl:if>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template name="createBackCoverContents">
        <fo:block-container xsl:use-attribute-sets="__back-cover.footer.container">
            <fo:block xsl:use-attribute-sets="__back-cover.footer.text">
                <fo:block xsl:use-attribute-sets="__back-cover.url">
                    <xsl:value-of select="$url"/>
                </fo:block>
                <fo:block text-align="center">
                    <fo:external-graphic xsl:use-attribute-sets="__back-cover.barcode.image">
                        <xsl:attribute name="src">
                            <xsl:value-of select="$barcode"/>
                        </xsl:attribute>
                        <xsl:attribute name="axf:alttext">
                            <xsl:text>Bar code</xsl:text>
                        </xsl:attribute>
                    </fo:external-graphic>
                </fo:block>
            </fo:block>
        </fo:block-container>
    </xsl:template>

</xsl:stylesheet>