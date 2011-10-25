
# Not needed:
#require 'wcc'

class FilelogNotificator
	# wcc will create an instances of this class while reading the 'recipients'
	# section of the configuration. If a recipient has 'filelog' as a way to
	# notify her an instance will be created.
	def initialize
	end
	
	# Will be called when wcc decides to notify a recipient.
	def notify!(data)
		# try to load a template via the wcc main programm
		tpl = WCC::Prog.load_template 'filelog.erb'
		if tpl.nil?
			WCC.logger.warn "File log template 'filelog.erb' not found, using default."
			msg = "#{data.site.uri.to_s} changed at #{Time.now.to_s}"
		else
			msg = tpl.result(binding)
		end
		# use the :filelog_file stored in the WCC::Conf
		File.open(WCC::Conf[:filelog_file], 'a') do |f|
			f.puts msg
		end
	end
	
	# wcc will call this while reading the 'conf' section of the configuration.
	# If there is a 'filelog' entry present the parameter hash (if any) will go here
	# as conf parameter else it might be nil. This method is awaited to return a hash
	# which's keys and values (if any) will be stored in WCC::Conf - prefix them!
	def self.parse_conf(conf)
		if conf.is_a?(Hash)
			if conf['file'].nil?
				WCC.logger.fatal "Missing file log location!"
			else
				return {
					:filelog_file => conf['file']
				}
			end
		end
		# no defaults
		{}
	end
	
	# wcc will call this directly before terminating the main program.
	def self.shut_down; end
end

# Registers the FilelogNotificator class under name 'filelog' which makes wcc
# use this class whenever a 'filelog' is required.
WCC::Notificators.map "filelog", FilelogNotificator
