

def set_values()
  lang = ENV['lang']
  lang ||= (Dir.pwd =~ /\bkwartz-(\w+)\b/) && $1
  lang  or raise "cannot detect lang."
  lang =~ /^(ruby|php|java)$/i  or raise "'#{lang}': unknown lang."
  @lang = lang.downcase
  table = { 'ruby'=> ['Ruby',  'eruby',  'rhtml',  'kwartz'],
            'php' => ['PHP',   'php',    'php',    'kwartz-php'],
            'java'=> ['Java',  'jstl',   'jsp',    'java kwartz.Main'],
          }
  @Lang, @outlang, @suffix, @command, = table[@lang]
  @support_defun = @lang == 'ruby'
  @support_pl    = @lang == 'java'
end


def error
  ex = StandardError.new("*** internal error: @lang='#{@lang.inspect}'")
  ex.set_backtrace(caller())
  raise ex
end


def create_testscript(testdata, testscript_filename)
  ## convert hash keys from symbol to string
  #hashlist = testdata.collect { |elem|
  #  elem.inject({}) { |h, t| h[t.first.to_s] = t.last; h }
  #}
  #testdata = hashlist
  ## context object
  context = Object.new
  context.instance_variable_set("@testdata", testdata)
  ## eruby object
  template = File.read(testscript_filename + '.eruby')
  require 'erubis'
  erubis = Erubis::Eruby.new(template)
  ## output
  output = context.instance_eval(erubis.src)
  #$stderr.print output
  File.open(testscript_filename, 'w') { |f| f.write(output) }
end
