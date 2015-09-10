require "gnuplot"
require "csv"
ag = ARGV[0].to_i

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.title  'test'
    plot.ylabel 'ylabel'
    plot.xlabel 'xlabel'
    y = Array.new(49, 0)

    x = (0..48).map{|v| v.to_f}
    CSV.foreach("per.csv") do |f|
      t = f[ag].to_i
      y[t] += 1
    end
    p y
    plot.data << Gnuplot::DataSet.new( [x, y] ) do |ds|
      ds.with = "lines"
      ds.notitle
    end
  end
end
