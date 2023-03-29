<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.citrix.qa project hosted on 
     Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0" xmlns:emc="http://www.emc.com" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:dita="***Function Processing***" xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/">

<xsl:param name="input"/> <!-- Ex: E\:\\InfoShare\\Data\\Publish\\Data\\dfd44ystfmx\\work\\1\\en-us\\GUID-E495BD42-2646-4B34-B31B-CE184BA056C9.ditamap -->
<xsl:param name="fileroot"/> 
<xsl:param name="OUTPUTDIR" />
<xsl:param name="FILTERFILE" />
<xsl:param name="metfiles" />
<xsl:param name="BASEDIR" />
<xsl:param name="tempDir"/>
<xsl:param name="inputFolder"/>
<xsl:param name="ditaMapGuid"/>
<xsl:include href="qachecks/_att_values.xsl"/>
<!-- the following file is an example of how to include company-specific terminology checks
<xsl:include href="qachecks/_citrix_terms.xsl"/>
-->

<!--Roopesh Added for Test-->



<!-- jholmber 11/30/12: Not used by EMC as may overlap significantly with Author Assistant
<xsl:include href="qachecks/_general_terms.xsl"/>
-->

<!-- jholmber 3/15/13: Reinstating to support cite element checks as requested by MikeParent -->
<xsl:include href="qachecks/_language_standards.xsl"/>


<xsl:include href="qachecks/_markup_checks.xsl"/>
<xsl:include href="qachecks/_nesting_elements.xsl"/>
<xsl:include href="qachecks/_output_standards.xsl"/>
<xsl:include href="qachecks/_source_topic_checks.xsl"/>
<xsl:include href="qachecks/_map_checks.xsl"/>
<xsl:include href="qachecks/_accessibility_errors.xsl"/>


<xsl:output method="html"/>
	
	<xsl:key name="tagErrors" match="li" use="@class" />
	
	<!--Use something like this for more advanced counting sequences...we don't have a need for this yet, but if we ever needed to create sub-classes, we might.  Either way, it's a nice blending of user-defined functions and keys.

	<xsl:function name="dita:errors" as="element(ul)">
		<xsl:param name="errorType" as="xs:string" />
		<xsl:param name="number" as="xs:string" />
		<xsl:variable name="identifier" select="concat($errorType, ':', $number)" />
		<xsl:sequence select="key('courses', $identifier, $hitCount)" />
	</xsl:function>-->


	<xsl:template match="/dita">
	
		<xsl:variable name="hitCount">
		<xsl:for-each select="//*[contains(@class,'bookmap/bookmap ')]">
		   </xsl:for-each> 
	       <xsl:for-each select="//*[contains(@class,'topic/body ')]">
						<xsl:call-template name="att_values"/>
						<!--					   
						<xsl:call-template name="citrix_terms"/>
						-->

						<!-- jholmber 3/15/13: Reinstating to support cite element checks as requested by MikeParent -->
						<xsl:call-template name="language_standards"/>


						<!-- jholmber 11/30/12: Not used by EMC as may overlap significantly with Author Assistant
					   <xsl:call-template name="general_terms"/>
					   					   
						-->					   
					   <xsl:call-template name="markup_checks"/>
					   <xsl:call-template name="nesting_elements"/>
					   <xsl:call-template name="output_standards"/>
					   <xsl:call-template name="source_topic_checks"/>
					   <xsl:call-template name="accessibility_errors"/>
					   <xsl:call-template name="map_checks"/>
					   
			</xsl:for-each> 
	    </xsl:variable>
	    <xsl:variable name="totalErrors">
			<xsl:value-of select="count(key('tagErrors', 'tagerror', $hitCount)) + count(key('tagErrors', 'standard', $hitCount)) + count(key('tagErrors', 'syntaxerror', $hitCount)) + count(key('tagErrors', 'accerror', $hitCount))"/>
	    </xsl:variable>
	    <xsl:variable name="totalWarnings">
			<xsl:value-of select="count(key('tagErrors', 'tagwarning', $hitCount)) + count(key('tagErrors', 'prodterm', $hitCount)) + count(key('tagErrors', 'genterm', $hitCount))"/>
	    </xsl:variable>
	    <xsl:variable name="OTDIR">
			<xsl:value-of select="replace($BASEDIR, '\\', '/')" />
	    </xsl:variable>
	    <xsl:variable name="inputMap">
	    
	    	<!--
			<xsl:value-of select="concat('file:///' , $OTDIR, '/' , $input)"/>
		-->
		
		<xsl:value-of select="concat('file:///', $input)"/>
		
	    </xsl:variable>
	    
	    <!--xsl:variable name="bookmapRootDir" select="concat(emc:substring-before-last(concat('file:///',$input),'/'),'/')" /-->
		<xsl:variable name="rootDir" select="replace(concat(concat('file:///',$inputFolder),'/'),'\\','/')" />  			
	    
		<html>
			<head>
				<title>DellEMC Standards Review</title>
				<link type="text/css" href="css/base.css" rel="stylesheet" />
				<!-- Pie Chart CSS Files 
				
				<link type="text/css" href="css/PieChart.css" rel="stylesheet" />
				-->
				
				<!--[if IE]><script language="javascript" type="text/javascript" src="../../Extras/excanvas.js"></script><![endif]-->

				<!-- JIT Library File 
				<script language="javascript" type="text/javascript" src="jit-yc.js"></script>
				-->
				
				<!-- Pie Chart  File 
				<xsl:element name="script">
					<xsl:attribute name="language">javascript</xsl:attribute>
					<xsl:attribute name="type">text/javascript</xsl:attribute>
					<xsl:attribute name="src"><xsl:value-of select="$fileroot"/>.js</xsl:attribute>
				</xsl:element>
				
				-->
				
				
				
				<style type="text/css"><![CDATA[
				body {font-family:sans-serif;}
				pre {font-family: sans-serif;
					 font-size: 12pt;}
				p {color:#25383C}
				ul {list-style: square}
				.tagerror {color: #B80000  }
				.tagwarning {color: #CC9900  }
				.standard {color: #385E0F  }
				.syntaxerror {color: #B80000  }
				.prodterm {color: #330099  }
				.accerror {color: #330099  }
				.genterm {color: #330099  }
				#totalScore {font-size: 16pt; }
				#main {
					margin-left:10.2em;
					margin-right:10.2em;
					padding-left:1em;
					padding-right:1em;
					}
				ul.twocolumn {
					width: 400px;
						}
				ul.twocolumn li {
					width: 190px;
					float: left;
						} 
			]]></style>
			
			</head>
			<body  onload="init();">
				<!-- trying to get the bookmap title, but the document function works relative to this xsl file, not to build.xml, so the input variable doesn't point to an actual document -->
				<h1>DellEMC Standards Review</h1> <!--: <xsl:value-of select="document($inputMap)//mainbooktitle"/>-->
				<font face="sans-serif">
					<table border="1" cellpadding="2" cellspacing="2">
						<tbody>
							<tr align="center">
								<td rowspan="9">
								
								<!--
								<xsl:choose>
									<xsl:when test="($totalErrors + $totalWarnings) &gt; 30">
										<p align="center"><font size="20">FAIL</font></p>
										<img alt="FAIL" src="img/fail.png"></img>
									</xsl:when>
									<xsl:when test="($totalErrors + $totalWarnings) &lt; 30">
									<p align="center"><font size="20">PASS</font></p>
									<img alt="Success" src="img/pass.png"></img>
									</xsl:when>
								</xsl:choose>
								-->
								
								<!-- use an if statement to select a pass or fail image -->
								<p align="center">Total violation count: </p>
								<p id="totalScore" align="center"><xsl:value-of select="$totalErrors + $totalWarnings"/></p>
								</td>
							</tr>
							<tr align="center">
								<td><b>Pass/Fail</b></td>
								<td><b>Check Type</b></td>
								<td><b>Violations</b></td>
							</tr>
							<tr align="center">	
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'tagerror', $hitCount)) &gt; 0">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'tagerror', $hitCount)) &lt; 1">
								<img alt="PASS" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="tagerror">Tagging errors</font></td>
								<td id="ErrTab"><xsl:value-of select="count(key('tagErrors', 'tagerror', $hitCount))" /></td>
							</tr>
							<tr align="center">
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'tagwarning', $hitCount)) &gt; 0">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'tagwarning', $hitCount)) &lt; 1">
								<img alt="FAIL" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose></td>
								<td><font class="tagwarning">Tagging warnings</font></td>
								<td id="WrnTab"><xsl:value-of select="count(key('tagErrors', 'tagwarning', $hitCount))"/></td>
							</tr>
							<tr align="center">
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'standard', $hitCount)) &gt; 0">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'standard', $hitCount)) &lt; 1">
								<img alt="Success" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="standard">Standards violations</font></td>
								<td id="StdTab"><xsl:value-of select="count(key('tagErrors', 'standard', $hitCount))"/></td>
							</tr>
							<tr align="center">
								<td>
								<xsl:choose>
								<xsl:when test="count(key('tagErrors', 'accerror', $hitCount)) &gt; 0">
								<img alt="FAIL" src="img/failsm.png"></img>
								</xsl:when>
								<xsl:when test="count(key('tagErrors', 'accerror', $hitCount)) = 0">
								<img alt="Success" src="img/passsm.png"></img>
								</xsl:when>
								</xsl:choose>
								</td>
								<td><font class="prodterm">Accessibility Errors</font></td>
								<td id="AccTab"><xsl:value-of select="count(key('tagErrors', 'accerror', $hitCount))"/></td>
							</tr>							
						</tbody>
					</table>
					<br/>
					<hr/>
					<h2>Summary of Content Processed</h2>
					
					<!-- NShadrina 05/2017 : TKT-579  added mainbooktitle and shortdesc check -->
								
						<xsl:variable name="objectGUID" select="$ditaMapGuid"/>
						<xsl:variable name="thisPubTicket" select="concat($rootDir, 'ishjobticket.xml')" />
						<xsl:variable name="thisPubTitle" select="document($thisPubTicket)/job-specification/parameter[@name='documenttitle']/text()" />
						<xsl:variable name="booktitle" select="document($inputMap)/bookmap/booktitle/mainbooktitle/text()" />
						<xsl:variable name="altbooktitle" select="document($inputMap)/bookmap/booktitle/booktitlealt/text()" />
						<xsl:variable name="thisBookmapMet" select="concat($rootDir,$objectGUID,'.met')" />
						<xsl:variable name="thisBookmapMetDoc" select="document($thisBookmapMet)" />
						<xsl:variable name="thisBookmapFtitle" select="$thisBookmapMetDoc/ishobject/ishfields/ishfield[@name='FTITLE']/text()" />
						<xsl:variable name="outputclass_attr_values" select="normalize-space(document($inputMap)/bookmap/@outputclass)" />
						
					
					<table border="1" cellpadding="2" cellspacing="2">
						<tbody>
							<tr>
								<td>Report run on</td>
								<td><xsl:value-of select="format-date(
                                 					current-date(),
                                 					'[FNn], [D1o] [MNn,*-3], [Y]',
                                 					'en',
                                 					(),
                                 					()
                              						)"/>
                              					</td>
							</tr>
							<tr>
								<td>Document info</td>
								<td>
								
								

								<p><b><u>PUBLICATION DETAILS</u></b></p>
								<ul>
								<li>
									<xsl:choose>
										<xsl:when test="$thisPubTitle[matches(.,'^[a-zA-Z0-9_-]*$')]">
											<b>Publication Name: </b><xsl:value-of select="$thisPubTitle"/><br/>
										</xsl:when>
										<xsl:otherwise>
											<b>Publication Name: </b><xsl:value-of select="$thisPubTitle"/>
											<br/><span class="tagwarning">Special characters used in the FTITLE could cause issues when publishing content to the web in future mechanisms planned for web publishing.</span>
											<script><![CDATA[
												var newScore = document.getElementById("WrnTab").innerText;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("WrnTab").innerText = value;
												var totalScore = document.getElementById("totalScore").innerText;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerText = totalScoreValue;
											]]></script>
										</xsl:otherwise>
									</xsl:choose>	
								</li>
															
								<!--<li>
									 Commenting to remove the override issue for output class 
									<xsl:choose>
										<xsl:when test="$booktitle[matches(.,'^[a-zA-Z0-9_-]*$')]">
										
										<xsl:when test="$booktitle[matches(.,'^[^=\[\]\(\)\{\}\*\+\|\-\^\$@&lt;&gt;!#%~;\\?/&amp;&quot;'']*$')]">
										
											<b>Publication Title: </b><xsl:value-of select="$booktitle" />
										</xsl:when>
										<xsl:otherwise>
											<b>Publication Title: </b><xsl:value-of select="$booktitle" />
											<br/><span class="tagwarning">Validator Warning: Special characters used in the mainbooktitle could cause issues when publishing content to the web in future mechanisms planned for web publishing.</span>
											<script><![CDATA[
												var newScore = document.getElementById("WrnTab").innerText;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("WrnTab").innerText = value;
												var totalScore = document.getElementById("totalScore").innerText;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerText = totalScoreValue;
											]]></script>
										</xsl:otherwise>
									</xsl:choose>  -->
									
									<!-- <xsl:if test="not(document($inputMap)/bookmap/booktitle) or not(document($inputMap)/bookmap/booktitle/mainbooktitle) or document($inputMap)/bookmap/booktitle/mainbooktitle[matches(.,'^\s*$')]">
									<br /><span class="tagerror">Validator Error: Missing or empty mainbooktitle element</span>
									<script><![CDATA[
												var newScore = document.getElementById("ErrTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("ErrTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
									]]></script>
									</xsl:if>
									
								</li>  -->
								<li>
									<xsl:choose>
										<xsl:when test="$altbooktitle[matches(.,'^[^=\[\]\(\)\{\}\*\+\|\-\^\$@&lt;&gt;!#%~;\\?/&amp;&quot;'']*$')]">
											<b>Publication Alt Book Title: </b><xsl:value-of select="$altbooktitle"/>
										</xsl:when>
										<xsl:otherwise>
											<b>Publication Alt Book Title: </b><xsl:value-of select="$altbooktitle"/>
											<br/><span class="tagwarning">Validator Warning: Special characters used in the booktitlealt could cause issues when publishing content to the web in future mechanisms planned for web publishing.</span>
											<script><![CDATA[
												var newScore = document.getElementById("WrnTab").innerText;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("WrnTab").innerText = value;
												var totalScore = document.getElementById("totalScore").innerText;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerText = totalScoreValue;
											]]></script>
										</xsl:otherwise>
									</xsl:choose>	
								
								</li>	
								<li><b>Language Values Set: </b><xsl:value-of select="distinct-values(//*/@xml:lang)" separator=", " /></li>
								</ul>
								<p><b><u>BOOKMAP DETAILS</u></b></p>
								<ul>
								<li><b>Bookmap Processed: </b><xsl:value-of select="$objectGUID"/></li>	
								<li>
									<xsl:choose>
										<xsl:when test="$thisBookmapFtitle[matches(.,'^[a-zA-Z0-9_-]*$')]">
											<b>Bookmap Name (FTITLE): </b><xsl:value-of select="$thisBookmapFtitle"/><br/>
										</xsl:when>
										<xsl:otherwise>
											<b>Bookmap Name (FTITLE): </b><span class="tagerror"><xsl:value-of select="$thisBookmapFtitle"/></span>
											<br/><span class="tagwarning">Validator Warning: Special characters used in the FTITLE could cause issues when publishing content to the web in future mechanisms planned for web publishing.</span>
											<script><![CDATA[
												var newScore = document.getElementById("WrnTab").innerText;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("WrnTab").innerText = value;
												var totalScore = document.getElementById("totalScore").innerText;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerText = totalScoreValue;
											]]></script>
										</xsl:otherwise>
									</xsl:choose>	
								</li>	
									
								<li>Short description: <xsl:value-of select="document($inputMap)/bookmap/bookmeta/shortdesc"/>
								<xsl:if test="not(document($inputMap)/bookmap/bookmeta/shortdesc) or document($inputMap)/bookmap/bookmeta/shortdesc[matches(.,'^\s*$')]">
									<br /><span class="accerror">Accessibility: shortdesc element is missing or empty </span>
									<script><![CDATA[
												var newScore = document.getElementById("AccTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("AccTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
									]]></script>
									</xsl:if>
								</li>
								<!--<li>Bookmap Outputclass Attribute(s): <xsl:value-of select="$outputclass_attr_values"/>
									<xsl:if test="string-length($outputclass_attr_values)=0">Not set</xsl:if>
									
									<xsl:for-each select="tokenize($outputclass_attr_values, ' ')" >
										<br /><xsl:if test="normalize-space(.)!='barcode' and normalize-space(.)!='landing_page' and normalize-space(.)!='landscape' and normalize-space(.)!='rotated' and normalize-space(.)!='no_help_folder' and normalize-space(.)!='nochap' and normalize-space(.)!='nopagebreak' and normalize-space(.)!='pagebreak' and normalize-space(.)!='pagewide' and normalize-space(.)!='rsa' and normalize-space(.)!='solutions' and normalize-space(.)!='confidential' and normalize-space(.)!='show_hide' and normalize-space(.)!='show_hide_expanded' "><span class="tagerror">Validator Error: Unsupported outputclass attribute value: <xsl:value-of select="normalize-space(.)"/></span>
										<script><![CDATA[
												var newScore = document.getElementById("ErrTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("ErrTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
										]]></script>
										</xsl:if>
									</xsl:for-each>
									
									<br /><xsl:if test="document($inputMap)/bookmap/chapter[position()>1 and exists(@outputclass) and @outputclass='no_help_folder'] "><span class="tagerror">Validator Error: The no_help_folder outputclass attribute option must be set on the first chapter element of the bookmap.</span>
									<script><![CDATA[
												var newScore = document.getElementById("ErrTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("ErrTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
									]]></script>
									</xsl:if>
									
									</li> -->
									
									<li>Version: <xsl:value-of select="$thisBookmapMetDoc/ishobject/ishfields/ishfield[@name='VERSION']/text()"/><br/></li>
									<li>Revision: <xsl:value-of select="$thisBookmapMetDoc/ishobject/ishfields/ishfield[@name='FISHREVCOUNTER']/text()"/><br/></li>
									<li>Status: <xsl:value-of select="$thisBookmapMetDoc/ishobject/ishfields/ishfield[@name='FSTATUS']/text()"/><br/></li>
									
									
									
									
									<!-- jholmber: 3/17/13 check for duplicate resourceIDs that may confuse context-sensitive calls -->
									<br />
									
									
									<xsl:for-each select="//resourceid[not(@appname)]">
										<xsl:variable name="csh" select="./@id" />
										<xsl:if test="(count(//resourceid[not(@appname) and @id=$csh])>1) and not(preceding::resourceid[@id = $csh and not(@appname)])">
											<li class="tagerror">Validator Error: Duplicate resourceid may cause context-sensitive help problems:  <xsl:value-of select="./@id"></xsl:value-of></li>
											<script><![CDATA[
												var newScore = document.getElementById("ErrTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("ErrTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
											]]></script>
										</xsl:if>
									</xsl:for-each>
									
									<!-- (IDPL-9849) Delete the following rules in Validator Dell and Validator EMC. -->
									<!--<xsl:for-each select="//resourceid[@appname]">
										<xsl:variable name="csh" select="./@id" />
										<xsl:variable name="appname" select="./@appname" />
										<xsl:if test="(count(//resourceid[@appname=$appname and @id=$csh])>1) and not(preceding::resourceid[@id = $csh and @appname=$appname])">
											<li class="tagerror">Validator Error: Duplicate resourceid (with appname attribute) may cause context-sensitive help problems:  <xsl:value-of select="./@appname" />:<xsl:value-of select="./@id"></xsl:value-of></li>
											<script><![CDATA[
												var newScore = document.getElementById("ErrTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("ErrTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
											]]></script>      									
      										</xsl:if>
											
									</xsl:for-each>-->
									
									
									<!-- jholmber 7/9/2014 Check for chapter elements without an href-->
									<xsl:for-each select="document($inputMap)/bookmap/chapter[not(@href)]" >
										<li><span class="tagwarning">Validator Warning: PDF-only: a chapter element (navtitle: <xsl:value-of select="./@navtitle"/> ) is missing an href attribute. This may result in unexpected TOC contents <em>in PDF output</em>.</span>
										</li>
										<script><![CDATA[
												var newScore = document.getElementById("WrnTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("WrnTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
											]]></script>
									</xsl:for-each>
									
									<!-- jholmber: 6/20/13: Check the bookmap topicrefs for errors -->
									<!--xsl:call-template name="map_checks_tests"/>
										<xsl:with-param name="rootDir" select="$rootDir" />
									</xsl:call-template-->
									
									<!--
									<li>DITA Open Toolkit build log: <a href="qalog.xml" target="_blank">open in new window</a></li>
									-->
								</ul>
								<p><b><u>DITA DETAILS</u></b></p>
								<ul>
								<li>DITA Version Used: <xsl:value-of select="distinct-values(//*/@ditaarch:DITAArchVersion)" separator=", " /></li>
								</ul>
								</td>
							</tr>
							
							<tr>
								<td>Document details</td>
								<td>
								<ul>
								<li>Bridge: <xsl:value-of select="count(//*[ends-with(normalize-space(@class),normalize-space('- topic/topic '))])"/></li>
									
									<li>Concept: <xsl:value-of select="count(//*[ends-with(normalize-space(@class),normalize-space('- topic/topic concept/concept'))])"/></li>
									<li>Task: <xsl:value-of select="count(//*[contains(normalize-space(@class),normalize-space('- topic/topic task/task'))])"/></li>
									<li>Reference: <xsl:value-of select="count(//*[ends-with(normalize-space(@class),normalize-space('- topic/topic reference/reference'))])"/></li>
									<li>Glossentry: <xsl:value-of select="count(//*[contains(normalize-space(@class),normalize-space('- topic/topic concept/concept glossentry/glossentry '))])"/></li>
									<li>CLI Reference: <xsl:value-of select="count(//*[contains(normalize-space(@class),normalize-space('- topic/topic reference/reference cli_reference/cli_reference '))])"/></li>
									
									
								</ul>
								
								
								     <p>Total topics: <xsl:value-of select="count(//*[starts-with(normalize-space(@class),normalize-space('- topic/topic '))])"/></p>

								
								     <p>Total images: <xsl:value-of select="count(//image)"/></p>
								
									<p>Total object elements: <xsl:value-of select="count(//object)"/></p>
								
								</td>
							</tr>	
							<tr>
								<td>Readability Score
								</td>
								<td>
								<pre><span class="innerPre"><xsl:value-of select="concat(substring-before(document(concat('file:///',$tempDir,'/readbilityScrore.xml'))//root,'Averaage'),'Average',substring-after(document(concat('file:///',$tempDir,'/readbilityScrore.xml'))//root,'Averaage'))"/></span></pre>
								</td>
							</tr>
							<tr>
								<td>Element Counts</td>
								<td>
									<p>Document contains <xsl:value-of select="count(distinct-values(descendant::*))" /> distinct tag values in <xsl:value-of select="count(descendant::*)" /> tags.</p>	<p>Total words: <xsl:value-of select="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)])"/></p>
								</td>
							</tr>
							<tr>
								<td>Non-Translated Elements</td>
								<td>
									<xsl:if test="//*/codeblock">&lt;codeblock&gt;<br/></xsl:if>
									<xsl:if test="//*/draft-comment">&lt;draft-comment&gt;<br/></xsl:if>
									<xsl:if test="//*/othermeta">&lt;othermeta&gt;<br/></xsl:if>
									<xsl:if test="//*/boolean">&lt;boolean&gt;<br/></xsl:if>
									<xsl:if test="//*/completed">&lt;completed&gt;<br/></xsl:if>
									<xsl:if test="//*/day">&lt;day&gt;<br/></xsl:if>
									<xsl:if test="//*/prodname">&lt;prodname&gt;<br/></xsl:if>
									<xsl:if test="//*/brand">&lt;brand&gt;<br/></xsl:if>
									<xsl:if test="//*/month">&lt;month&gt;<br/></xsl:if>
									<xsl:if test="//*/volume">&lt;volume&gt;<br/></xsl:if>
									<xsl:if test="//*/coords">&lt;coords&gt;<br/></xsl:if>
									<xsl:if test="//*/faqans">&lt;faqans&gt;<br/></xsl:if>
									<xsl:if test="//*/faqquest">&lt;faqquest&gt;<br/></xsl:if>
									<xsl:if test="//*/faqitem">&lt;faqitem&gt;<br/></xsl:if>
									<xsl:if test="//*/faqlist">&lt;faqlist&gt;<br/></xsl:if>
									<xsl:if test="//*/faqgroup">&lt;faqgroup&gt;<br/></xsl:if>
									<xsl:if test="//*/faqbody">&lt;faqbody&gt;<br/></xsl:if>
									<xsl:if test="//*/faq">&lt;faq&gt;<br/></xsl:if>
									<xsl:if test="//*/codeph">&lt;codeph&gt;<br/></xsl:if>
									<xsl:if test="//*/cmd">&lt;cmd&gt;<br/></xsl:if>
									<xsl:if test="//*/edition">&lt;edition&gt;<br/></xsl:if>
								</td>
							</tr>
<tr>
		<td>Bookmap Issues</td>
		<td>
		<xsl:for-each select="document($inputMap)">
							<xsl:call-template name="map_values"/>
							<!-- Flag if <notices> is not present (IDPL-9663) -->
<xsl:if test="not(.//*/notices)"><li class="tagerror">Validator Error: &lt;notices&gt; element must be present in order to produce copyright.</li></xsl:if>
					</xsl:for-each>
		</td>
		</tr>
		<!--<tr>
		<td>General issues</td>
		<td>
		<xsl:call-template name="map_checks"/><br/>
		</td>
		</tr> -->
						</tbody>
					</table>
					<br/>
					<hr/>
					<h2>Details</h2>
					
					<!-- apply map validator tests -->
					
					<!-- jholmber: 6/20/13: List and check the referenced maps for validator issues -->
					<xsl:for-each select="document($inputMap)//topicref[@format='ditamap']">
							<xsl:call-template name="map_checks">
								<xsl:with-param name="rootDir" select="$rootDir" />
								<xsl:with-param name="bookmapFile" select="concat($rootDir, ./@href)" />
							</xsl:call-template>
							<xsl:call-template name="map_values"/>
					</xsl:for-each>
					<xsl:apply-templates select="//*[contains(@class,' topic/body ') or contains(@class,' glossentry/glossterm ')]"/>

				</font>
			</body>
		</html>
		
		
		
	</xsl:template>
	<xsl:template match="*[contains(@class,' topic/body ')]">
		<!-- EMC add support for cli_reference 10-26-2012-->
		<xsl:for-each select="self::conbody | self::taskbody | self::refbody | self::body | self::cli_body">	
				<xsl:variable name="topicType">
					<xsl:choose>
						<xsl:when test="self::conbody">concept</xsl:when>
						<xsl:when test="self::taskbody">task</xsl:when>
						<xsl:when test="self::refbody">reference</xsl:when>
						<xsl:when test="self::cli_body">cli_reference</xsl:when>	
						<xsl:when test="self::body">bridge</xsl:when>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="shortdesc" select="preceding-sibling::shortdesc[contains(@class, ' topic/shortdesc ')]" />
				<xsl:variable name="docGUID" select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/@ishref" />
				<xsl:variable name="objectFtitle" select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>
				
				<p><b>Topic Title: <xsl:value-of select="preceding-sibling::title[contains(@class, ' topic/title ')]"/></b><br />
				Topic Type: <xsl:value-of select="$topicType"/><br />
				Short Description: <em><xsl:value-of select="$shortdesc"/></em><br />
				CSH Resource IDs: <em>
						<ul>	
						<xsl:for-each select="preceding-sibling::prolog/resourceid">	
							<xsl:variable name="cshID" select="concat(./@appname,':',./@id)" />
							
							<xsl:choose>
								<xsl:when test="starts-with($cshID,':')">
								      <li><xsl:value-of select="replace($cshID,':','')"/></li>
    								</xsl:when>
								<xsl:otherwise><li><xsl:value-of select="$cshID"/></li></xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>	
						</ul>
						</em><br />				
					<!-- Trisoft-aware code added by EMC to read metadata out of .met files -->
					GUID: <xsl:value-of select="$docGUID"/><br></br>
					
					<!-- NShadrina 07/2017 : TKT-437  Checking if FTITLE is alpha-numerical -->
						
					<xsl:choose>
						<xsl:when test="$objectFtitle[matches(.,'^[a-zA-Z0-9_-]*$')]">
							Object FTITLE: <xsl:value-of select="$objectFtitle"/><br/>
						</xsl:when>
						<xsl:otherwise>
							Object FTITLE: <span class="tagerror"><xsl:value-of select="$objectFtitle"/></span>
							<ul>
							<li class="tagwarning">Validator Warning: Special characters used in FTITLE could cause issues when publishing content to the web in future mechanisms planned for web publishing.</li>
							</ul>
							<script><![CDATA[
												var newScore = document.getElementById("WrnTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("WrnTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
											]]></script>
						</xsl:otherwise>
					</xsl:choose>				
					<!--Object Title: <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/><br></br>
					-->
					<!-- jholmber on 11/6/2013 added FMODULETYPE support -->
					
					<xsl:variable name="modType">
						<xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FMODULETYPE']"/>
					</xsl:variable>
					
					<!--Topic Type (metadata): <xsl:value-of select="$modType/text()"/><br></br>-->					
					Object Version: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='VERSION']/text()"/><br></br>
					Object Revision: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FISHREVCOUNTER']/text()"/><br></br>
					Author's Login ID: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FAUTHOR']/text()"/><br></br>
					Object Workflow Status: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FSTATUS']/text()"/><br></br>					
				</p>
				<ul>
				<xsl:if test="$shortdesc='' or not($shortdesc)">
					<li class="accerror">Accessibility: shortdesc is missing or empty</li>
					<script><![CDATA[
						var newScore = document.getElementById("AccTab").innerHTML;
						var value = parseInt(newScore,10) + 1;
						document.getElementById("AccTab").innerHTML = value;
						var totalScore = document.getElementById("totalScore").innerHTML;
						var totalScoreValue = parseInt(totalScore,10) + 1;
						document.getElementById("totalScore").innerHTML = totalScoreValue;
					]]></script>
				</xsl:if>
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
				
						<xsl:call-template name="att_values"/>
						<xsl:call-template name="language_standards"/>

<!-- jholmber 11/30/12: Not used by EMC as may overlap significantly with Author Assistant
                                           <xsl:call-template name="general_terms"/>
					   
-->
					   <xsl:call-template name="markup_checks"/>
					   <xsl:call-template name="nesting_elements"/>
					   <xsl:call-template name="output_standards"/>
					   <xsl:call-template name="accessibility_errors"/>
					   <!-- NShadrina 07/2017 TKT-436 -->
					   <xsl:if test=".//keyword">
							<xsl:for-each select="//keyword">
								<xsl:variable name="keyrefFromTopic" select="./@keyref"/>
								<xsl:variable name="keywordFromTopic" select="."/>
								<xsl:if test="string-length($keywordFromTopic)=0 and $keyrefFromTopic!=''">
									<li class="tagerror">Validator Error: A keyref to "<xsl:value-of select='./@keyref' />" has no matching keydef in a publication keymap.</li>
									<script><![CDATA[
												var newScore = document.getElementById("ErrTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("ErrTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
											]]></script>
								</xsl:if>
							</xsl:for-each>
						</xsl:if>
					   <xsl:call-template name="source_topic_checks"/>
				
				
				
		  		
		  		

		  
				</ul>				     
				<hr/>
		
		</xsl:for-each>
	</xsl:template>
	
			<xsl:template match="*[contains(@class,' glossentry/glossterm ')]">
			
		<!-- EMC add support for cli_reference 10-26-2012-->
		<xsl:for-each select="self::glossterm">
	
			<p><b>Glossary term: <xsl:value-of select="."/></b><br />	
<!-- Trisoft-aware code added by EMC to read metadata out of .met files -->
										<!-- Trisoft-aware code added by EMC to read metadata out of .met files -->
					GUID: <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/@ishref"/><br></br>
					<!-- NShadrina 07/2017 : TKT-437  Checking if FTITLE is alpha-numerical -->
					<xsl:variable name="objectFtitle" select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>	
					<xsl:choose>
						<xsl:when test="$objectFtitle[matches(.,'^[a-zA-Z0-9_-]*$')]">
							Object Title: <xsl:value-of select="$objectFtitle"/><br/>
						</xsl:when>
						<xsl:otherwise>
							Object Title: <span class="tagerror"><xsl:value-of select="$objectFtitle"/></span>
							<ul>
							<li class="tagwarning">Validator Warning: Special characters used in FTITLE could cause issues when publishing content to the web in future mechanisms planned for web publishing.</li>
							</ul>
							<script><![CDATA[
												var newScore = document.getElementById("WrnTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("WrnTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
											]]></script>
						</xsl:otherwise>
					</xsl:choose>
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
					<!--Object Title: <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/><br></br>-->
					
					<!-- jholmber on 11/6/2013 added FMODULETYPE support -->
					
					<xsl:variable name="modType">
						<xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FMODULETYPE']"/>
					</xsl:variable>
					
					Topic Type (metadata): <xsl:value-of select="$modType/text()"/><br></br>					
					Object Version: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='VERSION']/text()"/><br></br>
					Object Revision: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FISHREVCOUNTER']/text()"/><br></br>
					Author's Login ID: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FAUTHOR']/text()"/><br></br>
					Object Workflow Status: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FSTATUS']/text()"/><br></br>
						</p>			
					<!-- NShadrina 02/2019 - no such meta FMODULETYPE is available. Commenting out --> 
					<!--
					<xsl:variable name="modType">
						<xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FMODULETYPE']"/>
					</xsl:variable>	
					<ul>
					<xsl:if test="(./name()='glossterm') and not($modType/text()='Glossary Entry')"><li class="tagerror">Validator Error: Topic is a DITA glossentry topic, but its LiveContent Architect metadata says it is a <xsl:value-of select="$modType/text()" />.</li>
					<script><![CDATA[
												var newScore = document.getElementById("ErrTab").innerHTML;
												var value = parseInt(newScore,10) + 1;
												document.getElementById("ErrTab").innerHTML = value;
												var totalScore = document.getElementById("totalScore").innerHTML;
												var totalScoreValue = parseInt(totalScore,10) + 1;
												document.getElementById("totalScore").innerHTML = totalScoreValue;
											]]></script>
					</xsl:if>
				
					</ul>
					-->
					
				<hr/>
				
	</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="map_values">
<!-- Flag if <publisherinfo> is not present (IDPL-9663) -->
<xsl:if test="not(//*/publisherinformation)"><li class="tagerror"><span>Validator Error:</span>Publisherinformation is missing.</li></xsl:if>

<!-- Check for unsupported <othermeta> values (IDPL-9848) -->
<xsl:if test=".//othermeta[exists(@name) and not(@name='search') and not(@name='promoted') and not(@name='DELLMLTB_EMEA') and not(@name='DELLMLTB_DAO') and not(@name='DELLMLTB_EMEA1') and not(@name='DELLMLTB_EMEA2') and not(@name='DELLMLTB_APCC1') and not(@name='DELLMLTB_APCC2') and not(@name='DELLMLTB_ALL') and not(@name='PDF-partnumber') and not(@name='mini-toc') and not(@name='task-labels') and not(@name='PDF-releasedate') and not(@name='PDF-docnumber') and not(@name='PDF-currentversion') and not(@name='PDF-previousversion')] "><li class="tagerror"><span>Validator Error:</span> Unsupported othermeta value(s) found: <xsl:value-of select="distinct-values(.//othermeta[exists(@name) and not(@name='search') and not(@name='promoted') and not(@name='DELLMLTB_EMEA') and not(@name='DELLMLTB_DAO') and not(@name='DELLMLTB_EMEA1') and not(@name='DELLMLTB_EMEA2') and not(@name='DELLMLTB_APCC1') and not(@name='DELLMLTB_APCC2') and not(@name='DELLMLTB_ALL') and not(@name='PDF-partnumber') and not(@name='mini-toc') and not(@name='task-labels') and not(@name='PDF-releasedate') and not(@name='PDF-docnumber') and not(@name='PDF-currentversion') and not(@name='PDF-previousversion')]/@name)" separator=", "/></li></xsl:if>

<!-- Check for unsupported outputclasses (IDPL-9842) -->
 <xsl:if test=".//*[exists(@outputclass) and not(@outputclass='no_stars') and not(@outputclass='nochap') and not(@outputclass='branded') and not(@outputclass='part_number') and not(@outputclass='technote') and not(@outputclass='abstract') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='vrm_prefix_none') and not(@outputclass='show_hide') and not(@outputclass='show_hide_expanded') and not(@outputclass='no_help_folder') and not(@outputclass='landscape') and not(@outputclass='microvideo') and not(@outputclass='legal') and not(@outputclass='manual')and not(@outputclass='no_stars') and not(@outputclass='nochap part_number') and not(@outputclass='part_number nochap') and not(@outputclass='nochap part_number no_stars') and not(@outputclass='part_number nochap no_stars') and not(@outputclass='part_number no_stars nochap ') and not(@outputclass='no_stars nochap part_number') and not(@outputclass='no_stars part_number nochap') and not(@outputclass='nochap no_stars') and not(@outputclass='no_stars nochap') and not(@outputclass='nochap vrm_prefix_ver') and not(@outputclass='vrm_prefix_ver nochap') and not(@outputclass='nochap vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel nochap') and not(@outputclass='nochap no_stars vrm_prefix_ver') and not(@outputclass='no_stars nochap vrm_prefix_ver') and not(@outputclass='no_stars vrm_prefix_ver nochap') and not(@outputclass='vrm_prefix_ver nochap no_stars') and not(@outputclass='vrm_prefix_ver no_stars nochap') and not(@outputclass='technote part_number') and not(@outputclass='part_number technote') and not(@outputclass='technote part_number no_stars') and not(@outputclass='part_number no_stars technote') and not(@outputclass='part_number technote no_stars') and not(@outputclass='no_stars technote part_number') and not(@outputclass='no_stars part_number technote') and not(@outputclass='technote no_stars') and not(@outputclass='no_stars technote') and not(@outputclass='technote vrm_prefix_ver') and not(@outputclass='vrm_prefix_vertechnote') and not(@outputclass='technote vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel technote') and not(@outputclass='technote no_stars vrm_prefix_ver') and not(@outputclass='legal manual') and not(@outputclass='manual legal') and not(@outputclass='part_number solutions') and not(@outputclass='part_number nochap') and not(@outputclass='solutions part_number') and not(@outputclass='nochap part_number')] "><li class="tagerror"><span>Validator Error:</span> Unsupported Outputclass attribute value(s) found: <xsl:value-of select="distinct-values(.//*[exists(@outputclass) and not(@outputclass='no_stars') and not(@outputclass='nochap') and not(@outputclass='branded') and not(@outputclass='part_number') and not(@outputclass='technote') and not(@outputclass='abstract') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='vrm_prefix_none') and not(@outputclass='show_hide') and not(@outputclass='show_hide_expanded') and not(@outputclass='no_help_folder') and not(@outputclass='landscape') and not(@outputclass='microvideo') and not(@outputclass='legal') and not(@outputclass='manual')and not(@outputclass='no_stars') and not(@outputclass='nochap part_number') and not(@outputclass='part_number nochap') and not(@outputclass='nochap part_number no_stars') and not(@outputclass='part_number nochap no_stars') and not(@outputclass='part_number no_stars nochap ') and not(@outputclass='no_stars nochap part_number') and not(@outputclass='no_stars part_number nochap') and not(@outputclass='nochap no_stars') and not(@outputclass='no_stars nochap') and not(@outputclass='nochap vrm_prefix_ver') and not(@outputclass='vrm_prefix_ver nochap') and not(@outputclass='nochap vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel nochap') and not(@outputclass='nochap no_stars vrm_prefix_ver') and not(@outputclass='no_stars nochap vrm_prefix_ver') and not(@outputclass='no_stars vrm_prefix_ver nochap') and not(@outputclass='vrm_prefix_ver nochap no_stars') and not(@outputclass='vrm_prefix_ver no_stars nochap') and not(@outputclass='technote part_number') and not(@outputclass='part_number technote') and not(@outputclass='technote part_number no_stars') and not(@outputclass='part_number no_stars technote') and not(@outputclass='part_number technote no_stars') and not(@outputclass='no_stars technote part_number') and not(@outputclass='no_stars part_number technote') and not(@outputclass='technote no_stars') and not(@outputclass='no_stars technote') and not(@outputclass='technote vrm_prefix_ver') and not(@outputclass='vrm_prefix_vertechnote') and not(@outputclass='technote vrm_prefix_rel') and not(@outputclass='vrm_prefix_rel technote') and not(@outputclass='technote no_stars vrm_prefix_ver') and not(@outputclass='legal manual') and not(@outputclass='manual legal') and not(@outputclass='part_number solutions') and not(@outputclass='part_number nochap') and not(@outputclass='solutions part_number') and not(@outputclass='nochap part_number')]/@outputclass)" separator=", " /></li></xsl:if>


<!--Deprecated brand ticket needs to be added-->
<xsl:if test=".//brand"><li class="tagerror"><span>Validator Error:</span>brand tag is deprecated and should not be used.</li></xsl:if>
<xsl:if test="//*[contains(@class, ' topic/brand ') and ancestor::*[contains(@class,' bookmap/bookmeta ')]][not(lower-case(.)='manual' or lower-case(.)='sfits' or lower-case(.)='legal' or lower-case(.)='technote' or lower-case(.)='service manual')]"><li class="metaerror">Brand should be Manual</li></xsl:if>
<!--  Check for text in <copyrfirst> (IDPL-9958) -->
<xsl:if test=".//copyrfirst"><li class="tagerror"><span>Validator error: </span>Remove text from &lt;copyrfirst&gt;. Release date derives from &lt;published&gt;&lt;completed&gt;&lt;month&gt; and &lt;published&gt;&lt;completed&gt;&lt;year&gt;.</li></xsl:if>

<!-- Check for text strings in <volume> (IDPL-9840) -->
<xsl:if test=".//volume/text()[contains(.,'rev')]"><li class="tagerror"><span>Validator Warning: </span>Do not add “rev”, “Rev”, “Version,” “Document revision,” or “Revision” because the string will be automatically added to the output.</li></xsl:if>
<xsl:if test=".//volume/text()[contains(.,'Rev')]"><li class="tagerror"><span>Validator Warning: </span>Do not add “rev”, “Rev”, “Version,” “Document revision,” or “Revision” because the string will be automatically added to the output.</li></xsl:if>
<xsl:if test=".//volume/text()[contains(.,'Revision')]"><li class="tagerror"><span>Validator Warning: </span>Do not add “rev”, “Rev”, “Version,” “Document revision,” or “Revision” because the string will be automatically added to the output.</li></xsl:if>
<xsl:if test=".//volume/text()[contains(.,'Version')]"><li class="tagerror"><span>Validator Warning: </span>Do not add “rev”, “Rev”, “Version,” “Document revision,” or “Revision” because the string will be automatically added to the output.</li></xsl:if>
<xsl:if test=".//volume/text()[contains(.,'Document revision')]"><li class="tagerror"><span>Validator Warning: </span>Do not add “rev”, “Rev”, “Version,” “Document revision,” or “Revision” because the string will be automatically added to the output.</li></xsl:if>

</xsl:template>
</xsl:stylesheet>
