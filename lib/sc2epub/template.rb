class Sc2epub::Template
    TEMPLATE_MAKEFILE = 'makefile.tmpl'
    TEMPLATE_OPF = 'opf.tmpl'
    TEMPLATE_NCX = 'ncx.tmpl'
    TEMPLATE_XHTML = 'xhtml.tmpl'
    TEMPLATE_INDEX = 'index.tmpl'
    TEMPLATE_LINK = "<a href=\"%(url)\">%(title)</a>"
    TEMPLATE_NAVITEM = <<EOS
      <navPoint id="%(id)" playOrder="%(order)">
         <navLabel><text>%(title)</text></navLabel><content src="%(link)"/>
      </navPoint>
EOS
    TEMPLATE_ITEM = "<item id=\"%(id)\" media-type=\"text/x-oeb1-document\" href=\"%(link)\"></item>"
    TEMPLATE_CONTAINER = 'container.tmpl'
    def initialize
	@map = {}
        @dir = File::join(File::dirname(__FILE__), 'template')
    end
    def container params
        dotemplate TEMPLATE_CONTAINER, params
    end
    def link params
        dotemplate TEMPLATE_LINK, params
    end
    def item params
        dotemplate TEMPLATE_ITEM, params
    end
    def navi params
        dotemplate TEMPLATE_NAVITEM, params
    end
    def index params
        dotemplate TEMPLATE_INDEX, params
    end
    def opf params
        dotemplate TEMPLATE_OPF, params
    end
    def ncx params
        dotemplate TEMPLATE_NCX, params
    end
    def makefile params
        dotemplate TEMPLATE_MAKEFILE, params
    end
    def xhtml params
        dotemplate TEMPLATE_XHTML, params
    end
    def dotemplate template, params
        if template.rindex('.tmpl')
	    if @map.has_key? template
		t = @map[template]
	    else
		t = open(File::join(@dir, template)){|io|io.read}
		@map[template] = t
	    end
        else
            t = template
        end
        for k,v in params
            t = t.gsub(/%\(#{k}\)/, v)
        end
        t
    end
end
