<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>
    <meta name="layout" content="main" />
    <g:javascript>
      var j = jQuery.noConflict();
      var nlist = '${nlist}';
      var nld = '${nld}';
      var chtl = 1;

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
      
      function opendetails(evt,lUid){
        var test=null;
        try {
          test = evt.element().href
        } catch (e) {//IE такой IE :(. Warning! Dirty hack below.
          test = evt.srcElement
          if (test instanceof HTMLLIElement)
            test = null;
        }

        if(test==null || test=="javascript:void(0)") {
          ${remoteFunction(controller:'personal', action:'getopenchats',
                         update:'openchats',
                         params:'\'UId=\'+lUid'
          )};
          j('.hotlinks').find('.selected').removeClass('selected');
          j('#detailLink').addClass('selected');
        }
      }

      function closeChat(lUid){
        ${remoteFunction(controller:'personal', action:'getopenchats',
                       update:'openchats',
                       params:"'UId='+lUid+'&bclose=1'"
        )};
      }
      function processResponseOpenchats(lId){
        $('detailLink').show();
        toggleDetail(1,lId);
      }

      function newMessageResponse(e, iChatId){
        if (!e.responseJSON.error) {
          j('#sasdasdaxxzczx'+iChatId+' a:first').click();
        };
      }

      function toggleDetail(lId,iChatId){
        iChatId = iChatId || 0
        chtl = lId;
        if (lId){
          j('#messages_view').hide();
          j('#messages_view').html('');
          mMap = null;
          j('#messageDetail_list').show();
          var tmp = nlist.split(',')
          for (var i = 0; i < tmp.length; i++) {
            j('#sasdasdaxxzczx'+tmp[i]).filter(':not(.checked)').addClass('new');
          };
          if (iChatId==0) {
            toggleChecked('openchats',j('#messageDetail_list span:first'),'span');
            j('#messageDetail_list span:first').removeClass('new');
            j('#messageDetail_list a:first').click();
          } else {
            toggleChecked('openchats',j('#sasdasdaxxzczx'+iChatId),'span');
            j('#sasdasdaxxzczx'+iChatId).removeClass('new');
            j('#sasdasdaxxzczx'+iChatId+' a:first').click();
          }
        } else {
          srfr();
          j('#messages_view').show();
          j('#messageDetail_list').hide();
          j('#messageDetail_view').hide();
          j('#messageDetail_view').html('');
          mMap = null;
          if (iChatId==1) {
            $('detailLink').hide();
            j('.hotlinks a:first').click();
          }
        }
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
          jQuery.colorbox.close();
          if(!e.responseJSON.bchats) $('detailLink').hide();
          j('.hotlinks a:first').click();
        }
      }
      function openFoeNote(lId){
        if (lId==0) {
          j('#tofoe_note_s').animate({opacity: "show"}, 1200);
          j.colorbox.resize();
        } else {
          j('#tofoe_note_s').animate({opacity: "hide"}, 1200, function() {j.colorbox.resize();});
          $("tofoe_note").value = '';
        };
      }
    </g:javascript>
    <g:setupObserve function='clickPaginate' id='messages_view'/>
  </head>
  <body onload="initialize();">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    
    <ul class="hotlinks">
      <li id="listLink" class="selected">
        <g:remoteLink class="links messages" action="messageList" after="toggleDetail(0)" update="messages_view">Диалоги</g:remoteLink>
      </li>
      <li id='detailLink' style="${openchats?'':'display:none'}">
        <a class="links dialogs" href="javascript:void(0)" onclick="closeChat(0)">Детали диалогов</a>
      </li>
    </ul>   

    <div class="list_view">
      <div id="messages_view">
      </div>
      <div id="messageDetail_list" style="display:none">
        <div id="openchats">
        <g:each in="${openchats}" var="chats" status="i">
          <span id="sasdasdaxxzczx${chats.id}" class="dialog dk_toggle">
            <g:remoteLink action="messageDetails" id="${chats.id}" update="messageDetail_view">${chats.name}</g:remoteLink>
            <span class="action_button i">
              <a class="icon delete" title="Удалить" href="javascript:void(0)" onclick="closeChat(${chats.id})"></a>
            </span>
            <span class="action_button s">
              <a class="icon inactive" title="Новое сообщение"></a>
            </span>
          </span>
        </g:each>
        </div>
        <div id="messageDetail_view" style="display:none">
        </div>
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

    <g:formRemote name="relationshipForm" url="[controller: 'index', action: 'relationship']" onSuccess="relationshipResponse(e);">
      <input type="hidden" id="relationship_user_id" name="user_id" value="" />
      <input type="hidden" id="relationship_relnote_id" name="relnote_id" value="" />
      <input type="hidden" id="relationship_note" name="note" value="" />
      <input type="hidden" id="relationship_mark" name="mark" value="" />
      <input type="submit" id="relationship_submit_button" style="display:none" value="" />
    </g:formRemote>

  </body>
</html>
