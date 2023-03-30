<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:axf="http://www.antennahouse.com/names/XSL/Extensions" version="2.0">

	<!-- 
		Revision History
		================
		Suite/EMC   SOW7    07-Apr-2013   Fix topic-level change-markup
	-->

	<!-- ============================================================== -->
	<xsl:import href="infoshare.I18N.xsl"/>
	<xsl:import href="infoshare.jobticket.xsl"/>
	<xsl:import href="infoshare.template.xsl"/>

	<xsl:param name="compare.report">
		<xsl:variable name="compare.report">
			<xsl:call-template name="getJobTicketParam">
				<xsl:with-param name="varname">compare-report</xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="current.language">
			<xsl:call-template name="get.current.language"/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$multilingual = 'yes'">
				<xsl:value-of
					select="concat('file:///', $WORKDIR, '/', $current.language, '/', $compare.report)"
				/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat('file:///', $WORKDIR, '/', $compare.report)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'text_remove_begin']">
		<xsl:call-template name="add.changebars">
			<xsl:with-param name="node" select="."/>
			<xsl:with-param name="type" select="'begin'"/>
			<xsl:with-param name="language">
				<xsl:call-template name="get.current.language"/>
			</xsl:with-param>
			<xsl:with-param name="placement" select="'inline'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'text_remove_end']">
		<xsl:call-template name="add.changebars">
			<xsl:with-param name="node" select="."/>
			<xsl:with-param name="type" select="'end'"/>
			<xsl:with-param name="language">
				<xsl:call-template name="get.current.language"/>
			</xsl:with-param>
			<xsl:with-param name="placement" select="'inline'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'text_insert_begin']">
		<xsl:call-template name="add.changebars">
			<xsl:with-param name="node" select="."/>
			<xsl:with-param name="type" select="'begin'"/>
			<xsl:with-param name="language">
				<xsl:call-template name="get.current.language"/>
			</xsl:with-param>
			<xsl:with-param name="placement" select="'inline'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'text_insert_end']">
		<xsl:call-template name="add.changebars">
			<xsl:with-param name="node" select="."/>
			<xsl:with-param name="type" select="'end'"/>
			<xsl:with-param name="language">
				<xsl:call-template name="get.current.language"/>
			</xsl:with-param>
			<xsl:with-param name="placement" select="'inline'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'insert_begin']">
		<xsl:call-template name="add.changebars">
			<xsl:with-param name="node" select="."/>
			<xsl:with-param name="type" select="'begin'"/>
			<xsl:with-param name="language">
				<xsl:call-template name="get.current.language"/>
			</xsl:with-param>
			<xsl:with-param name="placement" select="'inline'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'insert_end']">
		<xsl:call-template name="add.changebars">
			<xsl:with-param name="node" select="."/>
			<xsl:with-param name="type" select="'end'"/>
			<xsl:with-param name="language">
				<xsl:call-template name="get.current.language"/>
			</xsl:with-param>
			<xsl:with-param name="placement" select="'inline'"/>
		</xsl:call-template>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'remove_begin']">
		<xsl:if test="not(contains(following-sibling::*[1]/@class, ' topic/image '))">
			<xsl:call-template name="add.changebars">
				<xsl:with-param name="node" select="."/>
				<xsl:with-param name="type" select="'begin'"/>
				<xsl:with-param name="language">
					<xsl:call-template name="get.current.language"/>
				</xsl:with-param>
				<xsl:with-param name="placement" select="'inline'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template match="processing-instruction('ish')[. = 'remove_end']">
		<xsl:if test="not(contains(preceding-sibling::*[1]/@class, ' topic/image '))">
			<xsl:call-template name="add.changebars">
				<xsl:with-param name="node" select="."/>
				<xsl:with-param name="type" select="'end'"/>
				<xsl:with-param name="language">
					<xsl:call-template name="get.current.language"/>
				</xsl:with-param>
				<xsl:with-param name="placement" select="'inline'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	<!-- ============================================================== -->
	<!-- named templates -->
	<!-- ============================================================== -->
	<xsl:template name="is.link.inserted">
		<xsl:param name="node"/>
		<xsl:variable name="is.link.inserted">
			<xsl:choose>
				<xsl:when test="*[contains($node/@class, ' topic/topic ')]">
					<xsl:for-each
						select="$node/preceding-sibling::processing-instruction() | $node/preceding-sibling::*">
						<xsl:if
							test="name() = 'ish' and . = 'insert_begin' and position() = count($node/preceding-sibling::processing-instruction()) + count($node/preceding-sibling::*)">
							<xsl:value-of select="'true'"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each
						select="$node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::processing-instruction() | $node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::*">
						<xsl:if
							test="name() = 'ish' and . = 'insert_begin' and position() = count($node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::processing-instruction()) + count($node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::*)">
							<xsl:value-of select="'true'"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($is.link.inserted) > 0">
				<xsl:value-of select="$is.link.inserted"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="is.link.deleted">
		<xsl:param name="node"/>
		<xsl:variable name="is.link.deleted">
			<xsl:choose>
				<!-- if topic node -->
				<xsl:when test="*[contains($node/@class, ' topic/topic ')]">
					<xsl:for-each
						select="$node/preceding-sibling::processing-instruction() | $node/preceding-sibling::*">
						<xsl:if
							test="name() = 'ish' and . = 'remove_begin' and position() = count($node/preceding-sibling::processing-instruction()) + count($node/preceding-sibling::*)">
							<xsl:value-of select="'true'"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each
						select="$node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::processing-instruction() | $node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::*">
						<xsl:if
							test="name() = 'ish' and . = 'remove_begin' and position() = count($node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::processing-instruction()) + count($node/ancestor::node()[contains(@class, ' topic/topic ')][1]/preceding-sibling::*)">
							<xsl:value-of select="'true'"/>
						</xsl:if>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="string-length($is.link.deleted) > 0">
				<xsl:value-of select="$is.link.deleted"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ============================================================== -->
	<xsl:template name="get.comparison.result.id">
		<xsl:param name="node"/>
		<xsl:param name="current-language"/>
		<xsl:variable name="compare-id">
			<xsl:choose>
				<xsl:when test="$multilingual = 'yes'">
					<!--<xsl:value-of select="substring-after($node/@id,concat($current-language,'-'))"/>-->
					<xsl:value-of
						select="substring-after($node/@oid, concat($current-language, '-'))"/>
				</xsl:when>
				<xsl:otherwise>
					<!--<xsl:value-of select="$node/@id"/>-->
					<xsl:value-of select="$node/@oid"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="$compare-available = 'yes'">
			<xsl:choose>
				<!-- if topic node -->
				<xsl:when test="*[contains($node/@class, ' topic/topic ')]">
					<xsl:value-of
						select="document($compare.report, /)/*/object[@ishref = $compare-id]/@compare-result"
					/>
				</xsl:when>
				<!-- if metadata file -->
				<xsl:when test="$node/ancestor::ishfield[1]">
					<xsl:value-of select="'changed'"/>
				</xsl:when>
				<!-- inside topic -->
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="$multilingual = 'yes'">
							<xsl:value-of
								select="document($compare.report, /)/*/object[@ishref = substring-after($node/ancestor::node()[contains(@class, ' topic/topic ')][1]/@oid, concat($current-language, '-'))]/@compare-result"
							/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="document($compare.report, /)/*/object[@ishref = $node/ancestor::node()[contains(@class, ' topic/topic ')][1]/@oid]/@compare-result"
							/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- BVC 20090121:
	Get comparison result searches for the topic id (class contains ' topic/topic ') in the comparison report.
	But when using topic in topic the inner topic id cannot be found within the comparison report.
	So the comparison report must be searched recursively with the ancestor in that case.
	-->

	<xsl:template name="get.comparison.result">
		<xsl:param name="node"/>
		<xsl:param name="current-language"/>
		<xsl:variable name="compare-result-id">
			<xsl:call-template name="get.comparison.result.id">
				<xsl:with-param name="node" select="$node"/>
				<xsl:with-param name="current-language" select="$current-language"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:if test="$compare-available = 'yes'">
			<xsl:choose>
				<xsl:when test="string-length($compare-result-id) != 0">
					<xsl:value-of select="$compare-result-id"/>
				</xsl:when>
				<xsl:when test="$node/ancestor::node()[contains(@class, ' topic/topic ')][@id][1]">
					<xsl:call-template name="get.comparison.result">
						<xsl:with-param name="node"
							select="$node/ancestor::node()[contains(@class, ' topic/topic ')][@id][1]"/>
						<xsl:with-param name="current-language" select="$current-language"/>
					</xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<!-- should not come here -->
					<xsl:value-of select="'changed'"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>

	<!-- ============================================================== -->
	<xsl:template name="add.fo.changebar">
		<xsl:param name="node"/>
		<xsl:param name="type"/>
		<xsl:param name="language"/>
		<xsl:param name="style"/>

		<xsl:variable name="changebarclass">chg-<xsl:value-of select="count($node/ancestor::node())"
			/></xsl:variable>

		<xsl:choose>
			<xsl:when test="$type = 'begin'">
				<fo:change-bar-begin>
					<xsl:attribute name="change-bar-class">
						<xsl:value-of select="$changebarclass"/>
					</xsl:attribute>
					<xsl:call-template name="add.style">
						<xsl:with-param name="style" select="concat('change-bar-', $style)"/>
						<xsl:with-param name="language" select="$language"/>
					</xsl:call-template>
				</fo:change-bar-begin>
			</xsl:when>
			<xsl:when test="$type = 'end'">
				<fo:change-bar-end>
					<xsl:attribute name="change-bar-class">
						<xsl:value-of select="$changebarclass"/>
					</xsl:attribute>
				</fo:change-bar-end>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<!-- ============================================================== -->
	<xsl:template name="add.changebars">
		<xsl:param name="node"/>
		<xsl:param name="type"/>
		<xsl:param name="language"/>
		<xsl:param name="flag.comparison.result"/>
		<xsl:param name="placement"/>
		<xsl:variable name="compare.result">
			<xsl:call-template name="get.comparison.result">
				<xsl:with-param name="node" select="$node"/>
				<xsl:with-param name="current-language" select="$language"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="link.inserted">
			<xsl:call-template name="is.link.inserted">
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="link.deleted">
			<xsl:call-template name="is.link.deleted">
				<xsl:with-param name="node" select="$node"/>
			</xsl:call-template>
		</xsl:variable>

		<!--
<xsl:message>
		[node:<xsl:value-of select="local-name($node)"/>]
		[type:<xsl:value-of select="$type"/> -result:<xsl:value-of select="$compare.result"/> -i:<xsl:value-of select="$link.inserted"/> -d:<xsl:value-of select="$link.deleted"/>]
</xsl:message>
-->

		<xsl:if
			test="$placement = 'break' and $type = 'begin' and ($compare.result = 'new' or $compare.result = 'deleted' or $compare.result = 'changed')">
			<xsl:text>⌠fo:block⌡</xsl:text>
		</xsl:if>
		<xsl:choose>
			<!-- TOPIC = NEW => everything green -->
			<!-- Suite/EMC   SOW7    07-Apr-2013   Fix topic-level change-markup BEGIN - rs -->
			<xsl:when test="$compare.result = 'new' and $type = 'begin'">
				<!--				<xsl:if test="contains(@class,' topic/topic ')">-->
				<xsl:call-template name="add.fo.changebar">
					<xsl:with-param name="node" select="$node"/>
					<xsl:with-param name="type" select="'begin'"/>
					<xsl:with-param name="language" select="$language"/>
					<xsl:with-param name="style" select="'insert'"/>
				</xsl:call-template>
				<xsl:text>⌠fo:inline text-decoration="underline"  color="green"⌡</xsl:text>
				<!--				</xsl:if>-->
				<xsl:if test="$flag.comparison.result = 'yes'">
					<xsl:text>[NEW] </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$compare.result = 'new' and $type = 'end'">
				<!--				<xsl:if test="contains(@class,' topic/topic ')">-->
				<xsl:text>⌠/fo:inline⌡</xsl:text>
				<xsl:call-template name="add.fo.changebar">
					<xsl:with-param name="node" select="$node"/>
					<xsl:with-param name="type" select="'end'"/>
					<xsl:with-param name="language" select="$language"/>
					<xsl:with-param name="style" select="'insert'"/>
				</xsl:call-template>
				<!--				</xsl:if>-->
			</xsl:when>
			<!-- TOPIC = DELETED => everything red -->
			<xsl:when test="$compare.result = 'deleted' and $type = 'begin'">
				<xsl:if test="contains(@class, ' topic/image ')">
					<xsl:text>⌠fo:inline axf:diagonal-border-color="red" axf:diagonal-border-style="solid" axf:diagonal-border-width="2pt" axf:reverse-diagonal-border-color="red" axf:reverse-diagonal-border-style="solid" axf:reverse-diagonal-border-width="2pt"⌡</xsl:text>
				</xsl:if>
				<!--				<xsl:if test="contains(@class,' topic/topic ')">-->
				<xsl:call-template name="add.fo.changebar">
					<xsl:with-param name="node" select="$node"/>
					<xsl:with-param name="type" select="'begin'"/>
					<xsl:with-param name="language" select="$language"/>
					<xsl:with-param name="style" select="'delete'"/>
				</xsl:call-template>
				<xsl:text>⌠fo:inline text-decoration="line-through"  color="red"⌡</xsl:text>
				<!--				</xsl:if>	-->
				<xsl:if test="$flag.comparison.result = 'yes'">
					<xsl:text>[DELETED] </xsl:text>
				</xsl:if>
			</xsl:when>
			<xsl:when test="$compare.result = 'deleted' and $type = 'end'">
				<!--				<xsl:if test="contains(@class,' topic/topic ')">-->
				<xsl:text>⌠/fo:inline⌡</xsl:text>
				<xsl:call-template name="add.fo.changebar">
					<xsl:with-param name="node" select="$node"/>
					<xsl:with-param name="type" select="'end'"/>
					<xsl:with-param name="language" select="$language"/>
					<xsl:with-param name="style" select="'delete'"/>
				</xsl:call-template>
				<!--				</xsl:if>-->
				<!-- Suite/EMC   SOW7    07-Apr-2013   Fix topic-level change-markup END - rs -->
				<xsl:if test="contains(@class, ' topic/image ')">
					<xsl:text>⌠/fo:inline⌡</xsl:text>
				</xsl:if>
			</xsl:when>
			<!-- TOPIC = CHANGED -->
			<xsl:when test="$compare.result = 'changed' and $type = 'begin'">
				<xsl:choose>
					<!-- topic is moved to another location => red -->
					<xsl:when test="$link.deleted = 'true'">
						<xsl:if test="contains(@class, ' topic/image ')">
							<xsl:text>⌠fo:inline axf:diagonal-border-color="red" axf:diagonal-border-style="solid" axf:diagonal-border-width="2pt" axf:reverse-diagonal-border-color="red" axf:reverse-diagonal-border-style="solid" axf:reverse-diagonal-border-width="2pt"⌡</xsl:text>
						</xsl:if>
						<xsl:if test="not(contains(@class, ' topic/image '))">
							<xsl:call-template name="add.fo.changebar">
								<xsl:with-param name="node" select="$node"/>
								<xsl:with-param name="type" select="'begin'"/>
								<xsl:with-param name="language" select="$language"/>
								<xsl:with-param name="style" select="'delete'"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:text>⌠fo:inline text-decoration="line-through"  color="red"⌡</xsl:text>
						<xsl:if test="$flag.comparison.result = 'yes'">
							<fo:inline>[MOVED] </fo:inline>
						</xsl:if>
					</xsl:when>
					<!-- topic is moved to this location: process all PI inside topic -->
					<xsl:otherwise>
						<xsl:if test="$flag.comparison.result = 'yes'">
							<fo:inline>[CHANGED] </fo:inline>
						</xsl:if>
						<xsl:choose>
							<xsl:when test=". = 'text_remove_begin'">
								<xsl:call-template name="add.fo.changebar">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="type" select="'begin'"/>
									<xsl:with-param name="language" select="$language"/>
									<xsl:with-param name="style" select="'delete'"/>
								</xsl:call-template>
								<xsl:text>⌠fo:inline text-decoration="line-through"  color="red"⌡</xsl:text>
							</xsl:when>
							<xsl:when test=". = 'text_insert_begin'">
								<xsl:call-template name="add.fo.changebar">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="type" select="'begin'"/>
									<xsl:with-param name="language" select="$language"/>
									<xsl:with-param name="style" select="'insert'"/>
								</xsl:call-template>
								<xsl:text>⌠fo:inline text-decoration="underline"  color="green"⌡</xsl:text>
							</xsl:when>
							<xsl:when test=". = 'insert_begin'">
								<!-- Balaji Mani 18-June-2013: added version compare -->
								<xsl:if
									test="contains(following-sibling::*[1]/@class, ' topic/image ') or ../*[contains(@class, ' topic/vrm ')]">
									<xsl:call-template name="add.fo.changebar">
										<xsl:with-param name="node" select="$node"/>
										<xsl:with-param name="type" select="'begin'"/>
										<xsl:with-param name="language" select="$language"/>
										<xsl:with-param name="style" select="'insert'"/>
									</xsl:call-template>
									<xsl:text>⌠fo:inline border="green 1pt solid" padding="1pt" ⌡</xsl:text>
								</xsl:if>
							</xsl:when>
							<xsl:when test=". = 'remove_begin'">
								<xsl:choose>
									<xsl:when
										test="contains(following-sibling::*[1]/@class, ' topic/image ')">
										<xsl:text>⌠fo:inline axf:diagonal-border-color="red" axf:diagonal-border-style="solid" axf:diagonal-border-width="2pt" axf:reverse-diagonal-border-color="red" axf:reverse-diagonal-border-style="solid" axf:reverse-diagonal-border-width="2pt"⌡</xsl:text>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>⌠fo:inline text-decoration="line-through"  color="red"⌡</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:call-template name="add.fo.changebar">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="type" select="'begin'"/>
									<xsl:with-param name="language" select="$language"/>
									<xsl:with-param name="style" select="'delete'"/>
								</xsl:call-template>

							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$compare.result = 'changed' and $type = 'end'">
				<xsl:choose>
					<!-- topic is moved to another location => red -->
					<xsl:when test="$link.deleted = 'true'">
						<xsl:text>⌠/fo:inline⌡</xsl:text>
						<xsl:if test="not(contains(@class, ' topic/image '))">
							<xsl:call-template name="add.fo.changebar">
								<xsl:with-param name="node" select="$node"/>
								<xsl:with-param name="type" select="'end'"/>
								<xsl:with-param name="language" select="$language"/>
								<xsl:with-param name="style" select="'delete'"/>
							</xsl:call-template>
						</xsl:if>
						<xsl:if test="contains(@class, ' topic/image ')">
							<xsl:text>⌠/fo:inline⌡</xsl:text>
						</xsl:if>
					</xsl:when>
					<!-- topic is moved to this location, process all PI inside topic -->
					<xsl:otherwise>
						<xsl:choose>
							<xsl:when test=". = 'text_remove_end'">
								<xsl:text>⌠/fo:inline⌡</xsl:text>
								<xsl:call-template name="add.fo.changebar">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="type" select="'end'"/>
									<xsl:with-param name="language" select="$language"/>
									<xsl:with-param name="style" select="'delete'"/>
								</xsl:call-template>
							</xsl:when>
							<xsl:when test=". = 'text_insert_end'">
								<xsl:text>⌠/fo:inline⌡</xsl:text>
								<xsl:call-template name="add.fo.changebar">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="type" select="'end'"/>
									<xsl:with-param name="language" select="$language"/>
									<xsl:with-param name="style" select="'insert'"/>
								</xsl:call-template>
							</xsl:when>
							<!-- Balaji Mani 18-June-2013: added version compare -->
							<xsl:when test=". = 'insert_end'">
								<xsl:if
									test="contains(preceding-sibling::*[1]/@class, ' topic/image ') or ../*[contains(@class, ' topic/vrm ')]">
									<xsl:text>⌠/fo:inline⌡</xsl:text>
									<xsl:call-template name="add.fo.changebar">
										<xsl:with-param name="node" select="$node"/>
										<xsl:with-param name="type" select="'end'"/>
										<xsl:with-param name="language" select="$language"/>
										<xsl:with-param name="style" select="'insert'"/>
									</xsl:call-template>
								</xsl:if>
							</xsl:when>
							<xsl:when test=". = 'remove_end'">

								<xsl:call-template name="add.fo.changebar">
									<xsl:with-param name="node" select="$node"/>
									<xsl:with-param name="type" select="'end'"/>
									<xsl:with-param name="language" select="$language"/>
									<xsl:with-param name="style" select="'delete'"/>
								</xsl:call-template>
								<!--<xsl:if test="contains(preceding-sibling::*[1]/@class, ' topic/image ')">-->
								<xsl:text>⌠/fo:inline⌡</xsl:text>
								<!--</xsl:if>-->
							</xsl:when>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<!-- TOPIC = UNCHANGED -->
			<xsl:when test="$compare.result = 'unchanged' and $type = 'begin'">
				<xsl:choose>
					<!-- topic is moved to another location => red -->
					<xsl:when test="$link.deleted = 'true'">
						<xsl:if
							test="contains(following-sibling::*[1]/@class, ' topic/image ') or contains(@class, ' topic/image ')">
							<xsl:text>⌠fo:inline axf:diagonal-border-color="red" axf:diagonal-border-style="solid" axf:diagonal-border-width="2pt" axf:reverse-diagonal-border-color="red" axf:reverse-diagonal-border-style="solid" axf:reverse-diagonal-border-width="2pt"⌡</xsl:text>
						</xsl:if>
						<xsl:if
							test="contains(following-sibling::*[1]/@class, ' topic/topic ') or contains(@class, ' topic/topic ')">
							<xsl:text>⌠fo:block ⌡</xsl:text>
						</xsl:if>
						<xsl:call-template name="add.fo.changebar">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="type" select="'begin'"/>
							<xsl:with-param name="language" select="$language"/>
							<xsl:with-param name="style" select="'delete'"/>
						</xsl:call-template>
						<xsl:text>⌠fo:inline text-decoration="line-through"  color="red"⌡</xsl:text>
						<xsl:if test="$flag.comparison.result = 'yes'">
							<fo:inline>[MOVED] </fo:inline>
						</xsl:if>
					</xsl:when>
					<!-- topic is moved to this location => no further processing -->
					<xsl:when test="$link.inserted = 'true'"><!-- DO NOTHING --></xsl:when>
					<xsl:otherwise><!-- DO NOTHING --></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$compare.result = 'unchanged' and $type = 'end'">
				<xsl:choose>
					<!-- topic is moved to another location => red -->
					<xsl:when test="$link.deleted = 'true'">
						<xsl:text>⌠/fo:inline⌡</xsl:text>
						<xsl:call-template name="add.fo.changebar">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="type" select="'end'"/>
							<xsl:with-param name="language" select="$language"/>
							<xsl:with-param name="style" select="'delete'"/>
						</xsl:call-template>
						<xsl:if
							test="contains(preceding-sibling::*[1]/@class, ' topic/image ') or contains(@class, ' topic/image ')">
							<xsl:text>⌠/fo:inline⌡</xsl:text>
						</xsl:if>
						<xsl:if
							test="contains(preceding-sibling::*[1]/@class, ' topic/topic ') or contains(@class, ' topic/topic ')">
							<xsl:text>⌠/fo:block⌡</xsl:text>
						</xsl:if>
					</xsl:when>
					<!-- topic is moved to this location => no further processing -->
					<xsl:when test="$link.inserted = 'true'"><!-- DO NOTHING --></xsl:when>
					<xsl:otherwise><!-- DO NOTHING --></xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise><!-- DO NOTHING --></xsl:otherwise>
		</xsl:choose>

		<!-- 29-FEB-2008 : BVC & RS
		  Handling of removed illustrations
		  Illustrations with placement break generate an extra fo:block - by this the strikethrough set by the processing instruction is no longer visible
		  Therefor change bars and strikethrough 
		  - is skipped during handling of processing instruction <?ish remove_begin?> for illustrations
		  - is done during the processing of the topic/image element
		  
		  Mantis issue 1825:
		  - Moved topics with changed images caused duplicate change-bar-class name in place where topic is deleted.
		-->
		<!--<xsl:if test="contains(@class, ' topic/image ') and preceding-sibling::node()[1][name()='ish' and .='remove_begin']">-->
		<xsl:if
			test="contains(@class, ' topic/image ') and (preceding-sibling::processing-instruction()[1][name() = 'ish' and . = 'remove_begin'] or preceding::processing-instruction()[1][name() = 'ish' and . = 'remove_begin'])">
			<xsl:choose>
				<xsl:when test="$type = 'begin'">
					<xsl:text>⌠fo:inline axf:diagonal-border-color="red" axf:diagonal-border-style="solid" axf:diagonal-border-width="2pt" axf:reverse-diagonal-border-color="red" axf:reverse-diagonal-border-style="solid" axf:reverse-diagonal-border-width="2pt"⌡</xsl:text>
					<xsl:if test="$link.deleted != 'true'">
						<xsl:call-template name="add.fo.changebar">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="type" select="'begin'"/>
							<xsl:with-param name="language" select="$language"/>
							<xsl:with-param name="style" select="'delete'"/>
						</xsl:call-template>
					</xsl:if>
				</xsl:when>
				<xsl:when test="$type = 'end'">
					<xsl:if test="$link.deleted != 'true'">
						<xsl:call-template name="add.fo.changebar">
							<xsl:with-param name="node" select="$node"/>
							<xsl:with-param name="type" select="'end'"/>
							<xsl:with-param name="language" select="$language"/>
							<xsl:with-param name="style" select="'delete'"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:text>⌠/fo:inline⌡</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:if>

		<!--<xsl:if test="contains(@class, ' topic/image ') and preceding-sibling::node()[1][name()='ish' and .='insert_begin'] and $link.deleted != 'true'">-->
		<xsl:if
			test="contains(@class, ' topic/image ') and preceding-sibling::processing-instruction()[1][name() = 'ish' and . = 'insert_begin'] and $link.deleted != 'true'">
			<xsl:choose>
				<xsl:when test="$type = 'begin'">
					<xsl:text>⌠fo:inline border="green 1pt solid" padding="1pt" ⌡</xsl:text>
				</xsl:when>
				<xsl:when test="$type = 'end'">
					<xsl:text>⌠/fo:inline⌡</xsl:text>
				</xsl:when>
			</xsl:choose>
		</xsl:if>

		<xsl:if
			test="$placement = 'break' and $type = 'end' and ($compare.result = 'new' or $compare.result = 'deleted' or $compare.result = 'changed')">
			<xsl:text>⌠/fo:block⌡</xsl:text>
		</xsl:if>

	</xsl:template>
	<!-- ============================================================== -->
</xsl:stylesheet>
