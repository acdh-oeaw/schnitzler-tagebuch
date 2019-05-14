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
    <xsl:param name="quotationURL"/>


    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:title[@type='main']/text()"/>
    </xsl:variable>

    <xsl:variable name="source_volume">
        <xsl:value-of select="replace(//tei:monogr//tei:biblScope[@unit='volume']/text(), '-', '_')"/>
    </xsl:variable>
    <xsl:variable name="source_base_url">https://austriaca.at/buecher/files/arthur_schnitzler_tagebuch/Tagebuch1879-1931Einzelseiten/schnitzler_tb_</xsl:variable>
    <xsl:variable name="source_page_nr">
        <xsl:value-of select="format-number(//tei:monogr//tei:biblScope[@unit='page']/text(), '000')"/>
    </xsl:variable>
    <xsl:variable name="source_pdf">
        <xsl:value-of select="concat($source_base_url, $source_volume, 's', $source_page_nr, '.pdf')"/>
    </xsl:variable>
    <xsl:variable name="current-date">
        <xsl:value-of select="substring-after($doctitle, ': ')"/>
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
                                <xsl:value-of select="//tei:title[@type='main']/text()"/>
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
                    <div id="srcbuttons">
                        <div class="res-act-button res-act-button-copy-url" id="res-act-button-copy-url" data-copyuri="{$quotationURL}">
                            <span id="copy-url-button">
                               <i class="fas fa-quote-right"/> ZITIEREN
                               <!-- {{ "Copy Resource Link"|trans }}-->
                            </span>
                            <span id="copyLinkTextfield-wrapper">
                                <span type="text" name="copyLinkInputBtn" id="copyLinkInputBtn" data-copyuri="{$quotationURL}">
                                    <i class="far fa-copy"/>
                                </span>
                                <input type="text" name="copyLinkTextfield" id="copyLinkTextfield" value="{$quotationURL}"/>
                            </span>
                        </div>
                        <a class="ml-3">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$path2source"/>
                            </xsl:attribute>
                            <i class="fa-lg far fa-file-code"/>TEI
                        </a>
                        <a class="ml-3">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$source_pdf"/>
                            </xsl:attribute>
                            <!--<i class="fa-lg far fa-file-pdf"/> 
                            PDF-->
                        </a>
                    </div>
                    <h6 style="text-align:center;">
                        <input type="range" min="1" max="{$amount}" value="{$currentIx}" data-rangeslider="" style="width:100%;"/>
                        <a id="output" class="btn btn-main btn-outline-success btn-sm" href="show.html?document=entry__1879-03-03.xml&amp;directory=editions" role="button">gehe zu</a>
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
<!--  don't process any tei:pb, tei:fw information  -->
    <xsl:template match="tei:pb"/>
    <xsl:template match="tei:fw"/>

    <xsl:template match="tei:rs[@ref or @key]">
        <xsl:choose>
            <xsl:when test="ends-with(data(./@ref), '_')">
                    <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="starts-with(data(./@ref), '#genID__bibl')">
                <span class="unlinked-entity-bibl">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
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
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
</xsl:stylesheet>