#!/usr/bin/env ruby

input = ARGF.read()
slides = input.scan(/^    <div id="(slide.*?)" class="slide(?: titlepage)?">/).collect { |a| a.first }
n_slides = slides.length

i = 0
input.scan(/(.*?)^      <div class="footer">(.*?)^      <\/div>\n/m) do |text, cont|
   #navi = {}
   #cont.scan(/<a href="(#slide.*?)" class="navi-(.*?)"/) do |href, klass|
   #   #puts "href=#{href.inspect}, class=#{klass.inspect}"
   #   navi[klass] = href
   #end
   slide_id = slides[i]
   toc_slide_id = case slide_id
                  when 'slide-toc'           ;  "slide-title"
                  when /^slide(\d+)-(\d+)$/  ;  "slide#{$1}-toc"
                  else                       ;  "slide-toc"
                  end
   navi = { 'id'=>slides[i], 'toc'=>toc_slide_id,
            'prev'=>slides[i-1], 'next'=>slides[(i+1)%n_slides] }
   #p navi
   i += 1
   print text
   print <<END
      <div class="footer">
        <div class="footer-left">
          &nbsp;<a href="##{navi['prev']}" class="navi-prev">&lt;&lt;</a>
          <a href="##{navi['toc'] || navi['up']}" class="navi-toc">^</a>
        </div>
        <div class="footer-right">
          <span class="pagenum">#{i}/#{n_slides}</span>
          <a href="##{navi['next']}" class="navi-next">&gt;&gt;</a>&nbsp;
        </div>
        <div class="footer-center">
          <span class="copyright">copyright&copy;2006 kuwata-lab.com all rights reserved</span>
        </div>
      </div>
END
   #puts navi.inspect
end
print $'
