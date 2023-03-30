<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    xmlns:opentopic-mapmerge="http://www.idiominc.com/opentopic/mapmerge"
    xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
    xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="opentopic-mapmerge opentopic-func related-links xs"
    version="2.0">


	<!-- Dimitri: Added template to skip rendering short descriptions in related links. -->
	<xsl:template name="insertLinkShortDesc">
		<xsl:param name="destination"/>
		<xsl:param name="element"/>
		<xsl:param name="linkScope"/>
		<xsl:choose>
			<!-- User specified description (from map or topic): use that. -->
			<xsl:when test="*[contains(@class,' topic/desc ')] and processing-instruction()[name()='ditaot'][.='usershortdesc']">
				<fo:block xsl:use-attribute-sets="link__shortdesc">
					<xsl:apply-templates select="*[contains(@class, ' topic/desc ')]"/>
				</fo:block>
			</xsl:when>
			<!-- External: do not attempt to retrieve. -->
			<xsl:when test="$linkScope='external'"></xsl:when>
			<!-- When the target has a short description and no local override, use the target -->
			<!-- Dimitri: Do not render short descriptions in related links. -->
			<!--xsl:when test="$element/*[contains(@class, ' topic/shortdesc ')]">
				<fo:block xsl:use-attribute-sets="link__shortdesc">
					<xsl:apply-templates select="$element/*[contains(@class, ' topic/shortdesc ')]"/>
				</fo:block>
			</xsl:when-->
			<xsl:when test="$element/*[contains(@class, ' topic/shortdesc ')]"/>
		</xsl:choose>
	</xsl:template>

	<!-- Dimitri: Added template to render related links' titles in the Dell blue color. -->
	<xsl:template match="*[contains(@class,' topic/related-links ')]">
		<xsl:if test="exists($includeRelatedLinkRoles)">
			<fo:block xsl:use-attribute-sets="related-links">
				<fo:block xsl:use-attribute-sets="related-links__content">
					<!-- Dimitri: Render related links' titles in the Dell blue color. -->
					<xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
					<xsl:if test="$includeRelatedLinkRoles = ('child', 'descendant')">
						<xsl:call-template name="ul-child-links"/>
						<xsl:call-template name="ol-child-links"/>
					</xsl:if>
					<xsl:variable name="unordered-links" as="element(linklist)*">
						<xsl:apply-templates select="." mode="related-links:group-unordered-links">
							<xsl:with-param name="nodes" select="descendant::*[contains(@class, ' topic/link ')][not(related-links:omit-from-unordered-links(.))][generate-id(.) = generate-id(key('hideduplicates', related-links:hideduplicates(.))[1])]"/>
						</xsl:apply-templates>
					</xsl:variable>
					<xsl:apply-templates select="$unordered-links"/>
					<!--linklists - last but not least, create all the linklists and their links, with no sorting or re-ordering-->
					<xsl:apply-templates select="*[contains(@class, ' topic/linklist ')]"/>
				</fo:block>
			</fo:block>
		</xsl:if>
	</xsl:template>

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
		<!-- Dimitri: Render "page" in Dell blue. -->
		<xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
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
		<!-- Dimitri: Render "on page" in Dell blue. -->
		<xsl:attribute name="color"><xsl:value-of select="$dell_blue"/></xsl:attribute>
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


	<!-- Dimitri: Additional related-links templates. -->

  <xsl:template match="*[contains(@class, ' topic/link ')]" mode="related-links:result-group" name="related-links:group-result." as="element(linklist)" priority="-10">
    <xsl:param name="links" as="node()*"/>
    <xsl:if test="exists($links)">
      <linklist class="- topic/linklist " outputclass="relinfo">
        <title class="- topic/title ">
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Related information'"/>
          </xsl:call-template>
			<!--Related Links-->
        </title>
        <xsl:copy-of select="$links"/>
      </linklist>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:get-group" name="related-links:group.concept" as="xs:string">
    <xsl:text>concept</xsl:text>
    <!--xsl:text>Link</xsl:text-->
  </xsl:template>

 <xsl:template match="*[contains(@class, ' topic/link ')][@type='reference']" mode="related-links:get-group" name="related-links:group.reference" as="xs:string">
    <xsl:text>reference</xsl:text>
    <!--xsl:text>Link</xsl:text-->
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:get-group" name="related-links:group.task" as="xs:string">
    <xsl:text>task</xsl:text>
    <!--xsl:text>Link</xsl:text-->
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:result-group" name="related-links:result.task" as="element(linklist)">
    <xsl:param name="links" as="node()*"/>
    <xsl:if test="normalize-space(string-join($links, ''))">
      <linklist class="- topic/linklist " outputclass="relinfo reltasks">
        <title class="- topic/title ">
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Related tasks'"/>
          </xsl:call-template>
			<!--Related Links-->
        </title>
        <xsl:copy-of select="$links"/>
      </linklist>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:result-group" name="related-links:result.concept" as="element(linklist)">
    <xsl:param name="links" as="node()*"/>
    <xsl:if test="normalize-space(string-join($links, ''))">
      <linklist class="- topic/linklist " outputclass="relinfo relconcepts">
        <title class="- topic/title ">
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Related concepts'"/>
          </xsl:call-template>
			<!--Related Links-->
        </title>
        <xsl:copy-of select="$links"/>
      </linklist>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*[contains(@class, ' topic/link ')][@type='reference']" mode="related-links:result-group" name="related-links:result.reference" as="element(linklist)">
    <xsl:param name="links"/>
    <xsl:if test="normalize-space(string-join($links, ''))">
      <linklist class="- topic/linklist " outputclass="relinfo relref">
        <title class="- topic/title ">
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="'Related reference'"/>
          </xsl:call-template>
			<!--Related Links-->
        </title>
        <xsl:copy-of select="$links"/>
      </linklist>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
