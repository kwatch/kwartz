###
### $Rev$
### $Release$
### $Copyright$
###

require "#{File.dirname(__FILE__)}/test.rb"

filename = __FILE__.sub(/\.\w+$/, '.yaml')
ydoc = YAML.load_file(filename)

PDATA = ydoc['pdata']
ERUBY_PLOGIC  = ydoc['plogic*']['eruby']
ERUBY_OUTPUT  = ydoc['expected*']['eruby']
PHP_PLOGIC    = ydoc['plogic*']['php']
PHP_OUTPUT    = ydoc['expected*']['php']
IMPORT_PDATA  = ydoc['import_pdata']
IMPORT_PLOGIC = ydoc['import_plogic*']['eruby']
LAYOUT        = ydoc['layout']
YAML_DATA     = ydoc['yamldata']
YAML_OUTPUT   = ydoc['yamloutput']
NOTEXT_ERUBY  = ydoc['notext*']['eruby']
NOTEXT_RUBY   = ydoc['notext*']['ruby']
DEFUN_ERUBY   = ydoc['defun*']['eruby']
DEFUN_PHP     = ydoc['defun*']['php']

class File
  def self.write(filename, content)
    File.open(filename, 'w') { |f| f.write(content) }
  end
end


class MainTest < Test::Unit::TestCase

  ## define test methods
  #filename = __FILE__.sub(/\.rb$/, '.yaml')
  #load_yaml_testdata(filename)


  def _test
    @name = (caller()[0] =~ /in `test_(.*?)'/) && $1
    return if ENV['TEST'] && ENV['TEST'] != @name
    begin
      File.write("#{@name}.pdata",  @pdata)  if @pdata
      File.write("#{@name}.plogic", @plogic) if @plogic
      File.write("#{@name}.yaml",   @yamldata) if @yamldata
      main = Kwartz::Main.new(@argv)
      if @exception
        mesg = nil
        assert_raise(@exception) do
          begin
            actual = main.execute()
          rescue => ex
            mesg = ex.message
            raise ex
          end
        end
        assert_text_equal(@message, mesg) if @message
      else
        actual = main.execute()
        @actual = actual
        assert_text_equal(@expected, actual)
      end
    ensure
      f = nil
      File.unlink(f) if test(?f, f = "#{@name}.pdata")
      File.unlink(f) if test(?f, f = "#{@name}.plogic")
      File.unlink(f) if test(?f, f = "#{@name}.yaml")
    end
  end


  def test_pdata1
    @pdata = PDATA
    @argv = %w[pdata1.pdata]
    @expected = PDATA.gsub(/ id="mark:\w+"/, '')
    _test
  end


  def test_pstyle1 # -P
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @argv = %w[-Pcss -p pstyle1 pstyle1.pdata]
    @expected = ERUBY_OUTPUT
    _test
    # NG
    @argv = %w[-Phoge -p pstyle1 pstyle1.pdata]
    @exception = Kwartz::CommandOptionError
    @message = "-P hoge: unknown style name (parser class not registered)."
    _test
  end


  def test_lang1 # -l
    # OK
    @pdata = PDATA
    @plogic = PHP_PLOGIC
    @argv = %w[-l php -p lang1 lang1.pdata]
    @expected = PHP_OUTPUT
    _test
    # NG
    @argv = %w[-l hoge -p lang1 lang1.pdata]
    @exception = Kwartz::CommandOptionError
    @message = "-l hoge: unknown lang name (handler class not registered)."
    _test
  end


  def test_requires1 # -r
    # OK
    @pdata = PDATA
    @argv = %w[-rstringio,tsort requires1.pdata]
    @expected = PDATA.gsub(/ id="mark:.*?"/, '')
    _test
    assert_nothing_raised do
      obj = StringIO.new("")
      s = TSort.name
    end
    # NG
    @argv = %w[-rhogeratta requires1.pdata]
    assert_raise(LoadError) do
      _test
    end
  end


  def test_plogics1 # -p
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @argv = %w[-p plogics1.plogic plogics1.pdata]
    @expected = ERUBY_OUTPUT
    _test
    # NG (not found)
    @argv = %w[-p hogeratta plogics1.pdata]
    @exception = Kwartz::CommandOptionError
    @message = "-p hogeratta[.plogic]: file not found."
    _test
    # NG (syntax error)
    @plogic = ERUBY_PLOGIC.sub(/@title;/, '@title')
    @argv = %w[-p plogics1 plogics1.pdata]
    @exception = Kwartz::ParseError
    @message = "plogics1.plogic:3:1: 'value:': ';' is required."
    _test
  end


  def test_escape1 # -e, --escape
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @expected = ERUBY_OUTPUT.sub(/<%= @title %>/, '<%=h @title %>')
    @argv = %w[-epescape1 escape1.pdata]
    _test
    # OK
    @pdata = PDATA
    @plogic = PHP_PLOGIC
    @expected = PHP_OUTPUT.sub(/echo \$title;/, 'echo htmlspecialchars($title);')
    @argv = %w[--escape -lphp -pescape1 escape1.pdata]
    _test
  end


  def test_import1 # -i
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC.sub(/^\#doctitle.*?\}/m, "#doctitle{logic:{\n_element(sectitle)\n}\n}")
    @expected = ERUBY_OUTPUT.sub(/^\s*<h1>.*?<\/h1>/, '<%= sectitle %>')
    File.write('import1a.pdata', IMPORT_PDATA)
    File.write('import1a.plogic', IMPORT_PLOGIC)
    @argv = %w[-p import1,import1a -i import1a.pdata import1.pdata]
    begin
      _test
    ensure
      %w[import1a.pdata import1a.plogic].each do |filename|
        File.unlink filename if test(?f, filename)
      end
    end
    # NG
    @argv = %w[-p import1 -i hogehoge import1.pdata]
    @exception = Kwartz::CommandOptionError
    @message = "-i hogehoge: file not found."
    _test
  end


  def test_layout1 # -L
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    File.write('layout.html', LAYOUT)
    content_str = (ERUBY_OUTPUT =~ /^\s*<table.*?<\/table>/m) && $&
    @expected = LAYOUT.sub(/^(\s*)<title.*?<\/title>/, '\1<title><%= @title %></title>')
    @expected.sub!(/^( *)<div .*?<\/div>/m, content_str)
    @argv = %w[-p layout1 -L layout.html layout1.pdata]
    begin
      _test
    ensure
      %w[layout.html].each do |filename|
        File.unlink filename if test(?f, filename)
      end
    end
    # NG
    @argv = %w[-p layout1 -L hogehoge layout1.pdata]
    @exception = Kwartz::CommandOptionError
    @message = "-L hogehoge: file not found."
    _test
  end


  def test_extract1 # -X
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @argv = %w[-X content -p extract1 extract1.pdata]
    @expected = (ERUBY_OUTPUT =~ /^ *<table.*?<\/table>\n/m) && $&
    _test
    # NG
    @exception = Kwartz::ConvertError
    @message = "extract1.pdata:: element 'hogehoge' not found."
    @argv = %w[-X hogehoge -p extract1 extract1.pdata]
    _test
  end


  def test_extract2 # -x
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @argv = %w[-x content -p extract2 extract2.pdata]
    @expected = (ERUBY_OUTPUT =~ /<table id=".*?">\n(.*)^ *<\/table>/m) && $1
    _test
    # NG
    @exception = Kwartz::ConvertError
    @message = "extract2.pdata:: element 'hogehoge' not found."
    @argv = %w[-x hogehoge -p extract2 extract2.pdata]
    _test
  end


  def test_yamlfile1 # -f
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @argv = %w[-f yamlfile1.yaml -p yamlfile1 yamlfile1.pdata]
    @yamldata = YAML_DATA.gsub(/\t/, '  ')
    @expected = YAML_OUTPUT
    _test
    # NG (not found)
    @argv = %w[-f hogehoge.yaml -p yamlfile1 yamlfile1.pdata]
    @exception = Kwartz::CommandOptionError
    @message = "-f hogehoge.yaml: file not found."
    _test
    # NG (not a mapping)
    @yamldata = <<END
- title: kwartz test
- list:
    - aaa
    - bbb
    - ccc
END
    @argv = %w[-f yamlfile1.yaml -p yamlfile1 yamlfile1.pdata]
    @exception = Kwartz::CommandOptionError
    @message = "-f yamlfile1.yaml: not a mapping."
    _test
  end


  def test_untabify1 # -t
    # OK
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @argv = %w[-tf untabify1.yaml -p untabify1 untabify1.pdata]
    @yamldata = YAML_DATA
    @expected = YAML_OUTPUT
    _test
    # NG
    @argv = %w[-f untabify1.yaml -p untabify1 untabify1.pdata]
    @exception = ArgumentError   # yaml syntax error
    _test
  end


  def test_intern1 # -S
    # OK
    @pdata = <<END
<span kw:d="value: @aaa[:bb1][:cc1][:dd1]">xxx</span>
<span kw:d="value: @aaa[:bb1][:cc1][:dd2][:bb2]">xxx</span>
END
    @yamldata = <<END
aaa: &anchor1
  bb1:
    cc1:
      dd1: foo
      dd2: *anchor1
  bb2: bar
END
    @expected = <<END
<span>foo</span>
<span>bar</span>
END
    @argv = %w[-tSf intern1.yaml intern1.pdata]
    _test
    # OK
    @pdata = <<END
<span kw:d="value: @aaa['bb1']['cc1']['dd1']">xxx</span>
<span kw:d="value: @aaa['bb1']['cc1']['dd2']['bb2']">xxx</span>
END
    @argv = %w[-tf intern1.yaml intern1.pdata]
    _test
  end


  def test_defun1   # -a defun
    @argv = %w[-a defun -p defun1 defun1.pdata]
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @lang = 'eruby'
    @expected = DEFUN_ERUBY
    _test
  end


  def test_defun2   # -a defun -l php
    @argv = %w[-a defun -l php -p defun2 defun2.pdata]
    @pdata = PDATA
    @plogic = PHP_PLOGIC
    @lang = 'php'
    @expected = DEFUN_PHP
    _test
  end


  def test_notext  # -N
    @argv = %w[-N -p notext notext.pdata]
    @pdata = PDATA
    @plogic = ERUBY_PLOGIC
    @expected = NOTEXT_ERUBY
    _test
    @argv = %w[-lruby -N -p notext notext.pdata]
    @expected = NOTEXT_RUBY
    _test
  end

  def test_no_args
    @exception = Kwartz::CommandOptionError
    tuples = [
      [?l, 'lang name'],
      [?k, 'kanji code'],
      [?a, 'action name'],
      [?r, 'library name'],
      [?p, 'file name'],
      [?P, 'parser style'],
      [?x, 'element id'],
      [?X, 'element id'],
      [?i, 'file name'],
      [?L, 'file name'],
      [?f, 'yaml file'],
    ]
    tuples.each do |char, argname|
      @argv = ["-#{char.chr}"]
      @message = "-#{char.chr}: #{argname} required."
      _test
    end
  end


  def test_no_filenames
    @exception = Kwartz::CommandOptionError
    @argv = %w[-p foo]
    @message = 'filename of presentation data is required.'
    _test
  end


end
