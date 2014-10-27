# http.rb
require 'sinatra'
require 'fiber'
require 'eventmachine'
require './extract'


class Http < Sinatra::Base
  get '/' do
    f = Fiber.current
    EM.add_timer(1) do
      f.resume("Hello World")
    end
    Fiber.yield
  end

  get '/upload' do
    fib = Fiber.current
    #operation = proc {
       EM.add_timer(1) do
        puts "request..."
        fib.resume("Uploading...")
        #addr = params[:address].rstrip
        addr = '/home/roger/Test_CVs'
        ext = Extract.new(addr)
        ext.import_files_from_dir()
        ext.extract_from_filelist()
       end
     #}
     #callback = proc { fib.resume("Upload Ok...") }

    #EM.defer operation, callback
    Fiber.yield
  end

  get '/test/:id' do
    fib = Fiber.current
    operation = proc {
       puts "request..."
     }
     callback = proc { fib.resume("Test successful...") }

    EM.defer operation, callback
    Fiber.yield
  end
end
