#!/usr/bin/env ruby

$target = nil
$arch = "x86"

$manifest_data = ""

def select_target()
	printf "target selection (i586, x86_64) [i586]? "
	$arch = "x86"
	if ($target = $stdin.gets().chomp) == ""
		$target = "i586"
	end
	if $target == "x86_64"
		$arch = "x86_64"
	end
end

def error(s)
	printf "error: #{s}\n"
	exit 1
end

def package(pack)
	# package it up!
	puts "packaging #{pack}..."
	$manifest_data << File.open(pack + "/" + pack + ".manifest", "r").read
	count = File.open(pack + "/buildnr", "r").read.to_i
	`tar -cJf packaged/pkg/#{$arch}/#{pack}-#{count}-#{$arch}.tar.xz #{pack}`
end

select_target()
`mkdir -p ported/install-bases-individual-#{$target}-pc-seaos/packaged/pkg/#{$arch}`
puts "scanning for packages..."

Dir.chdir("ported/install-bases-individual-#{$target}-pc-seaos")
Dir.foreach(".") { |pack|
	if pack == "." or pack == ".." or pack == "packaged"
		next
	end
	package(pack)
}

f = File.open("packaged/core.manifest", "w")
f.puts($manifest_data)
f.close
`md5sum packaged/core.manifest | awk '{print $1}' | tr -d '\n' > packaged/core.manifest.md5`

