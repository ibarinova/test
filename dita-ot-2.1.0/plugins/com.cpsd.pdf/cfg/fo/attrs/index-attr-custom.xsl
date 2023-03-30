<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="2.0">

  <!-- 
  Revision History
  ================  
  Suite/EMC   SOW5  15-Feb-2012   font changes
  EMC         IB4   15-Apr-2014   #351 - Glossary and Index should be all caps in PDF output
  -->
  
    <!-- Thomas Dill 2011-May-31: Start for RSA template updates  -->
    <!-- ****************************************************************************** --> 
    <!-- Suite Nov-2011: rsa attribute sets should inherit from default ones to include ootb attributes -->
    <xsl:attribute-set name="__index__label__rsa" use-attribute-sets="__index__label">
        <xsl:attribute name="margin-top">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
        <xsl:attribute name="space-before">0in</xsl:attribute>
        <xsl:attribute name="padding-bottom">37pt</xsl:attribute>
        <xsl:attribute name="font-size">24pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the index -->
        <!-- ****************************************************************************** -->
        <!-- <xsl:attribute name="color" > -->

          <!-- <xsl:value-of select="$rsa_red"/> -->
        <!-- </xsl:attribute> -->
        <xsl:attribute name="color">black</xsl:attribute>
	<!-- ********************************************************************************* -->
      <xsl:attribute name="font-family">SansLFCaps</xsl:attribute>
      <xsl:attribute name="line-height">25pt</xsl:attribute>
      <!-- Nathan McKimpson 2013-June-11 Remove underline from index heading -->
      <xsl:attribute name="border-bottom">none</xsl:attribute>
      <xsl:attribute name="margin-bottom">37pt</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__index__letter-group__rsa">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0in</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>

      <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
      <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
      
        <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the index -->
        <!-- ****************************************************************************** -->
        <!-- <xsl:attribute name="color" > -->

          <!-- <xsl:value-of select="$rsa_red"/> -->
        <!-- </xsl:attribute> -->
        <xsl:attribute name="color">black</xsl:attribute>
	<!-- ********************************************************************************* -->
      <xsl:attribute name="line-height">14pt</xsl:attribute>
      <xsl:attribute name="space-before">0pt</xsl:attribute>
    </xsl:attribute-set>
    <!-- Thomas Dill 2011-May-31: End for RSA template updates  -->
    <!-- ****************************************************************************** -->  


    <xsl:attribute-set name="__index__label">
        <xsl:attribute name="margin-top">0pt</xsl:attribute>
        <xsl:attribute name="space-after">0pt</xsl:attribute>
        <xsl:attribute name="space-before">0in</xsl:attribute>
        <xsl:attribute name="padding-bottom">37pt</xsl:attribute>
        <xsl:attribute name="font-size">24pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the index -->
        <!-- ****************************************************************************** -->
        <!-- <xsl:attribute name="color" > -->
          <!-- <xsl:value-of select="$pantone_279"/> -->
        <!-- </xsl:attribute> -->
        <xsl:attribute name="color">black</xsl:attribute>
	<!-- ********************************************************************************* -->
      <xsl:attribute name="font-family">SansLFCaps</xsl:attribute>
      <xsl:attribute name="line-height">25pt</xsl:attribute>
      <!-- Nathan McKimpson 2013-June-11 Remove underline from index heading -->
      <xsl:attribute name="border-bottom">none</xsl:attribute>
      <xsl:attribute name="margin-bottom">37pt</xsl:attribute>
      <!-- EMC  IB4  15-Apr-2014   #351 - Glossary and Index should be all caps in PDF output -->
      <xsl:attribute name="text-transform">uppercase</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__index__letter-group">
        <xsl:attribute name="font-size">12pt</xsl:attribute>
        <xsl:attribute name="font-weight">normal</xsl:attribute>
        <xsl:attribute name="space-after.optimum">0in</xsl:attribute>
        <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>

      <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
      <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
      
      <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the index -->
      <!-- ****************************************************************************** -->
      <!-- <xsl:attribute name="color" > -->
        <!-- <xsl:value-of select="$pantone_279"/> -->
      <!-- </xsl:attribute> -->
      <xsl:attribute name="color">black</xsl:attribute>
      <!-- ********************************************************************************* -->
      <xsl:attribute name="line-height">14pt</xsl:attribute>
      <xsl:attribute name="space-before">0pt</xsl:attribute>
    </xsl:attribute-set>
  
    <xsl:attribute-set name="__index__page__link" use-attribute-sets="common.link">
      <xsl:attribute name="color">black</xsl:attribute>
      <xsl:attribute name="page-number-treatment">link</xsl:attribute>
    </xsl:attribute-set>
  
    <!-- Dana/Natasha ib2 2013-06-28 fixed indent -->
    <xsl:attribute-set name="index.entry">
      <xsl:attribute name="space-after.optimum">14pt</xsl:attribute>
      <xsl:attribute name="space-after.minimum">14pt</xsl:attribute>
      <xsl:attribute name="font-size">9pt</xsl:attribute>
      <xsl:attribute name="margin-left">0.25in</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="index-indents">
        <xsl:attribute name="end-indent">5pt</xsl:attribute>
        <xsl:attribute name="last-line-end-indent">0pt</xsl:attribute>
        <xsl:attribute name="margin-left">0.5in</xsl:attribute>
        <xsl:attribute name="text-indent">-0.5in</xsl:attribute>
        <xsl:attribute name="font-size">9pt</xsl:attribute>
    </xsl:attribute-set>

  <xsl:attribute-set name="index-no-indents">
    <!--added by rs-->
    <xsl:attribute name="font-size">9pt</xsl:attribute>
    <xsl:attribute name="start-indent">0in</xsl:attribute>
    <xsl:attribute name="keep-with-next">always</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="index.entry__content">
      <xsl:attribute name="margin-left">0</xsl:attribute>
  </xsl:attribute-set>

</xsl:stylesheet>