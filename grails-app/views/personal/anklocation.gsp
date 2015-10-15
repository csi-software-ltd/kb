<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>    
    <title>${infotext.title?infotext.title:''}</title>  
    <meta name="layout" content="main"/>    
    <g:javascript>
    var geoCenterSPB_X = 3031579,
        geoCenterSPB_Y = 5993904,
        iScale=${inrequest?.x?13:10};    
        
    var sIconCont = '<img width="30" height="30" border="0" src="';                    
    <g:if test="${user?.picture}">
      sIconCont += '${(user?.is_local?imageurl:'') + user?.ultrasmallpicture}" />';
    </g:if><g:else>
      sIconCont += '${resource(dir:'images',file:'user-default-picture.png')}" />';
    </g:else>    

    iyX=${inrequest?.x?inrequest?.x/100000:City.get(inrequest?.city_id?:0)?.x?City.get(inrequest?.city_id?:0).x/100000:30.313622};
    iyY=${inrequest?.y?inrequest?.y/100000:City.get(inrequest?.city_id?:0)?.y?City.get(inrequest?.city_id?:0).y/100000:59.937720};
    
    var myPlacemark={};
    
    function initialize(){      
      Yandex();
    }

    function openPlace(lId){
      if (lId==2) {
        j('#placeName').animate({opacity: "show"}, 1200);
        j('#place_id').animate({opacity: "show"}, 1200);
      } else {
        j('#placeName').animate({opacity: "hide"}, 1200);
        j('#place_id').animate({opacity: "hide"}, 1200);
        resetPlace();
        if (lId==0) {
          getAnkLocation();
        } else{
          watchAnkLocation();
        };
      };
    }

    function updateMetro(lCityId){
      ${remoteFunction(controller:'personal', action:'metroupd',
                       update:'metro_UPD',
                       params:'\'cityId=\'+lCityId'
      )};
    }

    function getPlaceData(lId){
      if (lId!=0) {
        ${remoteFunction(controller:'personal', action:'getPlaceData',
                       params:'\'id=\'+lId',
                       onSuccess:"processResponsePlaceData(e)"
        )};
      } else{
        resetPlace();
      }
    }

    function resetPlace(){
      j('#city_id').dropkick("setValue", 0);
      updateMetro(0);
      j('#plId').dropkick("setValue", 0);
      $('address').value = '';
      $('name').value = '';
    }

    function processResponsePlaceData(e){
      if (!e.responseJSON.error){
        iyY = e.responseJSON.data.y/100000;
        iyX = e.responseJSON.data.x/100000;
        if (myPlacemark){
          map.geoObjects.remove(myPlacemark);
          myPlacemark = new ymaps.Placemark([iyX, iyY], { iconContent: sIconCont }, { 
            draggable: true,    
            hideIconOnBalloonOpen: false,
            iconImageHref: "${resource(dir:'images',file:'placemark-my.png')}",
            iconImageSize: [40, 58],
            iconOffset: [-11, -12]
          });
          myPlacemark.events.add("dragend", function(e){
            var x = myPlacemark.geometry.getCoordinates()[0]*100000;
            var y = myPlacemark.geometry.getCoordinates()[1]*100000;
            x = Math.round(x);
            y = Math.round(y);
            $('y').value = y;
            $('x').value = x;
          });
          map.geoObjects.add(myPlacemark);
          map.setCenter([iyX, iyY]);
        }
        $('y').value = e.responseJSON.data.y;
        $('x').value = e.responseJSON.data.x;
        $('address').value = e.responseJSON.data.address;
        $('name').value = e.responseJSON.data.name;
        j('#city_id').dropkick("setValue", e.responseJSON.data.city_id);
        for (var i=0; i<$('city_id').length;i++){
          if ($('city_id').options[i].value==e.responseJSON.data.city_id)
            $('city_id').options[i].selected = true;
        }
        ${remoteFunction(controller:'personal', action:'metroupd',
                       update:'metro_UPD',
                       params:"'cityId='+e.responseJSON.data.city_id+'&dValue='+e.responseJSON.data.metro_id"
        )}
      } else {
        alert('Ошибка');
      }
    }

    //map>>
    function Yandex(){
      ymaps.ready(function(){
        map = new ymaps.Map("map_container", 
          {center: [iyX, iyY], zoom: iScale, type: "yandex#map", behaviors: ["default","scrollZoom"] },
          {geoObjectHint: false}
        );
        map.controls.add("zoomControl").add("mapTools").add(
          new ymaps.control.TypeSelector(["yandex#map", "yandex#satellite", "yandex#hybrid", "yandex#publicMap"])
        );
        if (${inrequest?.geocodestatus==0})
          getAnkLocation();
        else if (${inrequest?.geocodestatus==1})
          watchAnkLocation();
          myPlacemark = new ymaps.Placemark([iyX, iyY], { iconContent: sIconCont }, { 
          draggable: true,    
          hideIconOnBalloonOpen: false,
          iconImageHref: "${resource(dir:'images',file:'placemark-my.png')}",
          iconImageSize: [40, 58],
          iconOffset: [-11, -12]
        });
        myPlacemark.events.add("dragend", function(e){
          var x = myPlacemark.geometry.getCoordinates()[0]*100000;
          var y = myPlacemark.geometry.getCoordinates()[1]*100000;
          x = Math.round(x);
          y = Math.round(y);
          $('y').value = y;
          $('x').value = x;
        });
        map.geoObjects.add(myPlacemark);
        map.setCenter([iyX, iyY]);
        map.events.add("click", function(e){
          map.geoObjects.remove(myPlacemark);
          myPlacemark = new ymaps.Placemark( e.get("coordPosition"), { iconContent: sIconCont }, {
            draggable: true,    
            hideIconOnBalloonOpen: false,
            iconImageHref: "${resource(dir:'images',file:'placemark-my.png')}",
            iconImageSize: [40, 58],          
            iconOffset: [-11, -12]
          });
          myPlacemark.events.add("dragend", function(e){
            var x = myPlacemark.geometry.getCoordinates()[0]*100000;
            var y = myPlacemark.geometry.getCoordinates()[1]*100000;
            x = Math.round(x);
            y = Math.round(y);
            $('y').value = y;
            $('x').value = x;
          });
          map.geoObjects.add(myPlacemark);
          var x = e.get("coordPosition")[0]*100000;
          var y = e.get("coordPosition")[1]*100000;
          x = Math.round(x);
          y = Math.round(y);
          $('y').value = y;
          $('x').value = x;
        });
      });
    }
    //map<<
    function showAddress(fulladdress){
      var myGeocoder = ymaps.geocode(fulladdress, {
        results: 1
      });
      myGeocoder.then(function(res){
        if(!res.geoObjects.get(0)){
          $('geocodererror').show();
        } else {
          $('geocodererror').hide();
          map.geoObjects.remove(myPlacemark);
          myPlacemark = new ymaps.Placemark( res.geoObjects.get(0).geometry.getCoordinates(), { iconContent: sIconCont }, { 
            draggable: true,
            hideIconOnBalloonOpen: false,
            iconImageHref: "${resource(dir:'images',file:'placemark-my.png')}",
            iconImageSize: [40, 58],
            iconOffset: [-11, -12]
          });
          myPlacemark.events.add("dragend", function(e) {
            var x = myPlacemark.geometry.getCoordinates()[0]*100000;
            var y = myPlacemark.geometry.getCoordinates()[1]*100000;
            x = Math.round(x);
            y = Math.round(y);
            $('y').value = y;
            $('x').value = x;
          });
          map.geoObjects.add(myPlacemark);
          map.setCenter(res.geoObjects.get(0).geometry.getCoordinates(), iScale, { checkZoomRange: true });
          var x = res.geoObjects.get(0).geometry.getCoordinates()[0]*100000;
          var y = res.geoObjects.get(0).geometry.getCoordinates()[1]*100000;
          x = Math.round(x);
          y = Math.round(y);
          $('y').value = y;
          $('x').value = x;
        }
      });
    }
    function getAnkLocation(){
      if(navigator.geolocation) {
        var timeoutVal = 120 * 1000; //watchPosition
        navigator.geolocation.getCurrentPosition(  
          displayAnkPosition,
          displayAnkError,
          { enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 }
        );
      } else {
        alert("Функция определения местоположения не поддерживается данным браузером");
      }
    }

    function displayAnkPosition(position) {
      $('y').value = Math.round(position.coords.latitude*100000);
      $('x').value = Math.round(position.coords.longitude*100000);
      map.geoObjects.remove(myPlacemark);
      myPlacemark = new ymaps.Placemark([position.coords.longitude, position.coords.latitude], { iconContent: sIconCont }, {
        draggable: true,    
        hideIconOnBalloonOpen: false,
        iconImageHref: "${resource(dir:'images',file:'placemark-my.png')}",
        iconImageSize: [40, 58],          
        iconOffset: [-11, -12]
      });
      myPlacemark.events.add("dragend", function(e) {
        var x = myPlacemark.geometry.getCoordinates()[0]*100000;
        var y = myPlacemark.geometry.getCoordinates()[1]*100000;
        x = Math.round(x);
        y = Math.round(y);
        $('y').value = y;
        $('x').value = x;
      });
      map.geoObjects.add(myPlacemark);
      map.setCenter(myPlacemark.geometry.getCoordinates());
      if(Math.round(position.coords.longitude*100000) == geoCenterSPB_X && Math.round(position.coords.latitude*100000) == geoCenterSPB_Y){
        if (confirm("${message(code:'anklocation.confirm.text')}")){
          j('#geocodestatus').dropkick("setValue", 2);
          $('geocodestatus').selectedIndex = 2;
          j('#placeName').animate({opacity: "show"}, 1200);
          j('#place_id').animate({opacity: "show"}, 1200);
          resetPlace();
        } else { $('submit_button').click(); }
      }
    }

    function displayAnkError(error) {
      var errors = {
        1: 'Нет прав доступа',
        2: 'Местоположение невозможно определить. Включите датчик определения местоположения',
        3: 'Таймаут соединения'
      };
      if (error.code!=1)
        alert("Ошибка: " + errors[error.code]);
    }

    function watchAnkLocation(){
      if(navigator.geolocation) {
        var timeoutVal = 120 * 1000; //watchPosition
        trackerId = navigator.geolocation.watchPosition(
          displayAnkPosition,
          displayAnkError,
          { enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 }
        );
      } else {
        alert("Функция определения местоположения не поддерживается вашим браузером");
      }
    }
    </g:javascript>
  </head>
  <body onload="initialize()">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    <div class="path">
    <g:each in="${regmenu}" var="item" status="i">
      <div class="${(item?.npage < infotext?.npage)?'passed':((item?.npage==infotext?.npage)?'current':'future')} triangle" style="z-index:${regmenu.size()-i};${(i==1)?'width:150px':''}"><p style="${(i==0)?'margin-left:10px':''}">${item?.shortname}</p></div>
    </g:each>
    </div>
    <div style="padding-top:5px;clear:left"/>
  <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
      <g:if test="${flash?.error == 1}"><li>Недостаточно данных для определения вашего местоположения. Включите датчик определения местоположения, либо укажите город или поставьте маркер на карте.</li></g:if>
      <g:if test="${flash?.error == 2}"><li>Ошибка БД. Попробуйте позже.</li></g:if>
      <g:if test="${flash?.error == 3}"><li>Вы не заполнили обязательное поле &laquo;Название&raquo;</li></g:if>
      <g:if test="${flash?.error == 4}"><li>Вы не заполнили обязательное поле &laquo;Город&raquo;</li></g:if>
    </ul>
  </div>
  </g:if>
    
    <div class="info">
      <g:form name="profileSettings" controller="personal" action="saveAnklocation">
        <fieldset class="noborder">
          <span class="select">
            <label for="geocodestatus">Мое местоположение</label>
            <select name="geocodestatus" id="geocodestatus" style="width: 70%" onchange="openPlace(this.value)">
              <option value="0" <g:if test="${inrequest?.geocodestatus==0}">selected="selected"</g:if>>определять автоматически</option>
              <option value="1" <g:if test="${inrequest?.geocodestatus==1}">selected="selected"</g:if>>отслеживать автоматически</option>
              <option value="2" <g:if test="${inrequest?.geocodestatus==2}">selected="selected"</g:if>>выбирать из "Моих мест"</option>
            </select>
          </span><br/>
          <span class="select" id="place_id" style="${inrequest?.geocodestatus!=2?'display:none':''}">
            <label for="place_id">Места</label>
            <select id="plId" name="place_id" onchange="getPlaceData(this.value)">
              <option value="0">новое</option>
            <g:each in="${places}" var="item">
              <option value="${item?.id}" <g:if test="${(item?.is_main==1)||(place_id==item?.id)}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
          </span><br/>
          <span class="select" id="placeName" style="${inrequest?.geocodestatus!=2?'display:none':''}">
            <label for="placeName">Название</label>
            <input type="text" id="name" name="name" value="${name?:''}"/>
          </span><br/>
          <span class="select">
            <label for="city_id">Город</label>
            <select id="city_id" name="city_id" onchange="updateMetro(this.value)">
              <option value="0" <g:if test="${inrequest?.city_id==0}">selected="selected"</g:if>>выберите город</option>
            <g:each in="${city}" var="item">
              <option value="${item?.id}" <g:if test="${inrequest?.city_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
          </span><br/>
          <span id="metro_UPD" class="select">
          <g:if test="${metro}">
            <label for="metro_id">Метро</label>
            <select name="metro_id" id="metro_id" style="width:260px">
              <option value="0" <g:if test="${inrequest?.metro_id==0}">selected="selected"</g:if>>Выберите метро</option>
            <g:each in="${metro}" var="item">
              <option value="${item?.id}" <g:if test="${inrequest?.metro_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
          </g:if>
          </span>
          <h3 class="blue" style="clear:left">Местоположение на карте</h3>
          <p>Для определения местоположения на карте введите адрес и нажмите &laquo;Найти адрес на карте&raquo;.<br/>
            Вы можете исправить указание местоположения на карте, изменив адрес и повторив поиск, либо перетащив маркер в нужное место.</p>					
          <label for="address">Адрес</label>
          <input type="text" id="address" name="address" value="${address?:''}" style="width: 100%"/>
          <div id="geocodererror" class="notice" style="display: none">
          	<p>Заданный адрес не найден.</p>
            <p>Укажите вручную ваше местоположение, щелкнув на карте в нужном месте мышью.</p>
            <p>Вы можете откорректировать местоположение, перетащив маркер мышью.</p>
          </div>
          <div class="clearfix">
            <input type="button" class="link" value="Найти адрес на карте >>" id="showaddressonmap" onclick="showAddress(document.profileSettings.address.value);" style="float:left"/>
            <input type="submit" id="submit_button" value="<g:message code='button.next' />" style="float:right" />
          </div>
          <div id="map_container" style="height:300px;margin-top:20px;"></div>
          <input type="hidden" id="x" name="x" value="${inrequest?.x}" />
          <input type="hidden" id="y" name="y" value="${inrequest?.y}" />          		  
        </fieldset>
      </g:form>
    </div>
  </body>
</html>
