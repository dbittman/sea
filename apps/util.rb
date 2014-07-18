# Simple progress bar
def draw_progress(complete, total)
	percent = (complete * 100) / total
	print "["
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
	printf "] %3d%%", percent
end

# clears entire line for the current line that this cursor is on. This only works
# for terminals that support this command, TODO: use termcap or something.
def reset_line()
	print("\r\e[0K")
end

# Download a file from <url>, with the known-good MD5 hash of <correcthash>, into the directory
# <local_dir>. <name> is the name to display while downloading. 
# local_dir defaults to ., name defaults to the basename of <url>
# and if correcthash is nil, the file is not checked. <url> is required.
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
	# it failed the hash test, or we can't verify. Re-download.
	if File.exists?(local_dir + "/" + File.basename(url))
		File.delete(local_dir + "/" + File.basename(url))
	end
	# calculate file size
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
				# need to redirect here...
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
	
	# fire off a new thread to run wget to actually download the file
	t = Thread.new {
		`wget -q #{url} -O #{local_dir}/#{File.basename(url)}`
		Thread.current[:output] = $?
	}
	time = 0
	while (t.alive?)
		# meanwhile, draw out the progress.
		sleep 0.1
		time += 1
		if ! File.exists?(local_dir + "/" + File.basename(url))
			next
		end
		cfs = File.size(local_dir + "/" + File.basename(url))
		reset_line()
		printf " * download#{name}: %4.2f/%4.2f MB", cfs.to_f / (1024*1024), file_size.to_f / (1024*1024)
		draw_progress(cfs, file_size.to_i)
		if time >= 10 then
			printf " (%5.3f MB/s)", (cfs.to_f / (time / 10))/(1024 * 1024)
		end
	end
	reset_line()
	print " * download#{name}:                                                                 \r"
	# return value of wget
	if t[:output] != 0
		print " * download#{name}: failed (wget returned #{t[:output]})\n"
		return false
	end
	# verify the download
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

# get a package hash from the manifests
def get_package(name)
	$manifests.each{|m|
		pack = m.read(name)
		if ! pack.nil? then return pack end
	}
	return nil
end

# is this package of this version installed?
def is_installed?(name, ver)
	if ver == "*"
		return ! $installed.read(name).nil?
	else
		return (!$installed.read(name).nil?) && $installed.read(name)[:version] == ver
	end
end

