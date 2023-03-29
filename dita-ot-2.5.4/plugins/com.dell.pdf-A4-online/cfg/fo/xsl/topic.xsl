<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:template match="*[contains(@class,' topic/fig ')]">
        <fo:block xsl:use-attribute-sets="fig">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="setFrame"/>
            <xsl:call-template name="setExpanse"/>
            <xsl:if test="not(@id)">
                <xsl:attribute name="id">
                    <xsl:call-template name="get-id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="*[contains(@class, ' topic/image ')]"/>
        </fo:block>
        <xsl:if test="not(($dell-brand = 'Non-brand') or ($dell-brand = 'Alienware'))">
            <xsl:apply-templates select="*[contains(@class,' topic/title ')]"/>
        </xsl:if>
        <xsl:if test="*[contains(@class, ' topic/ol ')]">
            <fo:block keep-with-previous="always">
                <xsl:apply-templates select="*[contains(@class, ' topic/ol ')]"/>
            </fo:block>
        </xsl:if>
		<xsl:if test="*[contains(@class, ' topic/sl ')]">
            <fo:block keep-with-previous="always">
                <xsl:apply-templates select="*[contains(@class, ' topic/sl ')]"/>
            </fo:block>
        </xsl:if>
        <xsl:if test="*[contains(@class, ' topic/ul ')]">
            <fo:block keep-with-previous="always">
                <xsl:apply-templates select="*[contains(@class, ' topic/ul ')]"/>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/image ')]">
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
        <xsl:choose>
            <xsl:when test="empty(@href)"/>
            <xsl:when test="@placement = 'break'">
                <fo:block xsl:use-attribute-sets="image__block">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="placeImage">
                        <xsl:with-param name="imageAlign" select="@align"/>
                        <xsl:with-param name="href" select="if (@scope = 'external' or opentopic-func:isAbsolute(@href)) then @href else concat($input.dir.url, @href)"/>
                        <xsl:with-param name="height" select="@height"/>
                        <xsl:with-param name="width" select="@width"/>
                    </xsl:apply-templates>
                </fo:block>
                <xsl:if test="$artLabel='yes'">
                    <fo:block>
                        <xsl:apply-templates select="." mode="image.artlabel"/>
                    </fo:block>
                </xsl:if>
            </xsl:when>
            <xsl:when test="(@placement = 'inline') and
                            (preceding-sibling::*[contains(@class, ' topic/p ')]
                                or following-sibling::*[contains(@class, ' topic/p ')])">
                <fo:block xsl:use-attribute-sets="image__block">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="placeImage">
                        <xsl:with-param name="imageAlign" select="@align"/>
                        <xsl:with-param name="href" select="if (@scope = 'external' or opentopic-func:isAbsolute(@href)) then @href else concat($input.dir.url, @href)"/>
                        <xsl:with-param name="height" select="@height"/>
                        <xsl:with-param name="width" select="@width"/>
                    </xsl:apply-templates>
                </fo:block>
                <xsl:if test="$artLabel='yes'">
                    <fo:block>
                        <xsl:apply-templates select="." mode="image.artlabel"/>
                    </fo:block>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <fo:inline xsl:use-attribute-sets="image__inline">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates select="." mode="placeImage">
                        <xsl:with-param name="imageAlign" select="@align"/>
                        <xsl:with-param name="href" select="if (@scope = 'external' or opentopic-func:isAbsolute(@href)) then @href else concat($input.dir.url, @href)"/>
                        <xsl:with-param name="height" select="@height"/>
                        <xsl:with-param name="width" select="@width"/>
                    </xsl:apply-templates>
                </fo:inline>
                <xsl:if test="$artLabel='yes'">
                    <xsl:apply-templates select="." mode="image.artlabel"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
    </xsl:template>

    <xsl:template match="*" mode="placeImage">
        <xsl:param name="imageAlign"/>
        <xsl:param name="href"/>
        <xsl:param name="height" as="xs:string?"/>
        <xsl:param name="width" as="xs:string?"/>
        <xsl:call-template name="processAttrSetReflection">
            <xsl:with-param name="attrSet" select="concat('__align__', $imageAlign)"/>
            <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
        </xsl:call-template>

        <fo:external-graphic src="url('{$href}')" xsl:use-attribute-sets="image">
            <xsl:if test="$height">
                <xsl:attribute name="content-height">
                    <xsl:choose>
                        <xsl:when test="not(string(number($height)) = 'NaN')">
                            <xsl:value-of select="concat($height, 'px')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$height"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="$width">
                <xsl:attribute name="content-width">
                    <xsl:choose>
                        <xsl:when test="not(string(number($width)) = 'NaN')">
                            <xsl:value-of select="concat($width, 'px')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$width"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="not($width) and not($height) and @scale">
                <xsl:attribute name="content-width">
                    <xsl:value-of select="concat(@scale,'%')"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@scalefit = 'yes' and not($width) and not($height) and not(@scale)">
                <xsl:attribute name="width">100%</xsl:attribute>
                <xsl:attribute name="height">100%</xsl:attribute>
                <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
                <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
                <xsl:attribute name="scaling">uniform</xsl:attribute>
            </xsl:if>
            <xsl:if test="not(@max-width)">
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::*[contains(@outputclass, 'landscape')]">
                        <xsl:attribute name="max-width">248mm</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="max-width">184mm</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="not(@max-height)">
                <xsl:choose>
                    <xsl:when test="ancestor-or-self::*[contains(@outputclass, 'landscape')]">
                        <xsl:attribute name="max-height">184mm</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="max-height">248mm</xsl:attribute>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>

            <xsl:variable name="image-alt">
                <xsl:choose>
                    <xsl:when test="normalize-space(*[contains(@class, ' topic/alt ')])">
                        <xsl:value-of select="normalize-space(*[contains(@class, ' topic/alt ')])"/>
                    </xsl:when>
                    <xsl:when test="normalize-space(@alt)">
                        <xsl:value-of select="normalize-space(@alt)"/>
                    </xsl:when>
                    <xsl:when test="normalize-space(parent::*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')])">
                        <xsl:value-of select="normalize-space(parent::*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ')])"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="normalize-space($image-alt)">
                <xsl:attribute name="axf:alttext">
                    <xsl:value-of select="$image-alt"/>
                </xsl:attribute>
            </xsl:if>

            <xsl:apply-templates select="node() except (text(),
                                          *[contains(@class, ' topic/alt ') or
                                            contains(@class, ' topic/longdescref ')])"/>
        </fo:external-graphic>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/section ')]/*[contains(@class,' topic/title ')]">
        <xsl:apply-templates select="." mode="processSectionTitle"/>
    </xsl:template>

    <xsl:template match="*" mode="processSectionTitle">
        <xsl:variable name="level" as="xs:integer">
            <xsl:apply-templates select="ancestor::*[contains(@class, ' topic/section ')][1]" mode="get-section-level"/>
        </xsl:variable>
        <xsl:variable name="title-level">
            <xsl:choose>
                <xsl:when test="$level &gt; 6">6</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$level"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="attrSet1">
            <xsl:apply-templates select="." mode="createTopicAttrsName">
                <xsl:with-param name="theCounter" select="$title-level"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="attrSet2" select="concat($attrSet1, '__content')"/>
        <fo:block>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="$attrSet1"/>
                <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
            </xsl:call-template>
            <fo:block>
                <xsl:call-template name="processAttrSetReflection">
                    <xsl:with-param name="attrSet" select="$attrSet2"/>
                    <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
                </xsl:call-template>
<!--                <fo:wrapper id="{parent::node()/@id}"/>-->
<!--
                <fo:wrapper>
                    <xsl:attribute name="id">
                        <xsl:call-template name="generate-toc-id">
                            <xsl:with-param name="element" select=".."/>
                        </xsl:call-template>
                    </xsl:attribute>
                </fo:wrapper>
-->
                <xsl:apply-templates select="." mode="getTitle"/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*" mode="get-section-level" as="xs:integer">
        <xsl:variable name="topic-level" as="xs:integer">
            <xsl:apply-templates select="ancestor::*[contains(@class, ' topic/topic ')][1]" mode="get-topic-level"/>
        </xsl:variable>
        <xsl:variable name="section-level" as="xs:integer" select="count(ancestor-or-self::*[contains(@class,' topic/section ')])"/>

        <xsl:sequence select="$topic-level + $section-level"/>
    </xsl:template>

    <xsl:template match="*" mode="processTopicTitle">
        <xsl:variable name="level" as="xs:integer">
            <xsl:apply-templates select="." mode="get-topic-level"/>
        </xsl:variable>
        <xsl:variable name="title-level">
            <xsl:choose>
                <xsl:when test="$level &gt; 6">5</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$level"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="attrSet1">
            <xsl:apply-templates select="." mode="createTopicAttrsName">
                <xsl:with-param name="theCounter" select="$title-level"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="attrSet2" select="concat($attrSet1, '__content')"/>
        <fo:block>
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="$attrSet1"/>
                <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
            </xsl:call-template>
            <fo:block>
                <xsl:call-template name="processAttrSetReflection">
                    <xsl:with-param name="attrSet" select="$attrSet2"/>
                    <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
                </xsl:call-template>
                <xsl:if test="$level = 1">
                    <xsl:apply-templates select="." mode="insertTopicHeaderMarker"/>
                </xsl:if>
                <xsl:if test="$level = 2">
                    <xsl:apply-templates select="." mode="insertTopicHeaderMarker">
                        <xsl:with-param name="marker-class-name" as="xs:string">current-h2</xsl:with-param>
                    </xsl:apply-templates>
                </xsl:if>
                <fo:wrapper id="{parent::node()/@id}"/>
                <xsl:if test="$generate-toc">
                    <fo:wrapper>
                        <xsl:attribute name="id">
                            <xsl:call-template name="generate-toc-id">
                                <xsl:with-param name="element" select=".."/>
                            </xsl:call-template>
                        </xsl:attribute>
                    </fo:wrapper>
                </xsl:if>
                <xsl:call-template name="pullPrologIndexTerms"/>
                <xsl:if test="lower-case($include-metadata) = 'yes'">
                    <xsl:call-template name="insert-pubmeta-data"/>
                </xsl:if>
                <xsl:call-template name="getTopicNumbering"/>
                <xsl:apply-templates select="." mode="getTitle"/>
            </fo:block>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/draft-comment ')]">
        <xsl:if test="lower-case($include-draft-comments) = 'yes'">
            <fo:block xsl:use-attribute-sets="draft-comment">
                <xsl:call-template name="commonattributes"/>
                <fo:inline xsl:use-attribute-sets="draft-comment__label">
                    <xsl:text>Draft comment: </xsl:text>
                </fo:inline>
                <xsl:apply-templates/>
            </fo:block>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/topic ')]/*[contains(@class,' topic/shortdesc ')]" priority="1">
        <xsl:variable name="topicType" as="xs:string">
            <xsl:call-template name="determineTopicType"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$isTechnote">
                <xsl:apply-templates select="." mode="format-shortdesc-as-block"/>
            </xsl:when>
            <xsl:when test="$isNochap">
                <xsl:apply-templates select="." mode="format-shortdesc-as-block"/>
            </xsl:when>
            <!--  Disable chapter summary processing when mini TOC is created -->
            <xsl:when test="$topicType = ('topicChapter', 'topicAppendix') and
                            $chapterLayout != 'BASIC'"/>
            <!--   Normal processing         -->
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="format-shortdesc-as-block"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="generate-toc-id">
        <xsl:param name="element" select="."/>
        <xsl:choose>
            <xsl:when test="$isTechnote">
                <xsl:value-of select="@id"/>
            </xsl:when>
            <xsl:when test="$isNochap">
                <xsl:value-of select="@id"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('_OPENTOPIC_TOC_PROCESSING_', generate-id($element))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/fn ')][not(ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')])]">
        <xsl:variable name="id" select="dita-ot:getFootnoteInternalID(.)" as="xs:string"/>
        <xsl:variable name="callout" as="xs:string">
            <xsl:apply-templates select="." mode="callout"/>
        </xsl:variable>
        <fo:footnote>
            <fo:inline xsl:use-attribute-sets="fn__callout_sup">
                <fo:basic-link internal-destination="{$id}">
                    <xsl:copy-of select="$callout"/>
                </fo:basic-link>
            </fo:inline>

            <fo:footnote-body>
                <fo:list-block xsl:use-attribute-sets="fn__body">
                    <fo:list-item>
                        <fo:list-item-label end-indent="label-end()">
                            <fo:block text-align="right" id="{$id}">
                                <fo:inline xsl:use-attribute-sets="fn__callout">
                                    <xsl:copy-of select="$callout"/>
                                </fo:inline>
                            </fo:block>
                        </fo:list-item-label>
                        <fo:list-item-body start-indent="body-start()">
                            <fo:block>
                                <xsl:apply-templates/>
                            </fo:block>
                        </fo:list-item-body>
                    </fo:list-item>
                </fo:list-block>
            </fo:footnote-body>
        </fo:footnote>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/fn ')]" mode="callout">
        <xsl:choose>
            <xsl:when test="@callout">
                <xsl:value-of select="@callout"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="count(preceding::*[contains(@class,' topic/fn ')][not(normalize-space(@callout))][not(ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')])]) + 1"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="getTopicNumbering">
        <xsl:if test="$addTopicNumbering">
            <xsl:for-each select="ancestor-or-self::*[contains(@class, ' topic/topic ')][1]">
                <xsl:call-template name="getTopicNumber">
                    <xsl:with-param name="start" select="true()"/>
                </xsl:call-template>
            </xsl:for-each>
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="getTopicNumber">
        <xsl:param name="start" select="true()" as="xs:boolean"/>

        <xsl:variable name="currentTopicType">
            <xsl:call-template name="determineTopicType"/>
        </xsl:variable>

        <xsl:variable name="preceding-topics">
            <xsl:for-each select="preceding-sibling::*[contains(@class, ' topic/topic ')]">
                <xsl:variable name="topicType">
                    <xsl:call-template name="determineTopicType"/>
                </xsl:variable>
                <xsl:if test="not($topicType = 'topicNotices') and ($topicType = $currentTopicType)">
                    <topic/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$currentTopicType = 'topicNotices'"/>
            <xsl:when test="$currentTopicType = 'topicAppendix'">
                <xsl:variable name="topic-number" select="count($preceding-topics/*) + 1"/>
                <xsl:number value="$topic-number" format="A"/>
            </xsl:when>
			<xsl:when test="$currentTopicType = 'topicPreface'"/>
            <xsl:when test="$currentTopicType = 'topicPart'">
                <xsl:variable name="topic-number" select="count($preceding-topics/*) + 1"/>
                <xsl:number value="$topic-number" format="I"/>
            </xsl:when>
            <xsl:when test="$currentTopicType = 'topicChapter'">
              <xsl:variable name="id" select="@id"/>
              <xsl:variable name="topicChapters">
                <xsl:copy-of select="//*[contains(@class, ' bookmap/chapter ')]"/>
              </xsl:variable>
              <xsl:variable name="chapterNumber">
                <xsl:number format="1" value="count($topicChapters/*[@id = $id]/preceding-sibling::*) + 1"/>
              </xsl:variable>
              <xsl:variable name="topic-number" select="$chapterNumber"/>
              <xsl:number value="$topic-number" format="1"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="topic-number" select="count($preceding-topics/*) + 1"/>
                <xsl:if test="parent::*[contains(@class, ' topic/topic ')]">
                    <xsl:for-each select="parent::*[contains(@class, ' topic/topic ')]">
                        <xsl:call-template name="getTopicNumber">
                            <xsl:with-param name="start" select="false()"/>
                        </xsl:call-template>
                    </xsl:for-each>
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:value-of select="$topic-number"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/lq ')]">
        <fo:block>
            <xsl:call-template name="commonattributes"/>
            <xsl:choose>
                <xsl:when test="@href or @reftitle">
                    <xsl:call-template name="processAttrSetReflection">
                        <xsl:with-param name="attrSet" select="'lq'"/>
                        <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="processAttrSetReflection">
                        <xsl:with-param name="attrSet" select="'lq_simple'"/>
                        <xsl:with-param name="path" select="'../../cfg/fo/attrs/commons-attr.xsl'"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'OpenQuote'"/>
            </xsl:call-template>
            <xsl:apply-templates/>
            <xsl:call-template name="getVariable">
                <xsl:with-param name="id" select="'CloseQuote'"/>
            </xsl:call-template>
        </fo:block>
        <xsl:choose>
            <xsl:when test="@href">
                <fo:block xsl:use-attribute-sets="lq_link">
                    <fo:basic-link>
                        <xsl:call-template name="buildBasicLinkDestination">
                            <xsl:with-param name="scope" select="@scope"/>
                            <xsl:with-param name="format" select="@format"/>
                            <xsl:with-param name="href" select="@href"/>
                        </xsl:call-template>

                        <xsl:choose>
                            <xsl:when test="@reftitle">
                                <xsl:value-of select="@reftitle"/>
                            </xsl:when>
                            <xsl:when test="not(@type = 'external' or @format = 'html')">
                                <xsl:apply-templates select="." mode="insertReferenceTitle">
                                    <xsl:with-param name="href" select="@href"/>
                                    <xsl:with-param name="titlePrefix" select="''"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="@href"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:basic-link>
                </fo:block>
            </xsl:when>
            <xsl:when test="@reftitle">
                <fo:block xsl:use-attribute-sets="lq_title">
                    <xsl:value-of select="@reftitle"/>
                </fo:block>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="commonattributes">
        <xsl:apply-templates select="@id"/>
        <xsl:call-template name="insertXmlLangAttr">
            <xsl:with-param name="xml-lang" select="ancestor-or-self::*[@xml:lang][1]/@xml:lang"/>
        </xsl:call-template>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')] |
                                   *[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="flag-attributes"/>
    </xsl:template>

    <xsl:template name="insertXmlLangAttr">
        <xsl:param name="xml-lang"/>

        <xsl:variable name="pub-lang" select="translate(lower-case(/descendant::*[@xml:lang][1]/@xml:lang), '_', '-')"/>
        <xsl:if test="normalize-space($xml-lang)">
            <xsl:choose>
                <xsl:when test="$pub-lang = 'en-us'">
                    <xsl:if test="$xml-lang != 'en-us'">
                        <xsl:attribute name="xml:lang" select="$xml-lang"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="($xml-lang != 'en-us') and ($xml-lang != $pub-lang)">
                    <xsl:attribute name="xml:lang" select="$xml-lang"/>
                </xsl:when>
            </xsl:choose>
        </xsl:if>

    </xsl:template>

</xsl:stylesheet>