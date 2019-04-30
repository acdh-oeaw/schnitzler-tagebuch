<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="tei" version="2.0">
    <xsl:import href="shared/base_index.xsl"/>
    <xsl:param name="entiyID"/>
    <xsl:variable name="entity" as="node()">
        <xsl:choose>
            <xsl:when test="//tei:person[@xml:id=$entiyID][1]">
                <xsl:value-of select="//tei:person[@xml:id=$entiyID][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="checker" as="text()">
        <xsl:choose>
            <xsl:when test="//tei:person[@xml:id=$entiyID][1]">
                <xsl:value-of select="'yes'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'no'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/">       
        <div class="modal" tabindex="-1" role="dialog" id="myModal">
            <div class="modal-dialog">
                <div class="modal-content">
                    <xsl:choose>
                        <xsl:when test="$checker = 'yes'">
                            <div class="modal-header">
                                <xsl:variable name="entity" select="//tei:person[@xml:id=$entiyID]"/>
                                <h3 class="modal-title">
                                    <xsl:choose>
                                        <xsl:when test="//$entity//tei:surname[1]/text()">
                                            <xsl:value-of select="$entity//tei:surname[1]/text()"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$entity//tei:persName[1]"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
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
                                    <xsl:variable name="entity" select="//tei:person[@xml:id=$entiyID]"/>
                                    <xsl:for-each select="$entity//tei:persName">
                                        <tr>
                                            <th>
                                                Name
                                            </th>
                                            <td>
                                                <xsl:choose>
                                                    <xsl:when test="./tei:forename and ./tei:surname">
                                                        <xsl:value-of select="concat(./tei:forename, ' ', ./tei:surname)"/>
                                                    </xsl:when>
                                                    <xsl:when test="./tei:forename or ./tei:surname">
                                                        <xsl:value-of select="./tei:forename"/>
                                                        <xsl:value-of select="./tei:surname"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        keine Angaben zu Namen vorhanden
                                                    </xsl:otherwise>
                                                </xsl:choose>                                                
                                            </td>
                                        </tr>
                                        <xsl:choose>
                                            <xsl:when test="$entity//tei:occupation/text()">
                                                <tr>
                                                    <th>
                                                        Beruf(e)
                                                    </th>
                                                    <td>
                                                        <xsl:for-each select="$entity//tei:occupation">
                                                            <li>
                                                                <xsl:value-of select="./text()"/>
                                                            </li>
                                                        </xsl:for-each>
                                                    </td>
                                                </tr>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:choose>
                                            <xsl:when test="$entity//tei:birth">
                                                <tr>
                                                    <th>
                                                        geboren am
                                                    </th>
                                                    <td>
                                                       <xsl:value-of select="$entity//tei:birth/tei:date/text()"/>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>
                                                        geboren in
                                                    </th>
                                                    <td>
                                                        <xsl:value-of select="$entity//tei:birth/tei:placeName/text()"/>
                                                    </td>
                                                </tr>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    <xsl:choose>
                                        <xsl:when test="$entity//tei:death">
                                            <tr>
                                                <th>
                                                    gestorben am
                                                </th>
                                                <td>
                                                    <xsl:value-of select="$entity//tei:death/tei:date/text()"/>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>
                                                    gestorben in
                                                </th>
                                                <td>
                                                    <xsl:value-of select="$entity//tei:death/tei:placeName/text()"/>
                                                </td>
                                            </tr>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$entity//tei:idno[@type='GND']">
                                            <tr>
                                                <th>
                                                    GND-ID
                                                </th>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="$entity//tei:idno[@type='GND']/text()"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select="$entity//tei:idno[@type='GND']/text()"/>
                                                    </a>
                                                </td>
                                            </tr>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$entity//@xml:id">
                                            <tr>
                                                <th>
                                                    Interne-ID
                                                </th>
                                                <td>
                                                    <xsl:value-of select="data($entity/@xml:id)"/>
                                                </td>
                                            </tr>
                                        </xsl:when>
                                    </xsl:choose>
                                    <xsl:choose>
                                        <xsl:when test="$entity//@xml:id">
                                            <tr>
                                                <th>
                                                    PMB
                                                </th>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="concat('https://pmb.acdh.oeaw.ac.at/apis/id?=', data($entity/@xml:id))"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select="concat('https://pmb.acdh.oeaw.ac.at/apis/id?=', data($entity/@xml:id))"/>
                                                    </a>
                                                </td>
                                            </tr>
                                        </xsl:when>
                                    </xsl:choose>
                                </table>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="modal-header">
                                <button type="button" class="close" data-dismiss="modal">
                                    <span class="fa fa-times"/>
                                </button>
                                <p class="modal-title">
                                    Für die übergebene ID <strong>
                                        <xsl:value-of select="$entiyID"/>
                                    </strong> konnte kein Registereintrag gefunden werden.  
                                </p>
                                
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-default" data-dismiss="modal">Schließen</button>
                    </div>
                </div>
            </div>
        </div>
        <script type="text/javascript">
            $(window).load(function(){
            $('#myModal').modal('show');
            });
        </script>
    </xsl:template>
</xsl:stylesheet>