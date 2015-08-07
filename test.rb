require 'MeCab'
require 'rubygems'
require 'classifier'
require 'stemmer'

begin
  op = nil
  File.open("bayes_data", "r") do |f|
    op = Marshal.load(f)
  end
rescue
  op = Classifier::Bayes.new("a","b","c")
end

me = MeCab::Tagger.new("-O wakati")

File.open("train.csv") do |f|
  while l = f.gets
    a = l.split(',')
    a[1].chomp!
    op.train(a[1], me.parse(a[0]))
  end
end

s = "もうやめたい"
puts s
sj = me.parse(s)
a = ["もう","やめ","たい"]
aj = a.join(" ")
puts op.classifications(sj).inspect
puts op.classify(sj)
p op

File.open("bayes_data", "wb") do |f|
  Marshal.dump(op, f)
end
