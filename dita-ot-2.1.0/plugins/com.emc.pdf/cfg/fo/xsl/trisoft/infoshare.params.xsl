<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" version="1.0">
	<!-- ============================================================== -->
  <!-- IDPL-2264, Roopesh. Params provided through DITA-OT-->
 <!-- <xsl:param name="DRAFT" />-->
   <!-- for local dev only BEGIN -->
<!--   <xsl:param name="WORKDIR" select="'C:/Dell/source/7295/compare/en-us/workset-new'"></xsl:param>-->
   <!-- for local dev only END -->
  <!--<xsl:param name="WORKDIR" select="'..'"/>	-->
  <!-- ============================================================== -->
	<xsl:param name="copyright">Copyright 2018</xsl:param>
  <!-- <xsl:param name="draft">yes</xsl:param>-->
   <xsl:param name="export-document-type">
      <!-- indicates the Infoshare type of the exported document (e.g. ISHPublication, ISHMasterDoc, ...) -->
      <xsl:call-template name="getJobTicketParam">
         <xsl:with-param name="varname">export-document-type</xsl:with-param>
         <xsl:with-param name="default"></xsl:with-param>
         <!-- allowable values are ISHPublication, ISHMasterDoc, ... -->
         <xsl:with-param name="document" select="."/>
      </xsl:call-template>
   </xsl:param>
   <xsl:param name="export-document-id">
      <!-- indicates the Infoshare exported document identifier -->
      <xsl:call-template name="getJobTicketParam">
         <xsl:with-param name="varname">export-document</xsl:with-param>
         <xsl:with-param name="default"></xsl:with-param>
         <xsl:with-param name="document" select="."/>
      </xsl:call-template>
   </xsl:param>
   <xsl:param name="export-document-level">
      <!-- indicates the Infoshare level of the exported document (e.g. version, lng) -->
      <xsl:call-template name="getJobTicketParam">
         <xsl:with-param name="varname">export-document-level</xsl:with-param>
         <xsl:with-param name="default"></xsl:with-param>
         <!-- allowable values are version, lng -->
         <xsl:with-param name="document" select="."/>
      </xsl:call-template>
   </xsl:param>
   <xsl:param name="watermark">
      <!-- indicates whether the document is printed with a watermark text -->
      <xsl:choose>
         <xsl:when test="$export-document-type = 'ISHPublication' and $export-document-level='lng'">
            <xsl:call-template name="getMetadataValue">
               <xsl:with-param name="fieldname">FPUBWATERMARK</xsl:with-param>
               <xsl:with-param name="fieldlevel">lng</xsl:with-param>
               <xsl:with-param name="default">no</xsl:with-param>
               <!-- allowable values are yes/no -->
               <xsl:with-param name="document.id" select="$export-document-id"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="getJobTicketParam">
               <xsl:with-param name="varname">show-watermark</xsl:with-param>
               <xsl:with-param name="default">no</xsl:with-param>
               <!-- allowable values are yes/no -->
               <xsl:with-param name="document" select="."/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:param>
   <xsl:param name="show-comments"><!-- indicates whether additional information as metadata will be printed -->
      <xsl:choose>
         <xsl:when test="$export-document-type = 'ISHPublication' and $export-document-level='lng'">
            <xsl:call-template name="getMetadataValue">
               <xsl:with-param name="fieldname">FPUBINCLUDECOMMENTS</xsl:with-param>
               <xsl:with-param name="fieldlevel">lng</xsl:with-param>
               <xsl:with-param name="default">no</xsl:with-param>
               <!-- allowable values are yes/no -->
               <xsl:with-param name="document.id" select="$export-document-id"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="getJobTicketParam">
  		         <xsl:with-param name="varname">show-comments</xsl:with-param>
  		         <xsl:with-param name="default">no</xsl:with-param><!-- allowable values are yes/no -->
  		         <xsl:with-param name="document" select="."/>
  	         </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:param>
	<xsl:param name="show-metadata"><!-- indicates whether additional information as metadata will be printed -->
      <xsl:choose>
         <xsl:when test="$export-document-type = 'ISHPublication' and $export-document-level='lng'">
            <xsl:call-template name="getMetadataValue">
               <xsl:with-param name="fieldname">FPUBINCLUDEMETADATA</xsl:with-param>
               <xsl:with-param name="fieldlevel">lng</xsl:with-param>
               <xsl:with-param name="default">no</xsl:with-param>
               <!-- allowable values are yes/no -->
               <xsl:with-param name="document.id" select="$export-document-id"/>
            </xsl:call-template>
         </xsl:when>
         <xsl:otherwise>
            <xsl:call-template name="getJobTicketParam">
               <xsl:with-param name="varname">show-metadata</xsl:with-param>
               <xsl:with-param name="default">no</xsl:with-param>
               <!-- allowable values are yes/no -->
               <xsl:with-param name="document" select="."/>
            </xsl:call-template>
         </xsl:otherwise>
      </xsl:choose>
	</xsl:param>
   <xsl:param name="multilingual">
	  <xsl:call-template name="getJobTicketAttrib">
	    <xsl:with-param name="varname">combinelanguages</xsl:with-param>
	    <xsl:with-param name="default">no</xsl:with-param>
	  </xsl:call-template>
	</xsl:param>
	<xsl:param name="compare-available">
	  <xsl:call-template name="getJobTicketAttrib">
	    <xsl:with-param name="varname">comparewitholderversion</xsl:with-param>
	    <xsl:with-param name="default">no</xsl:with-param>
	  </xsl:call-template>     
	</xsl:param>
<!--	<xsl:param name="display.indexes">no</xsl:param> replaced	
	<xsl:param name="display.pagerefs">yes</xsl:param> replaced -->
  <xsl:param name="document-id"/>
	<xsl:param name="ext.hyperlink">.html</xsl:param>
  <xsl:param name="ext.metadata">.met</xsl:param>
	<xsl:param name="img.dflt.path"></xsl:param>
	<xsl:param name="img.dflt.resolution">Low</xsl:param>
	<xsl:param name="url.documentinfo"></xsl:param>
	<xsl:param name="url.export"></xsl:param>
	<xsl:param name="url.report"></xsl:param>
	<xsl:param name="url.showdocument"></xsl:param>
	<xsl:param name="url.showillustration"></xsl:param>
  <xsl:param name="url.stylesheet">common.css</xsl:param>	
  <xsl:param name="mode">publishing</xsl:param>
  <!-- ============================================================== -->  
	<!-- Publication Manager specific params -->
	<xsl:param name="pe.authcontext"/>
	<xsl:param name="pe.configurationlocation"/>
	<xsl:param name="pe.docid"/>
	<xsl:param name="pe.illustrationlng"/>
  <!-- ============================================================== -->
</xsl:stylesheet>