require 'yomu'
require 'eventmachine'
require 'sinatra-websocket'
require 'sinatra'
require './extractstrategy'
require './mongodb'
class Extract
  @file_list 
  @task_list
  @dir_address
  @proc_record 

  def initialize(addr)
     @dir_address = addr
     @file_list = []
  end 
 
  def import_files_from_dir
      Dir.glob("#{@dir_address}/*").each do |f|
        if File.file?(f)
          puts "#{f}\n"
          splitlist = f.to_s.split('.')
          suffix = splitlist[-1]
          if suffix == 'doc' or suffix == 'docx' or suffix == 'pdf' or suffix == 'txt' or suffix == 'rtf'                          
            @file_list << f
            #puts f
          end
        end
      end
  end

  def extract_from_filelist(s)
     gfs = GFS.new
     strategy = Strategy.new('')
     name_extract = NameStrategy.new('')
     email_extract = EmailStrategy.new('')
     phone_extract = PhoneStrategy.new('')
     for i in (0...@file_list.length)
         yomu = Yomu.new @file_list[i]
         text = yomu.text
         name_extract.text=(text)
         email_extract.text=(text) 
         phone_extract.text=(text)
         name = name_extract.extract_name_interface()
         email = email_extract.extract_email_interface()
         phone = phone_extract.extract_phone_interface()
         puts @file_list[i] + ':'
         puts '['+name.to_s+'],[' + phone.to_s + '],[' + email.to_s + ']'
         puts '  '
         s.send('['+name.to_s+'],[' + phone.to_s + '],[' + email.to_s + ']')
         if name.strip.length != 0 and phone.strip.length != 0 and email.strip.length != 0
            gfs.insert_text(name,email,phone,@file_list[i],text)
            puts "Import Into DB successfully"
         end
       end
  end

end #Extract
