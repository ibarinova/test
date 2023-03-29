<?xml version='1.0' encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                exclude-result-prefixes="xs ia dita-ot"
                version="2.0">

    <xsl:import href="dita2html5-responsive-common-functions.xsl"/>
    <xsl:import href="dita2html5-responsive-common.xsl"/>

    <xsl:param name="properties-xml"/>
    <xsl:param name="out-extension" select="'.html'"/>

    <xsl:variable name="landing-page-filename" select="ia:getLandingPageName($properties-xml, base-uri())"/>

    <xsl:template match="/">
        <xsl:variable name="chapter-number" select="count(descendant::*[contains(@class, ' map/map ')][1]
                                                            /child::*[contains(@class, ' map/topicref ')][not(contains(@class, ' mapgroup-d/keydef '))]) + 1"/>
        <xsl:apply-templates/>

        <xsl:if test="$chapter-number &gt; 2">
            <xsl:call-template name="generateLandingPage"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="generateLandingPage">
        <xsl:result-document method="html" href="{$landing-page-filename}">
            <xsl:apply-templates select="." mode="landing-page"/>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="/" mode="landing-page">
        <html>
            <xsl:call-template name="setTopicLanguage"/>
            <xsl:value-of select="$newline"/>
            <xsl:call-template name="chapterHead"/>
            <xsl:call-template name="chapterBody-emc"/>
        </html>
    </xsl:template>

    <xsl:template match="*" mode="chapterHead">
        <head><xsl:value-of select="$newline"/>
            <!-- initial meta information -->
            <xsl:call-template name="generateCharset"/>   <!-- Set the character set to UTF-8 -->
            <xsl:call-template name="generateDefaultCopyright"/> <!-- Generate a default copyright, if needed -->
            <xsl:call-template name="generateDefaultMeta"/> <!-- Standard meta for security, robots, etc -->
            <xsl:call-template name="insertMeta-emc"/>
            <xsl:call-template name="getMeta"/>           <!-- Process metadata from topic prolog -->
            <xsl:call-template name="copyright"/>         <!-- Generate copyright, if specified manually -->
            <xsl:call-template name="insertCssLinks-emc"/>  <!-- Generate links to CSS files -->
            <xsl:call-template name="insertScripts-emc" /> <!-- include user's XSL javascripts here -->
            <xsl:call-template name="generateChapterTitle"/> <!-- Generate the <title> element -->
            <xsl:call-template name="gen-user-head" />    <!-- include user's XSL HEAD processing here -->
            <xsl:call-template name="processHDF"/>        <!-- Add user HDF file, if specified -->
        </head>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="chapterBody-emc">
        <body>
            <div id="landingPage">
                <xsl:apply-templates mode="landing-page"/>
            </div>
        </body>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/map ')]" mode="landing-page">
        <xsl:param name="pathFromMaplist"/>

        <xsl:variable name="chapters.number"
                      select="count(*[contains(@class, ' map/topicref ')][not(@toc = 'no')][not(@processing-role = 'resource-only')])"/>
        <xsl:variable name="chapters.half" select="xs:integer(round($chapters.number div 2))"/>

        <xsl:apply-templates mode="landing-page"/>

        <div class="landing-navigation">
            <div class="column-left">
                <nav>
                    <ul class="landing-page-ul">
                        <xsl:for-each select="*[contains(@class, ' map/topicref ')]
                                [count(preceding-sibling::*[contains(@class, ' map/topicref ')]) &lt; $chapters.half]">
                            <xsl:apply-templates select="." mode="toc">
                                <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                                <xsl:with-param name="tocType" select="'landing-page'"/>
                            </xsl:apply-templates>
                        </xsl:for-each>
                    </ul>
                </nav>
            </div>
            <xsl:if test="$chapters.number &gt; 1">
                <div class="column-right">
                    <nav>
                        <ul class="landing-page-ul">
                            <xsl:for-each select="*[contains(@class, ' map/topicref ')]
                                    [count(preceding-sibling::*[contains(@class, ' map/topicref ')]) &gt; $chapters.half - 1]">
                                <xsl:apply-templates select="." mode="toc">
                                    <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                                    <xsl:with-param name="tocType" select="'landing-page'"/>
                                </xsl:apply-templates>
                            </xsl:for-each>
                        </ul>
                    </nav>
                </div>
            </xsl:if>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicmeta ')]" mode="landing-page">
        <xsl:apply-templates select="*[contains(@class, ' topic/critdates ')]" mode="landing-page"/>
        <xsl:apply-templates select="*[contains(@class, ' map/shortdesc ')]" mode="landing-page"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/title ')]" mode="landing-page">
        <xsl:call-template name="insertTopicTitle-emc">
            <xsl:with-param name="level" select="1"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')]" mode="landing-page"/>
    <xsl:template match="*[contains(@class, ' map/reltable ')]" mode="landing-page"/>

    <xsl:template match="*[contains(@class, ' topic/critdates ')]" mode="landing-page">
        <xsl:apply-templates mode="landing-page"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/created ')]" mode="landing-page">
        <xsl:variable name="month" select="replace(normalize-space(@date), 'month=(.*);year=(.*);', '$1')"/>
        <xsl:variable name="year" select="replace(normalize-space(@date), 'month=(.*);year=(.*);', '$2')"/>

        <xsl:variable name="locale">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:if test="$year != 'undefined' and $month != 'undefined'">
            <p>
                <xsl:choose>
                    <xsl:when test="matches($locale, 'ja(-\w+)?')">
                        <xsl:value-of select="$year"/>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'year'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$month"/>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Published'"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="matches($locale, 'ko(-\w+)?')">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Published'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$year"/>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'year'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$month"/>
                    </xsl:when>
                    <xsl:when test="matches($locale, 'nl(-\w+)?')">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Published'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$month"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$year"/>
                    </xsl:when>
                    <xsl:when test="matches($locale, 'zh-(tw|hant)')">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Published'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$year"/>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'year'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$month"/>
                    </xsl:when>
                    <xsl:when test="matches($locale, 'zh(-\w+)?')">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Published'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$year"/>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'year'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$month"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Published'"/>
                        </xsl:call-template>
                        <xsl:value-of select="$month"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="$year"/>
                    </xsl:otherwise>
                </xsl:choose>
            </p>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/shortdesc ')]" mode="landing-page">
        <p>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates mode="landing-page"/>
        </p>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/map ')]" mode="chapterBody">
        <body>
            <xsl:attribute name="class" select="'toc'"/>
            <xsl:apply-templates select="." mode="toc"/>
        </body>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/map ')]" mode="toc">
        <xsl:param name="pathFromMaplist"/>
        <xsl:param name="tocType"/>
        <xsl:if test="descendant::*[contains(@class, ' map/topicref ')]
                               [not(@toc = 'no')]
                               [not(@processing-role = 'resource-only')]">
            <nav id="nav">
                <ul class="landing-page-link">
                    <li>
                        <a href="{$landing-page-filename}">
                            <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="text-only"/>
                        </a>

                    </li>
                </ul>
                <ul>
                    <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="toc">
                        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                        <xsl:with-param name="tocType" select="$tocType"/>
                    </xsl:apply-templates>
                </ul>
            </nav>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')]
                        [not(@toc = 'no')]
                        [not(@processing-role = 'resource-only')]"
                  mode="toc">
        <xsl:param name="pathFromMaplist"/>
        <xsl:param name="tocType"/>
        <xsl:variable name="title">
            <xsl:apply-templates select="." mode="get-navtitle"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$tocType != 'landing-page'">
                <xsl:if test="normalize-space(@href) and normalize-space($title)">
                    <xsl:variable name="href">
                        <xsl:choose>
                            <xsl:when test="contains(@href, concat($out-extension, '#'))">
                                <xsl:value-of select="substring-before(@href, '#')"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <li>
                        <a>
                            <xsl:attribute name="href">
                                <xsl:choose>
                                    <xsl:when test="@copy-to and not(contains(@chunk, 'to-content')) and
                                    (not(@format) or @format = 'dita' or @format = 'ditamap') ">
                                        <xsl:if test="not(@scope = 'external')">
                                            <xsl:value-of select="$pathFromMaplist"/>
                                        </xsl:if>
                                        <xsl:call-template name="replace-extension">
                                            <xsl:with-param name="filename" select="@copy-to"/>
                                            <xsl:with-param name="extension" select="$OUTEXT"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when
                                            test="not(@scope = 'external') and (not(@format) or @format = 'dita' or @format = 'ditamap')">
                                        <xsl:if test="not(@scope = 'external')">
                                            <xsl:value-of select="$pathFromMaplist"/>
                                        </xsl:if>
                                        <xsl:call-template name="replace-extension">
                                            <xsl:with-param name="filename" select="$href"/>
                                            <xsl:with-param name="extension" select="$OUTEXT"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise><!-- If non-DITA, keep the href as-is -->
                                        <xsl:if test="not(@scope = 'external')">
                                            <xsl:value-of select="$pathFromMaplist"/>
                                        </xsl:if>
                                        <xsl:value-of select="$href"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:if test="@scope = 'external' or not(not(@format) or @format = 'dita' or @format = 'ditamap')">
                                <xsl:attribute name="target">_blank</xsl:attribute>
                            </xsl:if>
                            <xsl:value-of select="$title"/>
                        </a>
                    </li>
                </xsl:if>
                <!-- If there are any children that should be in the TOC, process them -->
                <xsl:if test="descendant::*[contains(@class, ' map/topicref ')]
                                     [not(@toc = 'no')]
                                     [not(@processing-role = 'resource-only')]">
                    <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="toc">
                        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                        <xsl:with-param name="tocType" select="$tocType"/>
                    </xsl:apply-templates>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="normalize-space($title)">
                        <li>
                            <xsl:choose>
                                <!-- If there is a reference to a DITA or HTML file, and it is not external: -->
                                <xsl:when test="normalize-space(@href)">
                                    <xsl:variable name="href">
                                        <xsl:choose>
                                            <xsl:when test="contains(@href, concat($out-extension, '#'))">
                                                <xsl:value-of select="substring-before(@href, '#')"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@href"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:choose>
                                                <xsl:when test="@copy-to and not(contains(@chunk, 'to-content')) and
                                    (not(@format) or @format = 'dita' or @format = 'ditamap') ">
                                                    <xsl:if test="not(@scope = 'external')">
                                                        <xsl:value-of select="$pathFromMaplist"/>
                                                    </xsl:if>
                                                    <xsl:call-template name="replace-extension">
                                                        <xsl:with-param name="filename" select="@copy-to"/>
                                                        <xsl:with-param name="extension" select="$OUTEXT"/>
                                                    </xsl:call-template>
                                                    <!--
                                                                                                <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
                                                                                                    <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                                                                                                </xsl:if>
                                                    -->
                                                </xsl:when>
                                                <xsl:when
                                                        test="not(@scope = 'external') and (not(@format) or @format = 'dita' or @format = 'ditamap')">
                                                    <xsl:if test="not(@scope = 'external')">
                                                        <xsl:value-of select="$pathFromMaplist"/>
                                                    </xsl:if>
                                                    <xsl:call-template name="replace-extension">
                                                        <xsl:with-param name="filename" select="$href"/>
                                                        <xsl:with-param name="extension" select="$OUTEXT"/>
                                                    </xsl:call-template>
                                                </xsl:when>
                                                <xsl:otherwise><!-- If non-DITA, keep the href as-is -->
                                                    <xsl:if test="not(@scope = 'external')">
                                                        <xsl:value-of select="$pathFromMaplist"/>
                                                    </xsl:if>
                                                    <xsl:value-of select="$href"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:if test="@scope = 'external' or not(not(@format) or @format = 'dita' or @format = 'ditamap')">
                                            <xsl:attribute name="target">_blank</xsl:attribute>
                                        </xsl:if>
                                        <span>
                                            <xsl:value-of select="$title"/>
                                        </span>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span>
                                        <xsl:value-of select="$title"/>
                                    </span>
                                </xsl:otherwise>
                            </xsl:choose>
                            <!-- If there are any children that should be in the TOC, process them -->
                            <xsl:if test="descendant::*[contains(@class, ' map/topicref ')]
                                     [not(@toc = 'no')]
                                     [not(@processing-role = 'resource-only')]">
                                <ul>
                                    <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="toc">
                                        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                                        <xsl:with-param name="tocType" select="$tocType"/>
                                    </xsl:apply-templates>
                                </ul>
                            </xsl:if>
                        </li>
                    </xsl:when>
                    <xsl:otherwise><!-- if it is an empty topicref -->
                        <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]" mode="toc">
                            <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                            <xsl:with-param name="tocType" select="$tocType"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
