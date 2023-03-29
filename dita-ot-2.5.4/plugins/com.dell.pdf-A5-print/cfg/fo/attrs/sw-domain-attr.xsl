<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <xsl:attribute-set name="msgblock" use-attribute-sets="pre">
        <xsl:attribute name="start-indent">6pt + from-parent(start-indent)</xsl:attribute>
        <xsl:attribute name="end-indent">6pt + from-parent(end-indent)</xsl:attribute>
        <xsl:attribute name="padding">6pt</xsl:attribute>
        <xsl:attribute name="background-color">#f0f0f0</xsl:attribute>
    </xsl:attribute-set>

</xsl:stylesheet>