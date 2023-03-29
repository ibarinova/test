<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="*[contains(@class,' hi-d/sup ')]" name="topic.hi-d.sup">
        <span style="vertical-align: top; position: relative; top: -0.5em;">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class,' hi-d/sub ')]" name="topic.hi-d.sub">
        <span style="vertical-align: bottom; position: relative; bottom: -0.5em;">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>