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
                                <xsl:value-of select="//tei:title[@type='main']"/>         
                            </h1>
                            <h6>
                                <span class="badge badge-secondary">
                                    <xsl:value-of select="$currentIx"/> / <xsl:value-of select="$amount"/>
                                </span>
                            </h6>
                            <h5>
                                <muted>
                                    <xsl:value-of select="//tei:title[@type='sub']"/>
                                </muted>
                            </h5>
                           
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
                    <h2 style="text-align:center;">
                        <input type="range" min="1" max="{$amount}" value="{$currentIx}" data-rangeslider="" style="width:100%;"/>
                        <a id="output" class="btn btn-main btn-outline-primary btn-sm" href="show.html?document=entry__1879-03-03.xml&amp;directory=editions" role="button">go to </a>
                    </h2>
                </div>
                <div class="card-body">
                    <xsl:apply-templates select="//tei:div[@type='diary-day']"/>
                </div>
                <div class="card-footer text-muted" style="text-align:center">
                    ACDH-OeAW,
                    <i>
                        <xsl:value-of select="//tei:title[@type='sub']"/> - 
                        <xsl:value-of select="//tei:title[@type='main']"/>
                    </i>
                    <br/>
                    <a>
                        <xsl:attribute name="href">
                            <xsl:value-of select="$path2source"/>
                        </xsl:attribute>
                        see the TEI source of this document
                    </a>
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
</xsl:stylesheet>