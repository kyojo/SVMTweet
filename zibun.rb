require 'csv'

CSV.foreach("kj114514150525.csv") do |id|
  temp = id[0] + "," + id[2]
  File.open("kj114514.csv", "a") do |r|
    r.puts(temp)
  end
end

