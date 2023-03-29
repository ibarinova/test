<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				exclude-result-prefixes="xs"
				version="2.0">

	<xsl:import href="plugin:org.dita.xhtml:xsl/dita2xhtml.xsl"/>
	<xsl:import href="xslhtml/dita2htmlImpl-emc.xsl"/>
	<xsl:import href="xslhtml/taskdisplay.xsl"/>
	<xsl:import href="xslhtml/refdisplay.xsl"/>
	<xsl:import href="xslhtml/conceptdisplay.xsl"/>
	<xsl:import href="xslhtml/rel-links.xsl"/>
	<xsl:import href="xslhtml/syntax-braces.xsl"/>
	<xsl:import href="xslhtml/sw-d.xsl"/>
	<xsl:import href="xslhtml/ui-d.xsl"/>
    <xsl:import href="xslhtml/pr-d.xsl"/>
    <xsl:import href="xslhtml/hi-d.xsl"/>
    <xsl:import href="xslhtml/get-meta.xsl"/>
    <xsl:import href="dita2xhtml-util.xsl"/>

	<xsl:output method="xhtml" encoding="utf-8" indent="no" omit-xml-declaration="yes"/>
		
	<xsl:param name="NOPARENTLINK" select="'no'"/>
	<xsl:param name="OUTEXT" select="'.html'"/>
	<xsl:param name="GENERATE-TASK-LABELS" select="'YES'"/>

	<xsl:param name="dita-css"/> <!-- left to right languages -->

	<xsl:param name="bidi-dita-css"/> <!-- bidirectional languages -->

	<!-- add DRAFT if args.draft is set to yes -->
	<xsl:param name="DRAFT"/>

	<!-- add catch for args.bu='rsa' or 'mozy' style sheet -->
	<xsl:param name="ARGS.BU"/>
	<xsl:param name="LANGUAGE"/>

	<xsl:param name="disableRelatedLinks" select="'nofamily'"/>
	<xsl:param name="temp-dir"/>
	<xsl:variable name="temp-dir-uri" select="concat('file:///', translate($temp-dir, '\', '/'), '/')"/>

	<xsl:variable name="newline" select="'&#10;'"/>
	<xsl:variable name="insert-task-labels" as="xs:boolean" select="if(/descendant::*[contains(@class, 'topic/othermeta')][@name = 'task-labels'][last()]/@content = 'no') then(false()) else(true())"/>

	<xsl:template match="/">
	  <xsl:apply-imports />
	</xsl:template>

</xsl:stylesheet>