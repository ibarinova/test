<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                exclude-result-prefixes="related-links">

    <xsl:param name="OUTFORMAT">troff</xsl:param>

    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <text> element with specified wrap
                                        attribute starts here    IB-->

    <xsl:template match="text[@wrap = 'brackets']">
        <xsl:call-template name="insert-text-brackets"/>
        <xsl:choose>
            <xsl:when test="parent::block">
                <xsl:apply-templates select="following-sibling::*[1]"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text[@wrap = 'brackets']" mode="text-in-block">
        <xsl:call-template name="insert-text-brackets"/>
        <xsl:apply-templates select="following-sibling::*[1]" mode="text-in-block"/>
    </xsl:template>

    <xsl:template name="insert-text-brackets">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
    </xsl:template>

    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <text> element with specified wrap
                                        attribute ends here    IB-->

    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <text> element with specified style
                                        attribute starts here    IB-->
    <xsl:template name="format-text">
        <xsl:param name="current-style" select="'normal'"/>
        <xsl:choose>
            <xsl:when test="not(@style)">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@style='bold'">
                <xsl:call-template name="start-bold"/>
                <xsl:apply-templates>
                    <xsl:with-param name="current-style" select="'bold'"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="@style='italics'">
                <xsl:call-template name="start-italics"/>
                <xsl:apply-templates>
                    <xsl:with-param name="current-style" select="'italics'"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     added italic-bold text style    IB-->
            <xsl:when test="contains(@style,'italics') and contains(@style,'bold')">
                <xsl:call-template name="start-italics-bold"/>
                <xsl:apply-templates>
                    <xsl:with-param name="current-style" select="'italics bold'"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="@style='underlined'">
                <xsl:call-template name="start-underlined"/>
                <xsl:apply-templates>
                    <xsl:with-param name="current-style" select="'underlined'"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <sub> element's style
                                                starts here    IB-->
            <xsl:when test="@style='sub'">
                <xsl:call-template name="start-sub"/>
                <xsl:apply-templates/>
                <xsl:call-template name="end-sub"/>
            </xsl:when>
            <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <sup> element's style
                                                starts here    IB-->
            <xsl:when test="@style='sup'">
                <xsl:call-template name="end-sub"/>
                <xsl:apply-templates/>
                <xsl:call-template name="start-sub"/>
            </xsl:when>
            <xsl:when test="@style='tt'">
                <xsl:call-template name="start-tt"/>
                <xsl:apply-templates>
                    <xsl:with-param name="current-style" select="'tt'"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        <!-- If there was a style, return to original style -->
        <xsl:if test="@style='bold' or @style='italics' or @style='underlined' or @style='tt'">
            <xsl:choose>
                <xsl:when test="$current-style='bold'">
                    <xsl:call-template name="start-bold"/>
                </xsl:when>
                <xsl:when test="$current-style='italics'">
                    <xsl:call-template name="start-italics"/>
                </xsl:when>
                <xsl:when test="$current-style='underlined'">
                    <xsl:call-template name="start-underlined"/>
                </xsl:when>
                <xsl:when test="$current-style='tt'">
                    <xsl:call-template name="start-tt"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="start-normal"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="contains(@style,'italics') and contains(@style,'bold')">
            <xsl:choose>
                <xsl:when test="$current-style = 'italics bold'">
                    <xsl:call-template name="end-italics-bold"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="start-normal"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template name="start-italics-bold">
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'"/>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">\fB\fI</xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="end-italics-bold">
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'"/>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">\fR</xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="start-sub">
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'"/>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">\d</xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="end-sub">
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'"/>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">\u</xsl:when>
        </xsl:choose>
    </xsl:template>
    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <text> element with specified
                                        style attribute ends here.    IB-->

    <xsl:template match="section">
        <xsl:choose>
            <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <section> element with
                                                specified xtrc attribute starts here    IB-->
            <xsl:when test="contains(@xtrc, 'cli_body') or contains(@xtrc, 'cli_syntax') or contains(@xtrc, 'cli_prereq')
                            or contains(@xtrc, 'cli_description') or contains(@xtrc, 'cli_postreq') or contains(@xtrc, 'cli_args')
                            or contains(@xtrc, 'cli_options') or contains(@xtrc, 'cli_params') or contains(@xtrc, 'cli_backend_output')
                            or contains(@xtrc, 'cli_example') or contains(@xtrc, 'example') or contains(@xtrc, 'refsyn')
                            or contains(@xtrc, 'properties') or contains(@xtrc, 'section') or contains(@xtrc, 'result')
                            or contains(@xtrc, 'steps') or contains(@xtrc, 'prereq') or contains(@xtrc, 'postreq')">
                <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     Added 'cli-customization' mode to avoid
                                                    conflicts with DITA-OT transformation   IB-->
                <xsl:choose>
                    <xsl:when test="sectiontitle">
                        <xsl:apply-templates select="child::*[1]" mode="cli-customization"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="preceding-sibling::*">
                            <xsl:call-template name="force-two-newlines"/>
                        </xsl:if>
                        <xsl:apply-templates select="*[1]" mode="cli-customization"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="sectiontitle">
                        <xsl:apply-templates select="sectiontitle[1]"/>
                        <xsl:apply-templates select="(text|block)[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:if test="preceding-sibling::*">
                            <xsl:call-template name="force-two-newlines"/>
                        </xsl:if>
                        <xsl:apply-templates select="*[1]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="following-sibling::*[1]"/>
    </xsl:template>

    <xsl:template match="section/section" mode="cli-customization">
        <xsl:call-template name="force-two-newlines"/>
        <xsl:apply-templates select="*[1]"/>
        <xsl:apply-templates select="following-sibling::*[1]" mode="cli-customization"/>
    </xsl:template>

    <xsl:template match="sectiontitle" mode="cli-customization">
        <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <sectiontitle> element
                                            starts here    IB-->
        <xsl:choose>
            <xsl:when test="parent::*[contains(@xtrc, 'section')] or self::*[contains(@xtrc, 'title')]">
                <xsl:choose>
                    <xsl:when test="$OUTFORMAT='plaintext'">
                        <xsl:call-template name="force-two-newlines"/>
                        <xsl:apply-templates/>
                    </xsl:when>
                    <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">
                        <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     commented following code because
                                                            <sectiontitle> without specified <section> xtrc attribute
                                                            shouldn't have .SH title (only bold style).
                        <xsl:value-of select="$newline"/>.SH "<xsl:apply-templates/>"<xsl:value-of select="$newline"/>-->
                        <xsl:call-template name="force-two-newlines"/>
                        <xsl:call-template name="start-bold"/>
                        <xsl:apply-templates>
                            <xsl:with-param name="current-style" select="'bold'"/>
                        </xsl:apply-templates>
                        <xsl:call-template name="start-normal"/>
                    </xsl:when>
                    <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="insert-section-header"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:apply-templates select="following-sibling::*[1]" mode="cli-customization"/>
    </xsl:template>

    <xsl:template match="sectiontitle">
        <!-- Intelliarts Consulting/EMC     Troff01     01-aug-2013     The code to process topic title
                                            starts here    IB-->
        <xsl:call-template name="insert-topic-header"/>
        <xsl:call-template name="insert-section-header"/>
        <xsl:apply-templates select="following-sibling::*[1]"/>
    </xsl:template>

    <xsl:template match="block[contains(@xtrc, 'refbody')]">
        <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process reference body <block> element
                                            starts here    IB-->
        <xsl:choose>
            <xsl:when test="sectiontitle">
                <xsl:apply-templates select="child::*[1]" mode="cli-customization"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="preceding-sibling::*">
                    <xsl:call-template name="force-two-newlines"/>
                </xsl:if>
                <xsl:apply-templates select="*[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="following-sibling::*[1]"/>
    </xsl:template>

    <xsl:template match="block[preceding-sibling::sectiontitle]" mode="cli-customization">
        <xsl:variable name="thisLeadin">
            <xsl:if test="@leadin and (not(*) or *[1][self::block|section])">
                <xsl:value-of select="@leadin"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="leadinWithIndent">
            <xsl:if test="normalize-space($thisLeadin)">
                <xsl:apply-templates select="ancestor::*[@indent]" mode="find-indent"/>
                <xsl:value-of select="$thisLeadin"/>
                <xsl:value-of select="$newline"/>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains(@xtrc, 'codeblock') or contains(@xtrc, 'msgblock')">
                <!-- Intelliarts Consulting/EMC     Troff01     26-jul-2013     The code to process <codeblock> and
                                                    <msgblock> elements (in the reference topic) starts here  IB-->
                <xsl:if test="preceding-sibling::*">
                    <xsl:call-template name="force-two-newlines"/>
                </xsl:if>
                <xsl:call-template name="center-this-block"/>
                <xsl:value-of select="$leadinWithIndent"/>
                <xsl:call-template name="preserve-space"/>
                <xsl:call-template name="UN-center-this-block"/>
                <xsl:call-template name="force-two-newlines"/>
            </xsl:when>
            <xsl:when test="self::*[contains(@xml:space, 'preserve')][@type = 'screen']">
                <!-- Intelliarts Consulting/EMC     Troff01   06-aug-2013     The code to process <screen> element starts here  IB-->
                <xsl:call-template name="force-two-newlines"/>
                <xsl:call-template name="preserve-screen-space"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="force-two-newlines"/>
                <xsl:apply-templates select="*[1]"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="following-sibling::*[1]" mode="cli-customization"/>
    </xsl:template>

    <xsl:template name="preserve-screen-space">
        <xsl:param name="string" select="."/>
        <xsl:param name="addIndent">
            <xsl:choose>
                <xsl:when test="@expanse='page'"/>  <!-- Ignore any active indent -->
                <!-- Otherwise, start with the indent on the current element -->
                <xsl:otherwise>
                    <xsl:apply-templates select="ancestor-or-self::*[@indent]" mode="find-indent"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:param>
        <xsl:choose>
            <xsl:when test="string-length($string)=0"/>
            <xsl:when test="contains($string,$newline)">
                <xsl:variable name="substring-before" select="substring-before($string,$newline)" />
                <xsl:variable name="substring-before-length" select="string-length(normalize-space($substring-before))" />
                <xsl:variable name="substring-after" select="substring-after($string,$newline)" />
                <xsl:variable name="substring-after-length" select="string-length(normalize-space($substring-after))" />
                <xsl:value-of select="$addIndent"/>
                <xsl:if test="$substring-before-length &gt; 0 ">
                    <xsl:value-of select="$substring-before"/>
                </xsl:if>
                <xsl:if test="$substring-before-length &gt; 0 and $substring-after-length &gt; 0">
                    <xsl:call-template name="force-newline"/>
                </xsl:if>
                <xsl:if test="$substring-after-length &gt; 0">
                    <xsl:call-template name="preserve-screen-space">
                        <xsl:with-param name="string" select="$substring-after"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$addIndent"/>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text[preceding-sibling::sectiontitle]" mode="cli-customization">
        <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <text> element starts here  IB-->
        <xsl:param name="current-style"/>
        <xsl:variable name="upToBlock">
            <xsl:call-template name="format-text">
                <xsl:with-param name="current-style" select="$current-style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
            <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <text> element starts here  IB-->
            <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     added enclosing in brackets  IB-->
            <xsl:when test="@wrap = 'brackets'">
                <xsl:call-template name="insert-text-brackets"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="wrap">
                    <xsl:with-param name="string" select="normalize-space($upToBlock)"/>
                    <xsl:with-param name="leadin">
                        <xsl:if test="../@leadin">
                            <xsl:if test="not(preceding-sibling::*)">
                                <xsl:value-of select="../@leadin"/>
                            </xsl:if>
                        </xsl:if>
                    </xsl:with-param>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="following-sibling::*[1]" mode="cli-customization"/>
    </xsl:template>

    <xsl:template match="text[contains(@xtrc, 'title')][preceding-sibling::sectiontitle]">
        <!-- Intelliarts Consulting/EMC     Troff01     02-aug-2013     The code to process topic title starts here  IB-->
        <xsl:param name="current-style"/>
        <xsl:variable name="upToBlock">
            <xsl:call-template name="format-text">
                <xsl:with-param name="current-style" select="$current-style"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:call-template name="wrap">
            <xsl:with-param name="string" select="normalize-space($upToBlock)"/>
            <xsl:with-param name="leadin">
                <xsl:if test="../@leadin">
                    <xsl:if test="not(preceding-sibling::*)">
                        <xsl:value-of select="../@leadin"/>
                    </xsl:if>
                </xsl:if>
            </xsl:with-param>
        </xsl:call-template>
        <xsl:apply-templates select="following-sibling::*[1]"/>
    </xsl:template>

    <xsl:template match="text[string-length(normalize-space(.)) &lt; 1][preceding-sibling::*[1][contains(@xtrc, 'substeps')]]">
        <!-- Intelliarts Consulting/EMC     Troff01     01-aug-2013     Excluding extra line after <substeps> element  IB-->
    </xsl:template>

    <xsl:template name="insert-section-header">
        <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     Inserting specified section header  IB-->
        <xsl:if test="preceding-sibling::*">
            <xsl:call-template name="force-two-newlines"/>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'">
                <xsl:call-template name="force-two-newlines"/>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">
                <xsl:value-of select="$newline"/><text>.SH </text>
                <xsl:apply-templates/>
                <xsl:value-of select="$newline"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="insert-topic-header">
        <!-- Intelliarts Consulting/EMC     Troff01     02-aug-2013     Inserting topic header  IB-->
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'">
                <xsl:call-template name="force-two-newlines"/>
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">
                <xsl:value-of select="$newline"/><text>.TH &#34;</text>
                <xsl:value-of select="following-sibling::text[1]" />
                <text>&#34;</text>
		<!-- EMC    25-oct-2013     Remove hyphens-->
				<xsl:value-of select="$newline"/><text>.nh</text>
		<!-- End of Remove hyphens-->
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="set-default-linelength">
        <!-- Intelliarts Consulting/EMC Troff01 11-jul-2013 Change the default line length from 72 to 80. IB-->
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'"><xsl:value-of select="$newline"/></xsl:when>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">
                <xsl:value-of select="$newline"/>.ll 80<xsl:value-of select="$newline"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- Intelliarts Consulting/EMC     Troff01     29-jul-2013     The code to process bridge topics starts here  IB-->
    <xsl:template match="block[not(@xtrc)]/block[not(@xtrc)][@indent = '3'][child::*[@compact = 'yes']]">
        <xsl:call-template name="process-bridges"/>
    </xsl:template>

    <xsl:template name="process-bridges">
        <xsl:if test="preceding-sibling::*">
            <xsl:call-template name="force-two-newlines"/>
        </xsl:if>
        <xsl:apply-templates select="*[1]" mode="process-bridges"/>
        <xsl:apply-templates select="following-sibling::*[1]" mode="process-bridges"/>
    </xsl:template>

    <xsl:template match="block[@compact = 'yes']" mode="process-bridges">
        <xsl:if test="preceding-sibling::*">
            <xsl:value-of select="$newline"/>
        </xsl:if>
        <xsl:value-of select="'*'"/>
        <xsl:apply-templates select="ancestor::*[@indent][1]" mode="find-indent"/>
        <xsl:apply-templates mode="process-bridges"/>
    </xsl:template>

    <xsl:template match="text" mode="process-bridges">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="block[@indent = '3']" mode="process-bridges">
        <xsl:call-template name="process-bridges"/>
    </xsl:template>
    <!-- Intelliarts Consulting/EMC     Troff01     29-jul-2013     The code to process bridge topics ends here  IB-->

    <xsl:template name="force-two-newlines">
        <!-- Intelliarts Consulting/EMC     Troff01     31-jul-2013     Changed '.sp 2' to '.sp'  IB-->
        <xsl:choose>
            <xsl:when test="$OUTFORMAT='plaintext'"><xsl:value-of select="$newline"/><xsl:value-of select="$newline"/></xsl:when>
            <xsl:when test="$OUTFORMAT='troff' or $OUTFORMAT='nroff'">
                <xsl:value-of select="$newline"/>.sp<xsl:value-of select="$newline"/>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
