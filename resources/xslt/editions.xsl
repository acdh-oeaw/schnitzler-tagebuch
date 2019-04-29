<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="tei" version="2.0"><!-- <xsl:strip-space elements="*"/>-->
    <xsl:import href="shared/base.xsl"/>
    <xsl:param name="document"/>
    <xsl:param name="app-name"/>
    <xsl:param name="collection-name"/>
    <xsl:param name="path2source"/>
    <xsl:param name="ref"/>
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="currentIx"/>
    <xsl:param name="amount"/>
    <xsl:param name="progress"/>
    <xsl:function name="functx:day-of-week" as="xs:integer?">
        <xsl:param name="date" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="             if (empty($date))             then ()             else xs:integer((xs:date($date) - xs:date('1901-01-06'))             div xs:dayTimeDuration('P1D')) mod 7             "/>
        
    </xsl:function>
    <xsl:function name="functx:written-date">
        <xsl:param name="date" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="             if ($date = 0) then ('Sonntag')             else if ($date = 1)then ('Montag')             else if ($date = 2)then ('Dienstag')             else if ($date = 3)then ('Mittwoch')             else if ($date = 4)then ('Donnerstag')             else if ($date = 5)then ('Freitag')             else ('Samstag')             "/>
        
    </xsl:function>
    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:title[@type='main']/text()"/>
    </xsl:variable>
        
    <xsl:variable name="source_volume">
        <xsl:value-of select="replace(//tei:monogr//tei:biblScope[@unit='volume']/text(), '-', '_')"/>
    </xsl:variable>
    <xsl:variable name="source_base_url">https://austriaca.at/buecher/files/arthur_schnitzler_tagebuch/Tagebuch1879-1931Einzelseiten/schnitzler_tb_</xsl:variable>
    <xsl:variable name="source_page_nr">
        <xsl:value-of select="format-number(data(//tei:pb/@n), '000')"/>
    </xsl:variable>
    <xsl:variable name="source_pdf">
        <xsl:value-of select="concat($source_base_url, $source_volume, 's', $source_page_nr, '.pdf')"/>
    </xsl:variable>
    <xsl:variable name="current-date">
        <xsl:value-of select="substring-after($doctitle, ': ')"/>
    </xsl:variable>
    <xsl:variable name="current-year">
        <xsl:value-of select="tokenize($current-date, '-')[1]"/>
    </xsl:variable>
    <xsl:variable name="current-month">
        <xsl:value-of select="tokenize($current-date, '-')[2]"/>
    </xsl:variable>
    <xsl:variable name="current-day">
        <xsl:value-of select="tokenize($current-date, '-')[3]"/>
    </xsl:variable>
    
    <xsl:variable name="current-day-nr">
        <xsl:value-of select="functx:day-of-week(             xs:date($current-date))"/>
    </xsl:variable>
    
    <xsl:variable name="german-date">
        <xsl:value-of select="concat(functx:written-date($current-day-nr), ', ', format-number($current-day, '0'),'. ', $current-month, '. ', $current-year)"/>
    </xsl:variable>
    
    
 <!--
##################################
### Seitenlayout und -struktur ###
##################################
-->
    <xsl:template match="/">
        <div class="container">
            <div class="card">
                <div class="card-header" onload="initSlider()">
                    <div class="row" style="text-align:left">
                        <div class="col-md-2">
                            <xsl:if test="$prev">
                                <h1>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$prev"/>
                                        </xsl:attribute>
                                        <i class="fas fa-chevron-left" title="prev"/>
                                    </a>
                                </h1>
                            </xsl:if>
                        </div>
                        <div class="col-md-8" align="center">
                            <h1>
                                <xsl:value-of select="$german-date"/>
                            </h1>
                            
                        </div>
                        <div class="col-md-2" style="text-align:right">
                            <xsl:if test="$next">
                                <h1>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$next"/>
                                        </xsl:attribute>
                                        <i class="fas fa-chevron-right" title="next"/>
                                    </a>
                                </h1>
                            </xsl:if>
                        </div>
                    </div>
                    
                </div>
                <div class="card-body">
                    <xsl:apply-templates select="//tei:div[@type='diary-day']"/>
                </div>
                <div class="card-footer text-muted" style="text-align:center">
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$path2source"/>
                        </xsl:attribute>
                        TEI 
                    </a>
                    | Zitierung
                    | <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$source_pdf"/>
                        </xsl:attribute>
                       see source pdf
                    </a>
                    <h6 style="text-align:center;">
                        <input type="range" min="1" max="{$amount}" value="{$currentIx}" data-rangeslider="" style="width:100%;"/>
                        <a id="output" class="btn btn-main btn-outline-primary btn-sm" href="show.html?document=entry__1879-03-03.xml&amp;directory=editions" role="button">gehe zu</a>
                    </h6>
                </div>
            </div>
        </div>
        <style>
            .rangeslider__fill {
            background: #efd861;
            position: absolute;
            }
        </style>
        
    </xsl:template>
    
    <xsl:template match="tei:rs[@ref or @key]">
        <xsl:choose>
            <xsl:when test="ends-with(data(./@ref), '_')">
                <span class="unlinked-entity">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <strong>
                    <xsl:element name="a">
                        <xsl:attribute name="class">reference</xsl:attribute>
                        <xsl:attribute name="data-type">
                            <xsl:value-of select="concat('list', data(@type), '.xml')"/>
                        </xsl:attribute>
                        <xsl:attribute name="data-key">
                            <xsl:value-of select="substring-after(data(@ref), '#')"/>
                            <xsl:value-of select="@key"/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                    </xsl:element>
                </strong>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
</xsl:stylesheet>