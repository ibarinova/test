<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                version="2.0">

    <xsl:template match="*[contains(@class, ' topic/ol ')]
                            [preceding-sibling::*[1][contains(@class, ' topic/image ')]]
                            [count(*[contains(@class, ' topic/li ')]) &gt; 3]">
    <xsl:apply-templates select="." mode="fig-ol"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/ol ')]" mode="fig-ol">
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
        <fo:table xsl:use-attribute-sets="ol_fig">
            <fo:table-column column-width="5mm"/>
            <fo:table-column />
            <fo:table-column column-width="5mm"/>
            <fo:table-column />
            <fo:table-body>
                <xsl:for-each select="*[contains(@class, ' topic/li ')][((count(preceding-sibling::*[contains(@class, ' topic/li ')]) + 1) mod 2) != 0]">
                    <fo:table-row>
                        <xsl:apply-templates select="." mode="fig-ol">
                            <xsl:with-param name="position" select="count(preceding-sibling::*[contains(@class, ' topic/li ')]) + 1"/>
                        </xsl:apply-templates>
                        <xsl:choose>
                            <xsl:when test="following-sibling::*">
                                <xsl:apply-templates select="following-sibling::*[1]" mode="fig-ol">
                                        <xsl:with-param name="position" select="count(preceding-sibling::*[contains(@class, ' topic/li ')]) + 2"/>
                                </xsl:apply-templates>
                            </xsl:when>
                            <xsl:otherwise>
                                <fo:table-cell/>
                                <fo:table-cell/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:table-row>
                </xsl:for-each>
            </fo:table-body>
        </fo:table>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/ol ')]/*[contains(@class, ' topic/li ')]" mode="fig-ol">
        <xsl:param name="position" select="1"/>
        <fo:table-cell xsl:use-attribute-sets="ol_li_fig">
            <fo:block margin-bottom="2pt">
                <xsl:value-of select="concat($position, '.')"/>
            </fo:block>
        </fo:table-cell>
        <fo:table-cell xsl:use-attribute-sets="ol_li_fig">
            <fo:block margin-bottom="2pt">
                <xsl:apply-templates/>
            </fo:block>
        </fo:table-cell>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/ul ')]/*[contains(@class, ' topic/li ')]">
        <xsl:param name="pagebreak" tunnel="yes">no</xsl:param>
        <xsl:variable name="level" select="count(ancestor::*[contains(@class, ' topic/ul ')])"/>
        <xsl:variable name="depth" select="if($level &gt; 4) then(5) else($level)"/>
        <fo:list-item xsl:use-attribute-sets="ul.li">
            <xsl:call-template name="commonattributes"/>
            <xsl:if test="$pagebreak = 'yes'">
                <xsl:attribute name="break-before">page</xsl:attribute>
            </xsl:if>
            <xsl:if test="$pagebreak = 'nopagebreak'">
                <xsl:attribute name="keep-together.within-page">5</xsl:attribute>
            </xsl:if>
            <fo:list-item-label xsl:use-attribute-sets="ul.li__label">
                <fo:block xsl:use-attribute-sets="ul.li__label__content">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="concat('Unordered List bullet ', $depth)"/>
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

	<xsl:template match="*[contains(@class, ' topic/ol ')]/*[contains(@class, ' topic/li ')]">
        <xsl:param name="pagebreak" tunnel="yes">no</xsl:param>
        <xsl:variable name="depth" select="count(ancestor::*[contains(@class, ' topic/ol ')])"/>
        <xsl:variable name="format">
          <xsl:call-template name="getVariable">
            <xsl:with-param name="id" select="concat('Ordered List Format ', $depth)"/>
          </xsl:call-template>
        </xsl:variable>
        <fo:list-item xsl:use-attribute-sets="ol.li">
            <xsl:if test="$pagebreak = 'yes'">
                <xsl:attribute name="break-before">page</xsl:attribute>
            </xsl:if>
            <xsl:if test="$pagebreak = 'nopagebreak'">
                <xsl:attribute name="keep-together.within-page">5</xsl:attribute>
            </xsl:if>
            <xsl:call-template name="commonattributes"/>
            <fo:list-item-label xsl:use-attribute-sets="ol.li__label">
                <fo:block xsl:use-attribute-sets="ol.li__label__content">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="concat('Ordered List Number ', $depth)"/>
                        <xsl:with-param name="params" as="element()*">
                           <number>
                               <xsl:number format="{$format}"/>
                           </number>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:block>
            </fo:list-item-label>
            <fo:list-item-body xsl:use-attribute-sets="ol.li__body">
                <fo:block xsl:use-attribute-sets="ol.li__content">
                    <xsl:apply-templates/>
                </fo:block>
            </fo:list-item-body>
        </fo:list-item>
    </xsl:template>

</xsl:stylesheet>