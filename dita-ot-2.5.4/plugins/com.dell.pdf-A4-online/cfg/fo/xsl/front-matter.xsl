<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:template name="createFrontMatter">
        <xsl:if test="$generate-front-cover">
            <fo:page-sequence master-reference="front-matter" xsl:use-attribute-sets="page-sequence.cover">
				<!--Added draft beta watermark-->
                <!--<xsl:call-template name="insertFrontMatterStaticContents"/>-->
                <fo:flow flow-name="xsl-region-body">
                    <fo:block-container xsl:use-attribute-sets="restriction.watermark_container">
                        <xsl:if test="normalize-space($restriction-value) and not($isTechnote)">
                            <fo:block>
                                <fo:inline xsl:use-attribute-sets="restriction.watermark.cover">
                                    <xsl:value-of select="$restriction-value"/>
                                </fo:inline>
                            </fo:block>
                        </xsl:if>
                    </fo:block-container>
                    <xsl:if test="normalize-space($watermark-value) and not($isTechnote)">
                        <fo:block xsl:use-attribute-sets="draft.watermark.cover">
                            <fo:inline>
                                <xsl:value-of select="$watermark-value"/>
                            </fo:inline>
                        </fo:block>
                    </xsl:if>
                    <fo:block-container xsl:use-attribute-sets="__frontmatter">
                        <xsl:attribute name="id" select="$id.cover"/>
                        <xsl:call-template name="createFrontCoverContents"/>
                    </fo:block-container>
                    <xsl:call-template name="insert-solutions-abstract-frontmatter-block"/>
                    <xsl:call-template name="insert-solutions-author-frontmatter-block"/>
                    <fo:block-container xsl:use-attribute-sets="__frontmatter_footer_container">
                        <xsl:call-template name="createFrontCoverContents_footer"/>
                    </fo:block-container>
                    <fo:block-container>
                        <xsl:if test="$book.vrm!='0' and $book.vrm!='0.0' and $book.vrm!=''">
                            <xsl:choose>
                                <xsl:when test="$use-vrm-string_ver">
                                    <fo:block xsl:use-attribute-sets="vrm-cover-page">
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'Version'"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="$book.vrm"/>
                                    </fo:block>
                                </xsl:when>
                                <xsl:when test="$use-vrm-string_rel">
                                    <fo:block xsl:use-attribute-sets="vrm-cover-page">
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'release'"/>
                                        </xsl:call-template>
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="$book.vrm"/>
                                    </fo:block>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:block xsl:use-attribute-sets="vrm-cover-page">
                                        <xsl:text> </xsl:text>
                                        <xsl:value-of select="$book.vrm"/>
                                    </fo:block>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </fo:block-container>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <xsl:template name="createFrontCoverContents_footer">
        <fo:block xsl:use-attribute-sets="__frontmatter_footer">
            <fo:table xsl:use-attribute-sets="__frontmatter_footer_table">
                <fo:table-column column-width="60%"/>
                <fo:table-column column-width="40%"/>
                <fo:table-body>
                    <fo:table-row>
                        <fo:table-cell xsl:use-attribute-sets="__frontmatter_footer_content_cell">
                            <xsl:variable name="content">
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
                                        <xsl:choose>
                                            <xsl:when test="$use-part-number">
                                                <xsl:call-template name="getVariable">
                                                    <xsl:with-param name="id" select="'dsg Part Number'"/>
                                                </xsl:call-template>
                                                <xsl:text>:</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:call-template name="getVariable">
                                                    <xsl:with-param name="id" select="'Regulatory Model'"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
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
                                <!--Removed margin-and padding-->
                                <fo:block-container>
                                    <xsl:if test="not($isNochap)">
                                        <xsl:if test="not($isTechnote)">
                                            <fo:block>
                                                <xsl:value-of select="$release.date"/>
                                            </fo:block>
                                        </xsl:if>
                                        <xsl:if test="normalize-space($book.revision) and not($isTechnote)">
                                            <fo:block>
                                                <xsl:call-template name="getVariable">
                                                    <xsl:with-param name="id" select="'Technote Document Rev'"/>
                                                </xsl:call-template>
                                                <xsl:value-of select="$book.revision"/>
                                            </fo:block>
                                        </xsl:if>
                                    </xsl:if>
                                </fo:block-container>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$dell-brand = ('Alienware', 'Non-brand', 'RSA')">
                                    <xsl:copy-of select="$content"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <fo:block-container xsl:use-attribute-sets="__frontmatter_footer_content_container">
                                        <xsl:copy-of select="$content"/>
                                    </fo:block-container>
                                </xsl:otherwise>
                            </xsl:choose>
                        </fo:table-cell>
                        <fo:table-cell>
                            <xsl:if test="not($dell-brand = 'Non-brand')">
                                <fo:block xsl:use-attribute-sets="__frontmatter_footer_logo" text-align="right">
                                    <xsl:variable name="logo-path">
                                        <xsl:choose>
                                            <xsl:when test="$dell-brand = 'Dell EMC'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'dellemc-white.svg')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'Alienware'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'Alienware-black.jpg')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'RSA'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'rsa-logo-white.png')"/>
                                            </xsl:when>
                                            <xsl:when test="$dell-brand = 'Dell Technologies'">
                                                <xsl:value-of select="concat($artwork-logo-dir, 'DellTech_Logo_Wht.svg')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="concat($artwork-logo-dir, 'dell-white.svg')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <xsl:variable name="logo-width">
                                        <xsl:choose>
                                            <xsl:when test="$dell-brand = 'Dell EMC'">2in</xsl:when>
                                            <xsl:when test="$dell-brand = 'Alienware'">2in</xsl:when>
                                            <xsl:when test="$dell-brand = 'RSA'">1.15in</xsl:when>
                                            <xsl:when test="$dell-brand = 'Dell Technologies'">2.623in</xsl:when>
                                            <xsl:otherwise>0.85in</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>

                                    <fo:external-graphic src="url('{$logo-path}')"
                                                         width="{$logo-width}"
                                                         content-width="{$logo-width}"
                                                         content-height="scale-to-fit"
                                                         scaling="uniform"/>
                                </fo:block>
                            </xsl:if>
                        </fo:table-cell>
                    </fo:table-row>
                </fo:table-body>
            </fo:table>
        </fo:block>
    </xsl:template>

    <xsl:template name="insert-solutions-abstract-frontmatter-block">
        <xsl:variable name="shortdesc">
            <xsl:apply-templates select="/descendant::*[contains(@class,' bookmap/bookmeta ')][1]/descendant::*[contains(@class,' map/shortdesc ')][1][contains(@outputclass, 'abstract')][1]"/>
        </xsl:variable>
        <xsl:if test="normalize-space($shortdesc)">
            <fo:block-container xsl:use-attribute-sets="__frontmatter__solutions_abstract_container">
                <fo:block xsl:use-attribute-sets="__frontmatter__solutions_abstrac_title">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Abstract'"/>
                    </xsl:call-template>
                </fo:block>
                <fo:block xsl:use-attribute-sets="__frontmatter__solutions_shortdesc">
                    <xsl:value-of select="$shortdesc"/>
                </fo:block>
            </fo:block-container>
        </xsl:if>
    </xsl:template>

    <xsl:template name="insert-solutions-author-frontmatter-block">
        <xsl:variable name="author" select="/descendant::*[contains(@class,' bookmap/bookmeta ')][1]/descendant::*[contains(@class,' topic/author ')][1]"/>
        <xsl:if test="normalize-space($author)">
            <fo:block-container xsl:use-attribute-sets="__frontmatter__solutions_author_container">
                <fo:block xsl:use-attribute-sets="__frontmatter__author">
                    <xsl:value-of select="$author"/>
                </fo:block>
            </fo:block-container>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>