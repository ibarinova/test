<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="*[contains(@class,' topic/metadata ')]/*[contains(@class,' topic/category ')]" mode="gen-metadata"/>
    <xsl:template match="*[contains(@class,' topic/prodname ')]" mode="gen-metadata"/>
    <xsl:template match="*[contains(@class,' topic/vrm ')]/@version" mode="gen-metadata"/>
    <xsl:template match="*[contains(@class,' topic/series ')]" mode="gen-metadata"/>
    <xsl:template match="*[contains(@class,' topic/publisher ')]" mode="gen-metadata"/>
    <xsl:template match="*[contains(@class,' topic/othermeta ')]" mode="gen-metadata"/>

</xsl:stylesheet>
