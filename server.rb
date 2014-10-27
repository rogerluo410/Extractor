require 'rubygems'
require 'eventmachine'
require './extract' 


module Server
   def receive_data data 
     puts data

     operation = proc {
         
        addr = data.rstrip
        ext = Extract.new(addr)
        ext.import_files_from_dir()
        ext.extract_from_filelist()
     }
     callback = proc { send_data("Done\n") }

     EM.defer operation, callback
   end
end

EM.run { EM.start_server '0.0.0.0', 8080, Server } 
