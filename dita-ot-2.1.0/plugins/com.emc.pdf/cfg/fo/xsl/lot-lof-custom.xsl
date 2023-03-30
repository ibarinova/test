<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:dita2xslfo="http://dita-ot.sourceforge.net/ns/200910/dita2xslfo"
    xmlns:opentopic="http://www.idiominc.com/opentopic"
    xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
    xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
    exclude-result-prefixes="opentopic opentopic-index dita2xslfo ot-placeholder"
    version="2.0">

  <xsl:template name="createLOFHeader">
    <xsl:choose>
      <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Add using of RSA BRAND value from BRAND list instead of @outputclass with 'rsa' value - IB-->
      <xsl:when test="$BRAND-IS-RSA">
        <fo:block xsl:use-attribute-sets="__lotf__heading__rsa" id="{$id.lof}">
          <fo:marker marker-class-name="current-header">
            <xsl:call-template name="insertVariable">
              <xsl:with-param name="theVariableID" select="'List of Figures'"/>
            </xsl:call-template>
          </fo:marker>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="__lotf__heading" id="{$id.lof}">
          <fo:marker marker-class-name="current-header">
            <xsl:call-template name="insertVariable">
              <xsl:with-param name="theVariableID" select="'List of Figures'"/>
            </xsl:call-template>
          </fo:marker>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="createLOTHeader">
    <xsl:choose>
      <!-- Intelliarts Consulting   DellEMC Rebranding    10-Oct-2016   Add using of RSA BRAND value from BRAND list instead of @outputclass with 'rsa' value - IB-->
      <xsl:when test="$BRAND-IS-RSA">
        <fo:block xsl:use-attribute-sets="__lotf__heading__rsa" id="{$id.lot}">
          <fo:marker marker-class-name="current-header">
            <xsl:call-template name="insertVariable">
              <xsl:with-param name="theVariableID" select="'List of Tables'"/>
            </xsl:call-template>
          </fo:marker>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block xsl:use-attribute-sets="__lotf__heading" id="{$id.lot}">
          <fo:marker marker-class-name="current-header">
            <xsl:call-template name="insertVariable">
              <xsl:with-param name="theVariableID" select="'List of Tables'"/>
            </xsl:call-template>
          </fo:marker>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[contains (@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ' )]]" mode="list.of.figures">
    <fo:block xsl:use-attribute-sets="__lotf__content">
      <fo:float xsl:use-attribute-sets="__lotf__number">
        <fo:block >
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Figure number'"/>
            <xsl:with-param name="params" as="element()*">
              <number>
                <xsl:variable name="id" select="@id"/>
                <xsl:variable name="figureNumber">
                  <xsl:number format="1" value="count($figureset/*[@id = $id]/preceding-sibling::*) + 1" />
                </xsl:variable>
                <xsl:value-of select="$figureNumber"/>
              </number>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:float>
      <fo:block xsl:use-attribute-sets="__lotf__title">
        <fo:basic-link>
          <xsl:attribute name="internal-destination">
            <xsl:call-template name="get-id"/>
          </xsl:attribute>
          <fo:inline >
            <xsl:apply-templates select="./*[contains(@class, ' topic/title ')]" mode="insert-text"/>
          </fo:inline>
          <fo:inline xsl:use-attribute-sets="__lotf__page-number">
            <fo:leader xsl:use-attribute-sets="__lotf__leader"/>
            <fo:inline >
              <fo:page-number-citation>
                <xsl:attribute name="ref-id">
                  <xsl:call-template name="get-id"/>
                </xsl:attribute>
              </fo:page-number-citation>
            </fo:inline>
          </fo:inline>
        </fo:basic-link>
      </fo:block>
    </fo:block>
  </xsl:template>

  <xsl:template match="*[contains (@class, ' topic/table ')][child::*[contains(@class, ' topic/title ' )]]" mode="list.of.tables">
    <fo:block xsl:use-attribute-sets="__lotf__content">
      <fo:float xsl:use-attribute-sets="__lotf__number">
        <fo:block >
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Table number'"/>
            <xsl:with-param name="params" as="element()*">
              <number>
                <xsl:variable name="id" select="@id"/>
                <xsl:variable name="tableNumber">
                  <xsl:number format="1" value="count($tableset/*[@id = $id]/preceding-sibling::*) + 1" />
                </xsl:variable>
                <xsl:value-of select="$tableNumber"/>
              </number>
            </xsl:with-param>
          </xsl:call-template>
        </fo:block>
      </fo:float>
      <fo:block xsl:use-attribute-sets="__lotf__title">
        <fo:basic-link>
          <xsl:attribute name="internal-destination">
            <xsl:call-template name="get-id"/>
          </xsl:attribute>
          <fo:inline >
            <xsl:apply-templates select="./*[contains(@class, ' topic/title ')]" mode="insert-text"/>
          </fo:inline>
          <fo:inline xsl:use-attribute-sets="__lotf__page-number">
            <fo:leader xsl:use-attribute-sets="__lotf__leader"/>
            <fo:inline >
              <fo:page-number-citation>
                <xsl:attribute name="ref-id">
                  <xsl:call-template name="get-id"/>
                </xsl:attribute>
              </fo:page-number-citation>
            </fo:inline>
          </fo:inline>
        </fo:basic-link>
      </fo:block>
    </fo:block>
  </xsl:template>

</xsl:stylesheet>
