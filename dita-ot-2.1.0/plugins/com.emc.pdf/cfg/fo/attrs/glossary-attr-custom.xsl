<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rx="http://www.renderx.com/XSL/Extensions"
  version="2.0">

  <!-- 
  Revision History
  ================  
  Suite/EMC   SOW5          15-Feb-2012   font changes
  EMC         PDFGlossary    9-Jul-2013   Added customization for the PDF Glossary
  EMC         IB4           15-Apr-2014   #351 - Glossary and Index should be all caps in PDF output
  EMC		  IB4			16-May-2014	  #360 - page break in glossary definition
  -->

  <!-- Thomas Dill 2011-May-31: Start RSA template updates  -->
  <!-- ****************************************************************************** -->
  <xsl:attribute-set name="__glossary__label__rsa">
    <xsl:attribute name="margin-top">0pt</xsl:attribute>
    <xsl:attribute name="space-after">0pt</xsl:attribute>
    <xsl:attribute name="space-before">0in</xsl:attribute>
    <xsl:attribute name="padding-bottom">37pt</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">SansLFCaps</xsl:attribute>

    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <!--xsl:attribute name="color">
      <xsl:value-of select="$emc_blue"/>
    </xsl:attribute-->
    <xsl:attribute name="line-height">25pt</xsl:attribute>
    <!-- Nathan McKimpson 2013-June-11 Remove underline from glossary heading -->
    <xsl:attribute name="border-bottom">none</xsl:attribute>
    <!-- EMC 13-Aug-2013 Added logic to control the spacing of the first label, when the bridge topic content is present -->
    <xsl:attribute name="margin-bottom">
      <xsl:choose>
        <xsl:when test="*[1][not(contains(@class, 'glossentry/glossentry'))]">37pt</xsl:when>
        <xsl:otherwise>20pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <!-- EMC IB4 15-Apr-2014 #351 - Glossary and Index should be all caps in PDF output -->
    <xsl:attribute name="text-transform">uppercase</xsl:attribute>
  </xsl:attribute-set>
  <!-- Thomas Dill 2011-May-31: End RSA template updates  -->
  <!-- ****************************************************************************** -->

  <xsl:attribute-set name="__glossary__label">
    <xsl:attribute name="margin-top">0pt</xsl:attribute>
    <xsl:attribute name="space-after">0pt</xsl:attribute>
    <xsl:attribute name="space-before">0in</xsl:attribute>
    <xsl:attribute name="padding-bottom">37pt</xsl:attribute>
    <xsl:attribute name="space-after.optimum">0pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="font-family">SansLFCaps</xsl:attribute>
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the title -->
    <!-- ****************************************************************************** -->
    <!-- <xsl:attribute name="color" > -->
    <!-- <xsl:value-of select="$pantone_279"/> -->
    <!-- </xsl:attribute> -->
    <xsl:attribute name="color">black</xsl:attribute>
    <!-- ********************************************************************************* -->
    <xsl:attribute name="line-height">25pt</xsl:attribute>
    <!-- Nathan McKimpson 2013-June-11 Remove underline from glossary heading -->
    <xsl:attribute name="border-bottom">none</xsl:attribute>
    <!-- EMC 13-Aug-2013 Added logic to control the spacing of the first label, when the bridge topic content is present -->
    <xsl:attribute name="margin-bottom">
      <xsl:choose>
        <xsl:when test="*[1][not(contains(@class, 'glossentry/glossentry'))]">37pt</xsl:when>
        <xsl:otherwise>20pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <!-- EMC IB4 15-Apr-2014 #351 - Glossary and Index should be all caps in PDF output -->
    <xsl:attribute name="text-transform">uppercase</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__glossary__term">
    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="start-indent">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__glossary__def">
    <xsl:attribute name="margin-left">0in</xsl:attribute>

    <xsl:attribute name="font-weight">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'yes'">bold</xsl:when>
        <xsl:otherwise>normal</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">
      <xsl:choose>
        <xsl:when test="$addBoldWeight = 'no'">SansMediumLFRoman</xsl:when>
        <xsl:otherwise>SansLFRoman</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>

    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">5pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__glossary__entry">
    <xsl:attribute name="padding-bottom">5pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- EMC      PDFGlossary    9-Jul-2013   Added customization for the PDF Glossary -->
  <xsl:attribute-set name="__glossary__letter-group">
    <xsl:attribute name="padding">6pt</xsl:attribute>
    <xsl:attribute name="number-columns-spanned">2</xsl:attribute>
    <!-- EMC	IB4				15-Apr-2014	  #360 - page break in glossary definition -->
    <xsl:attribute name="keep-together.within-page">5</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__glossary__glossterm">
    <xsl:attribute name="padding">6pt</xsl:attribute>
    <xsl:attribute name="vertical-align">top</xsl:attribute>
    <xsl:attribute name="text-align">end</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__glossary__bold">
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__glossary__link">
    <xsl:attribute name="font-style">normal</xsl:attribute>
    <xsl:attribute name="color">blue</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__glossary__letter-block">
    <xsl:attribute name="keep-with-next.within-page">always</xsl:attribute>
  </xsl:attribute-set>
</xsl:stylesheet>
