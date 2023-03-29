<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- Comtech Services 11-21-2013 copy code from webworks implementation -->
    <xsl:template match="*[contains(@class,' pr-d/option ')]" name="topic.pr-d.option">
        <xsl:variable name="prefix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_option'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="suffix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_option'"/>
            </xsl:call-template>
        </xsl:variable>

        <span class="option">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:value-of select="$prefix-char"/>
            <xsl:apply-templates/>
            <xsl:value-of select="$suffix-char"/>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/codeph ')]" name="topic.pr-d.codeph">
        <span class="codeph">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>