require 'csv'
cen = Array.new()
sample = 0

CSV.foreach("per.csv") do |id|
  for i in 0..4
    cen = id[i+1].to_i
  end
  sample += 1
end

for elm in ave
  elm /= sample
  puts elm
end
ave.map!{|item| item / sample}

p ave
p sample
