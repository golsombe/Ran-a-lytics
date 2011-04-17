require 'rubygems'
require 'active_record'
# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'ran_a_lytics/pivot.rb'

module RanALytics

def make_pivotable
     puts "This will make me pivotable"
     include Pivot
end

end

ActiveRecord::Base.extend RanALytics
