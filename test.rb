# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rubygems'
require 'ran_a_lytics.rb'
require 'active_record'
require 'time'

puts "Gathering data"

ActiveRecord::Base.establish_connection(
  :adapter  => "mysql",
  :host     => "localhost",
  :username => "root",
  :password => "",
  :database => "carsales",
  :socket => "/tmp/mysql-ib.sock"
)

 
class FactSalesWide < ActiveRecord::Base
 set_table_name "fact_sales_wide"
 make_pivotable
end

starttime = Time.now
ma = FactSalesWide.PivotTable(:columns=> ['dlr_trans_type as Transaction'],:rows=>['dim_cars.make_name as make'],:measures=>['sum(sales_commission) as sum_sales_commission', 'sum(sales_discount) as sum_sales_discount'], :joins => ['JOIN dim_cars ON fact_sales_wide.make_id = dim_cars.make_id'])
endtime = Time.now
puts ma.to_json
#puts FactSalesWide.count.to_s + " Facts to " +  ma.size.to_s + " rows in " + (endtime - starttime).to_s


