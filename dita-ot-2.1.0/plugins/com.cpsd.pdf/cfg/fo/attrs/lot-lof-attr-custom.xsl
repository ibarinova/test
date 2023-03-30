<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:rx="http://www.renderx.com/XSL/Extensions"
    version="2.0">
  
  <!-- 
  Revision History
  ================
  Suite/EMC   SOW5  19-Jan-2012   font changes
  Suite/EMC   SOW5  7-Feb-2012    font changes to match FM
  -->
  
  
  <xsl:attribute-set name ="__lotf__heading__rsa" use-attribute-sets="__toc__header __lotf__heading">
  </xsl:attribute-set> 

  <xsl:attribute-set name ="__lotf__heading" use-attribute-sets="__toc__header">
    <xsl:attribute name="margin-top">0in</xsl:attribute>
    <xsl:attribute name="margin-bottom">37pt</xsl:attribute>
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__lotf__indent" use-attribute-sets="__toc__indent__booklist">
  </xsl:attribute-set>

  <xsl:attribute-set name ="__lotf__content" use-attribute-sets="base-font __toc__topic__content__booklist">
    <xsl:attribute name ="font-size">10pt</xsl:attribute>
    <xsl:attribute name ="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name ="line-height">12pt</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="text-align-last">justify</xsl:attribute>
    <xsl:attribute name="space-before">0pt</xsl:attribute>
    <xsl:attribute name="space-after">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__lotf__number" use-attribute-sets="__lotf__content">
    <xsl:attribute name="font-size">10pt</xsl:attribute>
	<!-- Dimitri: Render list-of-fugures and list-of-tables numbers flush left. -->
    <!--xsl:attribute name="start-indent">1.25in</xsl:attribute-->
    <xsl:attribute name="start-indent">0in</xsl:attribute>
    <xsl:attribute name="float">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__lotf__title" use-attribute-sets="__lotf__content">
	<!-- Dimitri: Move list-of-fugures and list-of-tables titles to the left. -->
    <!--xsl:attribute name="margin-left">1.75in</xsl:attribute-->
    <xsl:attribute name="margin-left">0.25in</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__lotf__page-number">
    <xsl:attribute name="keep-together.within-line">always</xsl:attribute>
  </xsl:attribute-set>

</xsl:stylesheet>
