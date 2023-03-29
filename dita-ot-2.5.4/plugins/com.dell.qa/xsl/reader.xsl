<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ckbk="www.dell.com">

<xsl:output method="text"/>

<xsl:param name="tempDir"/>
<xsl:param name="OUTPUTDIR"/>
<xsl:param name="chapcount"/>
<xsl:param name="inputdir"/>

<xsl:template match="/">

<xsl:variable name="chapCount1"><xsl:choose><xsl:when test="document(concat('file:///',$chapcount))//chapter"><xsl:value-of select="count(document(concat('file:///',$chapcount))//chapter) + count(document(concat('file:///',$chapcount))//appendix)"/></xsl:when><xsl:otherwise><xsl:value-of select="count(document(concat('file:///',$chapcount))//map/topicref)"/></xsl:otherwise></xsl:choose></xsl:variable>

<xsl:variable name="newline"><xsl:text>
</xsl:text></xsl:variable>
<xsl:variable name="guid"><xsl:value-of select="document(concat('file:///',$inputdir,'/',//parameter[@name='export-document'],'.met'))//ishfield[@name='VERSION']"/></xsl:variable>
<xsl:result-document href="{concat(//parameter[@name='export-document'],'-v',$guid)}.text">
<xsl:value-of select="//parameter[@name='export-document']"/>,v<xsl:value-of select="$guid"/>,<xsl:value-of select="//parameter[@name='documenttitle']"/>,<xsl:value-of select="document(concat('file:///',$OUTPUTDIR,'/accessability.txt'))//root"/>,<xsl:for-each select="tokenize((document(concat('file:///',$tempDir,'/readbilityScrore.xml'))//root),$newline)"><xsl:for-each select="tokenize(.,'\s+')[last()]">"<xsl:value-of select="."/>",</xsl:for-each></xsl:for-each>, <xsl:value-of select="document(concat('file:///',$OUTPUTDIR,'/topiccount.xml'))//root"/>,<xsl:value-of select="$chapCount1"/>,<xsl:value-of select="document(concat('file:///',$OUTPUTDIR,'/reuse.xml'))//root"/>,
</xsl:result-document>
</xsl:template>

</xsl:stylesheet>
