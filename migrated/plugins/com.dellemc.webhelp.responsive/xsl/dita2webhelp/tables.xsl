<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:dita2html="http://dita-ot.sourceforge.net/ns/200801/dita2html"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                xmlns:table="http://dita-ot.sourceforge.net/ns/201007/dita-ot/table"
                version="2.0"
                exclude-result-prefixes="xs dita-ot dita2html ditamsg table">

	<xsl:template match="*[contains(@class,' topic/table ')]" name="topic.table">
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
		<table>
			<xsl:apply-templates select="." mode="table:common"/>
			<xsl:apply-templates select="." mode="table:title"/>
			<xsl:apply-templates select="*[contains(@class, ' topic/tgroup ')]"/>
		</table>

		<xsl:if test="not(ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]) and
                (descendant::*[contains(@class, ' topic/fn ')] or descendant::*[contains(@class, ' topic/xref ')][@type = 'fn'])">
			<xsl:variable name="table">
				<xsl:copy-of select="."/>
			</xsl:variable>
			<xsl:call-template name="gen-table-endnotes">
				<xsl:with-param name="table" select="$table"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>

	<xsl:template name="gen-table-footnote">
		<xsl:param name="table"/>
		<xsl:param name="element"/>
		<xsl:param name="xtrc"/>
		<xsl:apply-templates select="$table/descendant::*[self::* = $element][@xtrc = $xtrc]
                                                [not( (ancestor-or-self::*[contains(@class, ' topic/draft-comment ')]
                                                        or ancestor::*[contains(@class, ' topic/required-cleanup ')])
                                                    and $DRAFT = 'no')][1]" mode="table.fn"/>
	</xsl:template>

	<xsl:template name="gen-table-endnotes">
		<xsl:param name="table"/>
		<div class="table-endnotes">
			<xsl:apply-templates select="$table/descendant::*[contains(@class, ' topic/fn ')
                                                        or (contains(@class, ' topic/xref ') and @type = 'fn')]
                                                    [not((ancestor-or-self::*[contains(@class, ' topic/draft-comment ')]
                                                        or ancestor::*[contains(@class, ' topic/required-cleanup ')])
                                                    and $DRAFT = 'no')]" mode="genTableEndnote"/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/fn ')]" mode="genTableEndnote">
		<div class="fn">
			<xsl:variable name="fnid">
				<xsl:number format="a" value="count(preceding::*[contains(@class, ' topic/fn ')]) + 1"/>
			</xsl:variable>
			<xsl:variable name="callout" select="@callout"/>
			<xsl:variable name="convergedcallout" select="if (string-length($callout) > 0) then $callout else $fnid"/>
			<xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>

			<xsl:call-template name="commonattributes"/>
			<span id="fntarg_{$fnid}_{$ancestorId}">
				<xsl:value-of select="concat($convergedcallout, '. ')"/>
			</span>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/xref ')][@type = 'fn']"
				  mode="genTableEndnote"/>

	<xsl:template match="*[contains(@class, ' topic/fn ') or (contains(@class, ' topic/xref ')and @type = 'fn')]
                            [ancestor::*[contains(@class, ' topic/table ') or contains(@class,' topic/simpletable ')]]"
				  mode="table.fn">
		<xsl:variable name="ref-id" select="substring-after(@href, '/')"/>

		<xsl:variable name="fn-number">
			<xsl:choose>
				<xsl:when test="contains(@class, ' topic/xref ')">
					<xsl:value-of select="count(/descendant::*[@id = $ref-id][1]/preceding::*[contains(@class, ' topic/fn ')]) + 1"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="count(preceding::*[contains(@class, ' topic/fn ')]) + 1"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="fnid">
			<xsl:number format="a" value="$fn-number"/>
		</xsl:variable>
		<xsl:variable name="ancestorId" select="ancestor::*[@id][not(@id = '')][1]/@id"/>
		<xsl:variable name="callout" select="@callout"/>
		<xsl:variable name="convergedcallout" select="if (string-length($callout)> 0) then $callout else $fnid"/>
		<a href="#fntarg_{$fnid}_{$ancestorId}">
			<sup>
				<xsl:value-of select="$convergedcallout"/>
			</sup>
		</a>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/table ')]" mode="table:title">
		<xsl:if test="normalize-space(*[contains(@class, ' topic/title ')])">
			<caption>
				<xsl:call-template name="place-tbl-lbl"/>
			</caption>
		</xsl:if>
	</xsl:template>

	<xsl:template name="place-tbl-lbl">
		<xsl:variable name="tbl-count-actual" select="count(preceding::*[contains(@class, ' topic/table ')][*[contains(@class, ' topic/title ')]])+1"/>
		<xsl:variable name="ancestorlang">
			<xsl:call-template name="getLowerCaseLang"/>
		</xsl:variable>

		<span class="table-anchor">
			<xsl:call-template name="setid"/>
		</span>
		<xsl:if test="normalize-space(*[contains(@class, ' topic/title ')])">
			<span class="tablecap">
				<xsl:if test="$insert-table-numbering">
					<span class="table-label">
						<xsl:choose>
							<xsl:when test="$ancestorlang = ('hu', 'hu-hu')">
								<xsl:value-of select="$tbl-count-actual"/>
								<xsl:text>. </xsl:text>
								<xsl:call-template name="getVariable">
									<xsl:with-param name="id" select="'Table'"/>
								</xsl:call-template>
								<xsl:text> </xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="getVariable">
									<xsl:with-param name="id" select="'Table'"/>
								</xsl:call-template>
								<xsl:text> </xsl:text>
								<xsl:value-of select="$tbl-count-actual"/>
								<xsl:text>. </xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</span>
				</xsl:if>
				<xsl:apply-templates select="*[contains(@class, ' topic/title ')]" mode="tabletitle"/>
			</span>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/table ')]" mode="get-output-class">
		<xsl:choose>
			<xsl:when test="@frame and not(@frame = '')">
				<xsl:value-of select="@frame"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'all'"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:choose>
			<xsl:when
					test="(@expanse = 'page' or @pgwide = '1')and (ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')] )">
				<xsl:value-of select="' no-pgwide'"/>
			</xsl:when>
			<xsl:when
					test="(@expanse = 'column' or @pgwide = '0') and (ancestor::*[contains(@class, ' topic/li ')] or ancestor::*[contains(@class, ' topic/dd ')] )">
				<xsl:value-of select="' no-pgwide'"/>
			</xsl:when>
			<xsl:when test="(@expanse = 'page' or @pgwide = '1')">
				<xsl:value-of select="' pgwide'"/>
			</xsl:when>
			<xsl:when test="(@expanse = 'column' or @pgwide = '0')">
				<xsl:value-of select="' pgwide'"/>
			</xsl:when>
			<xsl:when test="descendant::*[contains(@class, ' topic/colspec ')][contains(@colwidth , '*')]">
				<xsl:value-of select="' pgwide'"/>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/entry ')]" mode="get-output-class">
		<xsl:variable name="this-colname" select="@colname"/>
		<xsl:variable name="row" select=".." as="element()"/>
		<xsl:variable name="body" select="../.." as="element()"/>
		<xsl:variable name="group" select="../../.." as="element()"/>
		<xsl:variable name="colspec" as="element()">
            <xsl:choose>
                <xsl:when test="exists(../../../*[contains(@class, ' topic/colspec ')][@colname and @colname = $this-colname])">
                    <xsl:sequence select="../../../*[contains(@class, ' topic/colspec ')][@colname and @colname = $this-colname]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="dummy-colspec">
                        <colspec/>
                    </xsl:variable>
                    <xsl:sequence select="$dummy-colspec/*"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

		<xsl:variable name="table" select="ancestor::*[contains(@class, ' topic/table ')][1]" as="element()"/>
		<xsl:variable name="firstcol" as="xs:boolean" select="$table/@rowheader = 'firstcol' and @dita-ot:x = '1'"/>

		<xsl:variable name="framevalue">
			<xsl:choose>
				<xsl:when test="$table/@frame and $table/@frame != ''">
					<xsl:value-of select="$table/@frame"/>
				</xsl:when>
				<xsl:otherwise>all</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:variable name="rowsep" as="xs:integer">
			<xsl:choose>
				<xsl:when
						test="not(parent::*[parent::*[contains(@class, 'thead')]]) and not($firstcol) and not(../following-sibling::*)">
					<xsl:choose>
						<xsl:when test="$framevalue = 'all' or $framevalue = 'bottom' or $framevalue = 'topbot'">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="ancestor::*[2][contains(@class, ' topic/thead ')] and not($firstcol) and not(../preceding-sibling::*)">
					<xsl:choose>
						<xsl:when test="$framevalue = 'all' or $framevalue = 'bottom' or $framevalue = 'topbot'">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@rowsep"><xsl:value-of select="@rowsep"/></xsl:when>
				<xsl:when test="$row/@rowsep"><xsl:value-of select="$row/@rowsep"/></xsl:when>
				<xsl:when test="$colspec/@rowsep"><xsl:value-of select="$colspec/@rowsep"/></xsl:when>
				<xsl:when test="$group/@rowsep"><xsl:value-of select="$group/@rowsep"/></xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="colsep" as="xs:integer">
			<xsl:choose>
				<!-- If there are more columns, keep rows on -->
				<xsl:when test="not(parent::*[parent::*[contains(@class, 'thead')]]) and not($firstcol) and not(following-sibling::*)">
					<xsl:choose>
						<xsl:when test="$framevalue = 'all' or $framevalue = 'sides'">1</xsl:when>
						<xsl:otherwise>0</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:when test="@colsep"><xsl:value-of select="@colsep"/></xsl:when>
				<xsl:when test="$colspec/@colsep"><xsl:value-of select="$colspec/@colsep"/></xsl:when>
				<xsl:when test="$group/@colsep"><xsl:value-of select="$group/@colsep"/></xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$firstcol">firstcol </xsl:if>
		<xsl:choose>
			<xsl:when test="$rowsep = 0 and $colsep = 0">nocellnorowborder</xsl:when>
			<xsl:when test="$rowsep = 1 and $colsep = 0">row-nocellborder</xsl:when>
			<xsl:when test="$rowsep = 0 and $colsep = 1">cell-norowborder</xsl:when>
			<xsl:when test="$rowsep = 1 and $colsep = 1">cellrowborder</xsl:when>
		</xsl:choose>

		<xsl:apply-templates mode="#current" select="table:get-entry-align(.), table:get-entry-colsep(.), table:get-entry-rowsep(.), @valign"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/dl ')][not(contains(@class, ' pr-d/parml '))]" >
		<xsl:call-template name="setaname"/>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
		<xsl:variable name="thead">
			<thead>
				<xsl:apply-templates select="*[contains(@class, ' topic/dlhead ')]"/>
			</thead>
		</xsl:variable>
		<table>
			<!-- handle DL compacting - default=yes -->
			<xsl:if test="@compact = 'no'">
				<xsl:attribute name="class">dlexpand</xsl:attribute>
			</xsl:if>
			<xsl:call-template name="commonattributes"/>
			<xsl:apply-templates select="@compact"/>
			<xsl:call-template name="setid"/>
			<xsl:if test="$thead/descendant::th">
				<xsl:copy-of select="$thead"/>
			</xsl:if>
			<tbody>
				<xsl:apply-templates select="*[not(contains(@class, ' topic/dlhead '))]"/>
			</tbody>
		</table>
		<xsl:apply-templates select="*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/dlhead ')]">
		<tr>
			<xsl:call-template name="commonattributes">
				<xsl:with-param name="default-output-class" select="'row-nocellborder'"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/dthd ')]">
		<th>
			<xsl:apply-templates select="../@xml:lang"/>
			<xsl:call-template name="commonattributes"/>
			<xsl:call-template name="setidaname"/>
			<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
			<strong>
				<xsl:apply-templates/>
			</strong>
			<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
		</th>
	</xsl:template>

	<!-- DL heading, description -->
	<xsl:template match="*[contains(@class, ' topic/ddhd ')]">
		<th>
			<xsl:apply-templates select="../@xml:lang"/>
			<xsl:call-template name="commonattributes"/>
			<xsl:call-template name="setidaname"/>
			<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
			<strong>
				<xsl:apply-templates/>
			</strong>
			<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
		</th>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/dlentry ')][not(contains(@class, ' pr-d/plentry '))]">
		<tr>
			<xsl:call-template name="commonattributes">
				<xsl:with-param name="default-output-class" select="'row-nocellborder'"/>
			</xsl:call-template>
			<xsl:apply-templates/>
		</tr>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/dt ')][not(contains(@class, ' pr-d/pt '))]">
		<td>
			<xsl:apply-templates select="../@xml:lang"/>
			<xsl:call-template name="commonattributes"/>
			<xsl:choose>
				<xsl:when test="@keyref and @href">
					<a>
						<xsl:apply-templates select="." mode="add-linking-attributes"/>
						<xsl:apply-templates select="." mode="output-dt"/>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates select="." mode="output-dt"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/dt ')][not(contains(@class, ' pr-d/pt '))]" mode="output-dt">
		<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
		<xsl:apply-templates/>
		<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
	</xsl:template>

	<xsl:template match="*[contains(@class, ' topic/dd ')][not(contains(@class, ' pr-d/pd '))]">
		<td>
			<xsl:call-template name="commonattributes"/>
			<xsl:call-template name="setidaname"/>
			<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-startprop ')]" mode="out-of-line"/>
			<xsl:apply-templates/>
			<xsl:apply-templates select="../*[contains(@class, ' ditaot-d/ditaval-endprop ')]" mode="out-of-line"/>
		</td>
	</xsl:template>
</xsl:stylesheet>