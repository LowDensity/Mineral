#main entry point of Mineral
#Version of Mineral 
MINERAL_VERSION=0.8

require_relative 'Mineral.Geology'
require_relative 'Mineral.Form'
require_relative 'Mineral.Sediment'

geo=Mineral::Geology.new(ARGV)
raise "Unknown action : #{ARGV[0]} " if !Mineral.actions.include?(geo.action)
Mineral.send(geo.action,geo)

ARGV.clear

p "All done , press Enter to exit"
gets