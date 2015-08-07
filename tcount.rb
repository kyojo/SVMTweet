require 'csv'
require 'MeCab'
require 'rubygems'
require 'classifier'
require 'stemmer'

me = MeCab::Tagger.new
ave = [28, 25, 23, 27, 27]
pa = Array.new(5)
#0:op 1:co 2:ex 3:ag 4:ne
for n in 0..4
  pa[n] = Classifier::Bayes.new("0","1")
end
countnum = 0
count = 0

Dir::glob("/Users/kei/tweet/sampling/**/*.csv").each do |f|
  pass = f.split("/")
  id = pass[5].to_i
  if id > 6300000
    next
  end

  #words collect
  File.open(f) do |file|
    countnum += 1
    while str = file.gets do
      str.force_encoding("UTF-8")
      str = str.scrub('?')
      twe = str.split(",")
      if twe[1].nil?
        next
      elsif twe[1].index("@") == 0
        next
      end
      node = me.parseToNode(twe[1])
      node = node.next
      while node.next do
        feat = node.feature.split(",")
        if (feat[0] == ("助詞"||"助動詞"||"記号"))
          count += 1
        end
        node = node.next
      end
    end
  end
end

puts count/countnum.to_f
