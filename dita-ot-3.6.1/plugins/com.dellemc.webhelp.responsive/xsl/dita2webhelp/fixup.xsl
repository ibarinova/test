<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:xhtml="http://www.w3.org/1999/xhtml"
				exclude-result-prefixes="xs xhtml"
				version="2.0">

	<xsl:template name="generateHeadContent">
		<xsl:apply-templates select="*" mode="fixup"/>
	</xsl:template>

</xsl:stylesheet>