<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

	<xsl:variable name="PROPERTIES.XML" select="resolve-uri('workdir/properties.xml', base-uri(/))"/>

	<xsl:variable name="properties-xml-uri" select="resolve-uri('workdir/properties.xml', base-uri(/))"/>
	<xsl:variable name="properties-xml-doc" select="document($properties-xml-uri)"/>


	<xsl:template match="*[@collection-type='sequence']/*[contains(@class, ' map/topicref ')]
    						[not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]"
				  mode="link-to-next-prev"
				  name="link-to-next-prev">

		<xsl:param name="pathBackToMapDirectory"/>

		<xsl:variable name="previous" select="(preceding::*|ancestor::*)[contains(@class, ' map/topicref ')]
												  [@href][not(@href='')][not(@linking='none')]
												  [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]
												  [not(@linking='sourceonly')]
												  [not(@processing-role='resource-only')]
												  [not(@href = $properties-xml-doc//*[@bridge-topic = 'true']/@name)]
												  [last()]"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[contains(@class, ' map/relcell ')]">
				<xsl:if test="$previous/ancestor::*[contains(@class, ' map/relcell ')]
                    and generate-id(ancestor::*[contains(@class, ' map/relcell ')]) = 
                           generate-id($previous/ancestor::*[contains(@class, ' map/relcell ')])">
					<xsl:apply-templates mode="link" select="$previous">
						<xsl:with-param name="role">previous</xsl:with-param>
						<xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="link" select="$previous">
					<xsl:with-param name="role">previous</xsl:with-param>
					<xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:variable name="next" select="(descendant::*|following::*)[contains(@class, ' map/topicref ')][@href][not(@href='')]
												  [not(@linking='none')][not(@linking='sourceonly')]
												  [not(ancestor::*[contains(concat(' ', @chunk, ' '), ' to-content ')])]
												  [not(@processing-role='resource-only')]
												  [not(@href = $properties-xml-doc//*[@bridge-topic = 'true']/@name)]
												  [1]"/>
		<xsl:choose>
			<xsl:when test="ancestor::*[contains(@class, ' map/relcell ')]">
				<xsl:if test="$next/ancestor::*[contains(@class, ' map/relcell ')]
                    and generate-id(ancestor::*[contains(@class, ' map/relcell ')]) 
                        = generate-id($next/ancestor::*[contains(@class, ' map/relcell ')])">
					<xsl:apply-templates mode="link" select="$next">
						<xsl:with-param name="role">next</xsl:with-param>
						<xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
					</xsl:apply-templates>
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates mode="link" select="$next">
					<xsl:with-param name="role">next</xsl:with-param>
					<xsl:with-param name="pathBackToMapDirectory" select="$pathBackToMapDirectory"/>
				</xsl:apply-templates>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>