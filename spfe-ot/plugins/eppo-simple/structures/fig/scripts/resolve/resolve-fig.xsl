<?xml version="1.0" encoding="UTF-8"?>
<!-- This file is part of the SPFE Open Toolkit. See the accompanying license.txt file for applicable licenses.-->
<!-- (c) Copyright Analecta Communications Inc. 2014 All Rights Reserved. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:sf="http://spfeopentoolkit.org/spfe-ot/1.0/functions"
    xmlns:config="http://spfeopentoolkit/ns/spfe-ot/config"
    xmlns:es="http://spfeopentoolkit.org/ns/eppo-simple"
    xmlns="http://spfeopentoolkit.org/ns/eppo-simple"
    xpath-default-namespace="http://spfeopentoolkit.org/ns/eppo-simple"
    exclude-result-prefixes="#all" version="2.0">

    <!-- Make sure that the fig href is an absolute URI so that we know where to copy it from -->
    <xsl:template match="fig">
        <es:fig>
            <xsl:if test="@id">
                <xsl:attribute name="id" select="concat(fig, ':', @id)"/>
            </xsl:if>
            <xsl:apply-templates/>
        </es:fig>
     </xsl:template>
    
    <xsl:template match="fig/caption | fig/title">
        <xsl:element name="es:{local-name()}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    

</xsl:stylesheet>
