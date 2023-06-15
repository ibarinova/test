<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:relpath="http://dita2indesign/functions/relpath"
                exclude-result-prefixes="#all"
                version="2.0">

    <xsl:output method="xml" indent="yes" exclude-result-prefixes="#all"/>

    <!-- EMC	21-Oct-2015		IB8		TKT-266: map.xml does not handle multiple resourceid correctly -->
    <!-- If a topic which has <resourceid> is referenced more than once in the maps, then the mapID were getting duplicated.
         WebWorks does not show duplicates. So, we are stripping off the duplicates in this clean up style sheet.
    -->
    <xsl:key name="mapID-key" match="mapID" use="concat(@target,'_',@href)"/>

    <xsl:template match="@xmlns"/>

    <xsl:template match="/">
        <map version="1.0" xmlns="urn:WebWorks-Help-Book-Files-Schema">
            <xsl:for-each select="//mapID">
                <xsl:if test="generate-id()=generate-id(key('mapID-key', concat(@target,'_',@href))[1])">
                    <mapID>
                        <xsl:copy-of select="@*[not(name() = 'xmlns')]"/>
                    </mapID>
                </xsl:if>
            </xsl:for-each>
        </map>
    </xsl:template>
</xsl:stylesheet>