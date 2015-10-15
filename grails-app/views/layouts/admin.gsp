<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <title><g:layoutTitle default="Кто близко"/></title>
    <meta http-equiv="content-language" content="ru" />
    <meta http-equiv="content-type" content="text/html; charset=utf-8" />           
    <meta http-equiv="distribution" content="global" />    
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />                    
    <meta name="keywords" content="${infotext?.keywords?infotext.keywords:''}" />
    <meta name="description" content="${infotext?.description?infotext.description:''}" />    
    <meta name="resource-type" content="document" />
    <meta name="document-state" content="dynamic" />    
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>        
    <meta name="robots" content="all" />
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'main.css')}" />
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'dropkick.css')}" />        
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'qtip.css')}" />
    <g:javascript library="jquery-1.6.2" />
    <g:javascript library="jquery.dropkick" />    
    <!-- <g:javascript library="jquery.colorbox" />
    <g:javascript library="jquery.qtip" /> -->
    <!-- <g:javascript library="application" /> -->
    <g:javascript library="prototype" />        
    <!-- <g:javascript library="prototype/effects" />
    <g:javascript library="prototype/controls" /> -->
    <calendar:resources lang="ru" theme="tiger"/>    
    <g:javascript>
      var j=jQuery.noConflict();
      j(document).ready(function(){
        var oSelect = j('select').not('.default');
        for (var i=0; i<oSelect.size(); i++){
          oSelect[i].addClassName('default');
          oSelect[i].setAttribute('tabindex',(i+1));
        }  
        j('.default').dropkick({
          change: function(){
            j(this).change();
          }
        });
      });
    </g:javascript>
    <g:layoutHead />    
  </head>  
  <body onload="${pageProperty(name:'body.onload')}">
    <div class="html">
      <div align="center">
        <span style="${admin?'float:left':''}">        
          <b>Административное приложение <img src="${resource(dir:'images',file:'logo2.png')}" width="100" align="absmiddle" alt="На главную" border="0" /></b>
        <g:if test="${admin}">                                
          <a id="user" href="javascript:void(0)" style="margin: 0 50px;">${admin?.login?:''}</a>
        </g:if>
        </span>
      <g:if test="${admin}">  
        <span style="float:right">
          <span class="select" style="margin-top:17px">
            <g:form name="menuForm" url="[controller:'administrators',action:'menu']" method="post">            
              <label for="menu">Меню</label>
              <select name="menu" onchange="$('menuForm').submit()" style="width:175px">
              <g:each in="${admin?.menu}" var="item">
                <option value="${item.id}" <g:if test="${action_id==item.id}">selected="selected"</g:if>>${item.name}</option>
              </g:each>                                              
              </select>
            </g:form>        
          </span>
          <span style="float:right;margin-top:20px">
          <g:link controller="administrators" action="logout">Выйти</g:link>                      
          </span>          
        </span>  
      </g:if>
      </div>
      <div style="clear:both">
        <div class="content">          
          <g:layoutBody />                      
        </div>
      </div>
    </div>
    
  </body>
</html>
