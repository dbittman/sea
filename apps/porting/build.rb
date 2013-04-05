$packages = []
$make_flags = "DESTDIR=\`pwd\`/../../../data-test/"
$target=""
$install = ""
require "./ported/packages.rb"

def select_target()
	printf "target selection (i586, x86_64) [i586]? "
	if ($target = $stdin.gets().chomp) == ""
		$target = "i586"
	end
	$target = $target + "-pc-seaos"
end

def error(s)
	$stdout.puts(s)
	exit(1)
end

def download(p)
	puts "download #{p[P_NAME]}"
	`wget #{p[P_URL]} -O #{File.basename(p[P_URL])}`
	if ! $?.success?
		error("failed to download #{p[P_NAME]}")
	end
end

def extract(p)
	puts "extract #{p[P_NAME]}"
	`tar xf #{File.basename(p[P_URL])}`
	if ! $?.success?
		error("failed to extract #{p[P_NAME]}")
	end
end

def patch(p)
	puts "patch #{p[P_NAME]}"
	Dir.chdir("#{p[P_NAME]}-#{p[P_VERSION]}")
	`patch -p1 -i ../patches/#{p[P_NAME]}-#{p[P_VERSION]}-seaos.patch`
	Dir.chdir("..")
	if ! $?.success?
		error("failed to patch #{p[P_NAME]}")
	end
end

def inject(p)
	puts "inject #{p[P_NAME]}"
	if ! File.exist?("files/#{p[P_NAME]}-#{p[P_VERSION]}")
		return
	end
	`cp -rf files/#{p[P_NAME]}-#{p[P_VERSION]}/* #{p[P_NAME]}-#{p[P_VERSION]}`
	if ! $?.success?
		error("failed to inject #{p[P_NAME]}")
	end
end

def configure(p)
	puts "configure #{p[P_NAME]}"
	`mkdir -p build-#{$target}-#{p[P_NAME]}-#{p[P_VERSION]}`
	Dir.chdir("build-#{$target}-#{p[P_NAME]}-#{p[P_VERSION]}")
	out = `../#{p[P_NAME]}-#{p[P_VERSION]}/configure --host=#{$target} --prefix=#{p[P_PREFIX]} #{p[P_CONFIG_F]}`
	Dir.chdir("..")
	if ! $?.success?
		puts "#{out}"
		error("failed to configure #{p[P_NAME]}")
	end
end

def build(p)
	puts "build #{p[P_NAME]}"
	Dir.chdir("build-#{$target}-#{p[P_NAME]}-#{p[P_VERSION]}")
	out = `make #{$make_flags} #{p[P_MAKE_F]} all install`
	Dir.chdir("..")
	if ! $?.success?
		puts "#{out}"
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
		if x[P_NAME] == package
			return x
		end
	end
	return nil
end

file = File.open("../../.toolchain")
if ! file.nil?
	$install = file.gets.chomp
	file.close()
end

if $install == ""
	error("cannot detirmine toolchain path")
end

select_target()

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
	pac_arr = find_package(package)
	if pac_arr.nil?
		error("could not find package #{package}")
	end
	case action
	when "download"
		download(pac_arr)
	when "extract"
		extract(pac_arr)
	when "patch"
		patch(pac_arr)
	when "inject"
		inject(pac_arr)
	when "config"
		configure(pac_arr)
	when "build"
		build(pac_arr)
	when "clean"
		clean(pac_arr)
	when "cleansrc"
		clean_source(pac_arr)
	when "all"
		download(pac_arr)
		extract(pac_arr)
		patch(pac_arr)
		inject(pac_arr)
		configure(pac_arr)
		build(pac_arr)
	end
end

Dir.chdir("..")
