#!/usr/bin/ruby

require "../var.rb"

$target = ""
$install = ""

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

def download()
	download_extract_file($gmp)
	download_extract_file($mpc)
	download_extract_file($mpfr)
	download_extract_file($readline)
	download_extract_file($ncurses)
	download_extract_file($termcap)
end

def do_build()
	puts " * termcap"
	Dir.chdir("termcap-#{$termcap_ver}")
	`./configure --host=#{$target} --prefix=#{$install}/#{$target} &> build.log`
	if ! $?.success? then error("build") end
	`make CC=#{$target}-gcc AR=#{$target}-ar RANLIB=#{$target}-ranlib &>> build.log`
	
	if ! $?.success? then error("build") end
	`make install &>> build.log`	
	if ! $?.success? then error("build") end

	puts " * ncurses"
	Dir.chdir("../ncurses-#{$ncurses_ver}")
	`./configure --host=#{$target} --prefix=#{$install} --enable-termcap --disable-database --without-cxx --without-cxx-binding --oldincludedir=#{$install}/#{$target}/include --includedir=#{$install}/#{$target}/include &>> build.log`
	if ! $?.success? then error("build") end
	`make all install &>> build.log`
	if ! $?.success? then error("build") end

	puts " * readline"
	Dir.chdir("../readline-#{$readline_ver}")
	`./configure --host=#{$target} --prefix=#{$install}/#{$target} --without-curses --disable-shared &>> build.log`
	if ! $?.success? then error("build") end
	`make all install &>> build.log`
	if ! $?.success? then error("build") end

	puts " * gmp"
	Dir.chdir("../gmp-#{$gmp_ver}")
	`./configure --host=#{$target} --prefix=#{$install}/#{$target} &>> build.log`
	if ! $?.success? then error("build") end
	`make all install &>> build.log`
	if ! $?.success? then error("build") end

	puts " * mpfr"
	Dir.chdir("../mpfr-#{$mpfr_ver}")
	`./configure --host=#{$target} --prefix=#{$install}/#{$target} CFLAGS='-fno-stack-protector' &>> build.log`
	if ! $?.success? then error("build") end
	`make CC=#{$target}-gcc AR=#{$target}-ar RANLIB=#{$target}-ranlib CFLAGS='-fno-stack-protector' &>> build.log`
	if ! $?.success? then error("build") end
	`make install &>> build.log`
	if ! $?.success? then error("build") end

	puts " * mpc"
	Dir.chdir("../mpc-#{$mpc_ver}")
	`./configure --host=#{$target} --prefix=#{$install}/#{$target} CC=#{$target}-gcc AR=#{$target}-ar LD=#{$target}-ld &>> build.log`
	if ! $?.success? then error("build") end
	`make all install &>> build.log`
	if ! $?.success? then error("build") end

end

def insert_config_sub()
	`cp config.sub ncurses-#{$ncurses_ver}/config.sub`
	`cp config.sub readline-#{$readline_ver}/support/config.sub`
	`cp config.sub gmp-#{$gmp_ver}/configfsf.sub`
	`cp config.sub mpc-#{$mpc_ver}/config.sub`
	`cp config.sub mpfr-#{$mpfr_ver}/config.sub`
end

if ARGV.nil? or ARGV.length < 2
	error("argv[0] must be the install path, ARGV[1] must be target!")
end

$install = ARGV[0]
$target = ARGV[1]

download()
puts "building extra libraries..."
insert_config_sub()
do_build()

