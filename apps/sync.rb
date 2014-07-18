def check_conflicts(list)
	list.each{|p|
		if(p[0] != '+')
			next
		end
		name = p.sub(p[0], "")
		conf = get_package(name)
		if conf.nil? 
			next
		end
		conf = conf[:conflicts]
		conf = conf.split(",")
		list.each{|other|
			if p == other then next end
			if other[0] != '+'
				next
			end
			on = other.sub(other[0], "")
			if conf.include?(on)
				puts "error: #{name} conflicts with #{on}"
				return false
			end
		}
	}
	return true
end

def resolve_deps(list)
	newlist = []
	num=0
	list.each {|name|
		action = ""
		if (name[0] =~ /[A-Za-z0-9]/).nil?
			action = name[0]
			name.sub!(name[0], "")
		end
		if action != "+"
			newlist << action + name
			next
		end
		if get_package(name).nil?
			puts "error: could not find or resolve #{name}"
			return nil
		end
		deps = get_package(name)[:deps].split(",")
		deps.each {|d|
			vn = d.split(' ')
			if ! is_installed?(vn[0], vn[1])
				if vn[1] == "*"
					dn = vn[0]
				else
					dn = d
				end
				if !list.include?(dn)
					newlist << action + dn
					num += 1
				end
			end
		}
		newlist << action + name
	}
	if num != 0
		return resolve_deps(newlist)
	end
	return newlist
end


def do_install(name)
	package = get_package(name)
	if package.nil?
		puts "package '#{name}' not found"
		return false
	end
	print "installing #{name}-#{package[:arch]}"
	if ! $installed.read(name).nil?
		inst = $installed.read(name)
		if inst[:version] == package[:version] and inst[:release] == package[:release]
			print " -- reinstalling"
		else
			print " -- upgrading"
		end
	end
	puts

	source = get_manifest(package[:manifest])
	throw "What the fuck?" unless source != nil
	rpath = source.get_remote_dir + "/pkg/" + ARCH + "/" + package[:name] + "-" \
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
	$installed.write(name, get_package(name))
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
	if check_conflicts(list) == false
		return false
	end
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

