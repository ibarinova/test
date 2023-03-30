<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="http://www.w3.org/1999/XSL/Format" version="2.0">

  <!-- Elements for steps are in task-elements.xsl -->
  <!-- Templates for <dl> are in tables.xsl -->

  <!-- 
    Revision History
    ================
    Suite/EMC   SOW5    19-Mar-2013   fix pagebreak processing for list-items
    Natasha     IB2     08-Jul-2013   Commented out the topic/table case to remove alphabetical characters in table 1st level lists
	Chaya		IB3		08-Nov-2013   Increased space above the first li item in a nested ol and ul.
	EMC         IB4     25-Mar-2014   388/fix nopagebreak processing for list-items and steps
	EMC 		IB5 	21-Aug-2014   TKT-55: Fix unordered list formatting within tables inside a substep.
	EMC 		IB5 	27-Aug-2014   TKT-55: Fix unordered list formatting within tables inside a substep.
  -->

  <xsl:template match="*[contains(@class, ' topic/ul ')]/*[contains(@class, ' topic/li ')]">
    <xsl:param name="pagebreak" tunnel="yes">no</xsl:param>
    
    <xsl:variable name="templevel"
      select="count(ancestor-or-self::*[contains(@class, ' topic/ul ')])"/>
    <xsl:variable name="level">
      <xsl:choose>
        <xsl:when test="$templevel > 3">3</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$templevel"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="bulletType">
      <xsl:choose>
        <xsl:when test="parent::*/@outputclass = 'checkbox'">
          <xsl:text>checkbox bullet</xsl:text>
        </xsl:when>
        <!-- IB5 27-Aug-2014 TKT-55: Fix unordered list formatting within tables inside a substep. -->
        <!--xsl:when test="ancestor::*[contains(@class, ' topic/table ')]">
          <xsl:text>Unordered List bullet level2</xsl:text>
        </xsl:when-->
        <xsl:otherwise>
          <xsl:text>Unordered List bullet level</xsl:text>
          <xsl:value-of select="$level"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <fo:list-item xsl:use-attribute-sets="ul.li">
      <!-- Suite/EMC   SOW5    19-Mar-2013   fix pagebreak processing for list-items - RS -->
      <xsl:if test="$pagebreak = 'yes'">
        <xsl:attribute name="break-before">page</xsl:attribute>
      </xsl:if>
      <!-- EMC   IB4  25-Mar-2014   388/fix nopagebreak processing for list-items and steps -->
      <xsl:if test="$pagebreak = 'nopagebreak'">
        <xsl:attribute name="keep-together.within-page">5</xsl:attribute>
      </xsl:if>
      <fo:list-item-label xsl:use-attribute-sets="ul.li__label">
		<!-- Dimitri: In numbered lists, render numbers in Dell blue. -->
		<xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
        <fo:block xsl:use-attribute-sets="ul.li__label__content">
          <!--level specific attributes-->
          <xsl:attribute name="font-family">
            <xsl:choose>
              <xsl:when test="$level = 3">Sans</xsl:when>
              <xsl:when test="parent::*/@outputclass = 'checkbox'">Monospaced</xsl:when>
              <xsl:otherwise>Wingdings</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="font-size">
            <xsl:choose>
              <xsl:when test="$bulletType = 'checkbox bullet'">12pt</xsl:when>
              <xsl:when test="$level = 3">
                <xsl:value-of select="$default-font-size"/>
              </xsl:when>
              <xsl:otherwise>6pt</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <fo:inline id="{@id}"/>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="$bulletType"/>
          </xsl:call-template>
        </fo:block>
      </fo:list-item-label>

      <fo:list-item-body xsl:use-attribute-sets="ul.li__body">
        <fo:block xsl:use-attribute-sets="ul.li__content">
          <xsl:apply-templates/>
        </fo:block>
      </fo:list-item-body>

    </fo:list-item>
  </xsl:template>


  <xsl:template match="*[contains(@class, ' topic/ol ')]/*[contains(@class, ' topic/li ')]">

    <!-- Suite/EMC   SOW5    19-Mar-2013   fix pagebreak processing for list-items and steps BEGIN - RS -->
    <xsl:param name="pagebreak" tunnel="yes">no</xsl:param>

    <fo:list-item xsl:use-attribute-sets="ol.li">
      <xsl:if test="$pagebreak = 'yes'">
        <xsl:attribute name="break-before">page</xsl:attribute>
      </xsl:if>
      <!-- EMC   IB4  25-Mar-2014   388/fix nopagebreak processing for list-items and steps -->
      <xsl:if test="$pagebreak = 'nopagebreak'">
        <xsl:attribute name="keep-together.within-page">5</xsl:attribute>
      </xsl:if>

      <!-- Suite/EMC   SOW5    19-Mar-2013   fix pagebreak processing for list-items and steps END - RS -->
      <!-- Natasha   IB2    8-Jul-2013   Commented out the topic/table case to remove alphabetical characters in table 1st level lists -->
      <fo:list-item-label xsl:use-attribute-sets="ol.li__label">
		<!-- Dimitri: In numbered lists, render numbers in Dell blue. -->
		<xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
        <fo:block xsl:use-attribute-sets="ol.li__label__content">
          <fo:inline id="{@id}"/>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Ordered List Number'"/>
            <xsl:with-param name="params" as="element()*">
              <number>
                <xsl:choose>
                  <xsl:when test="count(ancestor::*[contains(@class, ' topic/ol ')]) > 1">
                    <xsl:number format="a"/>
                  </xsl:when>
                  <!--      <xsl:when test="ancestor::*[contains(@class, ' topic/table ')]">
                    <xsl:number format="a"/>
                  </xsl:when> -->
                  <xsl:otherwise>
                    <xsl:number/>
                  </xsl:otherwise>
                </xsl:choose>
              </number>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:list-item-label>

      <fo:list-item-body xsl:use-attribute-sets="ol.li__body">
        <fo:block xsl:use-attribute-sets="ol.li__content">
          <xsl:apply-templates/>
        </fo:block>
      </fo:list-item-body>

    </fo:list-item>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/ul ') or contains(@class, ' topic/ol ')]">
    <!--level variables-->
    <xsl:variable name="templevel"
      select="count(ancestor-or-self::*[contains(@class, ' topic/li ')]) + 1"/>
    <xsl:variable name="level">
      <xsl:choose>
        <xsl:when test="$templevel > 3">3</xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$templevel"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <fo:list-block xsl:use-attribute-sets="ul" id="{@id}">

      <!-- EMC  08-Nov-2013  IB3  Issue 345: More space above bullet items  -->
      <xsl:attribute name="space-before.optimum">6pt</xsl:attribute>

      <!--level-specific attributes-->
      <xsl:attribute name="provisional-distance-between-starts">
        <xsl:choose>
          <xsl:when test="$level = 1">0.23in</xsl:when>
          <xsl:otherwise>0.20in</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <!-- Balaji Mani 25-Feb-2013: updated the line space for the end of the document -->
      <!-- EMC  PDFGlossary 13-Aug-2013   Exclude glossary when formatting the bottom margin of ul or ol -->
      <xsl:if
        test="ends-with(normalize-space(ancestor::*[contains(@class, 'topic/topic') and not(contains(@class, ' glossentry/glossentry '))][1]), normalize-space(.)) and not(following::*[1][name() = 'image']) and (name() = 'steps' or name() = 'ol' or name() = 'ul')">
        <xsl:attribute name="margin-bottom">20px</xsl:attribute>
      </xsl:if>

      <xsl:apply-templates/>
    </fo:list-block>
  </xsl:template>

</xsl:stylesheet>
