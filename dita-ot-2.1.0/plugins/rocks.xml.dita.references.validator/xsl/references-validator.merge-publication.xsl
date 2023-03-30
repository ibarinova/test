<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xr="http://xml.rocks"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xr xs"
                version="2.0">

    <xsl:import href="references-validator.common-functions.xsl"/>

    <xsl:character-map name="escape-characters">
        <xsl:output-character character="&apos;" string="&amp;apos;"/>
        <xsl:output-character character="&quot;" string="&amp;quot;"/>
    </xsl:character-map>

    <xsl:output method="xml" use-character-maps="escape-characters"/>

    <xsl:param name="sourcedir"/>

    <xsl:variable name="sourcedir-path" select="translate($sourcedir, '\', '/')"/>

    <xsl:variable name="base-uri" select="base-uri()"/>
    <xsl:variable name="base-name" select="tokenize($base-uri,'/')[last()]"/>

    <xsl:template match="/">
        <xsl:apply-templates select="*[contains(@class, ' map/map ')]" mode="root-map"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' bookmap/publisherinformation ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' topic/category ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' topic/prodinfo ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' map/topicmeta ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' map/relheader ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' topic/titlealts ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' topic/prolog ')]" priority="10"/>
    <xsl:template match="*[contains(@class, ' topic/desc ')]" priority="10"/>

    <xsl:template match="*[contains(@class, ' topic/related-links ')]" priority="10"/>

    <xsl:template match="*[contains(@class, ' map/map ')]" mode="root-map">
        <xsl:variable name="meta-name" select="xr:getMetaFileName($base-name)"/>
        <xsl:variable name="meta-uri" select="concat('file:///', $sourcedir-path, '/', $meta-name)"/>
        <xsl:variable name="meta-doc" select="if(not(xr:hrefIsExternal(.))) then(document($meta-uri)) else()"/>
        <xsl:variable name="ftitle" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FTITLE'])
                                            else ('')"/>
        <xsl:variable name="LCAversion" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'VERSION'])
                                            else('')"/>
        <xsl:variable name="LCArevision" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FISHREVCOUNTER'])
                                            else('')"/>
        <xsl:variable name="LCAstatus" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FSTATUS'])
                                            else('')"/>
        <xsl:variable name="shortdesc">
            <xsl:value-of select="child::*[contains(@class, ' map/topicmeta ')]
                            /descendant::*[contains(@class, ' map/shortdesc ')][1]
                            /normalize-space(.)"/>
        </xsl:variable>
        <xsl:variable name="type" select="if(name() = 'bookmap') then('B') else('M')"/>
        <xsl:variable name="full-href" select="concat($base-name, '#', @id)"/>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="descendant::*[contains(@class, ' bookmap/mainbooktitle ')][1]">
                    <xsl:value-of select="normalize-space(descendant::*[contains(@class, ' bookmap/mainbooktitle ')][1])"/>
                </xsl:when>
                <xsl:when test="descendant::*[contains(@class, ' topic/title ')][1]">
                    <xsl:value-of select="normalize-space(descendant::*[contains(@class, ' topic/title ')][1])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'Untitled'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="tooltip">
            <xsl:choose>
                <xsl:when test="($title != '') and ($title != 'Untitled')">
                    <xsl:value-of select="$title"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ftitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <node>
            <xsl:attribute name="type" select="$type"/>
            <xsl:attribute name="id" select="@id"/>
            <xsl:attribute name="ltype" select="''"/>
            <xsl:attribute name="tooltip" select="$tooltip"/>
            <xsl:attribute name="href" select="''"/>
            <xsl:attribute name="full-href" select="$full-href"/>
            <xsl:attribute name="title" select="$title"/>
            <xsl:attribute name="ishcondition" select="xr:prepareIshconditionValue(@ishcondition)"/>
            <meta>
                <xsl:attribute name="ftitle" select="$ftitle"/>
                <xsl:attribute name="shortdesc" select="$shortdesc"/>
                <xsl:attribute name="LCAversion" select="$LCAversion"/>
                <xsl:attribute name="LCArevision" select="$LCArevision"/>
                <xsl:attribute name="LCAstatus" select="$LCAstatus"/>
            </meta>
            <xsl:variable name="nested-ishconditions">
                <xsl:for-each select="descendant::*[normalize-space(@ishcondition)]/@ishcondition">
                    <ishcondition><xsl:value-of select="xr:prepareIshconditionValue(.)"/></ishcondition>
                </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="unique-nested-ishconditions" select="xr:getUniqueIshconditions($nested-ishconditions)"/>
            <nested-ishconditions>
                <xsl:for-each select="$unique-nested-ishconditions/ishcondition">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </nested-ishconditions>
            <children>
                <xsl:apply-templates/>
            </children>
        </node>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/reltable ')]" priority="10">
        <xsl:variable name="ref-class-name" select="'dummy'"/>
        <xsl:variable name="ltype" select="'dummy'"/>
        <xsl:variable name="type" select="xr:getNodeType(@class, $ref-class-name)"/>
        <node>
            <xsl:attribute name="type" select="$type"/>
            <xsl:attribute name="id" select="''"/>
            <xsl:attribute name="ltype" select="$ltype"/>
            <xsl:attribute name="tooltip" select="''"/>
            <xsl:attribute name="href" select="''"/>
            <xsl:attribute name="full-href" select="''"/>
            <xsl:attribute name="title" select="''"/>
            <xsl:attribute name="ishcondition" select="xr:prepareIshconditionValue(@ishcondition)"/>
            <meta/>
            <nested-ishconditions/>
            <children>
                <xsl:apply-templates/>
            </children>
        </node>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/relrow ')]" priority="10">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/relcell ')]" priority="10">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/image ')]" priority="10">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[not(@href) and not(@conref)
                    and not(contains(@class, ' bookmap/chapter ')
                    or contains(@class, ' bookmap/appendix ')
                    or contains(@class, ' bookmap/part '))]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="*[not(@href) and not(@conref)
                    and (contains(@class, ' bookmap/chapter ')
                    or contains(@class, ' bookmap/appendix ')
                    or contains(@class, ' bookmap/part '))]">
        <xsl:variable name="ref-class-name" select="'dummy'"/>
        <xsl:variable name="ltype" select="'dummy'"/>
        <xsl:variable name="type" select="xr:getNodeType(@class, $ref-class-name)"/>
        <xsl:if test="descendant::*[contains(@class, ' map/topicref ')]">
            <node>
                <xsl:attribute name="type" select="$type"/>
                <xsl:attribute name="id" select="''"/>
                <xsl:attribute name="ltype" select="$ltype"/>
                <xsl:attribute name="tooltip" select="''"/>
                <xsl:attribute name="href" select="''"/>
                <xsl:attribute name="full-href" select="''"/>
                <xsl:attribute name="title" select="''"/>
                <xsl:attribute name="ishcondition" select="xr:prepareIshconditionValue(@ishcondition)"/>
                <meta/>
                <nested-ishconditions/>
                <children>
                    <xsl:apply-templates/>
                </children>
            </node>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[@conref]">
        <xsl:variable name="ref-base-uri" select="base-uri()"/>
        <xsl:variable name="ref-base-name" select="tokenize($ref-base-uri,'/')[last()]"/>

        <xsl:variable name="href" select="@conref"/>
        <xsl:variable name="class-name" select="@class"/>

        <xsl:variable name="ref-file-name" >
            <xsl:choose>
                <xsl:when test="matches($href, '^.*\..*#')">
                    <xsl:value-of select="substring-before($href, '#')"/>
                </xsl:when>
                <xsl:when test="matches($href, '^#.*$')">
                    <!--  it means that this is reference to ELEMENT in current file so metadata is needless-->
                    <xsl:value-of select="$ref-base-name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="meta-name" select="xr:getMetaFileName($ref-file-name)"/>
        <xsl:variable name="meta-uri" select="concat('file:///', $sourcedir-path, '/', $meta-name)"/>
        <xsl:variable name="meta-doc" select="if(not(xr:hrefIsExternal(.)) and doc-available($meta-uri))
                                            then(document($meta-uri)) else()"/>

        <xsl:variable name="ref-file-uri" select="concat('file:///', $sourcedir-path, '/', $ref-file-name)"/>
        <xsl:variable name="ref-file-doc" select="if(not(xr:hrefIsExternal(.)) and doc-available($ref-file-uri))
                                            then(document($ref-file-uri)) else()"/>

        <xsl:variable name="ref-root-id" select="if(doc-available($ref-file-uri)) then($ref-file-doc/*/@id) else('')"/>
        <xsl:variable name="ref-root-class" select="if(doc-available($ref-file-uri)) then($ref-file-doc/*/@class) else('')"/>
        <xsl:variable name="ref-node" select="xr:getReferencedNode(., $ref-file-uri, /)"/>
        <xsl:variable name="ref-id" select="$ref-node/*/@id"/>
        <xsl:variable name="ref-class-name" select="$ref-node/*/@class"/>
        <xsl:variable name="ref-shortdesc">
            <xsl:choose>
                <xsl:when test="contains($ref-class-name, ' topic/topic ') and $ref-node/*/child::*[contains(@class, ' topic/shortdesc ')][1]">
                    <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' topic/shortdesc ')][1]/normalize-space(.)"/>
                </xsl:when>
                <xsl:when test="contains($ref-class-name, ' map/map ')">
                    <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' map/topicmeta ')][1]
                                    /descendant::*[contains(@class, ' map/shortdesc ')][1]
                                    /normalize-space(.)"/>
                </xsl:when>
                <xsl:when test="contains($ref-root-class, ' topic/topic ') and $ref-file-doc/*/child::*[contains(@class, ' topic/shortdesc ')][1]">
                    <xsl:value-of select="$ref-file-doc/*/child::*[contains(@class, ' topic/shortdesc ')][1]/normalize-space(.)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ref-title">
            <xsl:if test="doc-available($ref-file-uri)">
                <xsl:choose>
                    <xsl:when test="contains($ref-class-name, ' bookmap/bookmap ')">
                        <xsl:value-of select="$ref-node/*/descendant::*[contains(@class, ' bookmap/mainbooktitle ')][1]/normalize-space(.)"/>
                    </xsl:when>
                    <xsl:when test="contains($ref-class-name, ' map/map ')">
                        <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' topic/title ')][1]/normalize-space(.)"/>
                    </xsl:when>
                    <xsl:when test="$ref-node/*/child::*[contains(@class, ' topic/title ')][1]">
                        <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' topic/title ')][1]/normalize-space(.)"/>
                    </xsl:when>
                    <xsl:when
                            test="contains($ref-root-class, ' topic/topic ') and $ref-file-doc/*/child::*[contains(@class, ' topic/title ')][1]">
                        <xsl:value-of select="$ref-file-doc/*/child::*[contains(@class, ' topic/title ')][1]/normalize-space(.)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="ref-ftitle" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FTITLE'])
                                            else('')"/>
        <xsl:variable name="ref-LCAversion" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'VERSION'])
                                            else('')"/>
        <xsl:variable name="ref-LCArevision" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FISHREVCOUNTER'])
                                            else('')"/>
        <xsl:variable name="ref-LCAstatus" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FSTATUS'])
                                            else('')"/>

        <xsl:variable name="href-is-valid" select="xr:elementHrefIsValid(.)"/>
        <xsl:variable name="element-exists" select="xr:checkIfElementExists(., $ref-file-uri, /)" as="xs:boolean"/>

        <xsl:variable name="ltype">
            <xsl:choose>
                <xsl:when test="$href-is-valid">
                    <xsl:value-of select="'conref'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'broken'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="$element-exists">
                    <xsl:value-of select="xr:getNodeType($class-name, $ref-class-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'broken'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="topic-type">
            <xsl:choose>
                <xsl:when test="$element-exists">
                    <xsl:value-of select="xr:getNodeType($ref-root-class, $ref-root-class)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'broken'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="full-href">
            <xsl:choose>
                <xsl:when test="$type = 'E' and matches($href, '^.*\..*#.*$')">
                    <!-- element in some other file-->
                    <xsl:value-of select="$href"/>
                </xsl:when>
                <xsl:when test="matches($href, '^#.*$')">
                    <!-- element in current file-->
                    <xsl:variable name="node-base-uri" select="base-uri(.)"/>
                    <xsl:variable name="node-base-name" select="tokenize($node-base-uri,'/')[last()]"/>

                    <xsl:value-of select="concat($node-base-name, $href)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($ref-file-name, '#', $ref-id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="topic-full-href">
            <xsl:value-of select="concat($ref-file-name, '#', $ref-root-id)"/>
        </xsl:variable>

        <xsl:variable name="tooltip">
            <xsl:choose>
                <xsl:when test="($ref-title != '') and ($ref-title != 'Untitled')">
                    <xsl:value-of select="$ref-title"/>
                </xsl:when>
                <xsl:when test="(($ltype = 'mail') or ($ltype = 'xref-external')) and ($href != '')">
                    <xsl:value-of select="$href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ref-ftitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="ishcondition">
            <xsl:choose>
                <xsl:when test="normalize-space(@ishcondition)">
                    <xsl:value-of select="@ishcondition"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ref-node/*/@ishcondition"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <node>
            <xsl:attribute name="type" select="$topic-type"/>
            <xsl:attribute name="id" select="$ref-root-id"/>
            <xsl:attribute name="ltype" select="$ltype"/>
            <xsl:attribute name="tooltip" select="$tooltip"/>
            <xsl:attribute name="href" select="$topic-full-href"/>
            <xsl:attribute name="full-href" select="$topic-full-href"/>
            <xsl:attribute name="title" select="$ref-title"/>
            <xsl:attribute name="ishcondition" select="''"/>
            <meta>
                <xsl:attribute name="ftitle" select="$ref-ftitle"/>
                <xsl:attribute name="shortdesc" select="$ref-shortdesc"/>
                <xsl:attribute name="LCAversion" select="$ref-LCAversion"/>
                <xsl:attribute name="LCArevision" select="$ref-LCArevision"/>
                <xsl:attribute name="LCAstatus" select="$ref-LCAstatus"/>
            </meta>
            <xsl:variable name="nested-ishconditions">
                <xsl:if test="doc-available($ref-file-uri)">
                    <xsl:for-each select="$ref-file-doc/descendant::*[normalize-space(@ishcondition)]/@ishcondition">
                        <ishcondition><xsl:value-of select="xr:prepareIshconditionValue(.)"/></ishcondition>
                    </xsl:for-each>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="unique-nested-ishconditions" select="xr:getUniqueIshconditions($nested-ishconditions)"/>
            <nested-ishconditions>
                <xsl:for-each select="$unique-nested-ishconditions/ishcondition">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </nested-ishconditions>
            <children>
                <node>
                    <xsl:attribute name="type" select="$type"/>
                    <xsl:attribute name="id" select="$ref-id"/>
                    <xsl:attribute name="ltype" select="$ltype"/>
                    <xsl:attribute name="tooltip" select="$tooltip"/>
                    <xsl:attribute name="href" select="$href"/>
                    <xsl:attribute name="full-href" select="$full-href"/>
                    <xsl:attribute name="title" select="$ref-title"/>
                    <xsl:attribute name="ishcondition" select="$ishcondition"/>
                    <meta>
                        <xsl:attribute name="ftitle" select="$ref-ftitle"/>
                        <xsl:attribute name="shortdesc" select="$ref-shortdesc"/>
                        <xsl:attribute name="LCAversion" select="$ref-LCAversion"/>
                        <xsl:attribute name="LCArevision" select="$ref-LCArevision"/>
                        <xsl:attribute name="LCAstatus" select="$ref-LCAstatus"/>
                    </meta>
                    <nested-ishconditions>
                    </nested-ishconditions>
                    <children>
                        <xsl:if test="contains(@class, ' map/topicref ')
                            and not(ancestor::*[contains(@class, ' map/reltable ')])
                            and not(ancestor::*[contains(@class, ' topic/related-links ')])
                            and doc-available($ref-file-uri)">
                            <xsl:apply-templates
                                    select="$ref-file-doc/*[contains(@class, ' map/map ') or contains(@class, ' topic/topic ')]/*"/>
                        </xsl:if>
                        <xsl:apply-templates/>
                    </children>
                </node>
            </children>
        </node>
    </xsl:template>

    <xsl:template match="*[@href]">
        <xsl:variable name="ref-base-uri" select="base-uri()"/>
        <xsl:variable name="ref-base-name" select="tokenize($ref-base-uri,'/')[last()]"/>

        <xsl:variable name="href" select="@href"/>
        <xsl:variable name="class-name" select="@class"/>

        <xsl:variable name="ref-file-name" >
            <xsl:choose>
                <xsl:when test="matches($href, '^.*\..*#')">
                    <xsl:value-of select="substring-before($href, '#')"/>
                </xsl:when>
                <xsl:when test="matches($href, '^#.*$')">
                    <!--  it means that this is reference to ELEMENT in current file so metadata is needless-->
                    <xsl:value-of select="$ref-base-name"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="meta-name" select="xr:getMetaFileName($ref-file-name)"/>
        <xsl:variable name="meta-uri" select="concat('file:///', $sourcedir-path, '/', $meta-name)"/>
        <xsl:variable name="meta-doc" select="if(not(xr:hrefIsExternal(.)) and doc-available($meta-uri))
                                            then(document($meta-uri)) else()"/>

        <xsl:variable name="ref-file-uri" select="concat('file:///', $sourcedir-path, '/', $ref-file-name)"/>
        <xsl:variable name="ref-file-doc" select="if(not(xr:hrefIsExternal(.)) and doc-available($ref-file-uri))
                                            then(document($ref-file-uri)) else()"/>

        <xsl:variable name="ref-node" select="xr:getReferencedNode(., $ref-file-uri, /)"/>
        <xsl:variable name="ref-id" select="$ref-node/*/@id"/>
        <xsl:variable name="ref-class-name" select="$ref-node/*/@class"/>
        <xsl:variable name="ref-shortdesc">
            <xsl:choose>
                <xsl:when test="contains($ref-class-name, ' topic/topic ') and $ref-node/*/child::*[contains(@class, ' topic/shortdesc ')][1]">
                    <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' topic/shortdesc ')][1]/normalize-space(.)"/>
                </xsl:when>
                <xsl:when test="contains($ref-class-name, ' map/map ')">
                    <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' map/topicmeta ')][1]
                                    /descendant::*[contains(@class, ' map/shortdesc ')][1]
                                    /normalize-space(.)"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="ref-title">
            <xsl:if test="doc-available($ref-file-uri)">
                <xsl:choose>
                    <xsl:when test="contains($ref-class-name, ' bookmap/bookmap ')">
                        <xsl:value-of select="$ref-node/*/descendant::*[contains(@class, ' bookmap/mainbooktitle ')][1]/normalize-space(.)"/>
                    </xsl:when>
                    <xsl:when test="contains($ref-class-name, ' map/map ')">
                        <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' topic/title ')][1]/normalize-space(.)"/>
                    </xsl:when>
                    <xsl:when test="$ref-node/*/child::*[contains(@class, ' topic/title ')][1]">
                        <xsl:value-of select="$ref-node/*/child::*[contains(@class, ' topic/title ')][1]/normalize-space(.)"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:variable>

        <xsl:variable name="ref-ftitle" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FTITLE'])
                                            else('')"/>
        <xsl:variable name="ref-LCAversion" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'VERSION'])
                                            else('')"/>
        <xsl:variable name="ref-LCArevision" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FISHREVCOUNTER'])
                                            else('')"/>
        <xsl:variable name="ref-LCAstatus" select="if(doc-available($meta-uri))
                                            then($meta-doc/descendant::*[@name = 'FSTATUS'])
                                            else('')"/>

        <xsl:variable name="href-is-valid" select="xr:elementHrefIsValid(.)"/>
        <xsl:variable name="element-exists" select="xr:checkIfElementExists(., $ref-file-uri, /)" as="xs:boolean"/>

        <xsl:variable name="ltype">
            <xsl:choose>
                <xsl:when test="$href-is-valid">
                    <xsl:choose>
                        <xsl:when test="xr:hrefIsExternal(.)">
                            <xsl:value-of select="'xref-external'"/>
                        </xsl:when>
                        <xsl:when test="contains(@class, ' topic/xref ')">
                            <xsl:value-of select="'xref-internal'"/>
                        </xsl:when>
                        <xsl:when test="contains(@class, ' map/topicref ')">
                            <xsl:choose>
                                <xsl:when test="ancestor::*[contains(@class, ' map/reltable ')]">
                                    <xsl:value-of select="'rel-topicref'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'topicref'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'broken'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'broken'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="type">
            <xsl:choose>
                <xsl:when test="xr:hrefIsExternal(.) and matches($href, '^mailto:.*')">
                    <xsl:value-of select="'mail'"/>
                </xsl:when>
                <xsl:when test="xr:hrefIsExternal(.)">
                    <xsl:value-of select="'I'"/>
                </xsl:when>
                <xsl:when test="$element-exists">
                    <xsl:value-of select="xr:getNodeType($class-name, $ref-class-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'broken'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="full-href">
            <xsl:choose>
                <xsl:when test="$type = 'mail' or $type = 'I' or $type = 'broken'"/>
                <xsl:when test="$type = 'E' and matches($href, '^.*\..*#.*$')">
                    <!-- element in some other file-->
                    <xsl:value-of select="$href"/>
                </xsl:when>
                <xsl:when test="matches($href, '^#.*$')">
                    <!-- element in current file-->
                    <xsl:variable name="node-base-uri" select="base-uri(.)"/>
                    <xsl:variable name="node-base-name" select="tokenize($node-base-uri,'/')[last()]"/>

                    <xsl:value-of select="concat($node-base-name, $href)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat($ref-file-name, '#', $ref-id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="tooltip">
            <xsl:choose>
                <xsl:when test="($ref-title != '') and ($ref-title != 'Untitled')">
                    <xsl:value-of select="$ref-title"/>
                </xsl:when>
                <xsl:when test="(($ltype = 'mail') or ($ltype = 'xref-external')) and ($href != '')">
                    <xsl:value-of select="$href"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$ref-ftitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <node>
            <xsl:attribute name="type" select="$type"/>
            <xsl:attribute name="id" select="$ref-id"/>
            <xsl:attribute name="ltype" select="$ltype"/>
            <xsl:attribute name="tooltip" select="$tooltip"/>
            <xsl:attribute name="href" select="$href"/>
            <xsl:attribute name="full-href" select="$full-href"/>
            <xsl:attribute name="title" select="$ref-title"/>
            <xsl:attribute name="ishcondition" select="if($ltype = 'xref-external' or $ltype = 'xref-internal' or $ltype = 'broken') then('') else(xr:prepareIshconditionValue(@ishcondition))"/>
            <meta>
                <xsl:attribute name="ftitle" select="$ref-ftitle"/>
                <xsl:attribute name="shortdesc" select="$ref-shortdesc"/>
                <xsl:attribute name="LCAversion" select="$ref-LCAversion"/>
                <xsl:attribute name="LCArevision" select="$ref-LCArevision"/>
                <xsl:attribute name="LCAstatus" select="$ref-LCAstatus"/>
            </meta>
            <xsl:variable name="nested-ishconditions">
                <xsl:if test="doc-available($ref-file-uri)">
                    <xsl:for-each select="$ref-file-doc/descendant::*[normalize-space(@ishcondition)]/@ishcondition">
                        <ishcondition><xsl:value-of select="xr:prepareIshconditionValue(.)"/></ishcondition>
                    </xsl:for-each>
                </xsl:if>
            </xsl:variable>
            <xsl:variable name="unique-nested-ishconditions" select="xr:getUniqueIshconditions($nested-ishconditions)"/>
            <nested-ishconditions>
                <xsl:for-each select="$unique-nested-ishconditions/ishcondition">
                    <xsl:copy-of select="."/>
                </xsl:for-each>
            </nested-ishconditions>
            <children>
                <xsl:if test="contains(@class, ' map/topicref ')
                            and not(ancestor::*[contains(@class, ' map/reltable ')])
                            and not(ancestor::*[contains(@class, ' topic/related-links ')])
                            and doc-available($ref-file-uri)">
                    <xsl:apply-templates
                            select="$ref-file-doc/*[contains(@class, ' map/map ') or contains(@class, ' topic/topic ')]/*"/>
                </xsl:if>
                <xsl:apply-templates/>
            </children>
        </node>
    </xsl:template>

    <xsl:template match="text()" priority="10"/>

    <xsl:function name="xr:getMetaFileName">
        <xsl:param name="filename"/>

        <xsl:variable name="correct-filename">
            <xsl:choose>
                <xsl:when test="contains($filename, '.')">
                    <xsl:value-of select="substring-before($filename, '.')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$filename"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="concat($correct-filename, '.met')"/>
    </xsl:function>

    <xsl:function name="xr:getNodeType">
        <xsl:param name="className"/>
        <xsl:param name="refClassName"/>

        <xsl:variable name="node-type">
            <xsl:choose>
                <xsl:when test="normalize-space($refClassName) = ''">
                    <xsl:value-of select="'broken'"/>
                </xsl:when>
                <xsl:when test="contains($className, ' bookmap/chapter ')">
                    <xsl:value-of select="'CH'"/>
                </xsl:when>
                <xsl:when test="contains($className, ' bookmap/appendix ')">
                    <xsl:value-of select="'A'"/>
                </xsl:when>
                <xsl:when test="contains($className, ' bookmap/part ')">
                    <xsl:value-of select="'P'"/>
                </xsl:when>
                <xsl:when test="contains($className, ' map/reltable ')">
                    <xsl:value-of select="'RT'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' bookmap/bookmap ')">
                    <xsl:value-of select="'B'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' map/map ')">
                    <xsl:value-of select="'M'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' glossentry/glossentry ')
                            or contains($refClassName, ' glossgroup/glossgroup ')">
                    <xsl:value-of select="'G'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' concept/concept ')">
                    <xsl:value-of select="'C'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' task/task ')">
                    <xsl:value-of select="'T'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' reference/reference ')">
                    <xsl:value-of select="'R'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' topic/cli ')">
                    <xsl:value-of select="'CLI'"/>
                </xsl:when>
                <xsl:when test="contains($refClassName, ' topic/topic ')">
                    <xsl:value-of select="'gT'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'E'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="$node-type"/>
    </xsl:function>

    <xsl:function name="xr:getReferencedNode" as="item()*">
        <xsl:param name="elem"/>
        <xsl:param name="ref-uri"/>
        <xsl:param name="current-file"/>

        <xsl:variable name="href" select="if($elem/@conref) then($elem/@conref) else($elem/@href)"/>
        <xsl:variable name="hrefIsExternal" select="xr:hrefIsExternal($elem)"/>
        <xsl:variable name="file-doc" select="if(not($hrefIsExternal)) then(document($ref-uri)) else ()"/>

        <xsl:variable name="contains-filename" select="matches($href, '^.*\..*')"/>
        <xsl:variable name="contains-root-id" select="matches($href, '^.*#.*')"/>
        <xsl:variable name="contains-descendant-id" select="matches($href, '^.*/.*')"/>

        <xsl:variable name="filename" select="if(contains($href, '#')) then(substring-before($href, '#')) else($href)"/>
        <xsl:variable name="descendants" select="substring-after($href, $filename)"/>

        <xsl:variable name="root-id">
            <xsl:choose>
                <xsl:when test="contains($descendants, '/')">
                    <xsl:value-of select="substring-before(substring-after($descendants, '#'), '/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after($descendants, '#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="descendant-id" select="substring-after($descendants, '/')"/>

        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when
                        test="$contains-filename and not($contains-root-id) and not($contains-descendant-id) and doc-available($ref-uri)">
                    <xsl:copy-of select="$file-doc/*[contains(@class, ' map/map ') or contains(@class, ' topic/topic ')][1]"/>
                </xsl:when>
                <xsl:when test="$contains-filename and $contains-root-id and not($contains-descendant-id) and doc-available($ref-uri)">
                    <xsl:copy-of select="$file-doc/descendant::*[@id = $root-id][1]"/>
                </xsl:when>
                <xsl:when test="$contains-filename and $contains-root-id and $contains-descendant-id and doc-available($ref-uri)">
                    <xsl:copy-of select="$file-doc/descendant::*[@id = $root-id][1]/descendant::*[@id = $descendant-id][1]"/>
                </xsl:when>
                <xsl:when test="not($contains-filename) and $contains-root-id and not($contains-descendant-id)">
                    <xsl:copy-of select="$current-file/descendant::*[@id = $root-id][1]"/>
                </xsl:when>
                <xsl:when test="not($contains-filename) and $contains-root-id and $contains-descendant-id">
                    <xsl:copy-of select="$current-file/descendant::*[@id = $root-id][1]/descendant::*[@id = $descendant-id][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <dummy/>
                </xsl:otherwise>
            </xsl:choose>

        </xsl:variable>

        <xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="xr:checkIfElementExists">
        <xsl:param name="elem"/>
        <xsl:param name="ref-uri"/>
        <xsl:param name="current-file"/>

        <xsl:variable name="href" select="if($elem/@conref) then($elem/@conref) else($elem/@href)"/>
        <xsl:variable name="hrefIsExternal" select="xr:hrefIsExternal($elem)"/>
        <xsl:variable name="file-doc" select="if(not($hrefIsExternal) and doc-available($ref-uri)) then(document($ref-uri)) else()"/>

        <xsl:variable name="contains-filename" select="matches($href, '^.*\..*')"/>
        <xsl:variable name="contains-root-id" select="matches($href, '^.*#.*')"/>
        <xsl:variable name="contains-descendant-id" select="matches($href, '^.*/.*')"/>

        <xsl:variable name="filename" select="if(contains($href, '#')) then(substring-before($href, '#')) else($href)"/>
        <xsl:variable name="descendants" select="substring-after($href, $filename)"/>

        <xsl:variable name="root-id">
            <xsl:choose>
                <xsl:when test="contains($descendants, '/')">
                    <xsl:value-of select="substring-before(substring-after($descendants, '#'), '/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="substring-after($descendants, '#')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="descendant-id" select="substring-after($descendants, '/')"/>
        <xsl:variable name="result">
             <xsl:choose>
                 <xsl:when test="$contains-filename and not($contains-root-id) and not($contains-descendant-id)">
                    <xsl:value-of select="exists($file-doc/descendant::*[@id])"/>
                </xsl:when>
                <xsl:when test="$contains-filename and $contains-root-id and not($contains-descendant-id)">
                    <xsl:value-of select="exists($file-doc/descendant::*[@id = $root-id])"/>
                </xsl:when>
                <xsl:when test="$contains-filename and $contains-root-id and $contains-descendant-id">
                    <xsl:value-of select="exists($file-doc/descendant::*[@id = $root-id]/descendant::*[@id = $descendant-id])"/>
                </xsl:when>
                <xsl:when test="not($contains-filename) and $contains-root-id and not($contains-descendant-id)">
                    <xsl:value-of select="exists($current-file/descendant::*[@id = $root-id])"/>
                </xsl:when>
                <xsl:when test="not($contains-filename) and $contains-root-id and $contains-descendant-id">
                    <xsl:value-of select="exists($current-file/descendant::*[@id = $root-id]/descendant::*[@id = $descendant-id])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="xr:hrefIsExternal">
        <xsl:param name="elem"/>

        <xsl:variable name="href" select="$elem/@href"/>
        <xsl:variable name="scope" select="$elem/@scope"/>
        <xsl:sequence
                select="(matches($href, '^((https?|HTTPS?)://)?([\da-zA-Z\.-]+)\.([\da-zA-Z\.]{2,6})([/\w \.-]*)*/?.*$')
                            or matches($href, '^mailto:.*')
                            or matches($href, '^.*\.doc$'))
                        and $scope = 'external'"/>
    </xsl:function>

    <xsl:function name="xr:elementHrefIsValid">
        <xsl:param name="elem"/>
        <xsl:variable name="href" select="if($elem/@conref) then($elem/@conref) else($elem/@href)"/>

        <xsl:variable name="hrefIsExternal" select="xr:hrefIsExternal($elem)"/>
        <xsl:variable name="contains-filename" select="matches($href, '^.*\..*')"/>
        <xsl:variable name="contains-root-id" select="matches($href, '^.*#.*')"/>
        <xsl:variable name="contains-descendant-id" select="matches($href, '^.*/.*')"/>

        <xsl:variable name="result">
            <xsl:choose>
                <xsl:when test="$hrefIsExternal">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:when test="$contains-filename and not($contains-root-id) and not($contains-descendant-id)">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:when test="$contains-filename and $contains-root-id and not($contains-descendant-id)">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:when test="not($contains-filename) and $contains-root-id and not($contains-descendant-id)">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:when test="not($contains-filename) and $contains-root-id and $contains-descendant-id">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="$result"/>
    </xsl:function>

    <xsl:function name="xr:getUniqueIshconditions">
        <xsl:param name="nested-ishconditions"/>
        <xsl:variable name="result">
            <xsl:for-each select="$nested-ishconditions/ishcondition">
                <xsl:variable name="current-value" select="normalize-space(.)"/>
                <xsl:if test="not(preceding-sibling::*/normalize-space(.) = $current-value)">
                    <xsl:copy-of select="."/>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$result"/>
    </xsl:function>
</xsl:stylesheet>
