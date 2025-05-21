
function DiscordWebhook(url) constructor {
	
	#region Private
	self.url	= url;
	payload		= {};
	actions		= []
	files		= [];
	request_id	= undefined;
	delivered	= false;
	
	#endregion

	static SetUser = function(username, avatar_url) {
		payload.username	= username;
		payload.avatar_url	= avatar_url;
		return self;
	}
	static SetContent = function(content) {
		payload.content = content;
		return self;
	}
	static SetPayload = function(payload) {
		if (is_string(payload)) {
			self.payload = json_parse(payload);
		} else {
			self.payload = payload;
		}		
		return self;
	}
	static AddEmbed = function(embed) {
		payload[$ "embeds"] ??= [];
		array_push(payload.embeds, embed);
		return self;
	}
	static AddPoll = function(poll) {
		payload.poll = poll;
		return self;
	}	
	static AddFile = function(filename) {
		array_push(files, {
			file	: filename,
			data	: buffer_load(filename),
		})
		return self;
	}
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
	static EnableTTS = function(enabled) {
		payload.tts = enabled;
		return self;
	}
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
		request_id = http_request(url, "POST", _header, _buffer);
		
		// Clear memory
		buffer_delete(_buffer)
		ds_map_destroy(_header);
		return self;
	}
	static Async = function() {
		var _async = json_parse(json_encode(async_load))
		if (_async[$ "id"] == request_id) {
			delivered = true;
		}
		show_debug_message(json_stringify(_async, true))
	}
	static Delivered = function() {
		return delivered;
	}
}

function DiscordEmbed() constructor {
	
	#region Private
	fields	= [];
	#endregion
	
	static AddField = function(name, value, inline) {
		array_push(fields, {name, value, inline});
		return self;
	}
	static SetFields = function(fields) {
		self.fields = variable_clone(fields);
		return self;
	}
	static SetTitle = function(title) {
		self.title = title;
		return self;
	}
	static SetDescription = function(description) {
		self.description = description;
		return self;
	}
	static SetColor = function(color) {
		self.color = ((color & $FF) << 16) | (color & $FF00) | (color >> 16);
		return self;
	}
	static SetAuthor = function(name, icon_url = "", url = "") {
		author = {name, icon_url, url};
		return self;
	}
	static SetURL = function(url) {
		self.url = url;
		return self;
	}
	static SetImage = function(url) {
		image = {url};
		return self;
	}
	static SetThumbnail = function(url) {
		thumbnail = {url};
		return self;
	}
	static SetFooter = function(text, icon_url) {
		footer = {text, icon_url};
		return self;
	}	
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

