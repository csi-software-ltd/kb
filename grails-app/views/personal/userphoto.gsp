<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>      
    <meta name="layout" content="main" />
    <g:javascript>      
      var saved = false;

      function deleteHomePhoto(){
        if (confirm('Вы уверены?')){
          $('deleteForm').submit();
        }
      }
      window.addEventListener('unload', function(){
        var needSave = false;
        for(i=1;i<=${maxI};i++){
          if($('is_uploaded'+i).value==1)
            needSave = true;
        }
        if(needSave && !saved)
          if(confirm('Вы не сохранили данные. Сохранить?'))
            $('photoAddForm').submit();
      }, false);

      function addPhoto(){
          saved = true;
          $('photoAddForm').submit();
      }

      function cancelP(){
        saved = true;
        $('apage').submit();
      }

      function deletepicuserphoto(lId,iNo){
        ${remoteFunction(controller:'personal', 
                         action:'deletepicuserphoto',
                         params:"'name=file'+iNo+'&id='+lId", 
                         onSuccess:'reloadImage(iNo)'
        )};
      }
    </g:javascript>
  </head>  
  <body onload="viewSmallMap()">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    <div class="info">
      <p><g:rawHtml>${infotext?.itext?infotext.itext:''}</g:rawHtml></p>
  <g:while test="${i <= maxI}">
    <g:if test="${(i==1)||!(id?:0)}">
      <fieldset id="tr_${i}" <g:if test="${i!=1}">style="display: none;"</g:if>>
        <g:form name='ff${i}' method="post" url="${[action:'saveuserphoto',id:id?:0]}" enctype="multipart/form-data" target="upload_target${i}">
          <div id="error${i}" style="display: none;"></div>
          <div id="uploaded${i}" class="upload" style="float:left">
          <g:if test="${images?.('photo_'+i)}">
            <img width="140" height="140" src="${images?.is_local?imageurl:''}${images?.('photo_'+i)}" border="0"/>
          </g:if><g:else>
            <img width="140" height="140" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0"/>
          </g:else>
          </div>
          <div style="width:50%;padding-top:45px;float:right">
            <input type="button" id="button${i}" value="Изменить" onclick="deletepicuserphoto(${id?:0},${i})" <g:if test="${(images?.('thumb_'+i)?:'')==''}">style="display: none;"</g:if>>
            <div id="btn${i}">
              <input type="file" <g:if test="${(i==1)&&!(id?:0)}">multiple</g:if> name="file${i}" id="file${i}" size="23" accept="image/jpeg,image/gif" onchange="startSubmit('ff${i}')" <g:if test="${images?.('thumb_'+i)}">style="display: none;"</g:if>/>
            </div>
            <input type="hidden" name="is_uploaded1" id="is_uploaded1" value="${images?.photo_1?1:0}" />
            <input type="hidden" id="no${i}" name="no" value="${i}"/>
            <input type="hidden" name="is_uploaded${i}" id="is_uploaded${i}" value="${images?.('photo_'+i)?1:0}"/>
          </div>
        </g:form>
        <div id="loader" style="position: absolute; top: 100px; display: none; width: 16px; height: 16px;">
          <img src="${resource(dir:'images',file:'spinner.gif')}" border="0">
        </div>
        <iframe id="upload_target${i}" name="upload_target${i}" src="#" style="width:0;height:0;border:0px solid #fff;"></iframe>
      </fieldset>
    </g:if>
    <%i++%>
  </g:while>
      <fieldset class="noborder" style="border:none">
        <input type="button" name="submit" value="<g:message code='button.save'/>" onclick="addPhoto()" style="float:left"/>
        <g:if test="${userphoto && !userphoto?.is_main}">
          <input type="button" name="delete" value="<g:message code='button.delete'/>" onclick="deleteHomePhoto()" style="margin-left:10px;float:left"/>
        </g:if>
        <g:form name="apage" url="${[controller:'personal',action:'photo']}" method="post">
          <input type="button" class="reset" value="<g:message code='button.cancel'/>" style="margin-left:10px;float:left" onclick="cancelP();"/>
        </g:form>
      </fieldset>
    </div>
  
<!-- /Загрузка имиджей -->
<script language="javascript" type="text/javascript">
  function reloadImage(iNum){
    $('uploaded'+iNum).update('<img width="140" height="140" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0"/>');
    $('button'+iNum).hide();
    $('file'+iNum).value='';
    $('file'+iNum).show();
    $('is_uploaded'+iNum).value=0;
  }

  function startSubmit(sName){
	  $(sName).submit();
    $('loader').show();
    return true;
  }

  function stopUpload(iNum,sFilename,sThumbname,iErrNo,sMaxWeight) {
	  if((iNum<=0)||(iNum>${maxI})) iNum=1;
	  
	  $('loader').hide();
    if(iNum==2){
      if($('file1').style.display!="none")
        $('btn1').update('<input type="file" name="file1" id="file1" size="23" accept="image/jpeg,image/gif" onchange="startSubmit('+'ff1'+')"/>');
      else
        $('btn1').update('<input type="file" name="file1" id="file1" size="23" accept="image/jpeg,image/gif" onchange="startSubmit('+'ff1'+')" style="display: none;"/>');
      $('no1').value=0;
    }
    if(iErrNo==0){
      $('is_uploaded'+iNum).value=1;
      $('uploaded'+iNum).show();
      $('uploaded'+iNum).update('<img width="140" height="140" src="${imageurl}'+sFilename+'" border="1">');
      $('file'+iNum).hide();
      $('error'+iNum).hide();
      $('button'+iNum).show();
      if (iNum<=${maxI}){
        $('tr_'+(iNum)).show();
      }
    }else{
      if (iNum<=${maxI}){
        $('tr_'+(iNum)).show();
      }
      var sText="Ошибка загрузки";
      switch(iErrNo){
        case 1: 
        case 2: sText="Ошибка загрузки"; break;
        case 3: sText="Слишком большой файл. Ограничение "+sMaxWeight+" Мб"; break;
        case 4: sText="Неверный тип файла. Используйте JPG или PNG"; break;
      } 
      $('is_uploaded'+iNum).value=0;
      $('error'+iNum).update(sText);
    	$('error'+iNum).show();
    }
    return true;
  }
</script>

  <g:form  id="deleteForm" name="deleteForm" url="${[controller:'personal',action:'userphotodelete',params:[id:id?:0]]}"
        method="POST" useToken="true">
  </g:form>
  <g:form id="photoAddForm" name="photoAddForm" url="${[controller:'personal',action:'userphotoadd',params:[id:id?:0]]}"
		method="POST" useToken="true">
  </g:form>

  </body>
</html>
