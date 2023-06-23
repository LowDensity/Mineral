require 'Pathname'
module Mineral

    actions.push(:sediment)


    def self.sediment(geo)
		raise "tgt and base cannot be the same " if geo.tgt == geo.base
        # 抓取所有base中的資料
		base_entries= Dir.glob("**/*",base:geo.base)
		# 製作tgt資料夾。
		base= Pathname.new(geo.base)
		tgt_dir	= base.parent if geo.tgt.nil?
		tgt_count = Dir.glob(File.join(tgt_dir,"*")).select{|d|File.directory? d}.length
		tgt_dir	=File.join(tgt_dir,"#{base.basename}_#{Time.now.strftime("%Y%m%d")}_更新") 
		tgt_dir = tgt_dir + "#{tgt_count+1}" if tgt_count >0
		
		p "base => #{geo.base} , tgt => #{tgt_dir}"
		# 這邊設定最多10層以提高操作靈活度。
		geo.surveil([tgt_dir],true,10)
		# 無腦全部copy 過去。
		count=0
		base_entries.each{
        |ent|
        count=Mineral.print_counter(count)
        FileUtils.cp(File.join(geo.base,ent)  ,tgt_dir)
		}
		print "\r\n"
    end

end
