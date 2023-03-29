<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                xmlns:opentopic-index="http://www.idiominc.com/opentopic/index"
                xmlns:isoi18n="java:com.isogen.saxoni18n.Saxoni18nService"
                exclude-result-prefixes="isoi18n opentopic-index"
                extension-element-prefixes="ot-placeholder"
                version="2.0">

    <xsl:variable name="lang">
        <xsl:call-template name="getGlossLanguage">
            <xsl:with-param name="param-lang" select="lower-case((//*[@xml:lang])[1]/@xml:lang)"/>
        </xsl:call-template>
    </xsl:variable>

    <!-- Language Specific variables for sorting and grouping -->
    <xsl:variable name="alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!#</xsl:variable>
    <xsl:variable name="ko-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ#</xsl:variable>
    <xsl:variable name="cs-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!#ÁCDÉEÍNÓRŠTÚUÝŽ</xsl:variable>
    <xsl:variable name="es-mx-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!#Ñ</xsl:variable>
    <xsl:variable name="zh-cn-alphabets">ABCDEFGHIJKLMNOPQRSTUVWXYZ0!#</xsl:variable>

    <!-- Language Specific Collation URL -->
    <xsl:variable name="collationUrl">
        <xsl:choose>
            <xsl:when test="$lang = 'ko'">http://saxon.sf.net/collation?lang=ko;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'de'">http://saxon.sf.net/collation?lang=de;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'fr'">http://saxon.sf.net/collation?lang=fr;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'it'">http://saxon.sf.net/collation?lang=it;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'cs'">http://saxon.sf.net/collation?lang=cs;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'ja'">http://saxon.sf.net/collation?lang=ja;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'ru'">http://saxon.sf.net/collation?lang=ru;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'es-mx'">http://saxon.sf.net/collation?lang=es-mx;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'pt-br'">http://saxon.sf.net/collation?lang=pt-br;strength=tertiary;</xsl:when>
            <xsl:when test="$lang = 'zh-cn'">http://saxon.sf.net/collation?class=com.emc.SimplifiedChineseComparator</xsl:when>
            <xsl:when test="$lang = 'zh-tw'">http://saxon.sf.net/collation?lang=zh-tw;strength=tertiary;</xsl:when>
            <xsl:otherwise>http://saxon.sf.net/collation?lang=en-us;strength=tertiary;</xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:key name="key-gloss"
             match="*[contains(@class, 'glossentry/glossentry')]"
             use="isoi18n:getIndexGroupKey($lang,
                                            isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                            normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"/>

    <xsl:template match="ot-placeholder:glossarylist" name="createGlossary">
        <fo:page-sequence master-reference="glossary-sequence" xsl:use-attribute-sets="page-sequence.glossary">
            <xsl:call-template name="insertGlossaryStaticContents"/>
            <fo:flow flow-name="xsl-region-body">
                <fo:marker marker-class-name="current-header">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Glossary'"/>
                    </xsl:call-template>
                </fo:marker>
                <xsl:choose>
                    <xsl:when test="$dell-brand = ('Non-brand', 'Alienware', 'RSA')">
                        <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.glossary}">
                            <fo:block xsl:use-attribute-sets="__toc__header_content">
                                <fo:bidi-override>
                                    <xsl:attribute name="direction">
                                        <xsl:choose>
                                            <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                            <xsl:otherwise>ltr</xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Glossary'" />
                                    </xsl:call-template>
                                </fo:bidi-override>
                            </fo:block>
                            <fo:block>
                                <fo:marker marker-class-name="current-header">
                                    <fo:bidi-override>
                                        <xsl:attribute name="direction">
                                            <xsl:choose>
                                                <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                                <xsl:otherwise>ltr</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'Glossary'" />
                                        </xsl:call-template>
                                    </fo:bidi-override>
                                </fo:marker>
                            </fo:block>
                        </fo:block>
                    </xsl:when>
                    <xsl:otherwise>
                        <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.glossary}">
                            <fo:marker marker-class-name="current-header">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'Glossary'"/>
                                </xsl:call-template>
                            </fo:marker>
                            <xsl:call-template name="insertBlueBarHeader">
                                <xsl:with-param name="content">
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'Glossary'" />
                                    </xsl:call-template>
                                </xsl:with-param>
                                <xsl:with-param name="type" select="'txt'"/>
                            </xsl:call-template>
                            <fo:block margin-top="11mm"/>
                        </fo:block>
                    </xsl:otherwise>
                </xsl:choose>

                <xsl:if test="*[1][not(contains(@class, 'glossentry/glossentry'))]">
                    <xsl:apply-templates select="*[1][not(contains(@class, 'glossentry/glossentry'))]/*[contains(@class, 'topic/body')]"/>
                </xsl:if>

                <xsl:choose>
                    <xsl:when test="$lang = 'ko'">
                        <xsl:call-template name="l10n-sort">
                            <xsl:with-param name="param-alpha">
                                <xsl:value-of select="$ko-alphabets"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <xsl:call-template name="en-sort">
                            <xsl:with-param name="param-alpha">
                                <xsl:value-of select="$ko-alphabets"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:when>
                    <!-- For ALL OTHER languages -->
                    <xsl:otherwise>
                        <!-- Special sorting of special characters and numbers for Simplified Chinese ONLY  -->
                        <xsl:choose>
                            <xsl:when test="$lang = 'zh-cn'">
                                <xsl:call-template name="l10n_special_number_sort">
                                    <xsl:with-param name="param-alpha">
                                        <xsl:value-of select="$zh-cn-alphabets"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                        </xsl:choose>
                        <!-- Special Sorting ends here-->

                        <xsl:call-template name="en-sort">
                            <xsl:with-param name="param-alpha">
                                <xsl:choose>
                                    <xsl:when test="$lang = 'cs'">
                                        <xsl:value-of select="$cs-alphabets"/>
                                    </xsl:when>
                                    <xsl:when test="$lang = 'es-mx'">
                                        <xsl:value-of select="$es-mx-alphabets"/>
                                    </xsl:when>
                                    <xsl:when test="$lang = 'zh-cn'">
                                        <xsl:value-of select="$zh-cn-alphabets"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$alphabets"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:with-param>
                        </xsl:call-template>

                        <xsl:choose>
                            <xsl:when test="$lang = 'zh-tw'">
                                <xsl:call-template name="l10n-zh_tw-sort">
                                    <xsl:with-param name="param-alpha">
                                        <xsl:value-of select="$alphabets"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:call-template name="l10n-sort">
                                    <xsl:with-param name="param-alpha">
                                        <xsl:choose>
                                            <xsl:when test="$lang = 'cs'">
                                                <xsl:value-of select="$cs-alphabets"/>
                                            </xsl:when>
                                            <xsl:when test="$lang = 'es-mx'">
                                                <xsl:value-of select="$es-mx-alphabets"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$alphabets"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:flow>
        </fo:page-sequence>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' glossentry/glossentry ')][ancestor::*[contains(@class, ' glossentry/glossentry ')]]" priority="10">
        <xsl:message>ERROR: nested gloss "<xsl:value-of select="normalize-space(*[contains(@class, ' glossentry/glossterm ')])"/>" entry will not be processed.</xsl:message>
    </xsl:template>

    <xsl:template match="ot-placeholder:glossarylist//*[contains(@class, ' glossentry/glossentry ')]" priority="10">
        <fo:block id="{@id}">
            <fo:block>
                <xsl:attribute name="id">
                    <xsl:call-template name="generate-toc-id"/>
                </xsl:attribute>
                <xsl:if test="lower-case($include-metadata) = 'yes'">
                    <xsl:call-template name="insert-pubmeta-data"/>
                </xsl:if>
                <fo:block>
                    <xsl:apply-templates select="*[contains(@class, ' glossentry/glossterm ')]/node()"/>
                    <xsl:variable name="glossAbbr" select="descendant::*[contains(@class, ' glossentry/glossAbbreviation ')]/node()"/>
                    <xsl:if test="normalize-space($glossAbbr) != ''">
                        <xsl:text> (</xsl:text>
                        <xsl:value-of select="$glossAbbr"/>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </fo:block>
                <fo:block>
                    <xsl:apply-templates select="*[contains(@class, ' glossentry/glossdef ')]/node()"/>
                </fo:block>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' glossentry/glossentry ')]/*[contains(@class, ' glossentry/glossBody ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' glossentry/glossentry ')]/*[contains(@class, ' topic/prolog ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' glossentry/glossentry ')]//*[contains(@class, ' glossentry/glossSynonym ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' glossentry/glossentry ')]//*[contains(@class, ' glossentry/glossAlt ')]" priority="10"/>

    <xsl:template name="glossary-label-group">
        <xsl:param name="param-position"/>
        <xsl:param name="param-glossterm"/>
        <!-- Display the Glossary Label only for the first entry of the key group -->
        <xsl:if test="$param-position = 1">
            <fo:block xsl:use-attribute-sets="__glossary__letter-block">
                <xsl:variable name="groupLabel" select="isoi18n:getIndexGroupLabel($lang, isoi18n:getIndexGroupKey($lang, $param-glossterm))[1]"/>
                <xsl:choose>
                    <xsl:when test="lower-case($groupLabel) = '#numeric'">
                        <xsl:value-of select="'Special Terms'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$groupLabel"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:block>
        </xsl:if>

        <xsl:apply-templates/>
    </xsl:template>

    <!-- Sorting based on the group sort key for english language -->
    <xsl:template name="en-sort">
        <xsl:param name="param-alpha"/>

        <xsl:for-each select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
            <xsl:sort select="isoi18n:getIndexGroupKey($lang,
                                                    isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                                            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                                            normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"
                      collation="{$collationUrl}"/>

            <xsl:for-each select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">
                <xsl:sort select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                                normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                                normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
                        collation="{$collationUrl}"/>

                <xsl:variable name="eng-letter-label">
                    <xsl:value-of select="translate(isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))), $param-alpha, '')"/>
                </xsl:variable>

                <xsl:if test="$eng-letter-label = ''">
                    <xsl:call-template name="glossary-label-group">
                        <xsl:with-param name="param-position" select="position()"/>
                        <xsl:with-param name="param-glossterm" select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- Sorting based on the group Label for localized language -->
    <xsl:template name="l10n-sort">
        <xsl:param name="param-alpha"/>

        <xsl:for-each select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
            <xsl:sort select="isoi18n:getIndexGroupLabel($lang,
                                                isoi18n:getIndexGroupKey($lang,
                                                                    isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                                                                normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                                                                normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))"
                        collation="{$collationUrl}"/>

            <xsl:for-each select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">

                <xsl:sort select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                                normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                                normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
                            collation="{$collationUrl}"/>

                <xsl:variable name="eng-letter-label">
                    <xsl:value-of select="translate(isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))), $param-alpha, '')"/>
                </xsl:variable>
                <xsl:if test="$eng-letter-label != ''">
                    <xsl:call-template name="glossary-label-group">
                        <xsl:with-param name="param-position" select="position()"/>
                        <xsl:with-param name="param-glossterm" select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- Sorting based on the group Sort Key for Traditional Chinese language -->
    <xsl:template name="l10n-zh_tw-sort">
        <xsl:param name="param-alpha"/>

        <xsl:for-each select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
            <xsl:sort select="isoi18n:getIndexGroupKey($lang,
                                                    isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                                            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                                            normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"
                        collation="{$collationUrl}"/>

            <xsl:for-each select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">

                <xsl:sort select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                            normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"
                            collation="{$collationUrl}"/>
                <xsl:variable name="eng-letter-label">
                    <xsl:value-of select="translate(isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))), $param-alpha, '')"/>
                </xsl:variable>
                <xsl:if test="$eng-letter-label != ''">
                    <xsl:call-template name="glossary-label-group">
                        <xsl:with-param name="param-position" select="position()"/>
                        <xsl:with-param name="param-glossterm" select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>

    <!-- For Simplified Chinese, the numbers should be sorted first and then the special characters. Hence, adding space infront of numbers -->
    <xsl:template name="l10n_special_number_sort">
        <xsl:param name="param-alpha"/>

        <xsl:for-each select="//*[contains(@class, ' glossentry/glossentry ') and generate-id(.) = generate-id(key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))[1])]">
            <xsl:sort select="isoi18n:getIndexGroupKey($lang,
                                                    isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                                        normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                                        normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"
                        collation="{$collationUrl}"/>

            <xsl:if test="' ' = isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')])))">
                <xsl:for-each select="key('key-gloss', isoi18n:getIndexGroupKey($lang, isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))))">
                    <xsl:sort select="isoi18n:formatGlossaryString(isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]),
                                                                                            normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]),
                                                                                            normalize-space(*[contains(@class, ' glossentry/glossterm ')])))"/>

                    <xsl:call-template name="glossary-label-group">
                        <xsl:with-param name="param-position" select="position()"/>
                        <xsl:with-param name="param-glossterm" select="isoi18n:glossarySortString(normalize-space(*[contains(@class, ' glossentry/gloss-sort-as ')]), normalize-space(*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]), normalize-space(*[contains(@class, ' glossentry/glossterm ')]))"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="getGlossLanguage">
        <xsl:param name="param-lang"/>
        <xsl:variable name="glossLang">
            <xsl:value-of select="translate($param-lang, '_', '-')"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="starts-with($glossLang, 'zh') or starts-with($glossLang, 'en') or starts-with($glossLang, 'es') or starts-with($glossLang, 'pt')">
                <xsl:value-of select="$glossLang"/>
            </xsl:when>
            <xsl:when test="contains($glossLang, '-')">
                <xsl:value-of select="substring-before($glossLang, '-')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$glossLang"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' glossentry/glossterm ')]">
        <fo:block xsl:use-attribute-sets="__glossary__term">
            <xsl:apply-templates select="../*[contains(@class, ' topic/prolog ')]//opentopic-index:index.entry[not(parent::opentopic-index:index.entry)]"/>
            <xsl:choose>
                <xsl:when test="normalize-space(following-sibling::*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]) != ''">
                    <xsl:value-of select="following-sibling::*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' glossentry/glossdef ')]">
        <fo:block xsl:use-attribute-sets="__glossary__def">
            <xsl:apply-templates/>
            <xsl:for-each select="following-sibling::*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossAlt ')]/*[contains(@class, ' glossentry/glossSynonym ')]">
                <xsl:if test="normalize-space(.) != ''">
                    <fo:block xsl:use-attribute-sets="__glossary__synonym">
                        <fo:inline xsl:use-attribute-sets="__glossary__bold">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'Index See Also String'"/>
                            </xsl:call-template>
                        </fo:inline>
                        <xsl:value-of select="normalize-space(.)"/>
                    </fo:block>
                </xsl:if>
            </xsl:for-each>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ')][@type = 'glossentry'][ancestor::*[contains(@class, ' glossentry/glossdef ')]]">
        <xsl:variable name="refid">
            <xsl:choose>
                <xsl:when test="contains(@href, '#')">
                    <xsl:value-of select="substring-after(@href, '#')"/>
                </xsl:when>
                <xsl:when test="contains(@href, '/')">
                    <xsl:value-of select="substring-after(@href, '/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$lang = 'ko' or $lang = 'ja'"><!-- Do nothing --></xsl:when>
            <xsl:otherwise>
                <fo:inline xsl:use-attribute-sets="__glossary__bold">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Index See String'"/>
                    </xsl:call-template>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>

        <fo:basic-link xsl:use-attribute-sets="__glossary__link">
            <xsl:attribute name="internal-destination" select="$refid"/>
            <fo:inline>
                <xsl:choose>
                    <xsl:when test="normalize-space(//*[@id = $refid]/*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]) != ''">
                        <xsl:value-of select="//*[@id = $refid]/*[contains(@class, ' glossentry/glossBody ')]/*[contains(@class, ' glossentry/glossSurfaceForm ')]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="//*[@id = $refid]/*[contains(@class, ' glossentry/glossterm ')]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:inline>
        </fo:basic-link>

        <xsl:if test="$lang = 'ko' or $lang = 'ja'">
            <fo:inline xsl:use-attribute-sets="__glossary__bold">
                <xsl:call-template name="getVariable">
                    <xsl:with-param name="id" select="'Index See String'"/>
                </xsl:call-template>
            </fo:inline>
        </xsl:if>
    </xsl:template>

    <!-- For Simplified Chinese, check if the first char is number. If yes, append space -->
    <xsl:function name="isoi18n:formatGlossaryString">
        <xsl:param name="glossaryText"/>

        <xsl:variable name="firstchar">
            <xsl:value-of select="substring($glossaryText, 1, 1)"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="contains('0123456789', $firstchar)">
                <xsl:value-of select="concat(' ', $glossaryText)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$glossaryText"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- The precedence for sort string is gloss-sort-as, glossSurfaceForm, glossTerm (in that order, whichever comes first)-->
    <xsl:function name="isoi18n:glossarySortString">
        <xsl:param name="glossSortAs"/>
        <xsl:param name="glossSrfFrm"/>
        <xsl:param name="glossTerm"/>

        <xsl:choose>
            <xsl:when test="$glossSortAs != ''">
                <xsl:value-of select="$glossSortAs"/>
            </xsl:when>
            <xsl:when test="$glossSrfFrm != ''">
                <xsl:value-of select="$glossSrfFrm"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$glossTerm"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
