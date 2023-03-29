<?xml version='1.0'?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
    version="2.0">

    <xsl:template match="*[contains(@class,' topic/ol ')][not(contains(@class, ' task/steps '))]">
        <xsl:choose>
            <xsl:when test="preceding-sibling::*[contains(@class,' topic/image ')] and count(child::*[contains(@class, ' topic/li ')])">
                <fo:block margin-top="4pt">
                    <xsl:for-each select="*[position() mod 2 = 1]">
                        <fo:table>
                            <fo:table-column column-width="51%" />
                            <fo:table-column column-width="49%" />
                            <fo:table-header>
                                <fo:table-row>
                                    <fo:table-cell>
                                        <fo:block />
                                    </fo:table-cell>
                                    <fo:table-cell>
                                        <fo:block />
                                    </fo:table-cell>
                                </fo:table-row>
                            </fo:table-header>
                            <fo:table-body>
                                <fo:table-row>
                                    <fo:table-cell xsl:use-attribute-sets="fig_callout_entry" >
                                        <fo:list-block margin-bottom="1pt">
                                            <xsl:apply-templates select="." />
                                        </fo:list-block>
                                    </fo:table-cell>
                                    <fo:table-cell xsl:use-attribute-sets="fig_callout_entry">
                                        <fo:list-block margin-bottom="1pt">
                                            <xsl:apply-templates select="following-sibling::*[1]" />
                                        </fo:list-block>
                                    </fo:table-cell>
                                </fo:table-row>
                            </fo:table-body>
                        </fo:table>
                    </xsl:for-each>
                </fo:block>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
                <fo:list-block xsl:use-attribute-sets="ol">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:apply-templates/>
                </fo:list-block>
                <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/ul ')]/*[contains(@class, ' topic/li ')]">
        <xsl:variable name="depth" select="count(ancestor::*[contains(@class, ' topic/ul ')])"/>
        <fo:list-item xsl:use-attribute-sets="ul.li">
            <xsl:call-template name="commonattributes"/>
            <fo:list-item-label xsl:use-attribute-sets="ul.li__label">
                <fo:block xsl:use-attribute-sets="ul.li__label__content">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Unordered List bullet'"/>
                    </xsl:call-template>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body xsl:use-attribute-sets="ul.li__body">
                <fo:block xsl:use-attribute-sets="ul.li__content">
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

</xsl:stylesheet>