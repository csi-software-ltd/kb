<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://ogp.me/ns/fb#">
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
    <meta name="google-site-verification" content="x-USxqApLraXncu7dG-DuvusdCeogJMyDxkW_sxa3Hw" />
    <meta name="yandex-verification" content="7c3954d394169393" />
    <meta name="cmsmagazine" content="55af4ed6d7e3fafc627c933de458fa04" />
    <meta name="robots" content="all" />
    <link rel="shortcut icon" href="${resource(dir:'images',file:'favicon.ico')}" type="image/x-icon" /> 
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'main.css')}" />
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'dropkick.css')}" />
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'prototype-ui.css')}" />
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'jquery-ui.css')}" />
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'qtip.css')}" />
    <g:javascript library="jquery-1.6.2" />    
    <g:javascript library="jquery.dropkick" />    
    <g:javascript library="jquery.colorbox" />
    <g:javascript library="jquery.qtip" />
    <g:javascript library="application" />
    <g:javascript library="prototype" />        
    <g:javascript library="prototype/effects" />
    <g:javascript library="prototype/controls" />    
    <g:javascript library="prototype/slider" />
  <g:if test="${actionName!='search'}">
    <g:javascript library="prototype/carousel" />
  </g:if>
<!--Датапикер-->
    <g:javascript library="jquery-ui.min"/>
    <g:javascript library="jquery-ui-timepicker-addon"/>
    <g:javascript library="jquery-ui-sliderAccess"/>
    <g:javascript library="jquery-ui-timepicker-ru"/>    
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'redmond.css')}" />
<!--Датапикер-->
    <!--script type="text/javascript" src="http://api-maps.yandex.ru/2.0/?coordorder=longlat&load=package.standard&wizard=constructor&lang=ru-RU"></script-->    
    <script type="text/javascript" src="http://api-maps.yandex.ru/2.0/?coordorder=longlat&load=package.full&wizard=constructor&lang=ru-RU"></script>    
  <g:if test="${!user}">                    
    <script src="http://userapi.com/js/api/openapi.js" type="text/javascript" charset="windows-1251"></script>
    <script src="//connect.facebook.net/ru_RU/all.js"></script>    
    <script src="http://platform.twitter.com/anywhere.js?id=${tw_api_key}&v=1" type="text/javascript"></script>
  </g:if>  
    <g:javascript>
      var iyX=${(user?.x)?(user?.x/100000):30.313622},
          iyY=${(user?.y)?(user?.y/100000):59.937720};     
      var map=small_map=null;
      var myPlacemarkSmall=null;
      var trackerId = 0;
      var apiX = null;
      var intervalID = null;
      var j=jQuery.noConflict();

      function srfr(){
        clearInterval(intervalID);
        intervalID = null;
      }

      function rfr(lId){
        intervalID = setInterval(function() { rfrAjax(lId) },${chat_refresh_delay}, lId);
      }

      function rfrAjax(lId){
        ${remoteFunction(controller:'personal', action:'chatUpd',
                         params:'\'id=\'+lId',
                         onSuccess:"processResponseRfr(e)"
        )};
      }

      function gNewAjax(lId){
        ${remoteFunction(controller:'personal', action:'watchNew',
                         params:'\'id=\'+lId',
                         onSuccess:"processResponseWth(e)"
        )};
      }

      function processResponseWth(e){
        if (!e.responseJSON.error) {
          var el = j('#chatmenu')[0];
          if (e.responseJSON.count) {
            el.innerHTML = el.innerHTML.split('[')[0]+' ['+e.responseJSON.count+']';
          } else {
            el.innerHTML = el.innerHTML.split('[')[0];
          }
          el = j('#meetmenu')[0];
          if (e.responseJSON.countM) {
            el.innerHTML = el.innerHTML.split('[')[0]+' ['+e.responseJSON.countM+']';
          } else {
            el.innerHTML = el.innerHTML.split('[')[0];
          }
        <g:if test="${controllerName=='personal' && actionName=='messages'}">
          if (nlist!=e.responseJSON.list || nld!=e.responseJSON.ld) {
            nlist = e.responseJSON.list;
            nld = e.responseJSON.ld;
            if (chtl) {
              var tmp = e.responseJSON.list.split(',')
              for (var i = 0; i < tmp.length; i++) {
                j('#sasdasdaxxzczx'+tmp[i]).filter(':not(.checked)').addClass('new');
              };
            } else {
              j('.hotlinks a:first').click();
            };
          };
        </g:if>
        }
      }
      function processResponseRfr(e){
        if (e.responseJSON) {
        } else {
          var nS = false;
          if (container[0].scrollTop+parseInt(container[0].style.height) == container[0].scrollHeight) {
            nS = true;
          };
          container.find('ul div.online:first').remove();
          container.find('ul').append(e.responseText);
          if (nS) {
            container[0].scrollTop = container[0].scrollHeight;
          };
        };
      }

      function getLocation(){
        if(navigator.geolocation) {
          var timeoutVal = 120 * 1000; //watchPosition
          navigator.geolocation.getCurrentPosition(  
            displayPosition,
            displayError,
            { enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 }
          );
        } else {
          alert("Функция определения местоположения не поддерживается вашим браузером");
        }
      }

      function displayPosition(position) {
        ${remoteFunction(controller:'index', action:'coordUpd',
                       params:"'x='+Math.round(position.coords.longitude*100000)+'&y='+Math.round(position.coords.latitude*100000)",
                       onSuccess:"processResponsePos(e)"
        )};
      }

      function processResponsePos(e){
        if (!e.responseJSON.error){
          iyY = e.responseJSON.y/100000;
          iyX = e.responseJSON.x/100000;
          if (myPlacemarkSmall){
            small_map.geoObjects.remove(myPlacemarkSmall);
            myPlacemarkSmall = new ymaps.Placemark([iyX, iyY], {}, {
              hideIconOnBalloonOpen: false,
              iconImageHref: "${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [11, 19],
              iconOffset: [5, 25]
            });
            small_map.geoObjects.add(myPlacemarkSmall);
            small_map.setCenter([iyX, iyY]);
          }
          if (myPlacemark){
            renderMyPlacemark(0);
          }
        }
      }

      function displayError(error) {
        var errors = {
          1: 'Нет прав доступа',
          2: 'Местоположение невозможно определить. Включите датчик определения местоположения',
          3: 'Таймаут соединения'
        };
        if (error.code!=1)
          alert("Ошибка: " + errors[error.code]);
      }

      function watchLocation(){
        if(navigator.geolocation) {
          var timeoutVal = 120 * 1000; //watchPosition
          trackerId = navigator.geolocation.watchPosition(
            displayPosition,
            displayError,
            { enableHighAccuracy: true, timeout: timeoutVal, maximumAge: 0 }
          );
        } else {
          alert("Функция определения местоположения не поддерживается вашим браузером");
        }
      }

      function stopTracking(){
        if (trackerId){
          navigator.geolocation.clearWatch(trackerId);
          trackerId = 0;
        }
      }

      function changeGeoStatus(lId,sName,checked){
        if (apiX)
          apiX.hide();
        ${remoteFunction(controller:'index', action:'geoStatusUpdate',
                       params:"'status='+lId",
                       onSuccess:"processResponseGeo(e)"
        )};
        $("location").innerHTML = sName;
        toggleChecked('mm_geo',checked);
      }
      
      function processResponseGeo(e){
        if (!e.responseJSON.error){
          stopTracking();
          if(e.responseJSON.geoSt==0){
            getLocation();
          } else if (e.responseJSON.geoSt==1){
            watchLocation();
          } else if(e.responseJSON.geoSt==2){
            iyY = e.responseJSON.y/100000;
            iyX = e.responseJSON.x/100000;
            if (myPlacemarkSmall){
              small_map.geoObjects.remove(myPlacemarkSmall);
              myPlacemarkSmall = new ymaps.Placemark([iyX, iyY], {}, {
                hideIconOnBalloonOpen: false,
                iconImageHref: "${resource(dir:'images',file:'marker.png')}",
                iconImageSize: [11, 19],
                iconOffset: [5, 25]
              });
              small_map.geoObjects.add(myPlacemarkSmall);
              small_map.setCenter([iyX, iyY]);
            }
            if (${controllerName=='personal' && actionName=='place'}) {
              if (myPlacemark){
                renderMyPlacemark(1);
              }
            }
            if (${controllerName=='index' && actionName=='search'}) {
              if (myMapSearchPlacemark){
                renderMyMapSearchPlacemark();
              }
            }
          }
        }
      }

      function updateUserStatus(sText){
        ${remoteFunction(controller:'index', action:'statusmessageUpdate',
                       params:"'message='+sText"
        )};
        $('status').update(sText?sText:'${message(code:'statusmessage.default')}');
        $('mm_status').hide();
      }      

      function ctrlEnt(e){
        var pK = e.which ? e.which : (window.event? window.event.keyCode : 0);
        if (pK == 10 || pK == 13 && e.ctrlKey)
          $('chat_submit_button').click();
      }

      j(document).ready(function(){
      <g:if test="${actionName!='search'&&tenderData?.records}">
        new UI.Carousel($("horizontal_carousel"), {previousButton: ".previous_button", nextButton: ".next_button"});
      </g:if>
        if (${user?1:0}) {
          setInterval(function() { gNewAjax(${user?.id?:0}) },${get_new_message_delay});
          try{
            document.attachEvent("onkeypress", ctrlEnt);
          } catch (e) {
            window.addEventListener('keypress', function (e) {ctrlEnt(e)},false);
          }
        };
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
        
        j('.main_wrapper').colorbox({
          onLoad: function(){          
            j('#cboxNext').show();
            j('#cboxPrevious').show();
          }
        });
        j('#vk_lbox_link').colorbox({
          inline: true, 
          href: '#vk_lbox',
          scrolling: false,
          onLoad: function(){
            j('#vk_lbox').show();          
          },
          onCleanup: function(){
            j('#vk_lbox').hide();            
          }        
        });      
        j('#tw_lbox_link').colorbox({
          inline: true, 
          href: '#tw_lbox',
          scrolling: false,
          onLoad: function(){
            j('#tw_lbox').show();          
          },
          onCleanup: function(){
            j('#tw_lbox').hide();            
          }        
        });
        
        j.fn.qtip.defaults.hide.delay = 3500;                  
        j('#sm_geo').qtip({      
          position: { my: 'top center', at: 'bottom center' },
          events: {
            show: function(event, api) {
              if (apiX)
                apiX.hide();
              apiX = api;
            }
          },
          style: { classes: 'ui-tooltip-shadow ui-tooltip-' + 'bootstrap' },
          content: { text: j('#mm_geo') }
        });        
        j('#sm_visibility').qtip({      
          position: { my: 'top center', at: 'bottom center' },
          events: {
            show: function(event, api) {
              if (apiX)
                apiX.hide();
              apiX = api;
            }
          },
          style: { classes: 'ui-tooltip-shadow ui-tooltip-' + 'bootstrap' },
          content: { text: j('#mm_visibility') }
        });                
      });

      function toggleChecked(sName, sNewChecked, tag) {
        tag = tag || 'li';
        j('#'+sName).find(tag).filter('.checked').removeClass('checked');
        j(sNewChecked).addClass('checked');
      }     
      
      function changeOnlineStatus(iStatus,checked){
        if (iStatus) {
          j('#mm_visibility').find('a').filter('.inactive').toggleClass('none inactive');
          j(checked).toggleClass('none active');
          $('visibility').className='status-icon active';
        } else {
          j('#mm_visibility').find('a').filter('.active').toggleClass('none active');
          j(checked).toggleClass('none inactive');
          $('visibility').className='status-icon inactive';
        };
        if (apiX)
          apiX.hide();
        ${remoteFunction(controller:'index', action:'onlineStatusUpdate',
                       params:"'status='+iStatus"
        )};
      }
      
      function viewSmallMap(){
        if(${user?1:0}){
          ymaps.ready(function(){          
            small_map = new ymaps.Map("small_map_container", 
              {center: [iyX, iyY], zoom: 11, type: "yandex#map", behaviors: [""]},
              {geoObjectHint: false}
            );
            if (${user?.geocodestatus==0})
              getLocation();
            else if (${user?.geocodestatus==1})
              watchLocation();
            myPlacemarkSmall = new ymaps.Placemark([iyX, iyY], {}, { 
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

      var container = null;
      var offsetChat = 0;
      var needOld = true;
      function getOldChats(lUid,lPos){
        if (offsetChat==10) {needOld=true;};
        if (needOld) {
          $('loader').show();
          ${remoteFunction(controller:'personal', action:'oldMessageDetails',
                         params:"'id='+lUid+'&offset='+offsetChat",
                         onSuccess:"processResponseOldChats(e,lPos)"
          )};
          offsetChat = offsetChat + 10;
          container[0].scrollTop = 1;
        };
      }

      function processResponseOldChats(e,lPos){
        if (e.responseText=='') needOld = false;
        container.find('ul').prepend(e.responseText);
        $('loader').hide();
        container[0].scrollTop = container[0].scrollHeight - lPos;
      }

      function openChat(){
        j('#chat_lbox_link').colorbox({
          inline: true,
          href: '#chat_lbox',
          scrolling: false,          
          onLoad: function(){
            j('#chat_lbox').show();
          },
          onCleanup: function(){
            srfr();
            j('#chat_lbox').hide();
          },
          onComplete: function(){
            var objDiv = j('#scrollarea');
            objDiv.scrollTop = objDiv.scrollHeight;
          }
        });
        j('#chat_lbox_link').click();
      }

      function newMessageResponse(e, iChatId){
        if (!e.responseJSON.error) {
          j('#sasdasdaxxzczx'+iChatId+' a:first').click();
        };
      }

      function meetingAddResponse(e,sId,sTab){
        sId = sId || '';
        sTab = sTab || '';
        if (e.responseJSON.error){
          if (e.responseJSON.errorprop){
            $('meeting_error').show();
            $('meeting_errorText').update(e.responseJSON.errorprop);
          }
          j.colorbox.resize();
        } else {
          if (sId!='') {
            j('#'+sTab+' a:first').click();
          };
          j.colorbox.close();
        }
      }
      var mMap = null;
      var meetPlacemark = null;
      function togglemeetingMap(sId){
        sId = sId || '';
        if($('meetingmap_container').style.visibility=='hidden'){
          $('meetingmap_view').show();
          $('meetingmap_container').setStyle({ visibility: 'visible', height: '240px' });
          if (!mMap) {
            viewMeetingMap();
          };
          j.colorbox.resize();
        }else{
          $('meetingmap_view').hide();
          $('meetingmap_container').setStyle({ visibility: 'hidden', height: '0px' });
          j.colorbox.resize();
        }
      }

      function viewMeetingMap(){
        ymaps.ready(function(){
          mMap = new ymaps.Map("meetingmap_container", 
            {center: [iyX, iyY], zoom: 13, type: "yandex#map", behaviors: ["default","scrollZoom"]}, 
            {geoObjectHint: false}
          );        
          mMap.controls.add("zoomControl").add("mapTools").add(
            new ymaps.control.TypeSelector(["yandex#map", "yandex#satellite", "yandex#hybrid", "yandex#publicMap"])
          );
          mMap.events.add("click", function(e){
            mMap.geoObjects.remove(meetPlacemark);
            meetPlacemark = new ymaps.Placemark( e.get("coordPosition"), {}, {
              iconImageHref: "${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [11, 19],
              iconOffset: [5, 20],
              draggable: true
            });
            meetPlacemark.events.add("dragend", function(e){
              var x = meetPlacemark.geometry.getCoordinates()[0]*100000;
              var y = meetPlacemark.geometry.getCoordinates()[1]*100000;
              x = Math.round(x);
              y = Math.round(y);
              $('meetY').value = y;
              $('meetX').value = x;
            });
            mMap.geoObjects.add(meetPlacemark);
            var x = e.get("coordPosition")[0]*100000;
            var y = e.get("coordPosition")[1]*100000;
            x = Math.round(x);
            y = Math.round(y);
            $('meetY').value = y;
            $('meetX').value = x;
          });
          meetPlacemark = new ymaps.Placemark([iyX, iyY], {}, { 
              iconImageHref: "${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [11, 19],
              iconOffset: [5, 20],
              draggable: true
          });
          meetPlacemark.events.add("dragend", function(e){
            var x = meetPlacemark.geometry.getCoordinates()[0]*100000;
            var y = meetPlacemark.geometry.getCoordinates()[1]*100000;
            x = Math.round(x);
            y = Math.round(y);
            $('meetY').value = y;
            $('meetX').value = x;
          });
          $('meetY').value = iyY;
          $('meetX').value = iyX;
          mMap.geoObjects.add(meetPlacemark);
        });
      }
      function findMeetAdr(address,lId){
        lId = lId || '';
        var myGeocoder = ymaps.geocode(address, {
          results: 1
        });
        myGeocoder.then(function(res){
          if(!res.geoObjects.get(0)){
            $('meeting_error').show();
            $('meeting_errorText').update(<g:rawHtml>"${message(code:'meetingAdd.geocode.error',args:[], default:'').toString()}"</g:rawHtml>);
            j.colorbox.resize();
          } else {
            $('meeting_error').hide();
            j.colorbox.resize();
            mMap.geoObjects.remove(meetPlacemark);
            meetPlacemark = new ymaps.Placemark(res.geoObjects.get(0).geometry.getCoordinates(), {}, {
              iconImageHref: "${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [11, 19],
              iconOffset: [5, 20],
              draggable: true
            });
            meetPlacemark.events.add("dragend", function(e) {
              var x = meetPlacemark.geometry.getCoordinates()[0]*100000;
              var y = meetPlacemark.geometry.getCoordinates()[1]*100000;
              x = Math.round(x);
              y = Math.round(y);
              $('meetY').value = y;
              $('meetX').value = x;
            });
            mMap.geoObjects.add(meetPlacemark);
            mMap.setCenter(res.geoObjects.get(0).geometry.getCoordinates(), 13, { checkZoomRange: true });
            var x = res.geoObjects.get(0).geometry.getCoordinates()[0]*100000;
            var y = res.geoObjects.get(0).geometry.getCoordinates()[1]*100000;
            x = Math.round(x);
            y = Math.round(y);
            $('meetY').value = y;
            $('meetX').value = x;
          }
        });
      }

      function ratingPhotoResponse(e,lId){
        if (!e.responseJSON.error){
          j('#ratingFormSet'+lId).animate({opacity: "hide"}, 1200, function() {
            if (e.responseJSON.rating) {
              j('#ratingSet'+lId+' h1:first').html(e.responseJSON.rating);
            };
            j('#ratingSet'+lId).animate({opacity: "show"}, 1200);
          });
        }
      }
      function reduceRating(lId){
        var el = j('#ratingFormSet'+lId+' input#ratingValue'+lId)
        var r = parseInt(el.val());
        if (r>1) {--r;};
        el.val(r);
        j('#ratingFormSet'+lId+' b:first').html(r);
      }
      function increaseRating(lId){
        var el = j('#ratingFormSet'+lId+' input#ratingValue'+lId)
        var r = parseInt(el.val());
        if (r<10) {++r;};
        el.val(r);
        j('#ratingFormSet'+lId+' b:first').html(r);
      }
      function newCommentsResponse(e){
        j('#scrollarea').find('ul').prepend(e.responseText);
      }
      function oldCommentsResponse(e){
        var el = j('#oldCommentsForm input:first');
        el.val(parseInt(el.val())+5);
        j('.seemore').remove();
        j('#scrollarea').find('ul').append(e.responseText);
      }
      function deleteComment(lId){
        j('#commli_'+lId).animate({opacity: "hide"}, 1200, function() {
          var el = j('#oldCommentsForm input:first');
          var r = parseInt(el.val());
          el.val(--r);
          ${remoteFunction(controller:'personal', action:'deleteComment',
                         params:"'id='+lId"
          )};
        });
      }

    <g:if test="${!user}">                
      function facebook(response) {
        if (response.authResponse) {
          FB.api('/me', function(response) {
            $("main_fb_id").value=response.id;
            $("main_fb_first_name").value=response.first_name;
            $("main_fb_last_name").value=response.last_name;
            $("main_fb_gender").value=response.gender;
            $("main_fb_email").value=response.email;
            $("main_fb_birthday").value=response.birthday;
            FB.api('/me/picture', function(response) {
              $("main_fb_pic").value=response.data.url;
              FB.api('/me/picture?type=large', function(response) {
                $("main_fb_photo").value=response.data.url;
                fbLoginClick();
              });
            });
          });
        }
      }
      function fbLoginClick() {
        $("main_Fb_submit_button").click();
      }
      function doFBlogin() {
        FB.login(facebook,{scope:'email,user_birthday'});
      }
      
      function doLogin() {
        VK.Auth.login(authInfo,2);      
      }
      function authInfo(response) {
        if (response.session) {
          VK.api('users.get',{uids:response.session.mid, fields:'uid,first_name,last_name,bdate,sex,photo_rec,photo_big,photo_medium_rec'}, function(data) {
            $("main_vk_id").value=data.response[0].uid;
            $("main_vk_first_name").value=data.response[0].first_name;
            $("main_vk_last_name").value=data.response[0].last_name;
            $("main_vk_gender").value=data.response[0].sex;
            $("main_vk_birthday").value=data.response[0].bdate;
            $("main_vk_small").value=data.response[0].photo_rec;
            $("main_vk_photo").value=data.response[0].photo_big;
            $("main_vk_pic").value=data.response[0].photo_medium_rec;
            $("main_Vk_submit_button").click();          
          });
        }
      }    
      function vkLoginResponse(e) {
        if (e.responseJSON.error){           
          if ($("main_vk_birthday").value=='undefined')
            $("vk_bd").show();
          if (e.responseJSON.message){
            $('vkLog_error').show();
            $('vkLog_errorText').update(e.responseJSON.message);
          }
          $("vk_lbox_link").click();        
        } else if(!e.responseJSON.ankcomplete) {
          location.assign("${context.is_dev?'/KB':''}/personal/anklocation/");
        } else {
          location.reload(true);
        }
      }
      function twLoginResponse(e) {
        if (e.responseJSON.error){
          if (e.responseJSON.message){
            $('twLog_error').show();
            $('twLog_errorText').update(e.responseJSON.message);
          }
          $("tw_lbox_link").click();
        } else if(!e.responseJSON.ankcomplete) {
          location.assign("${context.is_dev?'/KB':''}/personal/anklocation/");
        } else {
          location.reload(true);
        }
      }
      function fbLoginResponse(e) {
        if (!e.responseJSON.ankcomplete){
          location.assign("${context.is_dev?'/KB':''}/personal/anklocation/");
        } else {
          location.reload(true);
        }
      }
      function nextStepVK() {
        if ($("vk_bd").style.display!='none'){
          $("main_vk_birthday").value = $("vk_birthday_day").value+'.'+$("vk_birthday_month").value+'.'+$("vk_birthday_year").value;
        }
        $("main_vk_email").value = $("vk_email_t").value;
        $("main_Vk_submit_button").click();
      }
      function nextStepTW() {
        $("main_tw_birthday").value = $("tw_birthday_day").value+'.'+$("tw_birthday_month").value+'.'+$("tw_birthday_year").value;
        $("main_tw_email").value = $("tw_email_t").value;
        $("main_tw_gender").value = $("tw_gender_id").value;
        $("main_Tw_submit_button").click();
      }
      </g:if>            
    </g:javascript>
    <g:layoutHead />    
  </head>
  <body onload="${pageProperty(name:'body.onload')}">
    <div class="html">
      <div class="left">   
      <g:if test="${user}">
        <div class="usermenu" style="${(actionName=='search')?'padding-top:10px':''}">
        <g:if test="${actionName=='search'}">
          <span style="margin-left:-20px">
            <g:link controller="index" action="index" title="На главную"><img src="${resource(dir:'images',file:'logo2.png')}" alt="На главную" border="0" /></g:link>
          </span>  
        </g:if>                    
          <ul class="menu">
          <g:each in="${usermenu}" var="menu">
            <li class="${((controllerName==menu?.controller)&&(actionName==menu?.action))?'active':''}">
              <g:link elementId="${(menu.controller=='personal'&&menu.action=='messages')?'chatmenu':(menu.controller=='personal'&&menu.action=='meeting')?'meetmenu':''}" controller="${menu?.controller}" action="${menu?.action}">${menu?.shortname}${(menu.controller=='personal'&&menu.action=='messages'&&cntNew)?' ['+cntNew+']':''}${(menu.controller=='personal'&&menu.action=='meeting'&&cntMNew)?' ['+cntMNew+']':''}</g:link>
            </li>
          </g:each>
            <li><g:link controller="user" action="logout">Выход</g:link></li>
          </ul>          
        </div>
        <div class="center" align="center">        
        <g:if test="${actionName!='search'}">
          <div class="logo">
            <g:link controller="index" action="index" title="На главную"><img src="${resource(dir:'images',file:'logo2.png')}" alt="На главную" border="0" /></g:link>
          </div>  
        </g:if>
          <div class="user" style="margin-top:${(actionName=='search')?'32':((actionName=='view')?'10':'10')}px">
            <div class="userstatus" align="center">          
            <g:if test="${actionName!='view'}">
              <a class="visibility-status" id="sm_visibility" href="javascript:void(0)" alt="Изменить видимость">
                <span id="visibility" class="status-icon ${user?.onlinestatus?'active':'inactive'}"></span>
                <span class="status-icon dropdown"></span>              
              </a>
              <span class="username">${user?.nickname?:user?.firstname?:''}</span>           
              <div class="dropdown" id="mm_visibility" style="display:none">
                <span class="actions">
                  <span class="action_button nowrap">
                    <a class="icon ${user?.onlinestatus?'active':'none'}" href="javascript:void(0)" onclick="changeOnlineStatus(1,this);">видимый</a>
                  </span>
                  <span class="action_button nowrap">
                    <a class="icon ${user?.onlinestatus?'none':'inactive'}" href="javascript:void(0)" onclick="changeOnlineStatus(0,this);">невидимый</a>
                  </span>
                </span>
              </div>
            </g:if><g:else>
              <span class="visibility-status">
                <span class="status-icon ${detailonline?'active':'inactive'}" style="cursor:default"></span>
              </span>
              <span class="username">${detail?.nickname?:detail?.firstname?:''}</span>
            </g:else>
            </div>
          <g:if test="${actionName!='search'}">
            <br/><span class="bold">
              <g:if test="${actionName=='view'}">${detail?.age?:''}</g:if>
              <g:else>${user?.age?:''}</g:else>
            </span>
          </g:if>
          </div>
          <div id="small_map_view" class="map" style="${(user && ((actionName in ['anklocation','place'])||(actionName=='search')))?'margin-top:17px;height:160px;':''}">
            <div id="balloon" class="${!(user && ((actionName in ['anklocation','place'])||(actionName=='search')))?'open':''}">
            <g:if test="${actionName=='view' && detail?.picture}">            
              <img width="140" height="140" src="${detail?.is_local?imageurl:''}${detail?.picture}" />
            </g:if><g:elseif test="${actionName!='view' && user?.picture}">            
              <img width="140" height="140" id="userpic_img" src="${user?.is_local?imageurl:''}${user?.picture}" />
            </g:elseif><g:else>
              <img width="140" height="140" id="userpic_img" src="${resource(dir:'images',file:'user-default-picture.png')}" />
            </g:else>
            </div>
            <div id="small_map_container" style="visibility:${(user && ((actionName in ['anklocation','place'])||(actionName=='search')))?'hidden':'visible'}"></div>
          </div>
          <div class="useraddress">
          <g:if test="${actionName!='view'}">
            <a class="geo-location" id="sm_geo" href="javascript:void(0)">
              <span class="geo-icon geo-icon-on geo-icon-ok"></span>
              <b id="location">                
                ${(user?.geocodestatus==0)?message(code:'geostatus.message.getPosition'):(user?.geocodestatus==1)?message(code:'geostatus.message.watchPosition'):((Userplace.findByUser_idAndIs_main(user?.id,1)?.name)?:City.get(user?.city_id)?.name?:'')}
              </b>
              <span class="geo-dropdown-icon"></span>
            </a>
            <div class="dropdown" id="mm_geo" style="display:none">              
              <ul class="list-items">
                <li class="${(user?.geocodestatus==0)?'checked':''}" onclick="changeGeoStatus(-2,'Автоопределение',this);">
                  <a class="geo" href="javascript:void(0)"><span class="list-item-icon"> </span> Определять автоматически</a>
                </li>
                <li class="${(user?.geocodestatus==1)?'checked':''} separator" onclick="changeGeoStatus(-1,'Слежение',this);">
                  <a class="geo" href="javascript:void(0)"><span class="list-item-icon"> </span> Отслеживать автоматически</a>
                </li>
              <g:each in="${placelist}" var="place">
                <li class="${(user?.geocodestatus==2 && place?.is_main)?'checked':''}" onclick="changeGeoStatus(${place?.id},'${place?.name}',this);">
                  <a class="geo"  href="javascript:void(0)"><span class="list-item-icon"> </span> ${place?.name}</a>
                </li>
              </g:each>
              </ul>
            </div>    
          </g:if><g:elseif test="${actionName=='view' && detail?.city_id!=0}">
            <span class="geo-location">
              <span class="geo-icon geo-icon-on geo-icon-ok" style="cursor:default"></span>
              <b>${City.get(detail?.city_id)?.name?:''}</b>              
            </span>
          </g:elseif>
          </div>
          <div class="userstatus">
          <g:if test="${actionName!='view'}">
            <a class="status-message" id="sm_status" href="javascript:void(0)" alt="Изменить статусное сообщение" onclick="$('mm_status').show();$('mm_status_area').focus();">
              <span id="status">${user?.statusmessage?:message(code:'statusmessage.default')}</span>
            </a>            
            <div class="status-dropdown" id="mm_status" style="display:none">
              <input type="text" id="mm_status_area" value="${user?.statusmessage?:''}" name="status-message" maxlength="100" placeholder="статусное сообщение" onblur="updateUserStatus(this.value)">
            </div>            
          </g:if><g:else>
            <span class="status-message">
              <span id="status">${detail?.statusmessage?:message(code:'statusmessage.defaultforview',default:'')}</span>
            </span>
          </g:else>
          </div>
        </div>
      </g:if><g:else>
        <div class="logo padd">
          <g:link controller="index" action="index"><img src="${resource(dir:'images',file:'logo.png')}" alt="На главную" border="0" /></g:link>
        </div>        
        <div class="login">
          <h2>Авторизация</h2>
          <g:form name="auth" controller="user" action="login">
            <input type="text" name="user" value="" placeholder="email"/><br/>
            <input type="password" name="password" value="" placeholder="пароль"/><br/>
            <span id="captcha_label" height="20" style="${(session.user_enter_fail?:0)>user_max_enter_fail?'':'display: none;'}">
              Введите проверочный код:
            </span>
            <span id="captcha_log" style="${(session.user_enter_fail?:0)>user_max_enter_fail?'':'display: none;'}">
              <span width="20" valign="middle" id="captcha_picture"><jcaptcha:jpeg name="image" /></span>
              <span valign="middle">
                <input id="captcha_text" type="text" name="captcha" value="" style="width: 50px;"/>
              </span>
            </span>
            <div style="margin-top: 25px">
              <input type="submit" value="Войти" style="float:left"/>
              <input type="hidden" name="provider" value="ktoblizko"/>
              <input type="hidden" name="user_index" value="1"/>              
              <div class="social_login">
                <span>Войти при помощи:</span>
                <a class="social-link" id="fb_auth" href="javascript:void(0)" onclick="doFBlogin()">
                  <i class="social-icon fb"></i>
                </a>
                <a class="social-link" id="tw_auth" href="javascript:void(0)">
                  <i class="social-icon tw"></i>
                </a>                        
                <a class="social-link" id="vk_auth" href="javascript:void(0)" onclick="doLogin()">
                  <i class="social-icon vk"></i>
                </a>                                       
                <!--a class="social-link" id="ok_auth" href="javascript:void(0)" onclick="doOKLogin()">
                  <i class="social-icon ok"></i>
                </a-->                                        
              </div>              
            </div>
            <div style="clear:both;padding:15px 15px 40px 10px">
              <label for="remember" style="float:left"><input type="checkbox" checked name="remember" id="remember" value="1"/>Запомнить меня</label>
              <g:link controller="user" action="restore" style="margin-right:10px;float:right">Забыли пароль?</g:link>                      
            </div>            
            <input type="hidden" name="control" value="${controllerName}"/>
            <input type="hidden" name="act" value="${actionName}"/>
          <g:if test="${controllerName=='user' && actionName=='view'}">
            <input type="hidden" name="id" value="${detail?.id}"/>
          </g:if>
          </g:form>
        <g:if test="${!(controllerName=='user' && actionName=='reg')}">
          <h2>Впервые? Присоединяйтесь!</h2>
          <g:form name="reg" controller="user" action="reg">
            <input type="text" name="firstname" value="" placeholder="имя"/><br/>
            <input type="text" name="email" value="" placeholder="email"/><br/>
            <input type="password" name="passw" value="" placeholder="пароль"/><br/>
            <input type="hidden" name="control" value="${controllerName}"/>
            <input type="hidden" name="act" value="${actionName}"/>
          <g:if test="${controllerName=='user' && actionName=='view'}">
            <input type="hidden" name="id" value="${detail?.id}"/>
          </g:if>
            <div style="margin-top: 25px;">
              <input type="submit" value="Зарегистрироваться"/>
            </div>
          </g:form>
        </g:if>
        </div>        
      </g:else>
      <g:if test="${actionName!='search'&&tenderData?.records}">
        <div class="tender">
          <h2 class="blue" style="margin-left:15px">Конкурс</h2>
          <div id="horizontal_carousel">
            <div class="previous_button"></div>  
            <div class="container">
              <ul>
              <g:each in="${tenderData.records}">
                <li>                  
                  <a class="main_wrapper" href="${createLink(controller:'personal',action:'bigPhoto',id:it.img_id+'-'+it.user_id)}">
                    <img width="220" height="220" src="${it?.is_local?imageurl:''}${it?.picture}" border="0" />
                  </a>
                  <div class="username">
                    <a href="${createLink(controller:'user',action:'view',id:it.user_id)}">${it.nickname?:it.firstname}</a><br/>
                    <span style="font-size: 9pt;">${City.get(it.city_id?:78)}</span><br/>
                    <span class="bold">${it.age}</span>
                  </div>
                  <div class="rating">
                    <b>Рейтинг</b><br/><br/>
                    <span class="bold">${it.rating}</span>
                  </div>
                </li>
              </g:each>
              </ul>
            </div>
            <div class="next_button"></div>
          </div>
        </div>
      </g:if>
      </div>
      <div class="right">
        <div class="content">          
          <g:layoutBody />          
        </div>        
      </div>
    </div>  
    <div class="footer">
      <div class="copy">
        <span class="copyright">&copy; 2012 ООО &laquo;ФинИмп&raquo;</span>
        <img src="${resource(dir:'images',file:'logo2.png')}" width="80" alt="Кто близко?" border="0" />
      </div>
    <g:if test="${user}"> 
      <div class="counts">
        125 443 946<br/>
        <small>человек уже здесь</small><br/><br/>
        826 597<br/>
        <small>сейчас онлайн!</small>
      </div>
    </g:if>
      <div class="botmenu">
        <g:link controller="index" action="about">о проекте</g:link> &middot;
        <g:link controller="index" action="rules">правила сайта</g:link> &middot;
        <!--<g:link controller="index" action="contacts">контакты</g:link> &middot;-->
      <g:if test="${user}">        
        <g:each in="${usermenu}" var="menu" status="i">
          <g:link controller="${menu?.controller}" action="${menu?.action}">${menu?.shortname}</g:link> <g:if test="${i!=usermenu.size()-1}">&middot;</g:if>
        </g:each>
      </g:if>
      </div>
      <div class="col">
        <div class="developers">
          <img src="${resource(dir:'images',file:'design-logo.png')}" border="0" />
          <span class="copyright">
            Дизайн сайта<br/>студия а.кизяченко<br/>
            <a class="design" href="http://www.fntw.ru" rel="nofollow" target="_blank">www.fntw.ru</a>
          </span>
        </div>
        <div class="developers" style="margin-top:10px">
          <img src="${resource(dir:'images',file:'develop-logo.png')}" border="0" />
          <span class="copyright">
            Разработка сайта<br/>CSI Software<br/>
            <a href="http://www.trace.ru" target="_blank">www.trace.ru</a>                      
          </span>
        </div>                    
      </div>
    </div>  

    <div id="loader" style="position: absolute; top: 300px; left:700px; display: none; width: 16px; height: 16px;">
      <img src="${resource(dir:'images',file:'spinner.gif')}" border="0">
    </div>

    <g:formRemote name="mainFacebookloginForm" url="[controller: 'user', action: 'facebook']" onSuccess="fbLoginResponse(e)">
      <input type="hidden" id="main_fb_id" name="m_fb_id" value="0" />
      <input type="hidden" id="main_fb_first_name" name="fb_first_name" value="" />
      <input type="hidden" id="main_fb_last_name" name="fb_last_name" value="" />
      <input type="hidden" id="main_fb_gender" name="fb_gender" value="" />
      <input type="hidden" id="main_fb_email" name="fb_email" value="" />
      <input type="hidden" id="main_fb_birthday" name="fb_birthday" value="" />
      <input type="hidden" id="main_fb_pic" name="fb_pic" value="" />
      <input type="hidden" id="main_fb_photo" name="fb_photo" value="" />
      <input type="submit" id="main_Fb_submit_button" style="display:none" value="" />
    </g:formRemote>
    <g:formRemote name="mainVkloginForms" url="[controller: 'user', action: 'vk']" onSuccess="vkLoginResponse(e)">
      <input type="hidden" id="main_vk_id" name="vk_id" value="0" />
      <input type="hidden" id="main_vk_first_name" name="vk_first_name" value="" />
      <input type="hidden" id="main_vk_last_name" name="vk_last_name" value="" />
      <input type="hidden" id="main_vk_gender" name="vk_gender" value="" />
      <input type="hidden" id="main_vk_birthday" name="vk_birthday" value="" />
      <input type="hidden" id="main_vk_email" name="vk_email" value="" />
      <input type="hidden" id="main_vk_pic" name="vk_pic" value="" />
      <input type="hidden" id="main_vk_small" name="vk_small" value="" />
      <input type="hidden" id="main_vk_photo" name="vk_photo" value="" />
      <input type="submit" id="main_Vk_submit_button" style="display:none" value="" />
    </g:formRemote>
    <g:formRemote name="mainTwloginForms" url="[controller: 'user', action: 'twitter']" onSuccess="twLoginResponse(e)">
      <input type="hidden" id="main_tw_id" name="tw_id" value="0" />
      <input type="hidden" id="main_tw_first_name" name="tw_first_name" value="" />
      <input type="hidden" id="main_tw_gender" name="tw_gender" value="" />
      <input type="hidden" id="main_tw_birthday" name="tw_birthday" value="" />
      <input type="hidden" id="main_tw_email" name="tw_email" value="" />
      <input type="hidden" id="main_tw_pic" name="tw_pic" value="" />
      <input type="submit" id="main_Tw_submit_button" style="display:none" value="" />
    </g:formRemote>
    
    <a id="vk_lbox_link" style="display:none"></a> 
    <div id="vk_lbox" class="new-modal" style="display:none">
      <h2 class="blue clearfix">Для продолжения регистрации вам необходимо заполнить следующие поля:</h2>
      <div class="segment nopadding">
        <div id="vk_lbox_container" class="lightbox_filter_container">
          <div id="message_data"></div>         
          <div id="vkLog_error" class="notice" style="display:none">
            <span id="vkLog_errorText"></span>
          </div>                    
          <fieldset>
            <span class="select">
              <label for="vk_email_t">Email:</label>
              <input type="text" id="vk_email_t" value="" placeholder="email" />
            </span><br/>
            <div id="vk_bd" class="select" style="display:none">
              <label for="vk_birthday">Дата рождения:</label>
              <g:datePicker name="vk_birthday" precision="day" value="${new Date()}" years="${((new Date()).getYear()+1900-18)..1940}" />
            </div>
          </fieldset>          
        </div>
      </div>        
      <div class="segment buttons">  
        <input type="button" onclick="nextStepVK()" value="Продолжить" />
      </div>
    </div>              

    <a id="tw_lbox_link" style="display:none"></a> 
    <div id="tw_lbox" class="new-modal" style="display:none">
      <h2 class="blue clearfix">Для продолжения регистрации вам необходимо заполнить следующие поля:</h2>
      <div class="segment nopadding">
        <div id="tw_lbox_container" class="lightbox_filter_container">
          <div id="message_data"></div>         
          <div id="twLog_error" class="notice" style="display:none">
            <span id="twLog_errorText"></span>
          </div>          
          <fieldset>
            <span class="select">
              <label for="tw_email_t">Email:</label>
              <input type="text" id="tw_email_t" value="" placeholder="email" />
            </span><br/>
            <div class="select">
              <label for="tw_gender_id">Пол:</label>
              <select id="tw_gender_id" name="tw_gender_id">
                <option value="0">Выберите пол</option>
                <option value="1">Парень</option>
                <option value="2">Девушка</option>
              </select>
            </div><br/>
            <div id="tw_bd" class="select">
              <label for="tw_birthday">Дата рождения:</label>
              <g:datePicker name="tw_birthday" precision="day" value="${new Date()}" years="${((new Date()).getYear()+1900-18)..1940}" />
            </div>
          </fieldset>          
        </div>
      </div>        
      <div class="segment buttons">  
        <input type="button" onclick="nextStepTW()" value="Продолжить" />
      </div>
    </div>
    <g:javascript>    
      <g:if test="${!user}">                
        VK.init({ apiId: ${vk_api_key} });
        FB.init({ appId: ${fb_api_key}, status: true, cookie: true, xfbml: true, oauth: true });
        twttr.anywhere(function (T) {
          T.bind("authComplete", function (e, user) {
            $("main_tw_id").value=user.data('id');
            $("main_tw_first_name").value=user.data('name');
            $("main_tw_pic").value=user.data('profile_image_url');
            $("main_Tw_submit_button").click();
          });
          document.getElementById("tw_auth").onclick = function () {
            T.signIn();
          };
        });        
      </g:if>
<!-- Yandex.Metrika counter -->
      (function (d, w, c) {
        (w[c] = w[c] || []).push(function() {
          try {
            w.yaCounter18234016 = new Ya.Metrika({id:18234016, webvisor:true, clickmap:true,
              trackLinks:true, accurateTrackBounce:true, trackHash:true});
          } catch(e) { }
        });      
        var n = d.getElementsByTagName("script")[0],
          s = d.createElement("script"),
          f = function () { n.parentNode.insertBefore(s, n); };
        s.type = "text/javascript";
        s.async = true;
        s.src = (d.location.protocol == "https:" ? "https:" : "http:") + "//mc.yandex.ru/metrika/watch.js";
      
        if (w.opera == "[object Opera]") {
          d.addEventListener("DOMContentLoaded", f);
        } else { f(); }
      })(document, window, "yandex_metrika_callbacks");
<!-- /Yandex.Metrika counter -->        
    </g:javascript>
    <noscript><div><img src="//mc.yandex.ru/watch/18234016" style="position:absolute; left:-9999px;" alt="" /></div></noscript>
  </body>
</html>
