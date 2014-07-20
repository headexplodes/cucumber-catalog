<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output
         method="html"
         encoding="UTF-8"
         indent="yes" />

    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html></xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="/catalog">
        <html>
            <head>
                <title>Cucumber Step Catalog</title>
                <style type="text/css">

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
                        width: 400px;
                        background-color: #c5d88a;
                        min-height: 100%;
                        padding: 10px;

                    }
                    
                    #index h1 {
                        color: #164b2b;
                    }
                    
                    #index .logo {           
                        opacity: 0.5;
                        position: absolute;
                        top: 0;
                        right: 0;
                    }
                    
                    #index ul {
                        margin-bottom: 1em;
                    }
                    
                    #content {
                        margin-left: 420px;
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
                        --white-space: pre-wrap;
                    }
                    
                    .javadoc pre, .javadoc code {
                        background-color: #eee;
                    }

                    #source-templates {
                        display: none;
                    }

                    .source {
                        height: 200px;
                        overflow: hidden;
                        overflow-y: scroll;
                        background-color: #666;
                        color: #eee;
                        position: relative;
                        transition: height .5s;
                    }

                    #sources-close {
                        position: relative;
                        width: 50px;
                        height: 20px;
                        background-color: #666;
                        left: -50px;
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
                    
                    .source-container {

                    }
                    
                    .line-no {
                        display: inline-block;
                        color: #999;
                        width: 3em;
                    }
                    
                    .line-value {
                        white-space: pre;
                    }
                    
                    .hilight {
                        background-color: #fcf6c8;
                        color: #333;
                    }

                </style>
                <script style="text/javascript">
                    <![CDATA[
                    
                    Element.prototype.hasClassName = function(name) {
                        return new RegExp("(?:^|\\s+)" + name + "(?:\\s+|$)").test(this.className);
                    };

                    Element.prototype.addClassName = function(name) {
                        if (!this.hasClassName(name)) {
                            this.className = this.className ? [this.className, name].join(' ') : name;
                        }
                    };

                    Element.prototype.removeClassName = function(name) {
                        if (this.hasClassName(name)) {
                            var c = this.className;
                            this.className = c.replace(new RegExp("(?:^|\\s+)" + name + "(?:\\s+|$)", "g"), "");
                        }
                    };
                    
                    function getSourceElement(filename) {
                        return document.querySelector("#source-templates .source[data-filename='" + filename + "']").cloneNode(true); // deep clone
                    }
                    
                    function toggleHeight(elem, height) {
                        if (elem.clientHeight == 0) {
                            elem.style.height = height;
                        } else {
                            elem.style.height = "0";
                        }
                    }
                                        
                    function setOnClick(item) {
                        item.onclick = function(e) {
                        
                            var cont = item.parentElement.parentElement.querySelector(".source-container");
                            
                            if (cont.firstChild) {
                                
                                toggleHeight(cont.firstChild, "200px");
                                
                            } else {
                            
                                var filename = item.getAttribute("data-filename");
                                var lineNo = item.getAttribute("data-line"); 
                                
                                var src = getSourceElement(filename);
                                                    
                                cont.appendChild(src);
                                
                                src.style.height = "0";
                                window.getComputedStyle(src).height // trigger browser to acknowledge changed style
                                
                                removeClassAll(src, "hilight");
                                
                                var line = src.querySelector("div[data-line='" + lineNo + "']");

                                line.addClassName("hilight");

                                src.style.height = "200px";
                                src.scrollTop = line.offsetTop;
                            
                            }
                            
                            e.preventDefault();
                        };
                    }
                    
                    function removeClassAll(elem, name) {
                        var nodes = elem.querySelectorAll(".hilight");
                        for (var i = 0; i < nodes.length; ++i) {
                            nodes[i].removeClassName(name);
                        }
                    }
                    
                    function onLoad() {
                        var nodes = document.querySelectorAll("a.filename");
                        for (var i = 0; i < nodes.length; ++i) {
                            setOnClick(nodes[i]);
                        }
                    }

                    ]]>
                </script>
            </head>
            <body onload="onLoad()">
                <div id="index">
                    <div class="logo">
                        <img src="cucumber_logo.png"/>
                    </div>
                    <h1>Cucumber Step Catalog</h1>
                    <br/>
                    <h2>Index</h2>
                    <ul>
                        <xsl:apply-templates select="package" mode="index"/>
                    </ul>
                </div>
                <div id="content">                
                    <xsl:apply-templates select="package" />
                </div>
                <div id="source-templates">
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
    </xsl:template>
    
    <xsl:template match="step">
        <li>
            <p class="step-name"><span class="annotation"><xsl:value-of select="type" /></span> <xsl:value-of select="pattern" /></p>
            
            <xsl:apply-templates select="description"/>
            
            <p><a href="javascript:" class="filename" data-filename="{file}" data-line="{lineStart}">
                    <xsl:value-of select="file"/>:<xsl:value-of select="lineStart"/></a></p>
            
            <div class="source-container"/>
        </li>
    </xsl:template>
    
    <xsl:template match="description">
        <div class="javadoc">
            <xsl:value-of select="text()" disable-output-escaping="yes"/>
        </div>
    </xsl:template>
    
    <xsl:template match="source">
        <div class="source" data-filename="{name}">
            <xsl:apply-templates select="line"/>
        </div>
    </xsl:template>
    
    <xsl:template match="line">
        <div class="source-line" data-line="{@line}">
            <span class="line-no"><xsl:value-of select="@line"/></span> 
            <span class="line-value"><xsl:value-of select="concat(text(), ' ')"/></span>
        </div>  
    </xsl:template>
    
    <xsl:template match="*">
        #ERROR
    </xsl:template>
    
</xsl:stylesheet>
