<xsl:stylesheet xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				exclude-result-prefixes="xs"
				version="2.0">

	<xsl:import href="plugin:org.dita.xhtml:xsl/dita2html5.xsl"/>
	<xsl:import href="plugin:org.dita.xhtml:xsl/map2htmtoc/map2htmlImpl.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/dita2htmlImpl-emc.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/taskdisplay.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/refdisplay.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/conceptdisplay.xsl"/>
<!--	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/rel-links.xsl"/>-->
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/syntax-braces.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/sw-d.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/ui-d.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/pr-d.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/hi-d.xsl"/>
	<xsl:import href="../../com.dellemc.xhtml/xsl/xslhtml/get-meta.xsl"/>
	<xsl:import href="xslhtml/dita2htmlImpl-emc.xsl"/>
	<xsl:import href="xslhtml/taskdisplay.xsl"/>
	<xsl:import href="xslhtml/rel-links.xsl"/>
	<xsl:import href="xslhtml/dita-utilities.xsl"/>

	<xsl:output method="html"
				encoding="UTF-8"
				indent="no"
				doctype-system="about:legacy-compat"
				omit-xml-declaration="yes"/>

	<xsl:param name="NOPARENTLINK" select="'no'"/>
	<xsl:param name="OUTEXT" select="'.html'"/>
	<xsl:param name="GENERATE-TASK-LABELS" select="'YES'"/>
	<xsl:param name="OUTPUTCLASS"/>   <!-- class to put on body element. -->

	<xsl:param name="dita-css"/> <!-- left to right languages -->

	<xsl:param name="bidi-dita-css"/> <!-- bidirectional languages -->

	<!-- add DRAFT if args.draft is set to yes -->
	<xsl:param name="TRANSTYPE"/>
	<xsl:param name="DRAFT"/>
	<xsl:param name="MAP"/>

	<!-- add catch for args.bu='rsa' or 'mozy' style sheet -->
	<xsl:param name="ARGS.BU"/>
	<xsl:param name="LANGUAGE"/>

	<xsl:param name="disableRelatedLinks" select="'nofamily'"/>

	<xsl:param name="temp-dir"/>
	<xsl:variable name="temp-dir-uri" select="concat('file:///', translate($temp-dir, '\', '/'), '/')"/>

	<xsl:variable name="newline" select="'&#10;'"/>

	<xsl:variable name="MAP-path" select="concat('file:///', translate($MAP, '\', '/'), '/')"/>
	<xsl:variable name="MAP-doc" select="document($MAP-path)"/>
	<xsl:variable name="insert-task-labels" as="xs:boolean" select="if($MAP-doc/descendant::*[contains(@class, 'topic/othermeta')][@name = 'task-labels'][last()]/@content = 'no') then(false()) else(true())"/>
	<xsl:variable name="mainbooktitle">
		<xsl:apply-templates select="$MAP-doc/descendant::*[contains(@class, 'bookmap/mainbooktitle')]"/>
	</xsl:variable>

<!--
	<xsl:template match="/">
	  <xsl:apply-imports />
	</xsl:template>
-->

</xsl:stylesheet>