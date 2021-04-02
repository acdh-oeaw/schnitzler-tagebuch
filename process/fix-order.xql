<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs tei" version="2.0">
    <xsl:output omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="vOrdered" select="'|listEvent|idno|'"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:idno">
        <xsl:choose>
            <xsl:when test="contains(./text(), 'geonames')">
                <idno xmlns="http://www.tei-c.org/ns/1.0" type="URL" subtype="geonames"><xsl:value-of select="replace(./text(), 'http:', 'https:')"/></idno>
            </xsl:when>
            <xsl:otherwise>
                <idno xmlns="http://www.tei-c.org/ns/1.0" type="URL" subtype="GND"><xsl:value-of select="replace(./text(), 'http:', 'https:')"/></idno>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="tei:place">
        <xsl:copy>
            <xsl:apply-templates select="*|@*">
                <xsl:sort select="substring-before($vOrdered, concat('|',name(),'|'))"/>
            </xsl:apply-templates>
        </xsl:copy>        
    </xsl:template>  
</xsl:stylesheet>