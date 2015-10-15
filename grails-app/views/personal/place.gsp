<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>    
    <title>${infotext.title?infotext.title:''}</title>  
    <meta name="layout" content="main"/>
    <style type="text/css">      
      .list li p { padding-left: 7px; }
    </style>
    <g:javascript>
    var geoCenterSPB_X = 3031579,
        geoCenterSPB_Y = 5993904,
        iScale=${user?.x?11:10},
        sMainIconCont='<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="22" height="22" preserveAspectRatio="none" viewBox="-11 -11 22 22" style="position: absolute; left: -11px; top: -11px">'+
                  '  <defs/>'+
                  '  <g>'+
                  '    <circle cx="0" cy="0" r="10" fill="#ffffff" stroke="#ff0000" fill-opacity="1" style="stroke-width:2px" stroke-width="2" stroke-opacity="1"/>'+                  
                  '    <image x="-9" y="-8" width="17" height="17" xlink:href="${resource(dir:'images',file:'location.png')}" title="Текущее местоположение"/>'+
                  '  </g>'+
                  '</svg>',
        sIconCont='',
        sHighlightIconCont='';


    iyX=${user?.x?user?.x/100000:City.get(user?.city_id?:0)?.x?City.get(user?.city_id?:0).x/100000:30.313622};
    iyY=${user?.y?user?.y/100000:City.get(user?.city_id?:0)?.y?City.get(user?.city_id?:0).y/100000:59.937720};
    
    var myPlacemark={};
    var tmpPlacemark=highlightPlacemark={};
    var oPlacemark=null;
    var collection = null;
    var myLayout = null;

    function initialize(){      
      Yandex();
      $('placeForm_submit_button').click();
    }

    function setIconCont(iColor,sText){
        sText = sText || '+';
        sIconCont='<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="22" height="22" preserveAspectRatio="none" viewBox="-11 -11 22 22" style="position: absolute; left: -11px; top: -11px">'+
                  '  <defs/>'+
                  '  <g>'+
                  '    <circle cx="0" cy="0" r="10" fill="#'+((iColor)?'00B7FF':'ff0000')+'" stroke="#ffffff" fill-opacity="1" style="stroke-width:2px" stroke-width="2" stroke-opacity="1"/>'+
                  '    <text x="-6" y="'+((sText=='+')?'4':'5')+'" font-family="Arial" font-size="11" font-weight="bold" fill="#ffffff">'+((sText.length<2)?'&nbsp;':'')+sText+'</text>'+
                  '  </g>'+
                  '</svg>';
    }

    function setHighlightIconCont(sText){
        sText = sText || '+';
        sHighlightIconCont='<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="22" height="22" preserveAspectRatio="none" viewBox="-11 -11 22 22" style="position: absolute; left: -11px; top: -11px">'+
                  '  <defs/>'+
                  '  <g>'+
                  '    <circle cx="0" cy="0" r="10" fill="#00B7FF" stroke="#ff0000" fill-opacity="1" style="stroke-width:2px" stroke-width="2" stroke-opacity="1"/>'+
                  '    <text x="-6" y="'+((sText=='+')?'4':'5')+'" font-family="Arial" font-size="11" font-weight="bold" fill="#ffffff">'+((sText.length<2)?'&nbsp;':'')+sText+'</text>'+
                  '  </g>'+
                  '</svg>';
    }

    function deHighlightPlace(){
      map.geoObjects.remove(highlightPlacemark);
    }
    function highlightPlace(lIds,lId){
      var tmp = null
      collection.each(function (obj) {
        if(obj.ids == lIds) tmp = obj;
      });
      if(tmp) {
        setHighlightIconCont(tmp.id)
        highlightPlacemark = new ymaps.Placemark(tmp.geometry.getCoordinates(), {}, {
          iconContentLayout: ymaps.templateLayoutFactory.createClass(sHighlightIconCont),
          iconLayout: myLayout,
          draggable: false
        });
        map.geoObjects.add(highlightPlacemark);
      }
    }

    function newPlace(){
      jQuery('#addPlace').slideDown('slow');
      $('add_button').hide();
      iyX = map.getCenter()[0];
      iyY = map.getCenter()[1];
      setIconCont(0);
      tmpPlacemark = new ymaps.Placemark([iyX+0.01, iyY+0.01], {}, {
        iconContentLayout: ymaps.templateLayoutFactory.createClass(sIconCont),
        iconLayout: myLayout,
        draggable: true
      });
      tmpPlacemark.events.add("dragend", function(e){
        var x = tmpPlacemark.geometry.getCoordinates()[0]*100000;
        var y = tmpPlacemark.geometry.getCoordinates()[1]*100000;
        x = Math.round(x);
        y = Math.round(y);
        $('y').value = y;
        $('x').value = x;
      });
      map.geoObjects.add(tmpPlacemark);
      var x = (iyX+0.01)*100000;
      var y = (iyY+0.01)*100000;
      x = Math.round(x);
      y = Math.round(y);
      $('y').value = y;
      $('x').value = x;
    }
    function cancelPlace(){
      jQuery('#addPlace').slideUp('slow');
      $('add_button').show();
      map.geoObjects.remove(tmpPlacemark);
      if(oPlacemark){
        map.geoObjects.add(oPlacemark);
        collection.add(oPlacemark);
        oPlacemark = null;
      }
      $('y').value = 0;
      $('x').value = 0;
      $('place_id').value = 0;
    }
    function updateMetro(lCityId){
      ${remoteFunction(controller:'personal', action:'metroupd',
                       update:'metro_UPD',
                       params:'\'cityId=\'+lCityId'
      )};
    }

    //map>>
    function Yandex(){
      ymaps.ready(function(){
        myLayout = ymaps.templateLayoutFactory.createClass('$[[options.contentLayout]]');
        map = new ymaps.Map("map_container", 
          {center: [iyX, iyY], zoom: iScale, type: "yandex#map", behaviors: ["default","scrollZoom"] },
          {geoObjectHint: false}
        );
        map.controls.add("zoomControl").add("mapTools").add(
          new ymaps.control.TypeSelector(["yandex#map", "yandex#satellite", "yandex#hybrid", "yandex#publicMap"])
        );
        //setIconCont(1);
        if (${user?.geocodestatus==0})
          getLocation();
        else if (${user?.geocodestatus==1})
          watchLocation();
        else if (${user?.geocodestatus==2}) {
          myPlacemark = new ymaps.Placemark([iyX, iyY], {}, {
            iconContentLayout: ymaps.templateLayoutFactory.createClass(sIconCont),
            iconLayout: myLayout,
            draggable: false
          });
          map.geoObjects.add(myPlacemark);
        }
        collection = new ymaps.GeoObjectCollection();
      });
    }
    function renderMyPlacemark(bType){
      cancelPlace();
      map.geoObjects.remove(myPlacemark);
      if (bType==0) {
        myPlacemark = new ymaps.Placemark([iyX, iyY], {}, {
          iconContentLayout: ymaps.templateLayoutFactory.createClass(sMainIconCont),
          iconLayout: myLayout,
          draggable: false
        });
        map.geoObjects.add(myPlacemark);
      }
      $('placeForm_submit_button').click();
      map.setCenter([iyX, iyY]);
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
          var sText = tmpPlacemark.id || ''
          map.geoObjects.remove(tmpPlacemark);
          setIconCont(0,sText);
          tmpPlacemark = new ymaps.Placemark(res.geoObjects.get(0).geometry.getCoordinates(), {}, {
            iconContentLayout: ymaps.templateLayoutFactory.createClass(sIconCont),
            iconLayout: myLayout,
            draggable: true
          });
          tmpPlacemark.events.add("dragend", function(e) {
            var x = tmpPlacemark.geometry.getCoordinates()[0]*100000;
            var y = tmpPlacemark.geometry.getCoordinates()[1]*100000;
            x = Math.round(x);
            y = Math.round(y);
            $('y').value = y;
            $('x').value = x;
          });
          tmpPlacemark.id = sText;
          map.geoObjects.add(tmpPlacemark);
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

    function processResponse(e){
      if(e.responseJSON.error){
        $('placeadderror').show();
      }else{
        updateMMGeo();
        $('placeadderror').hide();
        $('placeForm_submit_button').click();
        $('reset_button').click();
      }
    }

    function addMarker(iX,iY,lId,lIds,bIsMain){
      lIds = lIds || 0;
      if(!bIsMain)
        setIconCont(lIds,lId);
      else
        sIconCont = sMainIconCont;
      tmpPlacemark = new ymaps.Placemark([iX/100000, iY/100000], {}, {
        iconContentLayout: ymaps.templateLayoutFactory.createClass(sIconCont),
        iconLayout: myLayout,
        draggable: false
      });
      if (!lIds)
        tmpPlacemark.options.set('draggable','true');
      tmpPlacemark.events.add("dragend", function(e) {
        var x = tmpPlacemark.geometry.getCoordinates()[0]*100000;
        var y = tmpPlacemark.geometry.getCoordinates()[1]*100000;
        x = Math.round(x);
        y = Math.round(y);
        $('y').value = y;
        $('x').value = x;
      });
      tmpPlacemark.ids = lIds;
      tmpPlacemark.id = lId;
      if (lIds)
        collection.add(tmpPlacemark);
      else
        map.geoObjects.add(tmpPlacemark);
    }

    function removeMarker(){
      collection.remove(tmpPlacemark);
      map.geoObjects.remove(tmpPlacemark);
    }

    function renderCollection(){
      map.geoObjects.add(collection);
    }

    function deletePlace(lId){
      if(confirm('Удалить?')){
        cancelPlace();
        ${remoteFunction(controller:'personal', action:'placedelete',
                       params:"'id='+lId",
                       onSuccess:"afterDelete(e)"
        )};
      }
    }

    function afterDelete(e){
      tmpPlacemark = {};
      collection.each(function (obj) {
        if(obj.ids == e.responseJSON.lIds) tmpPlacemark = obj;
      });
      removeMarker();
      updateMMGeo();
      $('placeForm_submit_button').click();
      if (e.responseJSON.is_main==1) {
        changeGeoStatus(-2,'Автоопределение');
      };
    }

    function updateMMGeo(){
      ${remoteFunction(controller:'personal', action:'mmGeoupd', update:'mm_geo')};
    }

    function setCenter(lIds){
      collection.each(function (obj) {
        if(obj.ids == lIds) map.setCenter(obj.geometry.getCoordinates());
      });
    }

    function edit(iX,iY,lIds,sName,lCId,lMId,sAdr,lId){
      if(!tmpPlacemark.ids) removeMarker();
      if(oPlacemark){
        map.geoObjects.add(oPlacemark);
        collection.add(oPlacemark);
        oPlacemark = null;
      }
      $('name').value=sName; 
      jQuery('#city_id').dropkick("setValue", lCId);
      ${remoteFunction(controller:'personal', action:'metroupd',
                       update:'metro_UPD',
                       params:"'cityId='+lCId+'&dValue='+lMId"
      )};
      $('y').value  = iY;
      $('x').value = iX;
      $('place_id').value = lIds;
      $('address').value = sAdr;
      collection.each(function (obj) {
        if(obj.ids == lIds) tmpPlacemark = obj;
      });
      oPlacemark = tmpPlacemark;
      removeMarker();
      jQuery('#addPlace').slideDown('slow');
      $('add_button').hide();
      addMarker(iX,iY,lId);
      map.setCenter([iX/100000, iY/100000]);
    }
    function removeAllMarkers(){
      map.geoObjects.remove(collection);
      collection.removeAll();
    }
    </g:javascript>
  </head>
  <body onload="initialize()">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
  <g:if test="${flash?.error}">
    <div class="notice">
      <ul>
        <g:if test="${flash?.error == 1}"><li>Недостаточно данных для определения вашего местоположения. Включите датчик определения местоположения, либо укажите город или поставьте маркер на карте.</li></g:if>
        <g:if test="${flash?.error == 2}"><li>Ошибка БД. Попробуйте позже.</li></g:if>
      </ul>
    </div>
  </g:if>
    
    <div class="info">
      <div id="addPlace" style="display:none">        
        <fieldset style="background:rgba(0,0,0,0.03)">
          <legend id="place">Добавление нового места</legend>
          <g:formRemote name="placeAddForm" url="[action:'savePlace']" method="post" onSuccess="processResponse(e)">
            <div class="notice" id="placeadderror" style="display: none;">
              Вы не заполнили обязательное поле &laquo;Название&raquo;
            </div>
            <div class="select">
              <label for="name">Название</label>
              <input type="text" id="name" name="name" value=""/>
            </div><br/>
            <div class="select">
              <label for="city_id">Город</label>
              <select id="city_id" name="city_id" style="width:140px" onchange="updateMetro(this.value)">
              <g:each in="${city}" var="item">
                <option value="${item?.id}" <g:if test="${user?.city_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
              </g:each>
              </select>
            </div><br/>          
            <div id="metro_UPD" class="select">
            <g:if test="${metro}">
              <label for="metro_id">Метро</label>
              <select name="metro_id" id="metro_id" style="width:260px">
                <option value="0">Выберите метро</option>
              <g:each in="${metro}" var="item">
                <option value="${item?.id}">${item?.name}</option>
              </g:each>
              </select>      
            </g:if>
            </div>
            <h3 class="blue" style="clear:left">Местоположение на карте</h2>
            <p>Для определения местоположения на карте введите адрес и нажмите &laquo;Найти адрес на карте&raquo;.<br/>
              Вы можете исправить указание местоположения на карте, изменив адрес и повторив поиск, либо перетащив маркер в нужное место.</p>					
            <label for="address">Адрес</label>
            <input type="text" id="address" name="address" style="width: 100%"/>          
            <div id="geocodererror" class="notice" style="display: none">
              <p>Заданный адрес не найден.</p>
              <p>Укажите вручную ваше местоположение, щелкнув на карте в нужном месте мышью.</p>
              <p>Вы можете откорректировать местоположение, перетащив маркер мышью.</p>
            </div>
            <div class="clearfix">
              <input type="button" class="link" value="Найти адрес на карте >>" id="showaddressonmap" onclick="showAddress(document.placeAddForm.address.value);" style="float:left"/>          
              <input type="reset" class="reset" id="reset_button" value="<g:message code='button.cancel' />" style="margin-left:10px;float:right" onclick="cancelPlace();"/>
              <input type="submit" id="submit_button" value="<g:message code='button.save' />" style="float:right" />
            </div>
            <input type="hidden" id="x" name="x" value="0" />
            <input type="hidden" id="y" name="y" value="0" />
            <input type="hidden" id="place_id" name="place_id" value="0">      
          </g:formRemote>
        </fieldset>
      </div>
      <fieldset class="noborder" style="border:none;margin-bottom:0px">
        <div id="map_container" style="height:300px"></div>
      </fieldset>          
      <div id="list_view">
      </div>
      <fieldset class="noborder" style="border:none">
        <input type="button" id="add_button" value="<g:message code='button.add' />" onclick="newPlace();$('place').update('Добавление нового места');javascript:scroll(0,0);"/>
      </fieldset>      
    </div>
    <g:formRemote name="placeForm" url="[action:'placelist']" update="list_view">
      <input type="submit" id="placeForm_submit_button" value="<g:message code='button.find' />" style="float:right;display:none" />
    </g:formRemote>
  </body>
</html>
