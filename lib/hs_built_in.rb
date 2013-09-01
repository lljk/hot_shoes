 class App
     
    def send_js(script)#########
        @socket.send %Q~<script>#{script}</script>~
    end
     
    def escape_text(text)
        text.gsub!(/\\|'|"/) { |c| "\\#{c}" }
    end
    
    def alert(message)
        send_js %Q~alert("#{message}")~
    end
    
    def animate(fps, &block)
        ms = 1000 / fps
        Shoes::TimerBase.new("animate", ms, block)
    end
    
    def ask(question, answer=nil)
        send_js %Q~var ask = prompt("#{question}", "#{answer}")~
        send_js %Q~if (ask != null && ask != ""){socket.send(ask + '#!!#user_response')}~
        Thread.stop unless @shoes_thread.stop?
        @user_response
    end
    
    def ask_color(title="Color Selector")
        escape_text(title)
        send_js %Q~$('#color_title').html('<h3>#{title}</h3><hr>')~
        send_js %Q~show_dialog('color')~
        Thread.stop unless @shoes_thread.stop?
        @user_response
    end
    
    def ask_open_file
        send_js %Q~$('#file_title').html('<h3>Open File</h3><hr>')~
        send_js %Q~show_dialog('file')~
        Thread.stop unless @shoes_thread.stop?
        @user_response
    end
    
    def ask_save_file
        send_js %Q~$('#file_title').html('<h3>Save File</h3><hr>')~
        send_js %Q~show_dialog('file')~
        Thread.stop unless @shoes_thread.stop?
        @user_response
    end
    
    def ask_open_folder
        send_js %Q~$('#folder_title').html('<h3>Open Folder</h3><hr>')~
        send_js %Q~show_dialog('folder')~
        Thread.stop unless @shoes_thread.stop?
        @user_response
    end
    
    def ask_save_folder
        send_js %Q~$('#folder_title').html('<h3>Save Folder</h3><hr>')~
        send_js %Q~show_dialog('folder')~
        Thread.stop unless @shoes_thread.stop?
        @user_response
    end
    
    def background(bg, size="100%", repeat="no-repeat")
        escape_text(bg)
        send_js %Q~#{@active_element}.css('background', '#{bg}').css('background-size', '#{size}').css('background-repeat', '#{repeat}')~
    end
    
    def confirm(question)
        escape_text(question)
        send_js %Q~var c = confirm("#{question}")~
        send_js %Q~socket.send(c + '#!!#user_response')~
        Thread.stop unless @shoes_thread.stop?
        @user_response
    end
    
    def debug(message)
        p message
    end
    
    def download(url, opts={}, &block)
        dl = Shoes::Download.new(self, url, opts, &block)
    end
    
    def error(message)
        send_js %Q~alert(#{message})~
    end
    
    def every(secs, &block)
        ms = 1000 * secs
        Shoes::TimerBase.new("every", ms, block)
    end
    
    def exit
    end
    
    def font(message)
    end
    
    def gradient(color1, color2, h_v_r="horizontal")
        case h_v_r
        when "horizontal"
            send_js %Q~#{@active_element}.css('background', '-webkit-gradient(linear, 0% 0%, 0% 100%, from(#{color1}), to(#{color2}))')~
            send_js %Q~#{@active_element}.css('background', '-webkit-linear-gradient(top, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-moz-linear-gradient(top, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-ms-linear-gradient(top, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-o-linear-gradient(top, #{color1}, #{color2})')~
        when "vertical"
            send_js %Q~#{@active_element}.css('background', '-webkit-gradient(linear, left top, right top, from(#{color2}), to(#{color1}))')~
            send_js %Q~#{@active_element}.css('background', '-webkit-linear-gradient(left, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-moz-linear-gradient(left, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-ms-linear-gradient(left, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-o-linear-gradient(left, #{color1}, #{color2})')~
        when "radial"
            send_js %Q~#{@active_element}.css('background', '-webkit-gradient(radial, center center, 0, center center, 460, from(#{color1}), to(#{color2}))')~
            send_js %Q~#{@active_element}.css('background', '-webkit-radial-gradient(circle, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-moz-radial-gradient(circle, #{color1}, #{color2})')~
            send_js %Q~#{@active_element}.css('background', '-ms-radial-gradient(circle, #{color1}, #{color2})')~
        end
    end
    
    def gray(scale)
    end
    
    def info(message)
    end
    
    def rgb(red, green, blue)
        "rgb(#{red}, #{green}, #{blue})"
    end
    
    def warn
        send_js %Q~alert(#{message})~
    end
    
end  #class App