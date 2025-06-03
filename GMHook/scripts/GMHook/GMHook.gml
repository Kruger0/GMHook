/*
    []=============================================[]
    ||  Webhook Integration System for GameMaker   ||
    ||  https://github.com/Kruger0/GMHook          ||
    ||                                             ||
    ||                                 --KrugDev   ||
    []=============================================[]
*/

///@desc Instantiates a Webhook object that can be configured and executed.
///@arg {String} url The webhook url as a string
function DiscordWebhook(url) constructor {

    #region Private
    self.url    = url;
    payload     = {};
    files       = [];
    message_id  = undefined;
    request_id  = undefined;
    processed   = false;
    boundary    = sha1_string_utf8(date_datetime_string(date_current_datetime()));
    
    ///@desc Internal trace function for debug messages.
    ///@arg {String} _msg The message to trace.
    ///@ignore
    static __Trace = function(_msg) {
        show_debug_message($"[GMHook] - {_msg}");
    }
    
    ///@desc Creates the multipart form data body for the HTTP request.
    ///@return {Buffer} The buffer containing the request body.
    ///@ignore
    static __CreateBody = function() {
        var _buffer = buffer_create(1024, buffer_grow, 1);        
        var _body = ""+
        $"--{boundary}\r\n"+
        "Content-Disposition: form-data; name=\"payload_json\"\r\n\r\n"+
        json_stringify(payload, true) + "\r\n";
        buffer_write(_buffer, buffer_text, _body);
        // Process files
        for (var i = 0; i < array_length(files); i++) {
            var _file = files[i].file;
            var _data = files[i].data;
            var _content = $"--{boundary}\r\n"+
            $"Content-Disposition: form-data; name=\"file_{i}\"; filename=\"{_file}\"\r\n\r\n";
            buffer_write(_buffer, buffer_text, _content);
            buffer_copy(_data, 0, buffer_get_size(_data), _buffer, buffer_tell(_buffer));
            buffer_seek(_buffer, buffer_seek_relative, buffer_get_size(_data));
            buffer_write(_buffer, buffer_text, "\r\n");
            buffer_delete(_data);
        }        
        // Finish message
        buffer_write(_buffer, buffer_text, $"--{boundary}--");
        return _buffer;
    }
    
    ///@desc Creates the HTTP headers for the Discord API request
    ///@arg {Buffer} body The body buffer to get the content length.
    ///@return {DsMap} The header map for the request.
    ///@ignore
    static __CreateHeader = function() {
        var _header = ds_map_create();
        _header[? "Host"] = "discord.com";
        _header[? "Content-Type"] = $"multipart/form-data; boundary={boundary}";
        return _header;
    }
    #endregion

    ///@desc Sets or changes the webhook URL.
    ///@arg {String} url The new webhook URL as a string.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static SetURL = function(url) {
        self.url = url;
        return self;
    }

    ///@desc Sets a user and avatar that overrides the default ones defined in the discord server config.
    ///@arg {String} username The webhook name.
    ///@arg {String} avatar_url The webhook avatar.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static SetUser = function(username, avatar_url) {
        if (username != undefined && username!= "") {
            payload.username = username;
        }
        if (avatar_url != undefined && avatar_url!= "") {
            payload.avatar_url = avatar_url;
        }
        return self;
    }
    
    ///@desc Sets the content/text message for the webhook.
    ///@arg {String} content The message content to send.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static SetContent = function(content) {
        payload.content = content;
        return self;
    }
    
    ///@desc Sets the entire payload for the webhook.
    ///@arg {Struct|String} payload The payload struct or JSON string to use.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static SetPayload = function(payload) {
        if (is_struct(payload)) {
            self.payload = variable_clone(payload);
        } else if (is_string(payload)) {
            try {
                self.payload = json_parse(payload);
            } catch (e) {
                __Trace($"Invalid payload string: {payload}");
            };
        } else {
            __Trace($"Invalid payload: {payload}");
        }        
        return self;
    }
    
    ///@desc Sets the entire embed array for the webhook.
    ///@arg {Array} embeds Array of embeds to use
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static SetEmbeds = function(embeds) {
        payload[$ "embeds"] = variable_clone(embeds);
        return self;
    }
    
    ///@desc Sets whether the message should be sent with text-to-speech.
    ///@arg {Bool} enabled Whether TTS should be enabled.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static SetTTS = function(enabled) {
        payload.tts = enabled;
        return self;
    }
    
    ///@desc Adds an embed to the webhook message.
    ///@arg {Struct.DiscordEmbed} embed The embed object to add.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static AddEmbed = function(embed) {
        payload[$ "embeds"] ??= [];
        array_push(payload.embeds, variable_clone(embed));
        return self;
    }
    
    ///@desc Adds a poll to the webhook message.
    ///@arg {Struct.DiscordPoll} poll The poll object to add.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static AddPoll = function(poll) {
        payload.poll = variable_clone(poll);
        return self;
    }
    
    ///@desc Adds a file attachment from disk to the webhook.
    ///@arg {String} filename The path to the file to attach.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static AddFile = function(filename) {
        if (!file_exists(filename)) {
            __Trace($"File {filename} not found!");
            return self;
        }
        array_push(files, {
            file : filename,
            data : buffer_load(filename),
        })
        return self;
    }
    
    ///@desc Adds a buffer as a file attachment to the webhook.
    ///@arg {Buffer} buffer The buffer to attach.
    ///@arg {String} name The filename for the attachment.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static AddBuffer = function(buffer, name) {
        if (!buffer_exists(buffer)) {
            __Trace($"Buffer {buffer} not found!");
            return self;
        }
        var _size = buffer_get_size(buffer);
        var _buffer = buffer_create(_size, buffer_fixed, buffer_get_alignment(buffer));
        buffer_copy(buffer, 0, _size, _buffer, 0);
        array_push(files, {
            file    : name,
            data    : _buffer,
        })
        return self;
    }
    
    ///@desc Executes the webhook and sends the message to Discord.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static Execute = function() {
        processed = false;
        var _url    = url+"?wait=true";
        var _method = "POST";
        var _header = __CreateHeader();
        var _body   = __CreateBody();
        request_id = http_request(_url, _method, _header, _body);
        buffer_delete(_body);
        ds_map_destroy(_header);
        return self;
    }
    
    ///@desc Edits a previously sent message (requires message_id from Execute).
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static Edit = function() {
        processed = false;
        if (message_id == undefined) {
            __Trace("Failed to edit: Message ID is undefined");
            return self;
        }
        var _url    = $"{url}/messages/{message_id}"+"?wait=true";
        var _method = "PATCH";
        var _header = __CreateHeader();
        var _body   = __CreateBody();
        request_id = http_request(_url, _method, _header, _body);
        buffer_delete(_body);
        ds_map_destroy(_header);
        return self;
    }
    
    ///@desc Deletes a previously sent message (requires message_id from Execute).
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static Delete = function() {
        processed = false;
        if (message_id == undefined) {
            __Trace("Failed to delete: Message ID is undefined");
            return self;
        }
        var _url    = $"{url}/messages/{message_id}"+"?wait=true";
        var _method = "DELETE";
        var _header = __CreateHeader();
        var _body   = 0;
        request_id = http_request(_url, _method, _header, _body);
        ds_map_destroy(_header);
        return self;
    }
    
    ///@desc Processes the async HTTP response from Discord API.
    ///@arg {Bool} trace Whether to output trace messages for status codes.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static Async = function(trace) {
        var _async = json_parse(json_encode(async_load));
        if (_async[$ "id"] != request_id) return self;
        var _http_status = _async[$ "http_status"];
        if (_http_status == undefined) return self;
        var _result = _async[$ "result"] ?? "{}";
        if (_result != "") {
            _result = json_parse(_result);
        } else {
          _result = {};
        }
        if (trace) {
            switch (_http_status) {
                case 200: __Trace("200 | Message Sent") break;
                case 204: __Trace("204 | Message Deleted") break;
                case 404: __Trace("404 | Message Not Found") break;
                case 429: __Trace("429 | Too Many Requests") break;
                default:  __Trace($"{_http_status} | {_result}")
            }
        }        
        message_id = _result[$ "id"];
        processed = true;
        return self;
    }
    
    ///@desc Checks if the last request has been processed.
    ///@return {Bool} True if the request was processed, false otherwise.
    static Processed = function() {
        return processed;
    }

    ///@desc Clears all webhook data and resets to initial state.
    ///@return {Struct.DiscordWebhook} Returns self for method chaining.
    static Clear = function() {
        payload = {};
        for (var i = 0; i < array_length(files); i++) {
            if (buffer_exists(files[i].data)) {
                buffer_delete(files[i].data);
            }
        }
        files = [];
        message_id = undefined;
        request_id = undefined;
        processed = false;
        return self;
    }

    ///@desc Destroys the webhook object and cleans up all resources.
    ///@return {Undefined} No return value as object should be nullified after calling.
    static Destroy = function() {
        Clear();
        url = undefined;
    }
}

///@desc Creates a Discord embed object for rich message formatting.
///@return {DiscordEmbed} A new embed instance.
function DiscordEmbed() constructor {

    ///@desc Adds a field to the embed.
    ///@arg {String} name The field name/title.
    ///@arg {String} value The field content.
    ///@arg {Bool} inline Whether the field should be displayed inline. Defaults to false.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static AddField = function(name, value, inline = false) {
        self[$ "fields"] ??= [];
        array_push(fields, {name, value, inline});
        return self;
    }
    
    ///@desc Sets multiple fields at once.
    ///@arg {Array} fields Array of field objects {name, value, inline}.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetFields = function(fields) {
        self.fields = variable_clone(fields);
        return self;
    }
    
    ///@desc Sets the embed title.
    ///@arg {String} title The embed title text.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetTitle = function(title) {
        self.title = title;
        return self;
    }
    
    ///@desc Sets the embed description.
    ///@arg {String} description The embed description text.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetDescription = function(description) {
        self.description = description;
        return self;
    }
    
    ///@desc Sets the embed color (left border color).
    ///@arg {Real} color The color value (BGR format will be converted to RGB).
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetColor = function(color) {
        self.color = ((color & 0xFF) << 16) | (color & 0xFF00) | ((color & 0xFF0000) >> 16);
        return self;
    }
    
    ///@desc Sets the embed author information.
    ///@arg {String} name The author name.
    ///@arg {String} icon_url The author icon URL.
    ///@arg {String} url The author URL (makes name clickable).
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetAuthor = function(name, icon_url = "", url = "") {
        author = {name, icon_url, url};
        return self;
    }
    
    ///@desc Sets the embed URL (makes title clickable).
    ///@arg {String} url The URL to link to.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetURL = function(url) {
        self.url = url;
        return self;
    }
    
    ///@desc Sets the embed image from a URL.
    ///@arg {String} url The image URL.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetImageURL = function(url) {
        image = {url};
        return self;
    }
    
    ///@desc Sets the embed image from an attached file.
    ///@arg {String} filename The filename of the attached file.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetImageFile = function(filename) {
        image = {url : "attachment://"+filename};
        return self;
    }
    
    ///@desc Sets the embed thumbnail image.
    ///@arg {String} url The thumbnail image URL.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetThumbnail = function(url) {
        thumbnail = {url};
        return self;
    }
    
    ///@desc Sets the embed footer information.
    ///@arg {String} text The footer text.
    ///@arg {String} icon_url The footer icon URL.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetFooter = function(text, icon_url = "") {
        footer = {text, icon_url};
        return self;
    }
    
    ///@desc Sets the embed timestamp.
    ///@arg {String} timestamp The timestamp in ISO 8601 format.
    ///@return {Struct.DiscordEmbed} Returns self for method chaining.
    static SetTimestamp = function(timestamp) {
        self.timestamp = timestamp;
        return self;
    }
}

///@desc Creates a Discord poll object for interactive voting.
///@arg {String} text The poll question text.
///@arg {Real} duration The poll duration in hours (1-768). Defaults to 24.
///@arg {Bool} multiselect Whether users can select multiple answers. Defaults to false.
///@return {DiscordPoll} A new poll instance.
function DiscordPoll(text, duration = 24, multiselect = false) constructor {
	
    #region Private
    question            = {text};
    self.duration       = clamp(duration, 1, 768);
    allow_multiselect   = multiselect;
    answers             = [];
    #endregion

    ///@desc Adds an answer option to the poll.
    ///@arg {String} text The answer text.
    ///@arg {String|Real} emoji The emoji for the answer (name string or ID number).
    ///@return {Struct.DiscordPoll} Returns self for method chaining.
    static AddAnswer = function(text, emoji = undefined) {
        var _answer = {
            poll_media : {text},
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

