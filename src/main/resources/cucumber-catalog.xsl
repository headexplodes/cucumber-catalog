<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:template match="/">
        <html>
            <head>
                <title>Cucumber Step Catalog</title>
                <style>

                </style>
            </head>
            <body>
                <h1>Cucumber Step Catalog</h1>
                
                <h2>Packages</h2>
                <ul>
                    <xsl:apply-templates select="package" mode="index"/>
                </ul>
                
                <xsl:apply-templates />
            </body>
        </html>
    </xsl:template>
    
    <!-- 
    <xsl:template match="//package" mode="index">
        <li><a href="#"><xsl:value-of select="name" /></a></li>
    </xsl:template>
    -->

    <xsl:template match="//package">
        <h2><xsl:value-of select="name" /></h2>
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="//class">
        <h3><xsl:value-of select="name" /></h3>
        <xsl:apply-templates />
    </xsl:template>
    
    <xsl:template match="//step">
        <p><b><xsl:value-of select="pattern" /></b></p>
        <p><i><xsl:value-of select="file" />:<xsl:value-of select="lineStart" /></i></p>
        <xsl:apply-templates select="description"/>
    </xsl:template>
    
    <xsl:template match="//description">
        <div style="background-color: #eee">
            <xsl:value-of select="text()" disable-output-escaping="yes"/>
        </div>
    </xsl:template>
    
    <!-- 
    <xsl:template match="*">
        #ERROR
    </xsl:template>
    -->
    
</xsl:stylesheet>