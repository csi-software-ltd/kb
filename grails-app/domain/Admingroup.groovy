class Admingroup {

  static constraints = {
  }
  static mapping = {
    version false
  }
  Integer id
  String name

  String menu
  Integer is_superuser
  Integer is_profile
  Integer is_groupmanage
  Integer is_users
  Integer is_tenders
}