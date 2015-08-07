require 'csv'
require 'MeCab'
require 'rubygems'
require 'classifier'
require 'stemmer'
include Math

allwd = []

me = MeCab::Tagger.new
ave = [28, 25, 23, 27, 27]
pa = Array.new(5)
#0:op 1:co 2:ex 3:ag 4:ne
for n in 0..4
  pa[n] = Classifier::Bayes.new("0","1")
end
np = Array.new(5, 0)
nn = Array.new(5, 0)
npw = Array.new(5){{}}
nnw = Array.new(5){{}}


Dir::glob("/Users/kei/tweet/sampling/**/*.csv").each do |f|
  pass = f.split("/")
  id = pass[5].to_i
  #if id > 1000000
    #next
  #end
  words = []

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
        if !(feat[0] == ("名詞"))
          words << feat[6]
          allwd << feat[6]
        end
        node = node.next
      end
    end
  end

  #Initialization
  for n in 0..4
    for wd in words
      if !npw[n].key?(wd)
        npw[n][wd] = 0
      end
      if !nnw[n].key?(wd)
        nnw[n][wd] = 0
      end
    end
  end

  #word count
  CSV.foreach("per.csv") do |per|
    if id == per[0].to_i
      for wd in words
        for n in 0..4
          if(per[n+1].to_i <= ave[n])
            np[n] += 1
            npw[n][wd] += 1
          else
            nn[n] += 1
            nnw[n][wd] += 1
          end
        end
      end
      break
    end
  end
end

infogain = Array.new(5){{}}
allwd.uniq!
allwd.delete("*")
eps = 1e-10
for wd in allwd
  for n in 0..4
    p_p = np[n] / (np[n] + nn[n]).to_f
    p_n = 1.0 - p_p
    p1 = (npw[n][wd] + nnw[n][wd]) / (np[n] + nn[n]).to_f
    p0 = 1.0 - p1
    p_p1 = npw[n][wd] / (npw[n][wd] + nnw[n][wd]).to_f
    p_n1 = 1.0 - p_p1
    p_p0 = (np[n] - npw[n][wd]) / (np[n] - npw[n][wd] + nn[n] - nnw[n][wd]).to_f
    p_n0 = 1.0 - p_p0
    h_c = -1.0 * p_p * log(p_p) - p_n * log(p_n)
    if (p_n1-0.0).abs <= eps
      h_c1 = -1.0 * p_p1 * log(p_p1)
    elsif (p_p1-0.0).abs <= eps
      h_c1 = -1.0 * p_n1 * log(p_n1)
    else
      h_c1 = -1.0 * p_p1 * log(p_p1) - p_n1 * log(p_n1)
    end
    if (p_n0-0.0).abs <= eps
      h_c0 = -1.0 * p_p0 * log(p_p0)
    elsif (p_p0-0.0).abs <= eps
      h_c0 = -1.0 * p_n0 * log(p_n0)
    else
      h_c0 = -1.0 * p_p0 * log(p_p0) - p_n0 * log(p_n0)
    end
    gain = h_c - (p1 * h_c1 + p0 * h_c0)
    #puts "#{wd},#{n} : #{h_c}, #{p1}, #{h_c1}, #{p0}, #{h_c0}, #{gain}"
    #puts "#{wd},#{n} : #{h_c}, #{p_p}, #{h_c0}, #{p_p0}"
    infogain[n][wd] = gain
  end
end

result = Array(2)
print "Openness,infogain,Conscientiousness,infogain,Extraversion,infogain,Agreeableness,infogain,Neuroticism,infogain\n"
for i in 0..500
  for n in 0..4
    result = infogain[n].sort{|(k1, v1), (k2, v2)| v2 <=> v1}[i]
    print "#{result[0]},#{result[1]}"
    if n != 4
      print ","
    end
  end
  print "\n"
end
