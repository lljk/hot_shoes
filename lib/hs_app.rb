
class App
    attr_accessor :elements, :active_element, :socket, :shoes_thread, :body, :message
    
    def initialize(opts, &block)
        Shoes::APPS << self
        if opts[:host] || opts[:port]
            opts[:host] ? host = opts[:host] : host = 'localhost'
            opts[:port] ? port = opts[:port] : port = 8080
        else
            host = 'localhost'; port = 8080
        end
        #File.prepend("#{Dir.getwd}/lib/hot_shoes.js", %Q~var url = "ws://#{host}:#{port}/";\n~)
        ###### UNCOMMENT TO CHANGE PORTS
        @elements = {}
        @active_element = %Q~$('body')~
        EM.run {
            puts "Open or refresh 'hot_shoes.html'..."
            EM::WebSocket.start(:host => host, :port => port) { |socket|
                @socket = socket
                socket.onopen { |handshake|
                    puts "WebSocket open on: #{host}, port #{port}"
                    @body = stack width: '100%', height: '100%', position: 'absolute', top: 0, left: 0, margin: 0, padding: 0 do
                        @shoes_thread = Thread.new{
                            send_js("var shoes_body = #{@body.jqid}")
                            @active_element = @body.jqid
                            self.instance_eval &block if block
                        }
                    end
                }
                socket.onmessage { |message|
                    msg = message.split('#!!#')
                    #puts "Recieved message: ' #{msg[0]}'"###
                    if msg.length > 1
                        if msg[-1] == "user_response"
                                 @user_response = msg[0]
                                 @shoes_thread.wakeup
                        else
                            @message = msg
                            @elements[msg[0]].handle_message(msg)
                        end
                    end
                }
                socket.onclose { puts "WebSocket closed" }
            } #socket start
        } #EM.run
        #@shoes_thread.join#############
        
    end  #App#initialize
    
    def stack(style={})
        stack = Shoes::Stack.new('div', style)
        stack.active = @active_element
        last_active = @active_element
        @active_element = stack.jqid
        yield if block_given?
        @active_element = last_active
        stack
    end
    
    def flow(style={})
        flow = Shoes::Flow.new('div', style) 
        flow.active = @active_element
        last_active = @active_element
        @active_element = flow.jqid
        yield if block_given?
        @active_element = last_active
        send_js %Q~$(#{flow.jqid}.children()).each(function(i, child){$(child).css('display', 'inline')});~
        flow
    end
    
    def shape(style={}, &block)
        shape = Shoes::Shape.new(%Q~canvas width="#{style[:width]}", height="#{style[:height]}"~, style)
        #shape.border('dashed 1px green')##########
        shape.get_context
        shape.filled = false
        shape.active = @active_element
        last_active = @active_element
        @active_element = shape.jqid
        shape.instance_eval(&block) if block_given?
        @active_element = last_active
        shape
    end
    
    def rect(w, h, style={})
        shape width: w, height: h do
            style.each{|key, val| self.send(key, val)}
            move_to(0, 0)
            line_to(w, 0); line_to(w, h); line_to(0, h); line_to(0, 0)
        end
    end
    
    def arc(start_angle, end_angle, radius, style={})
        shape width: radius * 2, height: radius * 2 do
            style.each{|key, val| self.send(key, val) unless key == :direction}
            if style.keys.include?(:direction)
                if ['counter_clockwise', 'anti_clockwise', 'counter', 'anti'].include?(style[:direction])
                    dir = 'true'
                end
            else
                dir = 'false'
            end
            arc(start_angle, end_angle, radius, dir)
        end
    end
    
    def circle(radius, style={})
        arc(0, 360, radius, style)
    end
    
    def oval(w, h, style={})
        shape width: w, height: h do
            style.each{|key, val| self.send(key, val)}
            send_js %Q~#{self.context}.save()~
            send_js %Q~#{self.context}.scale(#{w / 2}, #{h / 2})~
            send_js %Q~#{self.context}.arc(1, 1, 1, 0, 2 * Math.PI, false)~
            send_js %Q~#{self.context}.restore()~
            self.draw
        end
    end
    
    def star(points, outer_size, inner_size, style={})
        shape width: outer_size, height: outer_size do
            style.each{|key, val| self.send(key, val)}
            x = outer_size / 2
            y = outer_size / 2
            ratio = inner_size.to_f / outer_size.to_f
            l = outer_size - inner_size
            send_js %Q~#{self.context}.save()~
            send_js %Q~#{self.context}.translate(#{x}, #{y})~
            send_js %Q~#{self.context}.moveTo(0, 0 - #{x})~
            send_js %Q~for(var i = 0; i < #{points}; i++){#{self.context}.rotate(Math.PI / #{points}); #{self.context}.lineTo(0, 0 - #{inner_size}); #{self.context}.rotate(Math.PI / #{points}); #{self.context}.lineTo(0, 0 - #{x})}~
            send_js %Q~#{self.context}.restore()~
            self.draw
        end
    end
    
    def self.make_text_element(tag, text, style)
        element = Shoes::Text.new(tag, style, text)
        element.active = @active_element  ####
        element
    end
    
    def banner(text, style={})
        App.make_text_element('h1', text, style)
    end
    
    def title(text, style={})
        App.make_text_element('h2', text, style)
    end
    
    def subtitle(text, style={})
        App.make_text_element('h3', text, style)
    end
    
    def tagline(text, style={})
        App.make_text_element('h4', text, style)
    end
    
    def caption(text, style={})
        App.make_text_element('h5', text, style)
    end
    
    def para(text, style={})
        App.make_text_element('p', text, style)
    end
    
    def inscription(text, style={})
        App.make_text_element('h6', text, style)
    end
    
    def button(text, style={}, &block)
        btn = Shoes::Button.new('button', style, text)
        btn.active = @active_element
        if block_given?
            btn.click{
                last_active = @active_element
                @active_element = btn.active
                block.yield
                @active_element = last_active
            }
        end
        btn
    end
    
    def image(url, style={})
        img = Shoes::Image.new('img', style, url)
        img.active = @active_element
        img
    end
    
    def audio(url, style={})
        style[:controls] = 'controls' unless style.keys.include?(:controls)
        aud = Shoes::Audio.new('audio', style, url)
        aud.active = @active_element
        aud
    end
    
    def video(url, style={width: 320, height: 240})
        style[:controls] = 'controls' unless style.keys.include?(:controls)
        vid = Shoes::Video.new('video', style, url)
        vid.active = @active_element
        vid
    end
    
end  #class App