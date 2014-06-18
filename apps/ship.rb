#!/usr/bin/env ruby
# Package Management System
require "net/http"
require "net/ftp"
require "uri"
require "digest/md5"

require_relative "manifest.rb"
require_relative "util.rb"
require_relative "sync.rb"

REMOTE = "http://dbittman.mooo.com/sea/repo/core.manifest"
LOCAL  = "local_database"
ARCH   = "x86"
ARCH2  = "i586"
ROOT   = "porting/ported/install-base-#{ARCH2}-pc-seaos"

$manifest = nil

def is_installed?(name, ver)
	if ver == "*"
		return ! $installed.read(name).nil?
	else
		return (!$installed.read(name).nil?) && $installed.read(name)[:version] == ver
	end
end

def do_update(list)
	return $manifest.remote_sync
end

def do_upgrade(list)
	$old = $installed.dup
	$old.each_value { |pack|
		man = $manifest.read(pack[:name])
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
				x = $manifest.read(p)
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

def execute(type, list)
	if type == "" then return true end
	if type != "update" and type != "" and !File.exists?(LOCAL + "/" + File.basename(REMOTE))
		puts "error: local manifest doesn't exist (run update)"
		return
	end
	list.uniq!

	if type != "update" and type != "list"
	if list.size == 0 then return true end
	puts "--- perform action #{type} ---"
	puts "affected packages:"
	puts list.join(" ")
	
	print "\nContinue [Y/n]? "
	
	inp = $stdin.gets.chomp
	if inp == "n" or inp == "N" then return true end
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
		if $manifest.read(name).nil?
			puts "error: could not find or resolve #{name}"
			return nil
		end
		deps = $manifest.read(name)[:deps].split(",")
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

if ! Dir.exist?(LOCAL)
	Dir.mkdir(LOCAL)
end

if ! Dir.exist?(ROOT)
	`mkdir -p #{ROOT}`
end
if File.exist?(LOCAL + "/" + File.basename(REMOTE))
	print "loading remote manifest..."
	$manifest = Manifest.new(LOCAL + "/" + File.basename(REMOTE), REMOTE)
	puts " ok"
end

if ! File.exist?(LOCAL + "/installed.manifest")
	File.new(LOCAL + "/installed.manifest", "w").close
end
print "loading local manifest..."
$installed = Manifest.new(LOCAL + "/installed.manifest", nil)
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
				if !$manifest.nil?
					$manifest.each_value{|x|
						ar << x[:name]
					}
				end
				arg.slice!("ALL")
			elsif /INSTALLED$/ =~ arg
				ar = []
				$installed.each_value{|x|
					ar << x[:name]
				}
				arg.slice!("INSTALLED")
			end
			tmp_list = []
			if !ar.nil?
				tmp_list += (arg + ar.join(" " + arg)).split(" ")
			else
				tmp_list << arg
			end
			arr = resolve_deps(tmp_list)
			if arr.nil?
				next
			end
			list += arr
	end
}
execute(type, list)

