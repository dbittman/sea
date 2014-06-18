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

def reset_line()
	print("\r\e[0K")
end

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
		reset_line()
		printf " * download#{name}: %4.2f/%4.2f MB", cfs.to_f / (1024*1024), file_size.to_f / (1024*1024)
		draw_progress(cfs, file_size.to_i)
		if time >= 10 then
			printf " (%5.3f MB/s)", (cfs.to_f / (time / 10))/(1024 * 1024)
		end
	end
	reset_line
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

