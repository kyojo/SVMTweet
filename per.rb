require 'csv'
per = []

CSV.foreach("revised_data.csv") do |id|
  for x in 1..60
    case x
    when 2,4,5,6,7,10,11,13,17,19,20,21,22,25,26,28,32,34,36,37,40,43,47,49,50,51,52,53,56,58,60
      per[x] = 5 - id[x+26].to_i
    else
      per[x] = id[x+26].to_i - 1
    end
  end
  op = co =  ex = ag = ne = 0
  for x in 1..60
    case x
    when 1,6,11,16,21,26,31,36,41,46,51,56
      ne = ne + per[x]
    when 2,7,12,17,22,27,32,37,42,47,52,57
      ex = ex + per[x]
    when 3,8,13,18,23,28,33,38,43,48,53,58
      op = op + per[x]
    when 4,9,14,19,24,29,34,39,44,49,54,59
      ag = ag + per[x]
    when 5,10,15,20,25,30,35,40,45,50,55,60
      co = co + per[x]
    end
  end

  File.open("per.csv", "a") do |f|
    f.puts("#{id[0]},#{op},#{co},#{ex},#{ag},#{ne}")
  end
end
