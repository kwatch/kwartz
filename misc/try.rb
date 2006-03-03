
s = "hogehoge\r\n"
if s =~ /(\w+)$/
  puts "$1=#{$1.inspect}, $'=#{$'.inspect}"
end
