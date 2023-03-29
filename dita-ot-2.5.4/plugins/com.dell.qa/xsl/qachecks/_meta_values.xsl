<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="fo xs fn">

<xsl:template name="meta_values">
<xsl:param name="bookmapFile"/>
<xsl:param name="rootDir"/>

<!--<xsl:for-each select="tokenize(unparsed-text(replace(concat('file:///',$tempDir,'\fullditamap.list'),'\\','/'), 'utf-8'),'\n\r?')">-->
	

<xsl:if test=".//copyrfirst"><li class="pubfail"><span>Publishing Failure Error: </span>Remove text from &lt;copyrfirst&gt;. Release date derives from &lt;published&gt;&lt;completed&gt;&lt;month&gt; and &lt;published&gt;&lt;completed&gt;&lt;year&gt;.</li></xsl:if>
<xsl:if test=".//copyrlast"><li class="pubfail"><span>Publishing Failure Error: </span>Remove text from &lt;copyrlast&gt;. Release date derives from &lt;published&gt;&lt;completed&gt;&lt;month&gt; and &lt;published&gt;&lt;completed&gt;&lt;year&gt;.</li></xsl:if>
<xsl:if test=".//brand"><li class="pubfail"><span>Publishing Failure Error: </span>&lt;brand&gt; is deprecated and should not be used.</li></xsl:if>
<!-- Deleting this flag based on Document by DK for flag categorization
<xsl:if test=".//*[contains(@class, ' topic/brand ') and ancestor::*[contains(@class,' bookmap/bookmeta ')]][not(lower-case(.)='manual' or lower-case(.)='sfits' or lower-case(.)='legal' or lower-case(.)='technote' or lower-case(.)='service manual')]"><li class="metaerror"><span>Metadata Error: </span>Brand should be Manual</li></xsl:if> -->

<xsl:if test=".//*/volume[contains(.,'rev') or contains(., 'Revision') or contains(., 'Rev') or contains(., 'Version') or contains(., 'Document revision')]"><li class="metaerror"><span>Metadata Error: </span>Do not add “rev”, “Rev”, “Version,” “Document revision,” or “Revision” because the string will be automatically added to the output.</li></xsl:if>

<!-- Deleting this flag based on Document by DK for flag categorization
<xsl:if test=".//*[contains(@class, ' topic/brand ') and ancestor::*[contains(@class,' bookmap/bookmeta ')]][not(lower-case(.)='manual' or lower-case(.)='sfits' or lower-case(.)='legal' or lower-case(.)='technote' or lower-case(.)='service manual')]"><li class="metaerror"><span>Metadata Error: </span>Brand should be Manual</li></xsl:if> -->

<!-- Check for unsupported <othermeta> values (IDPL-9848) -->
<xsl:if test=".//othermeta[exists(@name) and not(@name='search') and not(@name='promoted') and not(@name='xref-page-numbers') and not(@name='DELLMLTB_EMEA') and not(@name='DELLMLTB_DAO') and not(@name='DELLMLTB_EMEA1') and not(@name='DELLMLTB_EMEA2') and not(@name='DELLMLTB_APCC1') and not(@name='DELLMLTB_APCC2') and not(@name='DELLMLTB_ALL') and not(@name='PDF-partnumber') and not(@name='mini-toc') and not(@name='task-labels') and not(@name='PDF-releasedate') and not(@name='PDF-docnumber') and not(@name='PDF-currentversion') and not(@name='PDF-previousversion') and not(@name='image_default_alignment') and not(@name='release-type') and not(@name='numbered-headings')] "><li class="metaerror"><span>Metadata Error: </span> Unsupported othermeta value(s) found: <strong><xsl:value-of select="distinct-values(.//othermeta[exists(@name) and not(@name='search') and not(@name='promoted') and not(@name='xref-page-numbers') and not(@name='DELLMLTB_EMEA') and not(@name='DELLMLTB_DAO') and not(@name='DELLMLTB_EMEA1') and not(@name='DELLMLTB_EMEA2') and not(@name='DELLMLTB_APCC1') and not(@name='DELLMLTB_APCC2') and not(@name='DELLMLTB_ALL') and not(@name='PDF-partnumber') and not(@name='mini-toc') and not(@name='task-labels') and not(@name='PDF-releasedate') and not(@name='PDF-docnumber') and not(@name='PDF-currentversion') and not(@name='PDF-previousversion') and not(@name='image_default_alignment') and not(@name='release-type') and not(@name='numbered-headings')]/@name)" separator=", "/></strong></li></xsl:if>

<xsl:if test=".//othermeta[not(@content='yes') and not(@content = 'no') and (@name='mini-toc')]"><li class="invaliddita"><span>Invalid DITA Error: </span>Unsupported attribute value found in mini-toc content. Use yes or no instead. <b>The value used is: <xsl:value-of select="distinct-values(.//othermeta[not(@content='yes') and not(@content = 'no') and (@name='mini-toc')]/@content)" separator=", "/></b></li></xsl:if>
<xsl:if test=".//othermeta[not(@content='yes') and not(@content = 'no') and (@name='task-labels')]"><li class="invaliddita"><span>Invalid DITA Error: </span>Unsupported attribute value found in task-labels content. Use yes or no instead. <b>The value used is: <xsl:value-of select="distinct-values(.//othermeta[not(@content='yes') and not(@content = 'no') and (@name='task-labels')]/@content)" separator=", "/> </b></li></xsl:if>
<xsl:if test=".//othermeta[not(@content='yes') and not(@content = 'no') and (@name='numbered-headings')]"><li class="invaliddita"><span>Invalid DITA Error: </span>Unsupported attribute value found in numbered-headings content. Use yes or no instead. <b>The value used is: <xsl:value-of select="distinct-values(.//othermeta[not(@content='yes') and not(@content = 'no') and (@name='task-labels')]/@content)" separator=", "/> </b></li></xsl:if>

<xsl:if test=".//othermeta[not(@content='left') and not(@content = 'right') and not(@content = 'center') and (@name='image_default_alignment')]"><li class="invaliddita"><span>Invalid DITA Error: </span>Unsupported attribute value found in image_default_alignment content. Use left, right or center instead. <b>The value used is: <xsl:value-of select="distinct-values(.//othermeta[not(@content='left') and not(@content = 'right') and not(@content = 'center') and (@name='image_default_alignment')]/@content)" separator=", "/> </b></li></xsl:if>

<xsl:if test=".//othermeta[not(@content='format-dateTime[Y0001]-[M01]-[D01]') and (@name='PDF-releasedate')]"><li class="invaliddita"><span>Invalid DITA Error: </span>Unsupported attribute value found in PDF-releasedate content. <b>The value used is: <xsl:value-of select="distinct-values(.//othermeta[not(@content='format-dateTime[Y0001]-[M01]-[D01]') and (@name='PDF-releasedate')]/@content)" separator=", "/> </b></li></xsl:if>

<xsl:if test=".//reltable/relcolspec[not(@type='concept' or @type='task' or @type='reference')]"><li class="invaliddita"><span>Invalid DITA Error: </span>Unsupported relcolspec value found. Use Concept or Task or Reference. <b>The value used is: <xsl:value-of select="distinct-values(.//relcolspec[not(@type='concept') and not(@type = 'task') and (@type='reference')]/@type)" separator=", "/> </b></li></xsl:if>

<!--<xsl:if test="not(../*[contains(@class, ' topic/shortdesc ')])"><li class="accerror"><span>Accessibility Error: </span>shortdesc element is missing or empty </li> 
</xsl:if>-->




<xsl:choose>
	<xsl:when test="not(@format)">
		<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/map">
			<li class="metaerror"><span>Metadata Error: </span>Map contains a topicref pointing at a map file, but the format attribute is not set. This will cause the referenced map's content to be missing from the output publication. Set the format="ditamap" attribute on the topicref. Topicref destination: <xsl:value-of select="./@href" /></li>				
		</xsl:if>		
	</xsl:when>
</xsl:choose>


<xsl:variable name="mapDocPath" select="concat($rootDir,./@href)" />
<xsl:variable name="mapDoc" select="document($mapDocPath)" />
<xsl:variable name="tocNoCount" select="count($mapDoc//*/topicref[@toc='no'])" />
	<xsl:choose>
	      <xsl:when test="$tocNoCount = 0" />
		<xsl:when test="$tocNoCount = 1" />
	      <xsl:otherwise>
	        <li class="tagwarning">Validator Warning: Validator standards suggest no more than one topicref with attribute toc set to no per map file.</li>
	      </xsl:otherwise>
	    </xsl:choose>
<xsl:for-each select="$mapDoc//*/topicref">
								<xsl:choose>
								    <xsl:when test="contains(./@format, 'ditamap')">									
										<xsl:if test="not(document(concat($rootDir,replace(./@href,'\\','/')))/map)">
											<li class="metaerror"><span>Metadata Error: </span>Map contains a topicref of type ditamap, but it does not point to an actual map at: <xsl:value-of select="./@href" /></li></xsl:if>
								    </xsl:when>
								</xsl:choose>
								<xsl:choose>
									<xsl:when test="ends-with(./@format, 'dita')">
										<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/map">
											<li class="metaerror"><span>Metadata Error: </span>Map contains a topicref of type dita, but it points to a map (not the expected topic) at: <xsl:value-of select="./@href" /></li></xsl:if>
									</xsl:when>				
								</xsl:choose>
								<xsl:choose>
								    <xsl:when test="not(@format)">
										<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/map">
											<li class="metaerror"><span>Metadata Error: </span>Map contains a topicref pointing at a map file, but the format attribute is not set. This will cause the referenced map's content to be missing from the output publication. Set the format="ditamap" attribute on the topicref. Topicref destination: <xsl:value-of select="./@href" /></li>				
										</xsl:if>
								    </xsl:when>
								</xsl:choose>
								<xsl:if test="not(document(concat($rootDir,replace(./@href,'\\','/'))))">
										<li class="metaerror"><span>Metadata Error: </span>Map contains a topicref to a file that does not exist in this document: <xsl:value-of select="./@href" /></li>			
								</xsl:if>
		  			</xsl:for-each>										
	<!--IDPL 19120 Library Concept reference -->
	<xsl:variable name="ishtype1"> 
		<xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/@ishtype"/>
	</xsl:variable>
	
	<xsl:choose>
		<xsl:when test="$ishtype1='ISHLibrary'">
			<li class="invaliddita"><span>Invalid DITA Error:This object is a library topic and it is referenced directly on the map. </span>
			</li>
		</xsl:when>
		<xsl:otherwise>
			
		</xsl:otherwise>
	</xsl:choose>
	<!--IDPL 19120 Library Concept reference -->
	
</xsl:template>

<!-- Section added to validate the o/p classes in topics and maps -->
<xsl:variable name="terms">
<t>no_stars</t>
<t>nochap</t>
<t>branded</t>
<t>rotated-text</t>
<t>part_number</t>
<t>solutions</t>
<t>technote</t>
<t>abstract</t>
<t>vrm_prefix_ver</t>
<t>vrm_prefix_rel</t>
<t>vrm_prefix_none</t>
<t>show_hide</t>
<t>show_hide_expanded</t>
<t>no_help_folder</t>
<t>landscape</t>
<t>microvideo</t>
<t>legal</t>
<t>manual</t>
<t>landing_page</t>
<t>pagebreak</t>
<t>nopagebreak</t>
</xsl:variable>

<xsl:template name="Output_Class">
<xsl:param name="ggg"/>
<xsl:for-each select="$ggg/descendant-or-self::*[@outputclass]/@outputclass">
<xsl:variable name="y">
<xsl:call-template name="replace">
<xsl:with-param name="curr" select="1"/>
<xsl:with-param name="pos" select="count($terms//t)"/>
<xsl:with-param name="text" select="."/>
</xsl:call-template>
</xsl:variable>
<xsl:choose>
<xsl:when test="normalize-space($y)!=''"><li class="metaerror"><span>Metadata Error: </span>Unsupported attribute found in single or different combination of Outputclass value(s): <xsl:value-of select="replace(normalize-space($y),' ',', ')"/></li></xsl:when>
<xsl:otherwise>
	
</xsl:otherwise>
</xsl:choose>
</xsl:for-each>
</xsl:template>



<xsl:template name="replace">
<xsl:param name="curr"/>
<xsl:param name="pos"/>
<xsl:param name="text"/>

<xsl:choose>
<xsl:when test="$curr &lt;= $pos">
<xsl:call-template name="replace">
<xsl:with-param name="curr" select="$curr + 1"/>
<xsl:with-param name="pos" select="count($terms//t)"/>
<xsl:with-param name="text" select="replace($text,$terms//t[$curr],'')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>

</xsl:template>


<!--<xsl:variable name="terms">
<t>no_stars</t>
<t>nochap</t>
<t>branded</t>
<t>part_number</t>
<t>solutions</t>
<t>technote</t>
<t>abstract</t>
<t>vrm_prefix_ver</t>
<t>vrm_prefix_rel</t>
<t>vrm_prefix_none</t>
<t>show_hide</t>
<t>show_hide_expanded</t>
<t>no_help_folder</t>
<t>landscape</t>
<t>microvideo</t>
<t>legal</t>
<t>manual</t>
<t>landing_page</t>
<t>pagebreak</t>
<t>nopagebreak</t>
</xsl:variable>

<xsl:template name="Output_Class">

<xsl:variable name="z"><xsl:value-of  select="//*[@outputclass]/@outputclass"/></xsl:variable>
<xsl:variable name="y">
<xsl:call-template name="replace">
<xsl:with-param name="curr" select="1"/>
<xsl:with-param name="pos" select="count($terms//t)"/>
<xsl:with-param name="text" select="$z"/>
</xsl:call-template>
</xsl:variable>
<xsl:choose>
<xsl:when test=".//*[exists(@outputclass) and normalize-space($y)!='']"><li class="tagerror"><span>Validator Error: Unsupported attribute found in single or different combination of Outputclass value(s): <xsl:value-of select="replace(normalize-space($y),' ',', ')"/></span></li></xsl:when>
<xsl:otherwise>
	
</xsl:otherwise>
</xsl:choose>
</xsl:template>



<xsl:template name="replace">
<xsl:param name="curr"/>
<xsl:param name="pos"/>
<xsl:param name="text"/>

<xsl:choose>
<xsl:when test="$curr &lt;= $pos">
<xsl:call-template name="replace">
<xsl:with-param name="curr" select="$curr + 1"/>
<xsl:with-param name="pos" select="count($terms//t)"/>
<xsl:with-param name="text" select="replace($text,$terms//t[$curr],'')"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$text"/>
</xsl:otherwise>
</xsl:choose>

</xsl:template> -->

</xsl:stylesheet>