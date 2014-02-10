#!/usr/bin/ruby

$packages = []
$make_flags = ""
$target=""
$install = ""
$verbose = false
$ignore_errors = "-i"

def select_target()
	printf "target selection (i586, x86_64) [i586]? "
	if ($target = $stdin.gets().chomp) == ""
		$target = "i586"
	end
	$target = $target + "-pc-seaos"
end

select_target()
$make_flags = "DESTDIR=\`pwd\`/../../../data-#{$target}/"
require "./ported/packages.rb"

def error(s)
	$stdout.puts(s)
	exit(1)
end

def download(p)
	puts "download #{p[P_NAME]}"
	if p[P_URL] == ""
		`mkdir -p #{p[P_NAME]}-#{p[P_VERSION]}`
		return
	end
	`wget #{p[P_URL]} -O #{File.basename(p[P_URL])}`
	if ! $?.success?
		error("failed to download #{p[P_NAME]}")
	end
end

def extract(p)
	puts "extract #{p[P_NAME]}"
	if ! File.exists?(File.basename(p[P_URL]))
		return
	end
	`tar xf #{File.basename(p[P_URL])}`
	if ! $?.success?
		error("failed to extract #{p[P_NAME]}")
	end
end

def patch(p)
	puts "patch #{p[P_NAME]}"
	if ! File.exist?("patches/#{p[P_NAME]}-#{p[P_VERSION]}-seaos.patch")
		return
	end
	Dir.chdir("#{p[P_NAME]}-#{p[P_VERSION]}")
	out = `patch -p1 -i ../patches/#{p[P_NAME]}-#{p[P_VERSION]}-seaos.patch`
	if $verbose then puts "#{out}" end
	Dir.chdir("..")
	if ! $?.success?
		error("failed to patch #{p[P_NAME]}")
	end
end

def inject(p)
	puts "inject #{p[P_NAME]}"
	if p[P_CONFIGSUB] != ""
		`cp -f scripts/config.sub #{p[P_NAME]}-#{p[P_VERSION]}/#{p[P_CONFIGSUB]}`
	end
	if ! File.exist?("files/#{p[P_NAME]}-#{p[P_VERSION]}")
		return
	end
	out = `cp -rfv files/#{p[P_NAME]}-#{p[P_VERSION]}/* #{p[P_NAME]}-#{p[P_VERSION]}`
	if $verbose then puts "#{out}" end
	if ! $?.success?
		error("failed to inject #{p[P_NAME]}")
	end
end

def prepare(p, num)
	puts "prepare-#{num} #{p[P_NAME]}"
	if ! File.exist?("scripts/#{p[P_NAME]}-#{p[P_VERSION]}-preparer-#{num}.sh")
		return
	end
	Dir.chdir("#{p[P_NAME]}-#{p[P_VERSION]}")
	out = `sh ../scripts/#{p[P_NAME]}-#{p[P_VERSION]}-preparer-#{num}.sh #{$target}`
	if $verbose then puts "#{out}" end
	Dir.chdir("..")
end

def configure(p)
	puts "configure #{p[P_NAME]}"
	`mkdir -p build-#{$target}-#{p[P_NAME]}-#{p[P_VERSION]}`
	Dir.chdir("build-#{$target}-#{p[P_NAME]}-#{p[P_VERSION]}")
	out=""
	if File.exists?("../#{p[P_NAME]}-#{p[P_VERSION]}/configure")
		out = `../#{p[P_NAME]}-#{p[P_VERSION]}/configure --#{p[P_HOSTORTARG]}=#{$target} --prefix=#{p[P_PREFIX]} #{p[P_CONFIG_F]}`
	end
	Dir.chdir("..")
	if $verbose then puts "#{out}" end
	if ! $?.success?
		if ! $verbose then puts "#{out}" end
		error("failed to configure #{p[P_NAME]}")
	end
end

def build(p)
	puts "build #{p[P_NAME]}"
	Dir.chdir("build-#{$target}-#{p[P_NAME]}-#{p[P_VERSION]}")
	out = ""
	if File.exists?("Makefile") or File.exists?("makefile")
		out = `make #{$make_flags} #{p[P_MAKE_F]} #{p[P_TARGETS]} #{$ignore_errors}`
	end
	Dir.chdir("..")
	if $verbose then puts "#{out}" end
	if ! $?.success?
		if ! $verbose then puts "#{out}" end
		error("failed to build #{p[P_NAME]}")
	end
end

def clean(p)
	puts "clean #{p[P_NAME]}"
	`rm -rf build-#{$target}-#{p[P_NAME]}-#{p[P_VERSION]}`
end

def clean_source(p)
	puts "cleansrc #{p[P_NAME]}"
	`rm -rf #{p[P_NAME]}-#{p[P_VERSION]} #{File.basename(p[P_URL])}`
end

def find_package(package)
	# gotta find the package data...
	$packages.each do |x|
		if !x.nil? and x[P_NAME] == package
			return x
		end
	end
	return nil
end

def do_package(action, pac_arr)
	case action
	when "download"
		download(pac_arr)
	when "extract"
		extract(pac_arr)
	when "patch"
		patch(pac_arr)
	when "inject"
		inject(pac_arr)
	when "prepare1"
		prepare(pac_arr, "1")
	when "config"
		configure(pac_arr)
	when "prepare2"
		prepare(pac_arr, "2")
	when "build"
		build(pac_arr)
	when "prepare3"
		prepare(pac_arr, "3")
	when "clean"
		clean(pac_arr)
	when "cleansrc"
		clean_source(pac_arr)
	when "all"
		download(pac_arr)
		extract(pac_arr)
		patch(pac_arr)
		inject(pac_arr)
		prepare(pac_arr, "1")
		configure(pac_arr)
		prepare(pac_arr, "2")
		build(pac_arr)
		prepare(pac_arr, "3")
	when "rebuild"
		clean(pac_arr)
		configure(pac_arr)
		prepare(pac_arr, "2")
		build(pac_arr)
		prepare(pac_arr, "3")
	end
	if pac_arr[P_COMMENT] != ""
		puts "#{pac_arr[P_COMMENT]}"
	end
end

file = File.open("../../.toolchain")
if ! file.nil?
	$install = file.gets.chomp
	file.close()
end

if $install == ""
	error("cannot detirmine toolchain path")
end

Dir.chdir("ported")

ENV["PATH"] = ENV["PATH"] + ":#{$install}/bin"

ARGV.each do |cmd|
	puts "perform: #{cmd}"
	act = cmd.split("-")
	if act[0].nil? or act[1].nil?
		error("invalid command: #{cmd}")
	end
	action = act[0]
	package = act[1]
	pac_arr = nil
	if package == "all"
		$packages.each do |q|
			do_package(action, q)
		end
	elsif
		pac_arr = find_package(package)
		if pac_arr.nil?
			error("could not find package #{package}")
		end
		do_package(action, pac_arr)
	end
end

Dir.chdir("..")
