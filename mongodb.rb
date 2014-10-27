require 'mongo'
require 'pp'
require 'inifile'  

include Mongo

###################mongodb class ##############################################
class GFS
 
      begin
         @@config = IniFile::load("database.conf")  
         data = @@config["DB_info"]   
      rescue Exception => e
         puts "Unable to  open config file , Message: #{e}"
         exit
      end

 
      begin  
         @@connection = MongoReplicaSetClient.new([data["address"]], :name =>  data["ReplicaName"] ,  :pool_size => 200, :pool_timeout => 10)
         @@db=@@connection.db(data["db_name"])
         @@db.authenticate(data["userne"], data["passwd"]) 
         @@coll = @@db[data["collection_name"]]
         @@fs = GridFileSystem.new(@@db)
      rescue Exception => e 
         puts "Unable to connect database , Message: #{e}"
         exit
      end


   def initialize()
      #puts "class init"
      #begin
      #   config = IniFile::load( "database.conf" ) 
      #   data = config["DB_info"]
      #rescue Exception => e
      #   puts "Unable to  open config file , Message: #{e}" 
      #   exit
      #end

      #puts "read config file OK"
      #make a connection 
      #If you want to read from a secondary node, you can pass :read => :secondary to ReplSetConnection#new. 
      #@connection = ReplSetConnection.new(['10.111.9.133:27017', '10.111.9.135:27017', '10.111.9.224:27017'],:read => :secondary)
      #begin
      #   puts "begin connection DB"
        # @@connection = MongoReplicaSetClient.new([data["address"]], :name => data["ReplicaName"])
         #puts "client OK"
         #@@db=@@connection.db(data["db_name"])
         #@@db.authenticate(data["userne"], data["passwd"]) 
         #@@coll = @@db[data["collection_name"]]
         #@@fs = GridFileSystem.new(@@db)
      #rescue Exception => e
      #   puts "Unable to connect database , Message: #{e}"
      #   exit
      #end
      #puts "init over"

   end
   
   def insert_text(_name,_email,_phonenumber,_filepath,_filetext) 
      
      #puts "split filename: "+_filepath 
      filenames = _filepath.split(".") 
      filename=_name+"_"+_email+"_"+_phonenumber+'.'+filenames[-1]
 
      #store file make sure filename does not repeat
      begin
         cvdata = File.open(_filepath)
         @@fs.open(filename, "w", :delete_old => true) do |f|
            f.write cvdata
         end
      rescue Exception => e
         puts "Unable to store file , Message: #{e}"
         exit
      end
      # Read it and print the contents to local FS
      #file = grid.get(id)
      #puts file.read
     
      #insert returns ObjectId for this record
      begin  
         insert_result =@@coll.insert('name' => _name,"email" => _email,"phone" => _phonenumber,"filename" => filename,"filetext" => _filetext)
         #puts insert_result
      rescue Exception => e
         puts "Unable to store CV information , Message: #{e}"
         del_cv(filename)
         exit
      end
      #query all records
      #coll.find().each { |row| pp row }
 
   end 

   #delete file from MongoDB GridFS 
   def del_cv(_filename)
      #puts("delete cv files "+_filename)
      @@fs.delete(_filename)
   end

   def sea_cv(*_args)
      #puts _args.inspect
      sea_strs = "" 
      for sea_str in _args
         #print sea_str, "\n"
          sea_strs = sea_strs +"'$regex'=>'"+sea_str+"'," 
      end
      #puts sea_strs
      strq = "{'filetext'=>{"+sea_strs.chop+"}}"
      #puts strq
      #coll.find(eval(strq)).each { |row| pp row }
   end


   #attr_reader attr_writer attr_accessor
   attr_accessor :db , :connection , :fs , :coll ,:config ,:data
   attr_reader   :userne , :passwd

end


###################test class ##################################################
   #gfs = GFS.new
   #gfs.insert_text("jiafeiz","jiafeiz@vmware.com","21321321312312","/root/Downloads/Test_CVs/HenryChai.doc","filetext_test")
   # delete files (_filename) from MongDB GridFS 
   # gfs.del_cv("jiafeiz_jiafeiz@vmware.com_21321321312312.doc")
   # gfs.sea_cv("linux","centos","fedora","suse","ubuntu")
   


