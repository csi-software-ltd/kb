import java.awt.Image 
import java.awt.image.BufferedImage      
import javax.swing.ImageIcon 
import javax.imageio.ImageIO as IIO  
import javax.imageio.metadata.IIOMetadata
import java.awt.Graphics2D
import javax.imageio.stream.*
import javax.imageio.ImageReader
import org.springframework.context.*
import java.awt.geom.*
import java.awt.Color

class ImageService implements ApplicationContextAware {
  ApplicationContext applicationContext
  
  boolean transactional = false
  static final THUMBPREFIX='t_'
  static final SMALLTHUMBPREFIX='m_'
  static final ORIGPREFIX='o_'
  static scope = "request"

  def transient m_oController=null
  def transient m_sPathRes
  def transient m_sSessionName
  def transient m_sSessionKeepName
  def transient m_sDirMark
  def transient m_sAlpha
  def transient m_sMask
  def transient m_bFolder
  
  /////////////////////////////////////////////////////////////////////////////////////////  
  private checkInit(){
    if(m_oController==null)
      log.debug("Does not set controller object in ImageService. Call imageService.init(this,....")
    return (m_oController==null)
  }
    
  /////////////////////////////////////////////////////////////////////////////////////////
  def init(oController,sSessionName, sSessionKeepName,sPathRes,sDirMark='',sAlpha='',sMask='', bFolder = false){ //!
    m_oController=oController
    m_sPathRes=sPathRes
    m_sSessionName=sSessionName
    m_sSessionKeepName=sSessionKeepName
    m_sDirMark=sDirMark
    m_sAlpha=sAlpha
    m_sMask=sMask
	m_bFolder=bFolder
        
    if(m_sPathRes[-1]!=File.separatorChar)
      m_sPathRes+=File.separatorChar
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  private getSizes1(iSize, iImageWidth,iImageHeight,iMaxHeight = 0, forThumb = false){  
    int iWidth = iSize;  
    int iHeight = iSize;  
    int iTempWidth;
    int iTempHeight;
    
    if (iMaxHeight){
	  def fM
	  if (forThumb) fM = Math.max(iSize/iImageWidth, iMaxHeight/iImageHeight)
      else fM = Math.min(iSize/iImageWidth, iMaxHeight/iImageHeight)
      if (fM > 1) return [height:iImageHeight,width:iImageWidth]
      else{
        iTempHeight = (int)(fM*iImageHeight)
        iTempWidth = (int)(fM*iImageWidth)
        return [height:iTempHeight,width:iTempWidth]
      }
    }
    if (iImageWidth > iImageHeight) {  
      iTempWidth = iWidth;  
      iTempHeight = (int)(((double)iImageHeight*iWidth) / iImageWidth);  
    }else {  
      iTempHeight = iHeight ;  
      iTempWidth = (int)(((double)iImageWidth*iHeight ) / iImageHeight);  
    }
    return [height:iTempHeight,width:iTempWidth]
  }
  private getSizes(iSize, iImageWidth,iImageHeight,iMaxHeight = 0, forThumb = true){  
    int iWidth = iSize;  
    int iHeight = iSize;  
    int iTempWidth;
    int iTempHeight;
    
    if (iMaxHeight){
      def fM
      if (forThumb) fM = Math.max(iSize/iImageWidth, iMaxHeight/iImageHeight)
      else fM = Math.min(iSize/iImageWidth, iMaxHeight/iImageHeight)
      if (fM > 1) return [height:iImageHeight,width:iImageWidth]
      else{
        iTempHeight = (int)(fM*iImageHeight)
        iTempWidth = (int)(fM*iImageWidth)
        return [height:iTempHeight,width:iTempWidth]
      }
    }
    if (iImageWidth > iImageHeight) {  
      iTempWidth = iWidth;  
      iTempHeight = (int)(((double)iImageHeight*iWidth) / iImageWidth);  
    }else {  
      iTempHeight = iHeight ;  
      iTempWidth = (int)(((double)iImageWidth*iHeight ) / iImageHeight);  
    }
    return [height:iTempHeight,width:iTempWidth]
  }
  /////////////////////////////////////////////////////////////////////////////////////////    
  def loadPicture(sName,iWeightLimit,iPictureSize,iThumbSize,bSaveThumb = true,bToSquare = false,iPictureHeight = 0, iThumbHeight = 0,bSquareOnlyThumb=false,bSaveThumpWithSize=false,iSmallThumbSize=0,iSmallThumbHeight = 0,bSaveSmallThumb = false,bSaveSmallThumpWithSize=false) { //!
    def hsRes=[filename:'',thufilename:'',error:1] // 1 - UNSPECIFIC ERROR
    if(checkInit()) 
      return hsRes
      
    def fileImage= m_oController.request.getFile(sName)   
    if(!fileImage) 
      return hsRes
      
    //FYI: fileImage.getStorageDescription() -- tmp upload dir
    def sOrignalName
    def sContentType
    
    sOrignalName=fileImage.originalFilename      
    sContentType=fileImage.getContentType()
        
    def sExtention='jpg'
      
      //RESERVED
      if(sOrignalName==null){
        hsRes.error=2
        return hsRes 
      }
      //CHECK WEIGHT
      hsRes.maxweight = String.format('%4.1f',iWeightLimit/(1024*1024))
      if(fileImage.getSize()>iWeightLimit){
        hsRes.error=3
        return hsRes 
      }
      //CHECK CONTENT TYPE  //,"image/bmp","image/gif" - prohibited
      if(!(sContentType in ["image/pjpeg","image/jpeg","image/png","image/x-png"])){
        hsRes.error=4        
        return hsRes 
      }
      switch(sContentType){
        case "image/jpeg":
          sExtention='jpg'
          break          
        /*case "image/gif":
          sExtention='gif'
          break */
        case "image/png":
        case "image/x-png":
          sExtention='png'
          break
      }
      //GENERATE NAME 
	  def sPictureName=java.util.UUID.randomUUID().toString()+'.'+sExtention	  
      //MOVE
      def sPath=m_sPathRes+(m_bFolder?sPictureName[0..1]+File.separatorChar:'') 
    try{
      def d2= new File(sPath)
      d2.mkdirs()
	  
      fileImage.transferTo(new File(sPath+sPictureName))

      def oTempPic
      //DELETE PREV VERSION OF THAT PICTURES
      if(m_oController.session[m_sSessionName]==null)
        m_oController.session[m_sSessionName]=[:]
      
      if(m_oController.session[m_sSessionName][sName]!=null) {
        def sOldPic=m_oController.session[m_sSessionName][sName]
                
        if(!(sOldPic in m_oController.session[m_sSessionKeepName])){
          deletePictureFiles(sOldPic)
        }
      }
      
      m_oController.session[m_sSessionName][sName]=sPictureName
      //////////////////////////////////////////////
	  
      //RESIZE
      BufferedImage biTemp = javax.imageio.ImageIO.read(new File(sPath+sPictureName))
	  
      def iWidth=biTemp.getWidth(null)
      def iHeight=biTemp.getHeight(null)
      //  WRITE THUMBNAIL
      def hsSizes
      Image imTemp
      def imOut

      if (bSaveThumb){
        hsSizes=getSizes(iThumbSize,iWidth,iHeight,iThumbHeight, true)
        imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height,Image.SCALE_SMOOTH);  
        def x = 0
        def y = 0
        if (bToSquare 
		  || bSquareOnlyThumb){
          if (hsSizes.height > hsSizes.width){
            y = (int)((hsSizes.width - hsSizes.height)/2)
            hsSizes.height = hsSizes.width
          }else{
            x = (int)((hsSizes.height - hsSizes.width)/2)
            hsSizes.width = hsSizes.height
          }
        }
		if(bSaveThumpWithSize){		
		  if(hsSizes.height > hsSizes.width)
            y = (int)((hsSizes.width - hsSizes.height)/2)            
          else
            x = (int)((hsSizes.height - hsSizes.width)/2)                   		  
		  hsSizes.height=iThumbHeight
		  hsSizes.width=iThumbSize
		  if (y+imTemp.getHeight(null) < iThumbHeight) y=0
		  if (x+imTemp.getWidth(null) < iThumbSize) x=0
		}
        imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
        imOut.getGraphics().drawImage(imTemp, x, y, null);

        try {  
          javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+THUMBPREFIX+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+THUMBPREFIX+sPictureName+"\n"+e.toString())      
        }
      }
	  
	  //<<small thumb
	  if (bSaveSmallThumb){
        hsSizes=getSizes(iSmallThumbSize,iWidth,iHeight,iSmallThumbHeight, true)
        imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height,Image.SCALE_SMOOTH);  
        def x = 0
        def y = 0
        if (bToSquare 
		  || bSquareOnlyThumb){
          if (hsSizes.height > hsSizes.width){
            y = (int)((hsSizes.width - hsSizes.height)/2)
            hsSizes.height = hsSizes.width
          }else{
            x = (int)((hsSizes.height - hsSizes.width)/2)
            hsSizes.width = hsSizes.height
          }
        }
		if(bSaveSmallThumpWithSize){		
		  if(hsSizes.height > hsSizes.width)
            y = (int)((hsSizes.width - hsSizes.height)/2)            
          else
            x = (int)((hsSizes.height - hsSizes.width)/2)                   		  
		  hsSizes.height=iSmallThumbHeight
		  hsSizes.width=iSmallThumbSize
		  if (y+imTemp.getHeight(null) < iSmallThumbHeight) y=0
		  if (x+imTemp.getWidth(null) < iSmallThumbSize) x=0
		}
        imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
        imOut.getGraphics().drawImage(imTemp, x, y, null);

        try {  
          javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+SMALLTHUMBPREFIX+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+SMALLTHUMBPREFIX+sPictureName+"\n"+e.toString())      
        }
      }
	  //>>
	  

    //<<original picture
        hsSizes=getSizes(900,iWidth,iHeight,600, false)
        imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height,Image.SCALE_SMOOTH);  

        imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
        imOut.getGraphics().drawImage(imTemp, 0, 0, null);

        try {  
          javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+ORIGPREFIX+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+ORIGPREFIX+sPictureName+"\n"+e.toString())      
        }
    //>>

	  def bMarginFlag=false
	  def bResizeFlag=false
	  if(iWidth<iPictureSize
	    && iPictureHeight>iHeight){
	    bMarginFlag=true
	  }else{	   	    
	    def fProcent=iWidth/iHeight/0.014-100	  

	    if(!(-10<fProcent
		  && fProcent<10))
	      bMarginFlag=true

        //   RESIZE PICTURE	  
        if(bMarginFlag
		  ||(iWidth>iPictureSize)
		  ||(iHeight>iPictureSize)
		  ||bToSquare
		  ||(iPictureHeight
		  &&(iPictureHeight<iHeight))){	  
          if ((iWidth>iPictureSize)
		    ||(iHeight>iPictureSize)
			||(iPictureHeight
			&&(iPictureHeight<iHeight))){
            hsSizes=getSizes(iPictureSize,iWidth,iHeight,iPictureHeight)
            imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height, Image.SCALE_SMOOTH);  
          }else{
            hsSizes = [height:iHeight,width:iWidth]
            imTemp = biTemp
          }
          def x = 0
          def y = 0
          if (bToSquare){
            if (hsSizes.height > hsSizes.width){
              y = (int)((hsSizes.width - hsSizes.height)/2)
              hsSizes.height = hsSizes.width
            }else{
              x = (int)((hsSizes.height - hsSizes.width)/2)
              hsSizes.width = hsSizes.height
            }
          }
          bResizeFlag=true	    
          imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
          imOut.getGraphics().drawImage(imTemp, x, y, null);  
          try {  
            javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+sPictureName));  
          }catch (IOException e) {
            log.debug("Cannot write picture "+sPath+sPictureName+"\n"+e.toString())      
          }
        }  
	  }
	  
	  if(bMarginFlag){   
	    if(bResizeFlag){
		  iWidth=hsSizes.width
		  iHeight=hsSizes.height
		}
        def left=(iWidth<iPictureSize)?(iPictureSize-iWidth)/2:0
		def top=(iHeight<iPictureHeight)?(iPictureHeight-iHeight)/2:0
		def right=(iWidth<iPictureSize)?(iPictureSize-iWidth)/2:0
		def bottom=(iHeight<iPictureHeight)?(iPictureHeight-iHeight)/2:0
	    BufferedImage biTemp1 = javax.imageio.ImageIO.read(new File(sPath+sPictureName))	 
	    def imOut1 =parseAndMargin(biTemp1,left,top,right,bottom)
	    try {  
          javax.imageio.ImageIO.write(imOut1, sExtention, new File(sPath+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+sPictureName+"\n"+e.toString())      
        }
	  }	  
	 

      //ADD WATERMARK    
      if( (m_sAlpha!='')&&(m_sMask!='')&&(m_sDirMark!='')&&
          ((sExtention=='jpg')||(sExtention=='png'))    ){
        /*def sPathMark=grailsAttributes.getApplicationContext().getResource(
                      m_sDirMark).getFile().toString()+File.separatorChar*/
		def sPathMark= applicationContext.getResource(m_sDirMark).getFile().toString()+File.separatorChar
        def imageTool = new ImageTool()
        imageTool.load(sPath+sPictureName)        
        imageTool.loadAlpha(sPathMark+m_sAlpha)
        imageTool.loadMask(sPathMark+m_sMask)
        imageTool.applyMask()
        imageTool.writeResult(sPath+sPictureName, (sExtention=='jpg')?"JPEG":"PNG")
      }
      
      //PUT TEMPORARY FILES INTO QUEUE FOR DELETETION UNTIL USER DO NOT SAVE IT INTO DB      
      deletePictureFiles(sPictureName)
      
      hsRes.filename=(m_bFolder?sPictureName[0..1]+'/':'')+sPictureName
      hsRes.thumbname=(m_bFolder?sPictureName[0..1]+'/':'')+THUMBPREFIX+sPictureName
	  hsRes.smallthumbname=(m_bFolder?sPictureName[0..1]+'/':'')+SMALLTHUMBPREFIX+sPictureName
      hsRes.error=0
    }catch (javax.imageio.IIOException ie) {
      log.debug("Cannot read picture\n"+ie.toString())	  
      def destFile=new File(sPath+sPictureName)
      if(destFile.exists())
        destFile.delete()  
	  hsRes.error=5
    }catch (Exception e) {
      log.debug("Cannot save picture\n"+e.toString())
    }
  
    return hsRes
  }

  	  BufferedImage parseAndMargin(image,left,top,right,bottom) {
        def parsedLeft = parseValue(left,image.width,true,"0px");
        def parsedTop =  parseValue(top,image.height,true,parsedLeft);
        def parsedRight = parseValue(right,image.width,true,parsedLeft);
        def parsedBottom = parseValue(bottom,image.height,true,parsedTop);
        return margin(image,parsedLeft,parsedTop,parsedRight,parsedBottom);
    }
      BufferedImage margin(image,left,top,right,bottom) {
        def width = left + image.width + right;
        def height = top + image.height + bottom;
        def newImage = new BufferedImage(width.intValue(), height.intValue(),BufferedImage.TYPE_INT_RGB);//TYPE_INT_ARGB
        // createGraphics() needs a display, find workaround.
        def graph = newImage.createGraphics();
		//Color(int r, int g, int b) toDo config
		//graph.setBackground(new Color(68,68,68));
		graph.setBackground(new Color(255,255,255));
		graph.clearRect(0,0,width,height);		
        graph.drawImage(image,new AffineTransform(1.0d,0.0d,0.0d,1.0d,left,top),null);		
        return newImage;
    }
  /**
     * absolute true  -> returns pixels.
     *          false -> returns relative decimal (e.g 1.0).
     */
    Number parseValue(value,size,absolute,defaultValue="0") {
        def pattern = "(-?[0-9]+\\.?[0-9]*)(.*)";
        def matcher = value =~ pattern;
        if(!matcher.find()) {
            matcher = defaultValue =~ pattern;
            matcher.find();
        }

        def decimalValue = Double.parseDouble(matcher.group(1));
        def type = matcher.group(2);

        if(absolute) { // pixels
            switch(type)  {
                case "%":
                    return (int) size * (decimalValue / 100);
                case "px":
                default:
                return (int) decimalValue;
            }
        }
        else { // scale
            switch(type) {
                case "px":
                    return decimalValue / size;
                case "%":
                    return decimalValue / 100;
                default:
                    return decimalValue;
            }
        }
    }


  /////////////////////////////////////////////////////////////////////////////////////////
  def deletePicture(sName){ //!
    if(checkInit()) 
      return null
        
    if(m_oController.session[m_sSessionName]==null)
      m_oController.session[m_sSessionName]=[:]
    if(m_oController.session[m_sSessionName][sName]!=null) {
      def sOldPic=m_oController.session[m_sSessionName][sName]
      if(!(sOldPic in m_oController.session[m_sSessionKeepName]))
        deletePictureFiles(sOldPic)
    }
    m_oController.session[m_sSessionName][sName]=null
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  private deletePictureFiles(sMainName){
    def sPath=m_sPathRes+(m_bFolder?sMainName[0..1]+File.separatorChar:'')
    try{
      //DELETE via service
      def oTempPic=new Picturetemp([filename:sMainName,fullname:sPath+sMainName])
      oTempPic.save(flush:true)
      oTempPic=new Picturetemp([filename:THUMBPREFIX+sMainName,fullname:sPath+THUMBPREFIX+sMainName])
      oTempPic.save(flush:true)
	  oTempPic=new Picturetemp([filename:SMALLTHUMBPREFIX+sMainName,fullname:sPath+SMALLTHUMBPREFIX+sMainName])
      oTempPic.save(flush:true)
    }catch(Exception e){
      log.debug("Cannot put into Picturetemp table\n"+e.toString())
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  private clearPictureTmpDb(lsFiles){
    def oPicturetemp=new Picturetemp() 
    oPicturetemp.csiDeleteByFilenames(lsFiles)
  }
  /////////////////////////////////////////////////////////////////////////////////////////  
  private clearPictureSession(){
    m_oController.session[m_sSessionName]=[:]
    m_oController.session[m_sSessionKeepName]=[]
  }
  /////////////////////////////////////////////////////////////////////////////////////////  
  def getSessionPics(sName){ //!
    if(checkInit()) 
      return null
        
    if((m_oController.session[m_sSessionName]==null)||(m_oController.session[m_sSessionName][sName]==null)) 
      return null
    def sPic=m_oController.session[m_sSessionName][sName]
    def sPath=(m_bFolder?sPic[0..1]+'/':'')
    def hsRes=[:]
    hsRes['photo']=sPath+sPic
    hsRes['thumb']=sPath+THUMBPREFIX+sPic
	hsRes['smallthumb']=sPath+SMALLTHUMBPREFIX+sPic
    return hsRes 
  }
  /////////////////////////////////////////////////////////////////////////////////////////  
  private getSessionFileList(lsNames){
    def lsFiles=[]
    def sPic
    for(sName in lsNames) {
      if((m_oController.session[m_sSessionName]==null)||(m_oController.session[m_sSessionName][sName]==null)) 
        continue
      sPic=m_oController.session[m_sSessionName][sName]
      lsFiles<<sPic
      lsFiles<<THUMBPREFIX+sPic
	  lsFiles<<SMALLTHUMBPREFIX+sPic
    }
    return lsFiles 
  }
  /////////////////////////////////////////////////////////////////////////////////////////  
  private deleteOldPictureFiles(lsKeepFiles){
    def lsFiles=[]
    if(m_oController.session[m_sSessionKeepName]!=null){
      for(sFile in m_oController.session[m_sSessionKeepName])
        if(!(sFile in lsKeepFiles))
          lsFiles<<sFile
      deleteListPictureFiles(lsFiles)      
    }
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  private deleteListPictureFiles(lsFiles){
    for(sMainName in lsFiles)
      deletePictureFiles(sMainName)
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  def startFileSession(){ //!
    if(checkInit()) 
      return null
      
    if(m_oController.session[m_sSessionName]==null)
      m_oController.session[m_sSessionName]=[:]
    m_oController.session[m_sSessionKeepName]=[]
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  def putIntoSessionFromDb(sFileName,sName){ //!
    if(checkInit()) 
      return null
      
    if(sFileName==null)
      return
      
    def lsToc=sFileName.tokenize('/')
    if(lsToc.size()==0)
      return
      
    sFileName=(lsToc.size()>1)? lsToc[1] : lsToc[0] 
    m_oController.session[m_sSessionKeepName]<<sFileName
    if(m_oController.session[m_sSessionName][sName]==null)
      m_oController.session[m_sSessionName][sName]=sFileName
  }
  /////////////////////////////////////////////////////////////////////////////////////////  
  def finalizeFileSession(lsNames){ //!
    if(checkInit()) 
      return null

    def lsFiles=getSessionFileList(lsNames)
    //УДАЛЯЕМ СТАРЫЕ ФАЙЛЫ  ИСКЛЮЧАЯ ТЕ, КОТОРЫЕ ОСТАВЛЕНЫ В СЕССИИ
    deleteOldPictureFiles(lsFiles)
    //УДАЛЯЕМ СОХРАНЕННЫЕ В БД ФАЙЛЫ ИЗ СПИСКА НА УДАЛЕНИЕ
    clearPictureTmpDb(lsFiles)
    //ОЧИЩАЕМ СЕССИЮ    
    clearPictureSession()
  }
  /////////////////////////////////////////////////////////////////////////////////////////
  def deletePictureFilesFromHd(lsFiles){
    lsFiles.each{deletePictureFiles(it)}
  }
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
  def loadMultiplePicture(fileImage,iWeightLimit,iPictureSize,iThumbSize,bSaveThumb = true,bToSquare = false,iPictureHeight = 0, iThumbHeight = 0,bSquareOnlyThumb=false,bSaveThumpWithSize=false,iNo=1,iSmallThumbSize=0,iSmallThumbHeight = 0,bSaveSmallThumb = false,bSaveSmallThumpWithSize=false) { //!
    def hsRes=[filename:'',thufilename:'',error:1,num:iNo] // 1 - UNSPECIFIC ERROR
    if(checkInit()) 
      return hsRes
    def sName = 'file'
    ///def fileImage= m_oController.request.getFile(sName)   
    if(!fileImage) 
      return hsRes
      
    //FYI: fileImage.getStorageDescription() -- tmp upload dir
    def sOrignalName
    def sContentType
    
    sOrignalName=fileImage.originalFilename      
    sContentType=fileImage.getContentType()
        
    def sExtention='jpg'
      
      //RESERVED
      if(sOrignalName==null){
        hsRes.error=2
        return hsRes 
      }
      //CHECK WEIGHT
      hsRes.maxweight = String.format('%4.1f',iWeightLimit/(1024*1024))
      if(fileImage.getSize()>iWeightLimit){
        hsRes.error=3
        return hsRes 
      }
      //CHECK CONTENT TYPE  //,"image/bmp","image/gif" - prohibited
      if(!(sContentType in ["image/pjpeg","image/jpeg","image/png","image/x-png"])){
        hsRes.error=4        
        return hsRes 
      }
      switch(sContentType){
        case "image/jpeg":
          sExtention='jpg'
          break          
        /*case "image/gif":
          sExtention='gif'
          break */
        case "image/png":
        case "image/x-png":
          sExtention='png'
          break
      }
      //GENERATE NAME 
	  def sPictureName=java.util.UUID.randomUUID().toString()+'.'+sExtention	  
      //MOVE
      def sPath=m_sPathRes+(m_bFolder?sPictureName[0..1]+File.separatorChar:'') 
    try{
      def d2= new File(sPath)
      d2.mkdirs()
	  
      fileImage.transferTo(new File(sPath+sPictureName))

      def oTempPic
      //DELETE PREV VERSION OF THAT PICTURES
      if(m_oController.session[m_sSessionName]==null)
        m_oController.session[m_sSessionName]=[:]
      
      if(m_oController.session[m_sSessionName][sName+iNo]!=null) {
        def sOldPic=m_oController.session[m_sSessionName][sName+iNo]
                
        if(!(sOldPic in m_oController.session[m_sSessionKeepName])){
          deletePictureFiles(sOldPic)
        }
      }
      
      m_oController.session[m_sSessionName][sName+iNo]=sPictureName
      //////////////////////////////////////////////
	  
      //RESIZE
      BufferedImage biTemp = javax.imageio.ImageIO.read(new File(sPath+sPictureName))
	  
      def iWidth=biTemp.getWidth(null)
      def iHeight=biTemp.getHeight(null)
      //  WRITE THUMBNAIL
      def hsSizes
      Image imTemp
      def imOut

      if (bSaveThumb){
        hsSizes=getSizes(iThumbSize,iWidth,iHeight,iThumbHeight, true)
        imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height,Image.SCALE_SMOOTH);  
        def x = 0
        def y = 0
        if (bToSquare 
		  || bSquareOnlyThumb){
          if (hsSizes.height > hsSizes.width){
            y = (int)((hsSizes.width - hsSizes.height)/2)
            hsSizes.height = hsSizes.width
          }else{
            x = (int)((hsSizes.height - hsSizes.width)/2)
            hsSizes.width = hsSizes.height
          }
        }
		if(bSaveThumpWithSize){		
		  if(hsSizes.height > hsSizes.width)
            y = (int)((hsSizes.width - hsSizes.height)/2)            
          else
            x = (int)((hsSizes.height - hsSizes.width)/2)                   		  
		  hsSizes.height=iThumbHeight
		  hsSizes.width=iThumbSize
		  if (y+imTemp.getHeight(null) < iThumbHeight) y=0
		  if (x+imTemp.getWidth(null) < iThumbSize) x=0
		}
        imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
        imOut.getGraphics().drawImage(imTemp, x, y, null);

        try {  
          javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+THUMBPREFIX+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+THUMBPREFIX+sPictureName+"\n"+e.toString())      
        }
      }

	  //<<small thumb
	  if (bSaveSmallThumb){
        hsSizes=getSizes(iSmallThumbSize,iWidth,iHeight,iSmallThumbHeight, true)
        imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height,Image.SCALE_SMOOTH);  
        def x = 0
        def y = 0
        if (bToSquare 
		  || bSquareOnlyThumb){
          if (hsSizes.height > hsSizes.width){
            y = (int)((hsSizes.width - hsSizes.height)/2)
            hsSizes.height = hsSizes.width
          }else{
            x = (int)((hsSizes.height - hsSizes.width)/2)
            hsSizes.width = hsSizes.height
          }
        }
		if(bSaveSmallThumpWithSize){		
		  if(hsSizes.height > hsSizes.width)
            y = (int)((hsSizes.width - hsSizes.height)/2)            
          else
            x = (int)((hsSizes.height - hsSizes.width)/2)                   		  
		  hsSizes.height=iSmallThumbHeight
		  hsSizes.width=iSmallThumbSize
		  if (y+imTemp.getHeight(null) < iSmallThumbHeight) y=0
		  if (x+imTemp.getWidth(null) < iSmallThumbSize) x=0
		}
        imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
        imOut.getGraphics().drawImage(imTemp, x, y, null);

        try {  
          javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+SMALLTHUMBPREFIX+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+SMALLTHUMBPREFIX+sPictureName+"\n"+e.toString())      
        }
      }
	  //>>
    //<<original picture
        hsSizes=getSizes(900,iWidth,iHeight,600, false)
        imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height,Image.SCALE_SMOOTH);  

        imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
        imOut.getGraphics().drawImage(imTemp, 0, 0, null);

        try {  
          javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+ORIGPREFIX+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+ORIGPREFIX+sPictureName+"\n"+e.toString())      
        }
    //>>

	  def bMarginFlag=false
	  def bResizeFlag=false
	  if(iWidth<iPictureSize
	    && iPictureHeight>iHeight){
	    bMarginFlag=true
	  }else{	   	    
	    def fProcent=iWidth/iHeight/0.014-100	  
	 
	    if(!(-10<fProcent
		  && fProcent<10))  
	      bMarginFlag=true
	  
        //   RESIZE PICTURE	  
        if(bMarginFlag
		  ||(iWidth>iPictureSize)
		  ||(iHeight>iPictureSize)
		  ||bToSquare
		  ||(iPictureHeight
		  &&(iPictureHeight<iHeight))){	  
          if ((iWidth>iPictureSize)
		    ||(iHeight>iPictureSize)
			||(iPictureHeight
			&&(iPictureHeight<iHeight))){
            hsSizes=getSizes(iPictureSize,iWidth,iHeight,iPictureHeight)
            imTemp = biTemp.getScaledInstance(hsSizes.width,hsSizes.height, Image.SCALE_SMOOTH);  
          }else{
            hsSizes = [height:iHeight,width:iWidth]
            imTemp = biTemp
          }
          def x = 0
          def y = 0
          if (bToSquare){
            if (hsSizes.height > hsSizes.width){
              y = (int)((hsSizes.width - hsSizes.height)/2)
              hsSizes.height = hsSizes.width
            }else{
              x = (int)((hsSizes.height - hsSizes.width)/2)
              hsSizes.width = hsSizes.height
            }
          }
          bResizeFlag=true	    
          imOut = new BufferedImage(hsSizes.width, hsSizes.height, BufferedImage.TYPE_INT_RGB);  
          imOut.getGraphics().drawImage(imTemp, x, y, null);  
          try {  
            javax.imageio.ImageIO.write(imOut, sExtention, new File(sPath+sPictureName));  
          }catch (IOException e) {
            log.debug("Cannot write picture "+sPath+sPictureName+"\n"+e.toString())      
          }
        }  
	  }
	  
	  if(bMarginFlag){   
	    if(bResizeFlag){
		  iWidth=hsSizes.width
		  iHeight=hsSizes.height
		}
        def left=(iWidth<iPictureSize)?(iPictureSize-iWidth)/2:0
		def top=(iHeight<iPictureHeight)?(iPictureHeight-iHeight)/2:0
		def right=(iWidth<iPictureSize)?(iPictureSize-iWidth)/2:0
		def bottom=(iHeight<iPictureHeight)?(iPictureHeight-iHeight)/2:0
	    BufferedImage biTemp1 = javax.imageio.ImageIO.read(new File(sPath+sPictureName))	 
	    def imOut1 =parseAndMargin(biTemp1,left,top,right,bottom)
	    try {  
          javax.imageio.ImageIO.write(imOut1, sExtention, new File(sPath+sPictureName));  
        }catch (IOException e) {
          log.debug("Cannot write picture "+sPath+sPictureName+"\n"+e.toString())      
        }
	  }	  
	 

      //ADD WATERMARK    
      if( (m_sAlpha!='')&&(m_sMask!='')&&(m_sDirMark!='')&&
          ((sExtention=='jpg')||(sExtention=='png'))    ){
        /*def sPathMark=grailsAttributes.getApplicationContext().getResource(
                      m_sDirMark).getFile().toString()+File.separatorChar*/
		def sPathMark= applicationContext.getResource(m_sDirMark).getFile().toString()+File.separatorChar
        def imageTool = new ImageTool()
        imageTool.load(sPath+sPictureName)        
        imageTool.loadAlpha(sPathMark+m_sAlpha)
        imageTool.loadMask(sPathMark+m_sMask)
        imageTool.applyMask()
        imageTool.writeResult(sPath+sPictureName, (sExtention=='jpg')?"JPEG":"PNG")
      }
      
      //PUT TEMPORARY FILES INTO QUEUE FOR DELETETION UNTIL USER DO NOT SAVE IT INTO DB      
      deletePictureFiles(sPictureName)
      
      hsRes.filename=(m_bFolder?sPictureName[0..1]+'/':'')+sPictureName
      hsRes.thumbname=(m_bFolder?sPictureName[0..1]+'/':'')+THUMBPREFIX+sPictureName
      hsRes.error=0
    }catch (javax.imageio.IIOException ie) {
      log.debug("Cannot read picture\n"+ie.toString())	  
      def destFile=new File(sPath+sPictureName)
      if(destFile.exists())
        destFile.delete()  
	  hsRes.error=5
    }catch (Exception e) {
      log.debug("Cannot save picture\n"+e.toString())
    }
  
    return hsRes
  }
}
