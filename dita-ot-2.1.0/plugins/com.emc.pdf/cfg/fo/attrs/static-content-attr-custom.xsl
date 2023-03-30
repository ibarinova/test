<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  version="2.0">

  <!--
    Revision History
    ================
    Suite/EMC   SOW5  19-Jan-2012   font/spacing changes
    Suite/EMC   SOW5  07-Feb-2012   Updated footer and header format
    Suite/EMC   SOW5  15-Feb-2012   font changes
    Suite/EMC   SOW5  05-Mar-2012   update footer location
    Natasha IB2 8-Jul-21013 Special formatting for EMC Confidential string for RU
    IA/EMC  PDF-Insert 20-feb-2014  Modified Confidential watermark formatting. IB
  -->

  <!-- Thomas Dill 2011-May-31: Start for RSA template updates  -->
  <!-- ****************************************************************************** -->
    <!--headers and footers-->
<!--
  &lt;!&ndash; this attr-sets are needless. They are not used in transformation. &ndash;&gt;
    <xsl:attribute-set name="__header__footer-small__rsa">

      &lt;!&ndash;Suite/EMC   SOW5  15-Feb-2012   font family - ck&ndash;&gt;
      <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>

      <xsl:attribute name="font-size">8pt</xsl:attribute>
      <xsl:attribute name="color">
        <xsl:choose>
          <xsl:when test="$BRAND-IS-EMC">
            <xsl:value-of select="$emc_blue"/>
          </xsl:when>
          <xsl:otherwise>
            &lt;!&ndash; Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Use Dell Blue color for DellEMC and Dell Mozy brands - IB&ndash;&gt;
            <xsl:value-of select="$dell_blue"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__header__footer-large__rsa">

      &lt;!&ndash;Suite/EMC   SOW5  15-Feb-2012   font family - ck&ndash;&gt;
      <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>

      <xsl:attribute name="font-size">8.5pt</xsl:attribute>
      <xsl:attribute name="color">
        <xsl:value-of select="$rsa_red"/>
      </xsl:attribute>
    </xsl:attribute-set>

-->
    <xsl:attribute-set name="__header__footer-large-italic__rsa">

      <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
      <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>

      <xsl:attribute name="font-size">8.5pt</xsl:attribute>
      <xsl:attribute name="color">
        <xsl:value-of select="$rsa_red"/>
      </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__header__footer-pagenum__rsa">
      <xsl:attribute name="font-size">8pt</xsl:attribute>
      <xsl:attribute name="color">
        <xsl:value-of select="$rsa_red"/>
      </xsl:attribute>
    </xsl:attribute-set>

  <!--headers and footers-->
  <xsl:attribute-set name="__header__footer-small">

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>

    <xsl:attribute name="font-size">8pt</xsl:attribute>
    <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the chapt -->
    <!-- ****************************************************************************** -->
    <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:value-of select="$pantone_279"/> -->
    <!-- </xsl:attribute> -->
    <xsl:attribute name="color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__header__footer-large">

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>

    <xsl:attribute name="font-size">8.5pt</xsl:attribute>
    <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the chapt -->
    <!-- ****************************************************************************** -->
    <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:value-of select="$pantone_279"/> -->
    <!-- </xsl:attribute> -->
    <xsl:attribute name="color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__header__footer-large-italic">

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>

    <xsl:attribute name="font-size">8.5pt</xsl:attribute>
    <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the chapt -->
    <!-- ****************************************************************************** -->
    <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:value-of select="$pantone_279"/> -->
    <!-- </xsl:attribute> -->
    <xsl:attribute name="color">black</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__header__footer-pagenum">
    <xsl:attribute name="font-size">8pt</xsl:attribute>
    <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the chapt -->
    <!-- ****************************************************************************** -->
    <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:value-of select="$pantone_279"/> -->
    <!-- </xsl:attribute> -->
    <xsl:attribute name="color">black</xsl:attribute>

  </xsl:attribute-set>

  <xsl:attribute-set name="__body__odd__footer__heading" use-attribute-sets="__header__footer-large-italic">
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__even__footer__heading" use-attribute-sets="__header__footer-large-italic">
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__even__footer__pagenum" use-attribute-sets="__header__footer-pagenum">
    <xsl:attribute name="font-weight">normal</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__odd__footer__pagenum" use-attribute-sets="__header__footer-pagenum">
    <xsl:attribute name="font-weight">normal</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__odd__header__heading" use-attribute-sets="__header__footer-small">
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__even__header__heading" use-attribute-sets="__header__footer-small">
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__first__footer__heading" use-attribute-sets="__header__footer-large-italic">
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__first__footer__pagenum" use-attribute-sets="__header__footer-pagenum">
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__odd__footer">
    <xsl:attribute name="text-align">right</xsl:attribute>
    <!-- Suite/EMC   SOW5  07-Feb-2012   Updated measurements - ck -->
    <xsl:attribute name="margin-right">
      <xsl:value-of select="$page-margin-outside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-left">
      <xsl:value-of select="$page-margin-inside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-top">0.125in</xsl:attribute>
    <!--<xsl:attribute name="margin-bottom">0.375in</xsl:attribute>-->
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__even__footer">
    <!-- Suite/EMC   SOW5  07-Feb-2012   Updated measurements - ck -->
    <xsl:attribute name="margin-right">
      <xsl:value-of select="$page-margin-inside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-left">
      <xsl:value-of select="$page-margin-outside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-top">0.125in</xsl:attribute>
    <!--<xsl:attribute name="margin-bottom">0.375in</xsl:attribute>-->
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__odd__header">
    <!-- Suite/EMC   SOW5  07-Feb-2012   Updated measurements - ck -->
    <xsl:attribute name="text-align">right</xsl:attribute>
    <xsl:attribute name="margin-right">
      <xsl:value-of select="$page-margin-outside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-top">0.5in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__even__header">
    <!-- Suite/EMC   SOW5  07-Feb-2012   Updated measurements - ck -->
    <xsl:attribute name="margin-left">
      <xsl:value-of select="$page-margin-inside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-top">0.5in</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__draft__header">
    <xsl:attribute name="width">100%</xsl:attribute>
    <xsl:attribute name="text-align">center</xsl:attribute>
    <!-- Suite/EMC   SOW5  07-Feb-2012   Updated draft format - ck -->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="margin-top">0.2in</xsl:attribute>
    <xsl:attribute name="line-height">100%</xsl:attribute>
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <!--<xsl:attribute name="font-weight">bold</xsl:attribute>-->
    <xsl:attribute name="color">
      <xsl:choose>
        <xsl:when test="$BRAND-IS-RSA">
          <xsl:value-of select="$rsa_red"/>
        </xsl:when>
<!--
        <xsl:when test="$BRAND-IS-EMC">
          <xsl:value-of select="$emc_blue"/>
        </xsl:when>
-->
        <xsl:otherwise>
          <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Use Dell Blue color for DRAFT/BETA block for DellEMC and Dell Mozy brands - IB-->
          <!-- Intelliarts Consulting   DellEMC Rebranding    17-Oct-2016   Use Dell Blue color for DRAFT/BETA block for all brands except RSA- IB-->
          <xsl:value-of select="$dell_blue"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

    <xsl:attribute-set name="__body__confidential__header_odd" use-attribute-sets="__body__confidential__header_common">
        <!-- Intelliarts Consulting/EMC PDF-Insert 20-feb-2014 Specific @text-align for Confidential watermark on odd page. IB-->
        <xsl:attribute name="text-align">right</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__body__confidential__header_even" use-attribute-sets="__body__confidential__header_common">
        <!-- Intelliarts Consulting/EMC PDF-Insert 20-feb-2014 Specific @text-align for Confidential watermark on even page. IB-->
        <xsl:attribute name="text-align">left</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__body__confidential__header_common">
        <!-- Intelliarts Consulting/EMC PDF-Insert 20-feb-2014 A set of common attributes for Confidential watermark on odd and even pages. IB-->
        <xsl:attribute name="margin-top">0.2in</xsl:attribute>
        <xsl:attribute name="margin-left">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
        <xsl:attribute name="margin-right">
            <xsl:value-of select="$page-margin-inside"/>
        </xsl:attribute>
        <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
        <xsl:attribute name="font-size">14pt</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
        <xsl:attribute name="text-transform">uppercase</xsl:attribute>
        <xsl:attribute name="width">100%</xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__body__confidential__header_RU_odd" use-attribute-sets="__body__confidential__header_RU_common">
        <!-- Intelliarts Consulting/EMC PDF-Insert 20-feb-2014 Specific attributes for Russian Confidential watermark on odd page. IB-->
        <xsl:attribute name="text-align">right</xsl:attribute>
        <xsl:attribute name="margin-left">6in</xsl:attribute>
        <xsl:attribute name="margin-right">
            <xsl:value-of select="$page-margin-outside"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__body__confidential__header_RU_even" use-attribute-sets="__body__confidential__header_RU_common">
        <!-- Intelliarts Consulting/EMC PDF-Insert 20-feb-2014 Specific attributes for Russian Confidential watermark on even page. IB-->
        <xsl:attribute name="text-align">left</xsl:attribute>
        <xsl:attribute name="margin-right">6in</xsl:attribute>
        <xsl:attribute name="margin-left">
            <xsl:value-of select="$page-margin-inside"/>
        </xsl:attribute>
    </xsl:attribute-set>

    <xsl:attribute-set name="__body__confidential__header_RU_common">
        <!-- Intelliarts Consulting/EMC PDF-Insert 20-feb-2014 A set of common attributes for Russian Confidential watermark on odd and even pages. IB-->
        <xsl:attribute name="margin-top">0.2in</xsl:attribute>
        <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
        <xsl:attribute name="font-size">10pt</xsl:attribute>
        <xsl:attribute name="line-height">11pt</xsl:attribute>
        <xsl:attribute name="font-style">italic</xsl:attribute>
        <xsl:attribute name="text-transform">uppercase</xsl:attribute>
        <xsl:attribute name="width">100%</xsl:attribute>
    </xsl:attribute-set>

    <!-- Suite/EMC   SOW5  07-Feb-2012   confidential header format START - ck -->
  <xsl:attribute-set name="__body__confidential__header">
    <xsl:attribute name="margin-top">0.2in</xsl:attribute>
    <xsl:attribute name="margin-left">
      <xsl:value-of select="$page-margin-inside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-right">
      <xsl:value-of select="$page-margin-outside"/>
    </xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">14pt</xsl:attribute>
    <!--<xsl:attribute name="font-weight">bold</xsl:attribute>-->
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="text-transform">uppercase</xsl:attribute>
  </xsl:attribute-set>

  <!-- Natasha IB2 8-Jul-21013 Special formatting for EMC Confidential string for RU -->
  <xsl:attribute-set name="__body__confidential__header_RU">
    <xsl:attribute name="margin-top">0.2in</xsl:attribute>
    <xsl:attribute name="margin-left">
      <xsl:value-of select="$page-margin-inside"/>
    </xsl:attribute>
    <xsl:attribute name="margin-right">
      <xsl:value-of select="$page-margin-outside"/>
    </xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="font-size">10pt</xsl:attribute>
    <xsl:attribute name="line-height">11pt</xsl:attribute>
    <xsl:attribute name="font-style">italic</xsl:attribute>
    <xsl:attribute name="text-transform">uppercase</xsl:attribute>
  </xsl:attribute-set>
  <!-- Suite/EMC   SOW5  07-Feb-2012   confidential header format END - ck -->

  <xsl:attribute-set name="__body__footer.table">
    <xsl:attribute name="space-before">0pt</xsl:attribute>
    <xsl:attribute name="space-after">0pt</xsl:attribute>
    <xsl:attribute name="margin-top">0pt</xsl:attribute>
    <xsl:attribute name="margin-bottom">0pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__body__footer.table.block">
    <xsl:attribute name="margin">0pt</xsl:attribute>
  </xsl:attribute-set>

  <!-- Thomas Dill 2011-May-31: Start for RSA template updates  -->
  <!-- ****************************************************************************** -->
  <xsl:attribute-set name="__chapter__frontmatter__name__container__rsa">
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <!-- Suite/EMC   SOW5  19-Jan-2012   Updated line-height - rs -->
    <xsl:attribute name="line-height">29pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the chapt -->
    <!-- ****************************************************************************** -->
    <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:value-of select="$rsa_red"/> -->
    <!-- </xsl:attribute> -->
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="border-top-style">none</xsl:attribute>
    <xsl:attribute name="border-bottom-style">none</xsl:attribute>
    <xsl:attribute name="border-top-width">0pt</xsl:attribute>
    <xsl:attribute name="border-bottom-width">0pt</xsl:attribute>
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">19pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__chapter__frontmatter__name__container">
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <!-- Suite/EMC   SOW5  19-Jan-2012   Updated line-height - rs -->
    <xsl:attribute name="line-height">29pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>

    <!--Suite/EMC   SOW5  15-Feb-2012   font family - ck-->
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
    <xsl:attribute name="text-transform">uppercase</xsl:attribute>

    <!-- Thomas Dill 2011-June-13: Changes to the templates remove color from the chapt -->
    <!-- ****************************************************************************** -->
    <!-- <xsl:attribute name="color" > -->
      <!-- <xsl:value-of select="$pantone_279"/> -->
    <!-- </xsl:attribute> -->
    <xsl:attribute name="color">black</xsl:attribute>
    <xsl:attribute name="border-top-style">none</xsl:attribute>
    <xsl:attribute name="border-bottom-style">none</xsl:attribute>
    <xsl:attribute name="border-top-width">0pt</xsl:attribute>
    <xsl:attribute name="border-bottom-width">0pt</xsl:attribute>
    <xsl:attribute name="padding-top">0pt</xsl:attribute>
    <xsl:attribute name="padding-bottom">19pt</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="__chapter__frontmatter__number__container">
    <xsl:attribute name="font-size">24pt</xsl:attribute>
    <!-- Suite/EMC   SOW5  19-Jan-2012   Updated line-height - rs -->
    <xsl:attribute name="line-height">29pt</xsl:attribute>
    <xsl:attribute name="font-weight">normal</xsl:attribute>
    <xsl:attribute name="font-family">SansLFRoman</xsl:attribute>
  </xsl:attribute-set>


  <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property STARTS HERE. - IB-->
  <xsl:attribute-set name="footer__dellrestricted_container_odd">
    <!--Add container at page footer-->
    <xsl:attribute name="position">fixed</xsl:attribute>
    <xsl:attribute name="top">
      <xsl:choose>
        <xsl:when test="//bookmap[contains(lower-case(@xml:lang),'ru')] and $DECR">10.38in</xsl:when>
        <xsl:otherwise>10.44in</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="left"><xsl:value-of select="$page-margin-inside"/></xsl:attribute>
    <xsl:attribute name="text-align">left</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="footer__dellrestricted_container_even">
    <!--Add container at page footer-->
    <xsl:attribute name="position">fixed</xsl:attribute>
    <xsl:attribute name="top">
      <xsl:choose>
        <xsl:when test="//bookmap[contains(lower-case(@xml:lang),'ru')] and $DECR">10.38in</xsl:when>
        <xsl:otherwise>10.44in</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="right"><xsl:value-of select="$page-margin-inside"/></xsl:attribute>
    <xsl:attribute name="text-align">right</xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="footer__dellrestricted_watermark">
    <xsl:attribute name="font-size">
      <xsl:choose>
        <xsl:when test="//bookmap[contains(lower-case(@xml:lang),'ru')] and $DECR">9pt</xsl:when>
        <xsl:otherwise>10pt</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:attribute-set>

  <xsl:attribute-set name="footer__dellrestricted_description">
    <xsl:attribute name="font-size">7pt</xsl:attribute>
  </xsl:attribute-set>
  <!-- IA   Tridion upgrade    Oct-2018   Add support for 'DELLRESTRICTED' property ENDS HERE. - IB-->

</xsl:stylesheet>
