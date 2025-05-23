
function DiscordWebhook(url) constructor {
	
	#region Private
	self.url	= url+"?wait=true";
	payload		= {};
	actions		= []
	files		= [];
	message_id	= undefined;
	execute_id	= undefined;
	edit_id		= undefined;
	delete_id	= undefined;
	delivered	= false;
	
	#endregion

	///@func SetUser(username, avatar_url)
	static SetUser = function(username, avatar_url) {
		payload.username	= username;
		payload.avatar_url	= avatar_url;
		return self;
	}
	///@func SetContent(content)
	static SetContent = function(content) {
		payload.content = content;
		return self;
	}
	///@func SetPayload(payload)
	static SetPayload = function(payload) {
		if (is_string(payload)) {
			self.payload = json_parse(payload);
		} else {
			self.payload = payload;
		}		
		return self;
	}
	///@func AddEmbed(embed)
	static AddEmbed = function(embed) {
		payload[$ "embeds"] ??= [];
		array_push(payload.embeds, embed);
		return self;
	}
	///@func AddPoll(poll)
	static AddPoll = function(poll) {
		payload.poll = poll;
		return self;
	}	
	///@func AddFile(filename)
	static AddFile = function(filename) {
		array_push(files, {
			file	: filename,
			data	: buffer_load(filename),
		})
		return self;
	}
	///@func AddBuffer(buffer, name)
	static AddBuffer = function(buffer, name) {
		var _size = buffer_get_size(buffer)
		var _buffer = buffer_create(_size, buffer_fixed, buffer_get_alignment(buffer))
		buffer_copy(buffer, 0, _size, _buffer, 0)
		array_push(files, {
			file	: name,
			data	: _buffer,
		})
		return self;
	}
	///@func EnableTTS(enabled)
	static EnableTTS = function(enabled) {
		payload.tts = enabled;
		return self;
	}
	///@func Execute()
	static Execute = function() {
		
		// Create temp buffer
		var _buffer = buffer_create(1, buffer_grow, 1);

		// Process payload
		var _body = ""+
		$"--boundary\r\n"+
		"Content-Disposition: form-data; name=\"payload_json\"\r\n"+
		"\r\n"+
		json_stringify(payload, true) + "\r\n";
		buffer_write(_buffer, buffer_text, _body);
		
		// Process files
		for (var i = 0; i < array_length(files); i++) {
			var _file = files[i].file;
			var _data = files[i].data;
			
			var _content = $"--boundary\r\n"+
			$"Content-Disposition: form-data; name=\"file_{i}\"; filename=\"{_file}\"\r\n"+
			$"\r\n"	
			
			buffer_write(_buffer, buffer_text, _content);
			buffer_copy(_data, 0, buffer_get_size(_data), _buffer, buffer_tell(_buffer));
			buffer_seek(_buffer, buffer_seek_relative, buffer_get_size(_data));
			buffer_write(_buffer, buffer_text, "\r\n");
			buffer_delete(_data);		
		}
		
		// Finish message
		buffer_write(_buffer, buffer_text, $"\r\n--boundary--");
		
		// Send message
		var _header = ds_map_create();
		_header[? "Host"] = "discord.com"
		_header[? "Content-Type"] = "multipart/form-data; boundary=boundary";
		execute_id = http_request(url, "POST", _header, _buffer);
		
		// Clear memory
		buffer_delete(_buffer)
		ds_map_destroy(_header);
		return self;
	}
	///@func Edit()
	static Edit = function() {
		if (message_id == undefined) return self;
		
		// Create temp buffer
		var _buffer = buffer_create(1, buffer_grow, 1);

		// Process payload
		var _body = ""+
		$"--boundary\r\n"+
		"Content-Disposition: form-data; name=\"payload_json\"\r\n"+
		"\r\n"+
		json_stringify(payload, true) + "\r\n";
		buffer_write(_buffer, buffer_text, _body);
		
		// Process files
		for (var i = 0; i < array_length(files); i++) {
			var _file = files[i].file;
			var _data = files[i].data;
			
			var _content = $"--boundary\r\n"+
			$"Content-Disposition: form-data; name=\"file_{i}\"; filename=\"{_file}\"\r\n"+
			$"\r\n"	
			
			buffer_write(_buffer, buffer_text, _content);
			buffer_copy(_data, 0, buffer_get_size(_data), _buffer, buffer_tell(_buffer));
			buffer_seek(_buffer, buffer_seek_relative, buffer_get_size(_data));
			buffer_write(_buffer, buffer_text, "\r\n");
			buffer_delete(_data);		
		}
		
		// Finish message
		buffer_write(_buffer, buffer_text, $"\r\n--boundary--");
		
		// Send message
		var _header = ds_map_create();
		_header[? "Host"] = "discord.com"
		_header[? "Content-Type"] = "multipart/form-data; boundary=boundary";
		edit_id = http_request($"{url}/messages/{message_id}", "PATCH", _header, _buffer);
		
		// Clear memory
		buffer_delete(_buffer)
		ds_map_destroy(_header);
		return self;
	}
	///@func Delete()
	static Delete = function() {
		if (message_id == undefined) return self;
		
		var _header = ds_map_create();
		edit_id = http_request($"{url}/messages/{message_id}", "DELETE", _header, 0);
		ds_map_destroy(_header);
		return self;
	}
	///@func Previous
	static Previous = function() {
		if (message_id == undefined) return self;
		
		var _header = ds_map_create();
		http_request($"{url}/messages/{message_id}", "GET", _header, 0);
		ds_map_destroy(_header);
	}
	///@func Async()
	static Async = function() {
		var _async = json_parse(json_encode(async_load))
		var _http_status = _async[$ "http_status"]
		var _result = json_parse(_async[$ "result"] ?? {})
					
		switch (_http_status) {
			case 200: {
				if (_async[$ "id"] == execute_id) {
					
					message_id = _result[$ "id"]
				}
			} break;
			case 204: {
				
			} break;
			case 404: {
				
			} break;
			default: {
				show_debug_message(_http_status)
			}
		}
		message_id = _result[$ "id"]
		show_debug_message(json_stringify(_async, true))
	}
	///@func Delivered()
	static Delivered = function() {
		return message_id != undefined;
	}
}

function DiscordEmbed() constructor {
	
	///@func AddField(name, value, [inline])
	static AddField = function(name, value, inline = false) {
		self[$ "fields"] ??= [];
		array_push(fields, {name, value, inline});
		return self;
	}
	///@func SetFields(fields)
	static SetFields = function(fields) {
		self.fields = variable_clone(fields);
		return self;
	}
	///@func SetTitle(title)
	static SetTitle = function(title) {
		self.title = title;
		return self;
	}
	///@func SetDescription(description)
	static SetDescription = function(description) {
		self.description = description;
		return self;
	}
	///@func SetColor(color)
	static SetColor = function(color) {
		self.color = ((color & $FF) << 16) | (color & $FF00) | (color >> 16);
		return self;
	}
	///@func SetAuthor(name, [icon_url], [url]
	static SetAuthor = function(name, icon_url = "", url = "") {
		author = {name, icon_url, url};
		return self;
	}
	///@func SetURL(url)
	static SetURL = function(url) {
		self.url = url;
		return self;
	}
	///@func SetImage(url)
	static SetImage = function(url) {
		image = {url};
		return self;
	}
	///@func SetThumbnail(url)
	static SetThumbnail = function(url) {
		thumbnail = {url};
		return self;
	}
	///@func SetFooter(text, [icon_url])
	static SetFooter = function(text, icon_url = "") {
		footer = {text, icon_url};
		return self;
	}	
	///@func SetTimestamp(timestamp)
	static SetTimestamp = function(timestamp) {
		self.timestamp = timestamp;
		return self;
	}
}

function DiscordPoll(text, duration = 24, multiselect = false) constructor {
	
	#region Private
	question			= {text};
	self.duration		= duration;
	allow_multiselect	= multiselect;
	answers				= [];
	#endregion
	
	///@func AddAnswer(text, [emoji]
	static AddAnswer = function(text, emoji = undefined) {
		var _answer = {
			poll_media : {text}
		}
		if (emoji != undefined) {
			_answer.poll_media.emoji = {};
			
			if (is_numeric(emoji)) {
				_answer.poll_media.emoji.id = string(emoji);
			} else {
				_answer.poll_media.emoji.name = emoji;			
			}
		}		
		array_push(answers, _answer);
		return self;
	}
}

