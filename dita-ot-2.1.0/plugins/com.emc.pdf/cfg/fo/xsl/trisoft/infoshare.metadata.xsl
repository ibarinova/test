<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
<!-- IDPL-2264 Roopesh, for L10N team : required  GUID and status-->
	<xsl:template name="pubmeta">
	<xsl:variable name="pubmeta.id">
	    <xsl:choose>
	      <xsl:when test="$multilingual = 'yes'">
	      <!--<xsl:value-of select="concat(ancestor-or-self::*/@xml:lang,'/',substring-after(ancestor-or-self::*/@oid,concat(ancestor-or-self::*/@xml:lang,'-')))"/>-->
	        <xsl:value-of select="concat(ancestor-or-self::*/@xml:lang,'/',substring-after((ancestor-or-self::*[@oid][1]/@oid),concat(ancestor-or-self::*/@xml:lang,'-')))"/>
	      </xsl:when>
	      <xsl:otherwise>
	      	<xsl:choose>
	      		<xsl:when test="@oid">
	        		<xsl:value-of select="ancestor-or-self::*[@oid][1]/@oid"/>
	        	</xsl:when>
	        	<xsl:otherwise>
	        		<xsl:value-of select="ancestor-or-self::*[@oid][1]/@oid"/>
	        	</xsl:otherwise>
	        </xsl:choose>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:message>Insert metadata for pubmeta.id [<xsl:value-of select="$pubmeta.id" />] based upon oid [<xsl:value-of select="@oid"/>]</xsl:message>
    <xsl:if test="translate($show-metadata,'YES','yes') = 'yes'">
      <!--xsl:message>Processing metadata for with following parameters: pubmeta.id: <xsl:value-of select="$pubmeta.id" /> | @id: <xsl:value-of select="parent::*/@id"/> | of element: <xsl:value-of select="name(parent::*)"/></xsl:message-->
	<!-- get the topic status -->
	<xsl:variable name="status">
		<xsl:value-of select="document(concat($WORKDIR, '/', $pubmeta.id, $ext.metadata),/)//ishfield[@name='FSTATUS']"/>
	</xsl:variable>
	<xsl:variable name="topicversion">
		<xsl:value-of select="document(concat($WORKDIR, '/', $pubmeta.id, $ext.metadata),/)//ishfield[@name='VERSION']"/>
	</xsl:variable>
	<fo:block font-size="8pt" keep-with-next.within-column='always'>
  			<xsl:call-template name="add.style">
  				<xsl:with-param name="style" select="'span'"/>
          <xsl:with-param name="language"><xsl:call-template name="get.current.language"/></xsl:with-param>
  			</xsl:call-template>
        <fo:table table-layout="fixed" border-style="solid" border-width="thin">
  				<xsl:choose>
				<xsl:when test="$status='To be translated'">
				<xsl:attribute name="border-color">red</xsl:attribute>
				<xsl:attribute name="color">red</xsl:attribute>
				</xsl:when>
				<xsl:when test="$status='In translation'">
				<xsl:attribute name="border-color">#E6B406</xsl:attribute>
				<xsl:attribute name="color">#E6B406</xsl:attribute>
				</xsl:when>
				<xsl:when test="$status='Translated'">
				<xsl:attribute name="border-color">#0000ff </xsl:attribute>
				<xsl:attribute name="color">#0000ff</xsl:attribute>
				</xsl:when>
				<xsl:when test="$status='Translation Validated'">
				<xsl:attribute name="border-color">#006400</xsl:attribute>
				<xsl:attribute name="color">#006400</xsl:attribute>
				</xsl:when>
				<xsl:when test="$status='Translation Rejected'">
				<xsl:attribute name="border-color">#A52A2A</xsl:attribute>
				<xsl:attribute name="color">#A52A2A</xsl:attribute>
				</xsl:when>
				<xsl:when test="$status='Released'">
				<xsl:attribute name="border-color">#90EE90</xsl:attribute>
				<xsl:attribute name="color">#90EE90</xsl:attribute>
				</xsl:when>
				<xsl:when test="$status='To be deleted'">
				<xsl:attribute name="border-color">black</xsl:attribute>
				<xsl:attribute name="color">black</xsl:attribute>
				</xsl:when>
				</xsl:choose>

				<fo:table-column column-width="25%"/>
  				<fo:table-column column-width="75%"/>
  				<fo:table-body>
                 <!-- Topic GUID-->
				<fo:table-row keep-with-next.within-column='always' keep-with-previous.within-column='always'>
                  <fo:table-cell>
                     <fo:block start-indent="2pt">Identifier</fo:block>
                  </fo:table-cell>
                  <fo:table-cell>
                     <xsl:choose>
                        <xsl:when test="$multilingual = 'yes'">
                           <fo:block start-indent="2pt">
                              <xsl:value-of select="substring-after($pubmeta.id,'/')" />
                           </fo:block>
                        </xsl:when>
                        <xsl:otherwise>
                           <fo:block start-indent="2pt">
                              <xsl:value-of select="$pubmeta.id" />
                           </fo:block>
                        </xsl:otherwise>
                     </xsl:choose>
                  </fo:table-cell>
               </fo:table-row>
			   <!-- Topic version added by Roopesh IDPL8034 -->
				<fo:table-row keep-with-next.within-column='always' keep-with-previous.within-column='always'>
  						<fo:table-cell>
  							<fo:block start-indent="2pt">Version</fo:block>
  						</fo:table-cell>
  						<fo:table-cell>
  							<fo:block start-indent="2pt">
  							  <xsl:value-of select="$topicversion"/>
  							</fo:block>
  						</fo:table-cell>
            </fo:table-row>
			   <!-- Topic status-->
				<fo:table-row keep-with-next.within-column='always' keep-with-previous.within-column='always'>
  						<fo:table-cell>
  							<fo:block start-indent="2pt">Status</fo:block>
  						</fo:table-cell>
  						<fo:table-cell>
  							<fo:block start-indent="2pt">
  							  <xsl:apply-templates select="document(concat($WORKDIR, '/', $pubmeta.id, $ext.metadata),/)//ishfield[@name='FSTATUS']"/>
  							</fo:block>
  						</fo:table-cell>
            </fo:table-row>
  			</fo:table-body>
        </fo:table>
      </fo:block>
    </xsl:if>
	</xsl:template>

	<!-- ============================================================== -->
	<xsl:template name="getMetadataValue">
		<xsl:param name="document.id" />
		<xsl:param name="fieldname" />
		<xsl:param name="fieldlevel" />
		<xsl:param name="default" />
		<xsl:choose>
			<xsl:when test="document(concat($WORKDIR, '/', $document.id, $ext.metadata),/)//ishfield[@name=$fieldname and @level=$fieldlevel]">
            <xsl:value-of select="document(concat($WORKDIR, '/', $document.id, $ext.metadata),/)//ishfield[@name=$fieldname and @level=$fieldlevel]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$default"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
</xsl:stylesheet>
