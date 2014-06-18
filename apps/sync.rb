def do_install(name)
	package = $manifest.read(name)
	if package.nil?
		puts "package '#{name}' not found"
		return false
	end
	print "installing #{name}"
	if ! $installed.read(name).nil?
		inst = $installed.read(name)
		if inst[:version] == package[:version] and inst[:release] == package[:release]
			print " -- reinstalling"
		else
			print " -- upgrading"
		end
	end
	puts

	rpath = File.dirname(REMOTE) + "/pkg/" + ARCH + "/" + package[:name] + "-" \
		+ package[:version] + "-" + package[:release] + "-" + ARCH + ".tar.xz"
	
	if ! download_file(rpath + ".md5", nil, LOCAL, "hash")
		return false
	end

	hash = File.open(LOCAL + "/" + File.basename(rpath) + ".md5", "r").read

	if ! download_file(rpath, hash, LOCAL, package[:name] + "-" + package[:version])
		return false
	end

	if !Dir.exist?("/tmp/ship-tmp")
		Dir.mkdir("/tmp/ship-tmp")
	end
	puts " * extracting"
	`cp #{LOCAL}/#{File.basename(rpath)} /tmp/ship-tmp/`
	if $? != 0
		return false
	end
	list = []
	Dir.chdir("/tmp/ship-tmp") {
		`tar xJf #{File.basename(rpath)}`
		if $? != 0
			return false
		end
		`mkdir install`
		Dir.chdir("/tmp/ship-tmp/#{package[:name]}-#{package[:version]}") {
			`cp *.manifest ../`
			`rm buildnr *.manifest`
			`cp -r * ../install`
		}
		
		archive = `tar tJf #{File.basename(rpath)}`.split("\n")
		archive.each{ |ent|
			file = ent.sub("#{package[:name]}-#{package[:version]}", "")
			if !(file == "/" or file == "/#{package[:name]}-#{package[:version]}.manifest" or file == "/buildnr")
				list << file
			end
		}

	}
	num=0
	list.each { |file|
		reset_line
		print " * installing files(#{num}/#{list.size}): "
		draw_progress(num, list.size)
		print " (installing #{File.basename(file)})"
		num += 1
		if file[-1] == '/' and !File.symlink?("/tmp/ship-tmp/install/#{file}")
			begin
				Dir.mkdir(ROOT + file)
			rescue
			end
		else
			`cp --no-dereference --preserve=mode,ownership,links -f \
			/tmp/ship-tmp/install/#{file} #{ROOT}/#{File.dirname(file)}/`
		end
	}
	reset_line
	puts " * installing files: success"
	`cp -rf /tmp/ship-tmp/*.manifest #{LOCAL}`
	`rm -rf /tmp/ship-tmp`

	fl = File.open("#{LOCAL}/" + package[:name] + "-" + package[:version] \
				   + "-" + package[:release] + "-" + ARCH + ".filelist", "w")
	fl.puts(list.join("\n"))
	fl.close
	$installed.write(name, $manifest.read(name))
	$installed.flush
	return true
end

def do_remove(name)
	package = $installed.read(name)
	if package.nil?
		puts "package '#{name}' not installed"
		return false
	end
	puts "removing #{name}"
	
	# remove files listed in filelist in reverse order
	list = File.open("#{LOCAL}/" + package[:name] + "-" + package[:version] \
				   + "-" + package[:release] + "-" + ARCH + ".filelist", "r").read.split("\n")
	num=0
	Dir.chdir(ROOT) {
		list.reverse_each{ |file|
			# Convert to current directory
			file = "." + file
			reset_line()
			print " * removing files (#{num}/#{list.size}): "
			draw_progress(num, list.size)
			print(" (removing #{File.basename(file)})")
			num += 1
			if Dir.exist?(file)
				if(Dir.entries(file) == [".", ".."]) # is empty?
					Dir.rmdir(file)
				end
			elsif File.exist?(file) or File.symlink?(file)
				File.delete(file)
			end
		}
		reset_line
		puts " * removing files: success"
	}

	$installed.delete(name)
	$installed.flush
	return true
end

def do_sync(list)
	list.each {|pac|
		name = pac.slice(1, pac.length-1)
		if(pac[0] == '+')
			if ! do_install(name) then return false end
		elsif(pac[0] == '-')
			if ! do_remove(name) then return false end
		else
			puts "error: unknown action for package: #{pac}"
			return false
		end
	}
end


