<%@ page contentType="text/html;charset=UTF-8" %>

<html>
  <head>
    <title>${infotext?.title?infotext.title:''}</title>    
    <meta name="layout" content="main" />    
    <g:javascript>      
      var oSlider={};
      function initialize(){
        if(${user?1:0})
          viewSmallMap();
        sliderf();        
      }

      function viewOnMap(){
        $('view').value = 'map';
        $('submit_button').click();
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
          }
        });
        $('slider_user_min').update('${lastsearch?.age_min?:inrequest?.age_min?:age_min}');
        var age_max=${lastsearch?.age_max?:inrequest?.age_max?:age_max};
      
        $('slider_user_max').update(''+age_max+'');
        $('age_min').value = ${lastsearch?.age_min?:inrequest?.age_min?:age_min};
        $('age_max').value = ${lastsearch?.age_max?:inrequest?.age_max?:age_max};      
      }
    </g:javascript>
  </head>
  <body onload="initialize()">
    <g:form name="filterForm" url="[action:'search']" method="post">
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
            <select name="remote">
              <option value="0" <g:if test="${lastsearch?.remote==0}">selected="selected"</g:if>>любое</option>
            <g:each in="${remote}" var="item">
              <option value="${item?.dist}" <g:if test="${lastsearch?.remote==item?.dist}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
          </g:if><g:else>
            <label for="city_id">Город</label>
            <select name="city_id">
              <option value="0" <g:if test="${inrequest?.city_id==0}">selected="selected"</g:if>>любой</option>
            <g:each in="${city}" var="item">  
              <option value="${item?.id}" <g:if test="${inrequest?.city_id==item?.id}">selected="selected"</g:if>>${item?.name}</option>
            </g:each>
            </select>
          </g:else>
          </span>
          <span class="select">          
            <label for="gender_id">Пол</label>
            <select name="gender_id">
              <option value="0" <g:if test="${lastsearch?.gender_id==0||inrequest?.gender_id==0}">selected="selected"</g:if>>любой</option>
              <option value="1" <g:if test="${lastsearch?.gender_id==1||inrequest?.gender_id==1}">selected="selected"</g:if>>парень</option>
              <option value="2" <g:if test="${lastsearch?.gender_id==2||inrequest?.gender_id==2}">selected="selected"</g:if>>девушка</option>          
            </select>                      
          </span>         
        <g:if test="${user}">  
          <span class="select" style="margin-right:0px">          
            <label for="visibility_id">Статус</label>
            <select name="visibility_id">
              <option value="-1" <g:if test="${lastsearch?.visibility_id==-1}">selected="selected"</g:if>>любой</option>
              <option value="1" <g:if test="${lastsearch?.visibility_id==1}">selected="selected"</g:if>>онлайн</option>
              <option value="0" <g:if test="${lastsearch?.visibility_id==0}">selected="selected"</g:if>>оффлайн</option>
            </select>                      
          </span>                    
        </g:if>
        </div>
        <br/><br/>
        <div style="float:left;clear:left;margin-top:35px">
          <input type="submit" id="submit_button" value="Найти кто близко!" style="float:left"/>
          <input type="button" id="view_button" class="link" value="Смотреть на карте" onclick="viewOnMap()" style="float:right" />
        </div>        
      </div>
      <input type="hidden" id="age_min" name="age_min" value="0"/>
      <input type="hidden" id="age_max" name="age_max" value="0"/>
      <input type="hidden" id="view" name="view" value="list"/>
      <input type="hidden" name="index" value="1"/>
    </g:form>
              
    <div class="user_list">
      <h2 class="blue">Популярные</h2>
      <ul class="photo">
      <g:each in="${records_top}" var="record">   
        <li>
          <g:if test="${record?.picture}">
            <img width="70" height="70" src="${record?.is_local?imageurl:''}${record?.smallpicture}" border="0" />
          </g:if><g:else>
            <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
          </g:else>
          <br/>
          <div class="username">
            <g:link controller="user" action="view" id="${record?.id}">${record?.nickname?:record?.firstname?:''}</g:link><br/>
            <g:each in="${city}" var="item"> 
              <g:if test="${record?.city_id==item?.id}">
                ${(item?.name=='Санкт-Петербург')?'Петербург':item?.name}
              </g:if>
            </g:each>
            <br/><span class="bold">${record?.age}</span>
          </div>
        </li>
      </g:each>
      </ul>
    </div>
    <div class="user_list">
      <h2 class="blue">Новые лица</h2>    
      <ul class="photo">
      <g:each in="${records_new}" var="record">   
        <li>
        <g:if test="${record?.picture}">
          <img width="70" height="70" src="${record?.is_local?imageurl:''}${record?.smallpicture}" border="0" />
        </g:if><g:else>
          <img width="70" height="70" src="${resource(dir:'images',file:'user-default-picture.png')}" border="0" />
        </g:else>
          <br/>
          <div class="username">
            <g:link controller="user" action="view" id="${record?.id}">${record?.nickname?:record?.firstname?:''}</g:link><br/>
            <g:each in="${city}" var="item"> 
              <g:if test="${record?.city_id==item?.id}">
                ${(item?.name=='Санкт-Петербург')?'Петербург':item?.name}
              </g:if>
            </g:each><br/>
            <span class="bold">${record?.age}</span>
          </div>
        </li>
      </g:each>
      </ul>
    </div>
    
  </body>
</html>
