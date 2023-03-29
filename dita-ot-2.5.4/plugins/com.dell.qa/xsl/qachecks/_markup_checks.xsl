<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" exclude-result-prefixes="xs">
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->
<xsl:template name="markup_checks">
<xsl:variable name="sp">
	<strong><xsl:value-of select="preceding-sibling::title[contains(@class, ' topic/title ')]"/></strong>
</xsl:variable>
<xsl:variable name="spp">
<xsl:value-of select="preceding-sibling::mainbooktitle[contains(@class, ' bookmap/mainbooktitle ')]"/>
</xsl:variable>


<!-- Valid markup that we don't want to use -->
<!-- Valid markup that we don't want to use -->
<xsl:if test=".//b"><li class="semantic"><span>Semantic tagging Error: </span>Do not use typographic markup &lt;b&gt;</li></xsl:if>
<xsl:if test=".//i"><li class="semantic"><span>Semantic tagging Error: </span>Do not use typographic markup &lt;i&gt;</li></xsl:if>
<xsl:if test=".//u"><li class="semantic"><span>Semantic tagging Error: </span>Do not use typographic markup &lt;u&gt;</li></xsl:if>
<xsl:if test=".//ul[not(*)]"><li class="missingcontent"><span>Missing content Error: </span>Unordered list (UL) element is empty.</li></xsl:if>
<xsl:if test=".//ol[not(*)]"><li class="missingcontent"><span>Missing content Error: </span>Ordered list (OL) element is empty.</li></xsl:if>
<xsl:if test=".//ol[not(li)]"><li class="missingcontent"><span>Missing content Error: </span>ordered list (UL) is missing li element.</li></xsl:if>
<xsl:if test=".//ul[not(li)]"><li class="missingcontent"><span>Missing content Error: </span>Unordered list (UL) is missing li element.</li></xsl:if>
<!--<xsl:if test=".//li[not(*)]"><li class="missingcontent"><span>Missing content Error: </span>li element is empty.</li></xsl:if>-->
<xsl:if test=".//li/text()=''"><li class="missingcontent"><span>Missing content Error: </span>li element is empty.</li></xsl:if>
<xsl:if test=".//dl/dlentry[not(dd)]"><li class="missingcontent"><span>Missing content Error: </span>DLEntry is missing DD</li></xsl:if>
<xsl:if test=".//dl/dlentry[not(dt)]"><li class="missingcontent"><span>Missing content Error: </span>DLEntry is missing DT</li></xsl:if>
<xsl:if test=".//dl[not(dlentry)]"><li class="missingcontent"><span>Missing content Error: </span>DLEntry is empty or missing</li></xsl:if>
<xsl:if test=".//dd[not(normalize-space(.))]"><li class="missingcontent"><span>Missing content Error: </span>dd element is empty.</li></xsl:if>
<xsl:if test=".//dt[not(normalize-space(.))]"><li class="missingcontent"><span>Missing content Error: </span>dt element is empty.</li></xsl:if>
<!-- commenting as DK said it is obselete on flag categorization email
<xsl:if test=".//fig[not(title)  and count(*)>0]"><li class="tagerror"><span>Validator Error: </span>Figure does not have a title or title is empty</li></xsl:if> -->
<xsl:if test=".//fig[not(*)]"><li class="missingcontent"><span>Missing content Error: </span>Figure element is empty</li></xsl:if>
<xsl:if test=".//image[not(alt)] or .//image/alt[normalize-space(.)='']"><li class="accerror"><span>Accessibility Error: </span>Image  does not have an alt tag  or alt tag is empty</li></xsl:if>
<!--<xsl:if test=".//image[not(normalize-space(.))]"><li class="missingcontent"><span>Missing content Error: </span>Image element is empty.</li></xsl:if> -->
<xsl:if test=".//image[not(@href)]"><li class="missingcontent"><span>Missing content Error: </span>Image element is empty.</li></xsl:if>
<xsl:for-each select=".//title[normalize-space(.)='']"><li class="missingcontent"><span>Missing content Error: </span><xsl:value-of select = "name(..)"/> Title element is empty</li></xsl:for-each>
<!--<xsl:if test=".//fig[not(title)]"><li class="accerror"><span>Accessibility Error: </span>Figure is missing <i>title</i> element. </li></xsl:if> -->
<xsl:if test=".//table[not(title)]"><li class="accerror"><span>Accessibility Error: </span>Table is missing <i>title</i> element. </li></xsl:if>
<!--<xsl:if test=".//table[not(desc)] or .//table/desc[normalize-space()='']"><li class="accerror"><span><span>Accessibility Error: </span>Table is missing <i>desc</i> element or it is empty.</span></li></xsl:if>-->
<xsl:if test=".//tgroup[not(thead)]"><li class="accerror"><span>Accessibility Error: </span>Empty or missing <i>thead</i> element in the table.</li></xsl:if>

<xsl:if test=".//strow[not(normalize-space(.)) and not(*)]"><li class="missingcontent"><span>Missing content Error: </span>Simple table has empty row(s). Consider deleting the empty row(s).</li></xsl:if>
<xsl:if test=".//row/entry[not(normalize-space(.)) and not(*)]"><li class="missingcontent"><span>Missing content Error: </span>Table has empty cell(s). Consider merging empty cell(s) or add some text, such as N/A, None, Not Applicable or just a hyphen.</li></xsl:if>
<xsl:if test=".//row[not(normalize-space(.))]"><li class="missingcontent"><span>Missing content Error: </span>Table has empty row(s). Consider deleting the empty row(s).</li></xsl:if>
<xsl:if test=".//image[exists(@alt)]"><li class="tagwarning">Information: Images in the topic contain alt text in the alt attribute. Move the alt text in the alt attribute to the &lt;alt&gt; element.</li></xsl:if>


<xsl:if test=".//step/cmd[not(normalize-space(.)) and not(*)]"><li class="missingcontent"><span>Missing content Error: </span>Step element is empty</li></xsl:if>
<xsl:if test=".//substep/cmd[not(normalize-space(.)) and not(*)]"><li class="missingcontent"><span>Missing content Error: </span>Substep element is empty</li></xsl:if>

<!--<xsl:if test=".//image[not(alt)]"><li class="accerror"><span>Accessibility Error: </span>Image does not have alternate text</li></xsl:if> -->
<xsl:if test=".//thead[not(preceding-sibling::colspec)]"><li class="tagwarning"><span>Validator warning: </span>colspec element is missing in table.</li></xsl:if>
<xsl:if test=".//colspec[not(contains(@colwidth,'*'))]"><li class="tagwarning"><span>Validator warning: </span>Table columns should be size proportionated (Colspec width must contain *). </li></xsl:if>
<!--<xsl:if test=".//*[contains(@class, ' topic/topic ') and not(//shortdesc)]"><li class="accerror"><span>Accessibility Error: </span>shortdesc is missing</li></xsl:if> -->

<!--<xsl:if test=".//xref[matches(@href, '%20|\s+')] and (@scope='local')"><li class="tagerror"><span>Validator Error: </span>HREF target contains a space</li></xsl:if>-->
<!--<xsl:if test=".//@href[contains(., '%20')]"><li class="tagerror"><span>Validator Error: </span>HREF target contains a space</li>
<xsl:message>href link<xsl:copy-of select=".//@href"/></xsl:message>
</xsl:if> -->

<xsl:if test=".//note/@type[contains(., 'attention') or contains(., 'danger') or contains(., 'fastpath') or contains(., 'important') or contains(., 'notice') or contains(., 'remember') or contains(., 'restriction') or  contains(., 'tip')]">
	<li class="invaliddita"><span>Invalid DITA Error: </span>Unsupported Note attribute value(s) found: 
		<xsl:for-each select=".//note[@type='attention' or @type='fastpath'  or @type='danger' or @type='important' or @type='notice' or @type='remember' or @type='restriction' or @type='tip']"><strong><xsl:value-of select="@type"/></strong><xsl:if test="position() != last()">
		<xsl:text>,</xsl:text>
		</xsl:if></xsl:for-each><xsl:text>. Use Note, Caution, or Warning instead</xsl:text>
	</li>
</xsl:if>
<!--  Need to add the section 3.2.22 by code cleanup and clearing issues -->
<xsl:if test=".//@href[contains(., 'HTTP:') or contains(., 'http:')]"><li class="tagwarning"><span>Validator warning: </span>Ensure your URL begins with as ‘https’ designation (unless you are linking to mailto or ftp or similar non-standard URI. Ex: https://www.dell.com/support/ .</li></xsl:if>
<xsl:if test=".//xref[not(@scope='external') and starts-with(@href, 'https')]"><li class="tagwarning"><span>Validator warning: </span>It is mandatory to define attribute scope as external for web links.</li></xsl:if>
<!--  Need to add the section 3.2.24 by code cleanup and clearing issues -->
<xsl:if test=".//object[(contains(@data,'ooyala') or contains(@data,'youtube'))]"><li class="invaliddita"><span>Invalid DITA Error: </span>Brightcove is the approved video source. Do not use YouTube or Ooyala source links to stream videos.</li> 
</xsl:if>
<xsl:if test=".//*/fig[exists(@outputclass) and @outputclass='landscape']"><li class="incorrectnest"><span>Incorrect nesting Error: </span>A figure (fig) has an outputclass defined as landscape but is nested within another element. The figure must be under the topic's body element.</li></xsl:if>
<xsl:if test=".//*/table[exists(@outputclass) and @outputclass='landscape']"><li class="incorrectnest"><span>Incorrect nesting Error: </span>A table has an outputclass defined as landscape but is nested within another element. It must be under the topic's body element.</li></xsl:if>
<xsl:if test=".//*/image[exists(@outputclass) and @outputclass='landscape']"><li class="incorrectnest"><span>Incorrect nesting Error: </span>An image has an outputclass defined as landscape but is nested within another element. It must be under the topic's body element.</li></xsl:if>
<xsl:if test=".//*/codeblock[exists(@outputclass) and @outputclass='landscape']"><li class="incorrectnest"><span>Incorrect nesting Error: </span>A codeblock has an outputclass defined as landscape but is nested within another element. It must be under the topic's body element.</li></xsl:if>
<xsl:if test=".//fig/image[exists(@outputclass)]"><li class="incorrectnest"><span>Incorrect nesting Error: </span>An image has an outputclass defined within a figure. Set the corresponding output class on the fig element if you are nesting the image element.</li></xsl:if>
<xsl:if test=".//image[@width]"><li class="tagwarning"><span>Validator warning: </span>Image has width set. Width should be determined by image source.</li></xsl:if>

<xsl:if test=".//dl[normalize-space(.)='' and not(*)]"><li class="missingcontent"><span>Missing content Error: </span>DL element is empty</li></xsl:if>
<xsl:if test=".//p[normalize-space(.)='' and not(*)]"><li class="missingcontent"><span>Missing content Error: </span>P element is empty</li></xsl:if>
<xsl:if test=".//xref[not(@href)]"><li class="invaliddita"><span>Invalid DITA Error: </span>Add @href to XREF</li></xsl:if>
<xsl:if test="@xtrf[contains(lower-case(.), 'zzz' )]"><li class="invaliddita"><span>Invalid DITA Error: </span>This file is archived, your publication should not refer this file and this file will be removed from repository soon.</li></xsl:if>
<!--<xsl:if test=".//@href[contains(., 'HTTP:') or contains(., 'http:')] or .//xref[starts-with(@href, 'www.') or  starts-with(@href, 'WWW.')]"><li class="tagerror"><span>Validator Error: </span>You must add complete URL in href attribute. Ex: https://www.dell.com/support/ .</li></xsl:if> -->

<xsl:if test=".//xref[(if(contains(@href,'#')) then not(substring-after(@href,'#')=//*[@id]) else not(@href=//*[@id])) and starts-with(@href, 'GUID-')]"><li class="invaliddita"><span>Invalid DITA Error: </span>Topic contains an xref to a file that does not exist in this document</li></xsl:if>
<xsl:if test=".//xref[not(@scope='external') and not(starts-with(@href, '#'))]"><li class="invaliddita"><span>Invalid DITA Error: </span>You must define attribute scope as ‘external’.</li></xsl:if>
<xsl:if test=".//xref[not(@href)]"><li class="invaliddita"><span>Invalid DITA Error: </span>You must define attribute format as ‘https’ only. </li></xsl:if>
<!--<xsl:if test=".//*[@translate='no' and not(name()='apiname' or name()='cmdname' or name()='codeblock' or name()='codeph' or name()='data' or name()='draft-comment' or name()='filepath' or name()='msgblock' or name()='msgph'  or name()='othermeta' or name()='platform' or name()='prodname' or name()='bookpartno' or name()='booknumber')]"><xsl:for-each select="//*[@translate='no' and not(name()='apiname' or name()='cmdname' or name()='codeblock' or name()='codeph' or name()='data' or name()='draft-comment' or name()='filepath' or name()='msgblock' or name()='msgph'  or name()='othermeta' or name()='platform' or name()='prodname' or name()='bookpartno' or name()='booknumber')]"><li class="tagwarning"><span>Validator warning: </span><strong>&lt;<xsl:value-of select="name()"/>&gt;</strong> tag content will not get translated.</li></xsl:for-each></xsl:if> -->
<xsl:if test=".//dl[not(dlentry) and not(*)]"><li class="missingcontent"><span>Missing content Error: </span>DLEntry is empty or missing</li></xsl:if>
<!--commented the duplicated DL section
<xsl:if test=".//dl[normalize-space(.)='' and not(*)]"><li class="tagerror"><span>Validator Error: </span>DL element is empty</li></xsl:if> -->
<xsl:if test="@xtrf=$resourceId//rid/fn"><li class="invaliddita"><span>Invalid DITA Error: </span> "<xsl:variable name="xtrf" select="@xtrf"/><strong><xsl:value-of select="$resourceId//rid[$xtrf=fn]/id"/></strong>" resourceid must be unique within document</li></xsl:if>
<!--commented the old outputclass section -->
<!--<xsl:if test=".//*[exists(@outputclass) and not(@outputclass='landscape') and not(@outputclass='microvideo')]"><li class="tagerror"><span>Validator Error:</span> Unsupported outputclass value(s) found: <strong><xsl:value-of select="distinct-values(.//*[exists(@outputclass) and not(@outputclass='landscape') and not(@outputclass='microvideo')]/@outputclass)" separator=", "/></strong></li></xsl:if>
<xsl:if test=".//keyword[exists(@outputclass) and not(@outputclass='branded')]"><li class="tagerror"><span>Validator Error:</span> Unsupported outputclass value(s) found at Keyword: <strong><xsl:value-of select="distinct-values(.//keyword[exists(@outputclass) and not(@outputclass='branded')]/@outputclass)" separator=", "/></strong></li></xsl:if> -->
</xsl:template>
<xsl:template name="source_topic_checks">

 <xsl:variable name="topicDocument" select="document(concat('file:///',replace(replace(@xtrf,'file:/',''),'\\','/')))" />
 <xsl:variable name="rootDirPath" select="concat(substring-before($input,'/'),'/')" />
 <xsl:variable name="rootDir" select="concat(substring-before(concat('file:///',$input),'/'),'/')" />
 <xsl:variable name="outputclass_attr_values" select="normalize-space($topicDocument//@outputclass)" />		  			
<!--<xsl:for-each select="$topicDocument//processing-instruction('xm-replace_text')[not(ancestor-or-self::*[@keyref]) or not(ancestor-or-self::*[@xref])]">
		  					<li class="tagwarning"><span>Validator warning: </span>Topic contains an unrecognized processing instruction. Did you forget to fill in a template field? Related description: <em><xsl:value-of select="." /></em>. </li>
</xsl:for-each> -->
<xsl:for-each select="$topicDocument//processing-instruction('xm-replace_text')">
	  				
		<xsl:choose> 
			<xsl:when test= "not(ancestor-or-self::*[@keyref] or ancestor-or-self::xref)" >
				<li class="tagwarning"><span>Validator warning: </span>Topic contains an unrecognized processing instruction. Did you forget to fill in a template field? Related description: <em><xsl:value-of select="." /></em>. </li>
			</xsl:when>
		</xsl:choose>			
				
</xsl:for-each>


		  			<xsl:variable name="rootDir" select="concat(substring-before(concat('file:///',replace(replace(@xtrf,'\\','/'),'file:/','')),'/'),'/')" />
		  			<xsl:for-each select="$topicDocument//xref[not(@scope='external')]">
							<xsl:if test="./@keyref">
								<li class="tagwarning"><span>Validator warning: </span>A cross reference in this topic uses a keyref "<strong><xsl:value-of select="./@keyref" /></strong>" to get its target, which Validator cannot check. Please look at the output.</li>
							</xsl:if>
							<xsl:if test="not(contains(lower-case(./@href),'www')) and not(contains(lower-case(./@href),'http')) and not(contains(lower-case(./@href),'mailto')) and not(./@keyref)"> </xsl:if>

								<!--<xsl:choose>
								    <xsl:when test="contains(./@href, '#')">
										<xsl:if test="document(concat($rootDir,replace(replace(replace(./@href,substring-after(./@href,'#'),''),'\\','/'),'#','')))/map">
											<li class="tagerror"><span>Validator error: </span>Topic contains an xref to a DITA map file, which will cause a publishing failure.</li>				
										</xsl:if>
										<xsl:if test="document(concat($rootDir,replace(replace(replace(./@href,substring-after(./@href,'#'),''),'\\','/'),'#','')))/bookmap">
											<li class="tagerror"><span>Validator error: </span>Topic contains an xref to a DITA bookmap file, which will cause a publishing failure.</li>				
										</xsl:if>
										<xsl:if test="not(starts-with(./@href,'#')) and not(document(concat($rootDir,replace(replace(substring-before(./@href,'#'),'\\','/'),'#',''))))">
											<li class="tagerror"><span>Validator error: </span>Topic contains an xref to a file that does not exist in this document:<xsl:value-of select="substring-before(./@href,'#')" /></li>
										</xsl:if>
								    </xsl:when>
								    <xsl:otherwise>
								    	<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/map">
										<li class="tagerror"><span>Validator error: </span>Topic contains an xref to a DITA map file, which will cause a publishing failure.</li>				
									</xsl:if>
									
									<xsl:if test="document(concat($rootDir,replace(./@href,'\\','/')))/bookmap">
										<li class="tagerror"><span>Validator error: </span>Topic contains an xref to a DITA bookmap file, which will cause a publishing failure.</li>				
									</xsl:if>
									
									<xsl:if test="not(document(concat($rootDir,replace(./@href,'\\','/'))))">
										<li class="tagerror"><span>Validator error: </span>Topic contains an xref to a file that does not exist in this document:<xsl:value-of select="./@href" /></li>
									</xsl:if>
								    </xsl:otherwise>
								</xsl:choose> -->
		  			</xsl:for-each>
					
</xsl:template>
</xsl:stylesheet>