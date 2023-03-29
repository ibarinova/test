<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <!-- EMC 	20-Oct-2014		Process syntaxdiagram to match WebWorks behavior -->
    <xsl:template match="*[contains(@class,' pr-d/syntaxdiagram ')]" priority="5">
        <div style="display: block; padding: 2pt; margin-bottom: 6pt;">
            <xsl:apply-templates mode="process-syntaxdiagram"/>
        </div>
    </xsl:template>
</xsl:stylesheet>