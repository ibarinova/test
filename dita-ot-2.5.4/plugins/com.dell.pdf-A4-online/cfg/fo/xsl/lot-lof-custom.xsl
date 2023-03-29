<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ot-placeholder="http://suite-sol.com/namespaces/ot-placeholder"
                exclude-result-prefixes=" ot-placeholder"
                version="2.0">

    <xsl:variable name="tableset">
        <xsl:for-each select="//*[contains (@class, ' topic/table ')][*[contains(@class, ' topic/title ' )]]">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:if test="not(@id)">
                    <xsl:attribute name="id">
                        <xsl:call-template name="get-id"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="figureset">
        <xsl:for-each select="//*[contains (@class, ' topic/fig ')][*[contains(@class, ' topic/title ' )]]">
            <xsl:copy>
                <xsl:copy-of select="@*"/>
                <xsl:if test="not(@id)">
                    <xsl:attribute name="id">
                        <xsl:call-template name="get-id"/>
                    </xsl:attribute>
                </xsl:if>
            </xsl:copy>
        </xsl:for-each>
    </xsl:variable>

    <!--   LOT   -->
    <xsl:template match="ot-placeholder:tablelist" name="createTableList">
        <xsl:if test="//*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ' )]">
            <!--exists tables with titles-->
            <fo:page-sequence master-reference="toc-sequence" xsl:use-attribute-sets="page-sequence.lot">
                <xsl:call-template name="insertTocStaticContents"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block start-indent="0in">
                        <xsl:call-template name="createLOTHeader"/>

                        <xsl:apply-templates
                                select="//*[contains (@class, ' topic/table ')][child::*[contains(@class, ' topic/title ' )]]"
                                mode="list.of.tables"/>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <xsl:template name="createLOTHeader">
        <xsl:choose>
            <xsl:when test="$dell-brand = ('Non-brand', 'Alienware', 'RSA')">
                <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.lot}">
                    <fo:block xsl:use-attribute-sets="__toc__header_content">
                        <fo:bidi-override>
                            <xsl:attribute name="direction">
                                <xsl:choose>
                                    <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                    <xsl:otherwise>ltr</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'LOT-dell'" />
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
                                    <xsl:with-param name="id" select="'LOT-dell'" />
                                </xsl:call-template>
                            </fo:bidi-override>
                        </fo:marker>
                    </fo:block>
                    <fo:block margin-top="1.5mm"/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.lot}">
                    <fo:marker marker-class-name="current-header">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'LOT-dell'"/>
                        </xsl:call-template>
                    </fo:marker>
                    <xsl:call-template name="insertBlueBarHeader">
                        <xsl:with-param name="content">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'LOT-dell'" />
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="type" select="'txt'"/>
                    </xsl:call-template>
                    <fo:block margin-top="21.5mm"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains (@class, ' topic/table ')][child::*[contains(@class, ' topic/title ' )]]" mode="list.of.tables">
        <xsl:variable name="id">
            <xsl:call-template name="get-id"/>
        </xsl:variable>
        <xsl:variable name="tableNumber">
            <xsl:number format="1" value="count($tableset/*[@id = $id]/preceding-sibling::*) + 1"/>
        </xsl:variable>
        <xsl:variable name="tableTitle">
            <xsl:apply-templates select="./*[contains(@class, ' topic/title ')]" mode="insert-text"/>
        </xsl:variable>
        <fo:table>
            <fo:table-column xsl:use-attribute-sets="__lotf__table_left_indent"/>
            <fo:table-column column-width="13mm"/>
            <fo:table-column/>
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell/>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="__toc__link">
                            <fo:inline xsl:use-attribute-sets="__lotf__number">
                                <xsl:value-of select="$tableNumber"/>
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="__lotf__topic__content">
                            <fo:basic-link xsl:use-attribute-sets="__toc__link">
                                <xsl:attribute name="internal-destination">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>

                                <fo:inline xsl:use-attribute-sets="__lotf__title">
                                    <xsl:value-of select="normalize-space($tableTitle)"/>
                                </fo:inline>

                                <fo:inline xsl:use-attribute-sets="__lotf__page-number">
                                    <fo:leader xsl:use-attribute-sets="__lotf__leader"/>
                                    <fo:page-number-citation>
                                        <xsl:attribute name="ref-id">
                                            <xsl:value-of select="$id"/>
                                        </xsl:attribute>
                                    </fo:page-number-citation>
                                </fo:inline>
                            </fo:basic-link>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>

    <!--   LOF   -->
    <xsl:template match="ot-placeholder:figurelist" name="createFigureList">
        <xsl:if test="//*[contains(@class, ' topic/fig ')]/*[contains(@class, ' topic/title ' )]">
            <!--exists figures with titles-->
            <fo:page-sequence master-reference="toc-sequence" xsl:use-attribute-sets="page-sequence.lof">
                <xsl:call-template name="insertTocStaticContents"/>
                <fo:flow flow-name="xsl-region-body">
                    <fo:block start-indent="0in">
                        <xsl:call-template name="createLOFHeader"/>

                        <xsl:apply-templates
                                select="//*[contains (@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ' )]]"
                                mode="list.of.figures"/>
                    </fo:block>
                </fo:flow>
            </fo:page-sequence>
        </xsl:if>
    </xsl:template>

    <xsl:template name="createLOFHeader">
        <xsl:choose>
            <xsl:when test="$dell-brand = ('Non-brand', 'Alienware', 'RSA')">
                <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.lof}">
                    <fo:block xsl:use-attribute-sets="__toc__header_content">
                        <fo:bidi-override>
                            <xsl:attribute name="direction">
                                <xsl:choose>
                                    <xsl:when test="$writing-mode='rl-tb'">rtl</xsl:when>
                                    <xsl:otherwise>ltr</xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'LOF-dell'" />
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
                                    <xsl:with-param name="id" select="'LOF-dell'" />
                                </xsl:call-template>
                            </fo:bidi-override>
                        </fo:marker>
                    </fo:block>
                    <fo:block margin-top="1.5mm"/>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <fo:block xsl:use-attribute-sets="__toc__header" id="{$id.lof}">
                    <fo:marker marker-class-name="current-header">
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'LOF-dell'"/>
                        </xsl:call-template>
                    </fo:marker>
                    <xsl:call-template name="insertBlueBarHeader">
                        <xsl:with-param name="content">
                            <xsl:call-template name="getVariable">
                                <xsl:with-param name="id" select="'LOF-dell'" />
                            </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="type" select="'txt'"/>
                    </xsl:call-template>
                    <fo:block margin-top="21.5mm"/>
                </fo:block>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains (@class, ' topic/fig ')][child::*[contains(@class, ' topic/title ' )]]" mode="list.of.figures">
        <xsl:variable name="id">
            <xsl:call-template name="get-id"/>
        </xsl:variable>
        <xsl:variable name="figureNumber">
            <xsl:number format="1" value="count($figureset/*[@id = $id]/preceding-sibling::*) + 1"/>
        </xsl:variable>
        <xsl:variable name="figureTitle">
            <xsl:apply-templates select="./*[contains(@class, ' topic/title ')]" mode="insert-text"/>
        </xsl:variable>
        <fo:table>
            <fo:table-column xsl:use-attribute-sets="__lotf__table_left_indent"/>
            <fo:table-column column-width="13mm"/>
            <fo:table-column/>
            <fo:table-body>
                <fo:table-row>
                    <fo:table-cell/>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="__toc__link">
                            <fo:inline xsl:use-attribute-sets="__lotf__number">
                                <xsl:value-of select="$figureNumber"/>
                            </fo:inline>
                        </fo:block>
                    </fo:table-cell>
                    <fo:table-cell>
                        <fo:block xsl:use-attribute-sets="__lotf__topic__content">
                            <fo:basic-link xsl:use-attribute-sets="__toc__link">
                                <xsl:attribute name="internal-destination">
                                    <xsl:value-of select="$id"/>
                                </xsl:attribute>

                                <fo:inline xsl:use-attribute-sets="__lotf__title">
                                    <xsl:value-of select="normalize-space($figureTitle)"/>
                                </fo:inline>

                                <fo:inline xsl:use-attribute-sets="__lotf__page-number">
                                    <fo:leader xsl:use-attribute-sets="__lotf__leader"/>
                                    <fo:page-number-citation>
                                        <xsl:attribute name="ref-id">
                                            <xsl:value-of select="$id"/>
                                        </xsl:attribute>
                                    </fo:page-number-citation>
                                </fo:inline>
                            </fo:basic-link>
                        </fo:block>
                    </fo:table-cell>
                </fo:table-row>
            </fo:table-body>
        </fo:table>
    </xsl:template>

</xsl:stylesheet>
