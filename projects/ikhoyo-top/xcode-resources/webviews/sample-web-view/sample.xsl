<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
<html>
<head>
<style type="text/css">
body {
margin: 0;
background-color: #eee;
font: 16px Verdana, Arial, Helvetica, sans-serif; 
}
.home {
padding: 20px;
}
</style>
</head>
<body>
<div class="home">
<center><h3>Welcome to the Ikhoyo Sample Web View</h3></center>
<p>
The Ikhoyo Sample Web View shows you how to create web applications using the Ikhoyo libraries, xml, and xsl. It's a very streamlined and efficient way to create local web applications that run on the iPad.
</p>
<h3>Here is the list taken from the context:</h3>
<div>
    <xsl:apply-templates select="//list"/>
</div>
</div>
</body>
</html>
</xsl:template>
    
<xsl:template match="list">
    <ul>
        <xsl:apply-templates/>
    </ul>
</xsl:template>

<xsl:template match="item">
    <li><xsl:value-of select="text()"/></li>
</xsl:template>

</xsl:stylesheet>
