<?xml version='1.0'?>


 

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:param name="ditaroot"/>


<xsl:output method="xml" indent="yes" doctype-public="-//OASIS//DTD DITA BookMap//EN" doctype-system="http://docs.oasis-open.org/dita/v1.2/os/dtd1.2/bookmap/dtd/bookmap.dtd"  />
	





  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>




    <xsl:template match="bookmap">

        <bookmap chunk="to-content by-document">
            <xsl:apply-templates select="@*|node()"/>
        </bookmap>
   
    
  </xsl:template>
  
  
 


</xsl:stylesheet>
    
    
