class City {    
  
  static constraints = {	
  }
  static mapping = {
    version false
  }
  Integer id
  String name      
  Integer x
  Integer y

  String toString() {"${this.name}" }  
}
