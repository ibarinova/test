<?xml version="1.0" encoding="UTF-8" ?>
<!-- This file is part of the DITA Open Toolkit project hosted on
     Sourceforge.net. See the accompanying license.txt file for
     applicable licenses.-->
<!-- (c) Copyright IBM Corp. 2004, 2005 All Rights Reserved. -->
<!-- Used as starting point by SDL for EMC ATL output
     This template combines the current document (parsed tree with all maps resolved) AND
     the SDL Architect export report XML file (<PUB GUID>.report.xml) to generate an Annotated Topic List
     containing a tree of the publication incl extra information about each object -->

<!DOCTYPE xsl:stylesheet [

        <!ENTITY gt            "&gt;">
        <!ENTITY lt            "&lt;">
        <!ENTITY rbl           " ">
        <!ENTITY nbsp          "&#xA0;">
        <!-- &#160; -->
        <!ENTITY quot          "&#34;">
        <!ENTITY copyr         "&#169;">
        ]>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:dita-ot="http://dita-ot.sourceforge.net/ns/201007/dita-ot"
                xmlns:ditamsg="http://dita-ot.sourceforge.net/ns/200704/ditamsg"
                xmlns:saxon="http://icl.com/saxon" extension-element-prefixes="saxon"
                xmlns:java="org.dita.dost.util.StringUtils" exclude-result-prefixes="java dita-ot ditamsg">

    <!-- map2htmltoc.xsl   main stylesheet
       Convert DITA map to a simple HTML table-of-contents view.
       Input = one DITA map file
       Output = one HTML file for viewing/checking by the author.

       Options:
          OUTEXT  = XHTML output extension (default is '.html')
          WORKDIR = The working directory that contains the document being transformed.
                     Needed as a directory prefix for the @href "document()" function calls.
                     Default is './'
  -->

    <!-- Include error message template -->
    <xsl:import href="../../../xsl/common/output-message.xsl"/>
    <xsl:import href="../../../xsl/common/dita-textonly.xsl"/>
    <xsl:import href="../../../xsl/common/dita-utilities.xsl"/>
    <!--<xsl:import href="common/dita-utilities.xsl"/>-->
    <!-- xsl:import href="common/infoshare.params.xsl"/>
    <xsl:import href="common/infoshare.jobticket.xsl"/>
    <xsl:import href="common/infoshare.I18N.xsl"/ -->

    <xsl:output method="html" indent="no" encoding="UTF-8"/>

    <!-- Set the prefix for error message numbers -->
    <xsl:variable name="msgprefix">DOTX</xsl:variable>

    <xsl:param name="variableFiles.path"/>
    <xsl:variable name="variableFiles.url"
                  select="resolve-uri(concat('file:///', translate($variableFiles.path, '\', '/')))"/>

    <!-- *************************** Command line parameters *********************** -->
    <xsl:param name="OUTEXT" select="'.html'"/>
    <!-- "htm" and "html" are valid values -->
    <xsl:param name="WORKDIR" select="'./'"/>
    <xsl:param name="DITAEXT" select="'.xml'"/>
    <xsl:param name="FILEREF" select="'file://'"/>
    <xsl:param name="contenttarget" select="'contentwin'"/>
    <xsl:param name="CSS"/>
    <xsl:param name="CSSPATH"/>
    <xsl:param name="OUTPUTCLASS"/>
    <xsl:param name="jobTicket" select="concat($WORKDIR, '../', 'ishjobticket.xml')"/>
    <!-- class to put on body element. -->
    <!-- the path back to the project. Used for c.gif, delta.gif, css to allow user's to have
    these files in 1 location. -->
    <xsl:param name="PATH2PROJ">
        <xsl:apply-templates select="/processing-instruction('path2project')" mode="get-path2project"/>
    </xsl:param>
    <xsl:param name="genDefMeta" select="'no'"/>
    <!-- Define a newline character -->
    <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
    </xsl:variable>
    <xsl:variable name="PublicationID">
        <xsl:call-template name="getJobTicketParam">
            <xsl:with-param name="varname" select="'export-document'"/>
            <xsl:with-param name="default" select="'No title found'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="MainMapID">
        <xsl:call-template name="getJobTicketParam">
            <xsl:with-param name="varname" select="'export-start-document'"/>
            <xsl:with-param name="default" select="'No title found'"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="reportdoc" select="document(concat($WORKDIR, '../', $PublicationID, '.report.xml'),/)/*"/>

    <xsl:template match="processing-instruction('path2project')" mode="get-path2project">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- *********************************************************************************
       Setup the HTML wrapper for the table of contents
       ********************************************************************************* -->
    <!--Added by William on 2009-11-23 for bug:2900047 extension bug start -->
    <xsl:template match="/">
        <xsl:call-template name="generate-toc"/>
    </xsl:template>
    <!--Added by William on 2009-11-23 for bug:2900047 extension bug end -->
    <!--  -->
    <xsl:template name="generate-toc">
        <xsl:variable name="metadata"
                      select="document(concat($WORKDIR, '../', /descendant::*[@id][1]/@id, '.met'),/)/*"/>
        <xsl:variable name="pubmetadata" select="document(concat($WORKDIR, '../', //*/$PublicationID, '.met'),/)/*"/>
        <xsl:variable name="productdef"
                      select="document(concat($WORKDIR, '../../../ProductDefinition.xml'),/)"/>
        <html>
            <xsl:value-of select="$newline"/>
            <head>
                <xsl:value-of select="$newline"/>
                <xsl:if test="string-length($contenttarget)>0 and $contenttarget!='NONE'">
                    <base target="{$contenttarget}"/>
                    <xsl:value-of select="$newline"/>
                </xsl:if>
                <!-- initial meta information -->
                <xsl:call-template name="generateCharset"/>
                <!-- Set the character set to UTF-8 -->
                <xsl:call-template name="generateDefaultCopyright"/>
                <!-- Generate a default copyright, if needed -->
                <xsl:call-template name="generateDefaultMeta"/>
                <!-- Standard meta for security, robots, etc -->
                <xsl:call-template name="copyright"/>
                <!-- Generate copyright, if specified manually -->
                <xsl:call-template name="generateCssLinks"/>
                <!-- Generate links to CSS files -->
                <xsl:call-template name="generateMapTitle"/>
                <!-- Generate the <title> element -->
                <xsl:call-template name="gen-user-head"/>
                <!-- include user's XSL HEAD processing here -->
                <xsl:call-template name="gen-user-scripts"/>
                <!-- include user's XSL javascripts here -->
                <xsl:call-template name="gen-user-styles"/>
                <!-- include user's XSL style element and content here -->
            </head>
            <xsl:value-of select="$newline"/>

            <body name="Top">
                <xsl:if test="string-length($OUTPUTCLASS) &gt; 0">
                    <xsl:attribute name="class">
                        <xsl:value-of select="$OUTPUTCLASS"/>
                    </xsl:attribute>
                </xsl:if>
                <xsl:value-of select="$newline"/>
                <xsl:element name="table">
                    <xsl:element name="TR">
                        <xsl:element name="TD">
                            <xsl:element name="b">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.publicationname'"/>
                                </xsl:call-template>
                                <xsl:text> : </xsl:text>
                                <xsl:call-template name="getJobTicketParam">
                                    <xsl:with-param name="varname" select="'documenttitle'"/>
                                    <xsl:with-param name="default" select="'No title found'"/>
                                </xsl:call-template>
                                <xsl:text>	 </xsl:text>
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.version'"/>
                                </xsl:call-template>
                                <xsl:text> : </xsl:text>
                                <xsl:call-template name="getMetadataValue">
                                    <xsl:with-param name="document" select="$pubmetadata"/>
                                    <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                                    <xsl:with-param name="fieldname">
                                        <xsl:value-of select="'VERSION'"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="fieldlevel">
                                        <xsl:value-of select="'version'"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="default">
                                        <xsl:value-of select="'-1'"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                        <xsl:element name="TD"/>
                        <xsl:element name="TD"/>
                        <xsl:element name="TD">
                            <xsl:element name="b">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.maptitle'"/>
                                </xsl:call-template>
                                <xsl:text> : </xsl:text>
                                <xsl:call-template name="getMetadataValue">
                                    <xsl:with-param name="document" select="$metadata"/>
                                    <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                                    <xsl:with-param name="fieldname">
                                        <xsl:value-of select="'FTITLE'"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="fieldlevel">
                                        <xsl:value-of select="'logical'"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="default">
                                        <xsl:value-of select="'-1'"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                                <xsl:text>	 </xsl:text>
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.version'"/>
                                </xsl:call-template>
                                <xsl:text> : </xsl:text>
                                <xsl:call-template name="getMetadataValue">
                                    <xsl:with-param name="document" select="$metadata"/>
                                    <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                                    <xsl:with-param name="fieldname">
                                        <xsl:value-of select="'VERSION'"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="fieldlevel">
                                        <xsl:value-of select="'version'"/>
                                    </xsl:with-param>
                                    <xsl:with-param name="default">
                                        <xsl:value-of select="'-1'"/>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                    </xsl:element>
                    <xsl:element name="TR"/>
                    <xsl:choose>
                        <xsl:when test="not($productdef)"/>
                        <xsl:otherwise>
                            <xsl:element name="TR">
                                <xsl:element name="TD">
                                    <xsl:element name="b">
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'atl.ConditionName'"/>
                                        </xsl:call-template>
                                    </xsl:element>
                                </xsl:element>

                                <xsl:for-each select="$productdef//feature">
                                    <xsl:element name="TD">
                                        <xsl:value-of select="./@name"/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:element>
                            <xsl:element name="TR">
                                <xsl:element name="TD">
                                    <xsl:element name="b">
                                        <xsl:call-template name="getVariable">
                                            <xsl:with-param name="id" select="'atl.ConditionValue'"/>
                                        </xsl:call-template>
                                    </xsl:element>
                                </xsl:element>
                                <xsl:for-each select="$productdef//feature">
                                    <xsl:element name="TD">
                                        <xsl:value-of select="./@value"/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>

                    <xsl:element name="TR"/>
                    <xsl:value-of select="$newline"/>
                    <xsl:element name="table">
                        <xsl:attribute name="border">0</xsl:attribute>
                        <xsl:attribute name="cellpadding">1</xsl:attribute>
                        <xsl:attribute name="cellspacing">0</xsl:attribute>
                        <xsl:attribute name="width">99%</xsl:attribute>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">15%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">2%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">2%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">2%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">15%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">2%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">15%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="col">
                            <xsl:attribute name="width">5%</xsl:attribute>
                        </xsl:element>
                        <xsl:element name="TR">
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.topicname1'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.topicname2'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.topicname3'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.topicname4'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.topicname5+'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.objectname'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.version'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.objecttype'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.topictype'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.parentobject'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.reused'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.datecreated'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.datemodified'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.status'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.informationarchitect'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.writer'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.lastmodifiedby'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.shortdescription'"/>
                                </xsl:call-template>
                            </xsl:element>
                            <xsl:element name="TH">
                                <xsl:call-template name="getVariable">
                                    <xsl:with-param name="id" select="'atl.GUID'"/>
                                </xsl:call-template>
                            </xsl:element>
                        </xsl:element>
                        <!-- parse the XML -->
                        <xsl:apply-templates/>
                        <!-- end with conrefs -->
                        <xsl:element name="TR">
                            <xsl:element name="TD">
                                <xsl:element name="b">
                                    <xsl:call-template name="getVariable">
                                        <xsl:with-param name="id" select="'atl.LibraryConrefTopics'"/>
                                    </xsl:call-template>
                                </xsl:element>
                            </xsl:element>
                        </xsl:element>
                        <!--  looking for conref libraries that are not part of the Map tree -->
                        <xsl:for-each select="$reportdoc//conref-start">
                            <xsl:variable name="resolved-conref" select="./@resolved-conref"/>
                            <xsl:variable name="id" select="substring-before($resolved-conref,'#')"/>
                            <xsl:choose>
                                <xsl:when test="$reportdoc//link-start[@ref=$id]">
                                    <!-- object is in the map tree so is already in the ATL -->
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- only want the first occurence a library topic reuse -->
                                    <xsl:if
                                            test="$id and $id!='' and count(preceding::conref-start[substring-before(@resolved-conref,'#')=$id])=0">
                                        <xsl:call-template name="create-row">
                                            <xsl:with-param name="id" select="$id"/>
                                            <xsl:with-param name="document"
                                                            select="document(concat($WORKDIR, '../', $id, '.xml'),/)/*"/>
                                        </xsl:call-template>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:element>
                    <xsl:value-of select="$newline"/>
                </xsl:element>
            </body>
            <xsl:value-of select="$newline"/>
        </html>
    </xsl:template>

    <xsl:template name="generateCharset">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
        <xsl:value-of select="$newline"/>
    </xsl:template>

    <!-- If there is no copyright in the document, make the standard one -->
    <xsl:template name="generateDefaultCopyright">
        <xsl:if test="not(//*[contains(@class,' topic/copyright ')])">
            <meta name="copyright">
                <xsl:attribute name="content">
                    <xsl:text>(C) </xsl:text>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Copyright'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                </xsl:attribute>
            </meta>
            <xsl:value-of select="$newline"/>
            <meta name="DC.rights.owner">
                <xsl:attribute name="content">
                    <xsl:text>(C) </xsl:text>
                    <xsl:call-template name="getVariable">
                        <xsl:with-param name="id" select="'Copyright'"/>
                    </xsl:call-template>
                    <xsl:text> </xsl:text>
                </xsl:attribute>
            </meta>
            <xsl:value-of select="$newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="generateDefaultMeta">
        <xsl:if test="$genDefMeta='yes'">
            <meta name="security" content="public"/>
            <xsl:value-of select="$newline"/>
            <meta name="Robots" content="index,follow"/>
            <xsl:value-of select="$newline"/>
            <xsl:text disable-output-escaping="yes">&lt;meta http-equiv="PICS-Label" content='(PICS-1.1 "http://www.icra.org/ratingsv02.html" l gen true r (cz 1 lz 1 nz 1 oz 1 vz 1) "http://www.rsac.org/ratingsv01.html" l gen true r (n 0 s 0 v 0 l 0) "http://www.classify.org/safesurf/" l gen true r (SS~~000 1))' /></xsl:text>
            <xsl:value-of select="$newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="copyright"></xsl:template>
    <!-- *********************************************************************************
       If processing only a single map, setup the HTML wrapper and output the contents.
       Otherwise, just process the contents.
       SDL: Disabled. All processing should go through main template
       ********************************************************************************* -->
    <!-- xsl:template match="/*[contains(@class, ' map/map ')]">
      <xsl:param name="pathFromMaplist"/>
      <xsl:if test=".//*[contains(@class, ' map/topicref ')]">
        <xsl:value-of select="$newline"/>
        <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
          <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
        </xsl:apply-templates>
        <xsl:value-of select="$newline"/>
      </xsl:if>
    </xsl:template -->

    <xsl:template name="generateMapTitle">
        <!-- Title processing - special handling for short descriptions -->
        <xsl:if
                test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')] or /*[contains(@class,' map/map ')]/@title">
            <title>
                <xsl:call-template name="gen-user-panel-title-pfx"/>
                <!-- hook for a user-XSL title prefix -->
                <xsl:choose>
                    <xsl:when test="/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')]">
                        <xsl:value-of
                                select="normalize-space(/*[contains(@class,' map/map ')]/*[contains(@class,' topic/title ')])"
                                />
                    </xsl:when>
                    <xsl:when test="/*[contains(@class,' map/map ')]/@title">
                        <xsl:value-of select="/*[contains(@class,' map/map ')]/@title"/>
                    </xsl:when>
                </xsl:choose>
            </title>
            <xsl:value-of select="$newline"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="gen-user-panel-title-pfx">
        <xsl:apply-templates select="." mode="gen-user-panel-title-pfx"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-panel-title-pfx">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- It will be placed immediately after TITLE tag, in the title -->
    </xsl:template>

    <!-- *********************************************************************************
      Main template going through the tree and finding any sub-maps to include from the <PUB-GUID>.report.xml
       ********************************************************************************* -->
    <xsl:template match="*[contains(@class, ' map/topicref ')]|*[contains(@class, ' map/map ')]|*[contains(@class, ' topic/image ')]">
        <xsl:param name="pathFromMaplist"/>
        <xsl:param name="depth"/>
        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="@href and @href!=''">
                    <xsl:value-of select="substring-before(./@href,'.')"/>
                </xsl:when>
                <xsl:when test="@id and @id!=''">
                    <xsl:value-of select="@id"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$id and $id!=''">
                <!-- First check if this topic was the first one of a submap that was unwrapped. We need this submap info in the ATL -->
                <!-- Topics can be used more than once in the map. Use $occurence for the topic to find the correct map in the report xml -->
                <xsl:variable name="occurence" select="count(preceding::*[@href=concat($id,'.xml')])+1"/>
                <xsl:variable name="linkstartnode"
                              select="($reportdoc//object-report/link-start[@ref=$id])[$occurence]"/>
                <xsl:variable name="mapid">
                    <xsl:if test="count($linkstartnode/preceding-sibling::link-start)=0">
                        <xsl:value-of select="$linkstartnode/../@ishref"/>
                    </xsl:if>
                </xsl:variable>
                <!-- if we find a map, put the map through the template also to include it in the ATL-->
                <xsl:choose>
                    <xsl:when test="$mapid and $mapid!='' and $mapid!=$MainMapID">
                        <xsl:call-template name="create-row">
                            <xsl:with-param name="id" select="$mapid"/>
                            <xsl:with-param name="mapid" select="$mapid"/>
                            <xsl:with-param name="document"
                                            select="document(concat($WORKDIR, '../', $mapid, '.ditamap'),/)/*"/>
                            <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
                <!-- process the topicref itself -->

                <xsl:choose>
                    <xsl:when test=".[contains(@class, ' topic/image ')]">
                        <xsl:call-template name="create-row">
                            <xsl:with-param name="id" select="$id"/>
                            <!-- xsl:with-param name="mapid" select="$mapid"/ -->
                            <xsl:with-param name="depth" select="$depth"/>
                            <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:call-template name="create-row">
                            <xsl:with-param name="id" select="$id"/>
                            <xsl:with-param name="mapid" select="$mapid"/>
                            <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <!-- if it is an empty topicref or chapter/part -->
                <xsl:call-template name="create-row">
                    <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                </xsl:call-template>
                <!-- xsl:apply-templates select="*[contains(@class, ' map/topicref ')]"> </xsl:apply-templates -->
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- template to create the actual row in the table -->
    <xsl:template name="create-row">
        <xsl:param name="id" select="''"/>
        <xsl:param name="mapid" select="''"/>
        <xsl:param name="pathFromMaplist"/>
        <xsl:param name="document" select="."/>
        <xsl:param name="depth" select="count(ancestor::*)"/>
        <xsl:variable name="metadata" select="document(concat($WORKDIR, '../', $id, '.met'),/)/*"/>
        <xsl:variable name="objecttype">
            <xsl:call-template name="getObjectType">
                <xsl:with-param name="document" select="$metadata"/>
                <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                <xsl:with-param name="default">
                    <xsl:value-of select="''"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <!-- need depth to determine the column number in which to place the title of the object -->
        <xsl:variable name="element-name">
            <xsl:value-of select="name($document/.)"/>
        </xsl:variable>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$objecttype='Illustration'">
                    <xsl:call-template name="getMetadataValue">
                        <xsl:with-param name="document" select="$metadata"/>
                        <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                        <xsl:with-param name="fieldname">
                            <xsl:value-of select="'FTITLE'"/>
                        </xsl:with-param>
                        <xsl:with-param name="fieldlevel">
                            <xsl:value-of select="'logical'"/>
                        </xsl:with-param>
                        <xsl:with-param name="default">
                            <xsl:value-of select="''"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$document" mode="get-navtitle"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$title and $title!='' and $depth>0">
                <xsl:element name="TR">
                    <xsl:choose>
                        <!-- Topic <title> (Topic name). Choose right level -->
                        <xsl:when test="$depth=1">
                            <xsl:element name="TD">
                                <xsl:choose>
                                    <xsl:when test="contains($title,'!#!')">
                                        <xsl:value-of select="substring-before($title,'!#!')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$title"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                        </xsl:when>
                        <xsl:when test="$depth=2">
                            <xsl:element name="TD"/>
                            <xsl:element name="TD">
                                <xsl:choose>
                                    <xsl:when test="contains($title,'!#!')">
                                        <xsl:value-of select="substring-before($title,'!#!')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$title"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                        </xsl:when>
                        <xsl:when test="$depth=3">
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD">
                                <xsl:choose>
                                    <xsl:when test="contains($title,'!#!')">
                                        <xsl:value-of select="substring-before($title,'!#!')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$title"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                        </xsl:when>
                        <xsl:when test="$depth=4">
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD">
                                <xsl:choose>
                                    <xsl:when test="contains($title,'!#!')">
                                        <xsl:value-of select="substring-before($title,'!#!')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$title"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                            <xsl:element name="TD"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD"/>
                            <xsl:element name="TD">
                                <xsl:choose>
                                    <xsl:when test="contains($title,'!#!')">
                                        <xsl:value-of select="substring-before($title,'!#!')"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$title"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:element name="TD">
                        <!-- Topic FTITLE (Object name) -->
                        <xsl:call-template name="getMetadataValue">
                            <xsl:with-param name="document" select="$metadata"/>
                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                            <xsl:with-param name="fieldname">
                                <xsl:value-of select="'FTITLE'"/>
                            </xsl:with-param>
                            <xsl:with-param name="fieldlevel">
                                <xsl:value-of select="'logical'"/>
                            </xsl:with-param>
                            <xsl:with-param name="default">
                                <xsl:value-of select="''"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Version of object -->
                        <xsl:call-template name="getMetadataValue">
                            <xsl:with-param name="document" select="$metadata"/>
                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                            <xsl:with-param name="fieldname">
                                <xsl:value-of select="'VERSION'"/>
                            </xsl:with-param>
                            <xsl:with-param name="fieldlevel">
                                <xsl:value-of select="'version'"/>
                            </xsl:with-param>
                            <xsl:with-param name="default">
                                <xsl:value-of select="''"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Object type (map/topic/etc) -->
                        <xsl:value-of select="$objecttype"/>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Topic type  (task/concept/etc) -->
                        <xsl:variable name="typefield">
                            <xsl:choose>
                                <xsl:when test="$objecttype='Topic'">
                                    <xsl:value-of select="'FMODULETYPE'"/>
                                </xsl:when>
                                <xsl:when test="$objecttype='Map'">
                                    <xsl:value-of select="'FMASTERTYPE'"/>
                                </xsl:when>
                                <xsl:when test="$objecttype='Library'">
                                    <xsl:value-of select="'FLIBRARYTYPE'"/>
                                </xsl:when>
                                <xsl:when test="$objecttype='Illustration'">
                                    <xsl:value-of select="'FILLUSTRATIONTYPE'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="FMODULETYPE"/>
                                </xsl:otherwise>
                            </xsl:choose>

                        </xsl:variable>
                        <xsl:call-template name="getMetadataValue">
                            <xsl:with-param name="document" select="$metadata"/>
                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                            <xsl:with-param name="fieldname">
                                <xsl:value-of select="$typefield"/>
                            </xsl:with-param>
                            <xsl:with-param name="fieldlevel">
                                <xsl:value-of select="'logical'"/>
                            </xsl:with-param>
                            <xsl:with-param name="default">
                                <xsl:value-of select="''"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Parent Object FTITLE -->
                        <xsl:if test="$depth>1">
                            <xsl:choose>
                                <!-- if parent is a topicref element (only - map/topicref as class, exact match) we can get if directly from the open map -->
                                <xsl:when test="../@class='- map/topicref '">
                                    <xsl:call-template name="getMetadataValue">
                                        <xsl:with-param name="document"
                                                        select="document(concat($WORKDIR, '../', substring-before(../@href,'.'), '.met'),/)/*"/>
                                        <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                                        <xsl:with-param name="fieldname">
                                            <xsl:value-of select="'FTITLE'"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="fieldlevel">
                                            <xsl:value-of select="'logical'"/>
                                        </xsl:with-param>
                                        <xsl:with-param name="default">
                                            <xsl:value-of select="''"/>
                                        </xsl:with-param>
                                    </xsl:call-template>
                                </xsl:when>
                                <xsl:otherwise>
                                    <!-- Finding the right parent to display from the <PUB-GUID>.report.xml in case it's a submap -->
                                    <xsl:variable name="occurence"
                                                  select="count(preceding::*[@href=concat($id,'.xml')])+1"/>
                                    <xsl:variable name="linkstartnode"
                                                  select="($reportdoc//object-report/link-start[@ref=$id])[$occurence]"/>
                                    <xsl:variable name="curmapid" select="$linkstartnode/../@ishref"/>
                                    <xsl:variable name="parentid">
                                        <xsl:choose>
                                            <xsl:when test="$objecttype='Illustration'">
                                                <xsl:value-of select="/descendant-or-self::*[@id][1]/@id"/>
                                            </xsl:when>
                                            <xsl:when test="$curmapid and $curmapid!='' and $curmapid!=$MainMapID">
                                                <xsl:value-of select="$curmapid"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="substring-before(../@href,'.')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:variable>
                                    <xsl:if test="$parentid and $parentid!=''">
                                        <xsl:call-template name="getMetadataValue">
                                            <xsl:with-param name="document"
                                                            select="document(concat($WORKDIR, '../', $parentid, '.met'),/)/*"/>
                                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                                            <xsl:with-param name="fieldname">
                                                <xsl:value-of select="'FTITLE'"/>
                                            </xsl:with-param>
                                            <xsl:with-param name="fieldlevel">
                                                <xsl:value-of select="'logical'"/>
                                            </xsl:with-param>
                                            <xsl:with-param name="default">
                                                <xsl:value-of select="''"/>
                                            </xsl:with-param>
                                        </xsl:call-template>
                                    </xsl:if>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Reused (empty column) -->
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Date created (From metadata) -->
                        <xsl:variable name="eurodate">
                            <xsl:call-template name="getMetadataValue">
                                <xsl:with-param name="document" select="$metadata"/>
                                <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                                <xsl:with-param name="fieldname">
                                    <xsl:value-of select="'CREATED-ON'"/>
                                </xsl:with-param>
                                <xsl:with-param name="fieldlevel">
                                    <xsl:value-of select="'lng'"/>
                                </xsl:with-param>
                                <xsl:with-param name="default">
                                    <xsl:value-of select="''"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="$eurodate!=''">
                            <xsl:value-of
                                    select="concat(substring-before(substring-after($eurodate,'/'),'/'), '/', substring-before($eurodate,'/'), '/', substring-after(substring-after($eurodate,'/'),'/'))"
                                    />
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Date modified (From metadata) -->
                        <xsl:variable name="eurodate">
                            <xsl:call-template name="getMetadataValue">
                                <xsl:with-param name="document" select="$metadata"/>
                                <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                                <xsl:with-param name="fieldname">
                                    <xsl:value-of select="'FISHLASTMODIFIEDON'"/>
                                </xsl:with-param>
                                <xsl:with-param name="fieldlevel">
                                    <xsl:value-of select="'lng'"/>
                                </xsl:with-param>
                                <xsl:with-param name="default">
                                    <xsl:value-of select="''"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="$eurodate!=''">
                            <xsl:value-of
                                    select="concat(substring-before(substring-after($eurodate,'/'),'/'), '/', substring-before($eurodate,'/'), '/', substring-after(substring-after($eurodate,'/'),'/'))"
                                    />
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Workflow status (From metadata) -->
                        <xsl:call-template name="getMetadataValue">
                            <xsl:with-param name="document" select="$metadata"/>
                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                            <xsl:with-param name="fieldname">
                                <xsl:value-of select="'FSTATUS'"/>
                            </xsl:with-param>
                            <xsl:with-param name="fieldlevel">
                                <xsl:value-of select="'lng'"/>
                            </xsl:with-param>
                            <xsl:with-param name="default">
                                <xsl:value-of select="''"/>
                            </xsl:with-param>
                        </xsl:call-template>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Information architect (From metadata) -->
                        <!-- xsl:if test="$objecttype!='Illustration'" -->
                        <xsl:call-template name="getMetadataValue">
                            <xsl:with-param name="document" select="$metadata"/>
                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                            <xsl:with-param name="fieldname">
                                <xsl:value-of select="'FEMCINFORMATIONARCHITECT'"/>
                            </xsl:with-param>
                            <xsl:with-param name="fieldlevel">
                                <xsl:value-of select="'lng'"/>
                            </xsl:with-param>
                            <xsl:with-param name="default">
                                <xsl:value-of select="''"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <!-- /xsl:if -->
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Writer (From metadata) -->
                        <!-- xsl:if test="$objecttype!='Illustration'" -->
                        <xsl:call-template name="getMetadataValue">
                            <xsl:with-param name="document" select="$metadata"/>
                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                            <xsl:with-param name="fieldname">
                                <xsl:value-of select="'FAUTHOR'"/>
                            </xsl:with-param>
                            <xsl:with-param name="fieldlevel">
                                <xsl:value-of select="'lng'"/>
                            </xsl:with-param>
                            <xsl:with-param name="default">
                                <xsl:value-of select="''"/>
                            </xsl:with-param>
                        </xsl:call-template>
                        <!-- /xsl:if -->
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- Last modified by (From metadata) -->
                        <xsl:call-template name="getMetadataValue">
                            <xsl:with-param name="document" select="$metadata"/>
                            <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                            <xsl:with-param name="fieldname">
                                <xsl:value-of select="'FISHLASTMODIFIEDBY'"/>
                            </xsl:with-param>
                            <xsl:with-param name="fieldlevel">
                                <xsl:value-of select="'lng'"/>
                            </xsl:with-param>
                            <xsl:with-param name="default">
                                <xsl:value-of select="''"/>
                            </xsl:with-param>
                        </xsl:call-template>

                    </xsl:element>
                    <xsl:element name="TD">
                        <xsl:if test="$objecttype!='Illustration'">
                            <!-- Short description (for topics) (From metadata) -->
                            <xsl:value-of select="substring-after($title,'!#!')"/>
                        </xsl:if>
                    </xsl:element>
                    <xsl:element name="TD">
                        <!-- GUID -->
                        <xsl:value-of select="$id"/>
                    </xsl:element>
                </xsl:element>
            </xsl:when>

            <xsl:otherwise>
                <!-- if it is an empty topicref -->

                <!-- xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
                </xsl:apply-templates -->

            </xsl:otherwise>
        </xsl:choose>

        <!-- If there are image elements in the XML, process them but not if the object just processed was an image. -->
        <xsl:if test="$objecttype!='Illustration' and $objecttype!='Template' and $objecttype!='Map'">
            <xsl:variable name="FileWithPath">
                <xsl:choose>
                    <xsl:when test="@copy-to and not(contains(@chunk, 'to-content'))">
                        <xsl:value-of select="$WORKDIR"/>
                        <xsl:value-of select="@copy-to"/>
                        <xsl:if test="not(contains(@copy-to, '#')) and contains(@href, '#')">
                            <xsl:value-of select="concat('#', substring-after(@href, '#'))"/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:when test="contains(@href,'#')">
                        <xsl:value-of select="$WORKDIR"/>
                        <xsl:value-of select="substring-before(@href,'#')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$WORKDIR"/>
                        <xsl:value-of select="@href"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="TargetFile" select="document($FileWithPath,/)"/>

            <xsl:choose>
                <xsl:when test="not($TargetFile)">
                    <xsl:apply-templates select="." mode="ditamsg:missing-target-file-no-navtitle"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="$TargetFile//image">
                        <xsl:with-param name="depth" select="$depth+1"/>
                    </xsl:apply-templates>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>

        <!-- If there are any children, process them -->
        <xsl:choose>
            <!-- if it was a submap we don't want to process any children, since the content of the submap is already part of the merged document -->
            <xsl:when test="$mapid=$id and $id!='' and $mapid!=$MainMapID"/>
            <!-- Apply on children -->
            <xsl:otherwise>
                <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
                    <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:value-of select="$newline"/>

    </xsl:template>

    <!-- SDL Disabled: everything goes through main template -->
    <!-- xsl:template
      match="*[contains(@class, ' map/topicref ')]">
      <xsl:param name="pathFromMaplist"/>
      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]">
        <xsl:with-param name="pathFromMaplist" select="$pathFromMaplist"/>
      </xsl:apply-templates>
    </xsl:template -->

    <xsl:template match="processing-instruction('workdir')" mode="get-work-dir">
        <xsl:value-of select="."/>
        <xsl:text>/</xsl:text>
    </xsl:template>

    <!-- Deprecating the named template in favor of the mode template. -->
    <xsl:template name="navtitle">
        <xsl:apply-templates select="." mode="get-navtitle"/>
    </xsl:template>
    <xsl:template match="*" mode="get-navtitle">
        <!-- xsl:variable name="WORKDIR">
          <xsl:value-of select="$FILEREF"/>
          <xsl:apply-templates select="/processing-instruction()" mode="get-work-dir"/>
        </xsl:variable -->
        <xsl:choose>

            <!-- If this references a DITA file (has @href, not "local" or "external"),
               try to open the file and get the title -->
            <xsl:when
                    test="@href and not(@href='') and
                    not ((ancestor-or-self::*/@scope)[last()]='external') and
                    not ((ancestor-or-self::*/@scope)[last()]='peer') and
                    not ((ancestor-or-self::*/@type)[last()]='external') and
                    not ((ancestor-or-self::*/@type)[last()]='local')">
                <xsl:apply-templates select="." mode="getNavtitleFromTopic">
                    <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- Added since we're now also using this template to get the title for a direct topic (with ID),
              instead of just resolved topics in a map tree (with HREF) -->
            <xsl:when
                    test="(name(.)='map' or name(.)='bookmap') and @id and not(@id='') and
        not ((ancestor-or-self::*/@scope)[last()]='external') and
        not ((ancestor-or-self::*/@scope)[last()]='peer') and
        not ((ancestor-or-self::*/@type)[last()]='external') and
        not ((ancestor-or-self::*/@type)[last()]='local')">
                <xsl:apply-templates select="." mode="getNavtitleFromTopic">
                    <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                    <xsl:with-param name="href" select="concat(@id,'.ditamap')"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when
                    test="@id and not(@id='') and
        not ((ancestor-or-self::*/@scope)[last()]='external') and
        not ((ancestor-or-self::*/@scope)[last()]='peer') and
        not ((ancestor-or-self::*/@type)[last()]='external') and
        not ((ancestor-or-self::*/@type)[last()]='local')">
                <xsl:apply-templates select="." mode="getNavtitleFromTopic">
                    <xsl:with-param name="WORKDIR" select="$WORKDIR"/>
                    <xsl:with-param name="href" select="concat(@id,'.xml')"/>
                </xsl:apply-templates>
            </xsl:when>
            <!-- If navtitle is specified, use it (!?but it should only be used when locktitle=yes is specifed?!) -->
            <xsl:when
                    test="*[contains(@class,'- map/topicmeta ')]/*[contains(@class, '- topic/navtitle ')]">
                <xsl:apply-templates
                        select="*[contains(@class,'- map/topicmeta ')]/*[contains(@class, '- topic/navtitle ')]"
                        mode="dita-ot:text-only"/>
            </xsl:when>
            <xsl:when
                    test="not(*[contains(@class,'- map/topicmeta ')]/*[contains(@class, '- topic/navtitle ')]) and @navtitle">
                <xsl:value-of select="@navtitle"/>
            </xsl:when>


            <!-- If there is no title and none can be retrieved, check for <linktext> -->
            <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
                <xsl:apply-templates
                        select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
                        mode="dita-ot:text-only"/>
            </xsl:when>

            <!-- No local title, and not targeting a DITA file. Could be just a container setting
               metadata, or a file reference with no title. Issue message for the second case. -->
            <xsl:otherwise>
                <xsl:if test="@href and not(@href='')">
                    <xsl:apply-templates select="." mode="ditamsg:could-not-retrieve-navtitle-using-fallback">
                        <xsl:with-param name="target" select="@href"/>
                        <xsl:with-param name="fallback" select="@href"/>
                    </xsl:apply-templates>
                    <xsl:value-of select="@href"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="getNavtitleFromTopic">
        <xsl:param name="WORKDIR"/>
        <xsl:param name="href" select="@href"/>
        <!-- Need to worry about targeting a nested topic? Not for now. -->
        <xsl:variable name="FileWithPath">
            <xsl:choose>
                <xsl:when test="@copy-to and not(contains(@chunk, 'to-content'))">
                    <xsl:value-of select="$WORKDIR"/>
                    <xsl:value-of select="@copy-to"/>
                    <xsl:if test="not(contains(@copy-to, '#')) and contains($href, '#')">
                        <xsl:value-of select="concat('#', substring-after($href, '#'))"/>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="contains($href,'#')">
                    <xsl:value-of select="$WORKDIR"/>
                    <xsl:value-of select="substring-before($href,'#')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$WORKDIR"/>
                    <xsl:value-of select="$href"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="TargetFile" select="document($FileWithPath,/)"/>

        <xsl:choose>
            <xsl:when test="not($TargetFile)">
                <!-- DITA file does not exist -->
                <xsl:choose>
                    <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
                        <!-- attempt to recover by using linktext -->
                        <xsl:apply-templates
                                select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
                                mode="dita-ot:text-only"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="." mode="ditamsg:missing-target-file-no-navtitle"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="$TargetFile/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
                <xsl:apply-templates
                        select="$TargetFile/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]"
                        mode="dita-ot:text-only"/>
            </xsl:when>
            <xsl:when test="$TargetFile/dita/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]">
                <xsl:apply-templates
                        select="$TargetFile/dita/*[contains(@class,' topic/topic ')]/*[contains(@class,' topic/title ')]"
                        mode="dita-ot:text-only"/>
            </xsl:when>
            <xsl:when test="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]">
                <xsl:apply-templates
                        select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' map/linktext ')]"
                        mode="dita-ot:text-only"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="ditamsg:could-not-retrieve-navtitle-using-fallback">
                    <xsl:with-param name="target" select="$FileWithPath"/>
                    <xsl:with-param name="fallback" select="'***'"/>
                </xsl:apply-templates>
                <xsl:text>***</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        <!-- concatenating the title and the shortdesc so that we don't have to go through the file again
            later to get the shortdesc-->
        <xsl:text>!#!</xsl:text>
        <xsl:value-of select="$TargetFile/*/shortdesc"/>
    </xsl:template>

    <!-- Link to user CSS. -->
    <!-- Test for URL: returns "url" when the content starts with a URL;
    Otherwise, leave blank -->
    <xsl:template name="url-string">
        <xsl:param name="urltext"/>
        <xsl:choose>
            <xsl:when test="contains($urltext,'http://')">url</xsl:when>
            <xsl:when test="contains($urltext,'https://')">url</xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- Can't link to commonltr.css or commonrtl.css because we don't know what language the map is in. -->
    <xsl:template name="generateCssLinks">
        <xsl:variable name="urltest">
            <xsl:call-template name="url-string">
                <xsl:with-param name="urltext">
                    <xsl:value-of select="concat($CSSPATH,$CSS)"/>
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="string-length($CSS)>0">
            <xsl:choose>
                <xsl:when test="$urltest='url'">
                    <link rel="stylesheet" type="text/css" href="{$CSSPATH}{$CSS}"/>
                </xsl:when>
                <xsl:otherwise>
                    <link rel="stylesheet" type="text/css" href="{$PATH2PROJ}{$CSSPATH}{$CSS}"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="$newline"/>
        </xsl:if>
        <link rel="stylesheet" href="style.css" type="text/css"/>
    </xsl:template>

    <!-- To be overridden by user shell. -->

    <xsl:template name="gen-user-head">
        <xsl:apply-templates select="." mode="gen-user-head"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-head">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- it will be placed in the HEAD section of the XHTML. -->
    </xsl:template>

    <xsl:template name="gen-user-header">
        <xsl:apply-templates select="." mode="gen-user-header"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-header">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- it will be placed in the running heading section of the XHTML. -->
    </xsl:template>

    <xsl:template name="gen-user-footer">
        <xsl:apply-templates select="." mode="gen-user-footer"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-footer">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- it will be placed in the running footing section of the XHTML. -->
    </xsl:template>

    <xsl:template name="gen-user-sidetoc">
        <xsl:apply-templates select="." mode="gen-user-sidetoc"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-sidetoc">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- Uncomment the line below to have a "freebie" table of contents on the top-right -->
    </xsl:template>

    <xsl:template name="gen-user-scripts">
        <xsl:apply-templates select="." mode="gen-user-scripts"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-scripts">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- It will be placed before the ending HEAD tag -->
        <!-- see (or enable) the named template "script-sample" for an example -->
    </xsl:template>

    <xsl:template name="gen-user-styles">
        <xsl:apply-templates select="." mode="gen-user-styles"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-styles">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- It will be placed before the ending HEAD tag -->
    </xsl:template>

    <xsl:template name="gen-user-external-link">
        <xsl:apply-templates select="." mode="gen-user-external-link"/>
    </xsl:template>
    <xsl:template match="/|node()|@*" mode="gen-user-external-link">
        <!-- to customize: copy this to your override transform, add the content you want. -->
        <!-- It will be placed after an external LINK or XREF -->
    </xsl:template>

    <!-- These are here just to prevent accidental fallthrough -->
    <xsl:template match="*[contains(@class, ' map/navref ')]"/>
    <xsl:template match="*[contains(@class, ' map/anchor ')]"/>
    <xsl:template match="*[contains(@class, ' map/reltable ')]"/>
    <xsl:template match="*[contains(@class, ' map/topicmeta ')]"/>
    <!--xsl:template match="*[contains(@class, ' map/topicref ') and contains(@class, '/topicgroup ')]"/-->

    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- Convert the input value to lowercase & return it -->
    <xsl:template name="convert-to-lower">
        <xsl:param name="inputval"/>
        <xsl:value-of
                select="translate($inputval,
                                  '-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',
                                  '-abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz')"
                />
    </xsl:template>

    <!-- Template to get the relative path to a map -->
    <xsl:template name="getRelativePath">
        <xsl:param name="remainingPath" select="@file"/>
        <xsl:choose>
            <xsl:when test="contains($remainingPath,'/')">
                <xsl:value-of select="substring-before($remainingPath,'/')"/>
                <xsl:text>/</xsl:text>
                <xsl:call-template name="getRelativePath">
                    <xsl:with-param name="remainingPath" select="substring-after($remainingPath,'/')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains($remainingPath,'\')">
                <xsl:value-of select="substring-before($remainingPath,'\')"/>
                <xsl:text>/</xsl:text>
                <xsl:call-template name="getRelativePath">
                    <xsl:with-param name="remainingPath" select="substring-after($remainingPath,'\')"/>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="*" mode="ditamsg:missing-target-file-no-navtitle">
        <xsl:call-template name="output-message">
            <xsl:with-param name="msgnum">008</xsl:with-param>
            <xsl:with-param name="msgsev">W</xsl:with-param>
            <xsl:with-param name="msgparams">%1=<xsl:value-of select="@href"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="*" mode="ditamsg:could-not-retrieve-navtitle-using-fallback">
        <xsl:param name="target"/>
        <xsl:param name="fallback"/>
        <xsl:call-template name="output-message">
            <xsl:with-param name="msgnum">009</xsl:with-param>
            <xsl:with-param name="msgsev">W</xsl:with-param>
            <xsl:with-param name="msgparams">%1=<xsl:value-of select="$target"/>;%2=<xsl:value-of
                    select="$fallback"/>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- SDL Template to retrieve certain metadata value from objects metadata file -->
    <xsl:template name="getMetadataValue">
        <xsl:param name="document" select="."/>
        <xsl:param name="fieldname"/>
        <xsl:param name="fieldlevel"/>
        <xsl:param name="default"/>
        <xsl:param name="WORKDIR"/>
        <xsl:choose>
            <xsl:when test="$document//ishfield[@name=$fieldname and @level=$fieldlevel]">
                <xsl:value-of select="$document//ishfield[@name=$fieldname and @level=$fieldlevel]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- SDL Template to retrieve object type from objects metadata file, <GUID>.met -->
    <xsl:template name="getObjectType">
        <xsl:param name="document" select="."/>
        <xsl:param name="default"/>
        <xsl:param name="WORKDIR"/>
        <xsl:variable name="ishtype">
            <xsl:choose>
                <xsl:when test="$document//@ishtype">
                    <xsl:value-of select="$document//@ishtype"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$ishtype='ISHModule'">
                <xsl:value-of select="'Topic'"/>
            </xsl:when>
            <xsl:when test="$ishtype='ISHMasterDoc'">
                <xsl:value-of select="'Map'"/>
            </xsl:when>
            <xsl:when test="$ishtype='ISHLibrary'">
                <xsl:value-of select="'Library'"/>
            </xsl:when>
            <xsl:when test="$ishtype='ISHIllustration'">
                <xsl:value-of select="'Illustration'"/>
            </xsl:when>
            <xsl:when test="$ishtype='ISHTemplate'">
                <xsl:value-of select="'Template'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- SDL Template to retrieve parameters from parameters file, ishjobticket.xml -->
    <xsl:template name="getJobTicketParam">
        <xsl:param name="varname"/>
        <xsl:param name="default"/>
        <xsl:choose>
            <xsl:when test="document($jobTicket,/)/job-specification/parameter[@name=$varname]">
                <xsl:value-of select="document($jobTicket,/)/job-specification/parameter[@name=$varname]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!-- ============================================================== -->
    <xsl:template name="getJobTicketAttrib">
        <xsl:param name="varname"/>
        <xsl:param name="default"/>
        <xsl:choose>
            <xsl:when test="document($jobTicket)/job-specification/@*[name()=$varname]">
                <xsl:value-of select="document($jobTicket)/job-specification/@*[name()=$varname]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$default"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
