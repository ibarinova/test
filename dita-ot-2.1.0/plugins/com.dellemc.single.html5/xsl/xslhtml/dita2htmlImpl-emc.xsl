<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:exsl="http://exslt.org/common" xmlns:java="org.dita.dost.util.ImgUtils"
                xmlns:url="org.dita.dost.util.URLUtils"
                exclude-result-prefixes="dita-ot dita2html ditamsg exsl java url xs">

    <xsl:template match="*" mode="chapterHead">
        <head>
            <xsl:value-of select="$newline"/>
            <!-- initial meta information -->
            <xsl:call-template name="generateCharset"/>   <!-- Set the character set to UTF-8 -->
            <!--
                        <xsl:call-template name="generateDefaultCopyright"/> &lt;!&ndash; Generate a default copyright, if needed &ndash;&gt;
                        <xsl:call-template name="generateDefaultMeta"/> &lt;!&ndash; Standard meta for security, robots, etc &ndash;&gt;
                        <xsl:call-template name="getMeta"/>           &lt;!&ndash; Process metadata from topic prolog &ndash;&gt;
                        <xsl:call-template name="copyright"/>         &lt;!&ndash; Generate copyright, if specified manually &ndash;&gt;
                        <xsl:call-template name="generateCssLinks"/>  &lt;!&ndash; Generate links to CSS files &ndash;&gt;
                        <xsl:call-template name="generateChapterTitle"/> &lt;!&ndash; Generate the <title> element &ndash;&gt;
                        <xsl:call-template name="gen-user-head" />    &lt;!&ndash; include user's XSL HEAD processing here &ndash;&gt;
                        <xsl:call-template name="gen-user-scripts" /> &lt;!&ndash; include user's XSL javascripts here &ndash;&gt;
            -->
            <xsl:call-template name="gen-user-styles"/>  <!-- include user's XSL style element and content here -->
            <xsl:call-template name="gen-user-title"/>  <!-- include user's XSL style element and content here -->
            <!--<xsl:call-template name="processHDF"/>        &lt;!&ndash; Add user HDF file, if specified &ndash;&gt;-->
        </head>
        <xsl:value-of select="$newline"/>
    </xsl:template>


    <xsl:template match="*" mode="chapterBody">
        <body>
            <xsl:apply-templates select="." mode="addAttributesToHtmlBodyElement"/>
            <xsl:call-template name="setaname"/>  <!-- For HTML4 compatibility, if needed -->
            <xsl:value-of select="$newline"/>
            <!--<xsl:apply-templates select="." mode="addHeaderToHtmlBodyElement"/>-->

            <!-- Include a user's XSL call here to generate a toc based on what's a child of topic -->
            <xsl:call-template name="gen-user-sidetoc"/>

            <xsl:apply-templates select="." mode="addContentToHtmlBodyElement"/>
            <!--<xsl:apply-templates select="." mode="addFooterToHtmlBodyElement"/>-->
        </body>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="gen-user-sidetoc">
        <xsl:apply-templates select="." mode="navToc"/>
    </xsl:template>

    <xsl:template match="*" mode="navToc">
        <xsl:variable name="TOC-header-value">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'TOC'"/>
            </xsl:call-template>
        </xsl:variable>
        <h2 id="topPage" style="color:#1F4998">
            <xsl:value-of select="normalize-space($mainbooktitle)"/>
            <xsl:choose>
                <xsl:when test="$ARGS.BU='rsa' and contains($TRANSTYPE, 'draft')">
                    <span class="draftClass" style="margin-left:150px;">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'DraftRSA'"/>
                        </xsl:call-template>
                    </span>
                </xsl:when>
                <xsl:when test="contains($TRANSTYPE, 'draft')">
                    <span class="draftClass" style="margin-left:150px;">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Draft'"/>
                        </xsl:call-template>
                    </span>
                </xsl:when>
            </xsl:choose>
        </h2>
        <h3>
            <xsl:value-of select="$TOC-header-value"/>
        </h3>

        <xsl:variable name="map-toc">
            <xsl:apply-templates
                    select="$MAP-doc/*/*[contains(@class, 'map/topicref')][not(contains(@class, 'bookmap/frontmatter'))]"
                    mode="toc"/>
        </xsl:variable>
        <xsl:variable name="fixed-toc">
            <xsl:apply-templates select="$map-toc" mode="fixed-toc"/>
        </xsl:variable>
        <nav>
            <div id="tree">
                <ul>
                    <xsl:copy-of select="$fixed-toc"/>
                </ul>
            </div>
        </nav>
    </xsl:template>

    <xsl:template match="@*|node()" mode="fixed-toc">
        <xsl:choose>
            <xsl:when test="local-name() = 'class'"/>
            <xsl:when test="local-name() = 'href'">
                <xsl:variable name="current-value" select="normalize-space(.)"/>
                <xsl:variable name="href-value">
                    <xsl:choose>
                        <xsl:when test="contains($current-value, '#')">
                            <xsl:value-of select="concat('#', substring-after($current-value, '#'))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="."/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:attribute name="href">
                    <xsl:value-of select="$href-value"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()" mode="fixed-toc"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="gen-user-styles">
        <xsl:value-of select="$newline"/>
        <style media="screen" type="text/css">
            <xsl:text disable-output-escaping="yes">
                            /*
            | This file is part of the DITA Open Toolkit project hosted on
            | Sourceforge.net. See the accompanying license.txt file for
            | applicable licenses.
            */

            /*
            | (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved.
            */

            html,
            body{
            /*  height: 100%;
            width: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
            background-color: #fff;*/
            font-family:Verdana, Arial, Helvetica, sans-serif;
            font-size:8pt;
            line-height:12pt;
            padding-bottom:1%;
            }

            .unresolved{
            background-color:skyblue;
            }
            .noTemplate{
            background-color:yellow;
            }

            .base{
            background-color:#ffffff;
            }

            /* Add space for top level topics */
            .nested0{
            margin-top:1em;
            }

            /* div with class=p is used for paragraphs that contain blocks, to keep the XHTML valid */
            .p{
            margin-top:1em
            }

            /* Default of italics to set apart figure captions */
            .figcap{
            font-style:italic
            }
            .figdesc{
            font-style:normal
            }

            /* Use @frame to create frames on figures */
            .figborder{
            border-style:solid;
            padding-left:3px;
            border-width:2px;
            padding-right:3px;
            margin-top:1em;
            border-color:Silver;
            }
            .figsides{
            border-left:2px solid;
            padding-left:3px;
            border-right:2px solid;
            padding-right:3px;
            margin-top:1em;
            border-color:Silver;
            }
            .figtop{
            border-top:2px solid;
            margin-top:1em;
            border-color:Silver;
            }
            .figbottom{
            border-bottom:2px solid;
            border-color:Silver;
            }
            .figtopbot{
            border-top:2px solid;
            border-bottom:2px solid;
            margin-top:1em;
            border-color:Silver;
            }

            /* Most link groups are created with div. Ensure they have space before and after. */
            .ullinks{
            list-style-type:none
            }
            .ulchildlink{
            margin-top:1em;
            margin-bottom:6pt
            }
            .olchildlink{
            margin-top:1em;
            margin-bottom:6pt
            }
            .linklist{
            margin-bottom:6pt
            }
            .linklistwithchild{
            margin-left:1.5em;
            margin-bottom:6pt
            }
            .sublinklist{
            margin-left:1.5em;
            margin-bottom:6pt
            }
            .relconcepts{
            margin-top:1em;
            margin-bottom:6pt
            }
            .reltasks{
            margin-top:1em;
            margin-bottom:6pt
            }
            .relref{
            margin-top:1em;
            margin-bottom:6pt
            }
            .relinfo{
            margin-top:1em;
            margin-bottom:6pt
            }
            .breadcrumb{
            font-size:smaller;
            margin-bottom:6pt
            }
            dt.prereq{
            margin-left:20px;
            }

            /* Set heading sizes, getting smaller for deeper nesting */
            /* Comtech 08132013 updated title color/size/underline */
            .topictitle1{
            margin-top:0pt;
            margin-bottom:24pt;
            color:#1F4998;
            font-size:12pt;
            border-bottom:1pt solid #1F4998;
            padding-bottom:6pt;
            padding-top:12pt;
            }
            .topictitle2{
            margin-top:1pc;
            margin-bottom:.45em;
            font-size:1.17em;
            }
            .topictitle3{
            margin-top:1pc;
            margin-bottom:.17em;
            font-size:1.17em;
            font-weight:bold;
            }
            .topictitle4{
            margin-top:.83em;
            font-size:1.17em;
            font-weight:bold;
            }
            .topictitle5{
            font-size:1.17em;
            font-weight:bold;
            }
            .topictitle6{
            font-size:1.17em;
            font-style:italic;
            }
            .sectiontitle{
            margin-top:1em;
            margin-bottom:0em;
            color:black;
            font-size:1.17em;
            font-weight:bold;
            }
            .section{
            margin-top:1em;
            margin-bottom:6pt
            }
            .example{
            margin-top:1em;
            margin-bottom:6pt
            }
            div.tasklabel{
            margin-top:1em;
            margin-bottom:6pt;
            }
            h2.tasklabel,
            h3.tasklabel,
            h4.tasklabel,
            h5.tasklabel,
            h6.tasklabel{
            font-size:100%;
            }

            /* All note formats have the same default presentation */
            /* EMC	  IB5	21-Aug-2014		TKT-130: Admonition graphics should appear consistent with WebWorks */
            .note{
            border-bottom:1px solid black;
            border-top:1px solid black;
            display: inline-block;
            margin-top: 4px;
            margin-bottom: 4px;
            padding-top: 2px;
            padding-bottom: 2px;
            line-height: 14px;
            }
            .notetext{
            margin-top:1em;
            margin-bottom: .5em;
            display: inline-block;
            }
            .notetitle{
            font-weight:bold;
            color:blue;
            display: inline-block;
            }
            .notelisttitle{
            font-weight:bold
            }
            .tip{
            margin-top:1em;
            margin-bottom:1em;
            }
            .tiptitle{
            font-weight:bold;
            }
            .fastpath{
            margin-top:1em;
            margin-bottom:1em;
            }
            .fastpathtitle{
            font-weight:bold
            }
            .important{
            margin-top:1em;
            margin-bottom:1em;
            }
            .importanttitle{
            font-weight:bold
            }
            .remember{
            margin-top:1em;
            margin-bottom:1em;
            }
            .remembertitle{
            font-weight:bold
            }
            .restriction{
            margin-top:1em;
            margin-bottom:1em;
            }
            .restrictiontitle{
            font-weight:bold
            }
            .attention{
            margin-top:1em;
            margin-bottom:1em;
            }
            .attentiontitle{
            font-weight:bold
            }
            .danger{
            border-bottom:1px solid black;
            display: inline-block;
            margin-top: 4px;
            margin-bottom: 4px;
            padding-top: 2px;
            padding-bottom: 2px;
            line-height: 14px;
            }
            .dangertitle{
            font-weight:bold;
            }
            .dangertext{
            margin-top:1em;
            margin-bottom: .5em;
            font-weight:bold;
            }
            .caution{
            border-bottom:1px solid black;
            display: inline-block;
            margin-top: 4px;
            margin-bottom: 4px;
            padding-top: 2px;
            padding-bottom: 2px;
            line-height: 14px;
            }
            .cautiontitle{
            font-weight:bold;
            }
            .cautiontext{
            margin-top:1em;
            margin-bottom: .5em;
            font-weight:bold;
            }
            .warning{
            border-bottom:1px solid black;
            display: inline-block;
            margin-top: 4px;
            margin-bottom: 4px;
            padding-top: 2px;
            padding-bottom: 2px;
            line-height: 14px;
            }
            .warningtext{
            margin-top:1em;
            margin-bottom: .5em;
            font-weight:bold;
            }
            .warningtitle{
            font-weight:bold;
            }
            .notice{
            border-bottom:1px solid black;
            display: inline-block;
            margin-top: 4px;
            margin-bottom: 4px;
            padding-top: 2px;
            padding-bottom: 2px;
            line-height: 14px;
            }
            .noticetext{
            margin-top:1em;
            margin-bottom: .5em;
            }
            .noticetitle{
            font-weight:bold;
            /*text-align:center;*/
            }
            /* Simple lists do not get a bullet */
            ul.simple{
            list-style-type:none
            }

            /* Used on the first column of a table, when rowheader="firstcol" is used */
            .firstcol{
            font-weight:bold;
            }

            /* Various basic phrase styles */
            .bold{
            font-weight:bold;
            }
            .boldItalic{
            font-weight:bold;
            font-style:italic;
            }
            .italic{
            font-style:italic;
            }
            .underlined{
            text-decoration:underline;
            }
            .uicontrol,
            .wintitle{
            font-weight:bold;
            }
            .parmname{
            font-weight:bold;
            }
            /*.kwd{
            font-weight:bold;
            }*/
            .defkwd{
            font-weight:bold;
            text-decoration:underline;
            }
            /*.var,*/
            .cite{
            font-style:italic;
            }
            .shortcut{
            text-decoration:underline;
            }

            /*.cmdname{
            font-family:courier, fixed, monospace;
            }*/
            .option{
            font-family:courier, fixed, monospace;
            }
            .parmname{
            font-family:courier, fixed, monospace;
            font-weight:normal;
            }


            /* Default of bold for definition list terms */
            .dlterm{
            font-weight:bold;
            margin-bottom: 1em;
            }
            .dd{
            margin-bottom: 1em;
            }
            /* Use CSS to expand lists with @compact="no" */
            .dltermexpand{
            font-weight:bold;
            margin-top:1em;
            }
            *[compact = "yes"] &gt; li{
            margin-top:0em;
            }
            *[compact = "no"] &gt; li{
            margin-top:.53em;
            }
            .liexpand{
            margin-top:1em;
            margin-bottom:6pt
            }
            .sliexpand{
            margin-top:1em;
            margin-bottom:6pt
            }
            .dlexpand{
            margin-top:1em;
            margin-bottom:6pt
            }
            .ddexpand{
            margin-top:1em;
            margin-bottom:6pt
            }
            .stepexpand{
            margin-top:1em;
            margin-bottom:6pt
            }
            .substepexpand{
            margin-top:1em;
            margin-bottom:6pt
            }

            /* Align images based on @align on topic/image */
            div.imageleft{
            text-align:left
            }
            div.imagecenter{
            text-align:center
            }
            div.imageright{
            text-align:right
            }
            div.imagejustify{
            text-align:justify
            }

            /* The cell border can be turned on with
            {border-right:solid}
            This value creates a very thick border in Firefox (does not match other tables)

            Firefox works with
            {border-right:solid 1pt}
            but this causes a barely visible line in IE */
            .cellrowborder{
            border-left:none;
            border-top:none;
            border-right:solid 1px;
            border-bottom:solid 1px
            }
            .row-nocellborder{
            border-left:none;
            border-right:none;
            border-top:none;
            border-right:hidden;
            border-bottom:solid 1px
            }
            .cell-norowborder{
            border-top:none;
            border-bottom:none;
            border-left:none;
            border-bottom:hidden;
            border-right:solid 1px
            }
            .nocellnorowborder{
            border:none;
            border-right:hidden;
            border-bottom:hidden
            }

            /*pre.screen{
            padding:5px 5px 5px 5px;
            border:outset;
            background-color:#CCCCCC;
            margin-top:2px;
            margin-bottom:2px;
            white-space:pre
            }
            .codeblock{
            border:1pt solid #1F4998;
            resize:both;
            overflow:auto;
            font-family:monospace;
            }*/
            .systemoutput{
            font-weight:bold;
            }
            span.filepath{
            font-family:courier, fixed, monospace;
            }
            .filepath,
            .apiname{
            font-family:courier, fixed, monospace;
            }


            /* OXYGEN PATCH START - EXM-18359 */
            body{
            margin-left:5px;
            margin-top:5px;
            }
            /* OXYGEN PATCH END - EXM-18359 */

            /* OXYGEN PATCH START - EXM-18138 */
            span.uicontrol &gt; img{
            padding-right:5px;
            }
            /* OXYGEN PATCH END - EXM-18138 */

            /* OXYGEN PATCH START EXM-17248 - Center figure captions. */
            div.fignone p.figcap{
            display:block;
            text-align:left;
            font-weight:bold;
            padding:2px 10px 5px 10px;
            }

            div.fignone p.figcapcenter{
            display:block;
            text-align:center;
            font-weight:bold;
            padding:2px 10px 5px 10px;
            }

            div.fignone p.figcapright{
            display:block;
            text-align:right;
            font-weight:bold;
            padding:2px 10px 5px 10px;
            }

            div.fignone p.figcapjustify{
            display:block;
            text-align:justify;
            font-weight:bold;
            padding:2px 10px 5px 10px;
            }

            div.fignone img{
            padding-top:5px;
            padding-left:10px;
            padding-right:10px;
            }

            /*Comtech 08/15/2013  Added below CSS classes to account for EMC required markup.  Classes are set by default in HTML transform, but specific style classes needed to be added*/
            sup{
            vertical-align:top;
            position:relative;
            top:-0.5em;
            }

            table{
            font-size:8pt;
            }
            .entry{
            vertical-align:top;
            }
            thead{
            background-color:#EFF5FA;
            }
            .proptypehd,.propvaluehd,.propdeschd{
            background-color:#EFF5FA;
            }
            span.tablecap{
            font-weight:bold;
            }
            caption{
            font-size:8pt;
            margin-bottom:6pt;
            text-align:left;
            }
            /* OXYGEN PATCH END EXM-17248 */
            /*  EMC		HTML5	10-Jul-2014  	kwd, cmdname, synph should be monospace font */
            .kwd,
            .cmdname,
            .synph{
            font-family: 'Courier New' , Courier, monospace;
            }
            /* Below styles should be consistent with the WebWorks */
            pre,
            .screen,
            .codeblock,
            .msgblock,
            .lines{
            border:none;
            padding:0pt;
            white-space:pre;
            font-family: 'Courier New' , Courier, monospace;
            background-color: #f0f0f0;
            overflow:auto;
            margin-bottom: 16px;
            margin-right: 0px;
            margin-top: 16px;
            padding-bottom: 8px;
            padding-left: 16px;
            padding-right: 0px;
            padding-top: 8px;
            }
            /*
            DELLEMC CUSTOMIZATION
            */
            /* The following sections define modifications to the default DITA-OT styles for Simple XHTML output. */
            .draft{text-align: center; color: #1F4998; font-weight: bold; font-size: 10pt;}
            .footer{}
            .header{}
            .varname{font-style:italic;}
            .choicetable{margin-top: 10px}
            /*Apply CSS class to print symbols*/
            .disc{list-style-type:disc;}
            .square{list-style-type:square;}
            .ndash {list-style-type:none; margin-left:0px;}
            ul.ndash &gt; li:before { content: '\2014\00a0\00a0' }
            dd.dd &gt; p.p{margin-top: 0px;}
            .table, .simpletable, .stentry, .sthead {border-color: black; margin-bottom: 8px;}
            .li, .substep, .itemgroup{margin-bottom: 8px; margin-top: 8px;}
            .cli_value{ font-weight: bold; margin-bottom: 8px; margin-left: 16pt; margin-top: 8px;}
            .cli_desc{  margin-bottom: 8px; margin-left: 32pt; margin-top: 8px;}
            .cli_syntax, .cli_description, .cli_example, .cli_prereq{ margin-bottom: 8px; margin-top: 8px;}
            .cli_label { margin-bottom: 8px;}
            .choicetable  &gt; thead &gt;tr &gt;th , .chdesc, .choption, .choicetable{border-color: black; border-style: solid;  border-width: 1px;}
            .fntable {margin-left: 36pt; margin-bottom: 8px;}
            .fn {margin-bottom: 4px;}
            .fn a {text-decoration: none}
            .figcap{ font-style:italic; font-weight: bold; }
            .b{font-weight: bold;}
            .relinfotitle{
            border-bottom-color: #1F4998;
            border-bottom-style: solid;
            border-bottom-width: 2px;
            color: #1F4998;
            margin-bottom: 16px;
            margin-right: 0px;
            margin-top: 16px;
            padding-bottom: 2px;
            padding-left: 8px;
            padding-right: 0px;
            padding-top: 5px;
            width: 250px;
            }
            div.relinfo &gt; div &gt; a.link {
            line-height: 14px;
            margin-bottom: 8px;
            margin-left: 0px;
            margin-right: 8px;
            margin-top: 8px;
            }
            .userinput{font-weight: bold; font-family:courier, fixed, monospace;}
            .option {font-style:normal;}
            .codeph{ font-family: 'Courier New' , Courier, monospace;}
            /* EMC 	IB6 	21-Oct-2014 	TKT-167:Consistently format lines controlled by @colsep and @rowsep attributes in tables */
            .row-topcellborder{
            border:none;
            border-right:hidden;
            border-bottom:none
            }

            .admonition td:first-of-type{
            padding-left: 0;
            padding-right: 5px;
            border-right: 3px solid rgb(5,125,183);
            }

            .admonition.danger td:first-of-type{
            border-right: 3px solid rgb(255,102,0);
            }

            .admonition.warning td:first-of-type{
            border-right: 3px solid rgb(206,32,40);
            }

            .admonition.caution td:first-of-type{
            border-right: 3px solid rgb(240,174,29);
            }

            .admonition-body p{
            margin-top: 8px;
            margin-bottom: 8px;
            }

            .admonition-body .bold {
            font-weight: bold;
            }

            .admonition-label {
            font-weight: bold;
            color: rgb(5,125,183);
            border-bottom: none;
            border-top: none;
            }

            .admonition-label.danger {
            color: rgb(255,102,0);
            }

            .admonition-label.caution {
            color: rgb(240,174,29);
            }

            .admonition-label.warning {
            color: rgb(206,32,40);
            }

            .admonition-image-container {
            }

            .admonition-image {
            width: 24px;
            max-width: inherit;
            }

            .admonition.note {
            }

            .admonition {
            border-bottom: none;
            border-top: none;
            display: block;
            }
            </xsl:text>
        </style>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="gen-user-title">
        <title>
            <xsl:value-of select="$mainbooktitle"/>
            <xsl:choose>
                <xsl:when test="$ARGS.BU='rsa' and contains($TRANSTYPE, 'draft')">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'DraftRSA'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="contains($TRANSTYPE, 'draft')">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Draft'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </title>
    </xsl:template>

    <xsl:template match="*" mode="addContentToHtmlBodyElement">
        <!--<main role="main">-->
            <!--<article role="article">-->
<!--
                <xsl:attribute name="aria-labelledby">
                    <xsl:apply-templates select="*[contains(@class,' topic/title ')] |
                                       self::dita/*[1]/*[contains(@class,' topic/title ')]" mode="return-aria-label-id"/>
                </xsl:attribute>
-->
                <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
                <xsl:apply-templates/> <!-- this will include all things within topic; therefore, -->
                <!-- title content will appear here by fall-through -->
                <!-- followed by prolog (but no fall-through is permitted for it) -->
                <!-- followed by body content, again by fall-through in document order -->
                <!-- followed by related links -->
                <!-- followed by child topics by fall-through -->
                <xsl:call-template name="gen-endnotes"/>    <!-- include footnote-endnotes -->
                <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
            <!--</article>-->
        <!--</main>-->
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]" mode="child.topic" name="child.topic">
        <xsl:param name="nestlevel" as="xs:integer">
            <xsl:choose>
                <!-- Limit depth for historical reasons, could allow any depth. Previously limit was 5. -->
                <xsl:when test="count(ancestor::*[contains(@class, ' topic/topic ')]) > 9">9</xsl:when>
                <xsl:otherwise><xsl:sequence select="count(ancestor::*[contains(@class, ' topic/topic ')])"/></xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <div class="nested{$nestlevel}">
<!--
            <xsl:attribute name="aria-labelledby">
                <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="return-aria-label-id"/>
            </xsl:attribute>
-->
            <xsl:call-template name="gen-topic">
                <xsl:with-param name="nestlevel" select="$nestlevel"/>
            </xsl:call-template>
        </div>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="gen-topic">
        <xsl:param name="nestlevel" as="xs:integer">
            <xsl:choose>
                <!-- Limit depth for historical reasons, could allow any depth. Previously limit was 5. -->
                <xsl:when test="count(ancestor::*[contains(@class, ' topic/topic ')]) > 9">9</xsl:when>
                <xsl:otherwise><xsl:sequence select="count(ancestor::*[contains(@class, ' topic/topic ')])"/></xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:choose>
            <xsl:when test="parent::dita and not(preceding-sibling::*)">
                <!-- Do not reset xml:lang if it is already set on <html> -->
                <!-- Moved outputclass to the body tag -->
                <!-- Keep ditaval based styling at this point (replace DITA-OT 1.6 and earlier call to gen-style) -->
                <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass" mode="add-ditaval-style"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="commonattributes">
                    <xsl:with-param name="default-output-class" select="concat('nested', $nestlevel)"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="gen-toc-id"/>
        <xsl:call-template name="setidaname"/>
        <xsl:apply-templates select="*[not(contains(@class, ' topic/shortdesc '))]"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/body ')]">
        <xsl:apply-templates/>
        <a href="#topPage">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'BacktoTop'"/>
            </xsl:call-template>
        </a>
    </xsl:template>

    <!-- object, desc, & param -->
    <xsl:template match="*[contains(@class,' topic/object ')]" name="topic.object">
        <object>
            <xsl:copy-of
                    select="@id | @declare | @codebase | @type | @archive | @height | @usemap | @tabindex | @classid | @data | @codetype | @standby | @width | @name"/>
            <xsl:if test="@longdescref or *[contains(@class, ' topic/longdescref ')]">
                <xsl:apply-templates select="." mode="ditamsg:longdescref-on-object"/>
            </xsl:if>
            <xsl:apply-templates/>
            <!-- Test for Flash movie; include EMBED statement for non-IE browsers -->
            <xsl:if test="contains(@codebase,'swflash.cab')">
                <embed>
                    <xsl:if test="@id">
                        <xsl:attribute name="name">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:copy-of select="@height | @width"/>
                    <xsl:attribute name="type">
                        <xsl:text>application/x-shockwave-flash</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="pluginspage">
                        <xsl:text>http://www.macromedia.com/go/getflashplayer</xsl:text>
                    </xsl:attribute>
                    <xsl:if test="*[contains(@class,' topic/param ')]/@name='movie'">
                        <xsl:attribute name="src">
                            <xsl:value-of
                                    select="*[contains(@class,' topic/param ')][@name='movie']/@value"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="*[contains(@class,' topic/param ')]/@name='quality'">
                        <xsl:attribute name="quality">
                            <xsl:value-of
                                    select="*[contains(@class,' topic/param ')][@name='quality']/@value"
                            />
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:if test="*[contains(@class,' topic/param ')]/@name='bgcolor'">
                        <xsl:attribute name="bgcolor">
                            <xsl:value-of
                                    select="*[contains(@class,' topic/param ')][@name='bgcolor']/@value"
                            />
                        </xsl:attribute>
                    </xsl:if>
                </embed>
            </xsl:if>
        </object>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/param ')]" name="topic.param">
        <param>
            <xsl:copy-of select="@name | @id | @value"/>
        </param>
    </xsl:template>

    <!-- need to add test for object/desc to avoid conflicts -->
    <xsl:template match="*[contains(@class,' topic/object ')]/*[contains(@class,' topic/desc ')]"
                  name="topic.object_desc">
        <span>
            <xsl:copy-of select="@name | @id | value"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/p ')]" name="topic.p">
        <xsl:choose>
            <xsl:when
                    test="descendant::*[contains(@class,' topic/pre ')] or
                                descendant::*[contains(@class,' topic/ul ')] or
                                descendant::*[contains(@class,' topic/sl ')] or
                                descendant::*[contains(@class,' topic/ol ')] or
                                descendant::*[contains(@class,' topic/lq ')] or
                                descendant::*[contains(@class,' topic/dl ')] or
                                descendant::*[contains(@class,' topic/note ')] or
                                descendant::*[contains(@class,' topic/lines ')] or
                                descendant::*[contains(@class,' topic/fig ')] or
                                descendant::*[contains(@class,' topic/table ')] or
                                descendant::*[contains(@class,' topic/simpletable ')]">
                <div class="p">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="setid"/>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="setid"/>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ol ')]" name="topic.ol">
        <xsl:if test="contains(@class,' task/steps ')">
            <xsl:apply-templates select="." mode="generate-task-label">
                <xsl:with-param name="use-label">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Steps Open'"/>
                    </xsl:call-template>
                </xsl:with-param>
            </xsl:apply-templates>
        </xsl:if>
        <xsl:variable name="olcount"
                      select="count(ancestor-or-self::*[contains(@class,' topic/ol ')])"/>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:call-template name="setaname"/>
        <ol>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="@compact"/>
            <xsl:choose>
                <xsl:when test="$olcount mod 3 = 1"/>
                <xsl:when test="$olcount mod 3 = 2">
                    <xsl:attribute name="type">a</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="type">i</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </ol>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/ul ')]" name="topic.ul">
        <xsl:variable name="templevel" select="count(ancestor-or-self::*[contains(@class,' topic/ul ')])"/>
        <xsl:variable name="level">
            <xsl:choose>
                <xsl:when test="$templevel>3">3</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$templevel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:call-template name="setaname"/>
        <ul>
            <!-- IB6 4-Sep-2014 TKT-166: HTML5 Fix bullet symbol hierarchy within tables inside a substep. -->
            <xsl:if test="$templevel>3">
                <xsl:attribute name="style">margin-left:15px;</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="@compact"/>
            <!-- IB6 4-Sep-2014 TKT-166: HTML5 Fix bullet symbol hierarchy within tables inside a substep. -->
            <xsl:choose>
                <xsl:when test="$level = 1">
                    <xsl:attribute name="class">disc</xsl:attribute>
                </xsl:when>
                <xsl:when test="$level = 2">
                    <xsl:attribute name="class">square</xsl:attribute>
                </xsl:when>
                <xsl:when test="$level = 3">
                    <xsl:attribute name="class">ndash</xsl:attribute>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:call-template name="setid"/>
            <xsl:apply-templates/>
        </ul>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/fig ')]" name="topic.fig">
        <xsl:variable name="default-fig-class">
            <xsl:apply-templates select="." mode="dita2html:get-default-fig-class"/>
        </xsl:variable>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <figure>
            <xsl:if test="$default-fig-class!=''">
                <xsl:attribute name="class">
                    <xsl:value-of select="$default-fig-class"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class" select="$default-fig-class"/>
            </xsl:call-template>
            <xsl:call-template name="setscale"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="*[not(contains(@class,' topic/title '))][not(contains(@class,' topic/desc '))] |text()|comment()|processing-instruction()"/>
            <xsl:call-template name="place-fig-lbl"/>
        </figure>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="place-fig-lbl">
        <xsl:param name="stringName"/>
        <!-- Number of fig/title's including this one -->
        <xsl:variable name="fig-count-actual" select="count(preceding::*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/title ')])+1"/>
        <xsl:variable name="ancestorlang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>
        <xsl:choose>
            <!-- title -or- title & desc -->
            <xsl:when test="*[contains(@class,' topic/title ')]">
                <p>
                    <xsl:choose>
                        <xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='center']">
                            <xsl:attribute name="class">figcapcenter</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='right']">
                            <xsl:attribute name="class">figcapright</xsl:attribute>
                        </xsl:when>
                        <xsl:when test="*[contains(@class, ' topic/image ')][@placement='break'][@align='justify']">
                            <xsl:attribute name="class">figcapjustify</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class">figcap</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- Comtech 08/15/2013 Remove the Figure gentext from the Table titles -->
                    <!--
              <xsl:choose>      <!-\- Hungarian: "1. Figure " -\->
              <xsl:when test="( (string-length($ancestorlang)=5 and contains($ancestorlang,'hu-hu')) or (string-length($ancestorlang)=2 and contains($ancestorlang,'hu')) )">
               <xsl:value-of select="$fig-count-actual"/><xsl:text>. </xsl:text>
               <xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'Figure'"/>
               </xsl:call-template><xsl:text> </xsl:text>
              </xsl:when>
              <xsl:otherwise>
               <xsl:call-template name="getString">
                <xsl:with-param name="stringName" select="'Figure'"/>
               </xsl:call-template><xsl:text> </xsl:text><xsl:value-of select="$fig-count-actual"/><xsl:text>. </xsl:text>
              </xsl:otherwise>
              </xsl:choose>-->
                    <!-- OXYGEN PATCH END  EXM-18109 -->

                    <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="figtitle"/>
                </p>

                <xsl:if test="*[contains(@class,' topic/desc ')]">
                    <xsl:text>. </xsl:text>
                    <span class="figdesc">
                        <xsl:for-each select="*[contains(@class,' topic/desc ')]">
                            <xsl:call-template name="commonattributes"/>
                        </xsl:for-each>
                        <xsl:apply-templates select="*[contains(@class,' topic/desc ')]" mode="figdesc"/>
                    </span>
                </xsl:if>
            </xsl:when>
            <!-- desc -->
            <xsl:when test="*[contains(@class, ' topic/desc ')]">
                <span class="figdesc">
                    <xsl:for-each select="*[contains(@class,' topic/desc ')]">
                        <xsl:call-template name="commonattributes"/>
                    </xsl:for-each>
                    <xsl:apply-templates select="*[contains(@class,' topic/desc ')]" mode="figdesc"/>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/section ')]" name="topic.section">
        <div>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="gen-toc-id"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="." mode="dita2html:section-heading"/>
            <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
        </div>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/table ')]" name="topic.table">
        <xsl:value-of select="$newline"/>
        <!-- special case for IE & NS for frame & no rules - needs to be a double table -->
        <xsl:variable name="colsep">
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/tgroup ')]/@colsep">
                    <xsl:value-of select="*[contains(@class, ' topic/tgroup ')]/@colsep"/>
                </xsl:when>
                <xsl:when test="@colsep">
                    <xsl:value-of select="@colsep"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rowsep">
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/tgroup ')]/@rowsep">
                    <xsl:value-of select="*[contains(@class, ' topic/tgroup ')]/@rowsep"/>
                </xsl:when>
                <xsl:when test="@rowsep">
                    <xsl:value-of select="@rowsep"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@frame = 'all' and $colsep = '0' and $rowsep = '0'">
                <xsl:value-of select="$newline"/>
                <xsl:call-template name="dotable"/>
            </xsl:when>
            <xsl:when test="@frame = 'top' and $colsep = '0' and $rowsep = '0'">
                <hr/>
                <xsl:value-of select="$newline"/>
                <xsl:call-template name="dotable"/>
            </xsl:when>
            <xsl:when test="@frame = 'bot' and $colsep = '0' and $rowsep = '0'">
                <xsl:call-template name="dotable"/>
                <hr/>
                <xsl:value-of select="$newline"/>
            </xsl:when>
            <xsl:when test="@frame = 'topbot' and $colsep = '0' and $rowsep = '0'">
                <hr/>
                <xsl:value-of select="$newline"/>
                <xsl:call-template name="dotable"/>
                <hr/>
                <xsl:value-of select="$newline"/>
            </xsl:when>
            <xsl:when test="not(@frame) and $colsep = '0' and $rowsep = '0'">
                <xsl:value-of select="$newline"/>
                <xsl:call-template name="dotable"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="tablenoborder">
                    <xsl:call-template name="dotable"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>

        <xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ')] or descendant::*[contains(@class, ' topic/xref ')][@type = 'fn'])">
            <xsl:variable name="table">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:call-template name="gen-table-endnotes">
                <xsl:with-param name="table" select="$table"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="place-tbl-lbl">
        <xsl:param name="stringName"/>
        <!-- Number of table/title's before this one -->
        <xsl:variable name="tbl-count-actual" select="count(preceding::*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')])+1"/>

        <!-- normally: "Table 1. " -->
        <xsl:variable name="ancestorlang">
            <!--<xsl:call-template name="getLowerCaseLang"/>-->
        </xsl:variable>

        <xsl:choose>
            <!-- title -or- title & desc -->
            <xsl:when test="*[contains(@class,' topic/title ')]">
                <caption>
                    <span class="tablecap">
                        <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="tabletitle"/>
                    </span>
                    <xsl:if test="*[contains(@class,' topic/desc ')]">
                        <xsl:text>. </xsl:text>
                        <span class="tabledesc">
                            <xsl:for-each select="*[contains(@class,' topic/desc ')]">
                                <xsl:call-template name="commonattributes"/>
                            </xsl:for-each>
                            <xsl:apply-templates select="*[contains(@class,' topic/desc ')]" mode="tabledesc"/>
                        </span>
                    </xsl:if>
                </caption>
            </xsl:when>
            <!-- desc -->
            <xsl:when test="*[contains(@class,' topic/desc ')]">
                <span class="tabledesc">
                    <xsl:for-each select="*[contains(@class,' topic/desc ')]">
                        <xsl:call-template name="commonattributes"/>
                    </xsl:for-each>
                    <xsl:apply-templates select="*[contains(@class,' topic/desc ')]" mode="tabledesc"/>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/section ')]/*[contains(@class,' topic/title ')] |
    *[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')] |
    *[contains(@class,' topic/example ')]/*[contains(@class,' topic/title ')]">
        <xsl:param name="headLevel">
            <xsl:variable name="headCount" select="count(ancestor::*[contains(@class, ' topic/topic ')])+1"/>
            <xsl:choose>
                <xsl:when test="$headCount > 6">h6</xsl:when>
                <xsl:otherwise>h<xsl:value-of select="$headCount"/></xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:element name="{$headLevel}">
            <xsl:attribute name="class">sectiontitle</xsl:attribute>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class" select="'sectiontitle'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="*" mode="dita2html:section-heading">
        <xsl:param name="defaulttitle"/> <!-- get param by reference -->
        <xsl:variable name="heading">
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/title ')]">
                    <xsl:apply-templates select="*[contains(@class, ' topic/title ')][1]"/>
                    <xsl:if test="*[contains(@class, ' topic/title ')][2]">
                        <xsl:apply-templates select="." mode="ditamsg:section-with-multiple-titles"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="@spectitle">
                    <xsl:value-of select="@spectitle"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="headCount" select="count(ancestor::*[contains(@class, ' topic/topic ')]) + 1"/>
        <xsl:variable name="headLevel">
            <xsl:choose>
                <xsl:when test="$headCount > 6">h6</xsl:when>
                <xsl:otherwise>h<xsl:value-of select="$headCount"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!-- based on graceful defaults, build an appropriate section-level heading -->
        <xsl:choose>
            <xsl:when test="normalize-space($heading)">
                <xsl:apply-templates select="*[contains(@class, ' topic/title ')][1]">
                    <xsl:with-param name="headLevel" select="$headLevel"/>
                </xsl:apply-templates>
                <xsl:if test="@spectitle and not(*[contains(@class, ' topic/title ')])">
                    <xsl:element name="{$headLevel}">
                        <xsl:attribute name="class">sectiontitle</xsl:attribute>
                        <xsl:value-of select="@spectitle"/>
                    </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$defaulttitle">
                <xsl:element name="{$headLevel}">
                    <xsl:attribute name="class">sectiontitle</xsl:attribute>
                    <xsl:value-of select="$defaulttitle"/>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/example ')]" name="topic.example">
        <div class="example">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="gen-toc-id"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <xsl:apply-templates select="." mode="dita2html:section-heading"/>
            <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </div>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <!--<xsl:template match="*[contains(@class, ' topic/shortdesc ')]"/>-->

    <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
        <xsl:param name="headinglevel" as="xs:integer">
            <xsl:choose>
                <xsl:when test="count(ancestor::*[contains(@class, ' topic/topic ')]) > 6">6</xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="count(ancestor::*[contains(@class, ' topic/topic ')])"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:value-of select="$newline"/>
        <!-- Comtech 07/18/2013 wrap h1 and shortdesc in <div> tag -->
        <header>
            <xsl:element name="h{$headinglevel}">
                <xsl:attribute name="class">topictitle<xsl:value-of select="$headinglevel"/>
                </xsl:attribute>
                <xsl:call-template name="commonattributes">
                    <xsl:with-param name="default-output-class">topictitle<xsl:value-of select="$headinglevel"/></xsl:with-param>
                </xsl:call-template>
                <!--<xsl:attribute name="id"><xsl:apply-templates select="." mode="return-aria-label-id"/></xsl:attribute>-->
                <xsl:apply-templates/>
            </xsl:element>

            <xsl:apply-templates select="//*[contains(@class,' topic/abstract ')]" mode="outofline"/>

            <xsl:apply-templates select="following-sibling::*[contains(@class,' topic/shortdesc ')]" mode="outofline"/>

            <!-- Insert pre-req links - after shortdesc - unless there is a prereq section about -->
            <!--<xsl:apply-templates select="//*[contains(@class,' topic/related-links ')]" mode="prereqs"/>-->
        </header>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' sw-d/systemoutput ')]" name="topic.sw-d.systemoutput">
        <samp class="sysout systemoutput">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </samp>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/codeph ')]" name="topic.pr-d.codeph">
        <samp class="codeph">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </samp>
    </xsl:template>

</xsl:stylesheet>