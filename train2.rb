require 'csv'
require 'MeCab'
require 'svm'

featnum = 1000

me = MeCab::Tagger.new
ave = [28, 25, 23, 27, 27]
#0:op 1:co 2:ex 3:ag 4:ne
pa = Array.new(5)
bow_list = Array.new(5){Array.new()}
outstring = Array.new(5, "")

i = 0
CSV.foreach("gain.csv") do |gw|
  j = 1
  for wd in gw
    bow_list[i] << wd
    j += 1
    if j == featnum
      break
    end
  end
  i += 1
end

Dir::glob("/Users/kei/tweet/sampling/**/*.csv").each do |f|
  pass = f.split("/")
  id = pass[5].to_i
  #if id > 6300000
    #next
  #end
  words = []
  bow = Array.new(5){Array.new(featnum, 0)}

  #words collect
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

  for n in 0..4
    for wd in words
      if bow_list[n].include?(wd)
        for m in 0..featnum-1
          if bow_list[n][m] == wd
            bow[n][m] += 1
          end
        end
      end
    end
  end

  #Output
  CSV.foreach("per.csv") do |per|
    if id == per[0].to_i
      for n in 0..4
        if(per[n+1].to_i <= ave[n])
          parameter = -1
        else
          parameter = 1
        end
        outstring[n] << "#{parameter}"
        for m in 0..featnum-1
          outstring[n] << " #{m+1}:#{bow[n][m]}"
        end
        outstring[n] << "\n"
      end
      break
    end
  end
end

for n in 0..4
  File.write("Parameter#{n}.train", outstring[n])
end
