<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">

    <xsl:template match="*[contains(@class,' ui-d/uicontrol ')]">
        <!-- insert an arrow before all but the first uicontrol in a menucascade -->
        <xsl:if test="ancestor::*[contains(@class,' ui-d/menucascade ')]">
            <xsl:variable name="uicontrolcount" select="count(preceding-sibling::*[contains(@class,' ui-d/uicontrol ')])"/>
            <xsl:if test="$uicontrolcount &gt; 0">
                <xsl:call-template name="getVariable">
                  <xsl:with-param name="id" select="'#menucascade-separator'"/>
                </xsl:call-template>
            </xsl:if>
        </xsl:if>
        <fo:inline xsl:use-attribute-sets="uicontrol">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$locale = ('ja')">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'start_uicontrol_responsive'"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="$locale = ('ja')">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'end_uicontrol_responsive'"/>
                </xsl:call-template>
            </xsl:if>
        </fo:inline>
    </xsl:template>

    <xsl:template match="*[contains(@class,' ui-d/wintitle ')]">
        <fo:inline xsl:use-attribute-sets="wintitle">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$locale = ('ja')">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'start_wintitle_responsive'"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="$locale = ('ja')">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'end_wintitle_responsive'"/>
                </xsl:call-template>
            </xsl:if>
        </fo:inline>
    </xsl:template>

</xsl:stylesheet>
