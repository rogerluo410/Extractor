require 'timeout'

class Strategy
  @text  
  def initialize(text)
     @text = text
  end   
 
  attr_writer :text
  attr_reader :text
end #Strategy

class NameStrategy < Strategy

  def extract_name_by_re
    name = ''
    if (namecatch = /(name|Name|NAME)+([\:|\s|\,|\W]{1,})+([A-Za-z]+\s{0,})([A-Za-z]+)?/.match(@text) ) != nil
          nameescape = namecatch.to_s[4 ..-1]
       if (nametmp = /([A-Za-z]+\s{0,})([A-Za-z]+)/.match(nameescape) ) != nil
        name = nametmp.to_s
       end
    end   
    return name
  end

  def extract_name_from_firstline
      name = ''
      nametmp = ''
      @text.each_line do | line |
        if !line.empty? and line.strip.length != 0
         nametmp = line
         #In some cases,the first line is not name,but some titles such as 'Resume' ,'resume' and so on.
         if (nonnamecatch = /(Resume|resume|Page|page)/.match(line) ) == nil
             break
         end
        end
      end
      name_out =  nametmp.strip
      for i in (0...name_out.length)
         if  /[a-zA-Z]/.match(name_out[i])
             name << name_out[i]
         end
      end
      return name
  end

  #First name & Last name or Family name & Given name extract
  def extract_name_by_multi_name
      name = ''
      names_arr = []
      @text.scan(/(Family|FAMILY|family|First|first|FIRST|Given|GIVEN|given|LAST|Last|last){1}[\s|\W]{0,}(name|Name|NAME){1}([\:|\s|\,|\W]{1,})+([A-Z]{1}[A-Za-z]+)/) do | track |
          names_arr << track
      end 
      if names_arr.size == 2
         name = names_arr[0][-1] + names_arr[1][-1]
      end
      return name 
  end 

  def extract_name_interface
      name_out = ''
      stat = 0
      name = extract_name_by_multi_name()
      if name == ''
         stat = 1
         name = extract_name_by_re()
      end
      #if no name in resume, in most of situations,the first line is candidate's name. 
      if name == ''
         stat = 2
         name = extract_name_from_firstline()
         if name.length > 0
          stat = 3
         end
      end
       
      for i in (0...name.length)
         #escape some special characters in name.
         if /\n/.match(name[i])
            break
         end
         if name[i] == '|' and i != 0
            break
         end
         if not /\W/.match(name[i])
            name_out = name_out + name[i]
         end
      end
      puts "stat:"+stat.to_s
      return name_out
  end
end #NameStrategy

 
class EmailStrategy < Strategy

  def extract_email_by_re
     email = ''
     begin 
         timeout(100) do
          if (emailcheck = /(\w+-*[.|\w]*)*@(\w+[.])*\w+/.match(@text) ) != nil              
              email = emailcheck.to_s
          end
         end
     rescue Timeout::Error  
       puts "Seaching email timeout,maybe there is no email info in this resume,please check it by yourself."
       return email
     end
     return email
  end
   
  def extract_email_interface
     email = extract_email_by_re()
     return email
  end
end #EmailStrategy


class PhoneStrategy < Strategy
  
  def extract_phone_by_re
      phone = ''
      if (phonecheck = /([\(\+])?([0-9]{1,3}([\s])?)?([\+|\(|\-|\)|\s])?([0-9]{2,4})([\-|\)|\s]([\s])?)?([0-9]{2,4})+([\-|\s])?([0-9]{4,8})+([\-|\s])?([0-9]{3,8})?/.match(@text) ) != nil
         phone = phonecheck.to_s     
      end
      return phone  
  end

  def extract_phone_interface
      phone = extract_phone_by_re()
      phone_out = ""
      if phone
         #escape space in phone string.
         for i in (0...phone.length)
             if not /\s/.match(phone[i]) and phone[i] != nil
               phone_out << phone[i]
             end
         end
      end
      return phone_out
  end

end #PhoneStrategy
