<?xml version="1.0" encoding="UTF-8"?>
<!-- UPDATES: 20100524: SF Bug 2385466, disallow font-family="inherit" due to
                        lack of support in renderers. -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:opentopic-i18n="http://www.idiominc.com/opentopic/i18n"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    exclude-result-prefixes="opentopic-i18n">

    <xsl:import href="plugin:org.dita.base:xsl/common/output-message.xsl"/>

    <xsl:param name="debug-enabled" select="'false'"/>
    <xsl:variable name="msgprefix" select="'PDFX'"/>

    <xsl:variable name="font-mappings-lang">
        <!--   Intelliarts Consulting   DellEMC Rebranding    18-Nov-2016   Remove language value from font-mapping filename after all font-mapping files were merged to one.   - IB-->
        <!--
                <xsl:choose>
                    <xsl:when test="lower-case(/descendant-or-self::*[@xml:lang][1]/@xml:lang) = 'cs'">-cs</xsl:when>
                    &lt;!&ndash; EMC	IB4		29-Apr-2014		Added new font-mappings file for Russian language &ndash;&gt;
                    <xsl:when test="lower-case(/descendant-or-self::*[@xml:lang][1]/@xml:lang) = 'ru'">-ru</xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
        -->
    </xsl:variable>
    <xsl:variable name="font-mappings" select="document(concat('cfg:fo/font-mappings',$font-mappings-lang,'.xml'))/font-mappings"/>
    <xsl:variable name="default-font" select="$font-mappings/font-table/aliases/alias[. = 'Normal']/@name"/>

    <xsl:variable name="lang" select="/descendant::*[@xml:lang][1]/@xml:lang"/>

    <xsl:template match="fo:bookmark | fo:bookmark-label | fo:bookmark-title" priority="+10">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="fo:bookmark//opentopic-i18n:text-fragment" priority="+10">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template match="*[@font-family][not(@font-family='inherit')]" priority="+1">
        <xsl:variable name="currFontFam" select="@font-family"/>
        <xsl:variable name="realFontName">
            <xsl:choose>
                <xsl:when test="$font-mappings/font-table/logical-font[@name=$currFontFam]">
                    <xsl:value-of select="$currFontFam"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--Try search this name within font aliases-->
                    <xsl:variable name="aliasValue" select="$font-mappings/font-table/aliases/alias[@name=$currFontFam]/."/>
                    <xsl:if test="not($aliasValue)">
                        <xsl:call-template name="output-message">
                            <xsl:with-param name="msgnum">008</xsl:with-param>
                            <xsl:with-param name="msgsev">W</xsl:with-param>
                            <xsl:with-param name="msgparams">%1=<xsl:value-of select="$currFontFam"/></xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:value-of select="$aliasValue"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <!--   Intelliarts Consulting   DellEMC Rebranding    28-Nov-2016   Add using of 'default' <physical-font> for EN-US content regardless of publication language.   - IB-->
        <xsl:variable name="logical-font" select="$font-mappings/font-table/logical-font[@name = normalize-space($realFontName)]"/>
        <xsl:variable name="phys-font" select="$logical-font/physical-font[@char-set = 'default']"/>

        <xsl:variable name="physical-font-family">
            <xsl:variable
                name="font"
                select="$phys-font/font-face"/>
            <xsl:choose>
                <xsl:when test="$font">
                    <xsl:value-of select="$font"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default-font"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$debug-enabled = 'true'">
            <xsl:comment>
            currFontFam  = <xsl:value-of select="$currFontFam"/>
            realFontName = <xsl:value-of select="$realFontName"/>
            physFontFam  = <xsl:value-of select="normalize-space($physical-font-family)"/>
        </xsl:comment>
        </xsl:if>
        <xsl:copy>
            <xsl:copy-of select="@*[not(name() = 'font-family')]"/>
            <xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
            <xsl:attribute name="font-family"><xsl:value-of select="normalize-space($physical-font-family)"/></xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="*[opentopic-i18n:text-fragment]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="line-height-shift-adjustment">disregard-shifts</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="fo:instream-foreign-object//opentopic-i18n:text-fragment" priority="100">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="opentopic-i18n:text-fragment">
        <xsl:variable name="fontFace" select="ancestor::*[@font-family][not(@font-family = 'inherit')][1]/@font-family"/>
        <xsl:variable name="charSet" select="@char-set"/>

        <xsl:variable name="realFontName">
            <xsl:choose>
                <xsl:when test="$font-mappings/font-table/logical-font[@name=$fontFace]">
                    <xsl:value-of select="$fontFace"/>
                </xsl:when>
                <xsl:otherwise>
                    <!--Try search this name within font aliases-->
                    <xsl:variable name="aliasValue" select="$font-mappings/font-table/aliases/alias[@name=$fontFace]/."/>
                    <xsl:if test="not($aliasValue)">
                        <xsl:call-template name="output-message">
                            <xsl:with-param name="msgnum">008</xsl:with-param>
                            <xsl:with-param name="msgsev">W</xsl:with-param>
                            <xsl:with-param name="msgparams">%1=<xsl:value-of select="$fontFace"/></xsl:with-param>
                        </xsl:call-template>
                    </xsl:if>
                    <xsl:value-of select="$aliasValue"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="logical-font" select="$font-mappings/font-table/logical-font[@name = normalize-space($realFontName)]"/>
        <xsl:variable name="phys-font.charset">
            <xsl:choose>
                <xsl:when test="$logical-font/physical-font[@char-set = $charSet]">
                    <xsl:value-of select="$charSet"/>
                </xsl:when>
                <xsl:otherwise>default</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="phys-font" select="$logical-font/physical-font[@char-set = $phys-font.charset]"/>

        <xsl:variable name="font-style" select="$phys-font/font-style"/>
        <xsl:variable name="baseline-shift" select="$phys-font/baseline-shift"/>
        <xsl:variable name="override-size" select="$phys-font/override-size"/>

        <xsl:variable name="physical-font-family">
            <xsl:variable
                name="font"
                select="$phys-font/font-face"/>
            <xsl:choose>
                <xsl:when test="$font">
                    <xsl:value-of select="$font"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default-font"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$debug-enabled = 'true'">
            <xsl:comment>
          currFontFam = <xsl:value-of select="$fontFace"/>
          physFontFam = <xsl:value-of select="normalize-space($physical-font-family)"/>
        </xsl:comment>
        </xsl:if>
        <fo:inline line-height="100%">
            <xsl:attribute name="font-family"><xsl:value-of select="normalize-space($physical-font-family)"/></xsl:attribute>

            <xsl:if test="$font-style">
                <xsl:attribute name="font-style"><xsl:value-of select="normalize-space($font-style)"/></xsl:attribute>
            </xsl:if>

            <xsl:if test="$baseline-shift">
                <xsl:attribute name="baseline-shift"><xsl:value-of select="normalize-space($baseline-shift)"/></xsl:attribute>
            </xsl:if>

            <xsl:if test="$override-size">
                <xsl:attribute name="font-size"><xsl:value-of select="normalize-space($override-size)"/></xsl:attribute>
            </xsl:if>

            <xsl:apply-templates/>

        </fo:inline>

    </xsl:template>

    <xsl:template match="*" priority="-1">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="@*|comment()|processing-instruction()" priority="-1">
        <xsl:copy />
    </xsl:template>

    <!-- XEP doesn't like to see font-family="inherit", though it's allowed by the XSLFO spec. -->
    <xsl:template match="@font-family[. = 'inherit']"/>

</xsl:stylesheet>

