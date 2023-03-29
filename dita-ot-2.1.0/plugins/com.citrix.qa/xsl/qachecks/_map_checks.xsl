<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:emc="http://www.emc.com" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" >
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->



<xsl:template name="map_checks">
	<xsl:param name="bookmapFile"/>
	<xsl:param name="rootDir"/>

	<xsl:variable name="mapDoc" select="document($bookmapFile)" />
	<xsl:variable name="thisMapMet" select="replace(concat($rootDir,replace(replace(./@href,'.ditamap','.met'),'.xml','.met')),'\\','/')" />
	<xsl:variable name="thisMapMetDoc" select="document($thisMapMet)" />
						<p>
							<b>Map Title: <xsl:value-of select="$mapDoc/map/title"/></b>
							
							<br />
							
							<!-- Trisoft-aware code added by EMC to read metadata out of .met files -->
							GUID: <xsl:value-of select="$thisMapMetDoc/ishobject/@ishref"/><br></br>	
							
							<!-- NShadrina 07/2017 : TKT-437  Checking if FTITLE is alpha-numerical -->
							<xsl:variable name="thisMapFtitle" select="$thisMapMetDoc/ishobject/ishfields/ishfield[@name='FTITLE']/text()" />
							<xsl:choose>
								<xsl:when test="$thisMapFtitle[matches(.,'^[a-z0-9_-]*$')]">
									Object FTITLE: <xsl:value-of select="$thisMapFtitle"/><br/>
								</xsl:when>
								<xsl:otherwise>
									Object FTITLE: <span class="tagerror"><xsl:value-of select="$thisMapFtitle"/></span>
									<li class="tagerror">Validator Error: Filename is not compliant with standards. See <a href="https://confluence.gtie.dell.com/display/IKB/Tridion+object+naming+conventions">IDD Knowledge Base Articles.</a></li>
									
									<!--<ul><li class="tagerror">Validator Error: Non-standard character in FTITLE. Map and topic FTITLEs should only contain the characters aA through zZ, 0 through 9, underscore (_), and hyphen (-).</li></ul>-->
								</xsl:otherwise>
							</xsl:choose>	
							
							Object Version: <xsl:value-of select="$thisMapMetDoc/ishobject/ishfields/ishfield[@name='VERSION']/text()"/><br></br>
							Object Revision: <xsl:value-of select="$thisMapMetDoc/ishobject/ishfields/ishfield[@name='FISHREVCOUNTER']/text()"/><br></br>
							Author's Login ID: <xsl:value-of select="$thisMapMetDoc/ishobject/ishfields/ishfield[@name='FAUTHOR']/text()"/><br></br>
							Object Workflow Status: <xsl:value-of select="$thisMapMetDoc/ishobject/ishfields/ishfield[@name='FSTATUS']/text()"/><br></br>
							
						</p>
						<ul>
							<!-- jholmber: 6/20/13: Check the map topicrefs for errors -->
							<xsl:call-template name="map_checks_tests">
								<xsl:with-param name="rootDir" select="$rootDir" />
							</xsl:call-template>
						</ul>
				
						<hr />
						
<!-- Flag if <notices> is not present (IDPL-9663) 
<xsl:if test="not(//notices)"><li class="tagerror">Validator Error: &lt; notices &gt; element must be present in order to produce copyright</li></xsl:if> -->






<!-- Check for unsupported outputclass values (IDPL-9848)

<xsl:if test=".//*[exists(@outputclass) and not(@outputclass='notice') and not(@outputclass='confidential') and not(@outputclass='omit_chapter_numbers') and not(@outputclass='no_stars') and not(@outputclass='nochap') and not(@outputclass='technote') and not(@outputclass='abstract') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='vrm_prefix_rev') and not(@outputclass='vrm_prefix_none')] "><li class="tagerror">Validator Error: Unsupported Outputclass attribute value(s) found: <xsl:value-of select=".//*[exists(@outputclass) and not(@outputclass='notice') and not(@outputclass='confidential') and not(@outputclass='omit_chapter_numbers') and not(@outputclass='no_stars') and not(@outputclass='nochap') and not(@outputclass='technote') and not(@outputclass='abstract') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='vrm_prefix_rev')  and not(@outputclass='vrm_prefix_none')]/@outputclass " separator=", " /></li></xsl:if>

Check for unsupported <othermeta> values (IDPL-9848)
<xsl:if test=".//othermeta/@name[contains(., 'section-titles-in-toc') or contains(., 'shorttitle')  or contains(., 'topicref-title-in-footer')  or contains(., 'PDF-releasedate')  or contains(., 'part number')  or contains(., 'language packs')  or contains(., 'nologo')]">
	<li class="tagerror"><span>ERROR: </span>  Unsupported othermeta value(s) found: 
		<xsl:for-each-group select=".//othermeta[@name='section-titles-in-toc' or @name='shorttitle'  or @name='topicref-title-in-footer'  or @name='PDF-releasedate'  or @name='part number'  or @name='language packs'  or @name='nologo' ]" group-by="@name" >
  <object><xsl:value-of select="current-grouping-key()" />, </object>
</xsl:for-each-group>
	</li>
</xsl:if> -->
						
						
						
						
						<xsl:for-each select="$mapDoc//topicref[@format='ditamap']">					
							<xsl:call-template name="map_checks">
								<xsl:with-param name="rootDir" select="$rootDir" />
								<xsl:with-param name="bookmapFile"/>
							</xsl:call-template>
						</xsl:for-each>

</xsl:template>

<xsl:template name="map_checks_tests">
	<xsl:param name="rootDir"/>
	<xsl:variable name="mapDocPath" select="concat($rootDir,./@href)" />
	<xsl:variable name="mapDoc" select="document($mapDocPath)" />


	<!-- jholmber: 3/13/2013 adding a sample map test for future reference -->
	<xsl:variable name="tocNoCount" select="count($mapDoc//*/topicref[@toc='no'])" />
	<xsl:choose>
	      <xsl:when test="$tocNoCount = 0" />
		<xsl:when test="$tocNoCount = 1" />
	      <xsl:otherwise>
	        <li class="tagwarning">Validator Warning: Validator standards suggest no more than one topicref with attribute toc set to no per map file.</li>
	      </xsl:otherwise>
	    </xsl:choose>


		  			<!-- jholmber: 3/20/13 looking for topicrefs to maps  -->	
		  			<xsl:for-each select="$mapDoc//*/topicref">
								<xsl:choose>
								    <xsl:when test="contains(./@format, 'ditamap')">
									
									
										<xsl:if test="not(document(concat($rootDir,replace(./@href,'\\','/')))/map)">
											<li class="tagerror">Validator Error: Map contains a topicref of type ditamap, but it does not point to an actual map at: <xsl:value-of select="./@href" /></li>				
										</xsl:if>
										
								    </xsl:when>
								
								</xsl:choose>
								
								<xsl:choose>
									<xsl:when test="ends-with(./@format, 'dita')">
								
										<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/map">
											<li class="tagerror">Validator Error: Map contains a topicref of type dita, but it points to a map (not the expected topic) at: <xsl:value-of select="./@href" /></li>				
										</xsl:if>
																		
									</xsl:when>
																
								</xsl:choose>
								
								<!-- jholmber: 7/20/13 check for topicref to map without format attribute defined at all-->
								<xsl:choose>
								    <xsl:when test="not(@format)">
									
									
										<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/map">
											<li class="tagerror">Validator Error: Map contains a topicref pointing at a map file, but the format attribute is not set. This will cause the referenced map's content to be missing from the output publication. Set the format="ditamap" attribute on the topicref. Topicref destination: <xsl:value-of select="./@href" /></li>				
										</xsl:if>
										
								    </xsl:when>
								
								</xsl:choose>
								
								
								<!-- jholmber 7/9/2014 JIRA TKT-115 check topicrefs in maps for existent target files-->
								<xsl:if test="not(document(concat($rootDir,replace(./@href,'\\','/'))))">
										<li class="tagerror">Validator Error: Map contains a topicref to a file that does not exist in this document: <xsl:value-of select="./@href" /></li>			
								</xsl:if>
								<!--<xsl:if test=".//frontmatter/notices"><li class="tagerror">Validator Error: RSA copyright needs to be specified on the href of the notices element, not as a separate topicref. Check your bookmap file.</li></xsl:if> -->


								
								
								
								
								
		  			</xsl:for-each>
					
					<!-- jholmber 11/08/13 -->
					<xsl:for-each select="$mapDoc//*/reltable/relrow/relcell/topicref">
						<xsl:choose>
							<xsl:when test="@type">
								<xsl:if test="not(@type='concept') and not(@type='task') and not(@type='reference') and not(@type='glossentry') and not(@type='cli_reference') and not(@type='topic')">
									<li class="tagerror">Validator Error: Reltable topicref is of an unknown type: <xsl:value-of select="@type" /></li>				
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
									<li class="tagerror">Validator Error: Reltable topicref is missing the required type definition.</li>				
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
		  <!-- end map checks -->
		  
		  
</xsl:template>
</xsl:stylesheet>