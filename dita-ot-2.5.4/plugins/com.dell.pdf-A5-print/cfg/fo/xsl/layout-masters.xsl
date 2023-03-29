<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

    <xsl:template match="/" mode="create-page-masters">
        <!-- Frontmatter simple masters -->
        <fo:simple-page-master master-name="front-matter-first" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body xsl:use-attribute-sets="region-body__frontmatter.odd"/>
            <xsl:if test="$multilingual">
                <fo:region-after region-name="front-matter-footer_multilingual" xsl:use-attribute-sets="region-after"/>
            </xsl:if>
        </fo:simple-page-master>

        <xsl:if test="$multilingual">
            <fo:simple-page-master master-name="front-matter-odd" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
                <fo:region-body xsl:use-attribute-sets="region-body__frontmatter.odd"/>
            </fo:simple-page-master>
            <fo:simple-page-master master-name="front-matter-even" xsl:use-attribute-sets="simple-page-master page-master-print.even">
                <fo:region-body xsl:use-attribute-sets="region-body__frontmatter.even"/>
            </fo:simple-page-master>
        </xsl:if>
        <!-- Backcover simple masters -->
        <fo:simple-page-master master-name="back-cover-odd" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body />
        </fo:simple-page-master>
        <fo:simple-page-master master-name="back-cover-even" xsl:use-attribute-sets="simple-page-master page-master-print.even">
            <fo:region-body />
        </fo:simple-page-master>

        <!--TOC simple masters-->
        <xsl:if test="$generate-toc">
            <xsl:if test="$mirror-page-margins">
                <fo:simple-page-master master-name="toc-even" xsl:use-attribute-sets="simple-page-master page-master-print.even">
                    <fo:region-body xsl:use-attribute-sets="region-body_toc.even"/>
                    <fo:region-after region-name="even-toc-footer" xsl:use-attribute-sets="region-after"/>
                </fo:simple-page-master>
            </xsl:if>

            <fo:simple-page-master master-name="toc-odd" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
                <fo:region-body xsl:use-attribute-sets="region-body_toc.odd"/>
                <fo:region-after region-name="odd-toc-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>

            <fo:simple-page-master master-name="toc-first" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
                <fo:region-body xsl:use-attribute-sets="region-body_toc.odd"/>
                <fo:region-after region-name="odd-toc-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>
        </xsl:if>

        <!--Notice simple masters-->
        <fo:simple-page-master master-name="notice-first" xsl:use-attribute-sets="simple-page-master page-master-print.even">
            <fo:region-body xsl:use-attribute-sets="region-body_notice.even"/>
        </fo:simple-page-master>

        <!--BODY simple masters-->
        <fo:simple-page-master master-name="body-first" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
            <fo:region-after region-name="odd-body-footer" xsl:use-attribute-sets="region-after"/>
        </fo:simple-page-master>

        <xsl:if test="$mirror-page-margins">
            <fo:simple-page-master master-name="body-even" xsl:use-attribute-sets="simple-page-master page-master-print.even">
                <fo:region-body xsl:use-attribute-sets="region-body.even"/>
                <fo:region-after region-name="even-body-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>
        </xsl:if>

        <fo:simple-page-master master-name="body-odd" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body xsl:use-attribute-sets="region-body.odd"/>
            <fo:region-after region-name="odd-body-footer" xsl:use-attribute-sets="region-after"/>
        </fo:simple-page-master>

        <!--INDEX simple masters-->
        <fo:simple-page-master master-name="index-first" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body xsl:use-attribute-sets="region-body_toc.odd">
                <xsl:attribute name="column-count">2</xsl:attribute>
            </fo:region-body>
            <fo:region-after region-name="odd-body-footer" xsl:use-attribute-sets="region-after"/>
        </fo:simple-page-master>

        <xsl:if test="$mirror-page-margins">
            <fo:simple-page-master master-name="index-even" xsl:use-attribute-sets="simple-page-master page-master-print.even">
                <fo:region-body xsl:use-attribute-sets="region-body_toc.even">
                    <xsl:attribute name="column-count">2</xsl:attribute>
                </fo:region-body>
                <fo:region-after region-name="even-body-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>
        </xsl:if>

        <fo:simple-page-master master-name="index-odd" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body xsl:use-attribute-sets="region-body_toc.odd">
                <xsl:attribute name="column-count">2</xsl:attribute>
            </fo:region-body>
            <fo:region-after region-name="odd-body-footer" xsl:use-attribute-sets="region-after"/>
        </fo:simple-page-master>

        <!--GLOSSARY simple masters-->
        <fo:simple-page-master master-name="glossary-first" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body xsl:use-attribute-sets="region-body_toc.odd"/>
            <fo:region-after region-name="odd-body-footer" xsl:use-attribute-sets="region-after"/>
        </fo:simple-page-master>

        <xsl:if test="$mirror-page-margins">
            <fo:simple-page-master master-name="glossary-even" xsl:use-attribute-sets="simple-page-master page-master-print.even">
                <fo:region-body xsl:use-attribute-sets="region-body_toc.even"/>
                <fo:region-after region-name="even-body-footer" xsl:use-attribute-sets="region-after"/>
            </fo:simple-page-master>
        </xsl:if>

        <fo:simple-page-master master-name="glossary-odd" xsl:use-attribute-sets="simple-page-master page-master-print.odd">
            <fo:region-body xsl:use-attribute-sets="region-body_toc.odd"/>
            <fo:region-after region-name="odd-body-footer" xsl:use-attribute-sets="region-after"/>
        </fo:simple-page-master>
    </xsl:template>

    <xsl:template match="/" mode="create-page-sequences">
        <xsl:if test="$generate-toc">
            <xsl:call-template name="generate-page-sequence-master">
                <xsl:with-param name="master-name" select="'toc-sequence'"/>
                <xsl:with-param name="master-reference" select="'toc'"/>
                <xsl:with-param name="first" select="false()"/>
                <xsl:with-param name="last" select="false()"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="generate-page-sequence-master">
            <xsl:with-param name="master-name" select="'body-sequence'"/>
            <xsl:with-param name="master-reference" select="'body'"/>
            <xsl:with-param name="first" select="false()"/>
            <xsl:with-param name="last" select="false()"/>
        </xsl:call-template>
        <xsl:call-template name="generate-page-sequence-master">
            <xsl:with-param name="master-name" select="'ditamap-body-sequence'"/>
            <xsl:with-param name="master-reference" select="'body'"/>
            <xsl:with-param name="first" select="false()"/>
            <xsl:with-param name="last" select="false()"/>
        </xsl:call-template>
        <xsl:call-template name="generate-page-sequence-master">
            <xsl:with-param name="master-name" select="'index-sequence'"/>
            <xsl:with-param name="master-reference" select="'index'"/>
            <xsl:with-param name="last" select="false()"/>
        </xsl:call-template>
        <xsl:call-template name="insert-page-sequence-master-frontmatter"/>
        <xsl:call-template name="insert-page-sequence-master-notice"/>
        <xsl:call-template name="generate-page-sequence-master">
            <xsl:with-param name="master-name" select="'back-cover'"/>
            <xsl:with-param name="master-reference" select="'back-cover'"/>
            <xsl:with-param name="first" select="false()"/>
            <xsl:with-param name="last" select="false()"/>
        </xsl:call-template>
        <xsl:call-template name="generate-page-sequence-master">
            <xsl:with-param name="master-name" select="'glossary-sequence'"/>
            <xsl:with-param name="master-reference" select="'glossary'"/>
            <xsl:with-param name="last" select="false()"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="insert-page-sequence-master-frontmatter">
        <fo:page-sequence-master master-name="front-matter">
            <fo:repeatable-page-master-alternatives>
                <fo:conditional-page-master-reference master-reference="front-matter-first" odd-or-even="odd" page-position="first"/>
                <xsl:if test="$multilingual">
                    <fo:conditional-page-master-reference master-reference="front-matter-odd" odd-or-even="odd"/>
                    <fo:conditional-page-master-reference master-reference="front-matter-even" odd-or-even="even"/>
                </xsl:if>
            </fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
    </xsl:template>

    <xsl:template name="insert-page-sequence-master-notice">
        <fo:page-sequence-master master-name="body-sequence-notice">
            <fo:repeatable-page-master-alternatives>
                <fo:conditional-page-master-reference master-reference="notice-first" odd-or-even="even"/>
            </fo:repeatable-page-master-alternatives>
        </fo:page-sequence-master>
    </xsl:template>
</xsl:stylesheet>