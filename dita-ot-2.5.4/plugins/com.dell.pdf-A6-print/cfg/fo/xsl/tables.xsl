<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fo="http://www.w3.org/1999/XSL/Format"
                xmlns:ia="http://intelliarts.com"
                xmlns:opentopic-func="http://www.idiominc.com/opentopic/exsl/function"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:variable name="table.rowsep-default" select="'1'"/>
    <xsl:variable name="table.colsep-default" select="'1'"/>

    <xsl:template match="*[contains(@class, ' topic/table ')]">
        <!-- FIXME, empty value -->
        <xsl:variable name="scale" as="xs:string?">
            <xsl:call-template name="getTableScale"/>
        </xsl:variable>
        <fo:block-container xsl:use-attribute-sets="table__container">
            <fo:block xsl:use-attribute-sets="table">
                <xsl:attribute name="axf:table-summary">
                    <xsl:value-of select="*[contains(@class, ' topic/desc ')]"/>
                </xsl:attribute>
                <xsl:call-template name="commonattributes"/>
                <xsl:if test="not(@id)">
                    <xsl:attribute name="id">
                        <xsl:call-template name="get-id"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:if test="exists($scale)">
                    <xsl:attribute name="font-size" select="concat($scale, '%')"/>
                </xsl:if>
                <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
                <xsl:apply-templates/>
                <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
            </fo:block>
        </fo:block-container>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')]" mode="from-tgroup">
        <fo:block xsl:use-attribute-sets="table.title" id="{@id}">
            <fo:inline>
                <fo:inline font-weight="bold">
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Table.title'"/>
                        <xsl:with-param name="params" as="element()*">
                            <number>
                              <xsl:choose>
                                  <xsl:when test="$multilingual">
                                        <xsl:number level="any"
                                            count="*[contains(@class, ' topic/table ')][child::*[contains(@class, ' topic/title ')]]"
                                            from="topic[not(ancestor::*[contains(@class, ' topic/topic ')])]"/>
                                  </xsl:when>
                                  <xsl:otherwise>
                                      <xsl:number level="any" count="*[contains(@class, ' topic/table ')]/*[contains(@class, ' topic/title ')]" from="/"/>
                                 </xsl:otherwise>
                              </xsl:choose>
                            </number>
                        </xsl:with-param>
                    </xsl:call-template>
                </fo:inline>
                <xsl:apply-templates/>
                <xsl:text>&#xA0;</xsl:text>
                <fo:retrieve-table-marker retrieve-class-name="continued"/>
            </fo:inline>
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class,' topic/table ')]/*[contains(@class,' topic/title ')]"/>

    <xsl:template match="*[contains(@class, ' topic/table ')]/*[contains(@class,' topic/desc ')]"/>

    <xsl:template match="*[contains(@class, ' topic/tbody ')]/*[contains(@class, ' topic/row ')]">
        <xsl:variable name="frame" as="xs:string">
            <xsl:variable name="f" select="ancestor::*[contains(@class, ' topic/table ')][1]/@frame"/>
            <xsl:choose>
                <xsl:when test="$f">
                    <xsl:value-of select="$f"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$table.frame-default"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <fo:table-row xsl:use-attribute-sets="tbody.row">
            <xsl:variable name="id">
                <xsl:choose>
                    <xsl:when test="@id">
                        <xsl:value-of select="concat('bodyrow-',@id,'should_remain')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('bodyrow-',generate-id(),'should_remain')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="id">
                <xsl:value-of select="$id"/>
            </xsl:attribute>
            <fo:marker marker-class-name="continued">
                <xsl:if test="preceding-sibling::*[contains(@class, ' topic/row ')]">
                    <fo:inline>
                        <!-- Suite/EMC   SOW7    31-Dec-2012   replace continuation notation - rs -->
                        <xsl:call-template name="getVariable">
                            <xsl:with-param name="id" select="'continued'"/>
                        </xsl:call-template>
                    </fo:inline>
                </xsl:if>
            </fo:marker>
            <xsl:apply-templates/>
        </fo:table-row>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/tbody ')]">
        <fo:table-body xsl:use-attribute-sets="tgroup.tbody">
            <xsl:call-template name="commonattributes"/>
            <xsl:apply-templates/>
        </fo:table-body>
    </xsl:template>

    <xsl:template name="generateTableEntryBorder">
        <xsl:variable name="colsep" as="xs:string">
            <xsl:call-template name="getTableColsep"/>
        </xsl:variable>
        <xsl:variable name="rowsep" as="xs:string">
            <xsl:call-template name="getTableRowsep"/>
        </xsl:variable>
        <xsl:variable name="frame" as="xs:string">
            <xsl:variable name="f" select="ancestor::*[contains(@class, ' topic/table ')][1]/@frame"/>
            <xsl:choose>
                <xsl:when test="$f">
                    <xsl:value-of select="$f"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$table.frame-default"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="needTopBorderOnBreak" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$frame = 'all' or $frame = 'topbot' or $frame = 'top'">
                    <xsl:choose>
                        <xsl:when test="../parent::node()[contains(@class, ' topic/thead ')]">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <xsl:when test="(../parent::node()[contains(@class, ' topic/tbody ')]) and not(../preceding-sibling::*[contains(@class, ' topic/row ')]) and (../../preceding-sibling::*[contains(@class, ' topic/thead ')])">
                            <xsl:sequence select="true()"/>
                        </xsl:when>
                        <xsl:when test="(../parent::node()[contains(@class, ' topic/tbody ')]) and not(../preceding-sibling::*[contains(@class, ' topic/row ')]) and (not(../../preceding-sibling::*[contains(@class, ' topic/thead ')]))">
                            <xsl:sequence select="false()"/>
                        </xsl:when>
                        <xsl:when test="../parent::node()[contains(@class, ' topic/tbody ')]">
                            <xsl:variable name="entryNum" select="count(preceding-sibling::*[contains(@class, ' topic/entry ')]) + 1"/>
                            <xsl:variable name="prevEntryRowsep" as="xs:string?">
                                <xsl:for-each select="../preceding-sibling::*[contains(@class, ' topic/row ')][1]/*[contains(@class, ' topic/entry ')][$entryNum]">
                                    <xsl:call-template name="getTableRowsep"/>
                                </xsl:for-each>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$prevEntryRowsep != '0'">
                                    <xsl:sequence select="true()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="false()"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="false()"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="number($rowsep) = 1 and (../parent::node()[contains(@class, ' topic/thead ')])">
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="'thead__tableframe__bottom'"/>
                <xsl:with-param name="path" select="$tableAttrs"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="number($rowsep) = 1 and ((../following-sibling::*[contains(@class, ' topic/row ')]) or (../parent::node()[contains(@class, ' topic/tbody ')] and ancestor::*[contains(@class, ' topic/tgroup ')][1]/*[contains(@class, ' topic/tfoot ')]))">
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="'__tableframe__bottom'"/>
                <xsl:with-param name="path" select="$tableAttrs"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="$needTopBorderOnBreak">
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="'__tableframe__top','__tableframe__bottom'"/>
                <xsl:with-param name="path" select="$tableAttrs"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="number($colsep) = 1 and following-sibling::*[contains(@class, ' topic/entry ')]">
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="'__tableframe__right'"/>
                <xsl:with-param name="path" select="$tableAttrs"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="number($colsep) = 1 and not(following-sibling::*[contains(@class, ' topic/entry ')]) and ((count(preceding-sibling::*) + 1) &lt; ancestor::*[contains(@class, ' topic/tgroup ')][1]/@cols)">
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="'__tableframe__right'"/>
                <xsl:with-param name="path" select="$tableAttrs"/>
            </xsl:call-template>
        </xsl:if>
        <xsl:if test="number($rowsep) = 0 and number($colsep) = 0 and $frame = 'none' and (../parent::node()[contains(@class, ' topic/thead ')])">
            <xsl:call-template name="processAttrSetReflection">
                <xsl:with-param name="attrSet" select="'thead__tableframe__bottom'"/>
                <xsl:with-param name="path" select="$tableAttrs"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/tgroup ')]" name="tgroup">
        <xsl:param name="parent" tunnel="yes" select="''"/>
        <xsl:if test="not(@cols)">
            <xsl:message terminate="yes">
                <xsl:text>ERROR: Number of columns must be specified.</xsl:text>
            </xsl:message>
        </xsl:if>

        <xsl:variable name="scale">
            <xsl:call-template name="getTableScale"/>
        </xsl:variable>

        <xsl:variable name="table">
            <fo:block float="left">
                <xsl:attribute name="space-before">
                    <xsl:choose>
                        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">8pt</xsl:when>
                        <xsl:when test="(parent::*[contains(@class, ' task/info ')][preceding-sibling::*]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">3pt</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="space-before.optimum">
                    <xsl:choose>
                        <xsl:when test="not(parent::*[contains(@class, ' task/info ')]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">8pt</xsl:when>
                        <xsl:when test="(parent::*[contains(@class, ' task/info ')][preceding-sibling::*]) and not(preceding-sibling::*) and ancestor::*[contains(@class, ' topic/li ')]">3pt</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
                <xsl:attribute name="start-indent">
                    <xsl:choose>
                        <xsl:when test="ancestor::*[contains(@class, ' topic/dl ') and not(contains(@class, ' pr-d/parml ')) and ancestor::*[contains(@class, ' task/choices ')]]">0.03</xsl:when>
                        <xsl:when test="ancestor::*[contains(@class, ' topic/dl ') and not(contains(@class, ' pr-d/parml '))]">0.14</xsl:when>
                        <xsl:when test="ancestor::*[contains(@class, ' pr-d/parml ')]">0.12</xsl:when>
                        <xsl:otherwise>0</xsl:otherwise>
                    </xsl:choose>
                    <xsl:text>in</xsl:text>
                </xsl:attribute>
                <fo:table table-omit-footer-at-break="true">
                    <fo:table-column/>
                    <xsl:if test="preceding-sibling::*[contains(@class,' topic/title ')]">
                        <fo:table-header>
                            <fo:table-row>
                                <fo:table-cell id="{@id}">
                                    <xsl:apply-templates
                                            select="preceding-sibling::*[contains(@class,' topic/title ')]"
                                            mode="from-tgroup"/>
                                </fo:table-cell>
                            </fo:table-row>
                        </fo:table-header>
                    </xsl:if>
                    <fo:table-body>
                        <fo:table-row>
                            <xsl:variable name="table">
                                <fo:table xsl:use-attribute-sets="table.tgroup" id="{@id}">
                                    <xsl:call-template name="displayAtts">
                                        <xsl:with-param name="element" select=".."/>
                                    </xsl:call-template>
                                    <xsl:apply-templates/>
                                </fo:table>
                            </xsl:variable>
                            <fo:table-cell>
                                <xsl:copy-of select="$table"/>
                            </fo:table-cell>
                        </fo:table-row>
                        <xsl:if test="descendant::*[contains(@class,' topic/fn ')]">
                            <fo:table-row>
                                <fo:table-cell xsl:use-attribute-sets="tablefootnote">
                                    <fo:block>
                                        <xsl:apply-templates
                                                select="descendant::*[contains(@class,' topic/fn ')]"
                                                mode="from-table"/>
                                    </fo:block>
                                </fo:table-cell>
                            </fo:table-row>
                        </xsl:if>
                    </fo:table-body>
                </fo:table>
            </fo:block>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="not($scale = '')">
                <xsl:apply-templates select="$table" mode="setTableEntriesScale"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="$table"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/dl ')]">
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-startprop ')]" mode="outofline"/>
        <fo:table xsl:use-attribute-sets="dl">
            <!--<xsl:call-template name="commonattributes"/>-->
            <!--<fo:table-column column-width="15mm"/>-->
            <!--<fo:table-column/>-->
            <xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]"/>
            <fo:table-body xsl:use-attribute-sets="dl__body">
                <xsl:choose>
                    <xsl:when test="contains(@otherprops,'sortable')">
                        <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]">
                            <xsl:sort
                                    select="opentopic-func:getSortString(normalize-space( opentopic-func:fetchValueableText(*[contains(@class, ' topic/dt ')]) ))"
                                    lang="{$locale}"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="*[contains(@class, ' topic/dlentry ')]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </fo:table-body>
        </fo:table>
        <xsl:apply-templates select="*[contains(@class,' ditaot-d/ditaval-endprop ')]" mode="outofline"/>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fn ')][ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]">
        <xsl:choose>
            <xsl:when test="normalize-space(@id)"/>
            <xsl:otherwise>
                <fo:basic-link font-style="normal">
                    <xsl:attribute name="internal-destination" select="generate-id(.)"/>
                    <fo:inline xsl:use-attribute-sets="fn__callout_ref">
                        <xsl:variable name="tableId" select="ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.)"/>
                        <xsl:variable name="tableFnCountRef" select="count(preceding::*[contains(@class, ' topic/fn ') and ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ') and generate-id(.) = $tableId] and ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id(.) = $tableId])"/>
                        <xsl:choose>
                            <xsl:when test="translate($locale, 'RU', 'ru') = 'ru'">
                                <xsl:number format="&#x0430;" value="$tableFnCountRef + 1"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:number format="a" value="$tableFnCountRef + 1"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </fo:inline>
                </fo:basic-link>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/fn ')]" mode="from-table">
        <fo:block xsl:use-attribute-sets="fn_container">
            <fo:list-block xsl:use-attribute-sets="fn__body">
                <xsl:attribute name="id">
                    <xsl:value-of select="generate-id(.)"/>
                </xsl:attribute>
                <fo:list-item>
                    <fo:list-item-label end-indent="label-end()">
                        <fo:block text-align="right">
                            <fo:inline xsl:use-attribute-sets="fn__callout">
                                <xsl:variable name="tableId" select="ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]/generate-id()"/>
                                <xsl:comment>tableId=<xsl:value-of select="$tableId"/></xsl:comment>
                                <xsl:choose>
                                    <xsl:when test="translate($locale, 'RU', 'ru') = 'ru'">
                                        <xsl:number format="&#x0430;."
                                                    from="//*[(contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')) and generate-id() = $tableId]"
                                                    level="any"
                                                    count="*[contains(@class, ' topic/fn ')][ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:number format="a."
                                                    from="//*[(contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')) and generate-id() = $tableId]"
                                                    level="any"
                                                    count="*[contains(@class, ' topic/fn ')][ancestor::*[contains(@class, ' topic/table ') or contains(@class, ' topic/simpletable ') or contains(@class, ' task/choicetable ')]]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
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
        </fo:block>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/thead ')]/*[contains(@class, ' topic/row ')]/*[contains(@class, ' topic/entry ')]">
        <fo:table-cell xsl:use-attribute-sets="thead.row.entry">
            <xsl:call-template name="commonattributes"/>
            <xsl:call-template name="applySpansAttrs"/>
            <xsl:call-template name="applyAlignAttrs"/>
            <xsl:call-template name="generateTableEntryBorder"/>
            <xsl:choose>
                <xsl:when test="ia:isVerticalEntry(.)">
                    <fo:block-container>
                        <xsl:call-template name="applyVerticalAlignAttrs"/>
                        <fo:block xsl:use-attribute-sets="thead.row.entry__content">
                            <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                            <xsl:call-template name="processEntryContent"/>
                            <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                        </fo:block>
                    </fo:block-container>
                </xsl:when>
                <xsl:otherwise>
                    <fo:block xsl:use-attribute-sets="thead.row.entry__content">
                        <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                        <xsl:call-template name="processEntryContent"/>
                        <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                    </fo:block>
                </xsl:otherwise>
            </xsl:choose>
        </fo:table-cell>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/tbody ')]/*[contains(@class, ' topic/row ')]/*[contains(@class, ' topic/entry ')]">
        <xsl:choose>
            <xsl:when test="ancestor::*[contains(@class, ' topic/table ')][1]/@rowheader = 'firstcol'
                        and empty(preceding-sibling::*[contains(@class, ' topic/entry ')])">
                <fo:table-cell xsl:use-attribute-sets="tbody.row.entry__firstcol">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="applySpansAttrs"/>
                    <xsl:call-template name="applyAlignAttrs"/>
                    <xsl:call-template name="generateTableEntryBorder"/>
                    <xsl:choose>
                        <xsl:when test="ia:isVerticalEntry(.)">
                            <fo:block-container>
                                <xsl:call-template name="applyVerticalAlignAttrs"/>
                                <fo:block xsl:use-attribute-sets="tbody.row.entry__content">
                                    <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                    <xsl:call-template name="processEntryContent"/>
                                    <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                                </fo:block>
                            </fo:block-container>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block xsl:use-attribute-sets="tbody.row.entry__content">
                                <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                <xsl:call-template name="processEntryContent"/>
                                <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:table-cell>
            </xsl:when>
            <xsl:otherwise>
                <fo:table-cell xsl:use-attribute-sets="tbody.row.entry">
                    <xsl:call-template name="commonattributes"/>
                    <xsl:call-template name="applySpansAttrs"/>
                    <xsl:call-template name="applyAlignAttrs"/>
                    <xsl:call-template name="generateTableEntryBorder"/>
                    <xsl:choose>
                        <xsl:when test="ia:isVerticalEntry(.)">
                            <fo:block-container>
                                <xsl:call-template name="applyVerticalAlignAttrs"/>
                                <fo:block xsl:use-attribute-sets="tbody.row.entry__content">
                                    <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                    <xsl:call-template name="processEntryContent"/>
                                    <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                                </fo:block>
                            </fo:block-container>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block xsl:use-attribute-sets="tbody.row.entry__content">
                                <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                <xsl:call-template name="processEntryContent"/>
                                <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </fo:table-cell>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/sthead ')]/*[contains(@class, ' topic/stentry ')]">
        <fo:table-cell xsl:use-attribute-sets="sthead.stentry">
            <xsl:call-template name="commonattributes"/>
            <xsl:variable name="entryCol" select="count(preceding-sibling::*[contains(@class, ' topic/stentry ')]) + 1"/>
            <xsl:variable name="frame" as="xs:string">
                <xsl:variable name="f" select="ancestor::*[contains(@class, ' topic/simpletable ')][1]/@frame"/>
                <xsl:choose>
                    <xsl:when test="$f">
                        <xsl:value-of select="$f"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$table.frame-default"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:call-template name="generateSimpleTableHorizontalBorders">
                <xsl:with-param name="frame" select="$frame"/>
            </xsl:call-template>
            <xsl:if test="$frame = 'all' or $frame = 'topbot' or $frame = 'top'">
                <xsl:call-template name="processAttrSetReflection">
                    <xsl:with-param name="attrSet" select="'__tableframe__top'"/>
                    <xsl:with-param name="path" select="$tableAttrs"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="following-sibling::*[contains(@class, ' topic/stentry ')]">
                <xsl:call-template name="generateSimpleTableVerticalBorders">
                    <xsl:with-param name="frame" select="$frame"/>
                </xsl:call-template>
            </xsl:if>

            <xsl:variable name="valign" as="xs:string?">
                <xsl:choose>
                    <xsl:when test="@valign">
                        <xsl:value-of select="@valign"/>
                    </xsl:when>
                    <xsl:when test="parent::*[contains(@class, ' topic/row ')][@valign]">
                        <xsl:value-of select="parent::*[contains(@class, ' topic/row ')]/@valign"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="$valign='top'">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'before'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="$valign='middle'">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'center'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="$valign='bottom'">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'after'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="ia:isVerticalEntry(.)">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'after'"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>

            <xsl:choose>
                <xsl:when test="number(ancestor::*[contains(@class, ' topic/simpletable ')][1]/@keycol) = $entryCol">
                    <xsl:choose>
                        <xsl:when test="ia:isVerticalEntry(.)">
                            <fo:block-container>
                                <xsl:call-template name="applyVerticalAlignAttrs"/>
                                <fo:block xsl:use-attribute-sets="sthead.stentry__keycol-content">
                                    <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                    <xsl:apply-templates/>
                                    <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                                </fo:block>
                            </fo:block-container>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block xsl:use-attribute-sets="sthead.stentry__keycol-content">
                                <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                <xsl:apply-templates/>
                                <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="ia:isVerticalEntry(.)">
                            <fo:block-container>
                                <xsl:call-template name="applyVerticalAlignAttrs"/>
                                <fo:block xsl:use-attribute-sets="sthead.stentry__content">
                                    <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                    <xsl:apply-templates/>
                                    <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                                </fo:block>
                            </fo:block-container>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block xsl:use-attribute-sets="sthead.stentry__content">
                                <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                <xsl:apply-templates/>
                                <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </fo:table-cell>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' topic/strow ')]/*[contains(@class, ' topic/stentry ')]">
        <fo:table-cell xsl:use-attribute-sets="strow.stentry">
            <xsl:call-template name="commonattributes"/>
            <xsl:variable name="entryCol" select="count(preceding-sibling::*[contains(@class, ' topic/stentry ')]) + 1"/>
            <xsl:variable name="frame" as="xs:string">
                <xsl:variable name="f" select="ancestor::*[contains(@class, ' topic/simpletable ')][1]/@frame"/>
                <xsl:choose>
                    <xsl:when test="$f">
                        <xsl:value-of select="$f"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$table.frame-default"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:if test="../following-sibling::*[contains(@class, ' topic/strow ')]">
                <xsl:call-template name="generateSimpleTableHorizontalBorders">
                    <xsl:with-param name="frame" select="$frame"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="following-sibling::*[contains(@class, ' topic/stentry ')]">
                <xsl:call-template name="generateSimpleTableVerticalBorders">
                    <xsl:with-param name="frame" select="$frame"/>
                </xsl:call-template>
            </xsl:if>

            <xsl:variable name="valign" as="xs:string?">
                <xsl:choose>
                    <xsl:when test="@valign">
                        <xsl:value-of select="@valign"/>
                    </xsl:when>
                    <xsl:when test="parent::*[contains(@class, ' topic/row ')][@valign]">
                        <xsl:value-of select="parent::*[contains(@class, ' topic/row ')]/@valign"/>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>

            <xsl:choose>
                <xsl:when test="$valign='top'">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'before'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="$valign='middle'">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'center'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="$valign='bottom'">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'after'"/>
                    </xsl:attribute>
                </xsl:when>
                <xsl:when test="ia:isVerticalEntry(.)">
                    <xsl:attribute name="display-align">
                        <xsl:value-of select="'after'"/>
                    </xsl:attribute>
                </xsl:when>
            </xsl:choose>

            <xsl:choose>
                <xsl:when test="number(ancestor::*[contains(@class, ' topic/simpletable ')][1]/@keycol) = $entryCol">
                    <xsl:choose>
                        <xsl:when test="ia:isVerticalEntry(.)">
                            <fo:block-container>
                                <xsl:call-template name="applyVerticalAlignAttrs"/>
                                <fo:block xsl:use-attribute-sets="strow.stentry__keycol-content">
                                    <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                    <xsl:apply-templates/>
                                    <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                                </fo:block>
                            </fo:block-container>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block xsl:use-attribute-sets="strow.stentry__keycol-content">
                                <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                <xsl:apply-templates/>
                                <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="ia:isVerticalEntry(.)">
                            <fo:block-container>
                                <xsl:call-template name="applyVerticalAlignAttrs"/>
                                <fo:block xsl:use-attribute-sets="strow.stentry__content">
                                    <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                    <xsl:apply-templates/>
                                    <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                                </fo:block>
                            </fo:block-container>
                        </xsl:when>
                        <xsl:otherwise>
                            <fo:block xsl:use-attribute-sets="strow.stentry__content">
                                <xsl:apply-templates select="." mode="ancestor-start-flag"/>
                                <xsl:apply-templates/>
                                <xsl:apply-templates select="." mode="ancestor-end-flag"/>
                            </fo:block>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </fo:table-cell>
    </xsl:template>

    <xsl:template name="applyAlignAttrs">
        <xsl:variable name="align" as="xs:string?">
            <xsl:choose>
                <xsl:when test="@align">
                    <xsl:value-of select="@align"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/tbody ')][1][@align]">
                    <xsl:value-of select="ancestor::*[contains(@class, ' topic/tbody ')][1]/@align"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/thead ')][1][@align]">
                    <xsl:value-of select="ancestor::*[contains(@class, ' topic/thead ')][1]/@align"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/tgroup ')][1][@align]">
                    <xsl:value-of select="ancestor::*[contains(@class, ' topic/tgroup ')][1]/@align"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="valign" as="xs:string?">
            <xsl:choose>
                <xsl:when test="@valign">
                    <xsl:value-of select="@valign"/>
                </xsl:when>
                <xsl:when test="parent::*[contains(@class, ' topic/row ')][@valign]">
                    <xsl:value-of select="parent::*[contains(@class, ' topic/row ')]/@valign"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="not(normalize-space($align) = '')">
                <xsl:attribute name="text-align">
                    <xsl:value-of select="$align"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="(normalize-space($align) = '') and contains(@class, ' topic/colspec ')"/>
            <xsl:otherwise>
                <xsl:attribute name="text-align">from-table-column()</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="$valign='top'">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'before'"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="$valign='middle'">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'center'"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="$valign='bottom'">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'after'"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="ia:isVerticalEntry(.)">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'after'"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="applyVerticalAlignAttrs">
        <xsl:attribute name="reference-orientation">90</xsl:attribute>
        <xsl:attribute name="height">100%</xsl:attribute>

        <xsl:variable name="colname" select="@colname"/>
        <xsl:variable name="align">
            <xsl:choose>
                <xsl:when test="@align">
                    <xsl:value-of select="@align"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/tbody ')][1][@align]">
                    <xsl:value-of select="ancestor::*[contains(@class, ' topic/tbody ')][1]/@align"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/thead ')][1][@align]">
                    <xsl:value-of select="ancestor::*[contains(@class, ' topic/thead ')][1]/@align"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/tgroup ')][1][@align]">
                    <xsl:value-of select="ancestor::*[contains(@class, ' topic/tgroup ')][1]/@align"/>
                </xsl:when>
                <xsl:when test="ancestor::*[contains(@class, ' topic/thead ') or contains(@class, ' topic/tbody ')][1]
                                                    /preceding-sibling::*[contains(@class, ' topic/colspec ')][@colname = $colname][1][@align]">
                    <xsl:value-of select="ancestor::*[contains(@class, ' topic/thead ') or contains(@class, ' topic/tbody ')][1]
                                                    /preceding-sibling::*[contains(@class, ' topic/colspec ')][@colname = $colname][1][@align]/@align"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$align = ''">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'before'"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="$align = 'left'">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'before'"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="$align = 'center'">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'center'"/>
                </xsl:attribute>
            </xsl:when>
            <xsl:when test="$align = 'right'">
                <xsl:attribute name="display-align">
                    <xsl:value-of select="'after'"/>
                </xsl:attribute>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:function name="ia:isVerticalEntry" as="xs:boolean">
        <xsl:param name="entry-node" as="item()"/>

        <xsl:variable name="colname" select="$entry-node/@colname"/>
        <xsl:choose>
            <xsl:when test="$entry-node/ancestor-or-self::*[contains(@outputclass, 'rotated-text')]">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$entry-node/ancestor::*[contains(@class, ' topic/thead ') or contains(@class, ' topic/tbody ')][1]
                                        /preceding-sibling::*[contains(@class, ' topic/colspec ')]
                                                    [@colname = $colname][1][contains(@base, 'rotated-text')]">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>