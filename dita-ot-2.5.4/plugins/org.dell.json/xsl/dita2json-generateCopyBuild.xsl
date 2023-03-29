<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:fs="java.io.File"
                exclude-result-prefixes="#all"
                version="2.0">
    <xsl:output method="xml"
                encoding="UTF-8"
                indent="yes"
                omit-xml-declaration="yes"/>
    <xsl:param name="images-subfolder-name" select="'image'"/>
    <xsl:param name="file-separator" select="'/'"/>
    <xsl:param name="dita.temp.dir"/>
    <xsl:param name="output.dir"/>
    <xsl:param name="args.input.location"/>
	
	<!--Removed image folder name and added images directly in the json folder-->
    <xsl:variable name="images-subfolder-path" select="concat(translate($images-subfolder-name, '/\', ''), $file-separator)"/>

    <xsl:template match="/">
        <project default="dita2json.copy-files">
            <target name="dita2json.copy-files">
                <move todir="{$dita.temp.dir}{$file-separator}tmp">
                    <fileset dir="{$output.dir}" includes="*.*">
					</fileset>
				</move>

                <xsl:for-each select="/descendant::*[contains(@class, ' bookmap/chapter ')]">
                    <xsl:apply-templates select=".">
                        <xsl:with-param name="output-path" select="$output.dir"/>
                    </xsl:apply-templates>
                </xsl:for-each>
            </target>
        </project>
    </xsl:template>

    <xsl:template match="*[contains(@class, ' map/topicref ')]">
        <xsl:param name="output-path"/>

        <xsl:variable name="href-uri" select="resolve-uri(@href, base-uri(.))"/>
		<!--<xsl:variable name="uc" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'" />
		<xsl:variable name="lc" select="'abcdefghijklmnopqrstuvwxyz'" />-->
        <xsl:if test="doc-available($href-uri)">
            <xsl:variable name="doc" select="document($href-uri)"/>
            <xsl:variable name="title" select="$doc/descendant::*[contains(@class, ' topic/title ')][1]"/>
            <move file="{concat($dita.temp.dir, $file-separator, 'tmp', $file-separator, $title, '.json')}" todir="{concat($output-path, $file-separator, $title)}"/>
            <xsl:for-each select="$doc/descendant::*[contains(@class, ' topic/image ')]">
			<xsl:variable name="image-title">
				<xsl:if test="normalize-space(*[contains(@class, ' topic/alt ')])">
					<xsl:value-of select="normalize-space(*[contains(@class, ' topic/alt ')])"/>
				</xsl:if>
			</xsl:variable>
			    <xsl:variable name="image-href" select="@href"/>
				<xsl:message>image:<xsl:value-of select="$image-href"/></xsl:message>
				<xsl:message>title:<xsl:value-of select="$image-title"/></xsl:message>
                <xsl:choose>
                    <xsl:when test="fs:exists(fs:new(concat(translate($args.input.location, '\', '/'), '/', $image-href)))">
                        <copy file="{concat($args.input.location, $file-separator, $image-href)}" tofile="{concat($output-path, $file-separator, $title, $file-separator, $image-title)}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>'<xsl:value-of select="$image-href"/>' Image doesn't exist in the input sources.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
			<xsl:for-each select="$doc/descendant::*[contains(@class, ' topic/xref ')]">
                <xsl:variable name="json-href" select="@href"/>
				<xsl:variable name="json-title" select="."/>
                <xsl:choose>
                    <xsl:when test="fs:exists(fs:new(concat(translate($args.input.location, '\', '/'), '/', $json-href)))">
                        <copy file="{concat($args.input.location, $file-separator, $json-href)}" tofile="{concat($output-path, $file-separator, $title, $file-separator, $json-title )}"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>'<xsl:value-of select="$json-href"/>' Json doesn't exist in the input sources.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>

            <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
                <xsl:with-param name="output-path" select="concat($output-path, $file-separator, $title)"/>
            </xsl:apply-templates>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>