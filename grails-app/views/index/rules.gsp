<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>
    <meta name="keywords" content="" />
    <meta name="description" content="" />     
    <meta name="layout" content="main" /> 
  </head>
  <body onload="viewSmallMap()">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    <g:if test="${infotext?.itext}">
    <div class="info">
      <fieldset> 
        ${infotext?.itext?:''}
      </fieldset>
    </g:if>  
  </body>
</html>
