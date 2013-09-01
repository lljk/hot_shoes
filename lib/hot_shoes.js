var url = "ws://localhost:8080/";
var open = false

function to_json(element){
	var obj = {}
	$.each(element, function(key, val, x){
		if ('getPropertyValue' in element){
			obj[String(val)] = String(element.getPropertyValue(val))
		}
		else { obj[String(key)] = String(val) }
	});
	return  (JSON.stringify(obj));
};

function show_dialog(type){
    make_dialog(type, function(dialog) {
        shoes_body.append(dialog)
        var body_width = parseInt(shoes_body.css('width')), body_height = parseInt(shoes_body.css('height'));
        var dialog_width = parseInt($('#' + type + '_dialog').css('width')), dialog_height = parseInt($('#'+ type + '_dialog').css('height'));
        
        $('#' + type + '_dialog').css('left', body_width / 2 - dialog_width / 2 + 'px' ).css('top', body_height / 2 - dialog_width / 2 + 'px' )
        
        $('#' + type + '_ok').click(function(){
            socket.send($('#' + type + '_input').val() + '#!!#user_response');
            $('#' + type + '_dialog').remove()
        });
        $('#' + type + '_cancel').click(function(){
            $('#' + type + '_dialog').remove()
        });        
    })
}

function make_dialog(type, callback) {
    var dialog = $('<div class="shoes_dialog" id="' + type + '_dialog"></div>');
    var title, input
    switch(type){
        case 'color':
            title = $('<div id="color_title"><h3>Color Selector</h3><hr></div>');
            input = $('<input type="color" name="color" id="color_input" class="dialog_input">');
            break;
        case 'file':
            title = $('<div id="file_title"><h3>File Selector</h3></div><hr>');
            input = $('<div id="file_input_div"><input type="file" name="file" id="file_input" class="dialog_input"></div>');
            break;
        case 'folder':
            title = $('<div id="folder_title"><h3>Folder Selector</h3></div><hr>');
            input = $('<div id="file_input_div"><input type="file" name="folder" id="folder_input" class="dialog_input" webkitdirectory /></div>');
    }
    var ok_btn = $('<button class="shoes_dialog_button" id="' + type + '_ok">ok</button>')
    var cancel_btn = $('<button class="shoes_dialog_button" id="' + type + '_cancel">cancel</button>')
    dialog.append(title).append(input).append('<hr>').append(ok_btn).append(cancel_btn)
    callback(dialog)    
}

////////////////////////////////////////////

var socket;
$(document).ready(function(){		
    
    //location.reload()
    
		var support = "MozWebSocket" in window ? 'MozWebSocket' : ("WebSocket" in window ? 'WebSocket' : null);
		if (support == null) {
			alert("Your browser doesn't support Websockets.");
			return;   
		}
		
		socket = new window[support](url);
		
		socket.onopen = function() {
			console.log('socket open');
			socket.send('client socket open');
            open = true
		};

		socket.onping = function(v){
			socket.pong('ponging:' + v)
		}
	
		socket.onmessage = function(evt){
			//console.log(evt.data)
			$('body').append(evt.data);
		};
		
		socket.onclose = function() {
			console.log('socket closed')
		};
		
		socket.onerror = function(evt) {
			var received_msg = evt.data;
			//alert("Error: " + received_msg);
            //location.reload
            if (open == true){alert("Error: " + received_msg)}
            else {setTimeout(function(){location.reload()}, 500)};
		};
		
		//////////////////////////////////////////
		
}); 
 
