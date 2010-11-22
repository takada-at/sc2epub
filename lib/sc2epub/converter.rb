class Sc2epub::Converter
    require 'nkf'
    require 'fileutils'
    require 'cgi'
    def initialize env, root, output
        @root = path(root)
        @output = output
        @template = Sc2epub::Template::new
        @dirstack = []
        @indexes = []
        @env = env
    end
    def path path
        r = File::expand_path(path)
    end
    def local path
        if path.index(@root)==0
            path = path[@root.size, path.size]
        end
        if path[0,1] == "/"
            path = path[1, path.size]
        end
        return path
    end
    def title path
        path.gsub(/\//, "_").gsub(/\./, '_')
    end
    def dogenerate doctitle
        output = @output
        indexhtml = ''
        items = ''; c=0;
        nvitems = ''
        cover = File::join(File::dirname(__FILE__), 'cover.jpg')
        FileUtils::cp(cover, output)
        @indexes.each do |data|
            title = data[:name]
            link = data[:src]
            if data[:type]==:dir && data[:level]+2<=4
                tagname = "h" + (data[:level]+2).to_s
            else
                tagname = 'p'
            end
            indexhtml += "<#{tagname}>" + @template.link('url'=>link, 'title'=>title) + "</#{tagname}>\n"
            if data[:type]==:file
                items += @template.item('id'=>"item#{c+=1}", 'link'=>link)
                nvitems += @template.navi('id'=>"navPoint-#{c}", 'order'=>c.to_s, 'link'=>link, 'title'=>title)
            end
        end
        indexhtml = @template.index('title'=>'index', 'body'=>indexhtml)
        opf = @template.opf('title'=>doctitle, 'date'=>Time::now.strftime("%Y/%m/%d"),
                            'lang' => @env[:lang],
                            'items'=>items, 'author'=>@env[:author])
        ncx = @template.ncx('title'=>doctitle, 'navitems'=>nvitems)
        open(File::join(output, 'index.html'), 'w') do |io|
            io.write(indexhtml)
        end
        opfpath = "#{doctitle}.opf"
        open(File::join(output, opfpath), 'w') do |io|
            io.write(opf)
        end
        open(File::join(output, 'toc.ncx'), 'w') do |io|
            io.write(ncx)
        end
        Dir::mkdir(File::join(output, 'META-INF')) unless FileTest::exists? File::join(output, 'META-INF')
        open(File::join(output, 'META-INF', 'container.xml'), 'w') do |io|
            io.write(@template.container('opfpath'=>opfpath))
        end
        open(File::join(output, 'mimetype'), 'w') do |io|
            io.puts('application/epub+zip')
        end
        makefile = @template.makefile('title'=>doctitle)
        open(File::join(output, 'Makefile'), 'w') do |io|
            io.write(makefile)
        end
    end
    def dofile path
        #ext = File::extname(path)
        #if ext == '.html' or ext == '.xhtml' or ext == '.jpg' or ext == '.gif' or ext == '.png'
        #    FileUtils::cp(path, @output)
        #    return
        #end
        output = @output
        s = open(path){|io|io.read}
        enc = NKF::guess(s)
        if enc==NKF::BINARY
            return nil
        elsif enc!=NKF::ASCII and enc!=NKF::UTF8
            s = NKF::nkf('-wxm0', s)
        end
        title = title(local(path))
        s = CGI::escapeHTML(s)
        s = @template.xhtml('title'=>local(path), 'body'=>s)
        npath = title+".html"
        if @dirstack.last and not @dirstack.last[:src]
            @dirstack.last[:src] = npath
            @indexes << @dirstack.last
        end
        open(File::join(output, npath), "w") do |io|
            io.write(s)
        end
        level = @dirstack.empty? ? 1 : @dirstack.last[:level]+1
        @indexes << {:src => npath, :name =>local(path), :type => :file, :level => level}
        title
    end
    def dodir dir
        return [] if File::basename(dir)=~/^\..*/
        @dirstack.push({:name =>local(dir), :src =>nil, :path => dir,
                           :type => :dir, :level => @dirstack.size})
        cache = {}
        until(@dirstack.empty?)
            dir = @dirstack.last[:path]
            subdir = nil
            Dir::foreach(dir) do |i|
                next if i=="."||i==".."
                path = File::join(dir, i)
                next if cache[path]
                if FileTest::directory? path
                    subdir = path unless subdir
                elsif FileTest::file? path
                    dofile(path)
                    cache[path] = true
                end
            end
            if !subdir
                done = @dirstack.pop
                cache[done[:path]] = true
            else
                path = subdir
                @dirstack.push({:name =>local(path), :src =>nil, :path => path,
                                   :type => :dir, :level => @dirstack.size})
            end
        end
    end
    def doroot dir
        dir = path(dir)
        Dir::foreach(dir) do |i|
            next if i=="."||i==".."
            path = File::join(dir, i)
            if FileTest::directory? path
                dodir(path)
            elsif FileTest::file? path
                dofile(path)
            end
        end
    end
end
