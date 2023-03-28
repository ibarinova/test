<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns="http://www.w3.org/1999/xhtml"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				exclude-result-prefixes="#all"
				version="2.0">

	<xsl:import href="../template/mainPageComponentsExpander.xsl"/>

	<xsl:param name="ARGS.INPUT.SCRIPT.MAP"/>
	<xsl:param name="ARGS.BU"/>
	<xsl:param name="DRAFT"/>

	<xsl:template match="*:head" mode="copy_template">
		<xsl:copy>
			<xsl:apply-templates select="node() | @*" mode="#current"/>
			<xsl:call-template name="generate-redirect-script"/>
			<xsl:call-template name="redirect-to-first-topic"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template name="generate-redirect-script">
		<script type="text/javascript" src="./oxygen-webhelp/app/topic-input-sanitizer.js"><!----></script>
		<script type="text/javascript" src="./oxygen-webhelp/app/topic-loader.js"><!----></script>
		<xsl:result-document method="text" href="oxygen-webhelp/app/topic-loader.js">
			<xsl:element name="script">
				<xsl:copy-of select="unparsed-text(concat('file:/', translate($ARGS.INPUT.SCRIPT.MAP, '\', '/')))"/>
				<xsl:text>
</xsl:text>
				<xsl:copy-of select="$script"/>
			</xsl:element>
		</xsl:result-document>
	</xsl:template>


	<xsl:template name="redirect-to-first-topic">
		<xsl:variable name="land-page-url" as="xs:string">
				<!--

					Assumptions:
					Bookmap template containing
					first topic as notes, caution and warning
					second topic as Copyright
					third topic onwards actual publication topics
					During webHelp preprocess we remove Copyrights if othermeta 'hide-admonitions' = 'yes', so second topic is actual first publication topic
				-->
			<xsl:value-of select="($toc//*:topic[not(contains(@outputclass, 'bridge'))]/@href[matches(., '\.htm(1)?')])[1]"/>
		</xsl:variable>

		<xsl:message>Landing page url : <xsl:value-of select="$land-page-url"/></xsl:message>
		<xsl:variable name="first-page-url" as="xs:string">
			<xsl:value-of select="$land-page-url"/>
		</xsl:variable>
		<meta http-equiv="refresh" content="0; url={$first-page-url}"/>
		<xsl:comment> First Topic is <xsl:value-of select="$land-page-url"/></xsl:comment>
	</xsl:template>

	<xsl:variable name="script">
		<xsl:text>
try {
	/**
	 * If an old URL is given, redirect to the corresponding topic from the WebHelp Responsive
	 */

	let actualLocation = encodeURIComponent(window.location.href);
	let newLocation;

	if (actualLocation.match(/[\w\.\-%]+\.htm(l)?%3F(topic|context)%3D([\w#\-]+)/gi) != null) {
		let linkSearchPosition = actualLocation.lastIndexOf("%3F");
		let linkTopicPosition = actualLocation.lastIndexOf("%2F");

		if (linkSearchPosition !== -1) {
			let linkSearch = actualLocation.substr(linkSearchPosition, actualLocation.length);
			let resourceId = linkSearch.split('%3D')[1];

			if (resourceId != null) {
				resourceId = ValidateAndSanitize(resourceId);
				$.each(EMCKickstart.webhelpMap, function (key, value) {
					if (key === resourceId) {
						newLocation = actualLocation.substr(0, linkTopicPosition) + "/" + encodeURIComponent(value);
						window.location.replace(decodeURIComponent(newLocation));
					}
				});
			}
		}
	}

	if (actualLocation.indexOf('%2F%23') !== -1) {
		newLocation = encodeURIComponent(actualLocation.replace(/%2F%23/g, "/%2F"));
		newLocation = newLocation.replace(/%5B/g, '[').replace(/%5D/g, ']');
		window.location.replace(decodeURIComponent(newLocation));
	}

	if (actualLocation.match(/%2Findex\.(.*)%23/gi)!=null) {
		newLocation = actualLocation.replace(/%2Findex\.(.*)%23/gi, "%2F");
		newLocation = newLocation.replace(/%5B/g, '[').replace(/%5D/g, ']');
		window.location.replace(decodeURIComponent(newLocation));
	}

} catch (err) {
	console.log("error occured : \n");
	console.log(err.message);
}
		</xsl:text>
	</xsl:variable>

</xsl:stylesheet>
