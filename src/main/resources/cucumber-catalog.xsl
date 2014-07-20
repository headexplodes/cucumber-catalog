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
                        margin-left: 420px;
                        padding: 0 10px;
                        height: 100%;
                        overflow: scroll;
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
                        --white-space: pre-wrap;
                    }
                    
                    .javadoc pre, .javadoc code {
                        background-color: #eee;
                    }
                    
                    body.with-source #sources {
                        display: block;
                    }
                    
                    body.with-source #sources {
                        display: block;
                    }
                    
                    #sources {
                        position: fixed;
                        right: 0;
                        left: 420px;
                        bottom: 0;
                        height: 500px;
                        overflow: hidden;
                        overflow-y: scroll;
                        padding: 10px;
                        background-color: #eee;
                        display: none;
                    }
                    
                    .source-line {
                        white-space: nowrap;
                        font-family: monospace;
                    }
                    
                    .source-name {
                        color: white;
                        background-color: #999;
                        padding: 3px;
                        font-weight: bold;
                        margin: 10px 0;
                    }
                    
                    .line-no {
                        display: inline-block;
                        color: #999;;
                        width: 3em;
                    }
                    
                    .line-value {
                        white-space: pre;
                    }
                    
                    :target {
                        background-color: #fcf6c8;
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
                <div id="sources">
                    <xsl:apply-templates select="//source"/>
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
        <!-- 
        <xsl:apply-templates select="source"/>
        -->
    </xsl:template>
    
    <xsl:template match="step">
        <li>
            <p class="step-name"><span class="annotation"><xsl:value-of select="type" /></span> <xsl:value-of select="pattern" /></p>
            
            <xsl:apply-templates select="description"/>
            
            <p>Source: <a href="#{file}:{lineStart}" class="filename"><xsl:value-of select="file" />:<xsl:value-of select="lineStart" /></a></p>
        </li>
    </xsl:template>
    
    <xsl:template match="description">
        <div class="javadoc">
            <xsl:value-of select="text()" disable-output-escaping="yes"/>
        </div>
    </xsl:template>
    
    <xsl:template match="source">
        <div class="source">
            <div class="source-name">
                <xsl:value-of select="name"/>
            </div>
            <xsl:apply-templates select="line"/>
        </div>
    </xsl:template>
    
    <xsl:template match="source/line">
        <div class="source-line" data-line="{@line}" id="{../name}:{@line}">
            <!-- <a name="{../name}:{@line}"/> -->
            <span class="line-no"><xsl:value-of select="@line"/></span> 
            <span class="line-value"><xsl:value-of select="concat(text(), ' ')"/></span>
        </div>  
    </xsl:template>
    
    <xsl:template match="*">
        #ERROR
    </xsl:template>
    
</xsl:stylesheet>
