<%@ page contentType="text/html;charset=UTF-8"%>
<g:javascript>
  $('thumbnail_'+${cur_main_photo_id}).addClassName('selected');
  $('thumbnail_'+${prev_main_photo_id}).removeClassName('selected');
  $('main_'+${cur_main_photo_id}).hide();
  $('main_'+${prev_main_photo_id}).show();
  $('delete_'+${cur_main_photo_id}).hide();
  $('delete_'+${prev_main_photo_id}).show();
  <g:if test="${user?.picture}">
    $('userpic_img').src="${user?.is_local?imageurl:''}${user?.picture}";
  </g:if>
  <g:else>
    $('userpic_img').src="${resource(dir:"images",file:"default-picture.png")}";
  </g:else>
</g:javascript>
<g:if test="${user?.picture}"><img src="${user?.is_local?imageurl:''}${user?.picture}" width="140" height="140"></g:if>
<g:else><img src="${resource(dir:'images',file:'default-picture.png')}" width="140" height="140"></g:else>
