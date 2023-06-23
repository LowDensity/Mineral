@echo off
ruby "%~dp0\Mineral\Mineral.Main.rb" form -base "%~1" 
:: debug時將此行打開以避免視窗自動關閉。
::set /p dummy= Press Enter to quit
