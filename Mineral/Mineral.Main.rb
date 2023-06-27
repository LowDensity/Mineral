#main entry point of Mineral
MINERAL_VERSION = "0.2.0" 
module Mineral

    #用來記錄這個程式現在有的功能。
    @@actions = []
    def self.actions 
         @@actions
    end
    
    def self.print_version(file_name , spec_version , api_level , revision)
        puts ''.ljust(4,' ') + file_name.ljust(25,'-') + 'v'+  [spec_version , api_level , revision].join(".")
    end

    def self.print_counter(count)
        print "*"		if count!=0 && count % 10==0
        print "\r\n"	if count!=0 && count % 100==0
        print '-'
        count+=1
    end


end
puts "Mineral , version #{MINERAL_VERSION}."
puts '======LOADING START====='
require_relative 'Mineral.Geology'
require_relative 'Mineral.Form'
require_relative 'Mineral.Sediment'
puts '======LOADING DONE======'
puts '======PROCESS START====='
begin
    
    geo=Mineral::Geology.new(ARGV)
    raise "Unknown action : #{ARGV[0]} " if !Mineral.actions.include?(geo.action)
    Mineral.send(geo.action,geo)
    
    ARGV.clear
rescue Exception => ex
    puts ex.message
    puts ex.backtrace
end

puts "All done , press Enter to exit"
STDIN.getc
    

