<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

    <xsl:template match="figure" mode="add-xhtml-ns" priority="30">
        <xsl:element name="figure" namespace="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates select="@* except (@role, @xmlns) | node()" mode="add-xhtml-ns"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
