<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">

  <!-- Nathan McKimpson 24-May-2013: Add quotations alternative -->
  <!-- EMC 	  IB4	      18-Mar-2014	 Remove extra formatting if varname is present within other elements -->
  <xsl:template match="*[contains(@class,' sw-d/varname ')]">
    <fo:inline xsl:use-attribute-sets="varname">
      <xsl:call-template name="commonattributes"/>

<!--
      <xsl:choose>
        <xsl:when test="parent::*[contains(@class,' ui-d/uicontrol ') or contains(@class,' pr-d/var ')]">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'start-quote'"/>
          </xsl:call-template>
          <xsl:apply-templates/>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'end-quote'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
-->
        <!-- Intelliarts Consulting   DellEMC SP-2017_aug    17-Jul-2017   TKT-409 - Remove quotation marks for varname and option.    - IB-->
        <xsl:apply-templates/>

    </fo:inline>
  </xsl:template>

  <!-- EMC    IB4     03-Apr-2014   Strip the leading/trailing spaces (in case of line-breaks as well) -->
  <xsl:template match="*[contains(@class,' sw-d/varname ') or parent::*[contains(@class,' sw-d/varname ')]]/text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

</xsl:stylesheet>