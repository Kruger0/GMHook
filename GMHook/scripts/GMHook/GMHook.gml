/*
    []=============================================[]
    ||  Webhook Integration System for GameMaker   ||
    ||  https://github.com/Kruger0/GMHook          ||
    ||                                             ||
    ||                                 --KrugDev   ||
    []=============================================[]
*/

///@func DiscordWebhook
function DiscordWebhook(url) constructor {

    #region Private
    self.url    = url;
    payload     = {};
    actions     = [];
    files       = [];
    message_id  = undefined;
    request_id  = undefined;
    processed   = false;
    ///@ignore
    static __Trace = function(_msg) {
        show_debug_message($"[GMHook] - {_msg}");
    }
    ///@ignore
    static __CreateBody = function() {
        var _buffer = buffer_create(1, buffer_grow, 1);
        var _body = ""+
        $"--boundary\r\n"+
        "Content-Disposition: form-data; name=\"payload_json\"\r\n\r\n"+
        json_stringify(payload, true) + "\r\n";
        buffer_write(_buffer, buffer_text, _body);
        // Process files
        for (var i = 0; i < array_length(files); i++) {
            var _file = files[i].file;
            var _data = files[i].data;
            var _content = $"--boundary\r\n"+
            $"Content-Disposition: form-data; name=\"file_{i}\"; filename=\"{_file}\"\r\n\r\n"
            buffer_write(_buffer, buffer_text, _content);
            buffer_copy(_data, 0, buffer_get_size(_data), _buffer, buffer_tell(_buffer));
            buffer_seek(_buffer, buffer_seek_relative, buffer_get_size(_data));
            buffer_write(_buffer, buffer_text, "\r\n");
            buffer_delete(_data);
        }        
        // Finish message
        buffer_write(_buffer, buffer_text, $"\r\n--boundary--");
        return _buffer;
    }
    ///@ignore
    static __CreateHeader = function() {
        var _header = ds_map_create();
        _header[? "Host"] = "discord.com";
        _header[? "Content-Type"] = "multipart/form-data; boundary=boundary";
        return _header;
    }
    #endregion

    ///@func SetUser(username, avatar_url)
    static SetUser = function(username, avatar_url) {
        payload.username    = username;
        payload.avatar_url  = avatar_url;
        return self;
    }
    ///@func SetContent(content)
    static SetContent = function(content) {
        payload.content = content;
        return self;
    }
    ///@func SetPayload(payload)
    static SetPayload = function(payload) {
        if (is_struct(payload)) {
            self.payload = payload;
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
    ///@func SetTTS(enabled)
    static SetTTS = function(enabled) {
        payload.tts = enabled;
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
        if (!file_exists(filename)) {
            __Trace($"File {filename} not found!") 
            return self;
        }
        array_push(files, {
            file    : filename,
            data    : buffer_load(filename),
         })
        return self;
    }
    ///@func AddBuffer(buffer, name)
    static AddBuffer = function(buffer, name) {
        if (!buffer_exists(buffer)) {
            __Trace($"Buffer {buffer} not found!")
            return self;
        }
        var _size = buffer_get_size(buffer)
        var _buffer = buffer_create(_size, buffer_fixed, buffer_get_alignment(buffer))
        buffer_copy(buffer, 0, _size, _buffer, 0)
        array_push(files, {
            file    : name,
            data    : _buffer,
        })
        return self;
    }
    ///@func Execute()
    static Execute = function() {   
        var _url    = url+"?wait=true";
        var _method = "POST";
        var _header = __CreateHeader();
        var _body   = __CreateBody();
        request_id = http_request(_url, _method, _header, _body);
        buffer_delete(_body);
        ds_map_destroy(_header);
        return self;
    }
    ///@func Edit()
    static Edit = function() {
        if (message_id == undefined) {
            __Trace("Failed to edit: Message ID is undefined")
            return self;
        }
        var _url    = $"{url}/messages/{message_id}"+"?wait=true";
        var _method = "PATCH"
        var _header = __CreateHeader();
        var _body   = __CreateBody();
        request_id = http_request(_url, _method, _header, _body);
        buffer_delete(_body);
        ds_map_destroy(_header);
        return self;
    }
    ///@func Delete()
    static Delete = function() {
        if (message_id == undefined) {
            __Trace("Failed to delete: Message ID is undefined")
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
    ///@func Async(trace)
    static Async = function(trace) {
        var _async = json_parse(json_encode(async_load));
        if (_async[$ "id"] != request_id) return false;
        var _http_status = _async[$ "http_status"];
        if (_http_status == undefined) return false;
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
    ///@func Processed()
    static Processed = function() {
        var _result = processed;
        processed = false;
        return _result;
    }
}

///@func DiscordEmbed
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
        self.color = ((color & 0xFF) << 16) | (color & 0xFF00) | ((color & 0xFF0000) >> 16);
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
    ///@func SetImageURL(url)
    static SetImageURL = function(url) {
        image = {url};
        return self;
    }
    ///@func SetImageFile(filename)
    static SetImageFile = function(filename) {
        image = {url : "attachment://"+filename};
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

///@func DiscordPoll(text, [duration], [multiselect])
function DiscordPoll(text, duration = 24, multiselect = false) constructor {
	
    #region Private
    question            = {text};
    self.duration       = duration;
    allow_multiselect   = multiselect;
    answers             = [];
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
