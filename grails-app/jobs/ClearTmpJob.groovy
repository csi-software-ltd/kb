import org.codehaus.groovy.grails.commons.ConfigurationHolder

class ClearTmpJob {
  def timeout = Tools.getIntVal(ConfigurationHolder.config.pic.clear.timeout,900000)  // 15 мин
  def execute() {
    //TODO move into service
    //TODO!!! DELETE PICS ONLY AFTER MODERATION NEW
    //TODO WHAT THE HELL?!! ConfigurationHolder.config.*deskcat*.timelife
    def oPicturetemp=new Picturetemp() 
    def lsFiles=oPicturetemp.csiGetFilesForDelete(Tools.getIntVal(ConfigurationHolder.config.timelifepic,(60*15)))
    def lsBadFiles=oPicturetemp.csiGetOldFiles(Tools.getIntVal(ConfigurationHolder.config.timelifepic,(60*15)))
    //println(lsFiles)
    def fileRemove
    def lsIds=[]
    for(hsFile in lsFiles) {
      try {
        log.debug("LOG>> Delete old file "+hsFile.fullname)
        fileRemove=new File(hsFile.fullname)
        if(fileRemove.exists()){
          fileRemove.delete()
          log.debug("LOG>>  OK")
        }
      }catch (Exception e) {
        log.debug("Cannont delete "+hsFile.fullname+"\n"+e.toString())
      }
      //lsIds<<hsFile.id
    }
    lsIds = lsBadFiles.collect{ it.id }
    oPicturetemp.csiDeleteByIds(lsIds)
  }
}
