module RanALytics
	module Pivot
	extend ActiveSupport::Concern
		module ClassMethods
			def pivotable?
			   true
			end
			def PivotTable(spec = nil)
				case spec
				when nil
				    raise "Not enough paramters specified"
				when Symbol, String
				    spec = spec.symbolize_keys
				end
				#Break out the SPEC into vars 
				columns = spec[:columns]
				rows = spec[:rows]
				measures = spec[:measures]
				conditions = spec[:conditions]
				joins = spec[:joins]

				#Clean up any SQL as stmnts				
				grpCols = Array.new
				grpRows = Array.new
				grpMeasures = Array.new
				columns.each{|r| grpCols << r.sub(/.* as /,'')}
				rows.each{|r| grpRows << r.sub(/.* as /,'')}
				measures.each{|r| grpMeasures << r.sub(/.* as /,'')}
	 			raw = self.find(:all, :select=> (rows + columns + measures).join(','), :joins => joins, :group=> (grpRows + grpCols).join(','),:order=>(grpRows + grpCols).join(','), :conditions=> conditions)
				turnMe(raw, :rows=>grpRows, :columns=>grpCols, :measures=>grpMeasures)
			end

			def turnMe(rset, spec)
				columns = spec[:columns]
				rows = spec[:rows]
				measures = spec[:measures]
				exp = ''
				#G are globals
				gblTotals = Array.new(measures.size)
				gblTotals.collect!{|m| m = 0}
				#r are rows
				rowTotals = gblTotals
				#m are measure
				msrTotals = gblTotals
				measureHash = Hash.new
				#c are columns
				colTotals = gblTotals
				columnHash = Hash.new
				
				ucol = Array.new()
				urow = Array.new()
				gen_row = ""
				gen_col = ""
			
				ma = rset
				ma.collect do |m|
					gen_row = rows.collect{|r| "m." + r.to_s + ".delete('" + r.to_s + "')"} 
					gen_col = columns.collect{|c| "m." + c.to_s + ".delete('" + c.to_s + "')"} 
					eval("urow << [" + gen_row.join(',') + "].join('-')")
					eval("ucol  << [" + gen_col.join(',') + "].join('-')")
				end
				grd = Array.new(urow.uniq.size+1)
				cur = 0
				gblTotals.collect!{|c| c = 0}
				urow.uniq.sort!.each do |ur|
					rowTotals.collect!{|m| m = 0}
					out = Hash.new()
					out = {"'" + rows.join('-') + "'" => "'" + ur.to_s + "'"}
					exp = "ma.select{|p| p." + rows.join('-') + "== '" + ur.to_s + "'}"
					sr = eval(exp)
					ucol.uniq.sort!.each do |uc|
						msrTotals.collect!{|mt| mt = 0}
						#sc = sr.select{|p| [p.yr,p.mth].join('-') == uc}
						exp = "sr.select{|q| q." + columns.join('-') + "=='" + uc.to_s + "'}"
						sc = eval(exp)
						sc.each  do |cCol| 
							msrTotals.each_index do |mt|
								msrTotals[mt] += eval("cCol." + measures[mt] + ".to_f")
								measureHash[measures[mt].to_s] = msrTotals[mt]
							end	
						end
						columnHash[uc.to_s] = measureHash
						
						rowTotals.each_index{|rt| rowTotals[rt] += msrTotals[rt]}
						out.merge!(columnHash)
					end
					gblTotals.each_index{|gt| gblTotals[gt] += rowTotals[gt]}
					measureHash.each_with_index do |msrArray,mi|
						measureHash[msrArray[0]] = rowTotals[mi]
					end
					out.merge!(measureHash)
					grd[cur] = out
					cur += 1
				end
				measureHash.each_with_index{|msrArray,mi| measureHash[msrArray[0]] = gblTotals[mi] }
				grd[cur] = measureHash
				endtime = Time.now()
				return grd
			end
		end
	end
end

