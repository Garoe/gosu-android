require 'rake'
#gem root -> where the gem is located
gem_root = File.expand_path(File.dirname(__FILE__))
#Delete last occurence of /commands
gem_root = gem_root.reverse.sub( "commands".reverse, '' ).reverse
require gem_root + "version.rb"

module Gosu
  module Commands
    module Base

      def self.show_help
        puts "Usage: gosu_android OPTION"
        puts "Adds or deletes dependencies for Gosu in a Ruboto project."
        puts "If no argument is specified it displays this help."  
        puts ""
        puts " -a, --add adds the files to the project"
        puts " -d, --delete deletes the files from the project"
        puts " -v, --version shows current version"
        puts " -h, --help display this help and exit"
        puts ""
        puts "The options -a and -d can not be given together."
        puts ""
        puts "Exit status:"
        puts " 0 if everything went ok,"
        puts " 1 if there was some error."
      end 
      
      def self.add_files 
        #root -> user directory
        root = Dir.pwd
        #gem root -> where the gem is located
        gem_root = File.expand_path(File.dirname(__FILE__))
        #Delete last occurence of /commands
        gem_root = gem_root.reverse.sub( "/commands".reverse, '' ).reverse

        #Add * to read all files in folder
        gem_root_s = gem_root + "/*"
        gem_root_ss = gem_root + "/*/*"
        
        #Get all the files needed for gosu android
        lib_files = FileList[ gem_root_s, gem_root_ss ].to_a
        #List of not usefull files
        not_copy_files = ["commands", "description", "version"]  
        
        #Do not copy the ones that are not needed
        not_copy_files.each do |not_copy|
          lib_files.delete_if do |element|
            element.include? not_copy 
          end
        end
        
        #Copy the files
        lib_files.each do |file|     
          src = String.new file     
          file.slice!(gem_root) 
          dst = root + '/src/gosu_android' + file 
          FileUtils.mkdir_p(File.dirname(dst))
          if file.include? ".rb"
            FileUtils.cp(src, dst)   
          end     
        end
        
        #Main file and jar dependencies go in different folders
        #than normal files
        #Delete last occurence of /gosu_android
        gem_root = gem_root.reverse.sub( "/gosu_android".reverse, '' ).reverse

        src = gem_root + "/gosu.rb"
        dst = root + "/src/gosu.rb"
        FileUtils.cp(src, dst)  
        src = gem_root + "/gosu.java.jar"
        dst = root + "/libs/gosu.java.jar"
        FileUtils.cp(src, dst)  
        
        #Resources files
        #Delete last occurence of /lib
        gem_root = gem_root.reverse.sub( "/lib".reverse, '' ).reverse
        gem_root_s = gem_root + "/res/*"
        gem_root_ss = gem_root + "/res/*/**"
        
        #Get all resources
        lib_files = FileList[ gem_root_s, gem_root_ss ].to_a   

        #Copy the resources
        lib_files.each do |file|     
          src = String.new file     
          file.slice!(gem_root) 
          dst = root + file
          FileUtils.mkdir_p(File.dirname(dst))
          if file.include? "."
            FileUtils.cp(src, dst)   
          end     
        end   
            
      end
      
      def self.delete_files 
        root = Dir.pwd
        
        #Deleting whole gosu_android folder
        to_delete = root + "/src/gosu_android"   
        begin        
          FileUtils.rm_rf to_delete        
        rescue => e
          $stderr.puts e.message
        end  
        
        #Deleting gosu.rb file
        to_delete = root + "/src/gosu.rb"
        begin    
          File.delete to_delete        
        rescue => e
          $stderr.puts e.message
        end 
        
        #Deleting gosu.java.jar file
        to_delete = root + "/libs/gosu.java.jar"
        begin     
          File.delete to_delete        
        rescue => e
          $stderr.puts e.message
        end        
        
        #gem root -> where the gem is located
        gem_root = File.expand_path(File.dirname(__FILE__))
        gem_root = gem_root.reverse.sub( "/gosu_android/commands".reverse, '' ).reverse

        #Resources files
        #Delete last occurence of /lib
        gem_root = gem_root.reverse.sub( "/lib".reverse, '' ).reverse
        gem_root_s = gem_root + "/res/*"
        gem_root_ss = gem_root + "/res/*/**"
        
        #Get all resources
        lib_files = FileList[ gem_root_s, gem_root_ss ].to_a   

        #Delete only the previous copied resources
        lib_files.each do |file|      
          file.slice!(gem_root) 
          to_delete = root + file
          if file.include? "."
            begin     
              File.delete to_delete        
            rescue => e
              $stderr.puts e.message
            end   
          end     
        end          
        
      end 

      def self.main
       add = false
       delete = false
       help = false
       version = false
        ARGV.each do|a|
          case a
          when "-a" 
            add = true
          when "--add"
            add = true
          when "-d"
            delete = true
          when "--delete" 
            delete = true
          when "-h" 
            help = true
          when "--help"
            help = true
          when "-v" 
            version = true
          when "--version"
            version = true            
          end    
        end
        
        if help or not add and not delete and not version
          show_help
          exit 0
        end
        
        if version
        	puts Gosu::VERSION
        	exit 0
        end
        
        if add and delete
          $stderr.puts "Add and delete can not be perform at the same time\n"
          exit 1
        end 
                
        if add 
          add_files
          exit 0
        end    
        
        if delete 
          delete_files
          exit 0
        end 
      end
        
    end
  end
end
          
