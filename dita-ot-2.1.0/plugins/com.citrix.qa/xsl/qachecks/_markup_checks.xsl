<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" >
<!-- Use this function to handle the following checks...shows error in xmlspy, but 2.0 should be able to handle xsl:function-->

<xsl:template name="markup_checks">


<!-- Valid markup that we don't want to use -->

<!--11/14/12: jholmber changes the three entries below to error instead of warning -->
<xsl:if test=".//b"><li class="tagerror">Validator Error: Do not use typographic markup b.</li></xsl:if>
<xsl:if test=".//i"><li class="tagerror">Validator Error: Do not use typographic markup i.</li></xsl:if>
<xsl:if test=".//u"><li class="tagerror">Validator Error: Do not use typographic markup u.</li></xsl:if>

<!-- Support filenaming standards (IDPL-9845)-->
<xsl:variable name="file1"> <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>
</xsl:variable>

<xsl:choose>
								<xsl:when test="$file1[matches(.,'^[a-z0-9_-]*$')]">
									<!--FTITLE of the File: <xsl:value-of select="$file1"/><br/> -->
								</xsl:when>
								<xsl:otherwise>
									 <!--Issue found in FTITLE: <span class="tagerror"><xsl:value-of select="$file1"/></span>-->
									<li class="tagerror">Validator Error: Filename is not compliant with standards. See <a href="https://confluence.gtie.dell.com/display/IKB/Tridion+object+naming+conventions">IDD Knowledge Base Articles.</a></li>
								</xsl:otherwise>
							</xsl:choose>

<!-- Check for unsupported outputclasses (IDPL-9842) -->
 <xsl:if test=".//*[exists(@outputclass) and not(@outputclass='no_stars') and not(@outputclass='nochap') and not(@outputclass='branded') and not(@outputclass='part_number') and not(@outputclass='technote') and not(@outputclass='abstract') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='vrm_prefix_none') and not(@outputclass='show_hide') and not(@outputclass='show_hide_expanded') and not(@outputclass='no_help_folder') and not(@outputclass='landscape') and not(@outputclass='microvideo') and not(@outputclass='legal') and not(@outputclass='manual')and not(@outputclass='no_stars') and not(@outputclass='nochap part_number') and not(@outputclass='part_number nochap') and not(@outputclass='nochap part_number no_stars') and not(@outputclass='part_number nochap no_stars') and not(@outputclass='part_number no_stars nochap ') and not(@outputclass='no_stars nochap part_number') and not(@outputclass='no_stars part_number nochap') and not(@outputclass='nochap no_stars') and not(@outputclass='no_stars nochap') and not(@outputclass='nochap vrm_prefix_ver') and not(@outputclass='vrm_prefix_ver nochap') and not(@outputclass='nochap vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel nochap') and not(@outputclass='nochap no_stars vrm_prefix_ver') and not(@outputclass='no_stars nochap vrm_prefix_ver') and not(@outputclass='no_stars vrm_prefix_ver nochap') and not(@outputclass='vrm_prefix_ver nochap no_stars') and not(@outputclass='vrm_prefix_ver no_stars nochap') and not(@outputclass='technote part_number') and not(@outputclass='part_number technote') and not(@outputclass='technote part_number no_stars') and not(@outputclass='part_number no_stars technote') and not(@outputclass='part_number technote no_stars') and not(@outputclass='no_stars technote part_number') and not(@outputclass='no_stars part_number technote') and not(@outputclass='technote no_stars') and not(@outputclass='no_stars technote') and not(@outputclass='technote vrm_prefix_ver') and not(@outputclass='vrm_prefix_vertechnote') and not(@outputclass='technote vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel technote') and not(@outputclass='technote no_stars vrm_prefix_ver') and not(@outputclass='legal manual') and not(@outputclass='manual legal') and not(@outputclass='part_number solutions') and not(@outputclass='part_number nochap') and not(@outputclass='solutions part_number') and not(@outputclass='nochap part_number')] "><li class="tagerror"><span>Validator Error:</span> Unsupported Outputclass attribute value(s) found: <xsl:value-of select="distinct-values(.//*[exists(@outputclass) and not(@outputclass='no_stars') and not(@outputclass='nochap') and not(@outputclass='branded') and not(@outputclass='part_number') and not(@outputclass='technote') and not(@outputclass='abstract') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='vrm_prefix_none') and not(@outputclass='show_hide') and not(@outputclass='show_hide_expanded') and not(@outputclass='no_help_folder') and not(@outputclass='landscape') and not(@outputclass='microvideo') and not(@outputclass='legal') and not(@outputclass='manual')and not(@outputclass='no_stars') and not(@outputclass='nochap part_number') and not(@outputclass='part_number nochap') and not(@outputclass='nochap part_number no_stars') and not(@outputclass='part_number nochap no_stars') and not(@outputclass='part_number no_stars nochap ') and not(@outputclass='no_stars nochap part_number') and not(@outputclass='no_stars part_number nochap') and not(@outputclass='nochap no_stars') and not(@outputclass='no_stars nochap') and not(@outputclass='nochap vrm_prefix_ver') and not(@outputclass='vrm_prefix_ver nochap') and not(@outputclass='nochap vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel nochap') and not(@outputclass='nochap no_stars vrm_prefix_ver') and not(@outputclass='no_stars nochap vrm_prefix_ver') and not(@outputclass='no_stars vrm_prefix_ver nochap') and not(@outputclass='vrm_prefix_ver nochap no_stars') and not(@outputclass='vrm_prefix_ver no_stars nochap') and not(@outputclass='technote part_number') and not(@outputclass='part_number technote') and not(@outputclass='technote part_number no_stars') and not(@outputclass='part_number no_stars technote') and not(@outputclass='part_number technote no_stars') and not(@outputclass='no_stars technote part_number') and not(@outputclass='no_stars part_number technote') and not(@outputclass='technote no_stars') and not(@outputclass='no_stars technote') and not(@outputclass='technote vrm_prefix_ver') and not(@outputclass='vrm_prefix_vertechnote') and not(@outputclass='technote vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel technote') and not(@outputclass='technote no_stars vrm_prefix_ver') and not(@outputclass='legal manual') and not(@outputclass='manual legal') and not(@outputclass='part_number solutions') and not(@outputclass='part_number nochap') and not(@outputclass='solutions part_number') and not(@outputclass='nochap part_number')]/@outputclass)" separator=", " /></li></xsl:if>

 
<!-- <xsl:if test=".//*[exists(@outputclass) or (@outputclass='landscape') or (@outputclass='nopagebreak') or (@outputclass='pagebreak')  or (@outputclass='pagewide') or (@outputclass='show_hide') or (@outputclass='show_hide_expanded')] ">
	<li class="tagerror">Validator Error: Unsupported outputclass attribute value(s):&#160; 
		 
		  <xsl:for-each select=".//*[exists(@outputclass) and not(@outputclass='landing_page') and not(@outputclass='landscape') and not(@outputclass='nochap') and not(@outputclass='nopagebreak') and not(@outputclass='pagebreak') and not(@outputclass='pagewide') and not(@outputclass='rsa') and not(@outputclass='confidential') and not(@outputclass='show_hide') and not(@outputclass='show_hide_expanded')]/@outputclass">   
		    
		      <xsl:value-of select="."/>&#160;
		    
		  </xsl:for-each>
		
	</li>
</xsl:if>  -->

<!-- RSA copyright check: Added by jholmber 11-27-2012, needs to be implemented at the bookmap level and not here
<xsl:if test=".//frontmatter/notices[not(@href)]"><li class="tagerror">Validator Error: RSA copyright needs to be specified on the href of the notices element, not as a separate topicref. Check your bookmap file.</li></xsl:if>
-->


<!-- pagewide and landscape checks -->
<xsl:if test=".//fig/image[exists(@outputclass)]"><li class="tagerror">Validator Error: An image has an outputclass defined within a figure. Set the corresponding output class on the fig element if you are nesting the image element.</li></xsl:if>
<xsl:if test=".//*/fig[exists(@outputclass) and @outputclass='landscape']"><li class="tagerror">Validator Error: A figure (fig) has an outputclass defined as landscape but is nested within another element. The figure must be under the topic's body element.</li></xsl:if>
<xsl:if test=".//*/table[exists(@outputclass) and @outputclass='landscape']"><li class="tagerror">Validator Error: A table has an outputclass defined as landscape but is nested within another element. It must be under the topic's body element.</li></xsl:if>
<xsl:if test=".//*/image[exists(@outputclass) and @outputclass='landscape']"><li class="tagerror">Validator Error: An image has an outputclass defined as landscape but is nested within another element. It must be under the topic's body element.</li></xsl:if>


<!-- jholmber: 12/4/12 test for missing and empty definition elements -->
<xsl:if test=".//dd[not(normalize-space(.))]"><li class="tagwarning">Validator Warning: dd element is empty.</li></xsl:if>
<xsl:if test=".//dt[not(normalize-space(.))]"><li class="tagwarning">Validator Warning: dt element is empty.</li></xsl:if>
<xsl:if test=".//dd[not(string(.))]"><li class="tagwarning">Validator Warning: dd element is empty</li></xsl:if>
<xsl:if test=".//dt[not(string(.))]"><li class="tagwarning">Validator Warning: dt element is empty</li></xsl:if>

<!-- jholmber: 12/10/12 test for missing and empty p elements -->
<!-- jholmber: 3/13/13 allow for nested children in the p element -->
<xsl:if test=".//p[not(string(.)) and not(*)]"><li class="tagwarning">Validator Warning: P element is empty.</li></xsl:if>
<xsl:if test=".//p[not(normalize-space(.)) and not(*)]"><li class="tagwarning">Validator Warning: P element is empty.</li></xsl:if>

<!-- jholmber: 7/8/14 JIRA TKT-116 test for missing ol, ul, and steps element content -->
<xsl:if test=".//ul[not(*)]"><li class="tagerror">Validator Error: Unordered list (UL) element is empty.</li></xsl:if>
<xsl:if test=".//ol[not(*)]"><li class="tagerror">Validator Error: Ordered list (OL) element is empty.</li></xsl:if>
<xsl:if test=".//steps[not(*)]"><li class="tagerror">Validator Error: Steps element is empty.</li></xsl:if>

<xsl:if test=".//fig[not(title)]"><li class="tagerror">Validator Error: Figure does not have a title. This is the standard.</li></xsl:if>
<!-- IDPL-10390 Development - Validation of video source -->
<xsl:if test=".//object[(contains(@data,'ooyala') or contains(@data,'youtube'))]"><li class="tagwarning"><span>Error: </span>Brightcove is the approved video source. Do not use YouTube or Ooyala source links to stream videos.</li> 
</xsl:if>
<!-- Image contains alt text in alt attribute check req by DK -->
<xsl:if test=".//image[exists(@alt)]"><li class="info">Information: Images in the topic contain alternate text in the alt attribute. Move the alternate text in the alt attribute to the &lt;alt&gt; element..</li></xsl:if>
<xsl:if test=".//@href[contains(., 'HTTP:') or contains(., 'http:')] or .//xref[starts-with(@href, 'www.') or  starts-with(@href, 'WWW.')]"><li class="tagerror"><span>ERROR: You must add complete URL in href attribute. Ex: https://www.dell.com/support/ .</span></li></xsl:if>
<!-- IDPL - 9843 add href rule to Dell Validator and modify EMC rule -->
<xsl:if test=".//xref/@href[matches(., '%20')]"><li class="tagerror">Validator Error: HREF target contains a space</li><xsl:message><xsl:value-of select= ".//xref/@href"/></xsl:message></xsl:if>
<xsl:if test=".//@href[contains(., '%20')]"><li class="tagerror">Validator Error: HREF target contains a space</li>
<xsl:message>href link<xsl:copy-of select=".//@href"/></xsl:message>
</xsl:if>
<!--xsl:if test=".//image[not(alt) and not(@alt)]"><li class="tagwarning">Validator Warning: IMAGE does not have alternate text</li></xsl:if-->
<!--  nshadrina: 11/2018 TKT-666 accessibility errors added 
<xsl:if test=".//image[not(alt)] or .//image/alt[normalize-space()='']"><li class="accerror"><span>Accessibility: </span>image does not have an alt tag or alt tag is empty</li></xsl:if>
-->
<!-- jholmber: 7/8/14 Check no longer necessary as issue was fixed. JIRA ticket TKT-117-->
<!-- jholmber: 7/20/13 check for content in an example that is not properly wrapped in a child element-->
<!--
<xsl:if test="./example/text()[normalize-space(.)]"><li class="tagerror">Validator Error: Topic contains an example element with text content but that text is not wrapped in a child element. Content in an example that is not contained in a child element will not appear in all output types.</li></xsl:if>
-->


<!--  nshadrina: 11/2018 TKT-666 accessibility errors added
<xsl:if test=".//table[not(title)]"><li class="accerror"><span>Accessibility: </span>Table is missing title element.</li></xsl:if>
<xsl:if test=".//table[not(desc)] or .//table/desc[normalize-space()='']"><li class="accerror"><span>Accessibility: </span>table is missing desc element or it is empty</li></xsl:if>
<xsl:if test=".//*[contains(@class, ' topic/topic ') and not(//shortdesc)]"><li class="accerror"><span>Accessibility: </span>shortdesc is missing</li></xsl:if>
 -->

<!-- jholmber:12/4/12 not necessary at EMC
<xsl:if test=".//image[@width]"><li class="tagwarning">Validator Warning: IMAGE has WIDTH set</li></xsl:if>
-->

<!-- 11//12 jholmber: This seems like a poorly written test throwing false errors for EMC.
<xsl:if test=".//uicontrol[contains(text(), '>')]"><li class="tagwarning">Validator Warning: Use MenuCascade element for series of UIControl items</li></xsl:if>
-->


<!-- jholmber: 12/3/12 commenting out per Huntley's advice
<xsl:if test=".//indexterm"><li class="tagwarning">Validator Warning: Remove indexterm elements</li></xsl:if>
-->

<!--
<xsl:if test=".//xref[not(starts-with(@href, 'http')) and not(starts-with(@href, 'https')) and not(starts-with(@href, 'GUID')) and not(starts-with(@href, '#GUID'))]"><li class="tagwarning">Validator Warning: Begin web links with "http:// or https://". Does not apply to mailto links.</li></xsl:if>
-->

<!--<xsl:if test=".//xref[not(@href)]"><li class="tagerror">Validator Error: Add @href to XREF</li></xsl:if>-->
<!--<xsl:if test=".//xref[not(@scope='external') and contains(@href, 'http://')]"><li class="tagerror">Validator Error: XREF does not have attribute scope as external</li></xsl:if>-->


<!-- 11/14/12 per Tom Dill, jholmber removes this check
<xsl:if test=".//draft-comment[not(@otherprops='DraftStatusOn')]"><li class="tagerror">Validator Error: Draft-Comment does not have DraftStatusOn</li></xsl:if>
-->

<!-- sample checks you may want to use
<xsl:if test=".//bookmap[not(@linking='none')]"><li class="tagerror">Validator Error: BOOKMAP does not have attribute linking as none</li></xsl:if>
<xsl:if test=".//dlentry/dd[position()>1]"><li class="tagerror">Validator Error: DLEntry has more than one definition (DD)</li></xsl:if>
<xsl:if test=".//indexterm"><li class="tagwarning">Validator Warning: Remove indexterm elements</li></xsl:if>
<xsl:if test=".//xref[not(@scope='external')]"><li class="tagerror">Validator Error: XREF does not have attribute scope as external</li></xsl:if>
-->

</xsl:template>
</xsl:stylesheet>