<xsl:stylesheet version="2.0"
   xmlns:zoomin="http://www.zoominsoftware.com/namespaces/mapcounts"
   xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   exclude-result-prefixes="zoomin dita-ot">
  
<xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>
<xsl:import href="plugin:org.dita.base:xsl/common/dita-utilities.xsl"/>
<xsl:import href="plugin:org.dita.base:xsl/common/dita-textonly.xsl"/>
<xsl:key name="meta-keywords" match="*[ancestor::*[contains(@class,' topic/keywords ')]]" use="text()[1]"/>  
<xsl:output method="xml" indent="yes"/>
<xsl:param name="job" />
<xsl:param name="ditamap"/>
<xsl:param name="ishjob" />
<xsl:param name="MAPLIST"/>
<xsl:param name="IMAGELIST"/>
<xsl:param name="OUTEXT" select="'.html'"/>
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
	<!-- added EMail meta data property IDPL-16431-->
	<email-id> 
		<xsl:value-of select="document(concat('file:///',$job))//parameter[@name='FISHEMAIL']"/>
	</email-id>
	<username>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FISHPUBLISHER']"/>
	</username>
	<language>
		<xsl:value-of select="document(concat('file:///',$job))//parameter[@name='language']"/>
	</language>
	<publication-name>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FTITLE']"/>
	</publication-name>
	<version>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='VERSION']"/>
	</version>
	<volume>
		<xsl:value-of select="document(concat('file:///',$ditamap))//*[contains(@class,' bookmap/volume ')]/descendant-or-self::*"/>
	</volume>
	<publication-type>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FISHPUBLICATIONTYPE']"/>
	</publication-type>
	<publication-guid> 
		<xsl:value-of select="document(concat('file:///',$job))//parameter[@name='export-document']"/></publication-guid>
	<contentgroup>
	</contentgroup>
	<accesslevel>
		<xsl:variable name="accessfieldvalue"><xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLACCESSLEVEL']"/></xsl:variable>
		<xsl:value-of select="substring($accessfieldvalue,1,2)"/>
	</accesslevel>
	<products> 
		<xsl:variable name="prodcode"> <xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLPRODUCTCODE']"/>
		</xsl:variable>
 <!-- tokenize by the seperator bar -->
		<xsl:for-each-group select="tokenize($prodcode, ', ')" group-by="substring-before(., '|')">
			<xsl:if test="contains(.,'|')">
				<code>
					<name>
					<xsl:value-of select="current-grouping-key()"/>
					</name>
					<versiontagid>
						<xsl:value-of select="for $str in current-group() return substring-after($str, '|')" separator="," />
                    </versiontagid>
				</code>
			</xsl:if>
        </xsl:for-each-group>
	  <xsl:for-each select="tokenize($prodcode, ',')">
		<xsl:if test="not(contains(.,'|'))">
		<code>
			<name>
				<xsl:value-of select="."/>
			</name>
		</code>
	</xsl:if>
	</xsl:for-each>
   </products>
	<operating-system>
		<xsl:value-of select=	"document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLOPERATINGSYSTEMS']"/>
	</operating-system>
	<supporttask>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLSUPPORTTASK']"/>
	</supporttask>
	<searchable>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLEMCSEARCHABLE']"/>
	</searchable>
	<notification>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLEMCCONTENT']"/>
	</notification>
	<contenttype>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLCONTENTTYPE']"/>
	</contenttype>
	<catalog-name>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLCATALOGNAME']"/>
	</catalog-name>
	<catalog-info>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLSUPPORTCATALOGINFO']"/>
	</catalog-info>
	<publishdate> 
	<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLREACHPUBLISHDATE']"/>
	</publishdate>
	<releasedate>
	<xsl:value-of select="(document(concat('file:///',$ditamap))//published/completed/month)[1]"/><xsl:text> - </xsl:text><xsl:value-of select="(document(concat('file:///',$ditamap))//published/completed/year)[1]"/>
	</releasedate>
	<title>
		<xsl:value-of select="document(concat('file:///',$ditamap))//mainbooktitle"/><xsl:text> </xsl:text><xsl:value-of select="document(concat('file:///',$ditamap))//booktitlealt"/>
	</title>
	<generate-task-labels>
		<xsl:choose>
		<xsl:when test="document(concat('file:///',$ditamap))//*[contains(@class, ' topic/othermeta ')][@name = 'task-labels']">
		<xsl:value-of select="'yes'"/>
		</xsl:when>
		<xsl:otherwise>no</xsl:otherwise>
		</xsl:choose>
	</generate-task-labels>
	<keywords>
		<xsl:for-each select="document(concat('file:///',$ditamap))//*[contains(@class,' topic/keywords ')]/*[contains(@class,' topic/keyword ')]/descendant-or-self::*">
			<xsl:if test="generate-id(key('meta-keywords',text()[1])[1])=generate-id(.)">
			<xsl:if test="position()>1"><xsl:text>, </xsl:text></xsl:if>
			<xsl:value-of select="normalize-space(text()[1])"/>
			</xsl:if>
		</xsl:for-each>
	</keywords>
	<shortdesc>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDESCRIPTION']"/>
		<!--<xsl:value-of select="document(concat('file:///',$ditamap))//*[contains(@class,' map/shortdesc ')][1]/*"/>-->
	</shortdesc>
	<dellrestricted>0</dellrestricted>
	<dellsecuritylevel>TBD</dellsecuritylevel>
	<pdf-file>
<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FTITLE']"/><xsl:text>_</xsl:text><xsl:value-of select="document(concat('file:///',$job))//parameter[@name='language']"/><xsl:text>.pdf</xsl:text>
	</pdf-file>
	<commonfilename><xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='FDELLCOMMONPDFNAME']"/></commonfilename>

<files>
	<xsl:apply-templates select="job/files/file" mode="filelist"/>
</files>
<bundleinfo>
	<created>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='CREATED-ON']"/>
	</created>
	<revised>
		<xsl:value-of select="document(concat('file:///',$inputdir,'/',$pubguid,'.met'))//ishfield[@name='MODIFIED-ON' and @level='version']"/>
	</revised>
</bundleinfo>
<manifest>
	<xsl:for-each select="document(concat('file:///',$ishjob))/job/files/file">
		<xsl:variable name="x"><xsl:value-of select="@uri"/></xsl:variable>
		<file> 
			<xsl:attribute name="guid"><xsl:value-of select="$x"/></xsl:attribute>
			<xsl:attribute name="created"><xsl:value-of select="document(concat('file:///',$inputdir,'/',concat(substring-before($x,'.'),'.met')))//ishfield[@name='CREATED-ON']"/>
			</xsl:attribute>
			<xsl:attribute name="modified">
			<xsl:value-of select="document(concat('file:///',$inputdir,'/',concat(substring-before($x,'.'),'.met')))//ishfield[@name='MODIFIED-ON']"/>
			</xsl:attribute>
		</file>
	</xsl:for-each>
	<xsl:for-each select="tokenize($IMAGELIST, '&#xA;')">
	<xsl:variable name="y"><xsl:sequence select="."/></xsl:variable>
	</xsl:for-each>
</manifest>
</metadata>
		
</xsl:template>
<xsl:template match="files/file" mode="filelist">
	<xsl:variable name="relpath">
	<xsl:call-template name="replace-extension">
	<xsl:with-param name="filename" select="@uri"/>
	<xsl:with-param name="extension" select="$OUTEXT"/>
	</xsl:call-template>
	</xsl:variable>
<xsl:variable name="file-uri" select="@uri"/>
	<file>
		<xsl:apply-templates select="." mode="relpath">
			<xsl:with-param name="relpath" select="$relpath"/>
		</xsl:apply-templates>
		<xsl:apply-templates select="." mode="title"/>
		<xsl:apply-templates select="." mode="created-date"/>
		<xsl:apply-templates select="." mode="revised-date"/>
		<xsl:apply-templates select="." mode="search"/>
		<xsl:apply-templates select="." mode="created-date"/>
		<xsl:if test="$fullditamap//*[contains(@class, ' map/topicref ')][$file-uri = @href or $file-uri = substring-before(@href,'#')][@search='no']">
		<xsl:attribute name="search">no</xsl:attribute>
		</xsl:if>

		<xsl:choose>
		<xsl:when test="$fullditamap//*[contains(@class, ' map/topicref ')]
		  [contains(@chunk,'to-content')]
		  [$file-uri = @href or $file-uri = substring-before(@href,'#')]">
		<meta name="mini-toc" value="yes"/>
		</xsl:when>
		<xsl:otherwise/>
		</xsl:choose>

	</file>
  
</xsl:template>
 
<xsl:template match="*" mode="relpath">
<xsl:param name="relpath"/>
<xsl:attribute name="relpath"><xsl:value-of select="$relpath"/></xsl:attribute>
</xsl:template>
 
<xsl:template match="files/file" mode="title">
<xsl:attribute name="title">
<xsl:choose>
<xsl:when
  test="document(concat('file:///', translate($TEMPDIR, '\', '/'), '/', @uri))">
<xsl:apply-templates
select="(doc(concat('file:///', translate($TEMPDIR, '\', '/'), '/', @uri))//*[contains(@class, ' topic/topic ')])[1]"
mode="get-title"/>
</xsl:when>
<xsl:otherwise>Unknown</xsl:otherwise>
</xsl:choose>
</xsl:attribute>
</xsl:template>
 
<xsl:template match="files/file" mode="created-date">
<xsl:attribute name="created">
<xsl:value-of select="document(concat('file:///',$inputdir,'/',concat(substring-before(@uri,'.xml'),'.met')))//ishfield[@name='CREATED-ON']"/>
</xsl:attribute>
  
</xsl:template>
 
<xsl:template match="files/file" mode="revised-date">
<xsl:attribute name="revised">
<xsl:value-of select="document(concat('file:///',$inputdir,'/',concat(substring-before(@uri,'.xml'),'.met')))//ishfield[@name='MODIFIED-ON']"/>
</xsl:attribute>
</xsl:template>
  
<xsl:template match="files/file[(@resource-only = 'true')]" mode="filelist" priority="10"/>
<xsl:template match="files/file[(@format = 'ditamap')]" mode="filelist" priority="15"/>
<xsl:template match="files/file[(@format = 'html')]" mode="filelist" priority="20"/>
<xsl:template match="files/file[(@format = 'image')]" mode="filelist" priority="25"/>
 
<xsl:template match="*[contains(@class, ' topic/topic ')]" mode="get-title">
  
<xsl:choose>
 
<xsl:when
  test="*[contains(@class, ' topic/titlealts ')]/*[contains(@class, ' topic/searchtitle ')]">
<xsl:apply-templates
select="*[contains(@class, ' topic/titlealts ')][1]/*[contains(@class, ' topic/searchtitle ')][1]"
mode="dita-ot:text-only"/>
</xsl:when>
 
<xsl:when
  test="*[contains(@class, ' topic/titlealts ')]/*[contains(@class, ' map/searchtitle ')]">
<xsl:apply-templates
  select="*[contains(@class, ' topic/titlealts ')][1]/*[contains(@class, ' map/searchtitle ')][1]"
  mode="dita-ot:text-only"/>
</xsl:when>
 
<xsl:when
test="*[contains(@class, ' topic/title ')]">
<xsl:apply-templates
select="*[contains(@class, ' topic/title ')]"
mode="dita-ot:text-only"/>
</xsl:when>
<xsl:otherwise>
<xsl:choose>
<xsl:when test="@type = 'external' or not(not(@format) or @format = 'dita')">
<xsl:value-of select="@href"/>
</xsl:when>
<!-- adding local -->
<xsl:when test="starts-with(@href, '#')">
<xsl:value-of select="@href"/>
</xsl:when>
<xsl:when test="@copy-to and (not(@format) or @format = 'dita')">
<xsl:call-template name="replace-extension">
<xsl:with-param name="filename" select="@copy-to"/>
<xsl:with-param name="extension" select="$OUTEXT"/>
<xsl:with-param name="ignore-fragment" select="true()"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="@href and (not(@format) or @format = 'dita')">
<xsl:call-template name="replace-extension">
<xsl:with-param name="filename" select="@href"/>
<xsl:with-param name="extension" select="$OUTEXT"/>
</xsl:call-template>
</xsl:when>
<xsl:when test="not(@href) or @href = ''"/>
<!-- P017000: error generated in prior step -->
<xsl:otherwise>
<xsl:value-of select="@href"/>
<xsl:call-template name="output-message">
<xsl:with-param name="id" select="'DOTX005E'"/>
<xsl:with-param name="msgparams">%1=<xsl:value-of select="@href"
  /></xsl:with-param>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
  
</xsl:template>
 
</xsl:stylesheet>
