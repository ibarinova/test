<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Customized to remove HTML5 <var> and replace it with <span> -->
    <xsl:template match="*[contains(@class,' sw-d/varname ')] | *[contains(@class,' pr-d/var ')]"
                  name="topic.sw-d.varname">
        <xsl:variable name="lang">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::*/@xml:lang">
                    <xsl:value-of select="ancestor-or-self::*/@xml:lang"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$LANGUAGE"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="prefix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_var'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="suffix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_var'"/>
            </xsl:call-template>
        </xsl:variable>
        <!-- EMC	15-Oct-2014		Fix to avoid floating prefix and suffix for L10N languages -->
        <span style="white-space: nowrap;">
            <xsl:if test="not(parent::*[contains(@class,' ui-d/uicontrol ') or contains(@class,' pr-d/var ')])">
                <xsl:value-of select="$prefix-char"/>
            </xsl:if>
            <span class="varname">
                <xsl:if test="starts-with(lower-case($lang),'ja') or starts-with(lower-case($lang),'zh')">
                    <xsl:attribute name="style">font-style:normal;</xsl:attribute>
                </xsl:if>
                <xsl:call-template name="setidaname"/>
                <xsl:apply-templates/>
            </span>
            <xsl:if test="not(parent::*[contains(@class,' ui-d/uicontrol ') or contains(@class,' pr-d/var ')])">
                <xsl:value-of select="$suffix-char"/>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' sw-d/userinput ')]" name="topic.sw-d.userinput">
        <xsl:variable name="uicontrolcount">
            <xsl:number count="*[contains(@class,' ui-d/uicontrol ')]"/>
        </xsl:variable>
        <xsl:if test="$uicontrolcount&gt;'1'">
            <xsl:text> > </xsl:text>
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

        <xsl:value-of select="$prefix-char"/>
        <span class="userinput">
            <xsl:apply-templates/>
        </span>
        <xsl:value-of select="$suffix-char"/>

    </xsl:template>

    <xsl:template match="*[contains(@class,' sw-d/msgph ')]" name="topic.sw-d.msgph">
        <span class="msgph">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class,' sw-d/systemoutput ')]" name="topic.sw-d.systemoutput">
        <span class="sysout">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>