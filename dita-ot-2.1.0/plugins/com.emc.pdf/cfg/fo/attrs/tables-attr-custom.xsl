<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="2.0">

  <!--
  Revision History
  ================
  Suite/EMC   SOW5  15-Feb-2012   font changes
  Suite/EMC   SOW7  18-Feb-2013   format choicetable like table
  EMC		  IB3	14-Nov-2013	  Issue 349: Keep dt with first paragraph of the dd
  EMC 	 	  IB4	18-Mar-2014	  Add the double border effect for the header row
  EMC 		  IB6 	17-Oct-2014   TKT-146:PDF, WebWorks outputs incorrectly display @colsep and @rowsep
  EMC				9-May-2015	  Fix for table footnote issue in production for PDF corruption
  EMC		  IB8	01-Oct-2015	  TKT-262: dl entries should break even when it's nested
  -->

  <!-- contents of table entries or similer structures -->
  <xsl:attribute-set name="common.table.body.entry">
    <xsl:attribute name="space-before">inherit</xsl:attribute>
    <xsl:attribute name="space-before.conditionality">retain</xsl:attribute>
    <xsl:attribute name="space-after">inherit</xsl:attribute>
    <xsl:attribute name="space-after.conditionality">retain</xsl:attribute>
    <xsl:attribute name="start-indent">inherit</xsl:attribute>
    <xsl:attribute name="end-indent">inherit</xsl:attribute>
    <xsl:attribute name="margin">3pt 3pt 3pt 3pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="common.table.head.entry">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="margin">3pt 3pt 3pt 3pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="thead.empty-row" use-attribute-sets="__tableframe__bottom">
    <xsl:attribute name="color">white</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="thead.empty-block" >
    <xsl:attribute name="color">white</xsl:attribute>
    <xsl:attribute name="line-height">2pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table" use-attribute-sets="base-font">
    <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">
      <xsl:choose>
        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and ancestor::*[contains(@class, ' topic/li ')] and not(ancestor::*[contains(@class, ' task/step ')])">5pt</xsl:when>
        <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]">0</xsl:when>
        <xsl:otherwise>5pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="thead__tableframe__bottom">
    <xsl:attribute name="border-bottom-style">solid</xsl:attribute>
    <xsl:attribute name="border-bottom-width">1px</xsl:attribute>
    <xsl:attribute name="border-bottom-color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__tableframe__top" use-attribute-sets="common.border__top">
    <xsl:attribute name="border-before-style">solid</xsl:attribute>
    <xsl:attribute name="border-before-width">1px</xsl:attribute>
    <xsl:attribute name="border-after-width.conditionality">retain</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__tableframe__bottom" use-attribute-sets="common.border__bottom">
    <xsl:attribute name="border-after-style">solid</xsl:attribute>
    <xsl:attribute name="border-after-width">1px</xsl:attribute>
    <xsl:attribute name="border-after-width.conditionality">retain</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__tableframe__left" use-attribute-sets="common.border__left">
    <xsl:attribute name="border-start-style">solid</xsl:attribute>
    <xsl:attribute name="border-start-width">1px</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__tableframe__right" use-attribute-sets="common.border__right">
    <xsl:attribute name="border-end-style">solid</xsl:attribute>
    <xsl:attribute name="border-end-width">1px</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table__tableframe__all" use-attribute-sets="table__tableframe__topbot table__tableframe__sides">
  </xsl:attribute-set>

  <xsl:attribute-set name="table__tableframe__topbot" use-attribute-sets="__tableframe__top __tableframe__bottom">
  </xsl:attribute-set>

  <xsl:attribute-set name="table__tableframe__sides" use-attribute-sets="__tableframe__left __tableframe__right">
  </xsl:attribute-set>

  <xsl:attribute-set name="table__tableframe__top"  use-attribute-sets="common.border__top">
    <xsl:attribute name="border-before-style">solid</xsl:attribute>
    <xsl:attribute name="border-before-width">1px</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table__tableframe__bottom" use-attribute-sets="common.border__bottom">
    <xsl:attribute name="border-after-style">solid</xsl:attribute>
    <xsl:attribute name="border-after-width">1px</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table__tableframe__left" use-attribute-sets="common.border__left">
    <xsl:attribute name="border-start-style">solid</xsl:attribute>
    <xsl:attribute name="border-start-width">1px</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table__tableframe__right" use-attribute-sets="common.border__right">
    <xsl:attribute name="border-end-style">solid</xsl:attribute>
    <xsl:attribute name="border-end-width">1px</xsl:attribute>
  </xsl:attribute-set>


  <xsl:attribute-set name="thead.row.entry">
    <xsl:attribute name="background-color">white</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table.title" use-attribute-sets="base-font common.title">
    <xsl:attribute name="font-size"><xsl:value-of select="$default-table-font-size"/></xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">10pt</xsl:attribute>
    <xsl:attribute name="padding-top">5pt</xsl:attribute>
    <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
    <xsl:attribute name="text-align-last">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="thead.table.title" use-attribute-sets="table.title">
    <xsl:attribute name="text-indent">1in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="thead.row" use-attribute-sets="__tableframe__bottom">
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight='no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight='yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <!-- Dimitri: Change table header font size to 9 pt. -->
    <!--xsl:attribute name="font-size">10pt</xsl:attribute-->
    <xsl:attribute name="font-size">9pt</xsl:attribute>
   	<xsl:attribute name="border-bottom-style">double</xsl:attribute>
   	<xsl:attribute name="border-bottom-width">3px</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="thead.row.entry__content" use-attribute-sets="common.table.body.entry common.table.head.entry">
    <xsl:attribute name="font-weight">normal</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="tbody.row.entry__content">
    <xsl:attribute name="margin">3pt 3pt 3pt 3pt</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size"><xsl:value-of select="$default-table-font-size"/></xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="below-header">
    <xsl:attribute name="height">50pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="sthead.stentry__keycol-content" use-attribute-sets="common.table.body.entry common.table.head.entry">
    <xsl:attribute name="background-color">white</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="strow.stentry__keycol-content" use-attribute-sets="common.table.body.entry common.table.head.entry">
    <xsl:attribute name="background-color">white</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="dl">
    <!--xsl:attribute name="width">100%</xsl:attribute-->
    <!--<xsl:attribute name="space-before">5pt</xsl:attribute>-->
    <xsl:attribute name="space-before">
      <xsl:choose>
        <xsl:when test="preceding-sibling::*[not(contains(@class, ' topic/title '))] and parent::*[contains(@class, ' topic/section ')]">0pt</xsl:when>
        <xsl:otherwise>5pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="dlentry">
    <xsl:attribute name="padding-bottom">5pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="dlentry.dt">
    <xsl:attribute name="relative-align">baseline</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="dlentry.dt__content" use-attribute-sets="base-font common.table.body.entry common.table.head.entry">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="dlentry.dd">
    <xsl:attribute name="font-size"><xsl:value-of select="$default-table-font-size"/></xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="dlentry.dd__content" use-attribute-sets="common.table.body.entry">
    <xsl:attribute name="margin">0pt 0pt 0pt 20pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="properties">
    <xsl:attribute name="margin-left">
    <xsl:choose>
      <xsl:when test="contains(@outputclass,'pagewide')">-<xsl:value-of select="$side-col-width"/></xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani 2-Aug-13 added property footnote -->
  <xsl:attribute-set name="propertiesFNtable">
    <xsl:attribute name="margin-left">
    <xsl:choose>
      <xsl:when test="contains(@outputclass,'pagewide')">-<xsl:value-of select="$side-col-width"/></xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-after.optimum">10pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="simpletable">
    <xsl:attribute name="margin-left">
      <xsl:choose>
        <xsl:when test="contains(@outputclass,'pagewide')">-<xsl:value-of select="$side-col-width"/></xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-after">
      <xsl:choose>
        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and ancestor::*[contains(@class, ' topic/li ')] and not(ancestor::*[contains(@class, ' task/step ')])">3pt</xsl:when>
        <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]">0</xsl:when>
        <xsl:otherwise>10pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-after.optimum">
      <xsl:choose>
        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and ancestor::*[contains(@class, ' topic/li ')] and not(ancestor::*[contains(@class, ' task/step ')])">3pt</xsl:when>
        <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]">0</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani 2-Aug-13 added simpletable footnote -->
  <xsl:attribute-set name="simpletableFNtable">
    <xsl:attribute name="margin-left">
      <xsl:choose>
        <xsl:when test="contains(@outputclass,'pagewide')">-<xsl:value-of select="$side-col-width"/></xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:attribute>
	<xsl:attribute name="space-after.optimum">10pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="chhead.choptionhd" use-attribute-sets="table__tableframe__all">
  </xsl:attribute-set>

  <xsl:attribute-set name="chhead.chdeschd" use-attribute-sets="table__tableframe__all">
  </xsl:attribute-set>

  <xsl:attribute-set name="chrow.choption" use-attribute-sets="table__tableframe__all">
  </xsl:attribute-set>

  <xsl:attribute-set name="chrow.chdesc" use-attribute-sets="table__tableframe__all">
  </xsl:attribute-set>

  <xsl:attribute-set name="choicetable">
    <xsl:attribute name="margin-top">3mm</xsl:attribute>
    <xsl:attribute name="space-after">
      <xsl:choose>
        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and ancestor::*[contains(@class, ' topic/li ')] and not(ancestor::*[contains(@class, ' task/step ')])">3pt</xsl:when>
        <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]">0</xsl:when>
        <xsl:otherwise>10pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="space-after.optimum">
      <xsl:choose>
        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and ancestor::*[contains(@class, ' topic/li ')] and not(ancestor::*[contains(@class, ' task/step ')])">3pt</xsl:when>
        <xsl:when test="ancestor::*[contains(@class, ' topic/li ')]">0</xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- Balaji Mani 12-June-2013: indent table footer -->
  <xsl:attribute-set name="tablefootnote">
    <xsl:attribute name="padding-left">0.39in</xsl:attribute>
	<xsl:attribute name="padding-top">0.10in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="table.footer">
    <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
  </xsl:attribute-set>
</xsl:stylesheet>