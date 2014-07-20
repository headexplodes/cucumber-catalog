<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output
         method="html"
         encoding="UTF-8"
         indent="yes" />

    <xsl:template match="/catalog">
        <html>
            <head>
                <title>Cucumber Step Catalog</title>
                <style>

                    /* cream: #fcf6c8; */

                    html, body, h1, h2 {
                        padding: 0;
                        margin: 0;
                    }
                    
                    a, a:visited {
                        color: #164b2b;
                    }
                    
                    span.prefix {
                        font-weight: normal;
                        font-size: 66%;
                        margin-right: 1em;
                    }
                    
                    span.suffix {
                        font-weight: normal;
                    }
                    
                    h2.package-name {
                        color: white;
                        background-color: #164b2b;
                        font-size: 14pt;
                        font-weight: bold;
                        padding: 5px 10px;
                        margin-top: 1em;
                    }
                    
                    h3.class-name {
                        color: #164b2b;
                        font-size: 14pt;
                        font-weight: bold;
                        padding: 5px 0px;
                    }
                    
                    #index {
                        position: fixed;
                        left: 0;
                        top: 0;
                        width: 400;
                        background-color: #c5d88a;
                        min-height: 100%;
                        padding: 10px;
                    }
                    
                    #index ul {
                        margin-bottom: 1em;
                    }
                    
                    #content {
                        margin-left: 420;
                        padding: 0 10px;
                    }
                    
                    span.annotation {
                        margin-right: .3em;
                        background-color: #c5d88a;
                        font-weight: bold;
                        border-radius: 3px;
                        padding: 2px 3px;
                        color: #164b2b;
                    }   
                    
                    .step-name {
                        font-weight: bold;
                    }
                    
                    .filename {
                        font-family: monospace;
                    }

                    .javadoc {
                        white-space: pre-wrap;
                    }
                    
                    .javadoc pre, .javadoc code {
                        background-color: #eee;
                    }

                </style>
            </head>
            <body>
                <div id="index">
                    <h1>Cucumber Step Catalog</h1>
                    
                    <h2>Index</h2>
                    <ul>
                        <xsl:apply-templates select="package" mode="index"/>
                    </ul>
                </div>
                <div id="content">                
                    <xsl:apply-templates select="package" />
                </div>
            </body>
        </html>
    </xsl:template>
     
    <xsl:template match="package" mode="index">
        <li>
            <a href="#{name}"><xsl:value-of select="name" /></a>
            <ul>
                <xsl:apply-templates select="class" mode="index" />
            </ul>
        </li>
    </xsl:template>
    
    <xsl:template match="class" mode="index">
        <li>
            <b><a href="#{../name}.{name}"><xsl:value-of select="name" /></a></b>
        </li>
    </xsl:template>

    <xsl:template match="package">
        <a name="{name}"/>
        <h2 class="package-name"><span><xsl:value-of select="name" /></span></h2>
        <xsl:apply-templates select="class"/>
    </xsl:template>
    
    <xsl:template match="class">
        <a name="{../name}.{name}"/>
        <h3 class="class-name"><span><xsl:value-of select="name" /></span></h3>
        <ul>
            <xsl:apply-templates select="step" />
        </ul>
    </xsl:template>
    
    <xsl:template match="step">
        <li>
            <p class="step-name"><span class="annotation"><xsl:value-of select="type" /></span> <xsl:value-of select="pattern" /></p>
            
            <xsl:apply-templates select="description"/>
            
            <p><a href="#" class="filename"><xsl:value-of select="file" />:<xsl:value-of select="lineStart" /></a></p>
        </li>
    </xsl:template>
    
    <xsl:template match="description">
        <div class="javadoc">
            <xsl:value-of select="text()" disable-output-escaping="yes"/>
            <!--
            <xsl:text disable-output-escaping="yes">
                <xsl:value-of select="text()"/>
            </xsl:text>
            -->
        </div>
    </xsl:template>
    
    <xsl:template match="*">
        #ERROR
    </xsl:template>
    
</xsl:stylesheet>
