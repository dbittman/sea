def do_update(list)
	$manifests.each{ |m|
		m.remote_sync
	}
end

def do_upgrade(list)
	$old = $installed.dup
	$old.each_value { |pack|
		man = get_package(pack[:name])
		if man.nil?
			next
		end
		raise "wrong!" unless man[:name] == pack[:name]

		up=false
		if Gem::Version.new(pack[:version]) < Gem::Version.new(man[:version])
			up = true
		elsif Gem::Version.new(pack[:release]) < Gem::Version.new(man[:release])
			up=true
		end
		if up
			puts "upgrading #{pack[:name]}"
			do_install(pack[:name])
		else
			puts "skipping #{pack[:name]}"
		end
	}
end

def do_list(list)
	if(list.nil? or list.length == 0)
		$installed.each_value {|p|
			puts "#{p[:name]} - INSTALLED"
			puts "    " + p.to_s
		}
	else
		list.each {|p|
			list_files = false
			list_hash = true
			if p[0] == '+'
				p = p.sub("+", "")
				list_files = true
			elsif p[0] == '-'
				p = p.sub("-", "")
				list_hash = false
			end
			x = $installed.read(p)
			if !x.nil?
				puts "#{p} - INSTALLED"
			else
				x = get_package(p)
				if(!x.nil?)
					puts "#{p}"
				end
			end
			if x.nil?
				puts "#{p} - NOT FOUND"
			else
				if list_hash
					puts "    " + x.to_s
				end
				if list_files
					list = File.open("#{LOCAL}/" + x[:name] + "-" + x[:version] \
								+ "-" + x[:release] + "-" + ARCH + ".filelist", "r").read.split("\n")
					list.each {|f|
						puts (" :: #{f}")
					}
				end
			end
		}
	end
	return true
end


