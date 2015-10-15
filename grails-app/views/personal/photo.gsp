<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>      
    <meta name="layout" content="main" />                            
    <g:javascript>    
    var apiX = null;
    var j = jQuery.noConflict();
    
    function initialize(){
      viewSmallMap();
      sortInit();
      j('.bigPhotoSlider').colorbox({
        rel: 'bigPhotoSlider',
        next: '',
        previous: '',
        loop: false,
        onLoad: function(){
          j('#cboxNext').show();
          j('#cboxPrevious').show();
        }
      });
    }
    
    function sortInit(){
      j('#pictures').sortable("disable");
      j('#pictures li').css({ 'cursor' : 'default' });
      j('#pictures li .layout').show();
      j('#sortsave').hide();
      j('#sortedit').show();
      j('#loader').hide();
    }

    function deletePhoto(lId){
      if (confirm('Вы уверены?')){
        $('deletePhotoForm'+lId).submit();
      }
    }
    
    function sendForm(){      
      $("mapForm").submit();			 	  
    }    
   
    function sortedit(){
      j('#sortsave').show();
      j('#sortedit').hide(); 
      j('#pictures').sortable("enable");      
      j('#pictures').sortable();      
      j('#pictures').disableSelection();
      j('#pictures li').css({ 'cursor' : 'move' }); 
      j('#pictures li .layout').hide();
      j('#loader').show();
    }
    function sortable(){
      var aOrder = j('#pictures').sortable('toArray');
      ${remoteFunction(action:'sort_photo',params:'\'ids=\'+aOrder')};
      sortInit();
    }

    function setMainPhoto(lId){
      ${remoteFunction(action:'set_main_photo',params:'\'id=\'+lId',update:'main_photo')};
    }
    function setTenderPhoto(lId){
      ${remoteFunction(action:'set_tender_photo',params:'\'id=\'+lId',onSuccess:'location.reload(true);')};
    }
    </g:javascript>
  </head>
  <body onload="initialize()">  
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    <div class="info">
      <fieldset>
        <legend>Главное фото</legend>
        <div id="main_photo">
          <g:if test="${user?.picture}"><img src="${user?.is_local?imageurl:''}${user?.picture}" width="140" height="140"></g:if>
          <g:else><img src="${resource(dir:'images',file:'user-default-picture.png')}" width="140" height="140"></g:else>
        </div>
      </fieldset>    
    <g:if test="${photo}">      
      <fieldset>
        <legend>Фотографии</legend>
      <g:if test="${infotext?.itext}">
        <div class="text">
          <g:rawHtml>${infotext?.itext?:''}</g:rawHtml>
        </div>
      </g:if>          
        <ul class="ui-sortable photo" id="pictures">
        <g:each in="${photo}" var="item" status="i">            
          <li class="ui-state-default" id="photo_${item.id}">
            <div class="thumbnail <g:if test="${item?.is_main}">selected</g:if>" id="thumbnail_${item.id}">
            <g:if test="${item?.picture}">
              <g:javascript>
              j(document).ready(function(){
                j.fn.qtip.defaults.hide.delay = 3500;                  
                j('#mm_${item.id}').qtip({      
                  position: { my: 'top center', at: 'bottom center' },
                  events: {
                    show: function(event, api) {
                      if (apiX)
                        apiX.hide();
                      apiX = api;
                    }
                  },
                  style: { classes: 'ui-tooltip-shadow ui-tooltip-' + 'plain' },
                  content: { text: j('#sm_${item.id}') }
                });                  
              });
              </g:javascript>
              <g:link class="bigPhotoSlider" action="bigPhoto" id="${item?.id}-${item?.user_id}">
                <img id="mm_${item.id}" src="${item?.is_local?imageurl:''}${item?.smallpicture}" width="70" height="70" border="0" />
              </g:link>
              <div id="sm_${item.id}" style="display:none">
                <span class="actions">
                  <div id="main_${item.id}" style="display:${(item.is_main)?'none':'block'}">
                    <span class="action_button nowrap">
                      <a class="icon mainphoto" href="javascript:setMainPhoto(${item.id});">главная</a>
                    </span>
                  </div>
                  <div id="tender_${item.id}" style="display:${(item.is_tender==curTenderId || curTenderId<=0)?'none':'block'}">
                    <span class="action_button nowrap">
                      <a class="icon mainphoto" href="javascript:setTenderPhoto(${item.id});">на конкурс</a>
                    </span>
                  </div>
                  <span class="action_button nowrap">
                    <g:link class="icon edit" controller="personal" action="userphoto" params="${[id:item.id]}"><g:message code='button.edit'/></g:link>
                  </span>
                  <div id="delete_${item.id}" style="display:${(item.is_main)?'none':'block'}">
                    <span class="action_button nowrap">
                      <a class="icon delete" href="javascript:deletePhoto(${item.id})"><g:message code='button.delete'/></a>                     
                    </span>
                  </div>
                  <g:form name="deletePhotoForm${item.id}" controller="personal" action="userphotodelete" params="${[id:item.id]}" method="POST" useToken="true">
                  </g:form>
                </span>   
              </div>                  
            </g:if>
            </div>
          </li>                    
        </g:each>          
        </ul>    
      </fieldset>
    </g:if>
      <fieldset class="noborder" style="border:none">
        <g:form  id="addForm" name="addForm" url="[controller:'personal',action:'userphoto']" method="POST" useToken="true">
          <input type="hidden" name="user_id" value="${user?.id?:0}"/>
          <input type="submit" value="Добавить фото" style="float:left;margin-right:10px"/>
        </g:form>
        <g:if test="${photo.size() > 1}">
          <input type="button" id="sortedit" onclick="sortedit();return false;" value="Изменить порядок" style="float:left"/>
          <input type="button" style="display:none" id="sortsave" onclick="sortable();return false;" value="Сохранить порядок"/>
          <div id="loader" class="spinner" style="display: none">
            <img src="${resource(dir:'images',file:'spinner.gif')}" align="absmiddle" hspace="5" border="0">
            <span>Вы находитесь в режиме сортировки</span>
          </div>
        </g:if>                      
      </fieldset>
    </div>
    
  </body>
</html>
