#!/usr/bin/ruby
# the more advanced toolchain builder

$install = ""
$target = ""

require "digest/md5"
require "./var-new.rb"

def select_target()
	printf "target selection (i586, x86_64) [i586]? "
	if ($target = $stdin.gets().chomp) == ""
		$target = "i586"
	end
	$target = $target + "-pc-seaos"
end

def error(s)
	printf "error: #{s}\n"
	exit 1
end

def download(package)
	if package[DT_VERSION].nil? then return false end
	print " * downloading: "
	begin
	file = File.open(File.basename(package[DT_REMOTE]))
	rescue
	end
	if ! file.nil? then
		hash = Digest::MD5.hexdigest(file.read)
		file.close
		if package[DT_HASH] == hash then
			print "(skipping) " 
			return true
		end
	end
	`wget #{package[DT_REMOTE]} -O #{File.basename(package[DT_REMOTE])}`
	begin
	file = File.open(File.basename(package[DT_REMOTE]))
	hash = Digest::MD5.hexdigest(file.read)
	file.close
	if package[DT_HASH] == hash then
		return true
	end
	rescue
	end
	error("Downloading #{package[0]} failed! (Couldn't download or bad hash)")
end

def extract(package)
	if package[DT_VERSION].nil? then return false end
	print " * extracting: "
	if ! Dir.exist?("#{package[DT_NAME]}-#{package[DT_VERSION]}") then
		`tar xf #{File.basename(package[DT_REMOTE])} 2>/dev/null`
		if ! $?.success? then error("extracting #{File.basename(package[DT_REMOTE])} failed\n") end
	else
		print "(skipping) "
	end
	return true
end

def patch(package)
	if package[DT_VERSION].nil? then return false end
	if ! package[DT_PATCH] then return false end
	print " * patching: "
	patch_filename = "#{package[DT_NAME]}-#{package[DT_VERSION]}-seaos-all.patch"
	Dir.chdir("#{package[DT_NAME]}-#{package[DT_VERSION]}")
	if package[DT_NAME] != "newlib" then
		`patch -p1 -N --dry-run --silent -i ../#{patch_filename}`
		if ! $?.success? then
			`true`
			print "(skipping) "
			Dir.chdir("..")
			return true
		end
	end
	`patch -p1 -N -i ../#{patch_filename}`
	Dir.chdir("..")
	return true
end

def create_build_dir(package)
	if package[DT_VERSION].nil? then return false end
	if ! Dir.exist?("build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}")
		Dir.mkdir("build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}")
	end
	return true
end

def clean(package)
	if package[DT_VERSION].nil? then return false end
	print " * cleaning build files: "
	`rm -r build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}`
	`true`
	return true
end

def cleansrc(package)
	if package[DT_VERSION].nil? then return false end
	print " * cleaning source: "
	`rm -r #{package[DT_NAME]}-#{package[DT_VERSION]}`
	`true`
	return true
end

def execute_command(package)
	if package[DT_COMMAND].nil? then return end
	`#{package[DT_COMMAND]}`
	if ! $?.success? then error("executing command '#{package[DT_COMMAND]}' for #{File.basename(package[DT_REMOTE])} failed\n") end
end

def configure(package)
	execute_command(package)
	if package[DT_VERSION].nil? then return false end
	create_build_dir(package)
	print " * configuring: "
	Dir.chdir("build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}")
	
	cross = package[DT_CROSS].split(" ")
	conf = []
	cross.each {|e|
	           case e
	           when "host"
		           conf.insert(-1, "--host=#{$target}")
	           when "target"
		           conf.insert(-1, "--target=#{$target}")
	           when "tarprefix"
		           conf.insert(-1, "--prefix=#{$install}/#{$target}")
	           when "prefix"
		           conf.insert(-1, "--prefix=#{$install}")
	           when "include"
		           conf.insert(-1, "--includedir=#{$install}/#{$target}/include")
	           when "oldinclude"
		           conf.insert(-1, "--oldincludedir=#{$install}/#{$target}/include")
	           end
	           }
	
	`../#{package[DT_NAME]}-#{package[DT_VERSION]}/configure #{conf.join(" ")} #{package[DT_CONFIG]} &> #{package[DT_NAME]}-#{package[DT_VERSION]}-configure-#{$target}.log`
	Dir.chdir("..")
	return true
end

def build(package)
	execute_command(package)
	print " * building: "
	cross = package[DT_MCROSS].split(" ")
	conf = []
	cross.each {|e|
	           case e
	           when "CC"
		           conf.insert(-1, "CC=#{$target}-gcc")
	           when "AR"
		           conf.insert(-1, "AR=#{$target}-ar")
	           when "RANLIB"
		           conf.insert(-1, "RANLIB=#{$target}-ranlib")
	           when "LD"
		           conf.insert(-1, "LD=#{$target}-ld")
	           end
	           }
	if package[DT_VERSION].nil? then
		Dir.chdir("build-#{package[DT_REMOTE]}-#{$target}")
		`make #{$make_flags} #{conf.join(" ")} #{package[DT_MAKE]} &> #{package[DT_NAME]}-build-#{$target}.log`
		Dir.chdir("..")
	else
		create_build_dir(package)
		Dir.chdir("build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}")
		`make #{$make_flags} #{conf.join(" ")} #{package[DT_MAKE]} &> #{package[DT_NAME]}-#{package[DT_VERSION]}-build-#{$target}.log`
		Dir.chdir("..")
	end
	return true
end

def check_error(act)
	if ! $?.nil? and ! $?.success? then
		error("FAILED\nerror in performing action #{act}")
	else
		puts "done"
	end
end

def perform_action(act)
	
	puts "performing #{act}..."
	pack = nil
	arr = act.split("-")
	
	if arr[1] == "all" then
		$downloads_table.each {|d| perform_action("#{arr[0]}-#{d[DT_NAME]}") }
		return
	end
	
	$downloads_table.each { |d| if d[DT_NAME] == arr[1] then pack = d; break end }
	
	if pack.nil? then error("unknown package: #{arr[1]}") end
	ret = false
	case arr[0]
	when "download"
		download(pack)
	when "extract"
		if pack[DT_NAME] == "newlib" then cleansrc(pack) end
		ret = extract(pack)
	when "patch"
		ret = patch(pack)
	when "configure"
		ret = configure(pack)
	when "build"
		ret = build(pack)
	when "clean"
		ret = clean(pack)
	when "cleansrc"
		ret = cleansrc(pack)
	when "all"
		if download(pack) then check_error(act) end
		if pack[DT_NAME] == "newlib" then cleansrc(pack); check_error(act) end
		if extract(pack) then check_error(act) end
		if patch(pack) then check_error(act) end
		if configure(pack) then check_error(act) end
		ret = build(pack)
	else
		error("unknown action: #{act}")
	end
	if ret then
		check_error(act)
	end
end

if ARGV.nil? or ARGV[0] == "" or ARGV[0] == "help" or ARGV[0] == "-h" or ARGV[0] == "--help" or ARGV.length == 0
	puts "seaos toolchain builder"
	puts "usage: build.rb [action1] [action2] ..."
	puts "each action will be executed in the order specified"
	puts "list of actions:"
	puts "  all                 execute all actions in the proper order"
	puts
	puts "  download-gcc"
	puts "  download-newlib"
	puts "  download-binutils"
	puts
	puts "  patch-gcc"
	puts "  patch-binutils"
	puts "  patch-newlib"
	puts "  populate-newlib    copies in seaos specific files into newlib"
	puts
	puts "  config-gcc         executes ./configure script for gcc"
	puts "  config-newlib"
	puts "  config-binutils"
	puts
	puts "  build-gcc"
	puts "  build-newlib"
	puts "  build-binutils"
	puts "  build-libgcc"
	puts 
	puts "  build-extra        builds extra libraries: mpfr, mpc, gmp, ncurses"
	puts "                     readline, and termcap"
	puts
	puts "  all-gcc            executes all gcc actions in the proper order."
	puts "                     does not include build-libgcc"
	puts "  all-binutils"
	puts "  all-newlib         includes build-libgcc"
	puts 
	puts "  mark-success       tells the build system that the toolchain is installed"
	puts "  clean              remove build files"
	puts "Note that most of these actions depend on other actions. 'all' is probably"
	puts "the best choice. The install prefix is chosen by reading the file"
	puts "'../.toolchain', which is set by the configure script in the parent directory."
	puts 
	puts "To change while tool version to build, edit var.rb to contain the proper"
	puts "version number."
	puts
	puts "The output (and error message) from the sub-processes invoked by the actions"
	puts "will be redirected to a log file contained within the build directory"
	puts "associated with the current action."
	puts
	puts "NOTE: you must specify a path to automake and aclocal version 1.12 for"
	puts "newlib to compile correctly!!"
	puts
	exit 0
end

select_target()

file = File.open("../.toolchain")

if ! file.nil?
	$install = file.gets.chomp
end

while $install.nil? or $install == ""
	printf "enter path to install toolchain to: "
	$install = $stdin.gets.chomp
end

ENV["PATH"] = "#{$install}/bin:" + ENV["PATH"]

$actions = ARGV

printf "will perform actions: #{$actions.join(", ")}\ninstalling to: #{$install}\ntarget: #{$target}\n\npress enter to start..."
$stdin.gets

$actions.each do |a|
	perform_action(a)
end
