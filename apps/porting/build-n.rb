#!/usr/bin/ruby
# the more advanced toolchain builder

$toolchain = ""
$target = nil
$reinstall = false
$reinstall_deps = false

$all_packs = []

require "digest/md5"
require "./var.rb"

def select_target()
	printf "target selection (i586, x86_64) [i586]? "
	if ($target = $stdin.gets().chomp) == ""
		$target = "i586"
	end
end

def error(s)
	printf "error: #{s}\n"
	exit 1
end

def download(package)
	if package[DT_VERSION].nil? then return false end
	if package[DT_REMOTE].nil? then return false end
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
	if package[DT_REMOTE].nil? then return false end
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
	`patch -p1 -N --dry-run --silent -i ../patches/#{patch_filename}`
	if ! $?.success? then
		`true`
		print "(skipping) "
		Dir.chdir("..")
		return true
	end
	`patch -p1 -N -i ../patches/#{patch_filename}`
	Dir.chdir("..")
	return true
end

def create_build_dir(package)
	if package[DT_VERSION].nil? then return false end
	if ! Dir.exist?("build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}")
		Dir.mkdir("build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}")
	end
	if ! Dir.exist?("install-base-#{$target}")
		Dir.mkdir("install-base-#{$target}")
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
	           when "cc_for_target"
		           conf.insert(-1, "CC_FOR_TARGET=#{$target}-gcc")
	           when "ar_for_target"
		           conf.insert(-1, "AR_FOR_TARGET=#{$target}-ar")
	           when "as_for_target"
		           conf.insert(-1, "AS_FOR_TARGET=#{$target}-as")
	           when "ranlib_for_target"
		           conf.insert(-1, "RANLIB_FOR_TARGET=#{$target}-ranlib")
	           when "strip_for_target"
		           conf.insert(-1, "STRIP_FOR_TARGET=#{$target}-strip")
	           end
	           }
	puts `pwd`
	puts "../#{package[DT_NAME]}-#{package[DT_VERSION]}/configure #{conf.join(" ")} #{package[DT_CONFIG]} &> #{package[DT_NAME]}-#{package[DT_VERSION]}-configure-#{$target}.log"
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
	           when "DESTDIR"
		           conf.insert(-1, "DESTDIR=#{`pwd`.chomp}/install-base-#{$target}")
	           when "cc_for_target"
		           conf.insert(-1, "CC_FOR_TARGET=#{$target}-gcc")
	           when "ar_for_target"
		           conf.insert(-1, "AR_FOR_TARGET=#{$target}-ar")
	           when "as_for_target"
		           conf.insert(-1, "AS_FOR_TARGET=#{$target}-as")
	           when "ranlib_for_target"
		           conf.insert(-1, "RANLIB_FOR_TARGET=#{$target}-ranlib")
	           when "strip_for_target"
		           conf.insert(-1, "STRIP_FOR_TARGET=#{$target}-strip")
	           end
	           }
	if package[DT_VERSION].nil? then
		Dir.chdir("build-#{package[DT_REMOTE]}-#{$target}")
		`make #{$make_flags} #{conf.join(" ")} #{package[DT_MAKE]} &> #{package[DT_NAME]}-build-#{$target}.log`
		Dir.chdir("..")
	else
		create_build_dir(package)
		Dir.chdir("build-#{package[DT_NAME]}-#{package[DT_VERSION]}-#{$target}")
		puts `pwd`
		puts "make #{$make_flags} #{conf.join(" ")} #{package[DT_MAKE]} &> #{package[DT_NAME]}-#{package[DT_VERSION]}-build-#{$target}.log"
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

def process_package(command, pack, isdep)
	act = "#{command}-#{pack[DT_NAME]}"
	ret = false
	case command
	when "download"
		ret = download(pack)
	when "extract"
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
	process_package(arr[0], pack, false)
end

def find_package(name)
	$downloads_table.each { |d| if d[DT_NAME] == name then return d; end }
	return nil
end

if ARGV.nil? or ARGV[0] == "" or ARGV[0] == "help" or ARGV[0] == "-h" or ARGV[0] == "--help" or ARGV.length == 0
	puts "seaos toolchain builder"
	puts "usage: build.rb [action1] [action2] ..."
	puts "each action will be executed in the order specified"
	puts "format for an action is '<command>-<package>'"
	puts "list of commands:"
	puts "  all                execute all build actions in the proper order"
	puts "  download           download the package source"
	puts "  extract            extract package source"
	puts "  patch              applies patch to package source"
	puts "  configure          run the configure script for the package"
	puts "  build              runs make for the package"
	puts "  cleansrc           removes package source directory"
	puts "  clean              removes package build files"
	puts "Note that most of these actions depend on other actions. 'all' is probably"
	puts "the best choice. The install prefix is chosen by reading the file"
	puts "'../.toolchain', which is set by the configure script in the parent directory."
	puts 
	puts "list of packages:"
	$downloads_table.each do |d| print "  #{d[DT_NAME]}"; if ! d[DT_VERSION].nil? then puts "-#{d[DT_VERSION]}" else puts end end
	puts
	puts "The output (and error message) from the sub-processes invoked by the actions"
	puts "will be redirected to a log file contained within the build directory"
	puts "associated with the current action."
	puts
	puts
	exit 0
end

ARGV.each do |a|
	arr = a.split("=")
	if ! arr[0][/^\-\-/].nil? then
		case arr[0][2..-1]
		when "target"
			if arr[1].nil? then error("must specify architecture when using --target") end
			$target = arr[1].clone
		end
	end
end

if $target.nil?
	select_target()
end
$target = $target + "-pc-seaos"

file = File.open("../../.toolchain")

if ! file.nil?
	$toolchain = file.gets.chomp
end

while $toolchain.nil? or $toolchain == ""
	printf "enter path to install toolchain to: "
	$toolchain = $stdin.gets.chomp
end

ENV["PATH"] = "#{$toolchain}/bin:" + ENV["PATH"]

$actions = ARGV

puts "target: #{$target}\n\n"
Dir.chdir("ported")
$list = []
flag = false
$actions.each do |a|
	if a[/^\-\-/].nil? then
		arr = a.split("-")
		if arr[0] == "all"
			if arr[1] == "all" then
				$downloads_table.each do |i|
					if $list.index(i).nil?
						$list.insert(-1, i)
					end
				end
			else
				pack = find_package(arr[1])
				if pack.nil? then error("could not resolve #{arr[1]}") end
				if $list.index(pack).nil?
					$list.insert(-1, pack)
				end
			end
			flag = true
		else
			perform_action(a)
		end
	end
end

if ! flag then exit 0 end

# calculate all needed packages
while $list.length > 0
	$all_packs.insert(0, $list.clone)
	arr = []
	$list.each do |l|
		deps = l[DT_DEPS]
		deps.each do |d|
			pack = find_package(d.split(" ")[0])
			if pack.nil? then error("could not resolve #{d.split(" ")[0]}") end
			if arr.index(pack).nil?
				arr.insert(-1, pack)
			end
		end
	end
	
	$list = arr.clone
end

# delete duplicates and generate depends
$all_packs.each do |a1|
	a1.each do |entry|
		$all_packs.each do |a2|
			if a1 != a2 then
				a2.each do |ent2|
					if ent2 == entry
						if $all_packs.index(a2) == $all_packs.length-1 then
							a1.delete(ent2)
						else
							a2.delete(ent2)
						end
					end
				end
			end
		end
	end
end
puts "selected packages:"
$all_packs.each do |a1|
	a1.each do |a2|
	  print a2[DT_NAME]
	  if ! a2[DT_VERSION].nil?
	    print "-#{a2[DT_VERSION]}"
	  end
	  print "  "
	end
end
puts "\n\npress enter to start"

$stdin.gets
# and install
$all_packs.each do |a1|
	a1.each do |a2|
		if $all_packs.index(a1) == ($all_packs.length-1)
			puts "performing all-#{a2[DT_NAME]}"
			process_package("all", a2, false)
		else
			puts "performing all-#{a2[DT_NAME]} (DEP)"
			process_package("all", a2, true)
		end
	end
end

exit 0
