<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>      
    <meta name="layout" content="main" />                        
    <g:javascript>    
      var j = jQuery.noConflict();
      var collection = null;
      var bFlag=0;
      
      function initialize(){
        viewSmallMap();
        j('.hotlinks a:first').click();
      }

      j(document).ready(function(){
        j('.hotlinks li a').click(function(){
          j(this).parent().parent().find('.selected').removeClass('selected');
          j(this).parent().addClass('selected');      
        });
      });

      function removeAllMarkers(){
        if (collection){
          map.geoObjects.remove(collection);
          collection.removeAll();
        }
      }
      function addUmarkers(){
        if (collection && bFlag){
          map.geoObjects.add(collection);
        }
      }
      function addMarker(iX,iY,iIsLocal,sPict,sFirstname,iAge,iId){
        sPict = sPict || '';        
        var sIconCont = '<div class="placemark">'+
                        '  <img width="30" height="30" border="0" src="';
        if(sPict) {                    
          sIconCont += ((iIsLocal)?'${imageurl}':'') + sPict + '" />';
        } else {
          sIconCont += '${resource(dir:'images',file:'user-default-picture.png')}" />';
        }
        sIconCont += '<br/><div class="username">';
        sIconCont += '<a href="${context.is_dev?'/KB':''}/user/view/'+iId+'">'+sFirstname+'</a><br/>';
        sIconCont += '<span class="bold">'+iAge+'</span></div>';
        sIconCont += '</div>';
        var placemark = new ymaps.Placemark([iX, iY], { iconContent: sIconCont }, { iconOffset: [25, 80], hasBalloon:false });
        collection.add(placemark);
      }

      function openFoeNote(lId){
        if (lId==0) {
          j('#tofoe_note_s').animate({opacity: "show"}, 1200);
        } else {
          j('#tofoe_note_s').animate({opacity: "hide"}, 1200);
          $("tofoe_note").value = '';
        };
      }

      function openFriendNote(lId){
        if (lId==0) {
          j('#tofriend_note_s').animate({opacity: "show"}, 1200);
        } else {
          j('#tofriend_note_s').animate({opacity: "hide"}, 1200);
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
          $("tofriend_note").value = '';
          $("tofoe_note").value = '';
          j.colorbox.close();
          j('.hotlinks a')[e.responseJSON.type-1].click();
        }
      }

      function viewMap(){
        ymaps.ready(function(){          
          map = new ymaps.Map("map_container", 
            {center: [iyX, iyY], zoom: 11, type: "yandex#map", behaviors: ["default","scrollZoom"]}, 
            {geoObjectHint: false}
          );        
          map.controls.add("zoomControl").add("mapTools").add(
            new ymaps.control.TypeSelector(["yandex#map", "yandex#satellite", "yandex#hybrid", "yandex#publicMap"])
          );        
        <g:if test="${user}">
          var myBalloon = '<div style="margin:2px 0 0 -4px">'+
          <g:if test="${user?.picture}">
            '<img width="30" height="30" src="${user?.is_local?imageurl:''}${user?.ultrasmallpicture}" border="0" />'+
          </g:if><g:else>
            '<img width="30" height="30" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />'+
          </g:else>
            '</div>',          
            myPlacemark = new ymaps.Placemark([iyX, iyY], { 
              balloonContent: myBalloon }, { 
              hideIconOnBalloonOpen: false,
              iconImageHref: "${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [11, 19],
              iconOffset: [5, 20],
              balloonContentSize: [40, 58],
              balloonLayout: "default#imageWithContent",
              balloonImageHref: "${resource(dir:'images',file:'placemark-my.png')}",
              balloonImageOffset: [-20, -77],
              balloonImageSize: [40, 58],            
              balloonShadow: false
            });        
          map.geoObjects.add(myPlacemark);
          myPlacemark.balloon.open();        
        </g:if>
          collection = new ymaps.GeoObjectCollection({}, { preset: "twirl#blueStretchyIcon" }); 
          map.geoObjects.add(collection);
        });
      }

      function toggleView(iId,iType){
        if(iType==3)
          $('view_link').hide();
        else
          $('view_link').show();

        if(iId==1 && bFlag!=1){
          if($('tableAJAX'))
            $('tableAJAX').hide();
          $('map_view').show();
          j('#map_view').animate({opacity: "show"}, 1200);
          $('map_container').setStyle({ visibility: 'visible'});
          viewMap();

          new Ajax.Updater('list_view',"${(context?.is_dev)?'/'+context?.appname+'/personal/mymapfriends':'/personal/mymapfriends'}",{asynchronous:true,evalScripts:true,onSuccess:function(e){
            $('view_link').value = 'Показать список';
            document.getElementById('view_link').onclick = function() {
              toggleView(0,iType);
            }
          }});
          bFlag=1; 
          
        }else if (iId==0 && bFlag==1) {

          new Ajax.Updater('list_view',"${(context?.is_dev)?'/'+context?.appname+'/personal/myfriends':'/personal/myfriends'}",{asynchronous:true,evalScripts:true,onSuccess:function(e){
            $('view_link').value = 'Смотреть на карте';
            document.getElementById('view_link').onclick = function() {
              toggleView(1,iType);
            }
          }});
          $('tableAJAX').show();
          $('map_view').hide();
          $('map_container').setStyle({ visibility: 'hidden'});
          $('map_container').update('');
          bFlag=0;
        }
      }
    </g:javascript>
    <g:setupObserve function='clickPaginate' id='list_view'/>
  </head>
  <body onload="initialize()">  
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    
   <ul class="hotlinks">
      <li class="selected">
        <g:remoteLink class="links friends" action="myfriends" before="toggleView(0,1)" params="[type:1]" update="list_view">Мои друзья</g:remoteLink>
      </li>
      <!--li>
        <g:remoteLink action="myfriends" before="toggleView(0);" params="[type:2]" update="list_view">Меня записали в друзья</g:remoteLink>
      </li-->
      <li>        
        <g:remoteLink class="links ignore" action="myfriends" before="toggleView(0,3)" params="[type:3]" update="list_view">Игнорируемые</g:remoteLink>
      </li>
    </ul>

    <div class="list_view">
      <input type="button" id="view_link" class="link" value="Смотреть на карте" onclick="toggleView(1,0)" style="float:right"/>              
      <div id="list_view">
      </div>    
      <div id="map_view" style="clear:both">
        <div id="map_container" style="visibility:hidden;width:535px"></div>
      </div>
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
                <option value="0">Своя версия</option>
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

    <div id="tofoe_lbox" class="new-modal" style="display:none">
      <h2 class="blue clearfix">Укажите причину удаления:</h2>
      <div class="segment nopadding">
        <div id="tofoe_lbox_container" class="lightbox_filter_container">
          <div id="message_data"></div>         
          <div id="tofoe_error" class="notice" style="display:none">
            <span id="tofoe_errorText"></span>
          </div>          
          <fieldset>
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
      <input type="hidden" id="relationship_user_id" name="user_id" value="" />
      <input type="hidden" id="relationship_relnote_id" name="relnote_id" value="" />
      <input type="hidden" id="relationship_note" name="note" value="" />
      <input type="hidden" id="relationship_mark" name="mark" value="" />
      <input type="hidden" id="relationship_type" name="type" value="1" />
      <input type="submit" id="relationship_submit_button" style="display:none" value="" />
    </g:formRemote>

  </body>
</html>
