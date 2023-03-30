<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xs">

    <!--
    Revision History
    ================
    Suite/EMC   SOW6  14-Mar-2012   Quotations alternative
	EMC 			  25-Oct-2013	Issue 348: Turn off hyphenation in <synph> and <syntaxdiagram> elements
  -->

    <xsl:template match="*[contains(@class,' pr-d/option ')]">
        <fo:inline xsl:use-attribute-sets="option">
            <xsl:call-template name="commonattributes"/>
<!--
            &lt;!&ndash;Suite/EMC   SOW6  14-Mar-2012   Quotations alternative START - ck&ndash;&gt;
            <xsl:if test="parent::*[not(contains(@class, 'pr-d'))]">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'start-quote'"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="parent::*[not(contains(@class, 'pr-d'))]">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'end-quote'"/>
                </xsl:call-template>
            </xsl:if>
-->
            <!-- Intelliarts Consulting   DellEMC SP-2017_aug    17-Jul-2017   TKT-409 - Remove quotation marks for varname and option.    - IB-->
            <xsl:apply-templates/>

        </fo:inline>
    </xsl:template>

    <!-- Nathan McKimpson 24-May-2013: add quotations alternative -->
    <xsl:template match="*[contains(@class,' pr-d/var ')]">
        <fo:inline xsl:use-attribute-sets="var">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start-quote'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end-quote'"/>
            </xsl:call-template>
        </fo:inline>
    </xsl:template>

    <!-- Nathan McKimpson 22-May-2013: Add default parml processing to prevent them from being overridden -->
    <xsl:template match="*[contains(@class,' pr-d/parml ')]">
        <xsl:call-template name="generateAttrLabel"/>
        <fo:block xsl:use-attribute-sets="parml">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/plentry ')]">
        <fo:block xsl:use-attribute-sets="plentry">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/pt ')]">
        <fo:block xsl:use-attribute-sets="pt">
            <xsl:call-template name="commonattributes"/>
            <xsl:choose>
                <xsl:when test="*"> <!-- tagged content - do not default to bold -->
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <fo:inline xsl:use-attribute-sets="pt__content">
                        <xsl:apply-templates/>
                    </fo:inline> <!-- text only - bold it -->
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/pd ')]">
        <fo:block xsl:use-attribute-sets="pd">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

</xsl:stylesheet>