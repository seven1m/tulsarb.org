#!/usr/bin/env ruby

# updates the index.html from code in tulsa.rb and merges with template.html
# run without any args (will replace existing index.html)

require 'net/http'
require 'uri'

code = File.read(File.dirname(__FILE__) + '/../src/tulsa.rb')
code_html = Net::HTTP.post_form(
  URI.parse('http://pygments.appspot.com/'),
  {'lang' => 'ruby', 'code' => code}
).body

code_html.gsub!(/^/, '  ')
code_html.sub!(/<div class="highlight"><pre>/, '\0  ')

repl_index = 0
indents = []
code_html = code_html.split(/\n/).map do |line|
  sub = line.gsub!(/^ ( *)(<span class="k">(class|def)<\/span>.+)$/) do
    indents << $1
    repl_index += 1
    if $2.index(':collapse:')
      "<a href=\"#\" onclick=\"expand('repl#{repl_index}',this);return false;\" class=\"expand\">+</a>#{$1}#{$2} <span id=\"repl#{repl_index}_dots\">...</span><span id=\"repl#{repl_index}_code\" style=\"display:none;\">"
    else
      "<a href=\"#\" onclick=\"expand('repl#{repl_index}',this);return false;\" class=\"expand\">-</a>#{$1}#{$2} <span id=\"repl#{repl_index}_dots\" style=\"display:none;\">...</span><span id=\"repl#{repl_index}_code\">"
    end
  end
  if !sub and indents.any? and line =~ Regexp.new('^ ' + indents.last + '\S')
    line += '</span>'
    indents.pop
  end
  line
end.join("\n")

code_html.gsub!(/ *<span class="c1"># *:collapse: *<\/span>/, '')

# this url regexp might need some work
code_html.gsub!(/https?:\/\/[a-zA-Z0-9\.\/]+/, '<a href="\0">\0</a>')

template_html = File.read(File.dirname(__FILE__) + '/../src/template.html')
html = template_html.sub(/\{\{content\}\}/, code_html)

File.open(File.dirname(__FILE__) + '/../index.html', 'w') { |f| f.write(html) }
