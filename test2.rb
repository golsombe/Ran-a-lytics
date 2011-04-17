# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rubygems'
require 'ran_a_lytics.rb'
require 'active_record'

def grid(cols,rows)
	h = Hash.new 
	a = Array.new(height)
	#rows.collect {|row|  h[row.to_s] = {cols.each {|k,v| k.to_s => v}}  
	return a
end

class Array
  def to_h(&block)
    Hash[*self.collect { |v|
      [v, block.call(v)]
    }.flatten]
  end
end

puts "Gathering data"

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "metric_agent",
  :socket => "/tmp/mysql-ib.sock"
)
 
class MetricAgent < ActiveRecord::Base
 set_table_name "metric_agent"
 make_pivotable
end

start = Time.now()

@rows = ['KAssignment_dim_id as KAssignment']
@columns = ['year(date_id) as yr','month(date_id) as mth']
@measures = ['sum(AHT_score) as sum_aht_score', 'sum(calls_handled) as sum_calls_handled']

ucol = Array.new()
urow = Array.new()
ma = MetricAgent.PivotTable(:columns=> @columns,:rows=>@rows,:measures=>@measures)
endtime = Time.now()
puts 'Collect: ' + (endtime - start).to_s
start = Time.now()
ma.collect do |m|
	urow << m.KAssignment.delete("KAssignment")
	ucol  << [m.yr.delete("yr"),m.mth.delete("mth")].join('-')
end
grd = Array.new(urow.uniq.size+1)
cur = 0
g1 =0
g2 = 0
urow.uniq.sort!.each do |ur|
	r1 = 0
	r2 = 0
	out = Hash.new()
	out = {:KAssignment=> ur.to_s}
	sr = ma.select{|p| p.KAssignment == ur}
	ucol.uniq.sort!.each do |uc|
		m1 = 0
		m2 = 0
		sc = sr.select{|p| [p.yr,p.mth].join('-') == uc}
		sc.each  do |s| 
			m1 += s.sum_aht_score.to_f
			m2 += s.sum_calls_handled.to_f
		end
		r1+= m1
		r2+= m2
		out.merge!(uc.to_s => {'sum_aht_score' => m1, 'sum_call_handled' => m2})
	end
	g1 += r1
	g2 += r2
	out.merge!({'sum_aht_score' => r1, 'sum_calls_handled' => r2})
	grd[cur] = out
	cur += 1
end
grd[cur] = {'sum_aht_score' => g1, 'sum_calls_handled' => g2}
endtime = Time.now()
grd.each{|g| puts g.inspect}
puts 'Pivot: ' + (endtime - start).to_s