
class Shoes
    attr_accessor :app##############
    APPS = []
    
    def self.app(opts={}, &block)
        link = "lib/hs_startup.html"
        
        if opts[:width] || opts[:height]
            opts[:width] ? width = opts[:width] : width = 600
            opts[:height] ? height = opts[:height] : height = 500
        else
            width = 600; height = 500
        end
        
        ### do all the options....
        
        left = 100; top = 20
        
        File.open(link, 'w+'){|startup|
            startup.puts %Q~<!DOCTYPE html><html><head><title>hot shoes startup</title><script>window.open("hot_shoes.html",'hot_shoes', 'fullscreen=no,toolbar=no,location=no,directories=no, status=no,menubar=no,scrollbars=no,resizable=yes,width=#{width}, height=#{height},left=#{left}, top=#{top}'); this.close()</script></head><body></body></html>~
        }
        
        if RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/
            system "start #{link}"
        elsif RbConfig::CONFIG['host_os'] =~ /darwin/
            system "open #{link}"
        elsif RbConfig::CONFIG['host_os'] =~ /linux|bsd/
            system "xdg-open #{link}"
        end
        
        @app = App.new(opts, &block)
    end  #Shoes.app
    
    def send_js(script)
        @app.socket.send %Q~<script>#{script}</script>~
    end
    
    def parse_js(js)
        JObject.new(js)
    end
    
    class JObject < Hash
        attr_accessor :str
        def initialize(string)
            string.gsub!(',', '!,!')
            string.gsub!(/\([^()]*\)(?![^\[]*\])/) do |parens|
                parens.gsub!('!,!', ',')
            end
            string.delete('{').delete('}').delete('"').split('!,!').each{|entry|
                self[entry.split(':')[0]] = entry.split(':')[1]
            }
        end
        
        def method_missing(method, *args, &block)           
            self[camel_case(method.to_s)]
        end
        
        def camel_case(string)
            if string.include?("_")
                words = string.split("_")
                words[1..-1].each{|w| w.capitalize!}
                words.join("")
            else
                string
            end
        end
    end #JObj
    
end  #class Shoes

require 'tempfile'
class File
  def self.prepend(path, string)
    Tempfile.open File.basename(path) do |tempfile|
      tempfile << string
      File.open(path, 'r+') do |file|
          arr = file.readlines
          arr[1..-1].each{|line| tempfile.puts(line)}
        file.pos = tempfile.pos = 0
        file << tempfile.read
      end
    end
  end
end