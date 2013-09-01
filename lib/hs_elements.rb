require_relative 'hs_element_methods'

class Shoes
    
    def handle_message(msg)
            if self.procs.include?(msg[1])
                event = msg[-1]
                last_active = @app.active_element
                @app.active_element = @app.elements[msg[0]].active if @app.elements[msg[0]].active
                self.procs[msg[1]].call(parse_js(event))
                @app.active_element = last_active
            else
                if msg[-1] == 'style'
                    self.style[msg[1]] = msg[2] unless msg[1] == 'text'
                    @app.shoes_thread.run if @app.shoes_thread.stop?
                end
            end
    end
    
    class Element < Shoes
        attr_accessor :id, :jqid, :procs, :style, :active, :position
        
        def initialize(element, style, text=nil)
            @id = "#{self.class}#{Time.now.to_f}"
            @jqid = %Q~$('[id="#{id}"]')~
            @procs = {}
            @style = {}
            @app = APPS[0]  ## have to change this for multiple apps
            @app.elements[self.to_s] = self
            if element == 'img'
                send_js %Q~#{@app.active_element}.append('<img id="#{self.id}" src="#{text}" alt="shoes image">')~
            elsif element == 'video'
                send_js %Q~#{@app.active_element}.append('<video id="#{self.id}" width="#{style[:width]}" height="#{style[:height]}" #{style[:controls]}><source src="#{text}" type="video/#{text.split('.')[-1]}">This browser does not support video tags</video>')~
            elsif element == 'audio'
                send_js %Q~#{@app.active_element}.append('<audio id="#{self.id}" #{style[:controls]}><source src="#{text}" type="audio/#{text.split('.')[-1]}">This browser does not support audio tags</video>')~
            else
                send_js %Q~#{@app.active_element}.append('<#{element} id="#{self.id}">#{text if text}</#{element}>')~
            end
            self.set_style(style) if style
        end
        
        def set_style(style)
            style.each{|key, val|
                val = "#{val}px" if val.class == Fixnum || val.class == Float
                k = key.to_s.gsub!("_", "-") || key
                v = val.to_s.gsub!("_", "-") || val
                self.style[k] = v
                send_js %Q~#{self.jqid}.css('#{k}', '#{v}')~
            }
            if style.keys.include?(:left) || style.keys.include?(:top) || style.keys.include?(:right) || style.keys.include?(:bottom)
                send_js %Q~#{self.jqid}.css('position', 'relative')~ unless style.keys.include?(:position)
            end
            @position = self.position
            
        end
        
        def method_missing(meth, *args, &block)
            method = meth.to_s.gsub('=', '')
            if args.empty?
                if self.style[method]
                    self.style[method]
                else
                    if meth == :text
                        send_js %Q~socket.send('#{self}#!!#text#!!#'+ #{self.jqid}.text() + '#!!#style')~
                        Thread.stop unless @app.shoes_thread.stop?
                        @app.message[2]
                    else
                        send_js %Q~socket.send('#{self}#!!#' + '#{method}#!!#'+ #{self.jqid}.css('#{method}') + '#!!#style')~
                        Thread.stop unless @app.shoes_thread.stop?
                        self.style[method]
                    end
                end
            else
                if meth == :text=
                    send_js %Q~#{self.jqid}.text('#{args[0]}')~
                else
                    if args[0].class == Fixnum || args[0].class == Float
                        val = "#{args[0]}px"
                    else
                        val = args[0]
                    end
                    if method == 'left' || method == 'top' || method == 'right' || method == 'bottom'
                        send_js %Q~#{self.jqid}.css('position', 'relative')~ unless @position == 'relative'
                        @position == 'relative'
                    end
                    send_js %Q~#{self.jqid}.css('#{method.gsub('_', '-')}', '#{val}')~
                    self.style[method] = val
                end
            end
        end
        
        def enable(shoes_method, jquery_function, block)
            send_js %Q~#{self.jqid}.#{jquery_function}(function(event){event.stopPropagation(); var shoes_event = to_json(event); socket.send('#{self}#!!##{shoes_method}#!!#' + shoes_event)})~
            self.procs[shoes_method] = block
        end
    end  #Shoes::Element
    
    class Button < Element
    end
    
    class Image < Element
    end
    
    class Text < Element
    end
    
    class Slot < Element
        def append
            last_active = @app.active_element
            @app.active_element = self.jqid
            yield
            @app.active_element = last_active
        end
    end
    
    class Stack < Slot
    end
    
    class Flow < Slot
    end
    
    class Shape < Element
        attr_accessor :context
        def append
            last_active = @app.active_element
            @app.active_element = self.jqid
            yield
            @app.active_element = last_active
        end
        
        def no_fill
            @fill = false
            draw
        end
        
        def no_stroke
            @stroke = false
            draw
        end
        
        def get_context
            @context = ("shape#{Time.now.to_f}").gsub!('.', '')
            send_js %Q~var #{@context} = #{self.jqid}[0].getContext("2d")~
            self.line_cap 'square'
            @stroke = true
        end
        
        def fill(color)
            @fill = true
            send_js %Q~#{self.context}.fillStyle="#{color}"~
            draw
        end
        
        def stroke(color)
            @stroke = true
            send_js %Q~#{self.context}.strokeStyle="#{color}"~
            draw
        end
        
        def draw
            send_js %Q~#{self.context}.fill()~ if @fill
            send_js %Q~#{self.context}.stroke()~ if @stroke
        end
        
        def move_to(x, y)
            send_js %Q~#{self.context}.moveTo(#{x}, #{y})~
        end
        
        def line_to(x, y)
            send_js %Q~#{self.context}.lineTo(#{x}, #{y})~
            draw
        end
        
        def line_width(w)
            send_js %Q~#{self.context}.lineWidth=#{w}~
            draw
        end
        
        def line_cap(c)
            send_js %Q~#{self.context}.lineCap='#{c}'~
            draw
        end
        
        def arc_to(start_x, start_y, end_x, end_y, radius)
            send_js %Q~#{self.context}.arcTo(#{start_x}, #{start_y}, #{end_x}, #{end_y}, #{radius})~
            draw
        end
        
        def arc(start_angle, end_angle, radius, dir)
            s_a = (start_angle - 90) * (Math::PI / 180)
            e_a = (end_angle - 90) * (Math::PI / 180)
            send_js %Q~#{self.context}.arc(#{radius}, #{radius}, #{radius}, #{s_a}, #{e_a}, #{dir})~
            draw
        end
        
        def curve_to(peak_x, peak_y, end_x, end_y)
            send_js %Q~#{self.context}.quadraticCurveTo(#{peak_x}, #{peak_y}, #{end_x}, #{end_y})~
        end
        
        def dbl_curve_to(x1, y1, x2, y2, end_x, end_y)
            send_js %Q~#{self.context}.bezierCurveTo(#{x1}, #{y1}, #{x2}, #{y2}, #{end_x}, #{end_y})~
        end
        
    end  #  Shape
    
    class Video < Element
    end
    
    class Audio < Element
    end
    
    class TimerBase < Shoes
        attr_accessor :active, :procs
        def initialize(type, time, block)
            @app = APPS[0]  ## UGLY!!!! #############
            @active = @app.active_element
            @procs = {'timer_block' => block}
            @var = "timer#{Time.now.to_i}"
            @time = time
            @running = false
            @app.elements[@var] = self
            case type
            when "animate"
                @timer = "setInterval"
            when "every"
                @timer = "setInterval"
            when "timer"
                @timer = "setTimeout"
            end
            start
            self
        end
        
        def start
            unless @running
                send_js %Q~#{@var} = #{@timer}(function(){socket.send('#{@var}#!!#timer_block')}, #{@time})~
                @running = true
            end
        end
        
        def stop
            if @running
                send_js %Q~clearInterval(#{@var})~ 
                @running = false
            end
        end
    end
    
    class Download
        attr_reader :progress, :content_length
        def initialize app, url, args, &blk
          @blk = blk
          start_download args, url
        end
        
        def started?
          @started
        end
        
        def finished?
            @finished
        end
        
        def join_thread
            @thread.join
        end
        
        private
        def start_download args, url
            require 'open-uri'
            @thread = Thread.new do
                options = {content_length_proc: lambda { |length| download_started(length) },
                progress_proc: lambda { |size| @progress = size }}
                open url, options do |download|
                    download_data = download.read
                    save_to_file(args[:save], download_data) if args[:save]
                    finish_download download_data
                end
            end
        end
        
        def finish_download download_data
          @finished = true
          result   = StringIO.new(download_data)
          eval_block(result) if @blk
        end
        
        def eval_block(result)
          @blk.call result
        end
        
        def save_to_file file_path, download_data
            open(file_path, 'wb') { |fw| fw.print download_data }
        end
        
        def download_started(length)
            @content_length = length
            @started = true
        end
    end  #Download
    
end  #class Shoes