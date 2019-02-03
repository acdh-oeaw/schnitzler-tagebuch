<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0"><!-- <xsl:strip-space elements="*"/>-->
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
    
    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:title[@type='main']/text()"/>
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
                                <xsl:value-of select="substring-after($doctitle, ': ')"/>
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
                    <h6 style="text-align:center;">
                        <input type="range" min="1" max="{$amount}" value="{$currentIx}" data-rangeslider="" style="width:100%;"/>
                        <a id="output" class="btn btn-main btn-outline-primary btn-sm" href="show.html?document=entry__1879-03-03.xml&amp;directory=editions" role="button">go to </a>
                    </h6>
                </div>
            </div>
        </div>
        <style>
            .rangeslider__fill {
            background: #87A0BA;
            position: absolute;
            }
        </style>
        <script>
            $(function() {
                var $document = $(document);
                var selector = '[data-rangeslider]';
                var $element = $(selector);
                // Example functionality to demonstrate a value feedback

                $element.rangeslider({
                
                // Deactivate the feature detection
                polyfill: false,
                
                // Callback function
                onInit: function() {
                    $('#output').hide()
                },
                
                // Callback function
                onSlideEnd: function(position, value) {
                
                    $.get( "../analyze/docname-by-index.xql?index="+ value, function( data ) {
                        var linkToDoc = data.replace('"', '');
                        console.log(linkToDoc)
                        var out = $('#output'); 
                        out.text( "go to entry: "+ value );
                        out.attr("href", linkToDoc.replace('"', ''));
                        out.show()
                    });
                    
                }
                });
            });
        </script>
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