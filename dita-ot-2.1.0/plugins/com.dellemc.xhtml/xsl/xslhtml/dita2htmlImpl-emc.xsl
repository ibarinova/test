<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:exsl="http://exslt.org/common" xmlns:java="org.dita.dost.util.ImgUtils"
                xmlns:url="org.dita.dost.util.URLUtils"
                exclude-result-prefixes="dita-ot dita2html ditamsg exsl java url xs">

    <!-- EMC	15-Oct-2014		 Add "Draft - EMC Confidential" on the header of each file -->
    <xsl:template match="/|node()|@*" mode="gen-user-header">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- it will be placed in the running heading section of the XHTML. -->
        <div class="draft">
            <xsl:if test="$DRAFT='yes'">
                <xsl:message>$DRAFT='yes'</xsl:message>
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Draft'"/>
                </xsl:call-template>
            </xsl:if>
        </div>
    </xsl:template>

    <!-- EMC	15-Oct-2014		Generate links to twisty CSS files -->
    <xsl:template match="/|node()|@*" mode="gen-user-scripts">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- It will be placed before the ending HEAD tag -->
        <!-- see (or enable) the named template "script-sample" for an example -->
        <!-- Comtech Services 07/26/2013 added twisty javascript reference code -->
        <xsl:element name="script">
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:attribute name="src">
                <xsl:value-of select="'twisty.js'"/>
            </xsl:attribute>
        </xsl:element>
        <xsl:value-of select="$newline"/>
        <xsl:element name="link">
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="'twisty.css'"/>
            </xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
            <xsl:attribute name="media">screen</xsl:attribute>
        </xsl:element>
        <xsl:value-of select="$newline"/>
        <xsl:element name="link">
            <xsl:attribute name="rel">stylesheet</xsl:attribute>
            <xsl:attribute name="href">
                <xsl:value-of select="'twisty-print.css'"/>
            </xsl:attribute>
            <xsl:attribute name="type">text/css</xsl:attribute>
            <xsl:attribute name="media">print</xsl:attribute>
        </xsl:element>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/keyword ')]" name="topic.keyword">
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="@keyref and @href">
                <xsl:apply-templates select="." mode="turning-to-link">
                    <xsl:with-param name="type" select="'keyword'"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <span class="keyword">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="setidaname"/>
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--  EMC 	15-Oct-2014		Copied from webhelp/a_pluginOverrides.xsl, changed the HTML5 <header> tag to <div> -->
    <!-- NESTED TOPIC TITLES (sensitive to nesting depth, but are still processed for contained markup) -->
    <!-- 1st level - topic/title -->
    <!-- Condensed topic title into single template without priorities; use $headinglevel to set heading.
       If desired, somebody could pass in the value to manually set the heading level -->
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
        <div class="header">
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

            <!-- get the shortdesc para
            <xsl:apply-templates select="following-sibling::*[contains(@class,' topic/shortdesc ')]"
              mode="outofline"/-->

            <!-- Insert pre-req links - after shortdesc - unless there is a prereq section about -->
            <xsl:apply-templates select="//*[contains(@class,' topic/related-links ')]" mode="prereqs"/>
        </div>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <!-- EMC 	15-Oct-2014		Customized from webhelp, changed the path of GIF files -->
    <!-- paragraphs -->
    <xsl:template match="*[contains(@class,' topic/p ')]" name="topic.p">
        <!-- To ensure XHTML validity, need to determine whether the DITA kids are block elements.
          If so, use div_class="p" instead of p -->
        <!-- Comtech 07/18/2013 set first <p> into concept topic to span page using <aside> -->
        <xsl:choose>
            <xsl:when test="preceding-sibling::* and parent::*[contains(@class, ' topic/body ')]">
                <xsl:choose>
                    <!-- Comtech 07/18/2013 add twisty catch and wrap content in <p>-->
                    <xsl:when test="contains(@outputclass,'show_hide_expanded')">
                        <span>
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="setid"/>
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:text>javascript:toggleTwisty('</xsl:text>
                                        <xsl:value-of select="generate-id()"/>
                                        <xsl:text>');</xsl:text>
                                    </xsl:attribute>
                                    <xsl:element name="img">
                                        <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                        <xsl:attribute name="src">
                                            <xsl:value-of select="'expanded.gif'"
                                            />
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:element>
                                <xsl:element name="div">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:element name="div">
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:element>
                            </p>
                        </span>
                    </xsl:when>
                    <xsl:when test="contains(@outputclass,'show_hide')">
                        <span>
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="setid"/>
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:text>javascript:toggleTwisty('</xsl:text>
                                        <xsl:value-of select="generate-id()"/>
                                        <xsl:text>');</xsl:text>
                                    </xsl:attribute>
                                    <xsl:element name="img">
                                        <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                        <xsl:attribute name="src">
                                            <xsl:value-of select="'collapse.gif'"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:element>
                                <xsl:element name="div">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="style">
                                        <xsl:value-of select="'display: none;'"/>
                                    </xsl:attribute>
                                    <xsl:element name="div">
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:element>
                            </p>
                        </span>
                    </xsl:when>
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
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="contains(@outputclass,'show_hide_expanded')">
                        <span>
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="setid"/>
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:text>javascript:toggleTwisty('</xsl:text>
                                        <xsl:value-of select="generate-id()"/>
                                        <xsl:text>');</xsl:text>
                                    </xsl:attribute>
                                    <xsl:element name="img">
                                        <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                        <xsl:attribute name="src">
                                            <xsl:value-of select="'expanded.gif'"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:element>
                                <xsl:element name="div">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:element name="div">
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:element>
                            </p>
                        </span>
                    </xsl:when>
                    <xsl:when test="contains(@outputclass,'show_hide')">
                        <span>
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="setid"/>
                                <xsl:element name="a">
                                    <xsl:attribute name="href">
                                        <xsl:text>javascript:toggleTwisty('</xsl:text>
                                        <xsl:value-of select="generate-id()"/>
                                        <xsl:text>');</xsl:text>
                                    </xsl:attribute>
                                    <xsl:element name="img">
                                        <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                        <xsl:attribute name="src">
                                            <xsl:value-of select="'collapse.gif'"/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:element>
                                <xsl:element name="div">
                                    <xsl:attribute name="id">
                                        <xsl:value-of select="generate-id()"/>
                                    </xsl:attribute>
                                    <xsl:attribute name="style">
                                        <xsl:value-of select="'display: none;'"/>
                                    </xsl:attribute>
                                    <xsl:element name="div">
                                        <xsl:apply-templates/>
                                    </xsl:element>
                                </xsl:element>
                            </p>
                        </span>
                    </xsl:when>
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
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <!-- EMC 	15-Oct-2014		Customized from webhelp, changed the path of GIF files -->
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
        <xsl:choose>
            <xsl:when test="contains(@outputclass,'show_hide_expanded') and @id">
                <span>
                    <p>
                        <xsl:call-template name="commonattributes"/>
                        <xsl:call-template name="setid"/>
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'expanded.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <xsl:variable name="olcount"
                                          select="count(ancestor-or-self::*[contains(@class,' topic/ol ')])"/>
                            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]"
                                                 mode="out-of-line"/>
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
                        </xsl:element>
                    </p>
                </span>
            </xsl:when>
            <xsl:when test="contains(@outputclass,'show_hide') and @id">
                <span>
                    <p>
                        <xsl:call-template name="commonattributes"/>
                        <xsl:call-template name="setid"/>
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'collapse.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'display: none;'"/>
                            </xsl:attribute>
                            <xsl:variable name="olcount"
                                          select="count(ancestor-or-self::*[contains(@class,' topic/ol ')])"/>
                            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]"
                                                 mode="out-of-line"/>
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
                            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]"
                                                 mode="out-of-line"/>
                            <xsl:value-of select="$newline"/>
                        </xsl:element>
                    </p>
                </span>
            </xsl:when>
            <xsl:otherwise>
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
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- EMC 		15-Oct-2014		Customized from webhelp, changed the path of GIF files. Also the bulleting style for unordered list	-->
    <xsl:template match="*[contains(@class,' topic/ul ')]" name="topic.ul">
        <xsl:choose>
            <xsl:when test="contains(@outputclass,'show_hide_expanded') and @id">
                <span>
                    <p>
                        <xsl:call-template name="commonattributes"/>
                        <xsl:call-template name="setid"/>
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'expanded.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <!-- This template is deprecated in DITA-OT 1.7. Processing will moved into the main element rule. -->
                            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
                            <xsl:call-template name="setaname"/>
                            <ul>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:apply-templates select="@compact"/>
                                <xsl:call-template name="setid"/>
                                <xsl:apply-templates/>
                            </ul>
                            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
                            <xsl:value-of select="$newline"/>
                        </xsl:element>
                    </p>
                </span>
            </xsl:when>
            <xsl:when test="contains(@outputclass,'show_hide') and @id">
                <span>
                    <p>
                        <xsl:call-template name="commonattributes"/>
                        <xsl:call-template name="setid"/>
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'collapse.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'display: none;'"/>
                            </xsl:attribute>
                            <!-- This template is deprecated in DITA-OT 1.7. Processing will moved into the main element rule. -->
                            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
                            <xsl:call-template name="setaname"/>
                            <ul>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:apply-templates select="@compact"/>
                                <xsl:call-template name="setid"/>
                                <xsl:apply-templates/>
                            </ul>
                            <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
                            <xsl:value-of select="$newline"/>
                        </xsl:element>
                    </p>
                </span>

            </xsl:when>
            <xsl:otherwise>
                <!-- IB6 4-Sep-2014 TKT-166: HTML5 Fix bullet symbol hierarchy within tables inside a substep. -->
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
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- EMC 		15-Oct-2014		Customized from webhelp, changed the path of GIF files -->
    <!-- =========== FIGURE =========== -->
    <xsl:template match="*[contains(@class,' topic/fig ')]" name="topic.fig">

        <!-- OXYGEN PATCH START  EXM-18109 - moved image caption below. -->
        <!--<xsl:apply-templates
            select="*[not(contains(@class,' topic/title '))][not(contains(@class,' topic/desc '))] |text()|comment()|processing-instruction()"/>-->
        <!--<xsl:call-template name="place-fig-lbl"/>-->
        <!-- OXYGEN PATCH END  EXM-18109 -->
        <!-- EMC	28-Oct-2014 	Added empty <div> for image to begin in newline -->
        <div></div>
        <xsl:choose>
            <xsl:when test="contains(@outputclass,'show_hide_expanded') and @id">
                <span>
                    <p>
                        <xsl:attribute name="id">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                        <!--<div class="p collapsible">-->
                        <xsl:call-template name="commonattributes"/>
                        <!--<xsl:call-template name="setid"/>-->
                        <xsl:call-template name="place-fig-lbl"/>
                        <xsl:text>  </xsl:text>
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="generate-id(@id)"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'expanded.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="generate-id(@id)"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="." mode="fig-fmt"/>
                        </xsl:element>
                    </p>
                </span>
            </xsl:when>
            <xsl:when test="contains(@outputclass,'show_hide') and @id">
                <span>
                    <p>
                        <xsl:attribute name="id">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                        <xsl:call-template name="commonattributes"/>
                        <!--<xsl:call-template name="setid"/>-->
                        <xsl:call-template name="place-fig-lbl"/>
                        <xsl:text>  </xsl:text>

                        <xsl:element name="a">
                            <xsl:attribute name="style">padding-left:6pt;</xsl:attribute>
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="generate-id(@id)"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'collapse.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="generate-id(@id)"/>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'display: none;'"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="." mode="fig-fmt"/>
                        </xsl:element>
                        <!--</div>-->
                    </p>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="fig-fmt"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/fig ')]" mode="fig-fmt">
        <!-- This template is deprecated in DITA-OT 1.7. Processing will moved into the main element rule. -->
        <xsl:variable name="default-fig-class">
            <xsl:apply-templates select="." mode="dita2html:get-default-fig-class"/>
        </xsl:variable>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <!-- Comtech 07/18/2013 change <div> to <figure> -->
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
            <!-- OXYGEN PATCH START  EXM-18109 - moved image caption below. -->
            <xsl:apply-templates select="*[not(contains(@class,' topic/title '))][not(contains(@class,' topic/desc '))] |text()|comment()|processing-instruction()"/>
            <xsl:if test="not(ancestor-or-self::*[contains(@outputclass,'show_hide')])">
                <xsl:call-template name="place-fig-lbl"/>
            </xsl:if>
            <!-- OXYGEN PATCH END  EXM-18109 -->
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

                <!-- OXYGEN PATCH START  EXM-18109 -->
                <!--<span class="figcap">-->
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::*[contains(@outputclass,'show_hide')]">
                        <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="figtitle"/>
                    </xsl:when>
                    <xsl:otherwise>
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
                    </xsl:otherwise>
                </xsl:choose>

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

    <!-- EMC 		15-Oct-2014		Customized from webhelp, changed the path of GIF files. Commented the HTML5 <aside> tag  -->
    <xsl:template match="*[contains(@class,' topic/fig ')]/*[contains(@class,' topic/desc ')]"
                  mode="figdesc">
        <!-- Comtech 07/18/2013 added <figurecaption> -->
        <figurecaption>
            <xsl:apply-templates/>
        </figurecaption>
    </xsl:template>

    <!-- EMC 		15-Oct-2014		Customized from webhelp, changed the path of GIF files -->
    <xsl:template match="*[contains(@class,' topic/section ')]" name="topic.section">
        <xsl:choose>
            <xsl:when test="contains(@outputclass,'show_hide_expanded') and @id">
                <span>
                    <div>
                        <xsl:call-template name="commonattributes"/>
                        <xsl:attribute name="id">
                            <xsl:value-of select="@id"/>
                        </xsl:attribute>
                        <xsl:element name="h4">
                            <xsl:attribute name="class">sectiontitle</xsl:attribute>
                            <xsl:call-template name="commonattributes">
                                <xsl:with-param name="default-output-class" select="'sectiontitle'"/>
                            </xsl:call-template>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:text>javascript:toggleTwisty('</xsl:text>
                                    <xsl:value-of select="@id"/>
                                    <xsl:text>');</xsl:text>
                                </xsl:attribute>
                                <xsl:element name="img">
                                    <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                    <xsl:attribute name="src">
                                        <xsl:value-of select="'expanded.gif'"
                                        />
                                    </xsl:attribute>
                                </xsl:element>
                            </xsl:element>
                            <xsl:choose>
                                <xsl:when test="*[contains(@class,' topic/title ')]">
                                    <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                                        <xsl:with-param name="idValue">
                                            <xsl:value-of select="@id"/>
                                        </xsl:with-param>
                                    </xsl:apply-templates>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:apply-templates select="." mode="dita2html:section-heading"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <!-- Comtech 07/18/2013 change <div @class='section'> to <section> -->
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="gen-toc-id"/>
                                <xsl:call-template name="setidaname"/>

                                <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
                                <!--<xsl:apply-templates select="." mode="section-fmt"/>-->
                            </p>
                            <xsl:value-of select="$newline"/>
                        </xsl:element>
                    </div>
                </span>
            </xsl:when>
            <xsl:when test="contains(@outputclass,'show_hide')">
                <span>
                    <!-- Changed <p> to <div> -->
                    <div>
                        <!--<div class="p collapsible">-->
                        <xsl:call-template name="commonattributes"/>
                        <!--          <xsl:element name="h4">
                        <xsl:attribute name="class">sectiontitle</xsl:attribute>
                        <xsl:call-template name="commonattributes">
                          <xsl:with-param name="default-output-class" select="'sectiontitle'"/>
                        </xsl:call-template>-->
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'collapse.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:choose>
                            <xsl:when test="*[contains(@class,' topic/title ')]">
                                <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                                    <xsl:with-param name="idValue">
                                        <xsl:value-of select="@id"/>
                                    </xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="dita2html:section-heading"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <!--</xsl:element>-->
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'display: none;'"/>
                            </xsl:attribute>
                            <!-- Comtech 07/18/2013 change <div @class='section'> to <section> -->
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="gen-toc-id"/>
                                <xsl:call-template name="setidaname"/>
                                <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
                                <!--<xsl:apply-templates select=".[not(contains(@class,' topic/title '))]" mode="section-fmt"/>-->
                            </p>
                            <xsl:value-of select="$newline"/>
                        </xsl:element>
                    </div>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <!-- Comtech 07/18/2013 change <div @class='section'> to <section> -->
                <!-- Changed <p> to <div> -->
                <div>
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="gen-toc-id"/>
                    <xsl:call-template name="setidaname"/>
                    <xsl:choose>
                        <xsl:when test="*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                                <xsl:with-param name="idValue">
                                    <xsl:value-of select="@id"/>
                                </xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="." mode="dita2html:section-heading"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
                    <!--<xsl:apply-templates select="." mode="section-fmt"/>-->
                </div>
                <xsl:value-of select="$newline"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/section ')]/*[contains(@class, ' topic/title ')] |
                        *[contains(@class, ' topic/example ')]/*[contains(@class, ' topic/title ')]" name="topic.section_title">
        <xsl:param name="headLevel">
            <xsl:variable name="headCount" select="count(ancestor::*[contains(@class, ' topic/topic ')])+1"/>
            <xsl:choose>
                <xsl:when test="$headCount > 6">h6</xsl:when>
                <xsl:otherwise>h<xsl:value-of select="$headCount"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:if test="not(ancestor::*[contains(@class, ' task/task ')])
                                or (ancestor::*[contains(@class, ' task/task ')] and $insert-task-labels)">
            <xsl:element name="{$headLevel}">
                <xsl:attribute name="class">sectiontitle</xsl:attribute>
                <xsl:call-template name="commonattributes">
                    <xsl:with-param name="default-output-class" select="'sectiontitle'"/>
                </xsl:call-template>
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <!-- =========== TABLE =========== -->
    <xsl:template match="*[contains(@class,' topic/table ')]" name="topic.table">
        <xsl:choose>
            <xsl:when test="contains(@outputclass,'show_hide_expanded')">
                <span>
                    <p>
                        <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                            <xsl:with-param name="idValue">
                                <xsl:value-of select="generate-id(.)"/>
                            </xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="generate-id(.)"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="." mode="table-fmt"/>
                        </xsl:element>
                    </p>
                </span>
            </xsl:when>
            <xsl:when test="contains(@outputclass,'show_hide')">
                <span>
                    <p>
                        <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                            <xsl:with-param name="idValue">
                                <xsl:value-of select="generate-id(.)"/>
                            </xsl:with-param>
                        </xsl:apply-templates>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="generate-id(.)"/>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'display: none;'"/>
                            </xsl:attribute>
                            <xsl:apply-templates select="." mode="table-fmt"/>
                        </xsl:element>
                    </p>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="table-fmt"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Comtech Services 09/09/2013 Override where table <fn> are displayed, moved from bottom of page to within table -->
    <xsl:template match="*[contains(@class, ' topic/table ')]" mode="table-fmt">
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

    <xsl:template name="gen-table-endnotes">
        <xsl:param name="table"/>
        <div class="table-endnotes">
            <xsl:apply-templates select="$table/descendant::*[contains(@class, ' topic/fn ')
                                                        or (contains(@class, ' topic/xref ') and @type = 'fn')]
                                                    [not((ancestor-or-self::*[contains(@class, ' topic/draft-comment ')]
                                                        or ancestor::*[contains(@class, ' topic/required-cleanup ')])
                                                    and $DRAFT = 'no')]" mode="genTableEndnote"/>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fn ')]" mode="genTableEndnote">
        <div class="fn">
            <xsl:variable name="fnid">
                <xsl:number format="a" value="count(preceding::*[contains(@class, ' topic/fn ')]) + 1"/>
            </xsl:variable>
            <xsl:variable name="callout" select="@callout"/>
            <xsl:variable name="convergedcallout" select="if (string-length($callout) > 0) then $callout else $fnid"/>
            <xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>

            <xsl:call-template name="commonattributes"/>
            <a href="#fnsrc_{$fnid}_{$ancestorId}">
                <span id="fntarg_{$fnid}_{$ancestorId}">
                    <xsl:value-of select="concat($convergedcallout, '. ')"/>
                </span>
            </a>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ')][@type = 'fn']"
                  mode="genTableEndnote"/>

    <xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')]
                            [ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]]" mode="table.fn">
        <xsl:variable name="ref-id" select="substring-after(@href, '/')"/>
        <xsl:variable name="href" select="@href"/>
        <xsl:variable name="fn-number">
            <xsl:choose>
                <xsl:when test="contains(@class, ' topic/xref ')">
                    <xsl:value-of select="count(/descendant::*[@id = $ref-id][1]/preceding::*[contains(@class, ' topic/fn ')]) + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count(preceding::*[contains(@class, ' topic/fn ')]) + 1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="fnid">
            <xsl:number format="a" value="$fn-number"/>
        </xsl:variable>
        <xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
        <xsl:variable name="callout" select="@callout"/>
        <xsl:variable name="convergedcallout" select="if (string-length($callout)> 0) then $callout else $fnid"/>
        <a href="#fntarg_{$fnid}_{$ancestorId}">
            <xsl:choose>
                <xsl:when test="(contains(@class, ' topic/xref ')and @type = 'fn') and
                                preceding::*[contains(@class, ' topic/xref ')and @type = 'fn'][@href = $href]"/>
                <xsl:when test="normalize-space(@id)"/>
                <xsl:otherwise>
                    <xsl:attribute name="id" select="concat('fnsrc_', $fnid, '_', $ancestorId)"/>
                </xsl:otherwise>
            </xsl:choose>
            <sup>
                <xsl:value-of select="$convergedcallout"/>
            </sup>
        </a>
    </xsl:template>

    <xsl:template name="dotable">
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:call-template name="setaname"/>
        <table cellpadding="4" cellspacing="0" style="margin-top:12pt;">
            <xsl:variable name="colsep">
                <xsl:choose>
                    <xsl:when test="*[contains(@class,' topic/tgroup ')]/@colsep">
                        <xsl:value-of select="*[contains(@class,' topic/tgroup ')]/@colsep"/>
                    </xsl:when>
                    <xsl:when test="@colsep">
                        <xsl:value-of select="@colsep"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="rowsep">
                <xsl:choose>
                    <xsl:when test="*[contains(@class,' topic/tgroup ')]/@rowsep">
                        <xsl:value-of select="*[contains(@class,' topic/tgroup ')]/@rowsep"/>
                    </xsl:when>
                    <xsl:when test="@rowsep">
                        <xsl:value-of select="@rowsep"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="setid"/>
            <xsl:call-template name="commonattributes"/>
            <!--xsl:apply-templates select="." mode="generate-table-summary-attribute"/-->
            <xsl:call-template name="setscale"/>
            <!-- When a table's width is set to page or column, force it's width to 100%. If it's in a list, use 90%.
             Otherwise, the table flows to the content -->
            <xsl:choose>
                <xsl:when test="(@expanse='page' or @pgwide='1')and (ancestor::*[contains(@class,' topic/li ')] or ancestor::*[contains(@class,' topic/dd ')] )">
                    <xsl:attribute name="width">90%</xsl:attribute>
                </xsl:when>
                <xsl:when test="(@expanse='column' or @pgwide='0') and (ancestor::*[contains(@class,' topic/li ')] or ancestor::*[contains(@class,' topic/dd ')] )">
                    <xsl:attribute name="width">90%</xsl:attribute>
                </xsl:when>
                <xsl:when test="(@expanse='page' or @pgwide='1')">
                    <xsl:attribute name="width">100%</xsl:attribute>
                </xsl:when>
                <xsl:when test="(@expanse='column' or @pgwide='0')">
                    <xsl:attribute name="width">100%</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="@frame='all' and $colsep='0' and $rowsep='0'">
                    <!-- EMC IB6  21-Oct-2014  TKT-167: outputs incorrectly display @colsep and @rowsep -->
                    <!--xsl:attribute name="border">0</xsl:attribute-->
                    <xsl:attribute name="frame">border</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:when>
                <xsl:when test="not(@frame) and $colsep='0' and $rowsep='0'">
                    <!-- EMC IB6  20-Oct-2014  TKT-167: outputs incorrectly display @colsep and @rowsep -->
                    <!--xsl:attribute name="border">0</xsl:attribute-->
                    <xsl:attribute name="frame">border</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:when>
                <xsl:when test="@frame='sides'">
                    <xsl:attribute name="frame">vsides</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:when>
                <xsl:when test="@frame='top'">
                    <xsl:attribute name="frame">above</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:when>
                <xsl:when test="@frame='bottom'">
                    <xsl:attribute name="frame">below</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:when>
                <xsl:when test="@frame='topbot'">
                    <xsl:attribute name="frame">hsides</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:when>
                <xsl:when test="@frame='none'">
                    <xsl:attribute name="frame">void</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="frame">border</xsl:attribute>
                    <xsl:attribute name="border">1</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="@frame='all' and $colsep='0' and $rowsep='0'">
                    <!-- EMC IB6  21-Oct-2014  TKT-167: outputs incorrectly display @colsep and @rowsep -->
                    <!--xsl:attribute name="border">0</xsl:attribute-->
                    <xsl:attribute name="rules">rows</xsl:attribute>
                </xsl:when>
                <xsl:when test="not(@frame) and $colsep='0' and $rowsep='0'">
                    <!-- EMC IB6  20-Oct-2014  TKT-167: HTML5 outputs incorrectly display @colsep and @rowsep -->
                    <!--xsl:attribute name="border">0</xsl:attribute-->
                    <xsl:attribute name="rules">rows</xsl:attribute>
                </xsl:when>
                <xsl:when test="$colsep='0' and $rowsep='0'">
                    <xsl:attribute name="rules">none</xsl:attribute>
                    <xsl:attribute name="border">0</xsl:attribute>
                </xsl:when>
                <xsl:when test="$colsep='0'">
                    <xsl:attribute name="rules">rows</xsl:attribute>
                </xsl:when>
                <xsl:when test="$rowsep='0'">
                    <xsl:attribute name="rules">cols</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="rules">all</xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="place-tbl-lbl"/>
            <!-- title and desc are processed elsewhere -->
            <xsl:apply-templates select="*[contains(@class,' topic/tgroup ')]"/>
        </table>
        <xsl:value-of select="$newline"/>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
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
                <xsl:if test="not(ancestor-or-self::*[contains(@outputclass,'show_hide')])">
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
                </xsl:if>
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
    *[contains(@class,' topic/example ')]/*[contains(@class,' topic/title ')]"
                  mode="section-fmt-title">
        <xsl:param name="idValue"/>

        <xsl:choose>
            <xsl:when test="ancestor-or-self::*[contains(@outputclass,'show_hide_expanded')] and ancestor-or-self::*[@id]">
                <xsl:element name="h4">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">sectiontitle</xsl:attribute>
                    <xsl:call-template name="commonattributes">
                        <xsl:with-param name="default-output-class" select="'sectiontitle'"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                    <xsl:element name="a">
                        <xsl:attribute name="style">padding-left:6pt;</xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:text>javascript:toggleTwisty('</xsl:text>
                            <xsl:value-of select="$idValue"/>
                            <xsl:text>');</xsl:text>
                        </xsl:attribute>
                        <xsl:element name="img">
                            <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                            <xsl:attribute name="src">
                                <xsl:value-of select="'expanded.gif'"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="ancestor-or-self::*[contains(@outputclass,'show_hide')] and ancestor-or-self::*[@id]">
                <xsl:element name="h4">
                    <xsl:attribute name="id">
                        <xsl:value-of select="@id"/>
                    </xsl:attribute>
                    <xsl:attribute name="class">sectiontitle</xsl:attribute>
                    <xsl:call-template name="commonattributes">
                        <xsl:with-param name="default-output-class" select="'sectiontitle'"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                    <xsl:element name="a">
                        <xsl:attribute name="style">padding-left:6pt;</xsl:attribute>
                        <xsl:attribute name="href">
                            <xsl:text>javascript:toggleTwisty('</xsl:text>
                            <xsl:value-of select="$idValue"/>
                            <xsl:text>');</xsl:text>
                        </xsl:attribute>
                        <xsl:element name="img">
                            <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                            <xsl:attribute name="src">
                                <xsl:value-of select="'collapse.gif'"/>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="parent::*" mode="dita2html:section-heading"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/example ')]" name="topic.example">
        <xsl:choose>
            <xsl:when test="contains(@outputclass,'show_hide_expanded') and @id">
                <span>
                    <div>
                        <xsl:call-template name="commonattributes"/>
                        <xsl:call-template name="setid"/>
                        <xsl:choose>
                            <xsl:when test="*[contains(@class,' topic/title ')]">
                                <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                                    <xsl:with-param name="idValue">
                                        <xsl:value-of select="@id"/>
                                    </xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="dita2html:section-heading"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <!-- Comtech 07/18/2013 change <div @class='section'> to <section> -->
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="gen-toc-id"/>
                                <xsl:call-template name="setidaname"/>
                                <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
                            </p>
                            <xsl:value-of select="$newline"/>
                        </xsl:element>
                    </div>
                </span>
            </xsl:when>
            <xsl:when test="contains(@outputclass,'show_hide') and @id">
                <span>
                    <div>
                        <xsl:call-template name="commonattributes"/>
                        <xsl:call-template name="setid"/>
                        <xsl:element name="a">
                            <xsl:attribute name="href">
                                <xsl:text>javascript:toggleTwisty('</xsl:text>
                                <xsl:value-of select="@id"/>
                                <xsl:text>');</xsl:text>
                            </xsl:attribute>
                            <xsl:element name="img">
                                <xsl:attribute name="class">show_hide_expanded</xsl:attribute>
                                <xsl:attribute name="src">
                                    <xsl:value-of select="'collapse.gif'"/>
                                </xsl:attribute>
                            </xsl:element>
                        </xsl:element>
                        <xsl:choose>
                            <xsl:when test="*[contains(@class,' topic/title ')]">
                                <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                                    <xsl:with-param name="idValue">
                                        <xsl:value-of select="@id"/>
                                    </xsl:with-param>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="." mode="dita2html:section-heading"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:element name="div">
                            <xsl:attribute name="id">
                                <xsl:value-of select="@id"/>
                            </xsl:attribute>
                            <xsl:attribute name="style">
                                <xsl:value-of select="'display: none;'"/>
                            </xsl:attribute>
                            <!-- Comtech 07/18/2013 change <div @class='section'> to <section> -->
                            <p>
                                <xsl:call-template name="commonattributes"/>
                                <xsl:call-template name="gen-toc-id"/>
                                <xsl:call-template name="setidaname"/>
                                <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
                            </p>
                            <xsl:value-of select="$newline"/>
                        </xsl:element>
                    </div>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <div class="example">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="gen-toc-id"/>
                    <xsl:call-template name="setidaname"/>
                    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
                    <xsl:choose>
                        <xsl:when test="*[contains(@class,' topic/title ')]">
                            <xsl:apply-templates select="*[contains(@class,' topic/title ')]" mode="section-fmt-title">
                                <xsl:with-param name="idValue">
                                    <xsl:value-of select="@id"/>
                                </xsl:with-param>
                            </xsl:apply-templates>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="." mode="dita2html:section-heading"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
                    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
                </div>
                <xsl:value-of select="$newline"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- EMC	15-Oct-2014		TKT 168: Remove shading and double spacing from the <lines> element -->
    <xsl:template match="*[contains(@class,' topic/lines ')]//text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ') and @type = 'fn')]" name="topic.fn">
        <xsl:param name="xref"/>
        <xsl:choose>
            <xsl:when test="ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]">
                <xsl:variable name="table">
                    <xsl:copy-of select="ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')][last()]"/>
                </xsl:variable>
                <xsl:call-template name="gen-table-footnote">
                    <xsl:with-param name="table" select="$table"/>
                    <xsl:with-param name="element" select="self::*"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="topic.fn"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="gen-table-footnote">
        <xsl:param name="table"/>
        <xsl:param name="element"/>
        <xsl:apply-templates select="$table/descendant::*[self::* = $element]
                                            [not( (ancestor-or-self::*[contains(@class, ' topic/draft-comment ')]
                                                    or ancestor::*[contains(@class, ' topic/required-cleanup ')])
                                                and $DRAFT = 'no')][1]" mode="table.fn"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')]
                            [not(ancestor::*[contains(@class, ' topic/table ')])]
                            [not(ancestor::*[contains(@class, ' topic/simpletable ')])]"
                  mode="topic.fn">
        <xsl:variable name="ref-id" select="substring-after(@href, '/')"/>
        <xsl:variable name="fn-number">
            <xsl:choose>
                <xsl:when test="contains(@class, ' topic/xref ')">
                    <xsl:value-of select="count(/descendant::*[@id = $ref-id][1]/
                                            preceding::*[contains(@class, ' topic/fn ')]
                                                        [not(ancestor::*[contains(@class, ' topic/table ')])]
                                                        [not(ancestor::*[contains(@class,' topic/simpletable ')])]) + 1"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="count(preceding::*[contains(@class, ' topic/fn ')]
                                                        [not(ancestor::*[contains(@class, ' topic/table ')])]
                                                        [not(ancestor::*[contains(@class,' topic/simpletable ')])]) + 1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="fnid">
            <xsl:number format="1" value="$fn-number"/>
        </xsl:variable>
        <xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
        <xsl:variable name="callout" select="@callout"/>
        <xsl:variable name="convergedcallout" select="if (string-length($callout)> 0) then $callout else $fnid"/>
        <xsl:variable name="href" select="@href"/>
        <a href="#fntarg_{$fnid}_{$ancestorId}">
            <xsl:choose>
                <xsl:when test="(contains(@class, ' topic/xref ')and @type = 'fn') and
                                preceding::*[contains(@class, ' topic/xref ')and @type = 'fn'][@href = $href]"/>
                <xsl:otherwise>
                    <xsl:attribute name="id" select="concat('fnsrc_', $fnid, '_', $ancestorId)"/>
                </xsl:otherwise>
            </xsl:choose>
            <sup>
                <xsl:value-of select="$convergedcallout"/>
            </sup>
        </a>
    </xsl:template>

    <xsl:template name="gen-endnotes">
        <xsl:if
                test="/descendant::*[contains(@class, ' topic/fn ')] or /descendant::*[contains(@class, ' topic/xref ')][@type = 'fn']">
            <div class="endnotes">
                <!-- Skip any footnotes that are in draft elements when draft = no -->
                <xsl:apply-templates
                        select="//*[contains(@class, ' topic/fn ')][not(ancestor::*[contains(@class, ' topic/table ')])]
                                    [not(ancestor::*[contains(@class,' topic/simpletable ')])]
                                    [not((ancestor-or-self::*[contains(@class, ' topic/draft-comment ')]
                                            or ancestor::*[contains(@class, ' topic/required-cleanup ')]) and $DRAFT = 'no')]"
                        mode="genEndnote"/>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fn ')]
                        [not(ancestor::*[contains(@class, ' topic/table ')])]
                        [not(ancestor::*[contains(@class,' topic/simpletable ')])]"
                  mode="genEndnote">
        <div class="fn">
            <xsl:variable name="fnid">
                <xsl:number format="1"
                            value="count(preceding::*[contains(@class, ' topic/fn ')]
                                    [not(ancestor::*[contains(@class,' topic/simpletable ')])]
                                    [not(ancestor::*[contains(@class, ' topic/table ')])]) + 1"/>
            </xsl:variable>
            <xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
            <xsl:variable name="callout" select="@callout"/>
            <xsl:variable name="convergedcallout" select="if (string-length($callout) > 0) then $callout else $fnid"/>

            <a href="#fnsrc_{$fnid}_{$ancestorId}">
                <span id="fntarg_{$fnid}_{$ancestorId}">
                    <xsl:value-of select="concat($convergedcallout, '. ')"/>
                </span>
            </a>

            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Comtech Services 09/09/2013 added to manage html5 video objects -->
    <!-- object, desc, & param -->
    <xsl:template match="*[contains(@class,' topic/object ')]" name="topic.object">
        <iframe>
            <xsl:copy-of
                    select="@id | @declare | @codebase | @type | @archive | @height | @usemap | @tabindex | @classid | @data | @codetype | @standby | @width | @name"/>
            <xsl:if test="@longdescref or *[contains(@class, ' topic/longdescref ')]">
                <xsl:apply-templates select="." mode="ditamsg:longdescref-on-object"/>
            </xsl:if>
            <xsl:apply-templates/>

            <xsl:attribute name="frameborder">0</xsl:attribute>
            <xsl:text> </xsl:text>
        </iframe>

    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/param ')]" name="topic.param">
        <xsl:choose>
            <xsl:when test="@name='movie'">
                <xsl:choose>
                    <xsl:when test="contains(@value,'watch?')">
                        <xsl:variable name="firstPart">
                            <xsl:value-of select="substring-after(@value,'watch?v=')"/>
                        </xsl:variable>
                        <xsl:attribute name="src">
                            <xsl:copy-of select="concat('http://www.youtube.com/embed/',substring-before($firstPart,'&amp;'))"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="contains(@value,'?')">
                        <xsl:variable name="firstPart">
                            <xsl:value-of select="substring-after(substring-before(@value,'?'),'/v/')"/>
                        </xsl:variable>
                        <xsl:attribute name="src">
                            <xsl:copy-of select="concat('http://www.youtube.com/embed/',$firstPart)"/>
                        </xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="src">
                            <xsl:copy-of select="@value"/>
                        </xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="{@name}">
                    <xsl:copy-of select="@value"/>
                </xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Comtech Services 11-21-2013 copy code from webworks implementation -->
    <xsl:template match="*[contains(@class, ' topic/cite ')]" name="topic.cite">
        <xsl:variable name="lang">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::*/@xml:lang">
                    <xsl:value-of select="ancestor-or-self::*/@xml:lang"/>
                </xsl:when>
                <xsl:when test="$LANGUAGE">
                    <xsl:value-of select="$LANGUAGE"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$LANGUAGE"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="prefix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_cite'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="suffix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_cite'"/>
            </xsl:call-template>
        </xsl:variable>

        <span class="cite">
            <xsl:attribute name="style">
                <xsl:choose>
                    <xsl:when test="starts-with(lower-case($lang),'ja') or contains(lower-case($lang),'zh')">font-style:normal;</xsl:when>
                    <xsl:otherwise>font-style:italic;</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="$prefix-char"/>
            <xsl:apply-templates/>
            <xsl:value-of select="$suffix-char"/>
        </span>
    </xsl:template>

    <!-- Comtech Services 11-21-2013 copy code from webworks implementation -->
    <xsl:template match="*[contains(@class, ' topic/q ')]" name="topic.q">
        <xsl:variable name="lang">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::*/@xml:lang">
                    <xsl:value-of select="ancestor-or-self::*/@xml:lang"/>
                </xsl:when>
                <xsl:when test="$LANGUAGE">
                    <xsl:value-of select="$LANGUAGE"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$LANGUAGE"/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:variable>

        <xsl:variable name="prefix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_q'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="suffix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_q'"/>
            </xsl:call-template>
        </xsl:variable>

        <span class="q">
            <xsl:value-of select="$prefix-char"/>
            <xsl:apply-templates/>
            <xsl:value-of select="$suffix-char"/>
        </span>
    </xsl:template>

    <!-- Comtech Services 11-21-2013 copy code from webworks implementation -->
    <xsl:template match="*[contains(@class, ' topic/lq ')]" name="topic.lq">
        <xsl:variable name="prefix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_lq'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="suffix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_lq'"/>
            </xsl:call-template>
        </xsl:variable>

        <span class="lq">
            <xsl:value-of select="$prefix-char"/>
            <xsl:apply-templates/>
            <xsl:value-of select="$suffix-char"/>
        </span>
    </xsl:template>

    <!-- EMC	 formatting of <term>  -->
    <xsl:template match="*[contains(@class,' topic/term ')]" mode="output-term">
        <xsl:param name="displaytext" select="''"/>
        <xsl:variable name="lang">
            <xsl:choose>
                <xsl:when test="ancestor-or-self::*/@xml:lang">
                    <xsl:value-of select="ancestor-or-self::*/@xml:lang"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$LANGUAGE"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="prefix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_term'"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="suffix-char">
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_term'"/>
            </xsl:call-template>
        </xsl:variable>

        <dfn class="term">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:attribute name="style">
                <xsl:choose>
                    <!-- HTML5 22/08/2014 fix for <term> issue #5.1.21 -->
                    <xsl:when test="starts-with(lower-case($lang),'ja')">font-style:normal; font-weight:bold;</xsl:when>
                    <xsl:when test="contains(lower-case($lang),'zh')">font-style:normal;</xsl:when>
                    <xsl:otherwise>font-style:italic;</xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="$prefix-char"/>
            <xsl:apply-templates/>
            <xsl:value-of select="$suffix-char"/>
            <!--
                        &lt;!&ndash;xsl:apply-templates/&ndash;&gt;
                        <xsl:apply-templates select="." mode="pull-in-title">
                            <xsl:with-param name="type" select="' term '"/>
                            <xsl:with-param name="displaytext" select="normalize-space($displaytext)"/>
                        </xsl:apply-templates>
            -->
        </dfn>
    </xsl:template>

    <xsl:template name="doentry">
        <xsl:variable name="this-colname" select="@colname"/>
        <!-- Rowsep/colsep: Skip if the last row or column. Only check the entry and colsep;
          if set higher, will already apply to the whole table. -->
        <xsl:variable name="row" select=".." as="element()"/>
        <xsl:variable name="body" select="../.." as="element()"/>
        <xsl:variable name="group" select="../../.." as="element()"/>
        <xsl:variable name="colspec" select="../../../*[contains(@class, ' topic/colspec ')][@colname and @colname = $this-colname]" as="element()"/>
        <xsl:variable name="table" select="../../../.." as="element()"/>

        <xsl:variable name="framevalue">
            <xsl:choose>
                <xsl:when test="$table/@frame and $table/@frame != ''">
                    <xsl:value-of select="$table/@frame"/>
                </xsl:when>
                <xsl:otherwise>all</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="rowsep" as="xs:integer">
            <xsl:choose>
                <!-- If there are more rows, keep rows on -->
                <xsl:when test="not(../following-sibling::*)">
                    <xsl:choose>
                        <xsl:when test="$framevalue = 'all' or $framevalue = 'bottom' or $framevalue = 'topbot'">1</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="@rowsep"><xsl:value-of select="@rowsep"/></xsl:when>
                <xsl:when test="$row/@rowsep"><xsl:value-of select="$row/@rowsep"/></xsl:when>
                <xsl:when test="$colspec/@rowsep"><xsl:value-of select="$colspec/@rowsep"/></xsl:when>
                <!-- IBHTML5 16/07/2014 TKT-100: HTML5 outputs incorrectly display colsep=”0" -->
                <xsl:when test="ancestor::*[contains(@class,' topic/tgroup ')]/@rowsep != ''">
                    <xsl:value-of select="ancestor::*[contains(@class,' topic/tgroup ')]/@rowsep"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colsep" as="xs:integer">
            <xsl:choose>
                <!-- If there are more columns, keep rows on -->
                <xsl:when test="not(following-sibling::*)">
                    <xsl:choose>
                        <xsl:when test="$framevalue = 'all' or $framevalue = 'sides'">1</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="@colsep"><xsl:value-of select="@colsep"/></xsl:when>
                <xsl:when test="$colspec/@colsep"><xsl:value-of select="$colspec/@colsep"/></xsl:when>
                <!-- IBHTML5 16/07/2014 TKT-100: HTML5 outputs incorrectly display colsep=”0" -->
                <xsl:when test="ancestor::*[contains(@class,' topic/tgroup ')]/@colsep != ''">
                    <xsl:value-of select="ancestor::*[contains(@class,' topic/tgroup ')]/@colsep"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="firstcol" as="xs:boolean" select="$table/@rowheader = 'firstcol' and @dita-ot:x = '1'"/>

        <xsl:call-template name="commonattributes">
            <xsl:with-param name="default-output-class">
                <xsl:if test="$firstcol">firstcol </xsl:if>
                <xsl:choose>
                    <xsl:when test="$rowsep = 0 and $colsep = 0">nocellnorowborder</xsl:when>
                    <xsl:when test="$rowsep = 1 and $colsep = 0">row-nocellborder</xsl:when>
                    <xsl:when test="$rowsep = 0 and $colsep = 1">cell-norowborder</xsl:when>
                    <xsl:when test="$rowsep = 1 and $colsep = 1">cellrowborder</xsl:when>
                </xsl:choose>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:choose>
            <xsl:when test="@id">
                <xsl:call-template name="setid"/>
            </xsl:when>
            <xsl:when test="$firstcol">
                <xsl:attribute name="id" select="generate-id(.)"/>
            </xsl:when>
        </xsl:choose>
        <xsl:if test="@morerows">
            <xsl:attribute name="rowspan"> <!-- set the number of rows to span -->
                <xsl:value-of select="@morerows + 1"/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="@dita-ot:morecols"> <!-- get the number of columns to span from the specified named column values -->
            <xsl:attribute name="colspan" select="@dita-ot:morecols + 1"/>
        </xsl:if>
        <!-- If align is specified on a colspec, that takes priority over tgroup -->

        <!-- If align is locally specified, that takes priority over all -->
        <xsl:call-template name="style">
            <xsl:with-param name="contents">
                <xsl:variable name="align" as="xs:string?">
                    <xsl:choose>
                        <xsl:when test="@align">
                            <xsl:value-of select="@align"/>
                        </xsl:when>
                        <xsl:when test="$group/@align">
                            <xsl:value-of select="$group/@align"/>
                        </xsl:when>
                        <xsl:when test="$colspec/@align">
                            <xsl:value-of select="$colspec/@align"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$table.align-default"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="exists($align)">
                    <xsl:text>text-align:</xsl:text>
                    <xsl:value-of select="$align"/>
                    <xsl:text>;</xsl:text>
                </xsl:if>
                <xsl:variable name="valign" as="xs:string?">
                    <xsl:choose>
                        <xsl:when test="@valign">
                            <xsl:value-of select="@valign"/>
                        </xsl:when>
                        <xsl:when test="$row/@valign">
                            <xsl:value-of select="$row/@valign"/>
                        </xsl:when>
                        <xsl:when test="$body/@valign">
                            <xsl:value-of select="$body/@valign"/>
                        </xsl:when>
                        <xsl:otherwise>top</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="exists($valign)">
                    <xsl:text>vertical-align:</xsl:text>
                    <xsl:value-of select="$valign"/>
                    <xsl:text>;</xsl:text>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:variable name="char" as="xs:string?">
            <xsl:choose>
                <xsl:when test="@char">
                    <xsl:value-of select="@char"/>
                </xsl:when>
                <xsl:when test="$colspec/@char">
                    <xsl:value-of select="$colspec/@char"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$char">
            <xsl:attribute name="char" select="$char"/>
        </xsl:if>
        <xsl:variable name="charoff" as="xs:string?">
            <xsl:choose>
                <xsl:when test="@charoff">
                    <xsl:value-of select="@charoff"/>
                </xsl:when>
                <xsl:when test="$colspec/@charoff">
                    <xsl:value-of select="$colspec/@charoff"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$charoff">
            <xsl:attribute name="charoff" select="$charoff"/>
        </xsl:if>

        <xsl:choose>
            <!-- When entry is in a thead, output the ID -->
            <xsl:when test="$body/self::*[contains(@class, ' topic/thead ')]">
                <xsl:attribute name="id" select="dita-ot:generate-html-id(.)"/>
            </xsl:when>
            <!-- otherwise, add @headers if needed -->
            <xsl:otherwise>
                <xsl:call-template name="add-headers-attribute"/>
            </xsl:otherwise>
        </xsl:choose>

        <!-- Add any flags from tgroup, thead or tbody, and row -->
        <xsl:apply-templates select="$group/*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="$body/*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="$row/*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:choose>
            <!-- When entry is empty, output a blank -->
            <xsl:when test="not(*|text()|processing-instruction())">
                <xsl:text>&#160;</xsl:text>  <!-- nbsp -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="$row/*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="$body/*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="$group/*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    </xsl:template>

    <!-- IA   Tridion upgrade    Dec-2018   Add new admonitions view STARTS HERE. - IB-->
    <xsl:template match="*[contains(@class, ' topic/note ')]" name="topic.note">
        <xsl:choose>
            <xsl:when test="@type = 'notice'">
                <xsl:apply-templates select="." mode="process.note.notice"/>
            </xsl:when>
            <xsl:when test="@type = 'caution'">
                <xsl:apply-templates select="." mode="process.note.caution"/>
            </xsl:when>
            <xsl:when test="@type = 'danger'">
                <xsl:apply-templates select="." mode="process.note.danger"/>
            </xsl:when>
            <xsl:when test="@type = 'warning'">
                <xsl:apply-templates select="." mode="process.note.warning"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="process.note"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*" mode="process.note">
        <xsl:apply-templates select="." mode="process.note.common-processing.emc">
            <!-- Force the type to note, in case new unrecognized values are added
                 before translations exist (such as Warning) -->
            <xsl:with-param name="type" select="'note'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="process.note.notice">
        <xsl:apply-templates select="." mode="process.note.common-processing.emc">
            <xsl:with-param name="type" select="'notice'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="process.note.caution">
        <xsl:apply-templates select="." mode="process.note.common-processing.emc">
            <xsl:with-param name="type" select="'caution'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="process.note.danger">
        <xsl:apply-templates select="." mode="process.note.common-processing.emc">
            <xsl:with-param name="type" select="'danger'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="process.note.warning">
        <xsl:apply-templates select="." mode="process.note.common-processing.emc">
            <xsl:with-param name="type" select="'warning'"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*" mode="process.note.common-processing.emc">
        <xsl:param name="type" select="@type"/>
        <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>

        <div class="{$type} admonition">
            <table>
                <tbody>
                    <tr>
                        <td>
                            <div class="admonition-image-container">
                                <xsl:call-template name="insertAdmonitionImage">
                                    <xsl:with-param name="type" select="$type"/>
                                </xsl:call-template>
                            </div>
                        </td>
                        <td>
                            <div class="admonition-body">
                                <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/revprop" mode="ditaval-outputflag"/>
                                <xsl:variable name="note-prefix">
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="$type"/>
                                    </xsl:call-template>
                                </xsl:variable>
                                <span class="{$type} admonition-label">
                                    <xsl:value-of select="upper-case($note-prefix)"/>
                                    <xsl:if test="not(contains($note-prefix, ':')) and not($lang = 'he')">
                                        <xsl:text>:</xsl:text>
                                    </xsl:if>
                                </span>
                                <span>&#xA0;</span>
                                <xsl:apply-templates/>
                                <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </xsl:template>

    <xsl:template name="insertAdmonitionImage">
        <xsl:param name="type"/>
        <xsl:variable name="image_name">
            <xsl:choose>
                <xsl:when test="$type = 'notice'">
                    <xsl:value-of select="'note.svg'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($type, '.svg')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <img class="admonition-image" src="{$image_name}" alt=""/>
    </xsl:template>
    <!-- IA   Tridion upgrade    Dec-2018   Add new admonitions view ENDS HERE. - IB-->

</xsl:stylesheet>