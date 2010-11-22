require 'rubygems'
require 'lib/sc2epub'

describe Sc2epub::Converter, 'when on html' do
    before(:all) do
        @in = File::join(File::dirname(__FILE__), 'in')
        @out = File::join(File::dirname(__FILE__), 'out')
        `rm -r #{@in}` if FileTest::exists? @in
        `rm -r #{@out}` if FileTest::exists? @out
        `mkdir #{@in}`
        `mkdir #{@out}`
        open(File::join(@in, 'some.html'), 'w') do |io|
            io.write('<html></html>')
        end
        open(File::join(@in, 'some.rb'), 'w') do |io|
            io.write('puts "hello"')
        end
        @converter = Sc2epub::Converter::new({:author => 'test', :lang => 'en'}, @in, @out)
        @converter.doroot(@in)
        @converter.dogenerate('test')
    end
    #it 'should copy html' do
    #    FileTest.should be_exists(File::join(@out, 'some.html'))
    #end
    it 'should rewrite source code' do
        FileTest.should be_exists(File::join(@out, 'some_rb.html'))
    end
    #it 'should not rewrite html' do
    #    FileTest.should_not be_exists(File::join(@out, 'some_html.html'))
    #end
    after(:all) do
        `rm -r #{@in}` if FileTest::exists? @in
        `rm -r #{@out}` if FileTest::exists? @out
    end
end
describe Sc2epub::Converter, 'when on sc2epub/lib'do
    before(:all) do
        @lib = File::join(File::dirname(__FILE__), '../lib')
        @out = File::join(File::dirname(__FILE__), 'out')
        `mkdir #{@out}`
        @converter = Sc2epub::Converter::new({:author => 'test', :lang => 'en'}, @lib, @out)
        @converter.doroot(@lib)
        @converter.dogenerate('test')
    end
    it 'should create META-INF and container.xml' do
        FileTest.should be_exists(File::join(@out, 'META-INF'))
        FileTest.should be_directory(File::join(@out, 'META-INF'))
        FileTest.should be_exists(File::join(@out, 'META-INF', 'container.xml'))
    end
    it 'should create mimetype' do
        FileTest.should be_exists(File::join(@out, 'mimetype'))
    end
    it 'should create Makefile' do
        FileTest.should be_exists(File::join(@out, 'Makefile'))
    end
    it 'should create toc.ncx, test.opf' do
        FileTest.should be_exists(File::join(@out, 'toc.ncx'))
        FileTest.should be_exists(File::join(@out, 'test.opf'))
    end
    it 'should create "sc2epub_rb.html"' do
        FileTest.should be_exists(File::join(@out, 'sc2epub_rb.html'))
    end
    it 'should create "sc2epub_converter_rb.html"' do
        FileTest.should be_exists(File::join(@out, 'sc2epub_converter_rb.html'))
    end
    it 'should create html for any file in directory' do
        checkfile = lambda do |f|
            return if File::extname(f)=='.jpg'
            f = @converter.path(f)
            html = @converter.title(@converter.local(f))+'.html'
            FileTest.should be_exists(File::join(@out, html))
        end
        checkdir = lambda do |d|
            Dir::foreach(d) do |c|
                next if c == '.' or c == '..'
                path = File::join(d, c)
                if FileTest::file? path
                    checkfile.call(path)
                elsif FileTest::directory? path
                    checkdir.call(path)
                end
            end
        end
        checkdir.call(@lib)
    end
    it 'should have "test" in title' do
        s = open(File::join(@out, 'test.opf')){|io|io.read}
        /<dc:Title>(.*)<\/dc:Title>/.match(s).should_not be(nil)
        Regexp::last_match[1].should == 'test'
        /<dc:Language>(.*)<\/dc:Language>/.match(s).should_not be(nil)
        Regexp::last_match[1].should == 'en'
        /<dc:Creator>(.*)<\/dc:Creator>/.match(s).should_not be(nil)
        Regexp::last_match[1].should == 'test'
    end
    it 'should place sc2epub.rb before sc2epub/converter.rb in index.html' do
        s = open(File::join(@out, 'index.html')){|io|io.read}
        p0 = s.index('sc2epub.rb')
        p1 = s.index('sc2epub/converter.rb')
        p0.should < p1
    end
    it 'should place sc2epub/main.rb and sc2epub/template.rb before sc2epub/template' do
        s = open(File::join(@out, 'index.html')){|io|io.read}
        p0 = s.index('sc2epub/main.rb</a>')
        p1 = s.index('sc2epub/template.rb</a>')
        p2 = s.index('sc2epub/template</a>')
        p0.should < p2
        p1.should < p2
    end
    after(:all) do
        if FileTest::exists? @out
            `rm -r #{@out}`
        end
    end
end
