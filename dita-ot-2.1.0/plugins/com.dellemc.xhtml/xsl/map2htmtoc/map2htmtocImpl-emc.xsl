<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                xmlns:saxon="http://icl.com/saxon"
                extension-element-prefixes="saxon"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:java="org.dita.dost.util.StringUtils"
                exclude-result-prefixes="java dita-ot xs ditamsg">
    <!--
      Revision History
      ================
      EMC		IB8  	01-Oct-2015		TKT-327 hovertext should be shortdesc, limited to one level down
      EMC     IB9     17-Jan-2016     TKT-257: Use topic title instead of navtitle in the TOC
    -->
    <xsl:output method="xhtml" encoding="utf-8" indent="no" omit-xml-declaration="yes"/>

    <xsl:param name="INPUTDIR"/>

    <!-- add DRAFT if args.draft is set to yes -->
    <xsl:param name="DRAFT"/>

    <!-- add catch for args.bu='rsa' or 'mozy' style sheet -->
    <xsl:param name="ARGS.BU"/>

    <xsl:param name="dita-css"/> <!-- left to right languages -->

    <xsl:param name="bidi-dita-css"/> <!-- bidirectional languages -->

    <xsl:param name="contenttarget" select="'contentwin'"/>
    <xsl:param name="OUTPUTCLASS"/>   <!-- class to put on body element. -->
    <xsl:param name="TEMPDIR"/>
    <xsl:param name="DITAEXT" select="'.xml'"/>

    <xsl:template match="/">
        <xsl:call-template name="generate-toc"/>
    </xsl:template>

    <!--  EMC	15-Oct-2014		 Added new template "gen-user-header-custom" -->
    <xsl:template name="generate-toc">
        <html>
            <xsl:value-of select="$newline"/>
            <head>
                <xsl:value-of select="$newline"/>
                <xsl:if test="string-length($contenttarget)>0 and
				$contenttarget!='NONE'">
                    <base target="{$contenttarget}"/>
                    <xsl:value-of select="$newline"/>
                </xsl:if>
                <!-- initial meta information -->
                <xsl:call-template name="generateCharset"/>   <!-- Set the character set to UTF-8 -->
                <xsl:call-template name="generateDefaultCopyright"/> <!-- Generate a default copyright, if needed -->
                <xsl:call-template name="generateDefaultMeta"/> <!-- Standard meta for security, robots, etc -->
                <xsl:call-template name="copyright"/>         <!-- Generate copyright, if specified manually -->
                <xsl:call-template name="generateCssLinks"/>  <!-- Generate links to CSS files -->
                <xsl:call-template name="generateMapTitle"/> <!-- Generate the <title> element -->
                <xsl:call-template name="gen-user-head"/>    <!-- include user's XSL HEAD processing here -->
                <xsl:call-template name="gen-user-scripts"/> <!-- include user's XSL javascripts here -->
                <xsl:call-template name="gen-user-styles"/>  <!-- include user's XSL style element and content here -->
            </head>
            <xsl:value-of select="$newline"/>

            <body>
                <!-- Added customized templates for custom header -->
                <xsl:call-template name="gen-user-header-custom"/>
                <xsl:if test="string-length($OUTPUTCLASS) &gt; 0">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$OUTPUTCLASS"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$newline"/>
                <xsl:apply-templates/>
            </body>
            <xsl:value-of select="$newline"/>
        </html>
    </xsl:template>

    <xsl:template name="gen-user-header-custom">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- it will be placed in the running heading section of the XHTML. -->
        <div class="draft">
            <xsl:choose>
                <!--xsl:when test="$ARGS.BU='rsa' and $DRAFT='yes'">
                  <xsl:message>$ARGS.BU='rsa' and $DRAFT='yes'</xsl:message>
                    <xsl:call-template name="getWebhelpString">
                      <xsl:with-param name="stringName" select="'DraftRSA'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test="$ARGS.BU='rsa'">
                  <xsl:message>$ARGS.BU='rsa'</xsl:message>
                    <xsl:call-template name="getWebhelpString">
                      <xsl:with-param name="stringName" select="'RSA'"/>
                    </xsl:call-template>
                </xsl:when-->
                <xsl:when test="$DRAFT='yes'">
                    <xsl:message>$DRAFT='yes'</xsl:message>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Draft'"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        </div>
    </xsl:template>

    <!--  EMC	15-Oct-2014		 Customized for CSS linking -->
    <xsl:template name="generateCssLinks">
        <xsl:variable name="childlang">
            <xsl:choose>
                <!-- Update with DITA 1.2: /dita can have xml:lang -->
                <xsl:when test="self::dita[not(@xml:lang)]">
                    <xsl:for-each select="*[1]">
                        <xsl:call-template name="getLowerCaseLang"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getLowerCaseLang"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="direction">
            <xsl:apply-templates select="." mode="get-render-direction">
                <xsl:with-param name="lang" select="$childlang"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="urltest" as="xs:boolean"> <!-- test for URL -->
            <xsl:call-template name="url-string">
                <xsl:with-param name="urltext" select="concat($CSSPATH, $CSS)"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$direction = 'rtl' and $urltest ">
                <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$bidi-dita-css}"/>
            </xsl:when>
            <xsl:when test="$direction = 'rtl' and not($urltest)">
                <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$bidi-dita-css}"/>
            </xsl:when>
            <xsl:when test="$urltest">
                <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$dita-css}"/>
            </xsl:when>
            <xsl:otherwise>
                <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$dita-css}"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
        <!-- Add user's style sheet if requested to -->
        <xsl:if test="string-length($CSS) > 0">
            <xsl:choose>
                <xsl:when test="$urltest">
                    <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}"/>
                </xsl:when>
                <xsl:otherwise>
                    <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$newline"/>
        </xsl:if>

    </xsl:template>

    <!--  EMC	15-Oct-2014		 Added class="disc" for first level -->
    <!-- *********************************************************************************
         If processing only a single map, setup the HTML wrapper and output the contents.
         Otherwise, just process the contents.
         ********************************************************************************* -->
    <xsl:template match="/*[contains(@class, ' map/map ')]">
        <xsl:param name="pathFromMaplist"/>
        <xsl:if test=".//*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
            <ul class="disc">
                <xsl:value-of select="$newline"/>

                <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
                    <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                </xsl:apply-templates>
            </ul>
            <xsl:value-of select="$newline"/>
        </xsl:if>
    </xsl:template>

    <!--  EMC	15-Oct-2014		 Added class="square"/"ndash" for second and third level -->
    <!-- *********************************************************************************
         Output each topic as an <li> with an A-link. Each item takes 2 values:
         - A title. If a navtitle is specified on <topicref>, use that.
           Otherwise try to open the file and retrieve the title. First look for a navigation title in the topic,
           followed by the main topic title. Last, try to use <linktext> specified in the map.
           Failing that, use *** and issue a message.
         - An HREF is optional. If none is specified, this will generate a wrapper.
           Include the HREF if specified.
         - Ignore if TOC=no.

         If this topicref has any child topicref's that will be part of the navigation,
         output a <ul> around them and process the contents.
         ********************************************************************************* -->
    <xsl:template match="*[contains(@class, ' map/topicref ')][not(@toc='no')][not(@processing-role='resource-only')]">
        <xsl:param name="pathFromMaplist"/>
        <xsl:param name="level"/>

        <xsl:variable name="title">
            <xsl:apply-templates select="." mode="get-navtitle"/>
        </xsl:variable>

        <!-- EMC     IB9     17-Jan-2016    TKT-257: Use topic title instead of navtitle in the TOC -->
        <!-- IBHTML5 16/07/2014 TKT-110: "type"/"class" attribute -->
        <xsl:variable name="uptoDot">
            <xsl:value-of select="substring-before(@href,'.')"/>
        </xsl:variable>
        <xsl:variable name="FileName" select="concat($uptoDot, '.xml')"/>
        <xsl:variable name="tempFile" select="concat('file:///',$TEMPDIR,'\', $FileName)"/>
        <xsl:variable name="classOfBridgeTopic" select="document($tempFile)/topic/@class"/>

        <xsl:choose>
            <xsl:when test="$title and $title!=''">
                <li>
                    <xsl:choose>
                        <!-- If there is a reference to a DITA or HTML file, and it is not external: -->
                        <xsl:when test="@href and not(@href='')">
                            <xsl:element name="a">
                                <!-- EMC		IB8  	01-Oct-2015		TKT-327 hovertext should be shortdesc, limited to one level down -->
                                <xsl:variable name="hovertext">
                                    <xsl:for-each select="descendant::*[contains(@class,' map/shortdesc ')][1]">
                                        <xsl:text> </xsl:text>
                                        <xsl:apply-templates select="*|text()" mode="text-only"/>
                                    </xsl:for-each>
                                </xsl:variable>
                                <xsl:if test="normalize-space($hovertext)!=''">
                                    <xsl:attribute name="title">
                                        <xsl:value-of select="normalize-space($hovertext)"/>
                                    </xsl:attribute>
                                </xsl:if>
                                <!-- EMC     IB9     17-Jan-2016    TKT-257: Use topic title instead of navtitle in the TOC -->
                                <xsl:choose>
                                    <xsl:when test="(contains(@class, ' bookmap/chapter ') or contains(@class, ' bookmap/appendix ')) and $classOfBridgeTopic = '- topic/topic '"/>
                                    <xsl:otherwise>
                                        <xsl:attribute name="href">
                                            <xsl:choose>        <!-- What if targeting a nested topic? Need to keep the ID? -->
                                                <!-- edited by william on 2009-08-06 for bug:2832696 start -->
                                                <xsl:when test="contains(@copy-to, $DITAEXT) and not(contains(@chunk, 'to-content')) and (not(@format) or @format = 'dita' or @format='ditamap' ) ">
                                                    <!-- edited by william on 2009-08-06 for bug:2832696 end -->
                                                    <xsl:if test="not(@scope='external')">
                                                        <xsl:value-of select="$pathFromMaplist"/>
                                                    </xsl:if>
                                                    <xsl:call-template name="getFileName">
                                                        <xsl:with-param name="filename" select="@href"/>
                                                        <xsl:with-param name="extension" select="$DITAEXT"/>
                                                    </xsl:call-template>
                                                    <xsl:value-of select="$OUTEXT"/>
                                                    <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
                                                        <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                                                    </xsl:if>
                                                </xsl:when>
                                                <!-- edited by william on 2009-08-06 for bug:2832696 start -->
                                                <xsl:when test="contains(@href,$DITAEXT) and (not(@format) or @format = 'dita' or @format='ditamap')">
                                                    <!-- edited by william on 2009-08-06 for bug:2832696 end -->
                                                    <xsl:if test="not(@scope='external')">
                                                        <xsl:value-of select="$pathFromMaplist"/>
                                                    </xsl:if>
                                                    <xsl:call-template name="getFileName">
                                                        <xsl:with-param name="filename" select="@href"/>
                                                        <xsl:with-param name="extension" select="$DITAEXT"/>
                                                    </xsl:call-template>
                                                    <xsl:value-of select="$OUTEXT"/>
                                                    <xsl:if test="contains(@href, '#')">
                                                        <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                                                    </xsl:if>
                                                </xsl:when>
                                                <xsl:otherwise>  <!-- If non-DITA, keep the href as-is -->
                                                    <xsl:if test="not(@scope='external')">
                                                        <xsl:value-of select="$pathFromMaplist"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="@href"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="@scope='external' or @type='external' or ((@format='PDF' or @format='pdf') and not(@scope='local'))">
                                    <xsl:attribute name="target">_blank</xsl:attribute>
                                </xsl:if>
                                <xsl:value-of select="$title"/>
                            </xsl:element>
                        </xsl:when>

                        <xsl:otherwise>
                            <xsl:value-of select="$title"/>
                        </xsl:otherwise>
                    </xsl:choose>

                    <!-- If there are any children that should be in the TOC, process them -->
                    <xsl:if test="descendant::*[contains(@class, ' map/topicref ')][not(contains(@toc,'no'))][not(@processing-role='resource-only')]">
                        <xsl:value-of select="$newline"/>
                        <ul>
                            <xsl:attribute name="class">square</xsl:attribute>
                            <xsl:if test="$level = '3'">
                                <xsl:attribute name="class">ndash</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$newline"/>
                            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
                                <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                                <xsl:with-param name="level" select="'3'"/>
                            </xsl:apply-templates>
                        </ul>
                        <xsl:value-of select="$newline"/>
                    </xsl:if>
                </li>
                <xsl:value-of select="$newline"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- if it is an empty topicref -->
                <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
                    <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')][@processing-role='resource-only']"/>

    <xsl:template match="*" mode="get-navtitle">
        <xsl:choose>
            <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
                <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
                                     mode="dita-ot:text-only"/>
            </xsl:when>
            <!-- If navtitle is specified -->
            <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]">
                <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"
                                     mode="dita-ot:text-only"/>
            </xsl:when>
            <xsl:when test="@navtitle">
                <xsl:value-of select="@navtitle"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="normalize-space(@href)">
                    <xsl:apply-templates select="." mode="ditamsg:could-not-retrieve-navtitle-using-fallback">
                        <xsl:with-param name="target" select="@href"/>
                        <xsl:with-param name="fallback" select="@href"/>
                    </xsl:apply-templates>
                    <xsl:value-of select="@href"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--  EMC 	15-Oct-2014		Map title should be <mainbooktitle> if present, else '<series> <prodname> Help' -->
        <xsl:template name="generateMapTitle">
          <!-- Title processing - special handling for short descriptions -->
          <xsl:if test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')] or /*[contains(@class,' map/map ')]/@title">
          <title>
            <xsl:call-template name="gen-user-panel-title-pfx"/> <!-- hook for a user-XSL title prefix -->
            <xsl:choose>
              <xsl:when test="descendant::*[contains(@class, ' bookmap/mainbooktitle ')] and not(normalize-space(descendant::*[contains(@class, ' bookmap/mainbooktitle ')])='')">
                <xsl:apply-templates select="descendant::*[contains(@class, ' bookmap/mainbooktitle ')]"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="descendant::*[contains(@class, ' topic/series ')][1]"/>
                <xsl:if test="not(normalize-space(descendant::*[contains(@class, ' topic/series ')])='') and not(normalize-space(descendant::*[contains(@class, ' topic/prodname ')])='')">
                <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="descendant::*[contains(@class, ' topic/prodname ')][1]"/>
                <xsl:text> Help</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </title><xsl:value-of select="$newline"/>
          </xsl:if>
        </xsl:template>

    <!-- ==============================================================	-->
    <!-- 			SUPRESS FRONTMATTER, BACKMATTER AND PART 	 		-->
    <!-- ==============================================================	-->
    <xsl:template
            match="*[contains(@class, ' bookmap/frontmatter ')]"
            priority="9">
        <xsl:message>SUPRESSING FRONTMATTER</xsl:message>
    </xsl:template>

    <xsl:template
            match="*[contains(@class, ' bookmap/backmatter ')]"
            priority="9">
        <xsl:message>SUPRESSING BACKMATTER</xsl:message>
    </xsl:template>

    <xsl:template
            match="*[contains(@class, ' bookmap/part ') and not(@href) and not(@navtitle)]"
            priority="9">
        <xsl:message>SUPRESSING PART</xsl:message>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/mainbooktitle ')]">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
