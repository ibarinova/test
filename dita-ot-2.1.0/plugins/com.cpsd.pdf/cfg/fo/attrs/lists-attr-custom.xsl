<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">

  <xsl:attribute-set name="minitoc__ul.li__content">
    <xsl:attribute name="text-align-last">justify</xsl:attribute>
    <xsl:attribute name="line-height">12pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="ul.li__label__content">
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="font-family">Wingdings</xsl:attribute>
    <xsl:attribute name="font-size">6pt</xsl:attribute>
    <xsl:attribute name="vertical-align">middle</xsl:attribute>
    <xsl:attribute name="line-height">12pt</xsl:attribute>
  </xsl:attribute-set>

	<!-- Dimitri: Indent unordered lists. -->
  <!--xsl:attribute-set name="ul" use-attribute-sets="common.block">
    <xsl:attribute name="provisional-distance-between-starts">0.23in</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">1mm</xsl:attribute>
    <xsl:attribute name="space-after.optimum">5pt</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  </xsl:attribute-set-->
    <xsl:attribute-set name="ul" use-attribute-sets="common.block">
        <xsl:attribute name="provisional-distance-between-starts">.25in</xsl:attribute>
        <xsl:attribute name="provisional-label-separation">1mm</xsl:attribute>
        <!--xsl:attribute name="font-family">Arial</xsl:attribute>
        <xsl:attribute name="font-size">
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ')]">9pt</xsl:when>
                <xsl:otherwise>10pt</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute-->
        <xsl:attribute name="padding-left">
            <xsl:variable name="ulLevel" select="count(ancestor::*[contains(@class, ' topic/ul ')])"/>
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ')]">0in</xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' task/step ')]"/>
                <xsl:when test="$ulLevel &gt; 0"/>
                <xsl:otherwise>.25in</xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="margin-left">0pt</xsl:attribute>
        <xsl:attribute name="line-height">12pt</xsl:attribute>
    </xsl:attribute-set>

  <xsl:attribute-set name="ul.li">
    <xsl:attribute name="space-after.optimum">5pt</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="minitoc__ul.li">
    <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="ol" use-attribute-sets="common.block">
    <xsl:attribute name="provisional-distance-between-starts">10mm</xsl:attribute>
    <xsl:attribute name="provisional-label-separation">3mm</xsl:attribute>
    <xsl:attribute name="space-after.optimum">5pt</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="ol.li">
    <xsl:attribute name="space-after.optimum">5pt</xsl:attribute>
    <xsl:attribute name="space-before.optimum">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="ol.li__label__content">
    <xsl:attribute name="text-align">right</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
  </xsl:attribute-set>

</xsl:stylesheet>