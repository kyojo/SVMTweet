require 'csv'
require 'MeCab'
require 'rubygems'
require 'classifier'
require 'stemmer'

ave = [28, 25, 23, 27, 27]
pa = Array.new(5)
fw = Array.new(5){Array.new()}
i = 0
CSV.foreach("gain.csv") do |gw|
  j = 0
  for wd in gw
    fw[i] << wd
    j += 1
    if j == 250
      break
    end
  end
  i += 1
end

begin
  for n in 0..4
    pa[n] = nil
    File.open("bayes_#{n}2", "r") do |f|
      pa[n] = Marshal.load(f)
    end
  end
rescue
  for n in 0..4
    pa[n] = Classifier::Bayes.new("0","1")
  end
end

me = MeCab::Tagger.new

tr = Array.new(5, 0)
fa = Array.new(5, 0)
re = Array.new(5, 0)
pr = Array.new(5, 0)

Dir::glob("/Users/kei/tweet/sampling/**/*.csv").each do |f|
  pass = f.split("/")
  id = pass[5].to_i
  if id < 6300000
    next
  end
  words = []

  File.open(f) do |file|
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
        if !(feat[0] == ("名詞"||"動詞"))
          words << feat[6]
        end
        node = node.next
      end
    end
  end

  docu = Array.new(5){Array.new()}
  doc = Array.new(5)
  for n in 0..4
    for wd in words
      if fw[n].include?(wd)
        docu[n] << wd
      end
    end
    doc[n] = docu[n].join(" ")
  end

  for n in 0..4
    re[n] = pa[n].classify(doc[n]).to_i
  end

  CSV.foreach("per.csv") do |per|
    if id == per[0].to_i
      for n in 0..4
        if(per[n+1].to_i <= ave[n] && re[n] == 0)
          tr[n] += 1
        elsif(per[n+1].to_i > ave[n] && re[n] == 1)
          tr[n] += 1
        else
          fa[n] += 1
        end
      end
      break
    end
  end
end

for n in 0..4
  pr[n] = (tr[n] / (tr[n] + fa[n])) * 100.to_f
end

puts "Openness:#{pr[0]}%\nConscientiousness:#{pr[1]}%\nExtraversion:#{pr[2]}%\nAgreeableness:#{pr[3]}%\nNeuroticism:#{pr[4]}%"
