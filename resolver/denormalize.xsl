<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="index"/>
    <xsl:variable name="indices" select="document($index)"/>
    
       
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
   
    
    <xsl:template match="tei:back">
        <back xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="$indices//tei:person">
                <listPerson>
                    <xsl:for-each select="$indices//tei:person">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </listPerson>
            </xsl:if>
            <xsl:if test="$indices//tei:place">
                <listPlace>
                    <xsl:for-each select="$indices//tei:place">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </listPlace>
            </xsl:if>
            <xsl:if test="$indices//tei:org">
                <listOrg>
                    <xsl:for-each select="$indices//tei:org">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </listOrg>
            </xsl:if>
            <xsl:apply-templates select="tei:listBibl"/>
        </back>
     </xsl:template>
     
     <xsl:template match="tei:listBibl">
         <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
     </xsl:template>
</xsl:stylesheet>