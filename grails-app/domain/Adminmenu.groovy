class Adminmenu {
  
  def searchService
  
  static constraints = {
  }
  
  static mapping = {
    version false
  }
  
  Integer id
  String name
  
  def csiGetMenu(iGroupId){
    def oAdmingroup = Admingroup.get(iGroupId)
    def lsMenuItemIds = oAdmingroup.menu.tokenize(',')
    def hsSql = [select :'*',
                 from   :'adminmenu',
                 where  :'id in (:ids)',
                 order  :'id']
    def hsList = [ids:lsMenuItemIds]
    return searchService.fetchData(hsSql,null,null,null,hsList,Adminmenu.class)
  }
}
