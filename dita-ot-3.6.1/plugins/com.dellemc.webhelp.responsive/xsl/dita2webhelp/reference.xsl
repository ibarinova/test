<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                version="2.0"
                exclude-result-prefixes="xs dita-ot dita2html related-links">

  <xsl:template match="*[contains(@class, ' reference/properties ')]
    [empty(*[contains(@class,' reference/property ')]/
    *[contains(@class,' reference/proptype ') or contains(@class,' reference/propvalue ') or contains(@class,' reference/propdesc ')])]"
                priority="10"/>

  <xsl:template match="*[contains(@class,' reference/properties ')]" name="reference.properties">
    <xsl:call-template name="spec-title"/>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
    <xsl:call-template name="setaname"/>
    <table cellpadding="4" cellspacing="0"><!--summary=""-->
      <xsl:call-template name="setid"/>
      <xsl:attribute name="border" select="if (@frame = 'none') then 0 else 1"/>
      <xsl:call-template name="commonattributes">
        <xsl:with-param name="default-output-class">
          <xsl:choose>
            <xsl:when test="@frame = 'none'">properties all</xsl:when>
            <xsl:otherwise>properties all</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:apply-templates select="." mode="generate-table-summary-attribute"/>
      <xsl:call-template name="setscale"/>
      <xsl:call-template name="dita2html:simpletable-cols"/>

      <xsl:variable name="header" select="*[contains(@class,' reference/prophead ')]"/>
      <xsl:variable name="properties" select="*[contains(@class,' reference/property ')]"/>
      <xsl:variable name="hasType"
                    select="exists($header/*[contains(@class,' reference/proptypehd ')] | $properties/*[contains(@class,' reference/proptype ')])"/>
      <xsl:variable name="hasValue"
                    select="exists($header/*[contains(@class,' reference/propvaluehd ')] | $properties/*[contains(@class,' reference/propvalue ')])"/>
      <xsl:variable name="hasDesc"
                    select="exists($header/*[contains(@class,' reference/propdeschd ')] | $properties/*[contains(@class,' reference/propdesc ')])"/>

      <xsl:variable name="prophead" as="element()">
        <xsl:choose>
          <xsl:when test="*[contains(@class, ' reference/prophead ')]">
            <xsl:sequence select="*[contains(@class, ' reference/prophead ')]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="gen" as="element(gen)?">
              <xsl:call-template name="gen-prophead">
                <xsl:with-param name="hasType" select="$hasType"/>
                <xsl:with-param name="hasValue" select="$hasValue"/>
                <xsl:with-param name="hasDesc" select="$hasDesc"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:sequence select="$gen/*"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:apply-templates select="$prophead">
        <xsl:with-param name="hasType" select="$hasType"/>
        <xsl:with-param name="hasValue" select="$hasValue"/>
        <xsl:with-param name="hasDesc" select="$hasDesc"/>
      </xsl:apply-templates>
      <tbody>
        <xsl:apply-templates select="*[contains(@class, ' reference/property ')] | processing-instruction()">
          <xsl:with-param name="hasType" select="$hasType"/>
          <xsl:with-param name="hasValue" select="$hasValue"/>
          <xsl:with-param name="hasDesc" select="$hasDesc"/>
        </xsl:apply-templates>
      </tbody>
    </table>
    <xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')])">
      <xsl:variable name="table">
        <xsl:copy-of select="."/>
      </xsl:variable>
      <xsl:call-template name="gen-table-endnotes">
        <xsl:with-param name="table" select="$table"/>
      </xsl:call-template>
    </xsl:if>
    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
  </xsl:template>

</xsl:stylesheet>
