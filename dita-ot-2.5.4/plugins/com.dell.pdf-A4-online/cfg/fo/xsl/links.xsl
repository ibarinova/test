<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
                xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:template match="*[contains(@class,' topic/xref ')]" name="topic.xref">

        <xsl:variable name="destination" select="opentopic-func:getDestinationId(@href)"/>
        <xsl:variable name="element" select="key('key_anchor',$destination, $root)[1]"/>

        <xsl:variable name="referenceTitle" as="node()*">
            <xsl:apply-templates select="." mode="insertReferenceTitle">
                <xsl:with-param name="href" select="@href"/>
                <xsl:with-param name="titlePrefix" select="''"/>
                <xsl:with-param name="destination" select="$destination"/>
                <xsl:with-param name="element" select="$element"/>
            </xsl:apply-templates>
        </xsl:variable>

        <fo:basic-link xsl:use-attribute-sets="xref">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="buildBasicLinkDestination">
                <xsl:with-param name="scope" select="@scope"/>
                <xsl:with-param name="format" select="@format"/>
                <xsl:with-param name="href" select="@href"/>
            </xsl:call-template>

            <xsl:choose>
                <xsl:when test="not(@scope = 'external' or not(empty(@format) or  @format = 'dita')) and exists($referenceTitle)">
                    <xsl:copy-of select="$referenceTitle"/>
                </xsl:when>
                <xsl:when test="not(@scope = 'external' or not(empty(@format) or  @format = 'dita'))">
                    <xsl:call-template name="insertPageNumberCitation">
                        <xsl:with-param name="isTitleEmpty" select="true()"/>
                        <xsl:with-param name="destination" select="$destination"/>
                        <xsl:with-param name="element" select="$element"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="*[not(contains(@class,' topic/desc '))] | text()">
                            <xsl:apply-templates select="*[not(contains(@class,' topic/desc '))] | text()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </fo:basic-link>

        <!--
            Disable because of the CQ#8102 bug
            <xsl:if test="*[contains(@class,' topic/desc ')]">
              <xsl:call-template name="insertLinkDesc"/>
            </xsl:if>
        -->

        <xsl:if test="not(@scope = 'external' or not(empty(@format) or  @format = 'dita')) and exists($referenceTitle) and not($element[contains(@class, ' topic/fn ')])">
            <!-- SourceForge bug 1880097: should not include page number when xref includes author specified text -->
            <xsl:if test="not(processing-instruction()[name()='ditaot'][.='usertext'])">
                <xsl:choose>
                    <xsl:when test="$dell-brand = ('EMC', 'RSA','Dell','Dell EMC','Non-brand','Alienware')">
                        <xsl:call-template name="insertPageNumberCitation">
                            <xsl:with-param name="destination" select="$destination"/>
                            <xsl:with-param name="element" select="$element"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test="$addXrefsPageNumbering">
                        <xsl:call-template name="insertPageNumberCitation">
                            <xsl:with-param name="destination" select="$destination"/>
                            <xsl:with-param name="element" select="$element"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:if>

    </xsl:template>

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
                        <xsl:with-param name="id" select="'on page'"/>
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

    <xsl:template match="*[contains(@class,' topic/link ')]" mode="processLink">
        <xsl:variable name="destination" select="opentopic-func:getDestinationId(@href)"/>
        <xsl:variable name="element" select="key('key_anchor',$destination, $root)[1]"/>

        <xsl:variable name="referenceTitle" as="node()*">
            <xsl:apply-templates select="." mode="insertReferenceTitle">
                <xsl:with-param name="href" select="@href"/>
                <xsl:with-param name="titlePrefix" select="''"/>
                <xsl:with-param name="destination" select="$destination"/>
                <xsl:with-param name="element" select="$element"/>
            </xsl:apply-templates>
        </xsl:variable>
        <xsl:variable name="linkScope" as="xs:string">
            <xsl:call-template name="getLinkScope"/>
        </xsl:variable>

        <fo:block xsl:use-attribute-sets="link">
            <fo:inline xsl:use-attribute-sets="link__content">
                <fo:basic-link>
                    <xsl:call-template name="buildBasicLinkDestination">
                        <xsl:with-param name="scope" select="$linkScope"/>
                        <xsl:with-param name="href" select="@href"/>
                    </xsl:call-template>
                    <xsl:choose>
                        <xsl:when test="not($linkScope = 'external') and exists($referenceTitle)">
                            <xsl:for-each select="$root/descendant::*[contains(@class, ' topic/topic ')][@id = $destination][1]">
                                <xsl:call-template name="getTopicNumbering"/>
                            </xsl:for-each>
                            <xsl:copy-of select="$referenceTitle"/>
                        </xsl:when>
                        <xsl:when test="not($linkScope = 'external')">
                            <xsl:call-template name="insertPageNumberCitation">
                                <xsl:with-param name="isTitleEmpty" select="true()"/>
                                <xsl:with-param name="destination" select="$destination"/>
                                <xsl:with-param name="element" select="$element"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="*[contains(@class, ' topic/linktext ')]">
                            <xsl:apply-templates select="*[contains(@class, ' topic/linktext ')]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="@href"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:basic-link>
            </fo:inline>
            <xsl:if test="not($linkScope = 'external') and exists($referenceTitle)">
                <xsl:if test="$dell-brand = ('EMC', 'RSA','Dell','Dell EMC','Non-brand','Alienware')">
                    <xsl:call-template name="insertPageNumberCitation">
                        <xsl:with-param name="destination" select="$destination"/>
                        <xsl:with-param name="element" select="$element"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:if>
            <!--
                        <xsl:call-template name="insertLinkShortDesc">
                            <xsl:with-param name="destination" select="$destination"/>
                            <xsl:with-param name="element" select="$element"/>
                            <xsl:with-param name="linkScope" select="$linkScope"/>
                        </xsl:call-template>
            -->
        </fo:block>
    </xsl:template>

    <!-- Added by Roopesh. Created links for all object tag in PDF A4 online  Name attribute is mandatory in xml for display text -->
    <xsl:template match="*[contains(@class,' topic/object ')]" name="topic.object">
        <fo:block>
            <fo:basic-link xsl:use-attribute-sets="xref">
                <xsl:call-template name="commonattributes"/>
                <xsl:attribute name="external-destination">
                    <xsl:value-of select="@data"/>
                </xsl:attribute>
                <fo:inline>
                    <xsl:value-of select="@name"/>
                </fo:inline>
            </fo:basic-link>
            <xsl:apply-templates/>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/related-links ')]">
        <xsl:variable name="relatedConceptsTitle">
            <xsl:call-template name="getVariable">
        <xsl:with-param name="id" select="'Related concepts'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="relatedTasksTitle">
        <xsl:call-template name="getVariable">
        <xsl:with-param name="id" select="'Related tasks'"/>
            </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="relatedReferencesTitle">
            <xsl:call-template name="getVariable">
              <xsl:with-param name="id" select="'Related references'"/>
        </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="relatedInformationTitle">
           <xsl:call-template name="getVariable">
           <xsl:with-param name="id" select="'Related information'"/>
                </xsl:call-template>
        </xsl:variable>

        <xsl:variable name="links">
             <xsl:for-each select="descendant::*[contains(@class, ' topic/link ')]
                                            [generate-id(.) = generate-id(key('hideduplicates', related-links:hideduplicates(.))[1])]">
                <xsl:variable name="topic-id" select="substring-after(@href, '#')"/>
              <xsl:if test="/descendant::*[contains(@class, ' topic/topic ')][@id = $topic-id]">
                  <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each>
        </xsl:variable>
    <xsl:choose>
         <xsl:when test="$map//*[contains(@class,' map/reltable ')][@print='no']"/>
         <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="*[contains(@class, ' topic/linkpool')]">
                        <xsl:if test="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'concept'][@role = ('friend', 'sibling')]">
                            <fo:block xsl:use-attribute-sets="related-links">
                                <fo:block xsl:use-attribute-sets="linklist.title">
                                    <xsl:copy-of select="$relatedConceptsTitle"/>
                                </fo:block>

                                <xsl:for-each select="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'concept'][@role = ('friend', 'sibling')]">
                                    <fo:block xsl:use-attribute-sets="related-links__content">
                                        <xsl:apply-templates select="." mode="processLink"/>
                                    </fo:block>
                                </xsl:for-each>
                            </fo:block>
                        </xsl:if>

                        <xsl:if test="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'reference'][@role = ('friend', 'sibling')]">
                            <fo:block xsl:use-attribute-sets="related-links">
                                <fo:block xsl:use-attribute-sets="linklist.title">
                                    <xsl:copy-of select="$relatedReferencesTitle"/>
                                </fo:block>

                                <xsl:for-each select="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'reference'][@role = ('friend', 'sibling')]">
                                    <fo:block xsl:use-attribute-sets="related-links__content">
                                        <xsl:apply-templates select="." mode="processLink"/>
                                    </fo:block>
                                </xsl:for-each>
                            </fo:block>
                        </xsl:if>

                        <xsl:if test="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'task'][@role = ('friend', 'sibling')]">
                            <fo:block xsl:use-attribute-sets="related-links">
                                <fo:block xsl:use-attribute-sets="linklist.title">
                                    <xsl:copy-of select="$relatedTasksTitle"/>
                                </fo:block>

                                <xsl:for-each select="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'task'][@role = ('friend', 'sibling')]">
                                    <fo:block xsl:use-attribute-sets="related-links__content">
                                        <xsl:apply-templates select="." mode="processLink"/>
                                    </fo:block>
                                </xsl:for-each>
                            </fo:block>
                        </xsl:if>

                        <xsl:if test="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'topic'][@role = ('friend', 'sibling')]">
                            <fo:block xsl:use-attribute-sets="related-links">
                                <fo:block xsl:use-attribute-sets="linklist.title">
                                    <xsl:copy-of select="$relatedInformationTitle"/>
                                </fo:block>

                                <xsl:for-each select="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'topic'][@role = ('friend', 'sibling')]">
                                    <fo:block xsl:use-attribute-sets="related-links__content">
                                        <xsl:apply-templates select="." mode="processLink"/>
                                    </fo:block>
                                </xsl:for-each>
                            </fo:block>
                        </xsl:if>

                        <xsl:if test="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'other'][@role = ('friend', 'sibling')]">
                            <fo:block xsl:use-attribute-sets="related-links">
                                <fo:block xsl:use-attribute-sets="linklist.title">
                                    <xsl:copy-of select="$relatedInformationTitle"/>
                                </fo:block>

                                <xsl:for-each select="$links/descendant::*[contains(@class, ' topic/link ')][@type = 'other' and @role = ('friend', 'sibling')]">
                                    <fo:block xsl:use-attribute-sets="related-links__content">
                                        <xsl:apply-templates select="." mode="processLink"/>
                                    </fo:block>
                                </xsl:for-each>
                            </fo:block>
                        </xsl:if>
                    </xsl:when>
                    <!--Process manually added related-links inside the topics seperately using the linkpool-->
                    <xsl:when test="not(*[contains(@class, ' topic/linkpool')])">
                        <xsl:if test="$links/descendant::*[contains(@class, ' topic/link ')]">
                            <fo:block xsl:use-attribute-sets="related-links">
                                <fo:block xsl:use-attribute-sets="linklist.title">
                                    <xsl:copy-of select="$relatedInformationTitle"/>
                                </fo:block>
                                <xsl:for-each select="$links/descendant::*[contains(@class, ' topic/link ')][generate-id(.) = generate-id(key('hideduplicates', related-links:hideduplicates(.))[1])]">
                                    <fo:block xsl:use-attribute-sets="related-links__content">
                                        <xsl:apply-templates select="." mode="processLink"/>
                                    </fo:block>
                                </xsl:for-each>
                            </fo:block>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>
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
            <xsl:otherwise>
                <fo:inline xsl:use-attribute-sets="fn_container">
                    <fo:inline xsl:use-attribute-sets="fn__callout_ref">
                        <xsl:copy-of select="$callout"/>
                    </fo:inline>
                </fo:inline>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="retrieveReferenceTitle" >
        <xsl:choose>
            <xsl:when test="self::*[contains(@class, ' topic/topic ')] and *[contains(@class,' topic/title ')]">
                <xsl:call-template name="getTopicNumbering"/>
                <xsl:value-of select="string(*[contains(@class, ' topic/title ')])"/>
            </xsl:when>
            <xsl:when test="self::*[contains(@class, ' topic/title ')] and parent::*[contains(@class,' topic/topic ')]">
                <xsl:call-template name="getTopicNumbering"/>
                <xsl:value-of select="string(.)"/>
            </xsl:when>
            <xsl:when test="*[contains(@class,' topic/title ')]">
                <xsl:value-of select="string(*[contains(@class, ' topic/title ')])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>#none#</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>