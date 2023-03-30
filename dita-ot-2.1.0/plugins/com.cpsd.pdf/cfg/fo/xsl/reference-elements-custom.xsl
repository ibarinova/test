<?xml version="1.0" encoding="UTF-8"?>
<!--
This file is part of the DITA Open Toolkit project.
See the accompanying license.txt file for applicable licenses.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:psmi="http://www.CraneSoftwrights.com/resources/psmi"
  exclude-result-prefixes="xs"
  version="2.0">

  <!-- mckimn 08/26/26: Cast entryCol to a number to allow for comparision of similiar types and prevent a mismatch error -->
  <xsl:template match="*[contains(@class, ' reference/proptype ') or contains(@class, ' reference/propvalue ') or contains(@class, ' reference/propdesc ')]">
    <xsl:param name="entryCol"/>
    <fo:table-cell xsl:use-attribute-sets="property.entry">
      <xsl:call-template name="commonattributes"/>
      <xsl:variable name="frame">
        <xsl:variable name="f" select="ancestor::*[contains(@class, ' reference/properties ')][1]/@frame"/>
        <xsl:choose>
          <xsl:when test="$f">
            <xsl:value-of select="$f"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$table.frame-default"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:if test="../following-sibling::*[contains(@class, ' reference/property ')]">
        <xsl:call-template name="generateSimpleTableHorizontalBorders">
          <xsl:with-param name="frame" select="$frame"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="following-sibling::*[contains(@class, ' reference/proptype ') or contains(@class, ' reference/propvalue ') or contains(@class, ' reference/propdesc ')]">
        <xsl:call-template name="generateSimpleTableVerticalBorders">
          <xsl:with-param name="frame" select="$frame"/>
        </xsl:call-template>
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test="number(ancestor::*[contains(@class, ' reference/properties ')][1]/@keycol) = number($entryCol)">
          <fo:block xsl:use-attribute-sets="property.entry__keycol-content">
            <xsl:apply-templates/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block xsl:use-attribute-sets="property.entry__content">
            <xsl:apply-templates/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:table-cell>
  </xsl:template>
  
  <!-- mckimn 08/26/26: Cast entryCol to a number to allow for comparision of similiar types and prevent a mismatch error -->
  <xsl:template match="*[contains(@class, ' reference/proptypehd ') or contains(@class, ' reference/propvaluehd ') or contains(@class, ' reference/propdeschd ')]">
    <xsl:param name="entryCol"/>
    <fo:table-cell xsl:use-attribute-sets="prophead.entry">
      <xsl:call-template name="commonattributes"/>
      <xsl:variable name="frame">
        <xsl:variable name="f" select="ancestor::*[contains(@class, ' reference/properties ')][1]/@frame"/>
        <xsl:choose>
          <xsl:when test="$f">
            <xsl:value-of select="$f"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$table.frame-default"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      
      <xsl:call-template name="generateSimpleTableHorizontalBorders">
        <xsl:with-param name="frame" select="$frame"/>
      </xsl:call-template>
      <xsl:if test="$frame = 'all' or $frame = 'topbot' or $frame = 'top' or not($frame)">
        <xsl:call-template name="processAttrSetReflection">
          <xsl:with-param name="attrSet" select="'__tableframe__top'"/>
          <xsl:with-param name="path" select="$tableAttrs"/>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="following-sibling::*[contains(@class, ' reference/proptypehd ') or contains(@class, ' reference/propvaluehd ') or contains(@class, ' reference/propdeschd ')]">
        <xsl:call-template name="generateSimpleTableVerticalBorders">
          <xsl:with-param name="frame" select="$frame"/>
        </xsl:call-template>
      </xsl:if>
      
      <xsl:choose>
        <xsl:when test="number(ancestor::*[contains(@class, ' reference/properties ')][1]/@keycol) = number($entryCol)">
          <fo:block xsl:use-attribute-sets="prophead.entry__keycol-content">
            <xsl:apply-templates/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <fo:block xsl:use-attribute-sets="prophead.entry__content">
            <xsl:apply-templates/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:table-cell>
  </xsl:template>
  
  <!-- Suite Jan-2012: test for landscape outputclass on properties.  Only honor outputclass if properties is top-level in topic - rs -->
  <xsl:template match="*[contains(@class, ' reference/properties ')]">
    <xsl:choose>
      <xsl:when test="contains(@outputclass, 'landscape') and parent::*[contains(@class,' topic/body ')]">
        <psmi:page-sequence master-reference="body-landscape-sequence">
          <xsl:call-template name="insertBodyStaticContents"/>
          <fo:flow flow-name="xsl-region-body">
            <xsl:call-template name="propertiesSubTemplate"/>
          </fo:flow>
        </psmi:page-sequence>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="propertiesSubTemplate"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>