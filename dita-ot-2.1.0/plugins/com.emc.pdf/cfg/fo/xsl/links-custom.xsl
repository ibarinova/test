<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:opentopic-mapmerge="http://www.idiominc.com/opentopic/mapmerge"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="opentopic-mapmerge opentopic-func related-links xs"
    version="2.0">
  
  <xsl:template match="*[contains(@class, ' topic/fig ')][*[contains(@class, ' topic/title ')]]" mode="retrieveReferenceTitle">
    <!--xref should not include title - rs-->
    <xsl:call-template name="getVariable">
      <xsl:with-param name="id" select="'Figure Num'"/>
      <xsl:with-param name="params" as="element()*">
        <number>
          <xsl:value-of select="count(preceding::*[contains(@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ')]]) + 1"/>
        </number>
        <!--<title>
          <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="insert-text"/>
        </title>-->
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/table ')][*[contains(@class, ' topic/title ')]]" mode="retrieveReferenceTitle">
    <!--xref should not include title - rs-->
    <xsl:call-template name="getVariable">
      <xsl:with-param name="id" select="'Table Num'"/>
      <xsl:with-param name="params" as="element()*">
        <number>
          <xsl:value-of select="count(preceding::*[contains(@class, ' topic/table ')][child::*[contains(@class, ' topic/title ')]]) + 1"/>
        </number>
        <!--<title>
          <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="insert-text"/>
        </title>-->
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Balaji Mani 12-June-2013: cross reference for table -->
  <xsl:template match="*[contains(@class, ' topic/xref ') and @type='fn']" priority="2">
    <xsl:variable name="href" select="substring-after(@href,'/')" />
    <xsl:choose>
      <xsl:when test="//*[@id=$href][ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]">
        <fo:basic-link font-style="normal">
          <xsl:attribute name="internal-destination" select="generate-id(//*[@id=$href])"/>
          <fo:inline xsl:use-attribute-sets="fn__callout_ref">
            <xsl:variable name="tableId" select="//*[@id=$href]/ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.)" />
            <xsl:variable name="xrefTableId"  select="current()/ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.)"/>
            <xsl:choose>
              <xsl:when test="$xrefTableId != $tableId">
                <xsl:message>WARNING: <xsl:value-of select="@ohref"/> table cross reference does not exist in same table.</xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="tableFnCount" select="//*[contains(@class, ' topic/fn ') and @id = $href]/count(preceding::*[contains(@class, ' topic/fn ') and $xrefTableId=$tableId and ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.) = $tableId]) + 1"/>
                <xsl:choose>
                  <xsl:when test="translate($locale,'RU','ru')='ru'">
                    <xsl:number format="&#x0430;" value="$tableFnCount"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:number format="a" value="$tableFnCount"/>
                  </xsl:otherwise>
                </xsl:choose>			
              </xsl:otherwise>
            </xsl:choose>
          </fo:inline>
        </fo:basic-link> 
      </xsl:when>
      <xsl:otherwise>
        <fo:inline xsl:use-attribute-sets="fn_container">
          <fo:inline xsl:use-attribute-sets="fn__callout_ref">
            <xsl:variable name="textFnCount" select="//*[contains(@class, ' topic/fn ') and @id = $href]/count(preceding::*[contains(@class, ' topic/fn ') and  not(ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')])])"/>
            <xsl:value-of select="$textFnCount + 1"/>
          </fo:inline>
        </fo:inline> 
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="insertPageNumberCitation">
    <xsl:param name="isTitleEmpty" as="xs:boolean" select="false()"/>
    <xsl:param name="destination" as="xs:string"/>
    <xsl:param name="element" as="element()?"/>
    
    <xsl:choose>
      <xsl:when test="not($element) or ($destination = '')"/>
      <xsl:when test="$isTitleEmpty">
        <fo:inline>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Page'"/>
            <xsl:with-param name="params" as="element()*">
              <pagenum>
                  <fo:page-number-citation ref-id="{$destination}"/>
              </pagenum>
            </xsl:with-param>
          </xsl:call-template>
        </fo:inline>
      </xsl:when>
      <xsl:otherwise>
        <fo:inline>
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'On page'"/>
            <xsl:with-param name="params" as="element()*">
              <pagenum>
                  <fo:page-number-citation ref-id="{$destination}"/> 
              </pagenum>
            </xsl:with-param>
          </xsl:call-template>
        </fo:inline>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
