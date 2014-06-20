class Manifest
include Enumerable
# returns a hash of of hashes, referenced by package name
def initialize(lpath, rpath, name)
	@local = lpath
	@remote = rpath
	@name = name
	@packages = parse()
end

def each(&block)
	@packages.each(&block)
end

def each_value(&block)
	throw "Manifest Not Present (#{@name})" unless @packages != nil
	@packages.each_value(&block)
end

def read(name)
	return @packages[name.to_sym]
end

def write(name, value)
	@packages[name.to_sym] = value
end

def delete(name)
	@packages.delete(name.to_sym)
end

def get_remote_dir()
	return File.dirname(@remote)
end

def remote_sync
	puts "downloading #{File.basename(@remote)}"
	if !download_file(@remote + ".md5", nil, File.dirname(@local), "hash")
		puts "unable to download hash"
		return false
	end
	file = File.open(@local + ".md5")
	if !download_file(@remote, file.read, File.dirname(@local), File.basename(@remote))
		file.close
		puts "unable to download manifest #{File.basename(@remote)}"
		return false
	end
	file.close

	parse()
	return true
end

def parse
	ret = Hash.new
	if ! File.exist?(@local)
		@packages = ret
		return
	end
	file = File.open(@local)
	file.each_line{ |line|
		line.strip!
		if line.include?("#")
		line = line.slice(0..(line.index("#")))
		if line == "#"
			next
		end
		end
		if line == "" then next end
		vals = line.split(":")
		hash = Hash.new
		hash[:name] = vals[0]
		hash[:version] = vals[1]
		hash[:release] = vals[2]
		hash[:arch] = vals[3]
		hash[:deps] = vals[4]
		if vals[4].nil?
			hash[:deps] = ""
		end
		hash[:conflicts] = vals[5]
		if vals[5].nil?
			hash[:conflicts] = ""
		end
		hash[:manifest] = @name
		ret[vals[0].to_sym] = hash
	}
	@packages = ret
end

def flush
	file = File.open(@local, "w")
	@packages.each_value {|p|
		file.puts p[:name] + ":" + p[:version] + ":" + p[:release] + ":" + p[:arch] + ":" + p[:deps]
	}
	file.close
end

def loaded?
	return @packages != nil
end

def get_name
	return @name
end

end

def get_manifest(name)
	$manifests.each{ |m|
		if m.get_name == name
			return m
		end
	}
	return nil
end

