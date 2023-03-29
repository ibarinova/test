<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:qa="****Function Processing****" exclude-result-prefixes="fo xs fn qa">
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->

<xsl:function name="qa:checkCase">
    <xsl:param name="string"/>
		<xsl:variable name="lowString" select="lower-case($string)"/>
		<xsl:variable name="regString" select="$string"/>
		<xsl:choose>
			<xsl:when test="$lowString = $regString">
					<!--<xsl:value-of select="string('PASS')"/>-->
			</xsl:when>
			<xsl:when test="not($lowString = $regString)">
					<xsl:value-of select="string( '- FAILED Interaction filename test - Change XML filename to lowercase')"/>
			</xsl:when>
		</xsl:choose>
  </xsl:function>
  
<xsl:template name="language_standards">
<!-- Check for file names undesireable characters --> <!-- not sure if this works -->
<xsl:if test="./@xtrf[matches(., '[!~]' )]"><li class="metaerror"><span>Metadata Error: </span>DITA file contains a space or undesireable character. Please rename the file, and only include lower case letters and underscores.</li></xsl:if>
<xsl:if test="./@xtrf[contains(lower-case(.), 'zzz' )]"><li class="invaliddita"><span>Invalid DITA Error: </span>This file is archived, your publication should not refer this file and this file will be removed from repository soon.</li></xsl:if>

<!-- Support filenaming standards (IDPL-9845)-->
<xsl:variable name="file1"> <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>
</xsl:variable>

<xsl:choose>
								<xsl:when test="$file1[matches(.,'^[.a-z0-9_-]*$')]">
									<!--FTITLE of the File: <xsl:value-of select="$file1"/><br/> -->
								</xsl:when>
								<xsl:otherwise>
									 <!--Issue found in FTITLE: <span class="tagerror"><xsl:value-of select="$file1"/></span>-->
									<li class="tagwarning">Validator warning: Filename is not compliant with standards. See <a href="https://confluence.gtie.dell.com/display/IKB/Tridion+object+naming+conventions">IDD Knowledge Base Articles.</a></li>
								</xsl:otherwise>
							</xsl:choose>
<xsl:if test=".//*/cite[not(contains(lower-case(.), 'guide')) and not(contains(lower-case(.),'manual')) and not(contains(lower-case(.),'worksheet')) and not(contains(lower-case(.),'matrix')) and not(contains(lower-case(.),'white paper')) and not(contains(lower-case(.),'release notes')) and not(contains(lower-case(.),'technical note')) and not(contains(lower-case(.),'catalog')) and not(contains(lower-case(.),'list')) and not(contains(lower-case(.),'technical module'))]"><li class="tagwarning">Validator Warning: It appears that you are using the cite element to reference something other than a Catalog, Guide, Manual, Worksheet, Matrix, White Paper, Release Notes, Technical Note, List, or Technical Module. This violates the standards for use of the element.</li></xsl:if>							
</xsl:template>
</xsl:stylesheet>