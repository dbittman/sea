# the more advanced toolchain builder

$binutils_ver = "2.22"
$gcc_ver      = "4.7.1"
$newlib_ver   = "1.20.0"

$gcc_download = "http://ftp.gnu.org/gnu/gcc/gcc-#{$gcc_ver}/gcc-#{$gcc_ver}.tar.gz"
$binutils_download = "http://ftp.gnu.org/gnu/binutils/binutils-#{$binutils_ver}.tar.gz"
$newlib_download = "ftp://sourceware.org/pub/newlib/newlib-1.20.0.tar.gz"

$install = ""
$target = ""

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

def download_extract_file(rpath)
	`wget #{rpath} -O #{File.basename(rpath)}`
	if ! $?.success? then error("downloading #{File.basename(rpath)} failed\n") end
	`tar xf #{File.basename(rpath)}`
	if ! $?.success? then error("extracting #{File.basename(rpath)} failed\n") end
end

def patch_binutils()
	Dir.chdir("binutils-#{$binutils_ver}")
	out = `patch -p1 -i ../binutils-#{$binutils_ver}-seaos.patch`
	if ! $?.success?
		puts(out)
		error("binutils patch failed")
	end
	`cp ../seaos_i386.sh ../seaos_x86_64.sh ld/emulparams/`
	Dir.chdir("..")
end

def patch_gcc()
	Dir.chdir("gcc-#{$gcc_ver}")
	out = `patch -p1 -i ../gcc-#{$gcc_ver}-seaos.patch`
	if ! $?.success?
		puts(out)
		error("gcc patch failed")
	end
	out = `patch -p1 -i ../gcc-4.7.2-texinfo.patch`
	if ! $?.success?
		puts(out)
		error("gcc texinfo patch failed")
	end
	`cp ../seaos.h ../seaos64.h gcc/config/`
	Dir.chdir("libstdc++-v3")
	out = `autoconf`
	if ! $?.success?
		puts(out)
		error("gcc autoconf failed")
	end
	Dir.chdir("..")
end

def patch_newlib()
	Dir.chdir("newlib-#{$newlib_ver}")
	out = `patch -p1 -i ../newlib-#{$newlib_ver}-seaos.patch`
	if ! $?.success?
		puts(out)
		error("newlib patch failed")
	end
	Dir.chdir("..")
end

def populate_newlib()
	if ! Dir.exist?("newlib-#{$newlib_ver}/newlib/libc/sys/seaos")
		Dir.mkdir("newlib-#{$newlib_ver}/newlib/libc/sys/seaos")
	end
	`cp -r newlib-sys-seaos/* newlib-#{$newlib_ver}/newlib/libc/sys/seaos/`
end

def create_build_dirs()
	if ! Dir.exist?("build-binutils-#{$binutils_ver}-#{$target}")
		Dir.mkdir("build-binutils-#{$binutils_ver}-#{$target}")
	end
	if ! Dir.exist?("build-gcc-#{$gcc_ver}-#{$target}")
		Dir.mkdir("build-gcc-#{$gcc_ver}-#{$target}")
	end
	if ! Dir.exist?("build-newlib-#{$newlib_ver}-#{$target}")
		Dir.mkdir("build-newlib-#{$newlib_ver}-#{$target}")
	end
end

def clean()
	`rm -r build-binutils-#{$binutils_ver}-#{$target}`
	`rm -r build-gcc-#{$gcc_ver}-#{$target}`
	`rm -r build-newlib-#{$newlib_ver}-#{$target}`
end

def conf_binutils()
	create_build_dirs()
	Dir.chdir("build-binutils-#{$binutils_ver}-#{$target}")
	`../binutils-#{$binutils_ver}/configure --target=#{$target} --prefix=#{$install} --disable-nls --disable-werror &> binutils-#{$binutils_ver}-configure-#{$target}.log`
	Dir.chdir("..")
end

def build_binutils()
	create_build_dirs()
	Dir.chdir("build-binutils-#{$binutils_ver}-#{$target}")
	`make -j3 MAKEINFO=makeinfo all install &> binutils-#{$binutils_ver}-build-#{$target}.log`
	Dir.chdir("..")
end

def conf_gcc()
	create_build_dirs()
	Dir.chdir("build-gcc-#{$gcc_ver}-#{$target}")
	`../gcc-#{$gcc_ver}/configure --target=#{$target} --prefix=#{$install} --enable-languages=c,c++ --enable-lto --disable-nls &> gcc-#{$gcc_ver}-configure-#{$target}.log`
	Dir.chdir("..")
end

def build_gcc()
	create_build_dirs()
	Dir.chdir("build-gcc-#{$gcc_ver}-#{$target}")
	`make -j3 all-gcc install-gcc &> gcc-#{$gcc_ver}-build-#{$target}.log`
	Dir.chdir("..")
end

def conf_newlib()
	create_build_dirs()
	
	Dir.chdir("newlib-#{$newlib_ver}/newlib/libc/sys")
	`autoconf &> newlib-#{$newlib_ver}-configure-#{$target}.log`
	if ! $?.success?
		error("error in autoconf of newlib (check newlib configure log)")
	end
	Dir.chdir("seaos")
	`autoreconf &>> newlib-#{$newlib_ver}-configure-#{$target}.log`
	if ! $?.success?
		error("error in autoreconf of newlib (check newlib configure log)")
	end
	Dir.chdir("../../../../..")
	Dir.chdir("build-newlib-#{$newlib_ver}-#{$target}")
	`../newlib-#{$newlib_ver}/configure --target=#{$target} --prefix=#{$install} &>> newlib-#{$newlib_ver}-configure-#{$target}.log`
	Dir.chdir("..")
end

def build_newlib()
	create_build_dirs()
	Dir.chdir("build-newlib-#{$newlib_ver}-#{$target}")
	`make all install &> newlib-#{$newlib_ver}-build-#{$target}.log`
	Dir.chdir("..")
end

def build_libgcc()
	create_build_dirs()
	Dir.chdir("build-gcc-#{$gcc_ver}-#{$target}")
	`make -j3 all-target-libgcc install-target-libgcc &> libgcc-#{$gcc_ver}-build-#{$target}.log`
	Dir.chdir("..")
end


def perform_action(act)
	
	puts "performing #{act}..."
	
	case act
	when "config-gcc"
		conf_gcc()
	when "config-binutils"
		conf_binutils()
	when "config-newlib"
		conf_newlib()
	
	when "download-gcc"
		download_extract_file($gcc_download)
	when "download-binutils"
		download_extract_file($binutils_download)
	when "download-newlib"
		download_extract_file($newlib_download)
	
	when "build-gcc"
		build_gcc()
	when "build-binutils"
		build_binutils()
	when "build-newlib"
		build_newlib()
	when "build-libgcc"
		build_libgcc()
	
	when "patch-gcc"
		patch_gcc()
	when "patch-binutils"
		patch_binutils()
	when "patch-newlib"
		patch_newlib()
	when "populate-newlib"
		populate_newlib()
	when "clean"
		clean()
	else
		error("unknown action: #{act}")
	end
	
	if ! $?.success?
		error("error in performing action #{act}")
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
	puts "  all-gcc            executes all gcc actions in the proper order."
	puts "                     does not include build-libgcc"
	puts "  all-binutils"
	puts "  all-newlib         includes build-libgcc"
	puts 
	puts "  clean              remove build files"
	puts "Note that most of these actions depend on other actions. 'all' is probably"
	puts "the best choice"
	puts "The install prefix is chosen by reading the file '../.toolchain', set"
	puts "by the configure script in the parent directory"
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

ENV["PATH"] = ENV["PATH"] + ":#{$install}/bin"

$actions = ARGV

printf "will perform actions: #{$actions.join(", ")}\ninstalling to: #{$install}\ntarget: #{$target}\n\npress enter to start..."
$stdin.gets

$actions.each do |a|
	if a == "all-gcc"
		perform_action("download-gcc")
		perform_action("patch-gcc")
		perform_action("config-gcc")
		perform_action("build-gcc")
	elsif a == "all-binutils"
		perform_action("download-binutils")
		perform_action("patch-binutils")
		perform_action("config-binutils")
		perform_action("build-binutils")
	elsif a == "all-newlib"
		perform_action("download-newlib")
		perform_action("patch-newlib")
		perform_action("populate-newlib")
		perform_action("config-newlib")
		perform_action("build-newlib")
		perform_action("build-libgcc")
	elsif a == "all"
		perform_action("download-binutils")
		perform_action("download-gcc")
		perform_action("download-newlib")
		perform_action("patch-gcc")
		perform_action("patch-binutils")
		perform_action("patch-newlib")
		perform_action("populate-newlib")
		
		perform_action("config-binutils")
		perform_action("build-binutils")
		
		perform_action("config-gcc")
		perform_action("build-gcc")
		
		perform_action("config-newlib")
		perform_action("build-newlib")
		
		perform_action("build-libgcc")
	else
		perform_action(a)
	end
end
