<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the com.dell.qaroject hosted on
Sourceforge.net.-->
<!-- (c) Copyright Citrix Systems, Inc. All Rights Reserved. -->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:dita="***Function Processing***"
	xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/" exclude-result-prefixes="fo xs fn dita dita ditaarch">
	<xsl:param name="input"/>
	<xsl:param name="fileroot"/>
	<xsl:param name="OUTPUTDIR" />
	<xsl:param name="workset" />
	<xsl:param name="FILTERFILE" />
	<xsl:param name="BASEDIR" />
	<xsl:param name="conditionFile" />
	<xsl:param name="metfiles" />
	<xsl:param name="tempDir"/>
	<xsl:param name="pubname"/>
	<xsl:param name="pubver"/>
	<xsl:param name="inputdir"/>
	<xsl:include href="qachecks/_att_values.xsl"/>
	<!-- <xsl:include href="qachecks/_general_terms.xsl"/> -->
	<!-- Pavan Test in TD 14 environment -->
	<xsl:include href="qachecks/_language_standards.xsl"/>
	<xsl:include href="qachecks/_markup_checks.xsl"/>
	<xsl:include href="qachecks/_nesting_elements.xsl"/>
	<xsl:include href="qachecks/_output_standards.xsl"/>
	<xsl:include href="qachecks/_meta_values.xsl"/>
	<xsl:include href="qachecks/_accessibility_errors.xsl"/>
	<xsl:variable name="newline">
		<xsl:text>

		</xsl:text>
	</xsl:variable>

	<xsl:output method="html"/>

	<xsl:key name="tagErrors" match="li" use="@class" />


	<xsl:variable name="resourceId">
		<xsl:for-each select="/*//resourceid/@id[.=preceding::resourceid/@id]">
			<rid>
				<id>
					<xsl:value-of select="."/>
				</id>
				<fn>
					<xsl:value-of select="../@xtrf"/>
				</fn>
			</rid>
		</xsl:for-each>
	</xsl:variable>
	<xsl:variable name="xtrf" select="/*/@xtrf"/>
	<xsl:template match="/">

		<xsl:variable name="metaCount">
			<xsl:call-template name="meta_values"/>
		</xsl:variable>

		<xsl:variable name="hitCount">
			<xsl:call-template name="meta_values"/>
			<!--<xsl:call-template name="Output_Class"/>-->
			<!-- Section added to validate the o/p classes in topics and maps -->
			<xsl:for-each select="document(concat('file:///',$tempDir,'/',$fileroot,'.ditamap'))">
				<xsl:call-template name="Output_Class">
					<xsl:with-param name="ggg" select="/"/>
				</xsl:call-template>
			</xsl:for-each>
			<xsl:for-each select="tokenize(unparsed-text(replace(concat('file:///',$tempDir,'\fullditamap.list'),'\\','/'), 'utf-8'),'\n\r?')">
				<xsl:variable name="mapvalid">
					<xsl:value-of select="document(concat(substring-before($xtrf, $fileroot),substring-before(.,'.ditamap'),'.met'))//*[@name='FTITLE']"/>
				</xsl:variable>
				<xsl:if test="not($mapvalid[matches(.,'^[.a-z0-9_-]*$')])">
					<li class="tagwarning">Validator warning: Map Name: <strong>
						<xsl:value-of select="$mapvalid"/>
					</strong> is not compliant with standards. See <a href="https://confluence.gtie.dell.com/display/IKB/Tridion+object+naming+conventions">IDD Knowledge Base Articles.</a>
				</li>
			</xsl:if>
		</xsl:for-each>
		<xsl:if test="document(concat(substring-before($xtrf, $fileroot),'baseline.en-us.xml'))//*[@type='ISHNone']">
			<xsl:for-each select="document(concat(substring-before($xtrf, $fileroot),'baseline.en-us.xml'))//*[@type='ISHNone']">
				<li class="invaliddita">
					<span>Invalid DITA Error: </span>Missing reference <strong>
					<xsl:value-of select="@ref"/>
				</strong> in DITAmap.</li>
		</xsl:for-each>
	</xsl:if>
	<xsl:if test="@xtrf=$resourceId//rid/fn">
		<li class="invaliddita">
			<span>Invalid DITA Error: </span> "			<xsl:variable name="xtrf" select="@xtrf"/>
			<xsl:value-of select="$resourceId//rid[$xtrf=fn]/id"/>
" resourceid must be unique within document</li>
	</xsl:if>
	<xsl:if test="@xtrf=$resourceId//rid/fn">
		<li class="invaliddita">
			<span>Invalid DITA Error: </span> "			<xsl:variable name="xtrf" select="@xtrf"/>
			<xsl:value-of select="$resourceId//rid[$xtrf=fn]/id"/>
" resourceid must be unique within document</li>
	</xsl:if>
	<xsl:for-each select="document(concat('file:///',$tempDir,'/',$fileroot,'.ditamap'))//relcolspec[not (@type='concept' or @type='task' or @type='reference')]">
		<li class="invaliddita">
			<span>Invalid DITA Error: </span>relcolspec type contains other than concept, task, reference at <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.ditamap'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>
.</li>
	</xsl:for-each>

	<xsl:if test="not(.//notices)">
		<li class="metaerror">
			<span>Metadata Error: </span>&lt;notices&gt; element must be present in order to produce copyright</li>
	</xsl:if>
	<!--commented the old outputclass section -->
	<!--<xsl:if test=".//bookmap[exists(@outputclass) and not(@outputclass='nochap') and not(@outputclass='technote') and not(@outputclass='solutions') and not(@outputclass='part_number') and not(@outputclass='legal') and not(@outputclass='manual') and not(@outputclass='no_stars') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='no_help_folder') and not(@outputclass='landing_page')]"><li class="tagerror"><span>Validator Error:</span> Unsupported outputclass value(s) found: <strong><xsl:value-of select="distinct-values(.//bookmap[exists(@outputclass) and not(@outputclass='nochap') and not(@outputclass='technote') and not(@outputclass='solutions') and not(@outputclass='part_number') and not(@outputclass='legal') and not(@outputclass='manual') and not(@outputclass='no_stars') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='no_help_folder') and not(@outputclass='landing_page')]/@outputclass)" separator=", "/></strong></li></xsl:if>
<xsl:if test=".//keyword[exists(@outputclass) and not(@outputclass='branded')]"><li class="tagerror"><span>Validator Error:</span> Unsupported outputclass value(s) found at Keyword: <strong><xsl:value-of select="distinct-values(.//keyword[exists(@outputclass) and not(@outputclass='branded')]/@outputclass)" separator=", "/></strong></li></xsl:if>-->
	<xsl:if test="//*[contains(@class, ' topic/shortdesc ')] //b">
		<li class="semantic">
			<span>Semantic tagging Error: </span>Do not use typographic markup &lt;b&gt;</li>
	</xsl:if>
	<xsl:if test="//*[contains(@class, ' topic/shortdesc ')] //i">
		<li class="semantic">
			<span>Semantic tagging Error: </span>Do not use typographic markup &lt;i&gt;</li>
	</xsl:if>
	<xsl:if test="//*[contains(@class, ' topic/shortdesc ')] //u">
		<li class="semantic">
			<span>Semantic tagging Error: </span>Do not use typographic markup &lt;u&gt;</li>
	</xsl:if>
	<li>Bookmap Outputclass Attribute(s):  <xsl:for-each select="document(concat('file:///',$tempDir,'/',$fileroot,'.ditamap'))">
		<xsl:call-template name="Output_Class">
			<xsl:with-param name="ggg" select="/"/>
		</xsl:call-template>
	</xsl:for-each>
</li>
<!-- for each error type, create a collapsible div that indicates which template the error came from-->

<xsl:for-each select="self::taskbody">
	<xsl:if test="not(.//steps)">
		<li class="missingcontent">
			<span>Missing content Error: </span>Steps element is missing in task.</li>
	</xsl:if>
</xsl:for-each>
<xsl:for-each select="*[contains(@class,'topic/title')]|//*[contains(@class,'topic/body ')]|//*[contains(@class,' glossentry/glossentry ')]">
	<xsl:call-template name="att_values"/>
	<xsl:call-template name="language_standards"/>
	<xsl:call-template name="markup_checks"/>
	<xsl:call-template name="nesting_elements"/>
	<xsl:call-template name="output_standards"/>
	<xsl:choose>
		<xsl:when test="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)]) &gt; 250">
			<li style="color:#0000FF;">CAUTION: Word count should be less than 150</li>
		</xsl:when>
		<xsl:when test="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)]) &gt; 200">
			<li style="color:#0000FF;">ATTENTION: Word count should be less than 150</li>
		</xsl:when>
		<xsl:when test="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)]) &gt; 150">
			<li style="color:#0000FF;">SUGGESTION: Word count should be less than 150</li>
		</xsl:when>
	</xsl:choose>
	<!--<xsl:call-template name="Output_Class"/>-->
	<!-- Section added to validate the o/p classes in topics and maps -->
	<xsl:choose>
		<xsl:when test="contains(../@refclass,'bookmap/chapter') or contains(../@refclass,'bookmap/part')">
			<xsl:call-template name="Output_Class">
				<xsl:with-param name="ggg" select="."/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="Output_Class">
				<xsl:with-param name="ggg" select=".."/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
	<xsl:call-template name="meta_values"/>
	<xsl:call-template name="accessibility_errors"/>
	<xsl:call-template name="source_topic_checks"/>
</xsl:for-each>
<!--Roopesh IDPL-2439 Removed all special character flagging-->
<!--<xsl:for-each select="*[contains(@class,'bookmap/mainbooktitle')]|//*[contains(@class,'bookmap/booktitlealt ')]|//*[contains(@class,' glossentry/glossentry ')]">
	<xsl:call-template name="Pubtitlecheck"/>
	</xsl:for-each>-->
</xsl:variable>
<xsl:variable name="totalErrors">
<xsl:value-of select="count(key('tagErrors', 'tagerror', $hitCount)) + count(key('tagErrors', 'syntaxerror', $hitCount)) + count(key('tagErrors', 'metaerror', $hitCount)) + count(key('tagErrors', 'accerror', $hitCount)) + count(key('tagErrors', 'semantic', $hitCount)) + count(key('tagErrors', 'missingcontent', $hitCount)) + count(key('tagErrors', 'invaliddita', $hitCount)) + count(key('tagErrors', 'incorrectnest', $hitCount))"/>
</xsl:variable>

<xsl:variable name="totalWarnings">
<xsl:value-of select="count(key('tagErrors', 'tagwarning', $hitCount)) + count(key('tagErrors', 'standard', $hitCount))"/>
</xsl:variable>

<xsl:variable name="OTDIR">
<xsl:value-of select="replace($BASEDIR, '\\', '/')" />
</xsl:variable>
<xsl:variable name="inputMap">
<xsl:value-of select="$fileroot"/>
</xsl:variable>
<xsl:text disable-output-escaping="yes">&lt;</xsl:text>!doctype html<xsl:text disable-output-escaping="yes">&gt;</xsl:text>
<html>
<head>
	<link rel="icon" type="image/png" href="img/Dell.jpg"/>
	<title>Validator Standards Review</title>


	<style type="text/css"><![CDATA[
		body {font-family:sans-serif;}
		p {color:#25383C}
		ul {list-style: square}
		.tagerror {color: #B80000  }
		.semantic {color: #B80000  }
		.missingcontent {color: #B80000  }
		.invaliddita {color: #B80000  }
		.incorrectnest {color: #B80000  }
		.metaerror {color: #B80000  }
		.tagwarning {color: #FFC125  }
		.tagwarningtrans {color: #FFC125  }
		.standard {color: #385E0F  }
		.syntaxerror {color: #B80000  }
		.prodterm {color: #330099  }
		.accerror {color: #330099  }
		.genterm {color: #330099  }
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
		.info{
		color: green;
		}
		]]>

.accerror, .tagwarning, .metaerror, .tagerror, .standard, .syntaxerror, .semantic, .pubfail, .missingcontent, .invaliddita, .incorrectnest {
margin: 10px 0px;
padding:5px;

}
.accerror {
	color: #00529B;
    background-color: #BDE5F8;
	border-radius:.5em;
}
.tagwarning {
    color: #4F8A10;
    background-color: #DFF2BF;
	border-radius:.5em;
}
.tagwarning {
    color: #4F8A10;
    background-color: #FAFAD2;
	border-radius:.5em;
}
.metaerror {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
.tagerror {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
.semantic {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
.missingcontent {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
.invaliddita {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
.incorrectnest {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
.pubfail {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
.standard {
    color: #D8000C;
    background-color: #FFD2F2;
	border-radius:.5em;
}
.syntaxerror {
    color: #D8000C;
    background-color: #FFD2D2;
	border-radius:.5em;
}
h2{
color: #0076CE;
}
h3{
color: #0076CE;
}
td, th {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 8px;
} 
#violationSummary td, th{
text-align:center;
padding: 5px;
}

	header {
  background-color: #0076CE;
  padding: 20px;
  text-align: center;
  font-size: 20px;
  color: white;
}
footer {
  background-color: #0076CE;
  padding: 10px;
  text-align: center;
  color: white;
}

details {
  font: 16px "Open Sans", Calibri, sans-serif;
  width: 1800px;
  border-color: #006bbd !important;
}

details > summary {
  padding: 2px 6px;
  width: 110em;
  background-color: #eaeaea;
  border: none;
  box-shadow: 3px 3px 4px rgb(0 0 0 / 60%);
  border:1px solid !important;
  border-color: #eaeaea !important;
  cursor: pointer;
  list-style: none;
  
}
details > summary::-webkit-details-marker {
  display: none;
}

details > p {
  														<!--border-radius: 0 0 10px 10px;
  background-color: #ddd; -->
  padding: 2px 6px;
  margin: 0;
  box-shadow: 3px 3px 4px black;
}

summary::-webkit-details-marker {display: none}
summary:before{content: "+"; color: #363636; display: block; float: left; font-size: 1.7em; font-weight: bold; width: 20px;}
details[open] summary:before {content: "-";}


.button {
  background-color: #008CBA; /* Green */
  border: none;
  color: white;
  padding: 16px 32px;
  text-align: center;
  text-decoration: none;
  display: inline-block;
  font-size: 16px;
  margin: 4px 2px;
  transition-duration: 0.4s;
  cursor: pointer;
}
.button2:hover {
  background-color: #4CAF50;
  color: white;
}
.modal {
  display: none; /* Hidden by default */
  position: fixed; /* Stay in place */
  z-index: 1; /* Sit on top */
  padding-top: 100px; /* Location of the box */
  left: 0;
  top: 0;
  width: 100%; /* Full width */
  height: 100%; /* Full height */
  overflow: auto; /* Enable scroll if needed */
  background-color: rgb(0,0,0); /* Fallback color */
  background-color: rgba(0,0,0,0.4); /* Black w/ opacity */
}

/* Modal Content */
.modal-content {
  background-color: #fefefe;
  margin: auto;
  padding: 40px;
  border: 1px solid #888;
  width: fit-content;
}

/* The Close Button */
.close {
  color: #aaaaaa;
  float: right;
  font-size: 28px;
  font-weight: bold;
}

.close:hover,
.close:focus {
  color: #000;
  text-decoration: none;
  cursor: pointer;
}
														<!--summary::-webkit-details-marker {display: none}
summary:before{content: "\2193"; color: #363636; display: block; float: left; font-size: 1.5em; font-weight: bold; margin: -2px 10px 0 10px; padding: 0; text-align: center; width: 20px;}
details[open] summary:before {content: "\2191";} -->
		<!--   ol, ul {
    counter-reset: item;
   }
   li {
    display: list-item;
    list-style-type: none;
   }
   li.chapter::before {
    content: "";
   }
   li:before {
    content: counters(item, ".") ". ";
    counter-increment: item
   }		-->

	</style>
	<script>
		<!--function dderrorlist (value){
			//alert(value);
			var errorclasses = ['metaerror', 'semantic', 'missingcontent', 'invaliddita', 'incorrectnest', 'accerror', 'tagwarning'];
			var parent = document.getElementById('details-container');
			for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> errorclasses.length; j++){
			var elements = parent.getElementsByClassName(errorclasses[j]);
			for( var i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> elements.length; i++){
			 if (value == 'all' || elements[i].className == value)
			 elements[i].style.display = "list-item";
			 else
			elements[i].style.display = "none";
			}
			}
			}-->
		function showHideErrors(){
		var table =	document.getElementById("filter_table");
		var selList = table.querySelectorAll('[type="checkbox"]:checked');
		var errorclasses = [];
		for (var j = 0; j		<xsl:text disable-output-escaping="yes">&lt;</xsl:text> selList.length; j++){
		errorclasses.push(selList[j].value);
		}
		errorclasses.length > 0? showHideError(errorclasses): ShowAllErrors();
			modal.style.display = "none";
		}; 
		
		function ShowAllErrors(){
		showHideError(['all']);
		var table =	document.getElementById("filter_table");
		var selList = table.querySelectorAll('[type="checkbox"]:checked');
		for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> selList.length; j++){
		selList[j].checked =false;
		}
		modal.style.display = "none";
		}
		function showHideError(errArr){
				var errorclasses = ['metaerror', 'semantic', 'missingcontent', 'invaliddita', 'incorrectnest', 'pubfail', 'accerror', 'tagwarning'];
				var parent = document.getElementById('details-container');
				for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> errorclasses.length; j++){
				var elements = parent.getElementsByClassName(errorclasses[j]);
				for( var i=0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> elements.length; i++){
				 if (errArr.indexOf('all') <xsl:text disable-output-escaping="yes">&gt;</xsl:text> -1 || errArr.indexOf(elements[i].className) <xsl:text disable-output-escaping="yes">&gt;</xsl:text> -1)
				 elements[i].style.display = "list-item";
				 else
				elements[i].style.display = "none";
				}
			}
			var accFilters = document.getElementsByClassName('filterApplied');
			for (var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> accFilters.length; j++){
			accFilters[j].style.display = errArr.indexOf('all')<xsl:text disable-output-escaping="yes">&gt;</xsl:text> -1 ? 'none' : 'block' ;
			}
			}

	</script>
</head>
<body>
	<!-- trying to get the bookmap title, but the document function works relative to this xsl file, not to build.xml, so the input variable doesn't point to an actual document -->
	<header>
		<img src="img/Dell1.png" alt="Logo" align="left" width="60" height="60"/>
		<img src="img/DellTech.png" alt="Logo" align="right" width="110" height="60"/>
		<h1 style ="margin:6px">Validator Standards Review</h1>
	</header>
	<br/>
	<xsl:variable name="outputclass_attr_values" select="normalize-space(document($inputMap)/bookmap/@outputclass)" />


	<table id="violationSummary" border="1" cellpadding="2" cellspacing="2" align="center" style="width:800px;text-align:center;">
		<tbody>
			<tr>
				<td rowspan="11">
					<xsl:choose>
						<xsl:when test="$totalErrors &gt; 0 or $totalWarnings &gt; 10">
							<p align="center">
								<font size="20">FAIL</font>
							</p>
							<img alt="FAIL" src="img/fail.png" width="260"></img>
						</xsl:when>
						<xsl:when test="$totalErrors = 0 and $totalWarnings &lt; 10">
							<p align="center">
								<font size="20">PASS</font>
							</p>
							<img alt="Success" src="img/pass.png" width="260"></img>
						</xsl:when>
					</xsl:choose>

					<!-- use an if statement to select a pass or fail image -->
					<b>
						<p align="center">Total violation count: <xsl:value-of select="$totalErrors + $totalWarnings"/>
						</p>
					</b>
				</td>
			</tr>
			<tr>
				<td>
					<b>Pass/Fail</b>
				</td>
				<td>
					<b>Check Type</b>
				</td>
				<td>
					<b>Violations</b>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="count(key('tagErrors', 'metaerror', $hitCount)) &gt; 0">
							<img alt="FAIL" src="img/failsm.png"></img>
						</xsl:when>
						<xsl:when test="count(key('tagErrors', 'metaerror', $hitCount)) &lt; 1">
							<img alt="Success" src="img/passsm.png"></img>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<font class="tagerror">Metadata errors</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'metaerror', $hitCount))" />
				</td>
			</tr>


			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="count(key('tagErrors', 'semantic', $hitCount)) &gt; 0">
							<img alt="FAIL" src="img/failsm.png"></img>
						</xsl:when>
						<xsl:when test="count(key('tagErrors', 'semantic', $hitCount)) &lt; 1">
							<img alt="Success" src="img/passsm.png"></img>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<font class="tagerror">Semantic tagging errors</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'semantic', $hitCount))" />
				</td>
			</tr>

			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="count(key('tagErrors', 'missingcontent', $hitCount)) &gt; 0">
							<img alt="FAIL" src="img/failsm.png"></img>
						</xsl:when>
						<xsl:when test="count(key('tagErrors', 'missingcontent', $hitCount)) &lt; 1">
							<img alt="Success" src="img/passsm.png"></img>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<font class="tagerror">Missing content errors</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'missingcontent', $hitCount))" />
				</td>
			</tr>

			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="count(key('tagErrors', 'invaliddita', $hitCount)) &gt; 0">
							<img alt="FAIL" src="img/failsm.png"></img>
						</xsl:when>
						<xsl:when test="count(key('tagErrors', 'invaliddita', $hitCount)) &lt; 1">
							<img alt="Success" src="img/passsm.png"></img>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<font class="tagerror">Invalid dita errors</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'invaliddita', $hitCount))" />
				</td>
			</tr>

			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="count(key('tagErrors', 'incorrectnest', $hitCount)) &gt; 0">
							<img alt="FAIL" src="img/failsm.png"></img>
						</xsl:when>
						<xsl:when test="count(key('tagErrors', 'incorrectnest', $hitCount)) &lt; 1">
							<img alt="Success" src="img/passsm.png"></img>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<font class="tagerror">Incorrect nesting errors</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'incorrectnest', $hitCount))" />
				</td>
			</tr>

			<!-- commmenting tagging errors since the category is added for all the errors
				<tr>
				<td>
				<xsl:choose>
				<xsl:when test="count(key('tagErrors', 'tagerror', $hitCount)) &gt; 0">
				<img alt="FAIL" src="img/failsm.png"></img>
				</xsl:when>
				<xsl:when test="count(key('tagErrors', 'tagerror', $hitCount)) &lt; 1">
				<img alt="Success" src="img/passsm.png"></img>
				</xsl:when>
				</xsl:choose>
				</td>
				<td><font class="tagerror">Tagging errors</font></td>
				<td><xsl:value-of select="count(key('tagErrors', 'tagerror', $hitCount))" /></td>
				</tr> -->
			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="count(key('tagErrors', 'tagwarning', $hitCount)) &gt; 10">
							<img alt="FAIL" src="img/failsm.png"></img>
						</xsl:when>
						<xsl:when test="count(key('tagErrors', 'tagwarning', $hitCount)) &lt; 10">
							<img alt="Success" src="img/passsm.png"></img>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<font class="tagwarning">Tagging warnings</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'tagwarning', $hitCount))"/>
				</td>
			</tr>
			<!--							<tr>
				<td>
				<xsl:choose>
				<xsl:when test="count(key('tagErrors', 'standard', $hitCount)) &gt; 10">
				<img alt="FAIL" src="img/failsm.png"></img>
				</xsl:when>
				<xsl:when test="count(key('tagErrors', 'standard', $hitCount)) &lt; 10">
				<img alt="Success" src="img/passsm.png"></img>
				</xsl:when>
				</xsl:choose>
				</td>
				<td><font class="standard">Standards violations</font></td>
				<td><xsl:value-of select="count(key('tagErrors', 'standard', $hitCount))"/></td>
				</tr>  
				<tr>
				<td>
				<xsl:choose>
				<xsl:when test="count(key('tagErrors', 'syntaxerror', $hitCount)) &gt; 0">
				<img alt="FAIL" src="img/failsm.png"></img>
				</xsl:when>
				<xsl:when test="count(key('tagErrors', 'syntaxerror', $hitCount)) = 0">
				<img alt="Success" src="img/passsm.png"></img>
				</xsl:when>
				</xsl:choose>
				</td>
				<td><font class="syntaxerror">Syntax errors</font></td>
				<td><xsl:value-of select="count(key('tagErrors', 'syntaxerror', $hitCount))"/></td>
				</tr>-->
			<tr>
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
				<td>
					<font class="accerror">Accessibility errors</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'accerror', $hitCount))"/>
				</td>
			</tr>
			<tr>
				<td>
					<xsl:choose>
						<xsl:when test="count(key('tagErrors', 'pubfail', $hitCount)) &gt; 0">
							<img alt="FAIL" src="img/failsm.png"></img>
						</xsl:when>
						<xsl:when test="count(key('tagErrors', 'pubfail', $hitCount)) = 0">
							<img alt="Success" src="img/passsm.png"></img>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<font class="pubfail">Publishing failure errors</font>
				</td>
				<td>
					<xsl:value-of select="count(key('tagErrors', 'pubfail', $hitCount))"/>
				</td>
			</tr>
		</tbody>
	</table>

	<div id='details-container'>
		<h2 align="center">
			<u>Summary of Content Processed</u>
		</h2>

		<table border="1" cellpadding="2" cellspacing="2">
			<tbody>
				<tr>
					<td style="color:green">Report run on</td>
					<td style="color:green">
						<xsl:value-of select="format-date(current-date(),'[FNn], [D1o] [MNn,*-3], [Y]','en',(),())"/>
					</td>
				</tr>
				<tr>
					<td>
						<h3>Document information</h3>
					</td>
					<td>
						<table>
							<tr style='border:none;'>
								<td style='border:none;'>
									<ul>
										<h3>
											<b>
												<u>PUBLICATION DETAILS</u>
											</b>
										</h3>
										<xsl:call-template name="Pubtitlecheck"/>
										<li>Language Values Set: <xsl:value-of select="distinct-values(//*/@xml:lang)" separator=", " />
										</li>
									</ul>
								</td>
								<td style='border:none;'>
									<ul>
										<h3>
											<b>
												<u>BOOKMAP DETAILS</u>
											</b>
										</h3>
										<!--<li>Bookmap Name: <xsl:value-of select="document(concat(substring-before($metfiles,'.ditamap'),'.met'))//*[@name='FTITLE']"/><br/></li> -->
										<li>
											<xsl:variable name="bkmapvalid">
												<xsl:value-of select="document(concat(substring-before($metfiles,'.ditamap'),'.met'))//*[@name='FTITLE']"/>
											</xsl:variable>

											<xsl:choose>
												<xsl:when test="$bkmapvalid[matches(.,'^[.a-z0-9_-]*$')]">
	Bookmap Name: <xsl:value-of select="$bkmapvalid"/>
												<br/>
											</xsl:when>
											<xsl:otherwise>
	 Bookmap Name: <span class="tagwarning">
												<xsl:value-of select="$bkmapvalid"/>
											</span>
											<li class="tagwarning">BookMap is not compliant with standards. See <a href="https://confluence.gtie.dell.com/display/IKB/Tridion+object+naming+conventions">IDD Knowledge Base Articles.</a>
											</li>
										</xsl:otherwise>
									</xsl:choose>
								</li>



								<li>Bookmap Title: <xsl:value-of select="//mainbooktitle"/>
								</li>
								<li>Bookmap GUID: <xsl:value-of select="$inputMap"/>
								</li>
								<br/>
								<li>Short description: <xsl:value-of select=".//*[contains(@class, ' map/shortdesc ')]"/>
								<xsl:if test="not(.//*[contains(@class, ' map/shortdesc ')])">
									<li class="accerror">
										<span>Accessibility Error: </span>shortdesc element is missing or empty </li>
								</xsl:if>
							</li>
							<br/>
							<!-- Section added to validate the o/p classes in topics and maps -->
							<li>Bookmap Outputclass Attribute(s):  <xsl:for-each select="document(concat('file:///',$tempDir,'/',$fileroot,'.ditamap'))">
								<xsl:call-template name="Output_Class">
									<xsl:with-param name="ggg" select="/"/>
								</xsl:call-template>
							</xsl:for-each>
						</li>
						<!-- <li>Bookmap Outputclass Attribute(s):  <xsl:call-template name="Output_Class"/> 
									
									<xsl:for-each select="tokenize($outputclass_attr_values, ' ')">
										<br /><xsl:if test="normalize-space(.)!='no_stars' and normalize-space(.)!='nochap' and normalize-space(.)!='branded' and normalize-space(.)!='part_number' and normalize-space(.)!='technote' and normalize-space(.)!='abstract' and normalize-space(.)!='vrm_prefix_ver' and normalize-space(.)!='vrm_prefix_rel' and normalize-space(.)!='vrm_prefix_none' and normalize-space(.)!='show_hide' and normalize-space(.)!='show_hide_expanded' and normalize-space(.)!='no_help_folder' and normalize-space(.)!='landscape' and normalize-space(.)!='microvideo' and normalize-space(.)!='legal' and normalize-space(.)!='manual' and normalize-space(.)!='no_stars' and normalize-space(.)!='landing_page' and normalize-space(.)!='pagebreak' and normalize-space(.)!='nopagebreak'"><span class="tagerror">Validator Error: Unsupported outputclass attribute value: <xsl:value-of select="normalize-space(.)"/></span>
										</xsl:if>
									</xsl:for-each>
									
									<br /><xsl:if test="document($inputMap)/bookmap/chapter[position()>1 and exists(@outputclass) and @outputclass='no_help_folder'] "><span class="tagerror">Validator Error: The no_help_folder outputclass attribute option must be set on the first chapter element of the bookmap.</span>
									</xsl:if> </li>	-->
						<li>Bookmap version: <xsl:value-of select="document(concat(substring-before($metfiles,'.ditamap'),'.met'))//*[@name='VERSION']"/>
						<br/>
					</li>
					<li>Bookmap revision: <xsl:value-of select="document(concat(substring-before($metfiles,'.ditamap'),'.met'))//*[@name='FISHREVCOUNTER']"/>
					<br/>
				</li>
				<li>Bookmap status: <xsl:value-of select="document(concat(substring-before($metfiles,'.ditamap'),'.met'))//*[@name='FSTATUS']"/>
				<br/>
			</li>

			<!--	lists each unique domain value, but it is a long list	<li>domains used: <xsl:value-of select="distinct-values(//*/@domains)" separator=", " /></li> 
		<h3><b><u>DITA DETAILS</u></b></h3>
		<li>DITA versions used: <xsl:value-of select="distinct-values(//*/@ditaarch:DITAArchVersion)" separator=", " /></li>
		<li>DITA Open Toolkit build log: <a href="{$fileroot}.ditamap_dellqa.log" target="_blank">open in new window</a><br/></li>-->
		</ul>
	</td>
</tr>
</table>

</td>
</tr>
<tr>
<td>
<h3>Document/Topic Details, <br></br>
<br></br> Elements Count,<br></br>
<br></br>Non-Translated Elements</h3>
</td>
<td>
<table>
<tr>
	<td style='border:none;'>
		<h3>
			<b>
				<u>OBJECT DETAILS</u>
			</b>
		</h3>
	</td>
	<td style='border:none;'>
		<h3>
			<b>
				<u>ELEMENT DETAILS</u>
			</b>
		</h3>
	</td>
	<td style='border:none;'>
		<h3>
			<b>
				<u>TRANSLATION DETAILS</u>
			</b>
		</h3>
	</td>
</tr>
<tr>
	<td style='border:none;'>
		<ul>

			<li>Number of bridge topics: <xsl:value-of select="count(//*[ends-with(normalize-space(@class),normalize-space('- topic/topic '))])"/>
			</li>
			<li>Number of concept topics: <xsl:value-of select="count(//*[@class='- topic/topic concept/concept '])"/>
			</li>
			<li>Number of Task topics: <xsl:value-of select="count(//*[contains(@class,' topic/topic task/task')])"/>
			</li>
			<li>Number of Reference topics: <xsl:value-of select="count(//*[contains(@class,'- topic/topic       reference/reference ')])"/>
			</li>
			<li>Number of Gloss entry topics: <xsl:value-of select="count(//*[contains(@class,' topic/topic concept/concept glossentry/glossentry ')])"/>
			</li>
			<ul>
				<li>Total topics: <xsl:value-of select="count(//*[contains(@class,' topic/topic ')])"/>
				</li>
				<li>Total images: <xsl:value-of select="count(//image)"/>
				</li>
				<li>Total maps: <xsl:value-of select="count(tokenize(unparsed-text(replace(concat('file:///',$tempDir,'\fullditamap.list'),'\\','/'), 'utf-8'),'\n\r?')) - 1"/>
				</li>
				<li>Total Bookmaps: <xsl:value-of select="count(//*[contains(@class,' bookmap/bookmap ')])"/>
				</li>
			</ul>
		</ul>

		<xsl:variable name="statusCount">
			<xsl:for-each select="//conbody | //taskbody | //refbody | //body | //glossentry">
				<status>
					<xsl:variable name="versionId">
						<xsl:value-of select="substring-before($metfiles,concat($fileroot,'.ditamap'))"/>
					</xsl:variable>
					<xsl:variable name="fileId" select="substring(substring-after(@xtrf,'workset\'),1,string-length(@xtrf))"/>
					<xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FSTATUS']/text()"/>
				</status>
			</xsl:for-each>
		</xsl:variable>
		<p>Total Object Status:
			<xsl:for-each select="$statusCount//status[not(.=preceding::status)]">
				<xsl:value-of select="."/>
			 :				<xsl:value-of select="concat( round((count($statusCount//status[.=current()]) div count($statusCount//status) ) * 100),'%')"/>
			</xsl:for-each>
		</p>
	</td>
	<td style='border:none;'>
		<p>Publication contains <xsl:value-of select="count(distinct-values(descendant::*))" />
				distinct tag values in <xsl:value-of select="count(descendant::*)" />
				elements.</p>
	<p>Publication contains <xsl:value-of select="count(tokenize(lower-case(normalize-space(.)),'(\s|[,.?!:;])+')[string(.)])"/>
				words.</p>
</td>
<td style='border:none;'>
	<p>The following elements that are found in <strong>this publication </strong> will not get translated:</p>
	<span>
		<strong>Block: </strong>
	</span>
	<br/>
	<xsl:if test="//*/codeblock">
		<li>&lt;codeblock&gt;</li>
	</xsl:if>
	<xsl:if test="//*/faq">
		<li>&lt;faq&gt;</li>
	</xsl:if>
	<xsl:if test="//*/faqans">
		<li>&lt;faqans&gt;</li>
	</xsl:if>
	<xsl:if test="//*/faqquest">
		<li>&lt;faqquest&gt;</li>
	</xsl:if>
	<xsl:if test="//*/faqitem">
		<li>&lt;faqitem&gt;</li>
	</xsl:if>
	<xsl:if test="//*/faqlist">
		<li>&lt;faqlist&gt;</li>
	</xsl:if>
	<xsl:if test="//*/faqgroup">
		<li>&lt;faqgroup&gt;</li>
	</xsl:if>
	<xsl:if test="//*/faqbody">
		<li>&lt;faqbody&gt;</li>
	</xsl:if>
	<xsl:if test="//*/othermeta">
		<li>&lt;othermeta&gt;</li>
	</xsl:if>
	<xsl:if test="//*/volume">
		<li>&lt;volume&gt;</li>
	</xsl:if>

	<span>
		<strong>Inline: </strong>
	</span>
	<br/>
	<xsl:if test="//*/boolean">
		<li>&lt;boolean&gt;</li>
	</xsl:if>
	<xsl:if test="//*/brand">
		<li>&lt;brand&gt;</li>
	</xsl:if>
	<xsl:if test="//*/codeph">
		<li>&lt;codeph&gt;</li>
	</xsl:if>
	<xsl:if test="//*/completed">
		<li>&lt;completed&gt;</li>
	</xsl:if>
	<xsl:if test="//*/coords">
		<li>&lt;coords&gt;</li>
	</xsl:if>
	<xsl:if test="//*/day">
		<li>&lt;day&gt;</li>
	</xsl:if>
	<xsl:if test="//*/date">
		<li>&lt;date&gt;</li>
	</xsl:if>
	<xsl:if test="//*/month">
		<li>&lt;month&gt;</li>
	</xsl:if>
	<xsl:if test="//*/day">
		<li>&lt;day&gt;</li>
	</xsl:if>
	<xsl:if test="//*/prodname">
		<li>&lt;prodname&gt;</li>
	</xsl:if>
	<xsl:if test="//*/shape">
		<li>&lt;shape&gt;</li>
	</xsl:if>
	<xsl:if test="//*/started">
		<li>&lt;started&gt;</li>
	</xsl:if>
	<xsl:if test="//*/draft-comment">
		<li>&lt;draft-comment&gt;</li>
	</xsl:if>
	<xsl:if test="//*/month">
		<li>&lt;month&gt;</li>
	</xsl:if>
	<xsl:if test="//*/cmd">
		<li>&lt;cmd&gt;</li>
	</xsl:if>
	<xsl:if test="//*/edition">
		<li>&lt;edition&gt;</li>
	</xsl:if>
</td>
</tr>
</table>

</td>
</tr>
<!--<tr>
		<td>Readability Score
		</td>
		<td>
		<pre><xsl:value-of select="concat(substring-before(document(concat('file:///',$tempDir,'/readbilityScrore.xml'))//root,'Averaage'),'Average',substring-after(document(concat('file:///',$tempDir,'/readbilityScrore.xml'))//root,'Averaage'))"/></pre>
		</td>
		</tr> -->
<!--<tr>
		<td>Reuse Metrics Score</td>
		<td><xsl:variable name="versionPath"><xsl:value-of select="substring-before($metfiles,concat($fileroot,'.ditamap'))"/></xsl:variable><xsl:variable name="content"><t><xsl:value-of select="unparsed-text(replace(concat('file:///',$tempDir,'\hreftargets.list'),'\\','/'), 'utf-8')"/></t></xsl:variable><xsl:variable name="topiclist"><xsl:for-each select="tokenize($content, $newline)[.]"><a><xsl:value-of select="."/></a></xsl:for-each></xsl:variable><xsl:variable name="topicre"><xsl:for-each select="$topiclist//a"><xsl:for-each select="document(concat($versionPath, substring-before(.,'xml'),'met'))//ishfield[@name='FISHRELEASELABEL']"><xsl:if test="string-length(normalize-space()) &gt; 0"><recount/></xsl:if></xsl:for-each></xsl:for-each></xsl:variable><xsl:variable name="contentmap"><t><xsl:value-of select="unparsed-text(replace(concat('file:///',$tempDir,'\fullditamap.list'),'\\','/'), 'utf-8')"/></t></xsl:variable><xsl:variable name="topiclistmap"><xsl:for-each select="tokenize($contentmap, $newline)[.]"><a><xsl:value-of select="."/></a></xsl:for-each></xsl:variable><xsl:variable name="topicremap"><xsl:for-each select="$topiclistmap//a"><xsl:for-each select="document(concat($versionPath, substring-before(.,'.'),'.met'))//ishfield[@name='FISHRELEASELABEL']"><xsl:if test="string-length(normalize-space()) &gt; 0"><recount/></xsl:if></xsl:for-each></xsl:for-each></xsl:variable><xsl:result-document href="reuse.xml"><root>
		<xsl:choose><xsl:when test="((count($topicre//recount) + count($topicremap//recount)) div (count($topiclist//a) + count($topiclistmap//a))) &gt; 0"><xsl:value-of select="round((count($topicre//recount) + count($topicremap//recount)) div (count($topiclist//a) + count($topiclistmap//a)) * 100)"/>%</xsl:when><xsl:otherwise>0%</xsl:otherwise></xsl:choose></root></xsl:result-document>
		<xsl:choose><xsl:when test="((count($topicre//recount) + count($topicremap//recount)) div (count($topiclist//a) + count($topiclistmap//a))) &gt; 0"><xsl:value-of select="round((count($topicre//recount) + count($topicremap//recount)) div (count($topiclist//a) + count($topiclistmap//a)) * 100)"/>%</xsl:when><xsl:otherwise>0%</xsl:otherwise></xsl:choose><xsl:comment><xsl:value-of select="concat((count($topicre//recount) + count($topicremap//recount)),' div ',(count($topiclist//a) + count($topiclistmap//a)))"/></xsl:comment></td></tr>-->
<!-- Roopesh added condition list section -->
<!--<tr>
		<td>Conditions found</td>
		<td>
		<ul>
		<li>filter file: <xsl:value-of select="$FILTERFILE"/></li>

		<li>Conditions: <br/>
		<xsl:for-each select="document($conditionFile,/)//feature">&#160;&#160;&#160;&#160;&#160;Name: <xsl:value-of select="@name"/>&#160;&#160;&#160;&#160;&#160; Value: <xsl:value-of select="@value"/><br/></xsl:for-each></li>
		</ul>
		<p>Files contains condition:</p>
		<ul>
		<xsl:variable name="x"><xsl:for-each select="//*[@ishlabelxpath]"><a><xsl:copy-of select="@xtrf"/><xsl:copy-of select="@ishlabelxpath"/></a></xsl:for-each></xsl:variable>
		<xsl:for-each select="$x//a[not(@xtrf=preceding::*/@xtrf)]">
		<li><xsl:value-of select="@xtrf"/></li>
		</xsl:for-each>
		</ul>
		</td>
		</tr>
<tr>
<td>Element Counts</td>
<td>
<p>Publication contains <xsl:value-of select="count(distinct-values(descendant::*))" />
 distinct tag values in <xsl:value-of select="count(descendant::*)" />
 elements.</p>
<p>Publication contains <xsl:value-of select="count(tokenize(lower-case(normalize-space(.)),'(\s|[,.?!:;])+')[string(.)])"/>
 words.</p>
</td>
</tr>
<tr>
<td>Non-Translated Elements</td>
<td>


<p>The following elements that are found in <strong>this publication </strong> will not get translated:</p>
<span>
<strong>Block: </strong>
</span>
<br/>
<xsl:if test="//*/codeblock">
<li>&lt;codeblock&gt;</li>
</xsl:if>
<xsl:if test="//*/faq">
<li>&lt;faq&gt;</li>
</xsl:if>
<xsl:if test="//*/faqans">
<li>&lt;faqans&gt;</li>
</xsl:if>
<xsl:if test="//*/faqquest">
<li>&lt;faqquest&gt;</li>
</xsl:if>
<xsl:if test="//*/faqitem">
<li>&lt;faqitem&gt;</li>
</xsl:if>
<xsl:if test="//*/faqlist">
<li>&lt;faqlist&gt;</li>
</xsl:if>
<xsl:if test="//*/faqgroup">
<li>&lt;faqgroup&gt;</li>
</xsl:if>
<xsl:if test="//*/faqbody">
<li>&lt;faqbody&gt;</li>
</xsl:if>
<xsl:if test="//*/othermeta">
<li>&lt;othermeta&gt;</li>
</xsl:if>
<xsl:if test="//*/volume">
<li>&lt;volume&gt;</li>
</xsl:if>

<span>
<strong>Inline: </strong>
</span>
<br/>
<xsl:if test="//*/boolean">
<li>&lt;boolean&gt;</li>
</xsl:if>
<xsl:if test="//*/brand">
<li>&lt;brand&gt;</li>
</xsl:if>
<xsl:if test="//*/codeph">
<li>&lt;codeph&gt;</li>
</xsl:if>
<xsl:if test="//*/completed">
<li>&lt;completed&gt;</li>
</xsl:if>
<xsl:if test="//*/coords">
<li>&lt;coords&gt;</li>
</xsl:if>
<xsl:if test="//*/day">
<li>&lt;day&gt;</li>
</xsl:if>
<xsl:if test="//*/date">
<li>&lt;date&gt;</li>
</xsl:if>
<xsl:if test="//*/month">
<li>&lt;month&gt;</li>
</xsl:if>
<xsl:if test="//*/day">
<li>&lt;day&gt;</li>
</xsl:if>
<xsl:if test="//*/prodname">
<li>&lt;prodname&gt;</li>
</xsl:if>
<xsl:if test="//*/shape">
<li>&lt;shape&gt;</li>
</xsl:if>
<xsl:if test="//*/started">
<li>&lt;started&gt;</li>
</xsl:if>
<xsl:if test="//*/draft-comment">
<li>&lt;draft-comment&gt;</li>
</xsl:if>
<xsl:if test="//*/month">
<li>&lt;month&gt;</li>
</xsl:if>
<xsl:if test="//*/cmd">
<li>&lt;cmd&gt;</li>
</xsl:if>
<xsl:if test="//*/edition">
<li>&lt;edition&gt;</li>
</xsl:if>
</td>
</tr>-->
<tr>
<td>
<h3>General/Bookmap Issues</h3>
</td>
<td>
<xsl:call-template name="meta_values"/>
<!--<xsl:call-template name="Output_Class"/> -->
<xsl:for-each select="tokenize(unparsed-text(replace(concat('file:///',$tempDir,'\fullditamap.list'),'\\','/'), 'utf-8'),'\n\r?')">
<xsl:variable name="mapvalid">
<xsl:value-of select="document(concat(substring-before($xtrf, $fileroot),substring-before(.,'.ditamap'),'.met'))//*[@name='FTITLE']"/>
</xsl:variable>
<xsl:if test="not($mapvalid[matches(.,'^[.a-z0-9_-]*$')])">
<li class="tagwarning">Validator warning: Map Name: <strong>
	<xsl:value-of select="$mapvalid"/>
</strong> is not compliant with standards. See <a href="https://confluence.gtie.dell.com/display/IKB/Tridion+object+naming+conventions">IDD Knowledge Base Articles.</a>
</li>
</xsl:if>
</xsl:for-each>
	<!-- IDPL-19120 Add Validator errors when variable libraries are added in regular content-->
	
	<xsl:for-each select="tokenize(unparsed-text(replace(concat('file:///',$tempDir,'\libraryinfo.list'),'\\','/'), 'utf-8'),'\n\r?')">
		<xsl:variable name="mapname">
			<xsl:value-of select="substring-before(.,',')"/>
		</xsl:variable>	
		<xsl:variable name="objecttype">
			<xsl:value-of select="substring-after(.,',')"/>
		</xsl:variable>
		<xsl:if test="not($mapname='')">	
			<li class="invaliddita">Invalid DITA Error:An object of type ConceptLibrary, ReferenceLibrary, or TaskLibrary is referenced directly in a Map/Bookmap.<br />
				<strong>
					<xsl:value-of select="$mapname"/> 
				</strong> is an object of type
				<strong>
					<xsl:value-of select="$objecttype"/>
				</strong> Library that is referenced directly in a Map/Bookmap.
			</li>
		</xsl:if>
	</xsl:for-each>
	<!-- IDPL-19120 Add Validator errors when variable libraries are added in regular content -->
	
<xsl:if test="document(concat(substring-before($xtrf, $fileroot),'baseline.en-us.xml'))//*[@type='ISHNone']">
<xsl:for-each select="document(concat(substring-before($xtrf, $fileroot),'baseline.en-us.xml'))//*[@type='ISHNone']">
<li class="invaliddita">
<span>Invalid DITA Error: </span>Missing reference <strong>
<xsl:value-of select="@ref"/>
</strong> in DITAmap.</li>
</xsl:for-each>
</xsl:if>
<xsl:if test="@xtrf=$resourceId//rid/fn">
<li class="invaliddita">
<span>Invalid DITA Error: </span> "<xsl:variable name="xtrf" select="@xtrf"/>
<xsl:value-of select="$resourceId//rid[$xtrf=fn]/id"/>
" resourceid must be unique within document</li>
</xsl:if>
<xsl:if test="@xtrf=$resourceId//rid/fn">
<li class="invaliddita">
<span>Invalid DITA Error: </span> "<xsl:variable name="xtrf" select="@xtrf"/>
<xsl:value-of select="$resourceId//rid[$xtrf=fn]/id"/>
" resourceid must be unique within document</li>
</xsl:if>

<xsl:for-each select="document(concat('file:///',$tempDir,'/',$fileroot,'.ditamap'))//relcolspec[not (@type='concept' or @type='task' or @type='reference')]">
<li class="invaliddita">
<span>Invalid DITA Error: </span> relcolspec type contains other than concept, task, reference at <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.ditamap'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>
.</li>
</xsl:for-each>
<xsl:if test="not(.//notices)">
<li class="metaerror">
<span>Metadata Error: </span>&lt;notices&gt; element must be present in order to produce copyright</li>
</xsl:if>
<!--commented the old outputclass section -->
<!--<xsl:if test=".//bookmap[exists(@outputclass) and not(@outputclass='nochap') and not(@outputclass='technote') and not(@outputclass='solutions') and not(@outputclass='part_number') and not(@outputclass='legal') and not(@outputclass='manual') and not(@outputclass='no_stars') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='no_help_folder') and not(@outputclass='landing_page')]"><li class="tagerror"><span>Validator Error:</span> Unsupported outputclass value(s) found: <strong><xsl:value-of select="distinct-values(.//bookmap[exists(@outputclass) and not(@outputclass='nochap') and not(@outputclass='technote') and not(@outputclass='solutions') and not(@outputclass='part_number') and not(@outputclass='legal') and not(@outputclass='manual') and not(@outputclass='no_stars') and not(@outputclass='vrm_prefix_ver') and not(@outputclass='vrm_prefix_rel') and not(@outputclass='no_help_folder') and not(@outputclass='landing_page')]/@outputclass)" separator=", "/></strong></li></xsl:if>
<xsl:if test=".//keyword[exists(@outputclass) and not(@outputclass='branded')]"><li class="tagerror"><span>Validator Error:</span> Unsupported outputclass value(s) found at Keyword: <strong><xsl:value-of select="distinct-values(.//keyword[exists(@outputclass) and not(@outputclass='branded')]/@outputclass)" separator=", "/></strong></li></xsl:if>-->
</td>
</tr>

</tbody>
</table>

<div id="myModal" class="modal">

<!-- Modal content -->
<div class="modal-content">
<span class="close">&#215;</span>
<h2 align="center">
<u>Error filter options</u>
</h2>
<table border="1" cellpadding="2" cellspacing="2" align="center" id="filter_table">
<tr>
<th>Selection</th>
<th>Error category</th>
<th>Details Section</th>
<th>Violations filter Section</th>
</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="accerror" />
</div>
</td>
<td>
							Accessibility Errors
</td>
<td rowspan="8">
<p>
<strong>Set your filter sections here:</strong>
</p>
<p>Select the error or warning that you<br></br> want to show in the report below </p>
<button id="submit" onclick="showHideErrors()">Apply Filters</button>
<button id="submit1" onclick="ShowAllErrors()">Clear Filters</button>
<!--<p align="center">(OR)</p>
							<p>
								<strong>Select your dropdown filter here:</strong>
							</p>
							<p>Select the individual error or warning from <br></br> the drop-down list that you want to show<br></br> in the report below</p>
							<p>
								<form>
								Error Filter:
									<select name="list" id="taglist" onchange="dderrorlist(this.value);">
										<option id="All" selected="selected" value="all">All Errors</option>
										<option id="AccessibilityErrors" value="accerror">Accessibility Errors</option>
										<option id="IncorrectNesting Errors" value="incorrectnest">Incorrect Nesting Errors</option>
										<option id="InvalidDITAErrors" value="invaliddita">Invalid DITA Errors</option>
										<option id="MetadataErrors" value="metaerror">Metadata Error</option>
										<option id="MissingContent errors" value="missingcontent">Missing Content errors</option>
										<option id="semantictagging Errors" value="semantic">semantic tagging Errors</option>
										<option id="TagWarning" value="tagwarning">Tag Warning</option>
									</select>
								</form>
							</p>-->
</td>
<td rowspan="10">
<button id="button1" onclick="SwitchButtons('button1');" class="sideviewtoggle myButton button button2">Hide Topics without violations</button>
<button id="button2" onclick="SwitchButtons('button2');" class="sideviewtoggle myButton button button2" style='display:none;'>Show entire report</button>
<p align="center">(OR) </p>
<button id="button3" onclick="SwitchButton('button3');" class="sideviewtoggle myButton button button2">Collapse all</button>
<button id="button4" onclick="SwitchButton('button4');" class="sideviewtoggle myButton button button2" style='display:none;'>Expand all</button>
</td>

</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="incorrectnest" />
</div>
</td>
<td>Incorrect Nesting Errors</td>
</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="invaliddita" />
</div>
</td>
<td>Invalid DITA Errors</td>
</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="metaerror" />
</div>
</td>
<td>Metadata Errors</td>
</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="missingcontent" />
</div>
</td>
<td>Missing Content Errors</td>
</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="pubfail" />
</div>
</td>
<td>Publishing Failure Errors</td>
</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="semantic" />
</div>
</td>
<td>semantic Tagging Errors</td>
</tr>
<tr>
<td>
<div class="form-control">
<input type="checkbox" value="tagwarning" />
</div>
</td>
<td>Tag Warning</td>
</tr>
</table>
</div>

</div>

<h2 align="center">
<u>QA Violations</u><!--<button style="float: right;" onclick="myFunction()">Hide the errorless topics</button><button style="float: right;" onclick="myFunction1()">show the errorless topics</button> -->
</h2>
<p>
<button id="myBtn" style="float: right; position: fixed; right: 20px; bottom: 400px" class="sideviewtoggle myButton button button2">Show Report Filters</button>
</p>
<script>
function SwitchButtons(buttonId) {
  if (buttonId == 'button1') {
  var element = document.getElementsByTagName("details");
  var elements = document.getElementsByClassName("xsdffff");
	for(var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> element.length; i++) {
		element[i].setAttribute('open','open');
		}
	for(var j = 0; j <xsl:text disable-output-escaping="yes">&lt;</xsl:text> elements.length; j++) {
		elements[j].parentNode.removeAttribute('open');
	}
	document.getElementById('button1').style.display = 'none';
	document.getElementById('button2').style.display = 'block';

  } else {
	var elements = document.getElementsByTagName("details");
	
	for(var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> elements.length; i++) {
		elements[i].setAttribute('open','open');
	}
	document.getElementById('button1').style.display = 'block';
	document.getElementById('button2').style.display = 'none';
  }
  modal.style.display = "none";
 
}
function SwitchButton(buttonId) {
	var elements = document.getElementsByTagName("details");
	for(var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> elements.length; i++) {
	  buttonId == 'button3' ? elements[i].removeAttribute('open'):elements[i].setAttribute('open','open');
	}
	document.getElementById('button4').style.display = buttonId == 'button3' ? 'block':'none';
	document.getElementById('button3').style.display = buttonId == 'button3' ? 'none':'block';
	modal.style.display = "none";
  }
var modal = document.getElementById("myModal");
var btn = document.getElementById("myBtn");
var span = document.getElementsByClassName("close")[0];
btn.onclick = function() {
  modal.style.display = "block";
}
span.onclick = function() {
  modal.style.display = "none";
}
window.onclick = function(event) {
  if (event.target == modal) {
    modal.style.display = "none";
  }
}
</script>
<!-- <xsl:apply-templates select="//*[(contains(@class,' topic/shortdesc ') and not(following-sibling::*[contains(@class,' topic/body ')])) or contains(@class,' topic/body ') or contains(@class,' glossentry/glossentry ')]"/>	-->
<xsl:variable name="x">
<xsl:apply-templates select="//*[(contains(@class,' topic/shortdesc ') and not(following-sibling::*[contains(@class,' topic/body ')])) or contains(@class,' topic/body ') or contains(@class,' glossentry/glossentry ')]"/>
</xsl:variable>
<!--<xsl:copy-of select="$x"/> -->
<xsl:for-each-group select="$x/*" group-ending-with="details[contains(@data-level,'level1')]">
<!--<div id="{concat('bb',position())}">
		  
		  </div> -->
<xsl:for-each select="current-group()">
<xsl:copy-of select="."/>
</xsl:for-each>
</xsl:for-each-group>
</div>
<footer>
<p style="color:white">&#169; Tool developed and maintained by IDD CoPS</p>
</footer>
<script>
	  (function (){
	  var elements = document.getElementsByClassName('parent');
	  for(var i = 0; i <xsl:text disable-output-escaping="yes">&lt;</xsl:text> elements.length; i++) {
		elements[i].addEventListener('click', function(e){
			//alert(e.target.innerText)
			var next = e.currentTarget.nextElementSibling;
			while(next &amp;&amp; next.className != 'parent')
			{
				if(e.currentTarget.hasAttribute('open'))
					next.removeAttribute('open');
				else
					next.setAttribute('open','open');
				next = next.nextElementSibling;
			}
		})
	}
	})();		
</script>

</body>
</html>
<xsl:result-document href="wordcount.csv">
<xsl:variable name="xcd">
<t>
<xsl:apply-templates select="*" mode="wcr"/>
</t>
</xsl:variable>
<xsl:text>Publication GUID,Word Count
</xsl:text>
<xsl:value-of select="document(concat('file:///',$pubname))//parameter[@name='export-document']"/>
,<xsl:value-of select="count(tokenize(lower-case($xcd),'(\s|[,.?!:;])+')[string(.)])"/>
<xsl:text>
		Topic GUID,Word Count
</xsl:text>
<xsl:apply-templates select="//*[contains(@class,' topic/body ') or contains(@class,' glossentry/glossentry ')]" mode="wc"/>
</xsl:result-document>
<xsl:result-document href="topiccount.xml">
<root>
<xsl:value-of select="count(//*[contains(@class,' topic/topic ')])"/>
</root>
</xsl:result-document>
<!--<xsl:result-document href="accessability.txt">
	<root>
	<xsl:value-of select="count(key('tagErrors', 'accerror', $hitCount))"/>
	</root>
	</xsl:result-document> -->
</xsl:template>

<xsl:template match="node()|@*" mode="x">
<xsl:copy>
<xsl:apply-templates select="node()|@*" mode="x"/>
</xsl:copy>
</xsl:template>

<xsl:template match="*" mode="wcr">
<xsl:copy>
<xsl:apply-templates select="node()|@*" mode="wcr"/>
</xsl:copy>
</xsl:template>

<xsl:template match="@*" mode="wcr">
<xsl:copy/>
</xsl:template>

<xsl:template match="related-links" mode="wcr"/>


<xsl:template match="*[contains(@class,' topic/shortdesc ') or contains(@class,' topic/body ') or contains(@class,' glossentry/glossentry ')]" mode="wc">
<xsl:for-each select="self::conbody | self::taskbody | self::refbody | self::body | self::glossentry">
<xsl:variable name="fileId" select="substring(substring-after(@xtrf,'workset\'),1,string-length(@xtrf))"/>
<xsl:value-of select="substring-before($fileId,'.xml')"/>
,<xsl:value-of select="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)]) + count(tokenize(lower-case(../title),'(\s|[,.?!:;])+')[string(.)])+ count(tokenize(lower-case(../shortdesc),'(\s|[,.?!:;])+')[string(.)])"/>
<xsl:text>
</xsl:text>
</xsl:for-each>
</xsl:template>

<xsl:template match="*[(contains(@class,' topic/shortdesc ') and not(following-sibling::*[contains(@class,' topic/body ')])) or contains(@class,' topic/body ') or contains(@class,' glossentry/glossentry ')]">

<xsl:for-each select="self::shortdesc[not(following-sibling::*[contains(@class,' topic/body ')])] | self::conbody | self::taskbody | self::refbody | self::body | self::glossentry">

<xsl:variable name="tempError">
<xsl:if test="self::conbody or self::taskbody or self::refbody">
<xsl:if test="../*[contains(@class, ' topic/shortdesc ') and .//b]">
<li class="semantic">
<span>Semantic tagging Error: </span>Do not use typographic markup &lt;b&gt;</li>
</xsl:if>
<xsl:if test="../*[contains(@class, ' topic/shortdesc ') and .//i]">
<li class="semantic">
<span>Semantic tagging Error: </span>Do not use typographic markup &lt;i&gt;</li>
</xsl:if>
<xsl:if test="../*[contains(@class, ' topic/shortdesc ') and .//u]">
<li class="semantic">
<span>Semantic tagging Error: </span>Do not use typographic markup &lt;u&gt;</li>
</xsl:if>
</xsl:if>
<xsl:if test="*[contains(@class, ' topic/shortdesc ') and .//b]">
<li class="semantic">
<span>Semantic tagging Error: </span>Do not use typographic markup &lt;b&gt;</li>
</xsl:if>
<xsl:if test="*[contains(@class, ' topic/shortdesc ') and .//i]">
<li class="semantic">
<span>Semantic tagging Error: </span>Do not use typographic markup &lt;i&gt;</li>
</xsl:if>
<xsl:if test="*[contains(@class, ' topic/shortdesc ') and .//u]">
<li class="semantic">
<span>Semantic tagging Error: </span>Do not use typographic markup &lt;u&gt;</li>
</xsl:if>
<!-- for each error type, create a collapsible div that indicates which template the error came from-->
<xsl:choose>
<xsl:when test="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)]) &gt; 250">
<li style="color:#0000FF;">CAUTION: Word count should be less than 150</li>
</xsl:when>
<xsl:when test="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)]) &gt; 200">
<li style="color:#0000FF;">ATTENTION: Word count should be less than 150</li>
</xsl:when>
<xsl:when test="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)]) &gt; 150">
<li style="color:#0000FF;">SUGGESTION: Word count should be less than 150</li>
</xsl:when>
</xsl:choose>
<xsl:for-each select="self::taskbody">
<xsl:if test="not(.//steps)">
<li class="missingcontent">
<span>Missing content Error: </span>Steps element is missing in task.</li>
</xsl:if>
</xsl:for-each>
<!-- output class in topic level-->
<!--<xsl:call-template name="Output_Class"/>-->
<!-- Section added to validate the o/p classes in topics and maps -->
<xsl:choose>
<xsl:when test="contains(../@refclass,'bookmap/chapter') or contains(../@refclass,'bookmap/part')">
<xsl:call-template name="Output_Class">
<xsl:with-param name="ggg" select="."/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:call-template name="Output_Class">
<xsl:with-param name="ggg" select=".."/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
<xsl:call-template name="att_values"/>
<xsl:call-template name="language_standards"/>
<xsl:call-template name="markup_checks"/>
<xsl:call-template name="nesting_elements"/>
<xsl:call-template name="output_standards"/>
<xsl:call-template name="accessibility_errors"/>
<xsl:call-template name="source_topic_checks"/>
<xsl:call-template name="meta_values"/>

</xsl:variable>

<details open="open" style="margin-left:{(count(ancestor::*[contains(@class,' topic/topic ')]) - 1) * 25}pt">
<xsl:if test="(count(ancestor::*[contains(@class,' topic/topic ')]) - 1) = 0">
<xsl:attribute name="data-level">level1</xsl:attribute>
<xsl:attribute name="class">parent</xsl:attribute>
</xsl:if>
<xsl:if test="count($tempError//li) eq 0">
<xsl:attribute name="id">vghhhhhgf</xsl:attribute>
</xsl:if>
<summary>
<p>
<b>&#x3000; Topic title: <xsl:choose>
<xsl:when test="self::glossentry">
<xsl:value-of select="*[contains(@class,' glossentry/glossterm ')]"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="preceding-sibling::title[contains(@class, ' topic/title ')]"/>
</xsl:otherwise>
</xsl:choose>
<xsl:choose>
<xsl:when test="count($tempError//li) ne 0">
<strong style="color:orange; float:right; display:none" class="filterApplied">Filters Applied: Some Errors or Warnings may not display.</strong>
</xsl:when>
</xsl:choose>
</b>
</p>
</summary>
<br></br>
<xsl:variable name="fileId" select="substring(substring-after(@xtrf,'workset\'),1,string-length(@xtrf))"/>
<xsl:choose>
<xsl:when test="count($tempError//li) eq 0">
<div class="xsdffff">
GUID: <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/@ishref"/>
<br></br>
Object Title: <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>
<br></br>
Version: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='VERSION']/text()"/>
<br></br>
Revision: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FISHREVCOUNTER']/text()"/>
<br></br>
Status: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FSTATUS']/text()"/>
<br></br>
<b>Author ID: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FAUTHOR']/text()"/>
<br></br>
</b>
ESTIMATED Word Count: <xsl:value-of select="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)])"/>
<br></br>
<xsl:copy-of select="$tempError"/>
</div>
</xsl:when>
<xsl:otherwise>
GUID: <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/@ishref"/>
<br></br>
Object Title: <xsl:value-of select="doc(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FTITLE']/text()"/>
<br></br>
Version: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='VERSION']/text()"/>
<br></br>
Revision: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FISHREVCOUNTER']/text()"/>
<br></br>
Status: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FSTATUS']/text()"/>
<br></br>
<b>Author ID: <xsl:value-of select="document(replace(concat(substring-before(@xtrf,'.xml'),'.met'),'\\','/'))/ishobject/ishfields/ishfield[@name='FAUTHOR']/text()"/>
<br></br>
</b>
ESTIMATED Word Count: <xsl:value-of select="count(tokenize(lower-case(.),'(\s|[,.?!:;])+')[string(.)])"/>
<br></br>
<xsl:copy-of select="$tempError"/>

</xsl:otherwise>
</xsl:choose>
</details>

</xsl:for-each>

</xsl:template>

<xsl:template name="Pubtitlecheck">
<xsl:variable name="booktitle">
<xsl:value-of select="//mainbooktitle"/>
</xsl:variable>
<xsl:variable name="altbooktitle">
<xsl:value-of select="//booktitlealt"/>
</xsl:variable>
<xsl:variable name="pubtitle">
<xsl:value-of select="document(concat('file:///',$pubname))//parameter[@name='documenttitle']"/>
</xsl:variable>
<!--<li>Publication Name: <xsl:value-of select="$pubtitle"/></li> -->
<li>
<xsl:choose>
<xsl:when test="$pubtitle[matches(.,'^[.a-z0-9_-]*$')]">
											Publication Name: <xsl:value-of select="$pubtitle"/>
<br/>
</xsl:when>
<xsl:otherwise>
											Publication Name: <xsl:value-of select="$pubtitle"/>
<br/>
<span class="tagwarning">Publication Title is not compliant with standards.</span>
</xsl:otherwise>
</xsl:choose>
</li>
<br/>
<li>Publication Title: <xsl:value-of select="$booktitle"/>
</li>
<!--<xsl:if test=".//mainbooktitle[not(*)]"><span class="tagerror"><span>Validator Error: </span>Missing or empty mainbooktitle element </span></xsl:if><br/> -->
<li>Publication GUID: <xsl:value-of select="document(concat('file:///',$pubname))//parameter[@name='export-document']"/>
</li>
<xsl:variable name="pubver">
<xsl:value-of select="document(concat('file:///',$pubname))//parameter[@name='baseline-name']"/>
</xsl:variable>
<li>Publication version: <xsl:value-of select="substring-before(substring-after($pubver, '-v'),'-GUID')"/>
</li>
<li>Publication Alt Book Title: <xsl:value-of select="$altbooktitle"/>
</li>
<li>Publisher Name: <xsl:value-of select="document(concat('file:///',$pubname))//parameter[@name='FISHPUBLISHER']"/>
</li>
<li>Baseline Values: <xsl:value-of select="document(concat('file:///',$pubname))//parameter[@name='baseline-name']"/>
</li>

</xsl:template>

</xsl:stylesheet>
