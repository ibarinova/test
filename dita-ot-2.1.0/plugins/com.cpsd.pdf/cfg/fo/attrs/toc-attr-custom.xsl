<?xml version='1.0'?>

<!-- 
  Revision History
  ================
  Suite/EMC   SOW5    19-Jan-2012   font changes  
  Suite/EMC   SOW5    07-Feb-2012   changes to match FM  
  Suite/EMC   SOW5    15-Feb-2012   more font changes
  Suite/EMC   Nochap  07-Aug-2012   customize mini-toc for no-chap
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">

  <xsl:attribute-set name="__toc__empty__leader">
    <!--added by rs-->
    <xsl:attribute name="leader-pattern">use-content</xsl:attribute>
  </xsl:attribute-set>

  <!-- EMC		  IB4	  23-Apr-2014	Page numbers on TOC for Russian should be displayed in Tahoma -->
  <xsl:attribute-set name="toc.item.right">
    <xsl:attribute name="keep-together.within-line">always</xsl:attribute>
    <xsl:attribute name="margin-left">0.01in</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__toplevel_pagenum">
	<xsl:attribute name="keep-together.within-line">always</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__indent">
    <xsl:attribute name="margin-left">
      <xsl:variable name="leveltemp"><xsl:choose><xsl:when test="preceding::*[contains(@class,' bookmap/part ')]"><xsl:value-of select="count(ancestor::*[contains(@class, ' topic/topic ')]) -1 "/></xsl:when><xsl:otherwise><xsl:value-of select="count(ancestor::*[contains(@class, ' topic/topic ')])"/></xsl:otherwise></xsl:choose></xsl:variable>
      <xsl:variable name="level" >
        <xsl:choose>
		<xsl:when test="preceding::chapter[current()/@id=@id] and preceding::*[contains(@class,' bookmap/part ')]">-4.5</xsl:when>
		  <xsl:when test="$leveltemp = 1">-0</xsl:when>
          <xsl:when test="$leveltemp=-1">0</xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$leveltemp"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
	  <!-- Dimitri: Decrease TOC indent. -->
      <!--xsl:value-of select="concat(string( 2.375 + number($level) * 0.25), 'in')"/-->
	  <xsl:value-of select="concat(string(number($level)*0.1),'in')"/>
    </xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__page-number">
    <xsl:attribute name="start-indent">-<xsl:value-of select="$toc.text-indent"/></xsl:attribute>
    <xsl:attribute name="keep-together.within-line">auto</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__toc__heading">
    <!--Suite/EMC   SOW5  07-Feb-2012   updated width - ck-->
	<!-- Dimitri: Decrease title indent in TOCs with chapter numbers. -->
    <!--xsl:attribute name="width">2.375in</xsl:attribute-->
	<xsl:attribute name="width">0.9in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__toc__toplevel">
    <!--added by rs-->
    <!--xsl:attribute name="space-before">19pt</xsl:attribute-->
	<!-- Dimitri: Decrease space before chapter entries. -->
	<xsl:attribute name="space-before">10pt</xsl:attribute>
    <xsl:attribute name="space-after">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__toc__heading__block">
    <!--added by rs-->
    
    <!--Suite/EMC   SOW5  07-Feb-2012   updated start-indent - ck-->
	<!-- Dimitri: In the TOC, align "Figures" and "Tables" flush left. -->
    <!--xsl:attribute name="start-indent">1.25in</xsl:attribute-->
    <xsl:attribute name="start-indent">0in</xsl:attribute>
    
    <xsl:attribute name="text-align-last">left</xsl:attribute>
    <xsl:attribute name="space-before">19pt</xsl:attribute>
    <xsl:attribute name="space-after">4pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__topic__content">
    <xsl:attribute name="last-line-end-indent">0pt</xsl:attribute>
    <xsl:attribute name="end-indent">0pt</xsl:attribute>
    <xsl:attribute name="text-indent">0in</xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="keep-together.within-page">always</xsl:attribute>
    <xsl:attribute name="line-height">
      <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
	    <!-- Balaji Mani 1-Apr-2013: Process part and part in same level -->
      <xsl:choose>
        <xsl:when test="$level &lt;= 1">14pt</xsl:when>
	    <xsl:when test="$level = 2 and preceding::*[contains(@class,' bookmap/part ')]">14pt</xsl:when>		
        <xsl:otherwise>12pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
	<!-- Balaji Mani 1-Apr-2013: Changed the alignment -->    
    <xsl:attribute name="text-align-last">justify</xsl:attribute>
    <!-- Suite/EMC   SOW5  7-Feb-2012    updated size to match FM - ck -->
    <!-- Suite/EMC   SOW5  19-Jan-2012   updated size - rs -->
    <xsl:attribute name="font-size">
      <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
	   <!-- Balaji Mani 1-Apr-2013: Process part and part in same level -->
      <xsl:choose>
        <xsl:when test="$level &lt;= 1">11pt</xsl:when>
		<xsl:when test="$level = 2 and preceding::*[contains(@class,' bookmap/part ')]">11pt</xsl:when>	
        <xsl:otherwise>10pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <!-- Suite/EMC   SOW5  7-Feb-2012    updated fonts to match FM - ck -->
    <!-- Suite/EMC   SOW5  19-Jan-2012   updated font - rs -->
	 <!-- Balaji Mani 1-Apr-2013: SansMediumLFRoman will not allow bold so removed it -->
    <xsl:attribute name="font-family">
	      <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
  	   <!-- Balaji Mani 1-Apr-2013: Process part and part in same level -->
  		<xsl:choose>
    		<xsl:when test="$level &lt;= 1 and $addBoldWeight='no'">SansMediumLFRoman</xsl:when>
    		<xsl:when test="$level = 2 and preceding::*[contains(@class,' bookmap/part ')] and $addBoldWeight='no'">SansMediumLFRoman</xsl:when>
  		<xsl:otherwise>SansLFRoman</xsl:otherwise>
		</xsl:choose>
	  </xsl:attribute>
      <!-- Thomas Dill 2011-June-13: Set this to black due to template change   -->
      <!-- ******************************************************************** -->          
      <xsl:attribute name="color" >black</xsl:attribute>      
      <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/> -->
      <!-- <xsl:choose> -->
        <!-- <xsl:when test="$level &lt;= 1"> -->
          <!-- <xsl:value-of select="$pantone_279"/> -->
        <!-- </xsl:when> -->
        <!-- <xsl:otherwise>black</xsl:otherwise> -->
      <!-- </xsl:choose> -->
    <!-- </xsl:attribute> -->

    <!-- Suite/EMC   SOW5  7-Feb-2012    updated weight to match FM - ck -->
    <!-- Suite/EMC   SOW5  19-Jan-2012   updated weight - rs -->
    <xsl:attribute name="font-weight">
      <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
		<xsl:choose>
		<xsl:when test="$level &lt;= 1 and $addBoldWeight='yes'">bold</xsl:when>
		<xsl:when test="$level = 2 and preceding::*[contains(@class,' bookmap/part ')] and $addBoldWeight='yes'">bold</xsl:when>
		<xsl:otherwise>normal</xsl:otherwise>
		</xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__part__content" use-attribute-sets="__toc__topic__content">
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__chapter__content" use-attribute-sets="__toc__topic__content">
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__appendix__content" use-attribute-sets="__toc__topic__content">
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__topic__content__booklist" use-attribute-sets="__toc__topic__content">
    <xsl:attribute name="font-size">11pt</xsl:attribute>
    <xsl:attribute name="font-weight">bold</xsl:attribute>
  </xsl:attribute-set>
  
  <xsl:attribute-set name="__toc__link">
    <xsl:attribute name="line-height">
      <xsl:variable name="level" select="count(ancestor-or-self::*[contains(@class, ' topic/topic ')])"/>
      <xsl:choose>
        <xsl:when test="$level &lt;= 1">14pt</xsl:when>
        <xsl:when test="$level = 2 and preceding::*[contains(@class,' bookmap/part ')]">14pt</xsl:when>		
        <xsl:otherwise>12pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>
  
    <!-- Thomas Dill 2011-May-31: Start conditional processing for RSA template updates  -->
    <!-- ****************************************************************************** -->          
    <xsl:attribute-set name="__toc__header__rsa">
      <xsl:attribute name="font-size">24pt</xsl:attribute>
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="padding-top">0pc</xsl:attribute>
      <xsl:attribute name="font-family">SansLFCaps</xsl:attribute>
      <!-- Thomas Dill 2011-June-13: Set this to black due to template change   -->
      <!-- ******************************************************************** -->
      <xsl:attribute name="color" >black</xsl:attribute>
      <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:value-of select="$rsa_red"/> -->
      <!-- </xsl:attribute> -->
      <!-- Suite/EMC   SOW5  7-Feb-2012 START - ck -->
      <xsl:attribute name="border-bottom">none</xsl:attribute>
      <xsl:attribute name="text-transform">uppercase</xsl:attribute>
      <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
      <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
      <xsl:attribute name="margin-top">0.625in</xsl:attribute>
      <xsl:attribute name="margin-left">0.625in</xsl:attribute>
      <!-- Suite/EMC   SOW5  7-Feb-2012 END - ck -->
    </xsl:attribute-set>
    <!-- Thomas Dill 2011-May-31: end conditional processing for RSA template updates   -->
    <!-- ****************************************************************************** -->          

  
  <xsl:attribute-set name="__toc__header">
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="padding-top">0pc</xsl:attribute>
    <xsl:attribute name="font-family">SansLFCaps</xsl:attribute>
	<!-- Dimitri: Render the "CONTENTS," "FIGURES," and "TABLES" headings in the Dell blue color. -->
    <!--xsl:attribute name="color" >black</xsl:attribute-->
	<xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
    <xsl:attribute name="border-bottom">none</xsl:attribute>
	<!-- Dimitri: Do not render the "CONTENTS," "FIGURES," and "TABLES" headings in uppercase. -->
    <!--xsl:attribute name="text-transform">uppercase</xsl:attribute-->
    <xsl:attribute name="padding-bottom">0pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
    <xsl:attribute name="margin-top">0.625in</xsl:attribute>
	<!-- Dimitri: Decrease TOC header indent. -->
    <!--xsl:attribute name="margin-left">0.625in</xsl:attribute-->
	<xsl:attribute name="margin-left">0.5in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__toc__mini">
        <xsl:attribute name="font-size">
          <xsl:value-of select="$default-font-size"/>
        </xsl:attribute>
   
        <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
        <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    
        <xsl:attribute name="end-indent">5pt</xsl:attribute>
        <xsl:attribute name="margin-left">
          <!--  Suite/EMC   Nochap  07-Aug-2012 - customize mini-toc for no-chap - Start -  AW -->
          <xsl:choose>
            <xsl:when test="$NOCHAP = 'yes'">0pt</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$side-col-width"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:attribute name="line-height">12pt</xsl:attribute>
      </xsl:attribute-set>

    <xsl:attribute-set name="__toc__mini__list">
      <xsl:attribute name="provisional-distance-between-starts">1.5pc</xsl:attribute>
      <xsl:attribute name="provisional-label-separation">1pc</xsl:attribute>
      <xsl:attribute name="space-after.optimum">
        <xsl:choose>
          <xsl:when test="$NOCHAP = 'yes'">0pt</xsl:when>
          <xsl:otherwise>9pt</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="space-before.optimum">
        <xsl:choose>
          <xsl:when test="$NOCHAP = 'yes'">0pt</xsl:when>
          <xsl:otherwise>9pt</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:attribute-set>
  <!--  Suite/EMC   Nochap  07-Aug-2012 - customize mini-toc for no-chap - End -  AW -->
  

</xsl:stylesheet>