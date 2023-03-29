<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:ia="http://intelliarts.com"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                version="2.0"
                exclude-result-prefixes="xs ia dita-ot dita2html related-links ditamsg">

    <xsl:import href="plugin:org.dita.xhtml:xsl/dita2html5.xsl"/>
    <xsl:import href="dita2html5-responsive-common-functions.xsl"/>
    <xsl:import href="dita2html5-responsive-common.xsl"/>

    <xsl:param name="properties-xml"/>
    <xsl:param name="temp-dir"/>
    <xsl:param name="out-extension" select="'.html'"/>

    <xsl:variable name="properties-xml-doc" select="doc(concat('file:/', translate($properties-xml, '\', '/')))"/>
    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:variable name="base-name" select="tokenize($base-uri,'/')[last()]"/>
    <xsl:variable name="topictile" select="$properties-xml-doc/descendant::*[@name = $base-name]/@topic-title"/>

    <xsl:variable name="insert-task-label" as="xs:boolean" select="if($properties-xml-doc/descendant::pub/@addTaskLabel = 'no') then(false()) else(true())"/>

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

    <xsl:template match="*" mode="addContentToHtmlBodyElement">
        <xsl:variable name="chapters-number" select="$properties-xml-doc/descendant::chapters/@number"/>
        <main>
            <div id="content-cover"><span> </span></div>
            <div id="content-wrapper">
                <xsl:if test="$chapters-number &gt; 1">
                    <xsl:call-template name="generate-navigationWrapper"/>
                </xsl:if>
                <xsl:call-template name="generate-onThisPageSection"/>
                <article id="mainArticle">
                    <xsl:if test="$chapters-number = 1">
                        <xsl:attribute name="class">
                            <xsl:value-of select="'no-navigation'"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:attribute name="aria-labelledby">
                        <xsl:apply-templates select="*[contains(@class,' topic/title ')] |
                                           self::dita/*[1]/*[contains(@class,' topic/title ')]" mode="return-aria-label-id"/>
                    </xsl:attribute>
                    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
                    <xsl:apply-templates/> <!-- this will include all things within topic; therefore, -->
                    <!-- title content will appear here by fall-through -->
                    <!-- followed by prolog (but no fall-through is permitted for it) -->
                    <!-- followed by body content, again by fall-through in document order -->
                    <!-- followed by related links -->
                    <!-- followed by child topics by fall-through -->
                    <xsl:call-template name="gen-endnotes"/>    <!-- include footnote-endnotes -->
                    <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
                </article>
            </div>
        </main>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]">
        <xsl:param name="headinglevel" as="xs:integer">
            <xsl:choose>
                <xsl:when test="count(ancestor::*[contains(@class, ' topic/topic ')]) > 6">6</xsl:when>
                <xsl:otherwise><xsl:sequence select="count(ancestor::*[contains(@class, ' topic/topic ')])"/></xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:element name="h{$headinglevel}">
            <xsl:attribute name="class">topictitle<xsl:value-of select="$headinglevel"/></xsl:attribute>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class">topictitle<xsl:value-of select="$headinglevel"/></xsl:with-param>
            </xsl:call-template>
            <xsl:attribute name="id"><xsl:apply-templates select="." mode="return-aria-label-id"/></xsl:attribute>

            <xsl:choose>
                <xsl:when test="$headinglevel = 1 and string-length(normalize-space(.)) = 0">
                    <xsl:value-of select="$topictile"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="generateChapterTitle">
        <!-- Title processing - special handling for short descriptions -->
        <title>
            <xsl:call-template name="gen-user-panel-title-pfx"/>
            <!-- hook for a user-XSL title prefix -->
            <xsl:variable name="maintitle">
                <xsl:apply-templates select="/*[contains(@class, ' topic/topic ')]/*[contains(@class, ' topic/title ')]"
                                     mode="text-only"/>
            </xsl:variable>
            <xsl:variable name="ditamaintitle">
                <xsl:apply-templates
                        select="/dita/*[contains(@class, ' topic/topic ')][1]/*[contains(@class, ' topic/title ')]"
                        mode="text-only"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="string-length($maintitle) > 0">
                    <xsl:value-of select="normalize-space($maintitle)"/>
                </xsl:when>
                <xsl:when test="string-length($ditamaintitle) > 0">
                    <xsl:value-of select="normalize-space($ditamaintitle)"/>
                </xsl:when>
                <xsl:when test="string-length($topictile) > 0">
                    <xsl:value-of select="normalize-space($topictile)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>***</xsl:text>
                    <xsl:apply-templates select="." mode="ditamsg:no-title-for-topic"/>
                </xsl:otherwise>
            </xsl:choose>
        </title>
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
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
        <div class="topic-content">
            <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))]"/>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/shortdesc ')]">
        <xsl:if test="ancestor::*[contains(@class, ' concept/concept ')
                            or contains(@class, ' reference/reference ') or contains(@class, ' task/task ')]">
            <xsl:choose>
                <xsl:when test="parent::*[contains(@class, ' topic/abstract ')]">
                    <xsl:apply-templates select="." mode="outofline.abstract"/>
                </xsl:when>
                <xsl:when test="not(following-sibling::*[contains(@class, ' topic/body ')])">
                    <xsl:apply-templates select="." mode="outofline"/>
                    <xsl:apply-templates select="following-sibling::*[contains(@class, ' topic/related-links ')]" mode="prereqs"/>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/link ')]/@href" mode="gen-metadata"/>

    <xsl:template match="*[contains(@class,' topic/shortdesc ')]" mode="gen-metadata">
        <xsl:variable name="shortmeta">
            <xsl:apply-templates select="*|text()" mode="text-only"/>
        </xsl:variable>
        <meta name="description">
            <xsl:attribute name="content">
                <xsl:value-of select="normalize-space($shortmeta)"/>
            </xsl:attribute>
        </meta>
    </xsl:template>

    <xsl:template name="generate-onThisPageSection">
        <xsl:if test="/descendant::*[contains(@class, ' topic/topic ')]
                                    [count(ancestor-or-self::*[contains(@class, ' topic/topic ')]) = 2]">
            <div id="onthispage-icon"><span> </span></div>
            <section id="onthispage">
                <div id="onthispage-container">
                    <p>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'on_this_page'"/>
                        </xsl:call-template>
                    </p>
                    <ul>
                        <xsl:apply-templates select="/descendant::*[contains(@class, ' topic/topic ')]
                                                [count(ancestor-or-self::*[contains(@class, ' topic/topic ')]) = 2]"
                                             mode="on-this-page"/>
                        <xsl:if test="/descendant::*[contains(@class, ' topic/related-links ')]">
                            <li>
                                <a href="#seealso">
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'see_also'"/>
                                    </xsl:call-template>
                                </a>
                            </li>
                        </xsl:if>
                    </ul>
                </div>
            </section>
        </xsl:if>
    </xsl:template>

    <xsl:template name="generate-navigationWrapper">
        <section class="toc" id="navigation-wrapper">
            <div id="show-navigation" class="hidden">
                <p>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'show_navigation'"/>
                    </xsl:call-template>
                </p>
            </div>

            <div id="hide-navigation" >
                <p>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'hide_navigation'"/>
                    </xsl:call-template>
                </p>
            </div>

            <div id="pub-navigation">
            </div>
        </section>
    </xsl:template>

    <xsl:template
            match="*[contains(@class, ' topic/topic ') and
                        count(ancestor-or-self::*[contains(@class, ' topic/topic ')]) &lt; 5]" mode="on-this-page">
        <li>
            <span>
                <a href="#{@id}">
                    <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="on-this-page-title"/>
                </a>
            </span>
            <xsl:if test="descendant::*[contains(@class, ' topic/topic ')]">
                <ul>
                    <xsl:apply-templates select="*[not(contains(@class, ' topic/title '))]" mode="on-this-page"/>
                </ul>
            </xsl:if>
        </li>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/title ') and
                        count(ancestor-or-self::*[contains(@class, ' topic/topic ')]) &lt; 4]"
                  mode="on-this-page-title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="@* | text()" mode="on-this-page"/>
    <xsl:template match="*" mode="on-this-page">
        <xsl:apply-templates mode="on-this-page"/>
    </xsl:template>

    <xsl:function name="ia:getColWidth">
        <xsl:param name="colwidth"/>
        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="not(matches($colwidth, '\d+'))">
                    <xsl:choose>
                        <xsl:when test="contains($colwidth, '*')">
                            <!--<xsl:value-ofselect="concat(count(string-to-codepoints(@myAttribute)[. = string-to-codepoints('*')]), '*')"/>-->
                            <xsl:value-of
                                    select="string-length($colwidth)-string-length(translate($colwidth,'*',''))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="1.00"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="translate($colwidth, '*', '')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="xs:double($result)"/>
    </xsl:function>

    <xsl:template match="*[contains(@class, ' topic/tgroup ')]" name="topic.tgroup">
        <xsl:variable name="totalwidth" as="xs:double">
            <xsl:variable name="relative-widths" as="xs:double*">
                <xsl:for-each select="*[contains(@class, ' topic/colspec ')][contains(@colwidth, '*')]">
                    <xsl:sequence select="ia:getColWidth(@colwidth)"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="sum($relative-widths)"/>
        </xsl:variable>
        <xsl:apply-templates>
            <xsl:with-param name="totalwidth" select="$totalwidth"/>
        </xsl:apply-templates>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/colspec ')]">
        <xsl:param name="totalwidth" as="xs:double"/>
        <xsl:variable name="width" as="xs:string">
            <xsl:choose>
                <xsl:when test="contains(@colwidth, '*')">
                    <xsl:value-of
                            select="concat((ia:getColWidth(@colwidth) div $totalwidth) * 100, '%')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@colwidth"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <col style="width:{$width}"/>
    </xsl:template>

    <xsl:template name="generateCssLinks">
        <xsl:call-template name="insertCssLinks-emc"/>
    </xsl:template>

    <xsl:template match="*" mode="gen-keywords-metadata">
        <xsl:variable name="keywords-content">
            <!-- for each item inside keywords (including nested index terms) -->
            <xsl:for-each
                    select="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/prolog ')]/*[contains(@class,' topic/metadata ')]/*[contains(@class,' topic/keywords ')]/descendant-or-self::*">
                <!-- If this is the first term or keyword with this value -->
                <xsl:if test="generate-id(key('meta-keywords',text()[1])[1])=generate-id(.)">
                    <xsl:if test="position()>2">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="normalize-space(text()[1])"/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:if test="string-length($keywords-content)>0">
            <meta name="DC.subject" content="{$keywords-content}"/>
            <xsl:value-of select="$newline"/>
            <meta name="keywords" content="{$keywords-content}"/>
            <xsl:value-of select="$newline"/>
        </xsl:if>
    </xsl:template>

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

    <xsl:template match="*" mode="process.note.common-processing.emc">
        <xsl:param name="type" select="@type"/>
        <xsl:variable name="lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>

        <div class="{$type} admonition">
            <!-- IA   Tridion upgrade    Oct-2018   Add new admonitions view STARTS HERE. - IB-->
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
                                <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]/revprop"
                                                     mode="ditaval-outputflag"/>
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
            <!-- IA   Tridion upgrade    Oct-2018   Add new admonitions view ENDS HERE. - IB-->
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

    <xsl:template match="*[contains(@class, ' topic/pre ')]" name="topic.pre">
        <pre>
            <xsl:attribute name="class" select="concat('pre ', name())"/>
            <code>
                <xsl:apply-templates/>
            </code>
        </pre>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/example ')]" name="topic.example">
        <div class="example">
            <!--<xsl:call-template name="commonattributes"/>-->
            <xsl:call-template name="gen-toc-id"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <!--<xsl:apply-templates select="." mode="dita2html:section-heading"/>-->
            <xsl:variable name="twistyClassName">
                <xsl:choose>
                    <xsl:when test="@outputclass = 'show_hide'">
                        <xsl:value-of select="'twisty collapsed'"/>
                    </xsl:when>
                    <xsl:when test="@outputclass = 'show_hide_expanded'">
                        <xsl:value-of select="'twisty expanded'"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <div class="example-title {$twistyClassName}">
                <xsl:if test="not(ancestor::*[contains(@class, ' task/task ')])
                                or (ancestor::*[contains(@class, ' task/task ')] and $insert-task-label)">
                    <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
                                Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
                    <span class="example-label">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Example Open'"/>
                        </xsl:call-template>
                    </span>
                    <xsl:text>&#xA0;</xsl:text>
                </xsl:if>
                <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
            </div>
            <xsl:apply-templates
                    select="*[not(contains(@class, ' topic/title '))] | text() | comment() | processing-instruction()"/>
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </div>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/example ')]/*[contains(@class, ' topic/title ')]"
                  name="topic.section_title">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/lines ')]" name="topic.lines">
        <xsl:if test="contains(@frame, 'top')">
            <hr/>
        </xsl:if>
        <xsl:call-template name="spec-title-nospace"/>
        <div class="lines">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setscale"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </div>
        <xsl:if test="contains(@frame, 'bot')">
            <hr/>
        </xsl:if>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="br-replace">
        <xsl:param name="brtext"/>
        <!-- capture an actual newline within the xsl:text element -->
        <xsl:variable name="cr"><xsl:text>
</xsl:text>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($brtext, $cr)">
                <xsl:value-of select="substring-before($brtext, $cr)"/>
                <!-- removed <br> element -->
                <xsl:value-of select="$cr"/>
                <xsl:call-template name="br-replace"> <!-- call again to get remaining CRs -->
                    <xsl:with-param name="brtext" select="substring-after($brtext, $cr)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$brtext"/>
                <!-- No CRs, just output -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/lq ')]" name="topic.lq">
        <p>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <xsl:apply-templates/>
            <xsl:choose>
                <xsl:when test="@href">
                    <br/>
                    <div style="text-align:right">
                        <a>
                            <xsl:attribute name="href">
                                <xsl:call-template name="href"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="@type = 'external'">
                                    <xsl:attribute name="target">_blank</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise><!--nop - no target needed for internal or biblio types (OR-should internal force DITA xref-like processing? What is intent? @type is only internal/external/bibliographic) --></xsl:otherwise>
                            </xsl:choose>
                            <cite>
                                <xsl:choose>
                                    <xsl:when test="@reftitle">
                                        <xsl:value-of select="@reftitle"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="@href"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </cite>
                        </a>
                    </div>
                </xsl:when>
                <xsl:when test="@reftitle"> <!-- Insert citation text -->
                    <br/>
                    <div style="text-align:right">
                        <cite>
                            <xsl:value-of select="@reftitle"/>
                        </cite>
                    </div>
                </xsl:when>
                <xsl:otherwise><!--nop - do nothing--></xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </p>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/ol ')]" name="topic.ol">
        <xsl:variable name="olcount" select="count(ancestor-or-self::*[contains(@class, ' topic/ol ')])"/>
        <xsl:variable name="twistyClassName">
            <xsl:choose>
                <xsl:when test="@outputclass = 'show_hide'">
                    <xsl:value-of select="'twisty collapsed'"/>
                </xsl:when>
                <xsl:when test="@outputclass = 'show_hide_expanded'">
                    <xsl:value-of select="'twisty expanded'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when test="$olcount > 2">
                    <xsl:value-of select="'level3'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('level', $olcount)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="self::*[contains(@class,' task/steps ') or contains(@class,' task/steps-unordered ')]">
            <xsl:if test="$insert-task-label">
                <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
                    Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
                <div class="task-label">
                    <span>
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'Steps Open'"/>
                        </xsl:call-template>
                    </span>
                </div>
            </xsl:if>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="string-length($twistyClassName) &gt; 1">
                <div>
                    <span class="{$twistyClassName}"/>
                    <ol class="{$className}">
                        <xsl:apply-templates/>
                    </ol>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <ol class="{$className}">
                    <xsl:apply-templates/>
                </ol>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/ul ')]" name="topic.ul">
        <xsl:variable name="ulcount" select="count(ancestor-or-self::*[contains(@class, ' topic/ul ')])"/>
        <xsl:variable name="twistyClassName">
            <xsl:choose>
                <xsl:when test="@outputclass = 'show_hide'">
                    <xsl:value-of select="'twisty collapsed'"/>
                </xsl:when>
                <xsl:when test="@outputclass = 'show_hide_expanded'">
                    <xsl:value-of select="'twisty expanded'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when test="$ulcount > 2">
                    <xsl:value-of select="'level3'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('level', $ulcount)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="string-length($twistyClassName) &gt; 1">
                <div>
                    <span class="{$twistyClassName}"/>
                    <ul class="{$className}">
                        <xsl:apply-templates/>
                    </ul>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <ul class="{$className}">
                    <xsl:apply-templates/>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/li ')]" name="topic.li">
        <li>
            <xsl:apply-templates select="." mode="add-step-importance-flag"/>
            <xsl:apply-templates/>
        </li><xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*" mode="add-step-importance-flag">
        <xsl:choose>
            <xsl:when test="@importance='optional'">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Step optional 1'"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@importance='required'">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Step required 1'"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dd ')]" name="topic.dd">
        <xsl:variable name="is-first-dd" select="empty(preceding-sibling::*[contains(@class, ' topic/dd ')])"/>
        <dd>
            <xsl:for-each select="..">
                <xsl:call-template name="commonattributes"/>
            </xsl:for-each>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class">
                    <xsl:if test="not($is-first-dd)">  <!-- para space before 2 thru N -->
                        <xsl:text>ddexpand</xsl:text>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <p>
                <xsl:apply-templates/>
            </p>
            <xsl:for-each select="following-sibling::*[contains(@class, ' topic/dd ')]">
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:for-each>
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </dd>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <!-- DL heading, term -->
    <xsl:template match="*[contains(@class, ' topic/dthd ')]" name="topic.dthd">
        <dt>
            <!-- Get ditaval style and xml:lang from DLHEAD, then override with local -->
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass"
                                 mode="add-ditaval-style"/>
            <xsl:apply-templates select="../@xml:lang"/>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <!--<strong>-->
            <xsl:apply-templates/>
            <!--</strong>-->
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </dt>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <!-- DL heading, description -->
    <xsl:template match="*[contains(@class, ' topic/ddhd ')]" name="topic.ddhd">
        <dd>
            <!-- Get ditaval style and xml:lang from DLHEAD, then override with local -->
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]/@outputclass"
                                 mode="add-ditaval-style"/>
            <xsl:apply-templates select="../@xml:lang"/>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <!--<strong>-->
            <xsl:apply-templates/>
            <!--</strong>-->
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </dd>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dlentry ')]" name="topic.dlentry">
        <xsl:apply-templates select="*[contains(@class, ' topic/dt ')]"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/dd ')][1]"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/cite ')]" name="topic.cite">
        <xsl:variable name="lowercase_lang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when test="matches($lowercase_lang, 'ja(-\w+)?') or
                                matches($lowercase_lang, 'zh-(tw|hant)') or
                                matches($lowercase_lang, 'zh(-\w+)?')">
                    <xsl:value-of select="'no-italic'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'italic'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="@keyref and @href">
                <xsl:apply-templates select="." mode="turning-to-link">
                    <xsl:with-param name="type" select="'cite'"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <cite>
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="setidaname"/>
                    <xsl:attribute name="class" select="$className"/>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'start_cite'"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'end_cite'"/>
                    </xsl:call-template>
                </cite>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="turning-to-link">
        <xsl:param name="keys" select="@keyref" as="xs:string?"/>
        <xsl:param name="type" select="name()" as="xs:string"/>
        <xsl:variable name="lowercase_lang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>
        <xsl:variable name="elementName" as="xs:string">
            <xsl:choose>
                <xsl:when test="$type = 'cite'">cite</xsl:when>
                <xsl:otherwise>span</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <a>
            <xsl:apply-templates select="." mode="add-linking-attributes"/>
            <xsl:apply-templates select="." mode="add-desc-as-hoverhelp"/>
            <xsl:element name="{$elementName}">
                <xsl:call-template name="commonattributes">
                    <xsl:with-param name="default-output-class">
                        <xsl:if test="normalize-space($type) != name()">
                            <xsl:value-of select="$type"/>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
                <xsl:if test="$type = 'cite'">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'start_cite'"/>
                    </xsl:call-template>
                </xsl:if>
                <xsl:apply-templates/>
                <xsl:if test="$type = 'cite'">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'end_cite'"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:element>
        </a>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/q ')]" name="topic.q">
        <span class="q">
            <!--<xsl:call-template name="commonattributes"/>-->
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_q_responsive'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_q_responsive'"/>
            </xsl:call-template>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/syntaxdiagram ')]//*[contains(@class,' pr-d/kwd ')] | *[contains(@class,' pr-d/synph ')]//*[contains(@class,' pr-d/kwd ')]"  mode="process-syntaxdiagram">
        <!--<kbd><b>-->
        <xsl:if test="parent::*[contains(@class,' pr-d/groupchoice ')]"><xsl:if test="count(preceding-sibling::*)!=0"> | </xsl:if></xsl:if>
        <xsl:if test="@importance='optional'"> [</xsl:if>
        <xsl:choose>
            <xsl:when test="@importance='default'"><u><xsl:value-of select="."/></u></xsl:when>
            <xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@importance='optional'">] </xsl:if>
        <!--</b>&#32;</kbd> &lt;!&ndash; force a space to follow the bold endtag, which has a concat behavior otherwise &ndash;&gt;-->
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/option ')]" name="topic.pr-d.option">
        <span class="option">
            <!--<xsl:call-template name="commonattributes"/>-->
            <!--<xsl:call-template name="setidaname"/>-->
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_option_responsive'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_option_responsive'"/>
            </xsl:call-template>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/term ')]" priority="10">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' ui-d/uicontrol ')]" name="topic.ui-d.uicontrol">
        <!-- insert an arrow with leading/trailing spaces before all but the first uicontrol in a menucascade -->
        <xsl:if test="ancestor::*[contains(@class,' ui-d/menucascade ')]">
            <xsl:variable name="uicontrolcount">
                <xsl:number count="*[contains(@class,' ui-d/uicontrol ')]"/>
            </xsl:variable>
            <xsl:if test="$uicontrolcount&gt;'1'">
                <xsl:text> > </xsl:text>
            </xsl:if>
        </xsl:if>

        <xsl:variable name="lowercase_lang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when test="matches($lowercase_lang, 'zh(-\w+)?')">
                    <xsl:value-of select="'uicontrol'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'uicontrol bold'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <span class="{$className}">
            <!--<xsl:call-template name="commonattributes"/>-->
            <!--<xsl:call-template name="setidaname"/>-->
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_uicontrol_responsive'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_uicontrol_responsive'"/>
            </xsl:call-template>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/var ')]" mode="process-syntaxdiagram" priority="10">
        <xsl:call-template name="process-varnames">
            <xsl:with-param name="type" select="'var'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class,' pr-d/var ')]" name="topic.pr-d.var" priority="10">
        <xsl:call-template name="process-varnames">
            <xsl:with-param name="type" select="'var'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class,' sw-d/varname ')]" name="topic.sw-d.varname" priority="10">
        <xsl:call-template name="process-varnames">
            <xsl:with-param name="type" select="'varname'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class,' ui-d/wintitle ')]" name="topic.ui-d.wintitle">

        <xsl:variable name="lowercase_lang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when test="matches($lowercase_lang, 'zh(-\w+)?')">
                    <xsl:value-of select="'wintitle'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'wintitle bold'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <span class="{$className}">
            <!--<xsl:call-template name="commonattributes"/>-->
            <!--<xsl:call-template name="setidaname"/>-->
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'start_wintitle_responsive'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'end_wintitle_responsive'"/>
            </xsl:call-template>
        </span>
    </xsl:template>

    <xsl:template name="process-varnames">
        <xsl:param name="type"/>

        <xsl:variable name="lowercase_lang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when test="matches($lowercase_lang, 'ja(-\w+)?')">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <xsl:when test="matches($lowercase_lang, 'zh(-\w+)?')">
                    <xsl:value-of select="$type"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($type, ' italic')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <var class="{$className}">
            <!--<xsl:call-template name="commonattributes"/>-->
            <!--<xsl:call-template name="setidaname"/>-->
            <xsl:choose>
                <xsl:when test="$type = 'varname'">
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'start_var_responsive'"/>
                    </xsl:call-template>
                    <xsl:apply-templates/>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'end_var_responsive'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
        </var>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/section ')]/*[contains(@class, ' topic/title ')]"
                  priority="10">
        <xsl:variable name="twistyClassName">
            <xsl:choose>
                <xsl:when test="parent::*[@outputclass = 'show_hide']">
                    <xsl:value-of select="'twisty collapsed'"/>
                </xsl:when>
                <xsl:when test="parent::*[@outputclass = 'show_hide_expanded']">
                    <xsl:value-of select="'twisty expanded'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <h6 class="sectiontitle {$twistyClassName}">
            <xsl:apply-templates/>
        </h6>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/related-links ')]" name="topic.related-links">
        <section id="seealso">
            <h2 class="topictitle2">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'see_also'"/>
                </xsl:call-template>
            </h2>
            <ul>
                <xsl:call-template name="commonattributes"/>
                <xsl:if test="$include.roles = ('child', 'descendant')">
                    <xsl:call-template name="ul-child-links"/>
                    <!--handle child/descendants outside of linklists in collection-type=unordered or choice-->
                    <xsl:call-template name="ol-child-links"/>
                    <!--handle child/descendants outside of linklists in collection-type=ordered/sequence-->
                </xsl:if>
                <xsl:if test="$include.roles = ('next', 'previous', 'parent')">
                    <xsl:call-template name="next-prev-parent-links"/>
                    <!--handle next and previous links-->
                </xsl:if>
                <!-- Group all unordered links (which have not already been handled by prior sections). Skip duplicate links. -->
                <!-- NOTE: The actual grouping code for related-links:group-unordered-links is common between
                       transform types, and is located in ../common/related-links.xsl. Actual code for
                       creating group titles and formatting links is located in XSL files specific to each type. -->
                <xsl:variable name="unordered-links" as="element(linklist)*">
                    <xsl:apply-templates select="." mode="related-links:group-unordered-links">
                        <xsl:with-param name="nodes"
                                        select="descendant::*[contains(@class, ' topic/link ')]
                                              [not(related-links:omit-from-unordered-links(.))]
                                              [generate-id(.) = generate-id(key('hideduplicates', related-links:hideduplicates(.))[1])]"/>
                    </xsl:apply-templates>
                </xsl:variable>
                <xsl:apply-templates select="$unordered-links"/>
                <!--linklists - last but not least, create all the linklists and their links, with no sorting or re-ordering-->
                <xsl:apply-templates select="*[contains(@class, ' topic/linklist ')]"/>
            </ul>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:result-group"
                  name="related-links:result.concept" as="element(linklist)">
        <xsl:param name="links" as="node()*"/>
        <xsl:if test="normalize-space(string-join($links, ''))">
            <linklist class="- topic/linklist " outputclass="relinfo relconcepts">
                <!--
                                <title class="- topic/title ">
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Related concepts'"/>
                                    </xsl:call-template>
                                </title>
                -->
                <xsl:copy-of select="$links"/>
            </linklist>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/link ')][@type='reference']" mode="related-links:result-group"
                  name="related-links:result.reference" as="element(linklist)">
        <xsl:param name="links"/>
        <xsl:if test="normalize-space(string-join($links, ''))">
            <linklist class="- topic/linklist " outputclass="relinfo relref">
                <!--
                                <title class="- topic/title ">
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Related reference'"/>
                                    </xsl:call-template>
                                </title>
                -->
                <xsl:copy-of select="$links"/>
            </linklist>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/link ')][@type='task']" mode="related-links:result-group"
                  name="related-links:result.task" as="element(linklist)">
        <xsl:param name="links" as="node()*"/>
        <xsl:if test="normalize-space(string-join($links, ''))">
            <linklist class="- topic/linklist " outputclass="relinfo reltasks">
                <!--
                                <title class="- topic/title ">
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Related tasks'"/>
                                    </xsl:call-template>
                                </title>
                -->
                <xsl:copy-of select="$links"/>
            </linklist>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*" mode="processlinklist">
        <xsl:param name="default-list-type" select="'linklist'" as="xs:string"/>
        <!--
                <xsl:call-template name="commonattributes">
                    <xsl:with-param name="default-output-class" select="$default-list-type"/>
                </xsl:call-template>
        -->
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]"/>
        <xsl:apply-templates select="*[contains(@class, ' topic/desc ')]"/>
        <xsl:for-each select="*[contains(@class, ' topic/linklist ')] | *[contains(@class, ' topic/link ')]">
            <xsl:choose>
                <!-- for children, div wrapper is created in main template -->
                <xsl:when test="contains(@class, ' topic/link ') and (@role = ('child', 'descendant'))">
                    <xsl:value-of select="$newline"/>
                    <xsl:apply-templates select="."/>
                </xsl:when>
                <xsl:when test="contains(@class, ' topic/link ')">
                    <xsl:value-of select="$newline"/>
                    <li>
                        <xsl:apply-templates select="."/>
                    </li>
                </xsl:when>
                <xsl:otherwise><!-- nested linklist -->
                    <xsl:apply-templates select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
        <xsl:apply-templates select="*[contains(@class, ' topic/linkinfo ')]"/>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/linklist ')]" name="topic.linklist">
        <xsl:value-of select="$newline"/>
        <xsl:choose>
            <!-- if this is a first-level linklist with no child links in it, put it in a div (flush left)-->
            <xsl:when test="(empty(parent::*) or parent::*[contains(@class, ' topic/related-links ')])
                      and not(child::*[contains(@class, ' topic/link ')][@role = ('child', 'descendant')])">
                <!--<ul class="linklist">-->
                <xsl:apply-templates select="." mode="processlinklist"/>
                <!--</ul>-->
            </xsl:when>
            <!-- When it contains children, indent with child class -->
            <xsl:when test="child::*[contains(@class, ' topic/link ')][@role = ('child', 'descendant')]">
                <!--<ul class="linklistwithchild">-->
                <xsl:apply-templates select="." mode="processlinklist">
                    <xsl:with-param name="default-list-type" select="'linklistwithchild'"/>
                </xsl:apply-templates>
                <!--</ul>-->
            </xsl:when>
            <!-- It is a nested linklist, indent with other class -->
            <xsl:otherwise>
                <!--<ul class="sublinklist">-->
                <xsl:apply-templates select="." mode="processlinklist">
                    <xsl:with-param name="default-list-type" select="'sublinklist'"/>
                </xsl:apply-templates>
                <!--</ul>-->
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="place-fig-lbl">
        <xsl:param name="stringName"/>
        <!-- Number of fig/title's including this one -->
        <xsl:variable name="fig-count-actual" select="count(preceding::*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')])+1"/>
        <xsl:variable name="ancestorlang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:variable name="twistyClassName">
            <xsl:choose>
                <xsl:when test="@outputclass = 'show_hide'">
                    <xsl:value-of select="'twisty collapsed'"/>
                </xsl:when>
                <xsl:when test="@outputclass = 'show_hide_expanded'">
                    <xsl:value-of select="'twisty expanded'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <!-- title -or- title & desc -->
            <xsl:when test="*[contains(@class, ' topic/title ')]">
                <div class="figcap {$twistyClassName}">
                    <span class="figure-label">
                        <xsl:choose>      <!-- Hungarian: "1. Figure " -->
                            <xsl:when test="$ancestorlang = ('hu', 'hu-hu')">
                                <xsl:value-of select="$fig-count-actual"/>
                                <xsl:text>. </xsl:text>
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Figure'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Figure'"/>
                                </xsl:call-template>
                                <xsl:text> </xsl:text>
                                <xsl:value-of select="$fig-count-actual"/>
                                <xsl:text>. </xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </span>
                    <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="figtitle"/>
                    <xsl:if test="*[contains(@class, ' topic/desc ')]">
                        <xsl:text>. </xsl:text>
                    </xsl:if>
                </div>
                <xsl:for-each select="*[contains(@class, ' topic/desc ')]">
                    <span class="figdesc">
                        <xsl:call-template name="commonattributes"/>
                        <xsl:apply-templates select="." mode="figdesc"/>
                    </span>
                </xsl:for-each>
            </xsl:when>
            <!-- desc -->
            <xsl:when test="*[contains(@class, ' topic/desc ')]">
                <xsl:for-each select="*[contains(@class, ' topic/desc ')]">
                    <span class="figdesc">
                        <xsl:call-template name="commonattributes"/>
                        <xsl:apply-templates select="." mode="figdesc"/>
                    </span>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fig ')]" name="topic.fig">
        <xsl:variable name="default-fig-class">
            <xsl:apply-templates select="." mode="dita2html:get-default-fig-class"/>
        </xsl:variable>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <figure>
            <xsl:if test="$default-fig-class != ''">
                <xsl:attribute name="class" select="$default-fig-class"/>
            </xsl:if>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class" select="$default-fig-class"/>
            </xsl:call-template>
            <xsl:call-template name="setscale"/>
            <xsl:call-template name="setidaname"/>
            <xsl:call-template name="place-fig-lbl"/>
            <xsl:apply-templates select="node() except *[contains(@class, ' topic/title ') or contains(@class, ' topic/desc ')]"/>
        </figure>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:value-of select="$newline"/>
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

    <xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')]
                            [not(ancestor::*[contains(@class, ' topic/table ')])]
                            [not(ancestor::*[contains(@class, ' topic/simpletable ')])]"
                  mode="topic.fn">
        <xsl:variable name="fnid">
            <xsl:number format="1"
                        value="count(preceding::*[contains(@class, ' topic/fn ')]
                                        [not(ancestor::*[contains(@class, ' topic/table ')])]
                                        [not(ancestor::*[contains(@class,' topic/simpletable ')])]) + 1"/>
        </xsl:variable>
        <xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
        <xsl:variable name="callout" select="@callout"/>
        <xsl:variable name="convergedcallout" select="if (string-length($callout)> 0) then $callout else $fnid"/>
        <a name="fnsrc_{$fnid}_{$ancestorId}" href="#fntarg_{$fnid}_{$ancestorId}">
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

            <span id="fntarg_{$fnid}_{$ancestorId}">
                <xsl:value-of select="concat($convergedcallout, '. ')"/>
            </span>

            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ')][@type != 'fn']" name="topic.xref">
        <xsl:choose>
            <xsl:when test="@href and normalize-space(@href)">
                <xsl:apply-templates select="." mode="add-xref-highlight-at-start"/>
                        <a>
                            <xsl:call-template name="commonattributes"/>
                            <xsl:apply-templates select="." mode="add-linking-attributes"/>
                            <xsl:apply-templates select="." mode="add-desc-as-hoverhelp"/>
                            <!-- if there is text or sub element other than desc, apply templates to them
                            otherwise, use the href as the value of link text. -->
                            <xsl:choose>
                                <xsl:when test="*[not(contains(@class, ' topic/desc '))] | text()">
                                    <xsl:apply-templates select="*[not(contains(@class, ' topic/desc '))] | text()"/>
                                    <!--use xref content-->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="href"/><!--use href text-->
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                <xsl:apply-templates select="." mode="add-xref-highlight-at-end"/>
            </xsl:when>
            <xsl:otherwise>
                <span>
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="add-desc-as-hoverhelp"/>
                    <xsl:apply-templates select="*[not(contains(@class, ' topic/desc '))] | text() | comment() | processing-instruction()"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ')][normalize-space(@keyref)]" >
        <xsl:variable name="TMP-path" select="concat('file:///', translate($temp-dir, '\', '/'), '/')"/>
        <xsl:variable name="keys" select="normalize-space(@keyref)"/>
        <xsl:variable name="keydefs" select="document(concat($TMP-path, 'keydef.xml'))"/>
        <xsl:variable name="keydef" select="$keydefs//*[contains(@keys, $keys)][1]"/>

        <xsl:variable name="keydefKeys" select="$keydef/@keys"/>
        <xsl:variable name="keydefSource" select="$keydef/@source"/>
        <xsl:variable name="keywordValue">
            <xsl:choose>
                <xsl:when test="$keydef[@scope = 'local'][matches(@href, 'https?:/')]">
                    <xsl:value-of select="$keydef/@href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                            select="document(concat($TMP-path, $keydefSource))/descendant::*[contains(@class, ' mapgroup-d/keydef ')][@keys = $keydefKeys][1]/descendant::*[contains(@class, ' topic/keyword ')][1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

         <xsl:choose>
            <xsl:when test="$keydef and normalize-space($keywordValue) != '' and $keydef[@scope = 'local'][matches(@href, 'https?:/')]">
                <a class="xref keyword" href="{$keywordValue}">
                    <xsl:value-of select="$keywordValue"/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <span class="keyword">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/table ')]" name="topic.table">
        <xsl:value-of select="$newline"/>
        <!-- special case for IE & NS for frame & no rules - needs to be a double table -->
        <xsl:variable name="className">
            <xsl:text>table </xsl:text>
            <xsl:choose>
                <xsl:when test="@frame and not(@frame = '')">
                    <xsl:value-of select="@frame"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'all'"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="(@expanse = 'page' or @pgwide = '1')and (ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')] )">
                    <xsl:value-of select="' no-pgwide'"/>
                </xsl:when>
                <xsl:when test="(@expanse = 'column' or @pgwide = '0') and (ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')] )">
                    <xsl:value-of select="' no-pgwide'"/>
                </xsl:when>
                <xsl:when test="(@expanse = 'page' or @pgwide = '1')">
                    <xsl:value-of select="' pgwide'"/>
                </xsl:when>
                <xsl:when test="(@expanse = 'column' or @pgwide = '0')">
                    <xsl:value-of select="' pgwide'"/>
                </xsl:when>
                <xsl:when test="descendant::*[contains(@class, ' topic/colspec ')][contains(@colwidth , '*')]">
                    <xsl:value-of select="' pgwide'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <table class="{$className}">
            <xsl:call-template name="setid"/>
            <xsl:call-template name="setscale"/>
            <xsl:call-template name="place-tbl-lbl"/>
            <!-- title and desc are processed elsewhere -->
            <xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]"/>
        </table>
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

    <xsl:template name="gen-table-footnote">
        <xsl:param name="table"/>
        <xsl:param name="element"/>
        <xsl:apply-templates select="$table/descendant::*[self::* = $element]
                                                [not( (ancestor-or-self::*[contains(@class, ' topic/draft-comment ')]
                                                        or ancestor::*[contains(@class, ' topic/required-cleanup ')])
                                                    and $DRAFT = 'no')][1]" mode="table.fn"/>
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
            <span id="fntarg_{$fnid}_{$ancestorId}">
                <xsl:value-of select="concat($convergedcallout, '. ')"/>
            </span>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ')][@type = 'fn']"
                  mode="genTableEndnote"/>

    <xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')]
                            [ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]]"
                  mode="table.fn">
        <xsl:variable name="fnid">
            <xsl:number format="a" value="count(preceding::*[contains(@class, ' topic/fn ')]) + 1"/>
        </xsl:variable>
        <xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
        <xsl:variable name="callout" select="@callout"/>
        <xsl:variable name="convergedcallout" select="if (string-length($callout)> 0) then $callout else $fnid"/>
        <a href="#fntarg_{$fnid}_{$ancestorId}">
            <sup>
                <xsl:value-of select="$convergedcallout"/>
            </sup>
        </a>
    </xsl:template>

    <xsl:template name="place-tbl-lbl">
        <!-- Number of table/title's before this one -->
        <xsl:variable name="tbl-count-actual" select="count(preceding::*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')])+1"/>

        <!-- normally: "Table 1. " -->
        <xsl:variable name="ancestorlang">
            <xsl:call-template name="getLowerCaseLang"/>
        </xsl:variable>

        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when test="@outputclass = 'show_hide'">
                    <xsl:value-of select="'twisty collapsed'"/>
                </xsl:when>
                <xsl:when test="@outputclass = 'show_hide_expanded'">
                    <xsl:value-of select="'twisty expanded'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- title -or- title & desc -->
            <xsl:when test="*[contains(@class, ' topic/title ')]">
                <caption >
                    <xsl:if test="normalize-space($className)">
                        <xsl:attribute name="class" select="$className"/>
                    </xsl:if>
                    <span class="tablecap">
                        <span class="table-label">
                            <xsl:choose>     <!-- Hungarian: "1. Table " -->
                                <xsl:when test="$ancestorlang = ('hu', 'hu-hu')">
                                    <xsl:value-of select="$tbl-count-actual"/>
                                    <xsl:text>. </xsl:text>
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Table'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Table'"/>
                                    </xsl:call-template>
                                    <xsl:text> </xsl:text>
                                    <xsl:value-of select="$tbl-count-actual"/>
                                    <xsl:text>. </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                        <xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="tabletitle"/>
                        <xsl:if test="*[contains(@class, ' topic/desc ')]">
                            <xsl:text>. </xsl:text>
                        </xsl:if>
                    </span>
                    <xsl:for-each select="*[contains(@class, ' topic/desc ')]">
                        <span class="tabledesc">
                            <xsl:call-template name="commonattributes"/>
                            <xsl:apply-templates select="." mode="tabledesc"/>
                        </span>
                    </xsl:for-each>
                </caption>
            </xsl:when>
            <!-- desc -->
            <xsl:when test="*[contains(@class, ' topic/desc ')]">
                <xsl:for-each select="*[contains(@class, ' topic/desc ')]">
                    <span class="tabledesc">
                        <xsl:call-template name="commonattributes"/>
                        <xsl:apply-templates select="." mode="tabledesc"/>
                    </span>
                </xsl:for-each>
            </xsl:when>
        </xsl:choose>
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
        <xsl:variable name="firstcol" as="xs:boolean" select="$table/@rowheader = 'firstcol' and @dita-ot:x = '1'"/>

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
                <xsl:when
                        test="not(parent::*[parent::*[contains(@class, 'thead')]]) and not($firstcol) and not(../following-sibling::*)">
                    <xsl:choose>
                        <xsl:when test="$framevalue = 'all' or $framevalue = 'bottom' or $framevalue = 'topbot'">1</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="@rowsep"><xsl:value-of select="@rowsep"/></xsl:when>
                <xsl:when test="$row/@rowsep"><xsl:value-of select="$row/@rowsep"/></xsl:when>
                <xsl:when test="$colspec/@rowsep"><xsl:value-of select="$colspec/@rowsep"/></xsl:when>
                <xsl:when test="$group/@rowsep"><xsl:value-of select="$group/@rowsep"/></xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="colsep" as="xs:integer">
            <xsl:choose>
                <!-- If there are more columns, keep rows on -->
                <xsl:when test="not(parent::*[parent::*[contains(@class, 'thead')]]) and not($firstcol) and not(following-sibling::*)">
                    <xsl:choose>
                        <xsl:when test="$framevalue = 'all' or $framevalue = 'sides'">1</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="@colsep"><xsl:value-of select="@colsep"/></xsl:when>
                <xsl:when test="$colspec/@colsep"><xsl:value-of select="$colspec/@colsep"/></xsl:when>
                <xsl:when test="$group/@colsep"><xsl:value-of select="$group/@colsep"/></xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

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
        <div class="table-entry">
            <xsl:choose>
                <!-- When entry is empty, output a blank -->
                <xsl:when test="not(*|text()|processing-instruction())">
                    <xsl:text>&#160;</xsl:text>  <!-- nbsp -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
        <xsl:apply-templates select="$row/*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="$body/*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:apply-templates select="$group/*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/simpletable ')]
                            [not(contains(@class,' reference/properties '))]
                            [not(contains(@class,' task/choicetable '))]" name="topic.simpletable">
        <xsl:call-template name="spec-title"/>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:call-template name="setaname"/>

        <xsl:variable name="className">
            <xsl:text>simpletable all</xsl:text>
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')]">
                    <xsl:value-of select="' no-pgwide'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="' pgwide'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <table class="{$className}">
            <xsl:call-template name="setid"/>
            <xsl:call-template name="setscale"/>
            <xsl:call-template name="dita2html:simpletable-cols"/>
            <xsl:apply-templates select="." mode="dita2html:simpletable-heading"/>
            <tbody>
                <xsl:apply-templates select="*[contains(@class, ' topic/strow ')]|processing-instruction()"/>
            </tbody>
        </table>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:value-of select="$newline"/>
        <xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ')  or (contains(@class, ' topic/xref ')and @type = 'fn')])">
            <xsl:variable name="table">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:call-template name="gen-table-endnotes">
                <xsl:with-param name="table" select="$table"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template name="topic.sthead_stentry">
        <th>
            <xsl:call-template name="style">
                <xsl:with-param name="contents">
                    <xsl:text>vertical-align:bottom;</xsl:text>
                    <xsl:call-template name="th-align"/>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="output-stentry-id"/>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <div class="table-entry">
                <xsl:choose>
                    <!-- If there is text, or a PI, or non-flagging element child -->
                    <xsl:when test="*[not(contains(@class, ' ditaot-d/startprop ') or contains(@class, ' dita-ot/endprop '))] | text() | processing-instruction()">
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Add flags, then either @specentry or NBSP -->
                        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
                        <xsl:choose>
                            <xsl:when test="@specentry"><xsl:value-of select="@specentry"/></xsl:when>
                            <xsl:otherwise>&#160;</xsl:otherwise>
                        </xsl:choose>
                        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </th><xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template name="stentry-templates">
        <div class="table-entry-wrapper">
            <xsl:choose>
                <xsl:when test="not(*|text()|processing-instruction()) and @specentry">
                    <xsl:value-of select="@specentry"/>
                </xsl:when>
                <xsl:when test="not(*|text()|processing-instruction())">
                    <xsl:text>&#160;</xsl:text>  <!-- nbsp -->
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class,' reference/properties ')]" name="reference.properties">
        <xsl:call-template name="spec-title"/>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <xsl:call-template name="setaname"/>
        <xsl:variable name="className">
            <xsl:text>properties all</xsl:text>
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')]">
                    <xsl:value-of select="' no-pgwide'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="' pgwide'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <table class="{$className}">
            <xsl:call-template name="dita2html:simpletable-cols"/>

            <xsl:variable name="header" select="*[contains(@class,' reference/prophead ')]"/>
            <xsl:variable name="properties" select="*[contains(@class,' reference/property ')]"/>
            <xsl:variable name="hasType" select="exists($header/*[contains(@class,' reference/proptypehd ')] | $properties/*[contains(@class,' reference/proptype ')])"/>
            <xsl:variable name="hasValue" select="exists($header/*[contains(@class,' reference/propvaluehd ')] | $properties/*[contains(@class,' reference/propvalue ')])"/>
            <xsl:variable name="hasDesc" select="exists($header/*[contains(@class,' reference/propdeschd ')] | $properties/*[contains(@class,' reference/propdesc ')])"/>

            <xsl:variable name="prophead" as="element()">
                <xsl:choose>
                    <xsl:when test="*[contains(@class, ' reference/prophead ')]">
                        <xsl:sequence select="*[contains(@class, ' reference/prophead ')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="gen" as="element(gen)?">
                            <xsl:call-template name="gen-prophead">
                                <xsl:with-param name="hasType" select="$hasType"/>
                                <xsl:with-param name="hasValue" select="$hasValue"/>
                                <xsl:with-param name="hasDesc" select="$hasDesc"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:sequence select="$gen/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:apply-templates select="$prophead">
                <xsl:with-param name="hasType" select="$hasType"/>
                <xsl:with-param name="hasValue" select="$hasValue"/>
                <xsl:with-param name="hasDesc" select="$hasDesc"/>
            </xsl:apply-templates>
            <tbody>
                <xsl:apply-templates select="*[contains(@class, ' reference/property ')] | processing-instruction()">
                    <xsl:with-param name="hasType" select="$hasType"/>
                    <xsl:with-param name="hasValue" select="$hasValue"/>
                    <xsl:with-param name="hasDesc" select="$hasDesc"/>
                </xsl:apply-templates>
            </tbody>
        </table>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        <xsl:value-of select="$newline"/>
        <xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')])">
            <xsl:variable name="table">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:call-template name="gen-table-endnotes">
                <xsl:with-param name="table" select="$table"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' reference/property ')]" name="topic.reference.property">
        <xsl:param name="hasType" as="xs:boolean"/>
        <xsl:param name="hasValue" as="xs:boolean"/>
        <xsl:param name="hasDesc" as="xs:boolean"/>
        <tr>
            <xsl:call-template name="setid"/>
            <xsl:call-template name="commonattributes"/>
            <xsl:value-of select="$newline"/>
            <!-- For each of the 3 entry types:
                 - If it is in this row, apply
                 - Otherwise, if it is in the table at all, create empty entry -->
            <xsl:choose>      <!-- Process or create proptype -->
                <xsl:when test="*[contains(@class,' reference/proptype ')]">
                    <xsl:apply-templates select="*[contains(@class,' reference/proptype ')]"/>
                </xsl:when>
                <xsl:when test="$hasType">
                    <td>    <!-- Create an empty cell. Add accessiblity attribute. -->
                        <div class="table-entry-wrapper">
                            <xsl:call-template name="addPropertiesHeadersAttribute">
                                <xsl:with-param name="classVal"> reference/proptypehd </xsl:with-param>
                                <xsl:with-param name="elementType">type</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>&#xA0;</xsl:text>
                        </div>
                    </td>
                    <xsl:value-of select="$newline"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>      <!-- Process or create propvalue -->
                <xsl:when test="*[contains(@class,' reference/propvalue ')]">
                    <xsl:apply-templates select="*[contains(@class,' reference/propvalue ')]"/>
                </xsl:when>
                <xsl:when test="$hasValue">
                    <td>    <!-- Create an empty cell. Add accessiblity attribute. -->
                        <div class="table-entry-wrapper">
                            <xsl:call-template name="addPropertiesHeadersAttribute">
                                <xsl:with-param name="classVal">reference/propvaluehd</xsl:with-param>
                                <xsl:with-param name="elementType">value</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>&#xA0;</xsl:text>
                        </div>
                    </td>
                    <xsl:value-of select="$newline"/>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>      <!-- Process or create propdesc -->
                <xsl:when test="*[contains(@class,' reference/propdesc ')]">
                    <xsl:apply-templates select="*[contains(@class,' reference/propdesc ')]"/>
                </xsl:when>
                <xsl:when test="$hasDesc">
                    <td>    <!-- Create an empty cell. Add accessiblity attribute. -->
                        <div class="table-entry-wrapper">
                            <xsl:call-template name="addPropertiesHeadersAttribute">
                                <xsl:with-param name="classVal">reference/propdeschd</xsl:with-param>
                                <xsl:with-param name="elementType">desc</xsl:with-param>
                            </xsl:call-template>
                            <xsl:text>&#xA0;</xsl:text>
                        </div>
                    </td>
                    <xsl:value-of select="$newline"/>
                </xsl:when>
            </xsl:choose>
        </tr>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*" mode="propertiesEntry">
        <xsl:param name="elementType"/>

        <xsl:variable name="localkeycol" as="xs:integer">
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class,' topic/simpletable ')][1]/@keycol">
                    <xsl:value-of select="ancestor::*[contains(@class,' topic/simpletable ')][1]/@keycol"/>
                </xsl:when>
                <xsl:otherwise>0</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="element-name" as="xs:string">
            <xsl:choose>
                <xsl:when test="$localkeycol = 1 and $elementType = 'type'">th</xsl:when>
                <xsl:when test="$localkeycol = 2 and $elementType = 'value'">th</xsl:when>
                <xsl:when test="$localkeycol = 3 and $elementType = 'desc'">th</xsl:when>
                <xsl:otherwise>td</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$element-name}">
            <xsl:call-template name="style">
                <xsl:with-param name="contents">
                    <xsl:text>vertical-align:top;</xsl:text>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="output-stentry-id"/>
            <xsl:call-template name="addPropertiesHeadersAttribute">
                <xsl:with-param name="classVal"> reference/prop<xsl:value-of select="$elementType"/>hd<xsl:text> </xsl:text></xsl:with-param>
                <xsl:with-param name="elementType" select="$elementType"/>
            </xsl:call-template>
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
            <div class="table-entry-wrapper">
                <xsl:call-template name="propentry-templates"/>
            </div>
            <xsl:apply-templates select="../*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
        </xsl:element>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/object ')][*[contains(@class, ' topic/param ')][@name = 'movie']]"
                  name="topic.object">
        <xsl:variable name="src" select="*[contains(@class, ' topic/param ')][@name = 'movie']/@value"/>
        <div class="video-wrap">
            <div class="video-container">
                <iframe src="{$src}">
                    <xsl:if test="*[contains(@class, ' topic/param ')][@name = 'allowFullScreen'][@value = 'true']">
                        <xsl:attribute name="allowFullScreen" select="'allowfullscreen'"/>
                    </xsl:if>
                </iframe>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/p ')]" name="topic.p">
        <xsl:variable name="twistyClassName">
            <xsl:choose>
                <xsl:when test="@outputclass = 'show_hide'">
                    <xsl:value-of select="'twisty collapsed'"/>
                </xsl:when>
                <xsl:when test="@outputclass = 'show_hide_expanded'">
                    <xsl:value-of select="'twisty expanded'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="string-length($twistyClassName) &gt; 1">
                <div>
                    <span class="{$twistyClassName}"/>
                    <xsl:apply-templates select="." mode="process-paragraph"/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="process-paragraph"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="$newline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/p ')]" mode="process-paragraph">
        <!-- To ensure XHTML validity, need to determine whether the DITA kids are block elements.
             If so, use div_class="p" instead of p -->
        <xsl:variable name="className">
            <xsl:choose>
                <xsl:when
                        test="parent::*[contains(@class, ' topic/li ')] and not(preceding-sibling::*) and not(preceding-sibling::text()[normalize-space()!=''])">
                    <!--<xsl:value-of select="'p'"/>-->
                    <xsl:value-of select="'p li-p-first'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'p'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="descendant::*[contains(@class, ' topic/pre ')] or
                       descendant::*[contains(@class, ' topic/ul ')] or
                       descendant::*[contains(@class, ' topic/sl ')] or
                       descendant::*[contains(@class, ' topic/ol ')] or
                       descendant::*[contains(@class, ' topic/lq ')] or
                       descendant::*[contains(@class, ' topic/dl ')] or
                       descendant::*[contains(@class, ' topic/note ')] or
                       descendant::*[contains(@class, ' topic/lines ')] or
                       descendant::*[contains(@class, ' topic/fig ')] or
                       descendant::*[contains(@class, ' topic/table ')] or
                       descendant::*[contains(@class, ' topic/simpletable ')]">
                <div class="{$className}">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <p class="{$className}">
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="topic-image">
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
        <img>
            <xsl:call-template name="commonattributes">
                <xsl:with-param name="default-output-class">
                    <xsl:if test="@placement = 'break'"><!--Align only works for break-->
                        <xsl:choose>
                            <xsl:when test="@align = 'left'">imageleft</xsl:when>
                            <xsl:when test="@align = 'right'">imageright</xsl:when>
                            <xsl:when test="@align = 'center'">imagecenter</xsl:when>
                        </xsl:choose>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="setid"/>
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/longdescref ')]">
                    <xsl:apply-templates select="*[contains(@class, ' topic/longdescref ')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="@longdescref"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="@href|@height|@width"/>
            <xsl:apply-templates select="@scale"/>
            <xsl:choose>
                <xsl:when test="*[contains(@class, ' topic/alt ')]">
                    <xsl:variable name="alt-content"><xsl:apply-templates select="*[contains(@class, ' topic/alt ')]" mode="text-only"/></xsl:variable>
                    <xsl:attribute name="alt" select="normalize-space($alt-content)"/>
                </xsl:when>
                <xsl:when test="@alt">
                    <xsl:attribute name="alt" select="@alt"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="alt"/>
                </xsl:otherwise>
            </xsl:choose>
        </img>
        <xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' task/choicetable ')]" name="topic.task.choicetable">
        <xsl:value-of select="$newline"/>
        <xsl:variable name="className">
            <xsl:text>simpletable all</xsl:text>
            <xsl:choose>
                <xsl:when test="ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')]">
                    <xsl:value-of select="' no-pgwide'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="' pgwide'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <table class="{$className}">
            <xsl:call-template name="setid"/>
            <xsl:call-template name="dita2html:simpletable-cols"/>
            <!--If the choicetable has no header - output a default one-->
            <xsl:variable name="chhead" as="element()?">
                <xsl:choose>
                    <xsl:when test="exists(*[contains(@class,' task/chhead ')])">
                        <xsl:sequence select="*[contains(@class,' task/chhead ')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="gen" as="element(gen)?">
                            <xsl:call-template name="gen-chhead"/>
                        </xsl:variable>
                        <xsl:sequence select="$gen/*"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:apply-templates select="$chhead"/>
            <tbody>
                <xsl:apply-templates select="*[contains(@class, ' task/chrow ')]"/>
            </tbody>
        </table>
        <xsl:value-of select="$newline"/>
        <xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')])">
            <xsl:variable name="table">
                <xsl:copy-of select="."/>
            </xsl:variable>
            <xsl:call-template name="gen-table-endnotes">
                <xsl:with-param name="table" select="$table"/>
            </xsl:call-template>
        </xsl:if>

    </xsl:template>

    <xsl:template match="*" mode="dita2html:simpletable-heading">
        <xsl:choose>
            <xsl:when test="contains(@class,' task/choicetable ')">
                <xsl:apply-templates select="*[contains(@class, ' topic/sthead ')]"/>
            </xsl:when>
            <xsl:otherwise>
                <thead>
                    <xsl:apply-templates select="*[contains(@class, ' topic/sthead ')]"/>
                </thead>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template
            match="*[contains(@class,' task/taskbody ')]/*[contains(@class,' topic/example ')][not(*[contains(@class,' topic/title ')])]"
            mode="dita2html:section-heading">
        <xsl:if test="$insert-task-label">
            <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
              Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
            <div class="task-label">
                <span>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Example Open'"/>
                    </xsl:call-template>
                </span>
            </div>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' task/prereq ')]" mode="dita2html:section-heading">
        <xsl:if test="$insert-task-label">
            <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
               Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
            <div class="task-label">
                <span>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Prerequisite Open'"/>
                    </xsl:call-template>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' task/result ')]" mode="dita2html:section-heading">
        <xsl:if test="$insert-task-label">
            <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
               Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
            <div class="task-label">
                <span>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Result Open'"/>
                    </xsl:call-template>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' task/postreq ')]" mode="dita2html:section-heading">
        <xsl:if test="$insert-task-label">
            <!-- IA   Tridion upgrade    Oct-2018   Add support for DELL 'task-label' othermeta parameter.
                  Do not add task labels ONLY if 'task-labels' <othermeta> value equal 'no'.  - IB-->
            <div class="task-label">
                <span>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Postrequisite Open'"/>
                    </xsl:call-template>
                </span>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' hi-d/u ')]" name="topic.hi-d.u">
        <span>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setidaname"/>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="*[contains(@class,' hi-d/b ')]" name="topic.hi-d.b">
        <!--<strong>-->
            <!--<xsl:call-template name="commonattributes"/>-->
            <!--<xsl:call-template name="setidaname"/>-->
            <xsl:apply-templates/>
        <!--</strong>-->
    </xsl:template>

</xsl:stylesheet>
