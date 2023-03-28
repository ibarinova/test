<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:oxygen="http://www.oxygenxml.com/functions"
				exclude-result-prefixes="oxygen xs">

	<xsl:template match="/|node()|@*" mode="gen-user-header">
		<!-- Navigation to the next, previous siblings and to the parent. -->
		<span id="topic_navigation_links" class="navheader">
			<xsl:if test="$NOPARENTLINK = 'no'">
				<xsl:for-each select=".//*[contains(@class, ' topic/related-links ')]/*[contains(@class, ' topic/linkpool ')][1]
									//*[contains(@class, ' topic/link ')][@role='parent' or @role='previous' or @role='next']">
					<xsl:text>&#10;</xsl:text>
					<xsl:variable name="cls">
						<xsl:choose>
							<xsl:when test="@role = 'parent'">
								<xsl:text>navparent</xsl:text>
							</xsl:when>
							<xsl:when test="@role = 'previous'">
								<xsl:text>navprev</xsl:text>
							</xsl:when>
							<xsl:when test="@role = 'next'">
								<xsl:text>navnext</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>nonav</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<span>
						<xsl:attribute name="class">
							<xsl:value-of select="$cls"/>
						</xsl:attribute>
						<xsl:variable name="textLinkBefore">
							<span class="navheader_label">
								<xsl:choose>
									<xsl:when test="@role = 'parent'">
										<xsl:call-template name="getWebhelpString">
											<xsl:with-param name="stringName" select="'Parent topic'"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="@role = 'previous'">
										<xsl:call-template name="getWebhelpString">
											<xsl:with-param name="stringName" select="'Previous topic'"/>
										</xsl:call-template>
									</xsl:when>
									<xsl:when test="@role = 'next'">
										<xsl:call-template name="getWebhelpString">
											<xsl:with-param name="stringName" select="'Next topic'"/>
										</xsl:call-template>
									</xsl:when>
								</xsl:choose>
							</span>
							<span class="navheader_separator">
								<xsl:text>: </xsl:text>
							</span>
						</xsl:variable>
						<xsl:call-template name="makelink">
							<xsl:with-param name="label" select="$textLinkBefore"/>
						</xsl:call-template>
					</span>
					<xsl:text>  </xsl:text>
				</xsl:for-each>
			</xsl:if>
		</span>
	</xsl:template>


</xsl:stylesheet>
