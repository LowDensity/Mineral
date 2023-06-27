require 'Pathname'
#Geology 參數解讀器
module Mineral

    print_version("Mineral.Geology.rb",0,2,0)
    #Mineral專用的參數讀取器
    class Geology
        attr_reader :action     #要執行的動作
        attr_reader :base       #來源資料夾
        attr_reader :tgt        #目標資料夾
        attr_reader :vein       #vein資料夾的位置
        attr_reader :veinless   #不使用vein結構

        def initialize(args)
            #先假設第0個元素一定是action。
            raise "Invalid Action" if(!/^\w+$/.match?(args[0])) 
            @action =args[0].to_sym
            @argmap = create_argmap(args[1,args.length-1])
			set_instancevars
        end

        def create_argmap(args)
            argmap = {}
            cur_key = ""
            for i in 0...args.length
                arg = args[i]
                next argmap[cur_key=/\w+/.match(arg)[0]] = [] if(/^-\w+$/.match?(arg))
                argmap[cur_key].push(arg)
            end
            argmap.select{|arx| arx.length!=0}
        end
	
	
		def set_instancevars() 
            @base = @argmap["base"].nil?	?	nil	:	@argmap["base"][0].gsub(/\\+/, '/')
            @tgt =  @argmap["tgt"].nil?		?	nil	:	@argmap["tgt"][0].gsub(/\\+/, '/')
            @vein = @argmap["vein"].nil?	?	nil	:	@argmap["vein"][0].gsub(/\\+/, '/')
            raise "option : -veinless is not implemented" if !@argmap["veinless"].nil? 
            @veinless =  false #尚未實作前先強制false
        end 

        #檢查指定的資料夾是否存在，如果不存在，是否要建立。
        # dirs  = 資料夾陣列
        # create_if_notexist =  如果不存在，是否要建立。<預設：false>
        # foundation = 最多往回建造幾層。<預設:1> 
        #    ex-1 :
        #     指定資料夾： D:\AA\BB\CC
        #            當下資料夾結構： D:\AA，foundation = 1
        #            則：先建立 BB、再在BB下建立CC
        #    ex-2 L 
        #     指定資料夾： D:\AA\BB\CC\DD
        #            當下資料夾結構： D:\AA，foundation = 1
        #            則：因為以當下狀況，會需要建立BB、CC，共2層資料夾才能建立DD，所以會拋出錯誤並且不會作任何動作。
        def surveil(dirs,create_if_notexist= false,foundation=1)
			puts "begin surveil"
            dirs_notexist = Array.new
			dirs.each do  |dir|
				next if Dir.exist? dir
				if !create_if_notexist
					dirs_notexist.push("folder : #{dir} does not exist , and create_if_notexist is set to #{create_if_notexist}") 
				else
					dirs_notexist.push(dir)
				end
            end
            raise dirs_notexist.join("\n") if !create_if_notexist  &&  dirs_notexist.compact.any?
            dirs_uncreateable=dirs_notexist.map do |dir|
                path = Pathname.new(dir)
				can_create = false
                #往回找 foundation 層
                for level in 0...foundation
                    path = path.parent
                    break if can_create= path.exist?
                end
                can_create ? nil :"#{dir} is uncreateable while foundation is set to #{foundation}"
            end
            #只要有任何一個無法建立的，就丟出錯誤。
			dirs_uncreateable.compact!
            raise dirs_uncreateable.join("\n") if dirs_uncreateable.any?

            #待建立的所有資料夾清單。(包含上層資料夾)
            dirs_tocreate = []

            #實際產生資料夾建立清單。注意這邊的資料夾順序會是 目標資料夾、目標資料夾上一層、目標資料夾上二層
            #因此後面要反轉過才是可以用來建立資料夾的狀態。
            dirs_notexist.each do |dir|
                path = Pathname.new(dir)
				hierachies_tocreate = [path]
                for level in 0...foundation
                    path = path.parent
					hierachies_tocreate.push(path)
                    break if path.parent.exist?
                end
				dirs_tocreate = dirs_tocreate + hierachies_tocreate.reverse
            end
            #實際建立每一個資料夾
			
			dirs_tocreate.each do |dir|
				next  puts "folder #{dir} already exists skipping." if Dir.exist? dir
				puts "making dir=> #{dir}"
                Dir.mkdir(dir)
            end
        end

    end


end
