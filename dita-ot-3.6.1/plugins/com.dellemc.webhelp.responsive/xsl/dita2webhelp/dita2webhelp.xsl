<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				exclude-result-prefixes="#all"
				version="2.0">

	<xsl:import href="plugin:com.oxygenxml.webhelp.responsive:xsl/dita2webhelp/dita2webhelp.xsl"/>

	<xsl:import href="dita2webhelpImpl.xsl"/>

	<xsl:param name="TEMPDIR"/>
	<xsl:param name="MAP_NAME"/>
	<xsl:param name="GENERATE-TASK-LABELS" select="'YES'"/>
	<xsl:param name="LANGUAGE" select="'en-us'"/>
	<xsl:param name="ARGS.BU"/>
	<xsl:param name="DRAFT"/>
	<xsl:param name="dell-brand"/>
	<xsl:param name="include-draft-comments" select="'no'"/>
	<xsl:param name="properties-xml"/>

	<xsl:variable name="ditamap-doc" select="document(concat('file:///',translate($TEMPDIR, '\', '/'), '/', $MAP_NAME))"/>

	<xsl:variable name="properties-xml-uri" select="concat('file:/', translate($properties-xml, '\', '/'))"/>
	<xsl:variable name="properties-xml-doc" select="document($properties-xml-uri)"/>

	<xsl:variable name="insert-task-labels" as="xs:boolean"
				  select="if(lower-case($ditamap-doc/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'task-labels'][1]/@content) = 'no')
						then(false()) else(true())"/>

	<xsl:variable name="insert-table-numbering" as="xs:boolean"
				  select="if(lower-case($ditamap-doc/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'hide-table-number'][1]/@content) = 'yes')
						then(false()) else(true())"/>

	<xsl:variable name="insert-fig-numbering" as="xs:boolean"
				  select="if(lower-case($ditamap-doc/descendant::*[contains(@class, ' topic/othermeta ')][@name = 'hide-figure-number'][1]/@content) = 'yes')
						then(false()) else(true())"/>

</xsl:stylesheet>