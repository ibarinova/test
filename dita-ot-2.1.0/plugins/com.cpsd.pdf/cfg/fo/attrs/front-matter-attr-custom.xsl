<?xml version='1.0'?>

<!--
  Revision History
  ================
  Comtech/EMC AdvTraining 24-Jan-2013 Add barcode39 attribute set.
  Suite/EMC   SOW5    19-Jan-2012   font changes
  Suite/EMC   SOW5    24-Apr-2012   font changes
  Suite/EMC   Nochap  21-Aug-2012   nochap front cover attribute sets
  Suite/EMC   Nochap  21-Aug-2012   Add conditional processing for front cover


-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">

  <xsl:attribute-set name="barcode39">
    <xsl:attribute name="font-family">Barcode39</xsl:attribute>
    <xsl:attribute name="font-size">24pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="barcode39_nochap">
    <xsl:attribute name="font-family">Barcode39</xsl:attribute>
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <xsl:attribute name="space-after">18pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter">
    <xsl:attribute name="text-align">left</xsl:attribute>
    <xsl:attribute name="margin-top">0in</xsl:attribute>
    <xsl:attribute name="margin-left">0in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="frontpage-image.block">
    <!--added by rs-->
    <xsl:attribute name="position">absolute</xsl:attribute>
    <xsl:attribute name="top">
      <!-- Suite/EMC   Nochap  21-Aug-2012 - Add conditional processing for front cover - Start - AW -->
      <xsl:choose>
        <xsl:when test="$NOCHAP = 'yes'">
          -<xsl:value-of select="$page-margin-top"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$image-margin-top-frontpage"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="left">
      <xsl:choose>
		<!-- Dimitri: Fix the nochap image indent on the title page. -->
        <!--xsl:when test="$NOCHAP = 'yes'">-0.63in</xsl:when-->
		<xsl:when test="$NOCHAP = 'yes'">-0.5in</xsl:when>
        <xsl:otherwise>
      -<xsl:value-of select="$page-margin-inside-frontpage"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Suite/EMC   Nochap  21-Aug-2012 - Add conditional processing for front cover - End - AW -->

    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__title">
    <xsl:attribute name="margin-top">0in</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">27pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">31pt</xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
    <xsl:attribute name="color">
      <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Use Dell Blue color for title for DellEMC and Dell Mozy brands - IB-->
      <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Use Dell Blue color for all brands except RSA- IB-->
      <xsl:value-of select="$dell_blue"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- Thomas Dill 2011-May_26: Added an RSA title attribute set to implement rsa_red   -->
  <!-- ******************************************************************************** -->
  <xsl:attribute-set name="__frontmatter__title__rsa">
    <xsl:attribute name="margin-top">0in</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">27pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">31pt</xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$rsa_red"/>
    </xsl:attribute>
  </xsl:attribute-set>
  <!-- Thomas Dill 2011-May-26: End added RSA title attribute set to implement rsa_red  -->
  <!-- ******************************************************************************** -->

  <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add attr-set for SolutionsPDF <titlealt> on frontmatter  - IB-->
  <xsl:attribute-set name="__frontmatter__titlealt">
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">21pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">24pt</xsl:attribute>
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="frontpage-image">
    <xsl:attribute name="content-width">
      <xsl:value-of select="$page-width"/>
    </xsl:attribute>
    <xsl:attribute name="content-height">
      <xsl:value-of select="$page-height"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__version">
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">11pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">11pt</xsl:attribute>
    <xsl:attribute name="space-after">36pt</xsl:attribute>
    <xsl:attribute name="color">
      <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Use Dell Blue color for title for DellEMC and Dell Mozy brands - IB-->
      <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Use Dell Blue color for title for all brands except RSA - IB-->
      <xsl:value-of select="$dell_blue"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- Thomas Dill 2011-May_26: Added an RSA version attribute set to implement rsa_red -->
  <!-- ******************************************************************************** -->
    <xsl:attribute-set name="__frontmatter__version__rsa">
      <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
      <xsl:attribute name="font-size">11pt</xsl:attribute>
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="line-height">11pt</xsl:attribute>
      <xsl:attribute name="space-after">36pt</xsl:attribute>
      <xsl:attribute name="color">
        <xsl:value-of select="$rsa_red"/>
      </xsl:attribute>
  </xsl:attribute-set>
  <!-- Thomas Dill 2011-May-26: End added RSA version attribute set to implement rsa_red -->
  <!-- ******************************************************************************** -->

  <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add specific attr-sets for Solutions PDF frontmatter page STARTS HERE   - IB-->
  <xsl:attribute-set name="__frontmatter__version__solutions" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">8pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__date" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__bookpartno" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__edition" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__author" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__solutions_shortdesc" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- IA   Tridion upgrade    Oct-2018   Add shortdesc on cover page STARTS HERE. - IB-->
  <xsl:attribute-set name="__frontmatter__abstract_container">
    <xsl:attribute name="margin-left">0.25in</xsl:attribute>
    <xsl:attribute name="margin-right">0.25in</xsl:attribute>
    <xsl:attribute name="margin-top">16pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">16pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__abstrac_title" use-attribute-sets="__frontmatter__version">
    <!--Add 'Abstract' title above shortdesc -->
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="font-size">12pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__shortdesc" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>
  <!-- IA   Tridion upgrade    Oct-2018   Add shortdesc on cover page ENDS HERE. - IB-->

  <xsl:attribute-set name="__frontmatter__solutions_abstrac_title" use-attribute-sets="__frontmatter__version">
    <xsl:attribute name="space-after">8pt</xsl:attribute>
    <xsl:attribute name="font-size">12pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__solutions_main_container">
    <xsl:attribute name="position">absolute</xsl:attribute>
    <xsl:attribute name="top">0in</xsl:attribute>
    <xsl:attribute name="left">0in</xsl:attribute>
    <xsl:attribute name="right">0in</xsl:attribute>
    <xsl:attribute name="bottom">6.5in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__solutions_category_container">
    <xsl:attribute name="position">absolute</xsl:attribute>
    <xsl:attribute name="top">4.61in</xsl:attribute>
    <xsl:attribute name="left">0in</xsl:attribute>
    <xsl:attribute name="right">0in</xsl:attribute>
    <xsl:attribute name="bottom">5.2in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__solutions_abstract_container">
    <xsl:attribute name="position">absolute</xsl:attribute>
    <xsl:attribute name="top">5.31in</xsl:attribute>
    <xsl:attribute name="left">0.7in</xsl:attribute>
    <xsl:attribute name="right">0.7in</xsl:attribute>
    <xsl:attribute name="bottom">3.5in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__solutions_author_container">
    <xsl:attribute name="position">absolute</xsl:attribute>
    <xsl:attribute name="top">7.11in</xsl:attribute>
    <xsl:attribute name="left">0in</xsl:attribute>
    <xsl:attribute name="right">0in</xsl:attribute>
    <xsl:attribute name="bottom">2.7in</xsl:attribute>
  </xsl:attribute-set>
  <!-- Intelliarts Consulting   SolutionsPDF    10-Mar-2017   Add specific attr-sets for Solutions PDF frontmatter page ENDS HERE   - IB-->

  <xsl:attribute-set name="__frontmatter__category">
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">21pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">24pt</xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- IA   Tridion upgrade    Oct-2018   Add processing of <booktitlealt> on cover page instead of <category>. - IB-->
  <xsl:attribute-set name="__frontmatter__booktitlealt">
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">21pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">24pt</xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__solutions__category" use-attribute-sets="__frontmatter__category">
    <xsl:attribute name="font-size">18pt</xsl:attribute>
    <xsl:attribute name="line-height">20pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__5">
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">11pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">14pt</xsl:attribute>
    <xsl:attribute name="space-after">4pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="inside.cover">
    <!--added by rs-->
    <!-- Suite/EMC   SOW5  19-Jan-2012   updated font family - rs -->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">7.5pt</xsl:attribute>
    <xsl:attribute name="break-before">page</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="inside.cover.p">
    <!--added by rs-->
    <xsl:attribute name="line-height">11pt</xsl:attribute>
    <xsl:attribute name="space-after">7.5pt</xsl:attribute>
  </xsl:attribute-set>
  <!-- Suite/EMC   Nochap  21-Aug-2012  nochap front cover attribute sets - Start - AW -->
  <xsl:attribute-set name="__frontmatter__category__nochap">
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">21pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">24pt</xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
    <xsl:attribute name="margin-top">-20pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">100pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- IA   Tridion upgrade    Oct-2018   Add processing of <booktitlealt> on cover page instead of <category>. - IB-->
  <xsl:attribute-set name="__frontmatter__booktitlealt__nochap">
    <xsl:attribute name="margin-top">0pc</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">21pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">24pt</xsl:attribute>
    <xsl:attribute name="space-after">5pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
    <xsl:attribute name="margin-top">-20pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">100pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__category__nochap__rsa" use-attribute-sets="__frontmatter__category__nochap">
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <!-- IA   Tridion upgrade    Oct-2018   Add processing of <booktitlealt> on cover page instead of <category>. - IB-->
  <xsl:attribute-set name="__frontmatter__booktitlealt__nochap__rsa" use-attribute-sets="__frontmatter__booktitlealt__nochap">
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__title__nochap_common">
      <xsl:attribute name="margin-top">0pc</xsl:attribute>
      <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
      <xsl:attribute name="font-size">18pt</xsl:attribute>
      <xsl:attribute name="font-weight">normal</xsl:attribute>
      <xsl:attribute name="line-height">24pt</xsl:attribute>
      <xsl:attribute name="space-after">5pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__title__nochap" use-attribute-sets="__frontmatter__title__nochap_common">
      <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__prodname__nochap" use-attribute-sets="__frontmatter__title__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$dell_blue"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__prodname__nochap__rsa" use-attribute-sets="__frontmatter__title__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$rsa_red"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__series__nochap" use-attribute-sets="__frontmatter__title__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$dell_blue"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__series__nochap__rsa" use-attribute-sets="__frontmatter__title__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$rsa_red"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__text__nochap_common">
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">11pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">11pt</xsl:attribute>
    <xsl:attribute name="space-after">3pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__version__nochap" use-attribute-sets="__frontmatter__text__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$dell_blue"/>
    </xsl:attribute>
    <xsl:attribute name="space-after">13pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__version__nochap__rsa" use-attribute-sets="__frontmatter__text__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$rsa_red"/>
    </xsl:attribute>
    <xsl:attribute name="space-after">13pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__edition__nochap" use-attribute-sets="__frontmatter__text__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__text__nochap" use-attribute-sets="__frontmatter__text__nochap_common">
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__frontmatter__published__nochap">
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">11pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">11pt</xsl:attribute>
    <xsl:attribute name="space-after">27pt</xsl:attribute>
    <xsl:attribute name="color">
      <xsl:value-of select="$emc_gray"/>
    </xsl:attribute>
  </xsl:attribute-set>
  <!-- Dana IB2 Fix Issue #279: Support URL does not render as a blue link on the PDF copyright page-->
  <xsl:attribute-set name="xref">
    <xsl:attribute name="color">blue</xsl:attribute>
    <xsl:attribute name="font-style">normal</xsl:attribute>
  </xsl:attribute-set>
  <!-- Suite/EMC   Nochap  21-Aug-2012  nochap front cover attribute sets - End - AW -->

  <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL Regulatory Model / Type values STARTS HERE- IB-->
  <xsl:attribute-set name="__frontmatter__regulatory_container">
        <xsl:attribute name="position">fixed</xsl:attribute>
        <xsl:attribute name="top">10.4in</xsl:attribute>
        <xsl:attribute name="left"><xsl:value-of select="$page-margin-inside"/></xsl:attribute>
        <xsl:attribute name="right">0in</xsl:attribute>
        <xsl:attribute name="bottom">0in</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__frontmatter__regulatory_data">
        <xsl:attribute name="color">white</xsl:attribute>
    </xsl:attribute-set>
  <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL Regulatory Model / Type values ENDS HERE- IB-->

  <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property STARTS HERE. - IB-->
  <xsl:attribute-set name="frontmatter__dellrestricted_container">
    <!--Add container at the bottom of cover page-->
    <xsl:attribute name="position">fixed</xsl:attribute>
    <xsl:attribute name="top">9in</xsl:attribute>
    <xsl:attribute name="left"><xsl:value-of select="$page-margin-inside"/></xsl:attribute>
    <xsl:attribute name="right"><xsl:value-of select="$page-margin-inside"/></xsl:attribute>
    <xsl:attribute name="bottom">1.7in</xsl:attribute>
    <xsl:attribute name="border">1pt solid black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="frontmatter__dellrestricted">
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when test="//bookmap[contains(lower-case(@xml:lang),'ru')] and $DECR">9pt</xsl:when>
        <xsl:otherwise>12pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="line-height">16pt</xsl:attribute>
    <xsl:attribute name="margin-top">4pt</xsl:attribute>
    <xsl:attribute name="start-indent">20pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property ENDS HERE. - IB-->

</xsl:stylesheet>