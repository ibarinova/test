<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mappull="http://dita-ot.sourceforge.net/ns/200704/mappull"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                version="2.0"
                exclude-result-prefixes="xs mappull ditamsg">

    <xsl:template match="*[contains(@class, ' map/topicref ')]">
        <xsl:param name="relative-path" as="xs:string">#none#</xsl:param>
        <!-- used for mapref source ditamap to retain the relative path information of the target ditamap -->
        <xsl:param name="parent-linking" as="xs:string">#none#</xsl:param>
        <!-- used for mapref target to see whether @linking should be override by the source of mapref -->
        <xsl:param name="parent-toc" as="xs:string">#none#</xsl:param>
        <!-- used for mapref target to see whether @toc should be override by the source of mapref -->
        <xsl:param name="parent-processing-role" as="xs:string">#none#</xsl:param>

        <!--need to create these variables regardless, for passing as a parameter to get-stuff template-->
        <xsl:variable name="type" as="xs:string">
            <xsl:call-template name="inherit"><xsl:with-param name="attrib">type</xsl:with-param></xsl:call-template>
        </xsl:variable>
        <xsl:variable name="print" as="xs:string">
            <xsl:call-template name="inherit"><xsl:with-param name="attrib">print</xsl:with-param></xsl:call-template>
        </xsl:variable>
        <xsl:variable name="format" as="xs:string">
            <xsl:call-template name="inherit"><xsl:with-param name="attrib">format</xsl:with-param></xsl:call-template>
        </xsl:variable>
        <xsl:variable name="scope" as="xs:string">
            <xsl:call-template name="inherit"><xsl:with-param name="attrib">scope</xsl:with-param></xsl:call-template>
        </xsl:variable>

        <!--copy self-->
        <xsl:copy>
            <!--copy existing explicit attributes-->
            <xsl:apply-templates select="@* except @href"/>

            <xsl:apply-templates select="." mode="mappull:set-href-attribute">
                <xsl:with-param name="relative-path" select="$relative-path"/>
            </xsl:apply-templates>

            <!--copy inheritable attributes that aren't already explicitly defined-->
            <!--@type|@importance|@linking|@toc|@print|@search|@format|@scope-->
            <!--need to create type variable regardless, for passing as a parameter to getstuff template-->
            <xsl:if test="(:not(@type) and :)$type!='#none#'">
                <xsl:attribute name="type"><xsl:value-of select="$type"/></xsl:attribute>
            </xsl:if>
            <!-- FIXME: importance is not inheretable per http://docs.oasis-open.org/dita/v1.2/os/spec/archSpec/cascading-in-a-ditamap.html -->
            <!--xsl:if test="not(@importance)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">importance</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <!-- if it's in target of mapref override the current linking attribute when parent linking is none -->
            <xsl:if test="$parent-linking='none'">
                <xsl:attribute name="linking">none</xsl:attribute>
            </xsl:if>
            <xsl:if test="(:not(@linking) and :)not($parent-linking='none')">
                <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">linking</xsl:with-param></xsl:apply-templates>
            </xsl:if>
            <!-- if it's in target of mapref override the current toc attribute when parent toc is no -->
            <xsl:if test="$parent-toc='no'">
                <xsl:attribute name="toc">no</xsl:attribute>
            </xsl:if>
            <xsl:if test="(:not(@toc) and :)not($parent-toc='no')">
                <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">toc</xsl:with-param></xsl:apply-templates>
            </xsl:if>
            <xsl:if test="$parent-processing-role='resource-only'">
                <xsl:attribute name="processing-role">resource-only</xsl:attribute>
            </xsl:if>
            <xsl:if test="(:not(@processing-role) and :)not($parent-processing-role='resource-only')">
                <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">processing-role</xsl:with-param></xsl:apply-templates>
            </xsl:if>
            <xsl:if test="(:not(@print) and :)$print!='#none#'">
                <xsl:attribute name="print"><xsl:value-of select="$print"/></xsl:attribute>
            </xsl:if>
            <!--xsl:if test="not(@search)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">search</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <xsl:if test="(:not(@format) and :)$format!='#none#'">
                <xsl:attribute name="format"><xsl:value-of select="$format"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="(:not(@scope) and :)$scope!='#none#'">
                <xsl:attribute name="scope"><xsl:value-of select="$scope"/></xsl:attribute>
            </xsl:if>
            <!--xsl:if test="not(@audience)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">audience</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <!--xsl:if test="not(@platform)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">platform</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <!--xsl:if test="not(@product)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">product</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <!--xsl:if test="not(@rev)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">rev</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <!--xsl:if test="not(@otherprops)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">otherprops</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <!--xsl:if test="not(@props)"-->
            <xsl:apply-templates select="." mode="mappull:inherit-and-set-attribute"><xsl:with-param name="attrib">props</xsl:with-param></xsl:apply-templates>
            <!--/xsl:if-->
            <!--grab type, text and metadata, as long there's an href to grab from, and it's not inaccessible-->
            <xsl:choose>
                <xsl:when test="@href=''">
                    <xsl:apply-templates select="." mode="ditamsg:empty-href"/>
                </xsl:when>
                <xsl:when test="$print='no' and ($FINALOUTPUTTYPE='PDF' or $FINALOUTPUTTYPE='IDD')"/>
                <xsl:when test="@href and not(matches(@href, 'https?:/'))">
                    <xsl:call-template name="get-stuff">
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="scope" select="$scope"/>
                        <xsl:with-param name="format" select="$format"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
            <!--apply templates to children-->
            <xsl:apply-templates  select="*|comment()|processing-instruction()">
                <xsl:with-param name="parent-linking" select="$parent-linking"/>
                <xsl:with-param name="parent-toc" select="$parent-toc"/>
                <xsl:with-param name="relative-path" select="$relative-path"/>
            </xsl:apply-templates>
        </xsl:copy>

    </xsl:template>

</xsl:stylesheet>
