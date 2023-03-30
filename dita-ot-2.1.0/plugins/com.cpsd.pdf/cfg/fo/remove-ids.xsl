<?xml version="1.0" encoding="utf-8"?>

  <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
    xmlns:exsl="http://exslt.org/common"
    xmlns:exslf="http://exslt.org/functions"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    extension-element-prefixes="exsl"
    exclude-result-prefixes="opentopic-func exslf exsl dita2xslfo"
    version="2.0">
    
    <xsl:template match="*">
      <xsl:copy>
        <xsl:apply-templates select="* | @* | comment() | text() | processing-instruction()"/>
      </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@id" priority="2">
      <xsl:variable name="isLinked">
        <xsl:call-template name="isLinked">
          <xsl:with-param name="id" select="."/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="contains($isLinked,'yes') or contains(.,'should_remain')">
          <xsl:attribute name="id">
            <xsl:value-of select="."/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:template>
    
    <xsl:template match="@* | comment() | text() | processing-instruction()">
      <xsl:copy-of select="."/>
    </xsl:template>


    <xsl:template name="isLinked">
      <xsl:param name="id"/>
      <xsl:for-each select="//fo:basic-link">
        <xsl:if test="@internal-destination = $id">
          <xsl:value-of select="'yes'"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="//fo:page-number-citation">
        <xsl:if test="@ref-id = $id">
          <xsl:value-of select="'yes'"/>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="//fo:bookmark">
        <xsl:if test="@internal-destination = $id">
          <xsl:value-of select="'yes'"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
