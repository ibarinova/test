<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:related-links="http://dita-ot.sourceforge.net/ns/200709/related-links"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				exclude-result-prefixes="related-links xs"
				version="2.0">

	<xsl:template match="*[contains(@class, ' topic/link ')][@type='concept']" mode="related-links:result-group"
				  name="related-links:result.concept" as="element(linklist)">
		<xsl:param name="links" as="node()*"/>
		<xsl:if test="normalize-space(string-join($links, ''))">
			<linklist class="- topic/linklist " outputclass="relinfo relconcepts">
				<title class="- topic/title ">
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Related Reference Open'"/>
					</xsl:call-template>
				</title>
				<xsl:copy-of select="$links"/>
			</linklist>
		</xsl:if>
	</xsl:template>

	<xsl:template match="*[contains(@class,'cli_body')]" priority="5">
		<xsl:apply-templates/>
	</xsl:template>

	<!--  EMC 	15-Oct-2014		Hide <th> for cli_reference elements -->
	<!-- Process a standard row in the properties table. Apply-templates on the entries one at a time;
		 if one is missing which should be present, create an empty cell. -->
	<xsl:template match="*[contains(@class,' reference/property ')]" name="topic.reference.property">
		<xsl:param name="hasType" as="xs:boolean"/>
		<xsl:param name="hasValue" as="xs:boolean"/>
		<xsl:param name="hasDesc" as="xs:boolean"/>
		<!-- If there was no header and this is the first child of properties; create default headers -->
		<xsl:if test="not(preceding-sibling::*[contains(@class,' reference/prophead ')])
						and not(preceding-sibling::*[contains(@class,' reference/property ')])">
			<xsl:choose>
				<xsl:when test="../*/*[contains(@class,' cli_reference/cli_arg_value ')]"/>
				<xsl:when test="../*/*[contains(@class,' cli_reference/cli_arg_desc ')]"/>
				<xsl:when test="../*/*[contains(@class,' cli_reference/cli_option_value ')]"/>
				<xsl:when test="../*/*[contains(@class,' cli_reference/cli_option_desc ')]"/>
				<xsl:when test="../*/*[contains(@class,' cli_reference/cli_param_value ')]"/>
				<xsl:when test="../*/*[contains(@class,' cli_reference/cli_param_desc ')]"/>
				<xsl:otherwise>
					<tr>
						<xsl:value-of select="$newline"/>

						<xsl:if test="../*/*[contains(@class,' reference/proptype ')]">
							<th id="{generate-id(parent::*)}-type" valign="bottom">
								<xsl:attribute name="align">
									<xsl:call-template name="th-align"/>
								</xsl:attribute>
								<xsl:call-template name="getVariable">
									<xsl:with-param name="id" select="'Type'"/>
								</xsl:call-template>
							</th>
							<xsl:value-of select="$newline"/>
						</xsl:if>
						<xsl:if test="../*/*[contains(@class,' reference/propvalue ')]">
							<th id="{generate-id(parent::*)}-value" valign="bottom">
								<xsl:attribute name="align">
									<xsl:call-template name="th-align"/>
								</xsl:attribute>
								<xsl:call-template name="getVariable">
									<xsl:with-param name="id" select="'Value'"/>
								</xsl:call-template>
							</th>
							<xsl:value-of select="$newline"/>
						</xsl:if>
						<xsl:if test="../*/*[contains(@class,' reference/propdesc ')]">
							<th id="{generate-id(parent::*)}-desc" valign="bottom">
								<xsl:attribute name="align">
									<xsl:call-template name="th-align"/>
								</xsl:attribute>
								<xsl:call-template name="getVariable">
									<xsl:with-param name="id" select="'Description'"/>
								</xsl:call-template>
							</th>
							<xsl:value-of select="$newline"/>
						</xsl:if>
					</tr>
					<xsl:value-of select="$newline"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		<tr>
			<xsl:call-template name="setid"/>
			<xsl:call-template name="commonattributes"/>
			<xsl:value-of select="$newline"/>
			<!-- For each of the 3 entry types:
                 - If it is in this row, apply
                 - Otherwise, if it is in the table at all, create empty entry -->
			<xsl:choose>      <!-- Process or create proptype -->
				<xsl:when test="*[contains(@class,' reference/proptype ')]">
					<xsl:apply-templates select="*[contains(@class,' reference/proptype ')]"/>
				</xsl:when>
				<xsl:when test="$hasType">
					<td>    <!-- Create an empty cell. Add accessiblity attribute. -->
						<xsl:call-template name="addPropertiesHeadersAttribute">
							<xsl:with-param name="classVal">reference/proptypehd</xsl:with-param>
							<xsl:with-param name="elementType">type</xsl:with-param>
						</xsl:call-template>
						<xsl:text disable-output-escaping="no">&#xA0;</xsl:text>
					</td>
					<xsl:value-of select="$newline"/>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>      <!-- Process or create propvalue -->
				<xsl:when test="*[contains(@class,' reference/propvalue ')]">
					<xsl:apply-templates select="*[contains(@class,' reference/propvalue ')]"/>
				</xsl:when>
				<xsl:when test="$hasValue">
					<td>    <!-- Create an empty cell. Add accessiblity attribute. -->
						<xsl:call-template name="addPropertiesHeadersAttribute">
							<xsl:with-param name="classVal">reference/propvaluehd</xsl:with-param>
							<xsl:with-param name="elementType">value</xsl:with-param>
						</xsl:call-template>
						<xsl:text disable-output-escaping="no">&#xA0;</xsl:text>
					</td>
					<xsl:value-of select="$newline"/>
				</xsl:when>
			</xsl:choose>
			<xsl:choose>      <!-- Process or create propdesc -->
				<xsl:when test="*[contains(@class,' reference/propdesc ')]">
					<xsl:apply-templates select="*[contains(@class,' reference/propdesc ')]"/>
				</xsl:when>
				<xsl:when test="$hasDesc">
					<td>    <!-- Create an empty cell. Add accessiblity attribute. -->
						<xsl:call-template name="addPropertiesHeadersAttribute">
							<xsl:with-param name="classVal">reference/propdeschd</xsl:with-param>
							<xsl:with-param name="elementType">desc</xsl:with-param>
						</xsl:call-template>
						<xsl:text disable-output-escaping="no">&#xA0;</xsl:text>
					</td>
					<xsl:value-of select="$newline"/>
				</xsl:when>
			</xsl:choose>
		</tr>
		<xsl:value-of select="$newline"/>
	</xsl:template>

	<!-- Process 'cli_reference' to match the formatting of WebWorks -->
	<xsl:template match="*[contains(@class,' cli_reference/cli_syntax ')]" priority="5">
		<div class="cli_syntax">
			<div class="cli_label">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Syntax'"/>
					</xsl:call-template>
				</strong>
			</div><xsl:value-of select="$newline"/>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_description ')]" priority="5">
		<div class="cli_description">
			<div class="cli_label">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Description'"/>
					</xsl:call-template>
				</strong>
			</div><xsl:value-of select="$newline"/>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_options ')]" priority="5">
		<div class="cli_options">
			<div class="cli_label">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Options Open'"/>
					</xsl:call-template>
				</strong>
			</div><xsl:value-of select="$newline"/>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_args ')]" priority="5">
		<div class="cli_args">
			<div class="cli_label">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Arguments Open'"/>
					</xsl:call-template>
				</strong>
			</div><xsl:value-of select="$newline"/>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_params ')]" priority="5">
		<div class="cli_params">
			<div class="cli_label">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Parameters Open'"/>
					</xsl:call-template>
				</strong>
			</div><xsl:value-of select="$newline"/>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_prereq ')]" priority="5">
		<div class="cli_prereq">
			<div class="cli_label">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Prerequisite Open'"/>
					</xsl:call-template>
				</strong>
			</div><xsl:value-of select="$newline"/>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_example ')]" priority="5">
		<div class="cli_example">
			<div class="cli_label">
				<strong>
					<xsl:call-template name="getVariable">
						<xsl:with-param name="id" select="'Example Open'"/>
					</xsl:call-template>
				</strong>
			</div><xsl:value-of select="$newline"/>
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_option ') or contains(@class,' cli_reference/cli_arg ') or contains(@class,' cli_reference/cli_param ')]"   priority="5">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_option_value ') or contains(@class,' cli_reference/cli_arg_value ') or contains(@class,' cli_reference/cli_param_value ')]"   priority="5">
		<div class="cli_value">
			<xsl:apply-templates />
		</div>
	</xsl:template>

	<xsl:template match="*[contains(@class,' cli_reference/cli_option_desc ') or contains(@class,' cli_reference/cli_arg_desc ') or contains(@class,' cli_reference/cli_param_desc ')]" priority="5">
		<div class="cli_desc">
			<xsl:apply-templates />
		</div>
	</xsl:template>

</xsl:stylesheet>
