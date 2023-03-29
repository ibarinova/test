<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" 
	xmlns:emc="http://www.emc.com" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:fo="http://www.w3.org/1999/XSL/Format" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema" 
	xmlns:fn="http://www.w3.org/2005/xpath-functions" 
	xmlns:java="http://www.java.com/"
	exclude-result-prefixes="java xs"
	
>
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->

<!-- jholmber: 3/15/2013 added this necessary string function -->
<xsl:function name="emc:substring-before-last">
    <xsl:param name="input" as="xs:string"/>
    <xsl:param name="substr" as="xs:string"/>
    <xsl:sequence 
       select="if ($substr) 
               then 
                  if (contains($input, $substr)) then 
                  string-join(tokenize($input, $substr)
                    [position( ) ne last( )],$substr) 
                  else ''
               else $input"/>
</xsl:function>

 <xsl:function name="java:file-exists" xmlns:file="java.io.File" as="xs:boolean">
	<xsl:param name="file" as="xs:string"/>
	<xsl:param name="base-uri" as="xs:string"/>
 
	<xsl:variable name="absolute-uri" select="resolve-uri($file, $base-uri)" as="xs:anyURI"/>
	<xsl:sequence select="file:exists(file:new($absolute-uri))"/>
</xsl:function>

<xsl:template name="source_topic_checks">

 <xsl:variable name="topicDocument" select="document(concat('file:///',replace(replace(@xtrf,'file:/',''),'\\','/')))" />
 <!--Topic source document: <xsl:value-of select="concat('file:///',replace(replace(@xtrf,'file:/',''),'\\','/'))" /> -->
 <xsl:variable name="rootDirPath" select="concat(emc:substring-before-last($input,'/'),'/')" />
 <xsl:variable name="rootDir" select="concat(emc:substring-before-last(concat('file:///',$input),'/'),'/')" />
 <xsl:variable name="outputclass_attr_values" select="normalize-space($topicDocument//@outputclass)" />

	


<!-- Source topic tests -->
				<!-- nshadrina 12/2018 TKT-665: check for the deprecated attribute outputclass=landscape -->
				<!-- Commented out until Dell content is in
				<xsl:choose>
					<xsl:when test="$topicDocument//*[contains(@outputclass,'landscape')]">
						<xsl:if test="$topicDocument//*[not(contains(@outputclass,'rotated'))]">
							<li class="tagwarning">Validator Warning: The topic includes elements <b>
								<xsl:for-each select="$topicDocument//*[contains(@outputclass,'landscape')]">
										<xsl:value-of select="name()"/> 
										<xsl:text> </xsl:text>
								</xsl:for-each>
							</b> with the deprecated attribute <i>outputclass=landscape</i>. Please apply <i><b>outputclass=rotated</b></i> to the appropriate topic-wide element to achieve a landscaped output of that topic in PDF outputs.</li>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:message>This topic does not have outputclass=landscape attribute.</xsl:message>
					</xsl:otherwise>
				</xsl:choose> -->
				<!-- jholmber: 12/10/12 added index-base test here	  -->
				<xsl:for-each select="$topicDocument//*[contains(@translate,'no')]">
					<li class="tagwarning">Validator Warning: &lt;<xsl:value-of select="local-name()"/>&gt; is not going to be translated.<br/></li>
				</xsl:for-each>
				<xsl:if test="$topicDocument//*/index-base"><li class="tagerror">Validator Error: The element index-base should not be used by authors.</li></xsl:if>
		  
				<!-- jholmber: 7/20/13 shortdesc in a bridge topic gets pushed onto previosu page in bridge topics	  -->
				<xsl:if test="$topicDocument/topic/shortdesc"><li class="tagwarning">Validator Warning: This bridge topic contains a shortdesc element. Content in the shortdesc element will not appear where desired in WebHelp and some other output formats.</li></xsl:if>

				<xsl:if test="$topicDocument//*/indexterm/keyword[../text()[normalize-space(.)]]"><li class="tagerror">Validator Error: Keyword elements within indexterm elements with text also in the indexterm element cause PDF publishing failures.</li></xsl:if>
		  
				
		  		<!-- jholmber: 3/7/13 looking for processing instructions in the actual source -->
		  		
				<!-- jholmber 9/21/15 nobody liked this check. it was just trying to do them a favor! goodbye cruel writing world!
		  			<xsl:for-each select="$topicDocument//processing-instruction('xm-replace_text')">
		  				
		  					<li class="tagwarning">Validator Warning: Topic contains an unrecognized processing instruction. Did you forget to fill in a template field? Related description: <em><xsl:value-of select="." /></em>. </li>
		  					
		  					

		  			</xsl:for-each>
		  		-->	
		  			
		  			<!-- jholmber: 3/15/13 looking for xrefs to maps...big errors!  -->	
		  			<xsl:variable name="rootDir" select="concat(emc:substring-before-last(concat('file:///',replace(replace(@xtrf,'\\','/'),'file:/','')),'/'),'/')" />
		  			
					
		  			<xsl:for-each select="$topicDocument//xref[not(@scope='external')]">
							<!-- NShadrina 05/2017 TKT-561 --> 
							<!-- NShadrina 01/2019 TKT-598 - Removed Visualizer reference -->  							
							<xsl:if test="./@keyref">
								<li class="tagwarning">Validator Warning: A cross reference in this topic uses a keyref "<xsl:value-of select="./@keyref" />" to get its target, which Validator cannot check. Please look at the output.</li>
							</xsl:if>
							<xsl:if test="not(contains(lower-case(./@href),'www')) and not(contains(lower-case(./@href),'http')) and not(contains(lower-case(./@href),'mailto')) and not(./@keyref)">

								<xsl:choose>
								    <xsl:when test="contains(./@href, '#')">
										<xsl:if test="document(concat($rootDir,replace(replace(replace(./@href,substring-after(./@href,'#'),''),'\\','/'),'#','')))/map">
											<li class="tagerror">Validator Error: Topic contains an xref to a DITA map file, which will cause a publishing failure.</li>				
										</xsl:if>
										<xsl:if test="document(concat($rootDir,replace(replace(replace(./@href,substring-after(./@href,'#'),''),'\\','/'),'#','')))/bookmap">
											<li class="tagerror">Validator Error: Topic contains an xref to a DITA bookmap file, which will cause a publishing failure.</li>				
										</xsl:if>
										<xsl:if test="not(starts-with(./@href,'#')) and not(document(concat($rootDir,replace(replace(substring-before(./@href,'#'),'\\','/'),'#',''))))">
											<li class="tagerror">Validator Error: Topic contains an xref to a file that does not exist in this document:<xsl:value-of select="substring-before(./@href,'#')" /></li>
											
										</xsl:if>
								    </xsl:when>
								    <xsl:otherwise>
								    	<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/map">
										<li class="tagerror">Validator Error: Topic contains an xref to a DITA map file, which will cause a publishing failure.</li>				
									</xsl:if>
									
									<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/bookmap">
										<li class="tagerror">Validator Error: Topic contains an xref to a DITA bookmap file, which will cause a publishing failure.</li>				
									</xsl:if>
									
									<xsl:if test="not(document(concat($rootDir,replace(./@href,'\\','/'))))">
										<li class="tagerror">Validator Error: Topic contains an xref to a file that does not exist in this document:<xsl:value-of select="./@href" /></li>
									</xsl:if>
									
								
								    </xsl:otherwise>
								</xsl:choose>

							</xsl:if>					
	  				
		  			</xsl:for-each>
					
					
					<!-- jholmber 1/20/2015 conref checks for JIRA TKT-185-->
					<xsl:for-each select="$topicDocument//@conref | $topicDocument//@conrefend">
							  			
						<!-- We have established that there is a conref or conrefenc in the content -->
						
						<!--
						<xsl:variable name="myTopicID" select="$topicDocument/*/@id" />
						-->
						
						
								<xsl:choose>
								    
									
									
									<xsl:when test="starts-with(., '#')">
										<!--
										<xsl:variable name="myID" select="substring-after(.,concat('#',$myTopicID,'/'))" />
										-->
										<xsl:variable name="myID" select="substring-after(.,'#')" />
										<!-- Now we know this is an internal conref-->
									
									
										<xsl:if test="not($topicDocument//*[exists(@id) and @id=$myID])">
											<li class="tagerror">Validator Error: Topic contains a conref to a missing internal element ID: <xsl:value-of select="$myID" /></li>				
										</xsl:if>
							
										
								    </xsl:when>
									
									
									
									<!-- later we will handle the more popular remote conref-->
									
								    <xsl:otherwise>
					
									
										<xsl:if test="not(starts-with(.,'#')) and not(document(concat($rootDir,replace(replace(substring-before(.,'#'),'\\','/'),'#',''))))">
												<li class="tagerror">Validator Error: Topic contains a conref to a file that does not exist in this document: <xsl:value-of select="substring-before(.,'#')" /></li>
												
										</xsl:if>
										
										<xsl:if test="not(starts-with(.,'#')) and document(concat($rootDir,replace(replace(substring-before(.,'#'),'\\','/'),'#','')))">
												
												 <xsl:variable name="remoteConrefDocument" select="document(concat($rootDir,replace(replace(substring-before(.,'#'),'\\','/'),'#','')))" />
												 
												 <!-- jholmber Sept2015 hotfix3.3
												 
												 <xsl:variable name="myRemoteTopicID" select="$remoteConrefDocument/*/@id" />
												 <xsl:variable name="myID" select="substring-after(.,concat('#',$myRemoteTopicID,'/'))" />
												-->
												
												<xsl:variable name="myID" select="substring-after(.,'/')" />
												
												<xsl:if test="not($remoteConrefDocument//*[exists(@id) and @id=$myID])">
													<li class="tagerror">Validator Error: Conref source topic <xsl:value-of select="replace(replace(substring-before(.,'#'),'\\','/'),'#','')" /> is missing reference element ID: <xsl:value-of select="$myID" /></li>				
												</xsl:if>
										</xsl:if>
									
								
								    </xsl:otherwise>
									
									
								</xsl:choose>

											
	  				
		  			</xsl:for-each>
					
					
					<!-- jholmber: 6/20/13 Check for missing image files in a document -->
					<xsl:for-each select="$topicDocument//image">
						 <xsl:variable name="imagePath" select="replace(concat($rootDir,./@href),'\\','/')" />
		
							<xsl:choose>
								<xsl:when test="java:file-exists(replace($imagePath,'workset/',''), base-uri())">
                
								</xsl:when>
								<xsl:otherwise>
									<li class="tagerror">Validator Error: This topic contains a reference to a missing image: <xsl:value-of select="replace($imagePath,'workset/','')" /></li>				
							
								</xsl:otherwise>
							</xsl:choose>

					</xsl:for-each>
					
					<!--
					<xsl:for-each select="$topicDocument//*[exists(@id)]">
										<xsl:variable name="localID" select="./@id" />
										<xsl:if test="count($topicDocument//*[@id=$localID and not(preceding::*[@id = $localID])])>1">
											<li class="tagerror">Validator Error: Duplicate id attribute in topic elements may cause uncertain behavior in remote or local references to those elements:  <xsl:value-of select="./@id"></xsl:value-of></li>      									
										</xsl:if>
					</xsl:for-each>
					-->
					
					<xsl:for-each-group select="$topicDocument//*" group-by="@id">
						<xsl:if test="current-group()[2]">
							<li class="tagerror">Validator Error: Duplicate id attribute in topic elements may cause uncertain behaviour in remote or local references to those elements:  @id=<xsl:value-of select="@id"/></li>      									
						</xsl:if>
					</xsl:for-each-group>

</xsl:template>




</xsl:stylesheet>