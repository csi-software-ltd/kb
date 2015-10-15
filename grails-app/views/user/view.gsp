<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${detail?.firstname?:''}</title>    
    <meta name="layout" content="main" />
    <g:javascript>
      j(document).ready(function(){
        j('#tofriend_lbox_link').colorbox({
          inline: true, 
          href: '#tofriend_lbox',
          scrolling: false,
          onLoad: function(){
            j('#tofriend_lbox').show();          
          },
          onCleanup: function(){
            j('#tofriend_lbox').hide();            
          }        
        });
        j('#tofoe_lbox_link').colorbox({
          inline: true, 
          href: '#tofoe_lbox',
          scrolling: false,
          onLoad: function(){
            j('#tofoe_lbox').show();          
          },
          onCleanup: function(){
            j('#tofoe_lbox').hide();            
          }        
        });
        j('.bigPhotoSlider').colorbox({
          rel:'bigPhotoSlider',
          next:'',
          previous:'',
          loop: false,
          scalePhotos: true,
          onLoad: function(){
            j('#cboxNext').show();
            j('#cboxPrevious').show();
          }
        });
      });

      function openFoeNote(lId){
        if (lId==0) {
          j('#tofoe_note_s').animate({opacity: "show"}, 1200);
          j.colorbox.resize();
        } else {
          j('#tofoe_note_s').animate({opacity: "hide"}, 1200, function() {j.colorbox.resize();});
          $("tofoe_note").value = '';
        };
      }

      function openFriendNote(lId){
        if (lId==0) {
          j('#tofriend_note_s').animate({opacity: "show"}, 1200);
          j.colorbox.resize();
        } else {
          j('#tofriend_note_s').animate({opacity: "hide"}, 1200, function() {j.colorbox.resize();});
          $("tofriend_note").value = '';
        };
      }

      function expressRelation(iId){
        if (iId==1) {
          $("relationship_relnote_id").value = $("tofriend_relnote_id").value;
          $("relationship_note").value = $("tofriend_note").value;
        } else if(iId==-1){
          $("relationship_relnote_id").value = $("tofoe_relnote_id").value;
          $("relationship_note").value = $("tofoe_note").value;
        } else {
          $("relationship_relnote_id").value = '';
          $("relationship_note").value = '';
        }
        $("relationship_mark").value = iId;
        $("relationship_submit_button").click();
      }

      function relationshipResponse(e) {
        if (e.responseJSON.error){
          if ($("relationship_mark").value==1) {
            if (e.responseJSON.message){
              $('tofriend_error').show();
              $('tofriend_errorText').update(e.responseJSON.message);
            }
            $("tofriend_lbox_link").click();
          } else if($("relationship_mark").value==-1) {
            if (e.responseJSON.message){
              $('tofoe_error').show();
              $('tofoe_errorText').update(e.responseJSON.message);
            }
            $("tofoe_lbox_link").click();
          }
        } else {
          location.reload(true);
        }
      }
      function viewSmallMapForDetail(){
        if(${user?1:0}){
          ymaps.ready(function(){          
            small_map = new ymaps.Map("small_map_container", 
              {center: [${detail.x}/100000, ${detail.y}/100000], zoom: 11, type: "yandex#map", behaviors: [""]},
              {geoObjectHint: false}
            );
            if (${user?.geocodestatus==0})
              getLocation();
            else if (${user?.geocodestatus==1})
              watchLocation();
            myPlacemarkSmall = new ymaps.Placemark([${detail.x}/100000, ${detail.y}/100000], {}, { 
              hideIconOnBalloonOpen: false,
              iconImageHref: "${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [11, 19],          
              iconOffset: [5, 25]            
            });        
            small_map.geoObjects.add(myPlacemarkSmall);
            
            if(!$('small_map_layout')){
              var layout = document.createElement('div');
              layout.setAttribute('id', 'small_map_layout');
              $('small_map_container').appendChild(layout);  
            }
          });
        }
      }
    </g:javascript>
  </head>
  <body onload="viewSmallMapForDetail()">
    <div class="gender ${(detail?.gender_id==1)?'male':'female'}">
      <h1>${detail?.firstname?:''} ${detail?.lastname?:''}</h1>      
      <g:each in="${city}" var="item">
        <g:if test="${detail?.city_id==item?.id}">  
      <div class="user">
        <span class="username">${item?.name}</span>
      </div>
        </g:if>
      </g:each>
    </div>
    <div style="padding:45px 0px;height:45px">          
      <label style="font-size: 14px;">День рождения</label>
      <h2 style="margin-top:0px">${dbday_day} ${dbday_month}</h2>
      <div class="sign">
      <g:if test="${user}">
        <div class="actions col">
        <g:if test="${(relationshipStatus?.fromuser==user.id && relationshipStatus.markfromto==1) || (relationshipStatus?.touser==user.id && relationshipStatus.marktofrom==1)}">
          <span class="action_button i">
            <a class="icon delete" title="Убрать из друзей" href="javascript:void(0)" onclick="expressRelation(0)"></a>
          </span>
        </g:if>
        <g:elseif test="${(relationshipStatus?.fromuser==user.id && relationshipStatus.markfromto==-1) || (relationshipStatus?.touser==user.id && relationshipStatus.marktofrom==-1)}">
          <span class="action_button i">
            <a class="icon delete" title="Убрать из списка игнорирования" href="javascript:void(0)" onclick="expressRelation(0)"></a>
          </span>
        </g:elseif>
        <g:else>
          <span class="action_button i">
            <a id="tofriend_lbox_link" class="icon favorite" title="Добавить в друзья" href="javascript:void(0)"></a>
          </span>
          <span class="action_button i">
            <a id="tofoe_lbox_link" class="icon ignore" title="Добавить в лист игнорирования" href="javascript:void(0)"></a>
          </span>
        </g:else>
          <span id="sasdasdaxxzczx${detail?.id}" class="action_button i">
            <g:remoteLink class="icon edit" controller="personal" action="messageDetails" id="${detail?.id}" title="Написать письмо" update="chat_lbox_container" onComplete="openChat();"></g:remoteLink>
          </span>
        </div>
      </g:if>
      </div>
    </div>
  <g:if test="${detail?.wishes}">
    <div class="relative">
      <label for="wishes">Ищу</label>
      <textarea name="wishes" disabled>${detail?.wishes?:''}</textarea>
    </div>
  </g:if>
  <g:if test="${detail?.description}">
    <div class="relative">
      <label for="description">О себе</label>
      <textarea name="description" disabled>${detail?.description?:''}</textarea>
    </div>
  </g:if>
  <g:if test="${detail?.hobby}">
    <div class="relative">
      <label for="hobby">Мои хобби</label>
      <textarea name="hobby" disabled>${detail?.hobby?:''}</textarea>      
    </div>
  </g:if>
    <div class="user_list">
      <ul class="photo">
      <g:each in="${detailPhotos}" var="item">   
        <li>
        <g:if test="${item?.picture}">
          <g:link class="bigPhotoSlider" action="bigPhoto" controller="personal" id="${item?.id}-${item?.user_id}"><img width="70" height="70" src="${item?.is_local?imageurl:''}${item?.smallpicture}" border="0" /></g:link>
        </g:if><g:else>
          <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
        </g:else>          
        </li>
      </g:each>
      </ul>
    </div>

    <div id="tofriend_lbox" class="new-modal" style="display:none">
      <h2 class="blue clearfix">Укажите причину добавления в друзья:</h2>
      <div class="segment nopadding">
        <div id="tofriend_lbox_container" class="lightbox_filter_container">
          <div id="message_data"></div>         
          <div id="tofriend_error" class="notice" style="display:none">
            <span id="tofriend_errorText"></span>
          </div>          
          <fieldset>
            <div class="select">
              <label for="tofriend_relnote_id">Причина:</label>
              <select id="tofriend_relnote_id" name="tofriend_relnote_id" onchange="openFriendNote(this.value);">
              <g:each in="${tofriend_relnote}" var="item">
                <option value="${item?.id}">${item?.name}</option>
              </g:each>
                <option value="0">своя версия</option>
              </select>
            </div><br/>
            <span class="select" id="tofriend_note_s" style="display:none">
              <label for="tofriend_note">Своя причина:</label>
              <input type="text" id="tofriend_note" value="" placeholder="причина" />
            </span><br/>
          </fieldset>          
        </div>
      </div>
      <div class="segment buttons">
        <input type="button" onclick="expressRelation(1)" value="${message(code:'button.add')}"/>
      </div>
    </div>

    <div id="tofoe_lbox" class="new-modal" style="width:580px;display:none">
      <h2 class="blue clearfix">Укажите причину игнорирования:</h2>
      <div class="segment nopadding">
        <div id="tofoe_lbox_container" class="lightbox_filter_container">
          <div id="message_data"></div>         
          <div id="tofoe_error" class="notice" style="display:none">
            <span id="tofoe_errorText"></span>
          </div>          
          <div class="info">
            <fieldset class="noborder">
              <div class="select">
                <label for="tofoe_relnote_id">Причина:</label>
                <select id="tofoe_relnote_id" name="tofoe_relnote_id" onchange="openFoeNote(this.value);">
                <g:each in="${tofoe_relnote}" var="item">
                  <option value="${item?.id}">${item?.name}</option>
                </g:each>
                  <option value="0">Своя версия</option>
                </select>
              </div><br/>
              <span class="select" id="tofoe_note_s" style="display:none">
                <label for="tofoe_note">Своя причина:</label>
                <input type="text" id="tofoe_note" value="" placeholder="причина" />
              </span><br/>
            </fieldset>
          </div>
        </div>
      </div>
      <div class="segment buttons">
        <input type="button" onclick="expressRelation(-1)" value="${message(code:'button.add')}"/>
      </div>
    </div>

    <div id="chat_lbox" class="new-modal" style="display:none">
      <div class="segment nopadding" style="padding:4px 10px 10px">
        <div id="chat_lbox_container" class="lightbox_filter_container">
        </div>
      </div>      
    </div>
    <a id="chat_lbox_link" href="javascript:void(0)" style="display:none;"></a>

    <g:formRemote name="relationshipForm" url="[controller: 'index', action: 'relationship']" onSuccess="relationshipResponse(e);">
      <input type="hidden" id="user_id" name="user_id" value="${detail?.id}" />
      <input type="hidden" id="relationship_relnote_id" name="relnote_id" value="" />
      <input type="hidden" id="relationship_note" name="note" value="" />
      <input type="hidden" id="relationship_mark" name="mark" value="" />
      <input type="submit" id="relationship_submit_button" style="display:none" value="" />
    </g:formRemote>

  </body>
</html>
