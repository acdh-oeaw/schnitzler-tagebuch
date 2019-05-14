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
    <xsl:param name="quotationURL"/>
    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:title[@type='main']/text()"/>
    </xsl:variable>
    <xsl:variable name="currentDate">
        <xsl:value-of select="format-date(current-date(), '[Y]-[M]-[D]')"/>
    </xsl:variable>
    <xsl:variable name="pid">
        <xsl:value-of select="//tei:publicationStmt//tei:idno[@type='URI']/text()"/>
    </xsl:variable>
    
    <xsl:variable name="quotationString">
        <xsl:value-of select="concat('Arthur Schnitzler: Tagebuch. Digitale Edition, ', $doctitle, ', ', $quotationURL, ' (Stand ', $currentDate, ') PID: ', $pid)"/>
    </xsl:variable>
    <!--
##################################
### Seitenlayout und -struktur ###
##################################
-->
    <xsl:template match="/">
        <div class="container">
            <div class="card">
                <div class="card-header">
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
                    <xsl:apply-templates select="//tei:body"/>
                </div>
                <div class="card-footer text-muted" style="text-align:center">
                    <div id="srcbuttons">
                        <div class="res-act-button res-act-button-copy-url" id="res-act-button-copy-url" data-copyuri="{$quotationString}">
                            <span id="copy-url-button">
                                <i class="fas fa-quote-right"/> ZITIEREN
                                <!-- {{ "Copy Resource Link"|trans }}-->
                            </span>
                            <span id="copyLinkTextfield-wrapper">
                                <span type="text" name="copyLinkInputBtn" id="copyLinkInputBtn" data-copyuri="{$quotationString}">
                                    <i class="far fa-copy"/>
                                </span>
                                 <textarea rows="3" name="copyLinkTextfield" id="copyLinkTextfield" value="">
                                <xsl:value-of select="$quotationString"/>
                                </textarea>
                            </span>
                        </div>
                        <a class="ml-3">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$path2source"/>
                            </xsl:attribute>
                            <i class="fa-lg far fa-file-code"/>TEI
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>