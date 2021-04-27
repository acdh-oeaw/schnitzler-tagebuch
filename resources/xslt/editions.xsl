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
<xsl:param name="facsIds"/>
<xsl:param name="facsArcheIds"/>
<xsl:param name="show-register"/>

<xsl:variable name="entryDate">
  <xsl:value-of select="xs:date(//tei:title[@type='iso-date']/text())"/>
</xsl:variable>
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

                    <xsl:if test="$facsArcheIds">
                        <a class="ml-3" title="Faksimile zu diesem Eintrag" data-toggle="modal" data-target="#exampleModal">
                            <i class="fa-lg far fa-file-image"/> Faksimile
                        </a>
                    </xsl:if>
                    <a class="ml-3" data-toggle="tooltip" title="Link zum PDF der Buchvorlage zu diesem Eintrag">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$source_pdf"/>
                        </xsl:attribute>
                        <i class="fa-lg far fa-file-pdf"/> PDF
                    </a>
                    <a class="ml-3" data-toggle="tooltip" title="Link zur TEI-Datei">
                        <xsl:attribute name="href">
                            <xsl:value-of select="$path2source"/>
                        </xsl:attribute>
                        <i class="fa-lg far fa-file-code"/> TEI 
                    </a>
                    <xsl:if test="//tei:back/*">
                        <a class="ml-3" data-toggle="tooltip" title="Eintrag als Netzwerk-Graph visualisiert">
                            <xsl:attribute name="href">
                                <xsl:value-of select="concat('../netvis/netvis.html?type=Tagebucheintrag&amp;id=', $document)"/>
                            </xsl:attribute>
                            <i class="fas fa-project-diagram"/> Netzwerk
                        </a>
                    </xsl:if>
                    <xsl:choose>
                        <xsl:when test="$show-register">
                            <a class="ml-3" data-toggle="tooltip" title="Verstecke Register">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat('show.html?directory=editions&amp;document=', $document)"/>
                                </xsl:attribute>
                                <i class="fas fa-map-marked-alt"></i> Verstecke Register
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <a class="ml-3" data-toggle="tooltip" title="Zeige Register">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat('show.html?directory=editions&amp;document=', $document, '&amp;show-register=true')"/>
                                </xsl:attribute>
                                <i class="fas fa-map-marked-alt"></i> Zeige Register
                            </a>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:variable name="datum" select="descendant::tei:titleStmt/tei:title[@type = 'iso-date']"/>
                    <span class="nav-link">
                                    <div id="csLink" data-correspondent-1-name="Arthur Schnitzler" data-correspondent-1-id="http%3A%2F%2Fd-nb.info%2Fgnd%2F118609807" data-correspondent-2-name="" data-correspondent-2-id="" data-start-date="{$datum}" data-end-date="" data-range="50" data-selection-when="before-after" data-selection-span="median-before-after" data-result-max="4" data-exclude-edition=""/>
                                </span>
                </div>
                <h6 style="text-align:center;">
                    <input type="range" min="1" max="{$amount}" value="{$currentIx}" data-rangeslider="" style="width:100%;"/>
                    <a id="output" class="btn btn-main btn-outline-success btn-sm" href="show.html?document=entry__1879-03-03.xml&amp;directory=editions" role="button">gehe zu</a>
                </h6>
                <xsl:if test="$show-register">
                    <nav>
                        <div class="nav nav-tabs" id="nav-tab" role="tablist">
                            <a class="nav-item nav-link active" id="nav-home-tab" data-toggle="tab" href="#nav-home" role="tab" aria-controls="nav-home" aria-selected="true">Orte</a>
                            <a class="nav-item nav-link" id="nav-profile-tab" data-toggle="tab" href="#nav-profile" role="tab" aria-controls="nav-profile" aria-selected="false">Personen</a>
                            <a class="nav-item nav-link" id="nav-contact-tab" data-toggle="tab" href="#nav-contact" role="tab" aria-controls="nav-contact" aria-selected="false">Werke</a>
                        </div>
                    </nav>
                    <div class="tab-content" id="nav-tabContent">
                        <div class="tab-pane fade show active" id="nav-home" role="tabpanel" aria-labelledby="nav-home-tab">
                            <legend>Orte</legend>
                            <div class="row">
                                <div class="col-md-4">
                                    <ul>
                                        <xsl:for-each select=".//tei:listPlace/tei:place">
                                            <li><xsl:value-of select="./tei:placeName/text()"/></li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                                <div id="mapid" style="height: 400px;" class="col-md-8"/>
                            </div>
                            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A==" crossorigin=""/>
                            <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js" integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA==" crossorigin=""/>
                            <script>
                                
                                var mymap = L.map('mapid').setView([51.505, -0.09], 6);
                                
                                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                attribution: 'Map data &amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
                                maxZoom: 18,
                                zIndex: 1
                                }).addTo(mymap);
                                <xsl:for-each select=".//tei:listPlace/tei:place">
                                    L.marker([<xsl:value-of select="substring-before(.//tei:geo/text()[1], ' ')"/>, <xsl:value-of select="substring-after(.//tei:geo/text(), ' ')"/>]).addTo(mymap)
                                    .bindPopup("<b><xsl:value-of select="./tei:placeName/text()"/></b>").openPopup();
                                </xsl:for-each>
                            </script>
                            
                        </div>
                        <div class="tab-pane fade" id="nav-profile" role="tabpanel" aria-labelledby="nav-profile-tab">
                            <legend>Personen</legend>
                            <ul>
                                <xsl:for-each select=".//tei:listPerson//tei:person">
                                    <li><xsl:value-of select="./tei:persName"/></li>
                                </xsl:for-each>
                            </ul>
                        </div>
                        <div class="tab-pane fade" id="nav-contact" role="tabpanel" aria-labelledby="nav-contact-tab">
                            <legend>Werke</legend>
                            <ul>
                                <xsl:for-each select=".//tei:listBibl//tei:bibl">
                                    <li><xsl:value-of select="./tei:title"/></li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </div>
                </xsl:if>
            </div>

            <!-- Modal -->
            <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                <div class="modal-dialog modal-lg" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h3>Faksimile</h3>
                        </div>
                        <div class="modal-body">
                            <div id="openseadragon-photo" style="height: 350px;"/>
                            <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/openseadragon.min.js"/>
                            <script type="text/javascript">
                                var viewer = OpenSeadragon({
                                id: "openseadragon-photo",
                                protocol: "http://iiif.io/api/image",
                                prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/",
                                sequenceMode : true,
                                showReferenceStrip: true,
                                tileSources: [<xsl:value-of select="$facsIds"/>]
                                });
                            </script>
                        </div>
                        <div class="modal-footer" style="justify-content: flex-start;">
                            <ul style="list-style-type: none;">
                                <xsl:for-each select="tokenize($facsArcheIds, ' ')">
                                        <li>
                                            <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="concat(., '?format=gui')"/>
                                            </xsl:attribute>
                                            <xsl:value-of select="."/>
                                        </a>
                                        </li>
                                </xsl:for-each>
                            </ul>
                        </div>
                    </div>
                </div>
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
<xsl:template match="tei:bibl">
    <xsl:apply-templates/>
</xsl:template>

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
                <xsl:apply-templates/>
            </xsl:element>
        </xsl:otherwise>
    </xsl:choose>

</xsl:template>
</xsl:stylesheet>