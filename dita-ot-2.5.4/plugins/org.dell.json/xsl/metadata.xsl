<xsl:stylesheet version="2.0"
   xmlns:zoomin="http://www.zoominsoftware.com/namespaces/mapcounts"
   xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="zoomin dita-ot">

  
<xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
<xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
<xsl:import href="plugin:org.dita.base:xsl/common/dita-textonly.xsl"/>
<xsl:output method="xml" indent="yes"/>
<xsl:param name="job" />
<xsl:param name="ditamap"/>
<xsl:param name="ishjob" />
<xsl:param name="MAPLIST"/>
<xsl:param name="TEMPDIR"/>
<xsl:param name="inputdir"/>
<xsl:variable name="pubguid">
	<xsl:value-of select="document(concat('file:///',$job))//parameter[@name='export-document']"/>
</xsl:variable>
<xsl:variable name="fullditamap"
  select="doc(concat('file:///', translate($TEMPDIR,'\','/'), '/', /job/property[@name = 'user.input.file.uri']/string))"/>
<!-- Deprecated since 2.3 -->
<xsl:variable name="msgprefix">DOTX</xsl:variable>

<xsl:template match="/">
<!--Metadata section-->
<metadata>
	<postingstatus>No</postingstatus>
	<publisher>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FISHPUBLISHER']"/>
	</publisher>
	<language>
		<xsl:value-of select="document(concat('file:///',$job))//parameter[@name='language']"/>
	</language>
	<publication-name>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FTITLE']"/>
	</publication-name>
	<version>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='VERSION']"/>
	</version>
	<!--Change the Fish field once the prodcut type is added-->
	<product-type>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FISHPUBLICATIONTYPE']"/>
	</product-type>
	<publication-guid> 
		<xsl:value-of select="document(concat('file:///',$job))//parameter[@name='export-document']"/>
	</publication-guid>
	<productcode> 
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLPRODUCTCODE']"/>
   </productcode>
	<publishdate> 
	<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLREACHPUBLISHDATE']"/>
	</publishdate>
</metadata>
		
</xsl:template>
  
 
</xsl:stylesheet>