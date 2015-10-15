<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'jRating.jquery.css')}" />
    <g:javascript library="jRating.jquery"/>
    <meta name="layout" content="main" />
    <g:javascript>
      var mdMap=null;
      var mdPlacemark = null;
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

      function toggleDesc(iId,sName){
        if($('desc_'+iId).style.display=='none'){
          j('#desc_'+iId).slideDown('slow');
          j(sName).removeClass(' down').addClass(' up');
        } else {
          j('#desc_'+iId).slideUp('slow');
          j(sName).removeClass(' up').addClass(' down');
        }
      }
      function renderMap(lX,lY){
        ymaps.ready(function(){
          if (!mdMap){
            mdMap = new ymaps.Map("md_container",
              {center: [lX/100000, lY/100000], zoom: 13, type: "yandex#map", behaviors: ["default","scrollZoom"]},
              {geoObjectHint: false}
            );
            mdMap.controls.add("zoomControl").add(
              new ymaps.control.TypeSelector(["yandex#map", "yandex#satellite", "yandex#hybrid", "yandex#publicMap"])
            );
          } else {
            mdMap.setCenter([lX/100000, lY/100000], 13, { checkZoomRange: true });
            mdMap.geoObjects.remove(mdPlacemark);
          }
          mdPlacemark = new ymaps.Placemark([lX/100000, lY/100000], {}, {
              iconImageHref: "${resource(dir:'images',file:'marker.png')}",
              iconImageSize: [11, 19],
              iconOffset: [5, 20],
              draggable: false
          });
          mdMap.geoObjects.add(mdPlacemark);
        });
      }
      function confirmMeeting(lId){
        ${remoteFunction(controller:'personal', action:'changeStatus',
                       params:"'id='+lId+'&status=1'",
                       onSuccess:"processResponseCM(e,lId)"
        )};
      }

      function declineMeeting(lId){
        ${remoteFunction(controller:'personal', action:'changeStatus',
                       params:"'id='+lId+'&status=-1'",
                       onSuccess:"processResponseDM(e,lId)"
        )};
      }

      function cancelMeeting(lId){
        ${remoteFunction(controller:'personal', action:'changeStatus',
                       params:"'id='+lId+'&status=-2'",
                       onSuccess:"processResponseDM(e,lId)"
        )};
      }

      function processResponseCM(e,lId){
        if (!e.responseJSON.error) {
          var el = j('#st_'+lId)
          j('#stbutton_'+lId).hide();
          el.removeClass('inactive');
          el.addClass('active');
          $('st_'+lId).innerHTML = 'подтверждена';
        };
      }

      function processResponseDM(e,lId){
        if (!e.responseJSON.error) {
          var el = j('#pagination label:first')[0];
          el.innerHTML = el.innerHTML.split('&nbsp;&nbsp;')[0]+'&nbsp;&nbsp;'+(parseInt(el.innerHTML.split('&nbsp;&nbsp;')[1])-1).toString();
          j('#meetli_'+lId).hide();
        };
      }
    </g:javascript>
    <g:setupObserve function='clickPaginate' id='meeting_list'/>
  </head>
  <body onload="initialize();">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>

    <ul class="hotlinks clearfix">
      <li class="selected">
        <g:remoteLink class="links meetingnext" action="meetingmenu" id="0" onComplete="j('#meetingMe a:first').click();" update="meeting_menu">Предстоящие</g:remoteLink>
      </li>
      <li>
        <g:remoteLink class="links meetingprev" action="meetingmenu" id="1" onComplete="j('#meetingMe a:first').click();" update="meeting_menu">Прошедшие</g:remoteLink>
      </li>
      <li>
        <g:remoteLink class="links meetingignore" action="meetingmenu" id="2" onComplete="j('#meetingMe a:first').click();" update="meeting_menu">Отклоненные</g:remoteLink>
      </li>
    </ul>
    
    <div class="list_view clearfix">
      <div id="meeting_menu">
      </div>
      <div id="meeting_list">
      </div>
    </div>

    <div id="mapdetail_lbox" class="new-modal" style="display:none">
      <h2 class="blue clearfix">Карта!(K.O.)</h2>
      <div id="mapdetail_lbox_segment" class="segment nopadding">
        <div id="mapdetail_lbox_container" class="lightbox_filter_container">
          <fieldset>
            <div id="md_view" style="clear:both">
              <div id="md_container" style="height:240px;width:530px;"></div>
            </div>
          </fieldset>
        </div>
      </div>
    </div>

    <div id="meeting_lbox" class="new-modal" style="width:585px;height:auto;display:none">
      <h2 class="blue clearfix">Назначить встречу:</h2>
      <div id="meeting_lbox_segment" class="segment nopadding">
        <div id="meeting_lbox_container" class="lightbox_filter_container">
          <div id="message_data"></div>
          <div id="meeting_error" class="notice" style="display:none">
            <span id="meeting_errorText"></span>
          </div>
          <fieldset>
            <g:formRemote name="meetingAddForms" url="[controller: 'personal', action: 'meetingAdd']" onSuccess="meetingAddResponse(e,\$('reassign_meeting_id').value,\$('reassign_tab_id').value)">
            <div id="meetingmap_view" style="display:none">
              <label for="geoAddress"><a href="javascript:void(0)" onclick="findMeetAdr($('geoAddress').value,$('meetId').value);">Найти</a> адрес:</label>
              <input type="text" id="geoAddress" value="" />
              <div id="meetingmap_container" style="visibility:hidden;width:530px;"></div>
            </div>
            <span class="select">
              <label for="meetname">Что:</label>
              <input type="text" name="meetname" id="meetname" maxlength="135" value="" />
            </span><br/>
            <div class="select" nowrap>
              <label for="meetwhere">Где:</label>
              <input type="text" name="meetwhere" maxlength="230" id="meetwhere" value="" />
              <input type="checkbox" name="mapwhere" id="mapwhere" value="0" onclick="togglemeetingMap($('meetId').value);" />
            </div><br/>
            <div class="select">
              <label for="datetime">Когда:</label>
              <span class="dpicker">
                <input type="text" name="datetime" id="datetime" style="width:155px" value="" />
                <img src="${resource(dir:'images',file:'calendar.png')}" border="0" />
              </span>
            </div><br/>
            <input type="hidden" id="reassign_interlocutor_id" name="interlocutor_id" value="" />
            <input type="hidden" id="reassign_tab_id" value="" />
            <input type="hidden" id="reassign_meeting_id" name="meeting_id" value="" />
            <input type="hidden" id="meetId" value="" />
            <input type="hidden" id="meetX" name="meetX" value="" />
            <input type="hidden" id="meetY" name="meetY" value="" />
            <input type="submit" id="meetingSubmitButton" style="display:none" value="${message(code:'button.add')}" />
            </g:formRemote>
          </fieldset>
        </div>
      </div>
      <div class="segment buttons">
        <input type="button" onclick="$('meetingSubmitButton').click();" value="${message(code:'button.add')}" />
      </div>
    </div>

  </body>
</html>
