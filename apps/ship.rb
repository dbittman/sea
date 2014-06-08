# Package Management System
require "net/http"
require "net/ftp"
require "uri"
require "digest/md5"

REMOTE = "http://dbittman.mooo.com/sea/repo/core.manifest"
LOCAL  = "local_database"
ARCH   = "x86"
ARCH2  = "i586"
ROOT   = "install-base-#{ARCH2}-pc-seaos"

$manifest = nil

def download_file(url, correcthash, local_dir, name)
	if name.nil?
		name = ""
	elsif name != ""
		name = " "+name
	end
	print " * download#{name}: \r"
	if local_dir.nil? or local_dir == ""
		local_dir = "."
	end
	begin
		file = File.open(local_dir + "/" + File.basename(url))
	rescue
	end
	if ! file.nil? and !hash.nil? then
		testhash = Digest::MD5.hexdigest(file.read)
		file.close
		if testhash == correcthash then
			puts " * download#{name}: (skipping) " 
			return true
		end
	end

	if File.exists?(local_dir + "/" + File.basename(url))
		File.delete(local_dir + "/" + File.basename(url))
	end
	file_size = 0
	remote = url
	uri = URI.parse(remote)

	case uri.scheme
	when "http"
		redir_count=0
		while file_size == 0
			http = Net::HTTP.new(uri.host, uri.port)
			response = http.request_head(uri.request_uri)
			case response
			when Net::HTTPRedirection
				redir_count += 1
				if redir_count > 16
					printf " * download#{name}: error: maximum redirect count reached\n"
					return false
				end
				printf " * download#{name}: redirecting...\n"
				remote = response['location']
				uri = URI.parse(remote)
			when Net::HTTPSuccess
				file_size = response['content-length']
				if(file_size == 0)
					printf " * download#{name}: error: unable to read content length\n"
					return false
				end
			else
				printf " * download#{name}: error: HTTP invalid response: #{response}\n"
				return false
			end
		end
	when "ftp"
		ftp = Net::FTP.new(uri.host)
		ftp.login
		file_size = ftp.size(uri.path)
		ftp.close
	end


	t = Thread.new {
		`wget -q #{url} -O #{local_dir}/#{File.basename(url)}`
		Thread.current[:output] = $?
	}
	time = 0
	while (t.alive?)
		sleep 0.1
		time += 1
		if ! File.exists?(local_dir + "/" + File.basename(url))
			next
		end
		cfs = File.size(local_dir + "/" + File.basename(url))
		percent = (cfs * 100) / file_size.to_i
		printf " * download#{name}: %4.2f/%4.2f MB [", cfs.to_f / (1024*1024), file_size.to_f / (1024*1024)
		num = percent / 5
		for i in 0..20
			if i < num then 
				print "=" 
			elsif i == num
				print ">"
			else
				print " "
			end
		end
		if time >= 10 then
			printf "] %3d%% (%5.3f MB/s)        \r", percent, (cfs.to_f / (time / 10))/(1024 * 1024)
		else
			printf "] %3d%%                     \r", percent
		end
	end
	print " * download#{name}:                                                                 \r"
	if t[:output] != 0
		print " * download#{name}: failed (wget returned #{t[:output]})\n"
		return false
	end
	if !correcthash.nil?
		begin
			file = File.open(local_dir + "/" + File.basename(url))
			downloaded_hash = Digest::MD5.hexdigest(file.read)
			file.close
			if downloaded_hash == correcthash then
				print " * download#{name}: success\n"
				return true
			end
		rescue
		end
		print " * download#{name}: error: could not verify hash\n"
	else
		print " * download#{name}: success\n"
		return true
	end
end

def write_manifest(path, hash)
	file = File.open(path, "w")
	hash.each_value {|p|
		file.puts p[:name] + ":" + p[:version] + ":" + p[:release] + ":" + p[:arch] + ":" + p[:deps]
	}
	file.close
end

# returns a hash of of hashes, referenced by package name
def parse_manifest(path)
	ret = Hash.new
	file = File.open(path)
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
		ret[vals[0].to_sym] = hash
	}
	return ret
end

def do_install(name)
	package = $manifest[name.to_sym]
	if package.nil?
		puts "package '#{name}' not found"
		return false
	end
	print "installing #{name}"
	if ! $installed[name.to_sym].nil?
		inst = $installed[name.to_sym]
		if inst[:version] == package[:version] and inst[:release] == package[:release]
			print " -- reinstalling"
		else
			print " -- upgrading"
		end
	end
	puts

	rpath = File.dirname(REMOTE) + "/pkg/" + ARCH + "/" + package[:name] + "-" + package[:version] + "-" + package[:release] + "-" + ARCH + ".tar.xz"
	
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
	}
	puts " * installing files"
	`cp -rf /tmp/ship-tmp/install/* #{ROOT}`
	`cp -rf /tmp/ship-tmp/*.manifest #{LOCAL}`
	`rm -rf /tmp/ship-tmp`

	$installed[name.to_sym] = $manifest[name.to_sym]
	write_manifest(LOCAL + "/installed.manifest", $installed)
	return true
end

def do_remove(name)
	package = $installed[name.to_sym]
	if package.nil?
		puts "package '#{name}' not installed"
		return false
	end
	puts "removing #{name}"

	$installed.delete(name.to_sym)
	write_manifest(LOCAL + "/installed.manifest", $installed)
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

def do_update(list)
	puts "downloading #{File.basename(REMOTE)}"
	if !download_file(REMOTE + ".md5", nil, LOCAL, "hash")
		puts "unable to download hash"
		return false
	end
	file = File.open(LOCAL + "/" + File.basename(REMOTE) + ".md5")
	if !download_file(REMOTE, file.read, LOCAL, File.basename(REMOTE))
		file.close
		puts "unable to download manifest"
		return false
	end
	file.close

	$manifest = parse_manifest(LOCAL + "/" + File.basename(REMOTE))
	return true
end

def do_upgrade(list)
	$old = $installed.dup
	$old.each_value { |pack|
		man = $manifest[pack[:name].to_sym]
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
			x = $installed[p.to_sym]
			if !x.nil?
				puts "#{p} - INSTALLED"
			else
				x = $manifest[p.to_sym]
				if(!x.nil?)
					puts "#{p}"
				end
			end
			if x.nil?
				puts "#{p} - NOT FOUND"
			else
				puts "    " + x.to_s
			end
		}
	end
	return true
end

def execute(type, list)
	if type != "update" and type != "" and !File.exists?(LOCAL + "/" + File.basename(REMOTE))
		puts "error: local manifest doesn't exist (run update)"
		return
	end
	r = false
	case type
	when "sync"
		r=do_sync(list)
	when "update"
		r=do_update(list)
	when "upgrade"
		r=do_upgrade(list)
	when "list"
		r=do_list(list)
	when ""
		return true
	else
		puts "error: type=#{type}, unknown"
	end
	return r
end


if ! Dir.exist?(LOCAL)
	Dir.mkdir(LOCAL)
end

if ! Dir.exist?(ROOT)
	Dir.mkdir(ROOT)
end
if File.exist?(LOCAL + "/" + File.basename(REMOTE))
	print "loading remote manifest..."
	$manifest = parse_manifest(LOCAL + "/" + File.basename(REMOTE))
	puts " ok"
end

if ! File.exist?(LOCAL + "/installed.manifest")
	File.new(LOCAL + "/installed.manifest", "w").close
end
print "loading local manifest..."
$installed = parse_manifest(LOCAL + "/installed.manifest")
puts " ok"

list = []
type = ""
ARGV.each { |arg|
	case arg
		when "sync", "update", "upgrade", "list"
			if ! execute(type, list)
				puts "quitting..."
				exit 1
			end
			list = []
			type = arg
		else
			ar = nil
			arg = arg.dup
			if /ALL$/ =~ arg
				ar = []
				$manifest.each_value{|x|
					ar << x[:name]
				}
				arg.slice!("ALL")
			elsif /INSTALLED$/ =~ arg
				ar = []
				$installed.each_value{|x|
					ar << x[:name]
				}
				arg.slice!("INSTALLED")
			end

			if !ar.nil?
				list += (arg + ar.join(" " + arg)).split(" ")
			else
				list << arg
			end
	end
}
execute(type, list)

