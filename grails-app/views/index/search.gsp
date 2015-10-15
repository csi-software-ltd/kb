<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
<title>${infotext?.title?infotext.title:''}</title>    
    <meta name="layout" content="main" />
    <g:javascript>      
      var oSlider={};
      var bFlag=0;
      var cityArr=new Array();      
      var cluster = null, curCenter = null, myMapSearchPlacemark, myBalloon = null;
      <g:each in="${city}" var="item">
        var tmp = new Array();
        tmp.push('${item.id}');
        tmp.push('${item.x}');
        tmp.push('${item.y}');
        cityArr.push(tmp);
      </g:each>

      j(document).ready(function(){
        j('.hotlinks li a').click(function(){
          j(this).parent().parent().find('.selected').removeClass('selected');
          j(this).parent().addClass('selected');      
        });
      });

      function viewMap(){
        ymaps.ready(function(){
          map = new ymaps.Map("map_container",
            {center: [iyX, iyY], zoom: 11, type: "yandex#map", behaviors: ["default","scrollZoom"]},
            {geoObjectHint: false}
          );
          map.controls.add("zoomControl").add("mapTools").add(
            new ymaps.control.TypeSelector(["yandex#map", "yandex#satellite", "yandex#hybrid", "yandex#publicMap"])
          );
          map.events.add("boundschange", function(evt){
            var bounds = evt.get('newBounds');
            $('xl').value = Math.round(bounds[0][0]*100000);
            $('yl').value = Math.round(bounds[0][1]*100000);
            $('xr').value = Math.round(bounds[1][0]*100000);
            $('yr').value = Math.round(bounds[1][1]*100000);
            $('submit_button').click();
          });
          if (curCenter) {
            map.setCenter(curCenter);
          };
        <g:if test="${user}">
          myBalloon = '<div style="margin:2px 0 0 -4px">'+
          <g:if test="${user?.picture}">
            '<img width="30" height="30" src="${user?.is_local?imageurl:''}${user?.ultrasmallpicture}" border="0" />'+
          </g:if><g:else>
            '<img width="30" height="30" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />'+
          </g:else>
            '</div>';          
          myMapSearchPlacemark = new ymaps.Placemark([iyX, iyY], { 
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
          map.geoObjects.add(myMapSearchPlacemark);
          myMapSearchPlacemark.balloon.open();
        </g:if>
          cluster = new ymaps.Clusterer({ preset: "twirl#blueStretchyIcon" });
          map.geoObjects.add(cluster);
          $('xl').value = Math.round(map.getBounds()[0][0]*100000);
          $('yl').value = Math.round(map.getBounds()[0][1]*100000);
          $('xr').value = Math.round(map.getBounds()[1][0]*100000);
          $('yr').value = Math.round(map.getBounds()[1][1]*100000);
        });
      }

      function renderMyMapSearchPlacemark(){
        map.geoObjects.remove(myMapSearchPlacemark);
        myMapSearchPlacemark = new ymaps.Placemark([iyX, iyY], { 
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
        map.geoObjects.add(myMapSearchPlacemark);
        myMapSearchPlacemark.balloon.open();
        map.setCenter([iyX, iyY]);
      }

      function removeAllMarkers(){
        if (cluster){
          map.geoObjects.remove(cluster);
          cluster.removeAll();
        }
      }

      function addUmarkers(){
        if (cluster && bFlag){
            map.geoObjects.add(cluster);
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
        cluster.add(placemark);
      }
    
      function initialize(){
        $('map_view').hide();
        sliderf();
        if(${inrequest.view=='map'})
          toggleView();        
        $('submit_button').click();
      }

      function toggleView(){
        if(!bFlag){
          $('view_button').value = 'Показать список';
          $('view').value = 'map';
          if($('tableAJAX'))
            $('tableAJAX').hide();
          $('map_view').show();
          $('map_container').setStyle({ visibility: 'visible' });
          viewMap();
          bFlag = 1;
          $('submit_button').click();
        }else{
          $('view_button').value = 'Смотреть на карте';
          $('view').value = 'list';
          $('tableAJAX').show();
          $('map_view').hide();
          $('map_container').setStyle({ visibility: 'hidden' });
          $('map_container').update('');
          bFlag = 0;
          $('submit_button').click();
        }
      }

      function sliderf(){
        var slider = $('slider-range');
        oSlider=new Control.Slider(slider.select('.ui-slider-handle'), slider, {
          range: $R(${age_min}, ${age_max}),
          sliderValue: [${lastsearch?.age_min?:inrequest?.age_min?:age_min}, ${lastsearch?.age_max?:inrequest?.age_max?:age_max}],
          values: ${arr},                
          step: ${agestep},
          spans: ["slider_span"],
          restricted: true,        
          onChange: function(values){			
            $('slider_user_min').update(values[0]);
            if(values[1]==${age_max})
              $('slider_user_max').update(values[1]);
            else
              $('slider_user_max').update(values[1]);
		   
            $("age_min").value = values[0];
            $("age_max").value = values[1];
            $('submit_button').click();
          }
        });
        $('slider_user_min').update('${lastsearch?.age_min?:inrequest?.age_min?:age_min}');
        var age_max=${lastsearch?.age_max?:inrequest?.age_max?:age_max};
      
        $('slider_user_max').update(''+age_max+'');
        $('age_min').value = ${lastsearch?.age_min?:inrequest?.age_min?:age_min};
        $('age_max').value = ${lastsearch?.age_max?:inrequest?.age_max?:age_max};      
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
          } else if($("relationship_mark").value==-1) {
            if (e.responseJSON.message){
              $('tofoe_error').show();
              $('tofoe_errorText').update(e.responseJSON.message);
            }
          }
          j.colorbox.resize();
        } else {
          $("tofriend_note").value = '';
          jQuery.colorbox.close();
          $('submit_button').click();
        }
      }

      function changeCity(e) {
        if (e==0) { e = 78 };
        for (var i = 0; i < cityArr.length; ++i) {
          if (cityArr[i][0]==e) {
            curCenter = [cityArr[i][1]/100000,cityArr[i][2]/100000]
          }
        };
        if (map) {
          map.setCenter(curCenter);
        };
      }
    </g:javascript>
    <g:setupObserve function='clickPaginate' id='list_view'/>        
  </head>
  <body onload="initialize()">
    <g:formRemote name="filterForm" url="[action:'search_table']" update="list_view"> 
      <div class="slider_content">
        <ul id="slider_values">
          <li>Возраст:&nbsp;&nbsp;</li>
          <li id="slider_user_min"></li>
          <li style="color:#009bff">-</li>
          <li id="slider_user_max"></li>
        </ul>
        <div id="slider-range" name="slider-range" class="ui-slider ui-slider-horizontal ui-widget ui-widget-content ui-corner-all">
          <div id="slider_span" class="ui-slider-range ui-widget-header ui-corner-all" style="left: 0%; width: 100%;"></div>
          <a class="ui-slider-handle ui-state-default ui-corner-all" href="javascript:void(0);" style="left:0%;"></a>
          <a class="ui-slider-handle ui-state-default ui-corner-all" href="javascript:void(0);" style="left:100%;"></a>
        </div>        
        <div style="margin-top:25px">
          <span class="select">
          <g:if test="${user}">  
            <label for="remote">Расстояние</label>
            <select name="remote" onchange="$('submit_button').click();">
              <option value="0" <g:if test="${lastsearch?.remote==0}">selected="selected"</g:if>>любое</option>
            <g:each in="${remote}" var="item">
              <option value="${item?.dist}" <g:if test="${lastsearch?.remote==item?.dist}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
          </g:if><g:else>
            <label for="city_id">Город</label>
            <select name="city_id" onchange="$('submit_button').click();changeCity(this.value);">
              <option value="0" <g:if test="${inrequest?.city_id==0}">selected="selected"</g:if>>любой</option>
            <g:each in="${city}" var="item">  
              <option value="${item?.id}" <g:if test="${inrequest?.city_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
          </g:else>
          </span>
          <span class="select">          
            <label for="gender_id">Пол</label>
            <select name="gender_id" onchange="$('submit_button').click();">
              <option value="0" <g:if test="${lastsearch?.gender_id==0||inrequest?.gender_id==0}">selected="selected"</g:if>>любой</option>
              <option value="1" <g:if test="${lastsearch?.gender_id==1||inrequest?.gender_id==1}">selected="selected"</g:if>>парень</option>
              <option value="2" <g:if test="${lastsearch?.gender_id==2||inrequest?.gender_id==2}">selected="selected"</g:if>>девушка</option>          
            </select>                      
          </span>          
        <g:if test="${user}">  
          <span class="select" style="margin-right:0px">          
            <label for="visibility_id">Статус</label>
            <select name="visibility_id" onchange="$('submit_button').click();">
              <option value="-1" <g:if test="${lastsearch?.visibility_id==-1}">selected="selected"</g:if>>любой</option>
              <option value="1" <g:if test="${lastsearch?.visibility_id==1}">selected="selected"</g:if>>онлайн</option>
              <option value="0" <g:if test="${lastsearch?.visibility_id==0}">selected="selected"</g:if>>оффлайн</option>
            </select>                      
          </span>                    
        </g:if>
        </div>
        <br/><br/>
        <div class="float" style="clear:left;margin-top:${user?'40':'15'}px">
          <input type="submit" id="submit_button" value="Найти кто близко!" style="float:left"/>
          <input type="button" id="view_button" class="link" value="Смотреть на карте" onclick="toggleView()" />
        </div>
      </div>
      <input type="hidden" id="age_min" name="age_min" value="0"/>
      <input type="hidden" id="age_max" name="age_max" value="0"/>
      <input type="hidden" id="hotlink" name="hotlink" value="0"/>
      <input type="hidden" id="view" name="view" value="${inrequest?.view?:'list'}"/>
      <input type="hidden" id="xl" name="xl" value="0"/>
      <input type="hidden" id="yl" name="yl" value="0"/>
      <input type="hidden" id="xr" name="xr" value="0"/>
      <input type="hidden" id="yr" name="yr" value="0"/>
  
      <ul class="hotlinks clearfix" style="margin-top:${user?'70':'12'}px" align="right">
        <li class="selected"><a href="javascript:void(0)" onclick="$('hotlink').value=0;$('submit_button').click();">Все</a></li>
      <g:if test="${user}">  
        <li><a href="javascript:void(0)" onclick="$('hotlink').value=1;$('submit_button').click();">Мои друзья</a></li>
      </g:if>        
        <li><a href="javascript:void(0)" onclick="$('hotlink').value=2;$('submit_button').click();">Новые лица</a></li>
        <li><a href="javascript:void(0)" onclick="$('hotlink').value=3;$('submit_button').click();">Популярные</a></li>
      </ul>
      <div class="list_view" style="margin-bottom:35px;${user?'margin-left:-230px;border-top-left-radius:5px':''}">            
        <g:if test="${user}">  
        <div class="select" style="margin:0 0 -20px 0;float:right">
          <label for="sort">Сортировать по</label>
          <select name="sort" onchange="$('submit_button').click();">
            <option value="0" <g:if test="${lastsearch?.sort==0}">selected="selected"</g:if>>по умолчанию</option>
            <option value="1" <g:if test="${lastsearch?.sort==1}">selected="selected"</g:if>>дате посещения</option>
            <option value="2" <g:if test="${lastsearch?.sort==2}">selected="selected"</g:if>>расстоянию</option>
            <option value="3" <g:if test="${lastsearch?.sort==3}">selected="selected"</g:if>>степени близости</option>
            <option value="4" <g:if test="${lastsearch?.sort==4}">selected="selected"</g:if>>имени</option>
            <option value="5" <g:if test="${lastsearch?.sort==5}">selected="selected"</g:if>>дате добавления в друзья</option>
          </select>    
        </div>
        </g:if>
      </g:formRemote>
      <div id="list_view">
      </div>
      <div id="map_view" style="clear:both">
        <div id="map_container" style="visibility:hidden;width:${user?'765':'535'}px"></div>
      </div>
    </div>
    <div id="tofriend_lbox" class="new-modal" style="display:none">
      <h2 class="blue clearfix">Укажите причину добавления в друзья:</h2>
      <div id="tofriend_lbox_segment" class="segment nopadding">
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
      <input type="submit" id="relationship_submit_button" style="display:none" value="" />
    </g:formRemote>
  </body>
</html>
