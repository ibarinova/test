<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                exclude-result-prefixes="related-links">

    <xsl:output use-character-maps="characters"/>

    <xsl:character-map name="characters">
        <!-- Intelliarts Consulting/EMC     Troff01     02-aug-2013
                                            Added character map for replacing extended ASCII characters    IB-->
        <!-- apostrophes -->
        <xsl:output-character character="&#96;" string="&#39;"/>
        <xsl:output-character character="&#697;" string="&#39;"/>
        <xsl:output-character character="&#699;" string="&#39;"/>
        <xsl:output-character character="&#700;" string="&#39;"/>
        <xsl:output-character character="&#701;" string="&#39;"/>
        <xsl:output-character character="&#1370;" string="&#39;"/>
        <xsl:output-character character="&#8216;" string="&#39;"/>
        <xsl:output-character character="&#8217;" string="&#39;"/>
        <xsl:output-character character="&#8218;" string="&#39;"/>
        <xsl:output-character character="&#8219;" string="&#39;"/>

        <!-- quotation marks -->
        <xsl:output-character character="&#171;" string="&#34;"/>
        <xsl:output-character character="&#187;" string="&#34;"/>
        <xsl:output-character character="&#698;" string="&#34;"/>
        <xsl:output-character character="&#750;" string="&#34;"/>
        <xsl:output-character character="&#8220;" string="&#34;"/>
        <xsl:output-character character="&#8221;" string="&#34;"/>
        <xsl:output-character character="&#8222;" string="&#34;"/>
        <xsl:output-character character="&#8223;" string="&#34;"/>

        <!-- dashes, hyphens and minuses -->
        <xsl:output-character character="&#727;" string="&#45;"/>
        <xsl:output-character character="&#1418;" string="&#45;"/>
        <xsl:output-character character="&#8208;" string="&#45;"/>
        <xsl:output-character character="&#8209;" string="&#45;"/>
        <xsl:output-character character="&#8210;" string="&#45;"/>
        <xsl:output-character character="&#8211;" string="&#45;"/>
        <xsl:output-character character="&#8212;" string="&#45;"/>
        <xsl:output-character character="&#8213;" string="&#45;"/>
        <xsl:output-character character="&#8259;" string="&#45;"/>
        <xsl:output-character character="&#8275;" string="&#45;"/>
        <xsl:output-character character="&#8722;" string="&#45;"/>
    </xsl:character-map>

    <xsl:template match="*[contains(@class,' pr-d/var ')]">
        <xsl:choose>
            <xsl:when test="@importance='default'">
                <text style="italics">
                    <text style="underlined">
                        <xsl:call-template name="debug"/>
                        <xsl:apply-templates/>
                    </text>
                </text>
            </xsl:when>
            <xsl:otherwise>
                <!-- Intelliarts Consulting/EMC Troff01 11-jul-2013 The code to enclose <var> element in brackets starts here IB-->
                <!-- added new attribute wrap with value 'brackets'-->
                <text wrap="brackets">
                    <text style="italics">
                        <xsl:call-template name="debug"/>
                        <xsl:apply-templates/>
                    </text>
                </text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' sw-d/varname ')]">
        <!-- Intelliarts Consulting/EMC Troff01 11-jul-2013 The code to enclose <varname> element in brackets starts here IB-->
        <!-- added new attribute wrap with value 'brackets'-->
        <text wrap="brackets">
            <text style="italics">
                <xsl:call-template name="debug"/>
                <xsl:apply-templates/>
            </text>
        </text>
    </xsl:template>

    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     DITA-OT doesn't process correctly following DITA elements.
                                        The code to process <cmdname>, <filepath>, <wintitle>, <apiname>, <option>, <cite>,
                                         <term> elements in compliance with BRD starts here    IB-->
    <xsl:template match="*[contains(@class, ' sw-d/cmdname ')]">
        <text style="bold">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' sw-d/filepath ')]">
        <text style="bold">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' ui-d/wintitle ')]">
        <text style="bold">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' pr-d/apiname ')]">
        <text style="bold">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' pr-d/option ')]">
        <text style="bold italics">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/cite ')]">
        <text style="italics">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/term ')]">
        <!--added 'italic' style-->
        <text style="italics">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>
    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <cmdname>, <filepath>, <wintitle>,
                               <apiname>, <option>, <cite>, <term> elements in compliance with BRD ends here    IB-->

    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <cli_body> element starts here    IB-->
    <xsl:template match="*[contains(@class, 'cli_body')]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process <cli_syntax>, <refsyn>, <cli_prereq>,
                                        <cli_description>, <cli_postreq>, <cli_args>, <cli_options>, <cli_params>,
                                        <cli_backend_output>, <properties>, <cli_example>, <example>, <prereq>, <steps>,
                                        <result>, <postreq> elements starts here.
                                        Added specific section title for them. IB-->
    <xsl:template match="*[contains(@class, ' cli_reference/cli_syntax ') or contains(@class, ' reference/refsyn ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'SYNTAX'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_reference/cli_prereq ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'PREREQUISITE'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_reference/cli_description ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'DESCRIPTION'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_reference/cli_postreq ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'POSTREQUISITE'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_reference/cli_args ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'ARGUMENTS'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_reference/cli_options ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'OPTIONS'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/prereq ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'BEFORE YOU BEGIN'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/steps ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'PROCEDURE'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/result ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'RESULTS'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' task/postreq ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'AFTER YOU FINISH'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' reference/properties ')
                        and not(contains(@class, ' cli_reference/cli_options '))
                        and not(contains(@class, ' cli_reference/cli_args '))
                        and not(contains(@class, ' cli_reference/cli_params '))]">
        <!-- Intelliarts Consulting/EMC     Troff01     17-jul-2013     The code to process <properties> element starts here.
                                            Excluding processing of <properties> element. Added warning message into the
                                            log-file IB-->
        <xsl:message>: Warning! <properties/> element detected!</xsl:message>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_reference/cli_params ')]">
        <section>
            <xsl:call-template name="debug"/>

            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'PARAMETERS'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_reference/cli_backend_output ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'BACKEND OUTPUT'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' cli_example ') or contains(@class, ' topic/example ')]">
        <section>
            <xsl:call-template name="debug"/>
            <xsl:call-template name="generate-section-header">
                <xsl:with-param name="type" select="'EXAMPLE'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
        </section>
    </xsl:template>
    <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     The code to process section elements ends here. IB-->

    <xsl:template match="*[contains(@class,' topic/image ')]">
        <xsl:choose>
            <xsl:when test="@placement='break'">
                <block>
                    <xsl:call-template name="debug"/>
                    <text>
                        <xsl:call-template name="debug"/>
                        <xsl:call-template name="output-alt-text"/>
                    </text>
                </block>
            </xsl:when>
            <xsl:otherwise>
<!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013  Removed following part of code because of additional .sp2    IB
                <text>
                    <xsl:call-template name="debug"/>
                    <xsl:call-template name="output-alt-text"/>
                </text>
-->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Intelliarts Consulting/EMC     Troff01     12-jul-2013     The code to process <cli_option>, <cli_arg> and
                                            <cli_param> elements starts here    IB-->
    <xsl:template match="*[contains(@class, ' cli_reference/cli_option ')
                        or contains(@class, ' cli_reference/cli_arg ')
                        or contains(@class, ' cli_reference/cli_param ')]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class,' cli_reference/cli_option_value ')
                        or contains(@class,' cli_reference/cli_arg_value ')
                        or contains(@class,' cli_reference/cli_param_value ')]">
        <block>
            <xsl:call-template name="debug"/>
            <xsl:if test="preceding-sibling::*[1][contains(@class,' cli_reference/cli_option_value ')
                    or contains(@class,' cli_reference/cli_arg_value ')
                    or contains(@class,' cli_reference/cli_param_value ')]
                    or ancestor::*[2][@compact='yes']">
                <xsl:attribute name="compact">yes</xsl:attribute>
            </xsl:if>
            <text style="bold">
                <xsl:call-template name="debug"/>
                <xsl:apply-templates/>
            </text>
        </block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' cli_reference/cli_option_desc ')
                        or contains(@class,' cli_reference/cli_arg_desc ')
                        or contains(@class,' cli_reference/cli_param_desc ')]">
        <block indent="9" compact="yes">
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </block>
    </xsl:template>
    <!-- Intelliarts Consulting/EMC     Troff01     12-jul-2013     The code to process <cli_option>, <cli_arg> and
                                            <cli_param> elements ends here    IB-->

    <xsl:template name="generate-section-header">
        <!-- Intelliarts Consulting/EMC     Troff01     11-jul-2013     Adding specific <sectiontitle> to the <section>  IB-->
        <xsl:param name="type"/>
        <sectiontitle>
            <xsl:call-template name="debug"/>
            <text>
                <xsl:value-of select="$type"/>
            </text>
        </sectiontitle>
    </xsl:template>

    <xsl:template name="generate-topic-header">
        <!-- Intelliarts Consulting/EMC     Troff01     02-aug-2013     Processing topic header  IB-->
        <xsl:param name="type"/>
        <sectiontitle>
            <xsl:call-template name="debug"/>
            <text>
                <xsl:value-of select="$type"/>
            </text>
        </sectiontitle>
        <text>
            <xsl:call-template name="debug"/>
            <xsl:apply-templates/>
        </text>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/draft-comment ')]">
        <!-- Intelliarts Consulting/EMC     Troff01     23-jul-2013     The code to process <draft-comment> element     IB-->
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/table ') or contains(@class,' topic/simpletable ')]
                          [not(contains(@class, ' reference/properties '))]
                          [not(contains(@class, ' cli_reference/cli_options '))]
                          [not(contains(@class, ' cli_reference/cli_args '))]
                          [not(contains(@class, ' cli_reference/cli_params '))]">
        <!-- Intelliarts Consulting/EMC     Troff01     31-jul-2013     The code to process <table> element     IB-->
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
        <!-- Intelliarts Consulting/EMC     Troff01     02-aug-2013    Processing topic title  IB-->
        <xsl:call-template name="debug"/>
        <xsl:call-template name="generate-topic-header">
            <xsl:with-param name="type" select="'NAME'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' ui-d/screen ')]">
        <!-- Intelliarts Consulting/EMC     Troff01     06-aug-2013     Adding @type for screen element  IB-->
        <block xml:space="preserve" type="screen">
            <xsl:apply-templates/>
        </block>
    </xsl:template>

    <xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="ancestor::*[@xml:space='preserve'][not(contains(@class, ' ui-d/screen '))]">
                <text>
                    <xsl:value-of select="."/>
                </text>
            </xsl:when>
            <xsl:when test="ancestor::*[@xml:space='preserve'][contains(@class, ' ui-d/screen ')]">
                <!-- Intelliarts Consulting/EMC     Troff01     06-aug-2013     Adding line breaks to exclude spaces
                                                    at the begin of screen block  IB-->
                <text>
                    <xsl:value-of select="'&#10;'"/>
                    <xsl:value-of select="."/>
                </text>
            </xsl:when>
            <!-- If this string is only white-space, AND it is not between phrases, then drop it. -->
            <xsl:when test="string-length(normalize-space(.))=0">
                <xsl:variable name="siblingPhrase"><xsl:call-template name="CheckForPhraseSibling"/></xsl:variable>
                <xsl:if test="$siblingPhrase='yes'">
                    <text><xsl:value-of select="."/></text>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise><text><xsl:value-of select="."/></text></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
