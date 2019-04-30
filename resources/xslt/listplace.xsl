<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:import href="shared/base_index.xsl"/>
    <xsl:param name="entiyID"/>
    <xsl:variable name="apis-resolver">https://pmb.acdh.oeaw.ac.at/apis/api2/uri?uri=https://schnitzler-tagebuch.acdh.oeaw.ac.at/</xsl:variable>
    <xsl:variable name="entity" as="node()">
        <xsl:choose>
            <xsl:when test="not(empty(//tei:place[@xml:id=$entiyID][1]))">
                <xsl:value-of select="//tei:place[@xml:id=$entiyID][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:if test="$entity">
            <div class="modal" tabindex="-1" role="dialog" id="myModal">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <xsl:choose>
                            <xsl:when test="$entity">
                                <xsl:variable name="entity" select="//tei:place[@xml:id=$entiyID]"/>
                                <div class="modal-header">
                                    
                                    <h3 class="modal-title">
                                        <xsl:value-of select="$entity/tei:placeName[1]"/>
                                        <br/>
                                        <small>
                                            <a>
                                                <xsl:attribute name="href">
                                                    <xsl:value-of select="concat('hits.html?searchkey=', $entiyID)"/>
                                                </xsl:attribute>
                                                <xsl:attribute name="target">_blank</xsl:attribute>
                                                weitere Erwähnungen
                                            </a>
                                        </small>
                                    </h3>
                                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                        <span aria-hidden="true">x</span>
                                    </button>
                                </div>
                                <div class="modal-body">
                                    <table class="table table-boardered table-hover">
                                        <tr>
                                            <th>Name</th>
                                            <td>
                                                <xsl:value-of select="//tei:place[@xml:id=$entiyID]/tei:placeName[1]"/>
                                            </td>
                                        </tr>
                                        
                                        <xsl:if test="count($entity//tei:placeName) &gt; 1">
                                            <xsl:for-each select="$entity//tei:placeName[position()&gt;1]">
                                                <tr>
                                                    <th>Alternative Namen</th>
                                                    <td>
                                                        <xsl:value-of select="."/>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:if>
                                        <xsl:choose>
                                            <xsl:when test="$entity//tei:geo">
                                                <tr>
                                                    <th>
                                                        Koordinaten
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="$entity//tei:geo/text()"/>
                                                    </td>
                                                </tr>
                                            </xsl:when>
                                        </xsl:choose>
                                        
                                        <xsl:choose>
                                            <xsl:when test="$entity//tei:idno[@type='geonames']">
                                                <tr>
                                                    <th>
                                                        GND-ID
                                                    </th>
                                                    <td>
                                                        <a>
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="$entity//tei:idno[@type='geonames']/text()"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="$entity//tei:idno[@type='geonames']/text()"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:if test="$entity/@xml:id">
                                            <tr>
                                                <th>Interne-ID:</th>
                                                <td>
                                                    <xsl:value-of select="$entity/@xml:id"/>
                                                </td>
                                            </tr>
                                        </xsl:if>
                                        <xsl:choose>
                                            <xsl:when test="$entity//@xml:id">
                                                <tr>
                                                    <th>
                                                        PMB
                                                    </th>
                                                    <td>
                                                        <a>
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="concat($apis-resolver, data($entity/@xml:id))"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="concat($apis-resolver, data($entity/@xml:id))"/>
                                                        </a>
                                                    </td>
                                                </tr>
                                            </xsl:when>
                                        </xsl:choose>
                                    </table>
                                    <p>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="concat('../resolver/resolve-id.xql?id=', $entiyID)"/>
                                            </xsl:attribute>
                                            TEI
                                        </a>
                                    </p>
                                </div>
                            </xsl:when>
                        </xsl:choose>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-default" data-dismiss="modal">Schließen</button>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:if>
        <script type="text/javascript">
            $(window).load(function(){
            $('#myModal').modal('show');
            });
        </script>
    </xsl:template>
</xsl:stylesheet>