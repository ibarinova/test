<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- Comtech Services 11-21-2013 copy code from webworks implementation -->
<xsl:template match="*[contains(@class, ' ui-d/uicontrol ') or contains(@class, ' ui-d/wintitle ')]">
    <xsl:variable name="uicontrolcount">
        <xsl:number count="*[contains(@class,' ui-d/uicontrol ')]"/>
    </xsl:variable>
    <xsl:if test="$uicontrolcount&gt;'1'">
        <!-- IBHTML5 21/07/2014 TKT-145: Multiple <uicontrol> elements in <step> produce extra > symbols -->
        <!--xsl:text> > </xsl:text-->
        <xsl:choose>
            <xsl:when test="parent::*[contains(@class,' ui-d/menucascade ')] and preceding-sibling::*[contains(@class, ' ui-d/uicontrol ')]">
                <xsl:text> > </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:if>

    <xsl:variable name="prefix-char">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'start_userinput'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="suffix-char">
        <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'end_userinput'"/>
        </xsl:call-template>
    </xsl:variable>

    <span class="uicontrol">
        <xsl:value-of select="$prefix-char"/>
        <xsl:apply-templates/>
        <xsl:value-of select="$suffix-char"/>
    </span>
</xsl:template>
</xsl:stylesheet>