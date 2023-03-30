<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<!-- ==================================================================== -->
	<xsl:template name="array.count">
		<xsl:param name="array"/>
		<xsl:param name="delimiter" select="', '"/>
		<xsl:param name="index" select="1"/>
		<xsl:choose>
			<xsl:when test="contains($array,$delimiter)">
				<xsl:call-template name="array.count">
					<xsl:with-param name="array" select="substring-after($array,$delimiter)"/>
					<xsl:with-param name="index" select="number($index) + 1"/>
					<xsl:with-param name="delimiter" select="$delimiter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($array,$delimiter)">
				<xsl:value-of select="substring-before($array,$delimiter)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$index"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ==================================================================== -->
	<xsl:template name="array.item">
		<xsl:param name="array"/>
		<xsl:param name="delimiter" select="', '"/>
		<xsl:param name="index" select="1"/>
		<xsl:choose>
			<xsl:when test="number($index) &gt; 1">
				<xsl:call-template name="array.item">
					<xsl:with-param name="index" select="number($index) - 1"/>
					<xsl:with-param name="array" select="substring-after($array,$delimiter)"/>
					<xsl:with-param name="delimiter" select="$delimiter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($array,$delimiter)">
				<xsl:value-of select="substring-before($array,$delimiter)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$array"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ==================================================================== -->
	<xsl:template name="array.contains">
		<xsl:param name="array"/>
		<xsl:param name="item"/>
		<xsl:param name="delimiter" select="', '"/>
		<xsl:choose>
			<xsl:when test="string-length($item) = 0">
				<xsl:value-of select="'false'"/>
			</xsl:when>
			<xsl:when test="substring-before($array,$delimiter) = $item">
				<xsl:value-of select="'true'"/>
			</xsl:when>
			<xsl:when test="contains($array,$delimiter)">
				<xsl:call-template name="array.contains">
					<xsl:with-param name="item" select="$item"/>
					<xsl:with-param name="array" select="substring-after($array,$delimiter)"/>
					<xsl:with-param name="delimiter" select="$delimiter"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="$array = $item">
				<xsl:value-of select="'true'"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'false'"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ==================================================================== -->
</xsl:stylesheet>
