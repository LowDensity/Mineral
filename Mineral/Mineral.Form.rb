require 'fileutils'
require 'Pathname'
p 'Form VERSION 0.2.0'
module Mineral
        
    @@actions.push(:form)
    def self.form(geo)

	#先處理預設值問題，-base 參數必要參數。tgt 預設是 {-base的parent }/ Mine / vein /，vein則是預設放在tgt {-base的parent }/ Mine  / vein
	tgt_dir = geo.tgt
	if(tgt_dir.nil?)
		tgt_path  =Pathname.new(geo.base).parent
		tgt_dir = File.join(tgt_path,'Mine',tgt_path.basename)
	end
	
	vein_base = geo.vein
	if(vein_base.nil?)
		tgt_path  =Pathname.new(tgt_dir)
		vein_base =  File.join(tgt_path.parent,'Vein')
	end
	
	p "forming -base #{geo.base} , tgt = #{tgt_dir} , vein = #{vein_base}"
	
	
	
    #先找出直接的資料夾
    base_entries= Dir.glob("**/*",base:geo.base)
    tgt_entries = Dir.glob("**/*",base:tgt_dir)
        
        
    tgt_only =  tgt_entries - base_entries # 刪除目標資料夾中的檔案，並且移動到deleted資料夾中
    base_only = base_entries - tgt_entries #複製base_only到目標資料夾，並加入倒目標資料夾的ADD區塊中。
    common_entries = base_entries - base_only # 先一律採用base=> target的方式更新的原則。
    change_entries = common_entries.select{
        |ent|
        base_ent = File.join(geo.base,ent)
        tgt_ent = File.join(tgt_dir,ent)
        !FileUtils.compare_file(base_ent,tgt_ent)
    }
    
    # Vein資料夾結構
    vein_base_dir=File.join(vein_base,Time.now.strftime("%Y%m%d"))
    vein_base_count = Dir.glob(File.join(vein_base,"*")).select{|d|File.directory? d}.length
    vein_base_dir = vein_base_dir + "_#{vein_base_count+1}" if vein_base_count >0
    
    vein_added_dir=File.join(vein_base_dir,"addded")
    vein_deleted_dir=File.join(vein_base_dir,"deleted") 
    vein_changed_dir=File.join(vein_base_dir,"changed")
	
	dirs_tosurveil =[tgt_dir,vein_base_dir]

    # 更新重複檔案
    dirs_tosurveil << vein_base_dir		if  change_entries.any? | base_only.any? | tgt_only.any?  
    dirs_tosurveil << vein_added_dir	if  base_only.any?
    dirs_tosurveil << vein_deleted_dir	if  tgt_only.any?
    dirs_tosurveil << vein_changed_dir	if  change_entries.any?
	
	# 這邊最多建立兩層，第一層是 yyyyMMdd，第二層是 yyyyMMdd / added | changed | deleted
    geo.surveil(dirs_tosurveil,true,4)
    
    p "process added files"
    count =0
    base_only.each{
        |ent|
        count=Mineral.print_counter(count)
        FileUtils.cp(File.join(geo.base,ent)  ,tgt_dir)
        FileUtils.cp(File.join(geo.base,ent)  ,vein_added_dir)
    }
	print "\r\n"
    
    p "process changed files"
    count=0
    change_entries.each{
        |ent|
        count=Mineral.print_counter(count)
        base_ent = File.join(geo.base,ent)
        tgt_ent = File.join(tgt_dir,ent)
        FileUtils.cp(base_ent,vein_changed_dir) 
        FileUtils.cp(base_ent,tgt_ent) 
    }
    print "\r\n"
    
    p "process deleted files"
    count=0
    tgt_only.each{
        |ent|
		count=Mineral.print_counter(count)
        tgt_ent =File.join(tgt_dir,ent)
        FileUtils.cp(tgt_ent,vein_deleted_dir)
        FileUtils.rm(tgt_ent)
    }
    print "\r\n"
    p "done"
    
    end
end