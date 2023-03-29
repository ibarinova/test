<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:template name="insertPageNumberCitation">
        <xsl:param name="isTitleEmpty" as="xs:boolean" select="false()"/>
        <xsl:param name="destination" as="xs:string"/>
        <xsl:param name="element" as="element()?"/>

        <xsl:choose>
            <xsl:when test="not($element) or ($destination = '')"/>
            <xsl:when test="$isTitleEmpty">
                <fo:inline>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Page'"/>
                        <xsl:with-param name="params">
                            <pagenum>
                                <fo:inline>
                                    <fo:page-number-citation ref-id="{$destination}"/>
                                </fo:inline>
                            </pagenum>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:inline>
            </xsl:when>
            <xsl:otherwise>
                <fo:inline>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'On the page EMC'"/>
                        <xsl:with-param name="params">
                            <pagenum>
                                <fo:inline>
                                    <fo:page-number-citation ref-id="{$destination}"/>
                                </fo:inline>
                            </pagenum>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/xref ') and @type = 'fn']" priority="2">
        <xsl:variable name="href" select="substring-after(@href,'/')"/>
        <xsl:variable name="id" as="xs:string">
            <xsl:for-each select="/descendant::*[contains(@class, ' topic/fn ')][@id = $href][1]">
                <xsl:value-of select="dita-ot:getFootnoteInternalID(.)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="callout" as="xs:string">
            <xsl:for-each select="/descendant::*[contains(@class, ' topic/fn ')][@id = $href][1]">
                <xsl:apply-templates select="." mode="callout"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="//*[@id=$href][ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]">
                <fo:basic-link font-style="normal">
                    <xsl:attribute name="internal-destination" select="generate-id(//*[@id=$href])"/>
                    <fo:inline xsl:use-attribute-sets="fn__callout_ref">
                        <xsl:variable name="tableId" select="//*[@id=$href]/ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.)"/>
                        <xsl:variable name="xrefTableId" select="current()/ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.)"/>
                        <xsl:choose>
                            <xsl:when test="$xrefTableId != $tableId">
                                <xsl:message>WARNING: <xsl:value-of select="@ohref"/> table cross reference does not exist in same table.</xsl:message>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:variable name="tableFnCount" select="//*[contains(@class, ' topic/fn ') and @id = $href]/count(preceding::*[contains(@class, ' topic/fn ') and $xrefTableId=$tableId and ancestor::*[contains(@class,' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.) = $tableId]) + 1"/>
                                <xsl:choose>
                                    <xsl:when test="translate($locale,'RU','ru')='ru'">
                                        <xsl:number format="&#x0430;" value="$tableFnCount"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:number format="a" value="$tableFnCount"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:inline>
                </fo:basic-link>
            </xsl:when>
            <xsl:when test="not(preceding::*[contains(@class, ' topic/xref ') and @type = 'fn'][substring-after(@href,'/') = $href])">
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
            </xsl:when>
            <xsl:otherwise>
                <fo:inline xsl:use-attribute-sets="fn_container">
                    <fo:inline xsl:use-attribute-sets="fn__callout_ref">
                        <xsl:copy-of select="$callout"/>
                    </fo:inline>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>