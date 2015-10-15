<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext.title?infotext.title:''}</title>
    <link rel="stylesheet" type="text/css" href="${resource(dir:'css',file:'jRating.jquery.css')}" />
    <style type="text/css">
      .am-wrapper {float:left;position:relative;overflow:hidden;}
      .am-wrapper img {position:absolute;outline:none;}
    </style>
    <g:javascript library="jquery.montage.min"/>
    <meta name="layout" content="main" />
    <g:javascript>
      function initialize(){
        viewSmallMap();
        $('tenderPhotosFormSubmitButton').click();
      }
      var cnt = 0;
      var container  = imgs = totalImgs = null;
      function montImg(){
        if (!container) {
          container  = j('#am-container');
          imgs = container.find('img').hide();
          totalImgs = imgs.length;
        }
        ++cnt;
        if( cnt === totalImgs ) {
          cnt = 0;
          imgs.show();
          container.montage({
            alternateHeight : true,
            alternateHeightRange : {
              min : 100,
              max : 200
            },
            margin : 4,
            fillLastRow : true,
            minw : 80
          });
          container  = imgs = totalImgs = null;
          j('.am-wrapper').colorbox({
            rel:'am-wrapper',
            next:'',
            previous:'',
            loop: false,
            onLoad: function(){
              j('#cboxNext').show();
              j('#cboxPrevious').show();
            }
          });
        }
      }
    </g:javascript>
    <g:setupObserve function='clickPaginate' id='tenderPhotos'/>
  </head>
  <body onload="initialize();">
    <h1 class="blue">${infotext?.header?infotext.header:''}</h1>
    <div class="info">
      <fieldset>
        <legend>${tenderDetails.name}</legend>
        <h2 class="blue" style="text-align:center;">${tenderDetails.slogan}</h2>
        <b>${tenderDetails.info}</b>
      </fieldset>
    </div>
    <div class="user_list">
      <div class="select" style="margin:0 0 -45px 0;float:right">
        <label for="sort">Сортировать по</label>
        <select name="sort" onchange="$('t_sort').value=this.value;$('tenderPhotosFormSubmitButton').click();">
          <option value="0">случайный порядок</option>
          <option value="1">новые</option>
          <option value="2">лучшие</option>
        </select>
      </div>
      <div id="tenderPhotos" style="float:right;width:100%">
      </div>
      <g:formRemote name="tenderPhotosForm" url="[controller: 'index', action: 'tenderPhotos']" update="tenderPhotos">
        <input id="tenderPhotosFormSubmitButton" type="submit" style="display:none"/>
        <input type="hidden" id="t_sort" name="sort" value="0"/>
      </g:formRemote>
    </div>
  </body>
</html>
