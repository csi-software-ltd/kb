class UrlMappings {

	static mappings = {
		"/$controller/$action?/$id?"{
			constraints {
				// apply constraints here
			}
		}

		"/"(controller : "index", action:"index")
		"/tenders"(controller : "index", action:"tenders")
		"/search"(controller : "index", action:"search")
		"/robots.txt"(controller:'index',action:'robots')
		"500"(view:'/error')
	}
}
