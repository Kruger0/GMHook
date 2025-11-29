
// Simple message
if (keyboard_check_pressed(ord("Q"))) {
    var _msg = new DiscordWebhook(url)
        .SetContent("Hello Discord!")
        .Execute()
        .Destroy();
}

// Embed message essage build from playload struct (https://glitchii.github.io/embedbuilder/)
if (keyboard_check_pressed(ord("W"))) {
    var _payloadData = {
        username: "GMHook",
        avatar_url: "https://i.imgur.com/RApIX2B.png",
        content: "You can~~not~~ do `this`.```py\nAnd this.\nprint('Hi')```\n*italics* or _italics_     __*underline italics*__\n**bold**     __**underline bold**__\n***bold italics***  __***underline bold italics***__\n__underline__     ~~Strikethrough~~",
        embeds: [
            {
                title: "Hello ~~people~~ world :wave:",
                description: "You can use [links](https://discord.com) or emojis :smile: 😎\n```\nAnd also code blocks\n```",
                color: 4321431,
                timestamp: "2025-11-29T16:35:57.178Z",
                url: "https://discord.com",
                author: {
                    name: "Author name",
                    url: "https://discord.com",
                    icon_url: "https://cdn.discordapp.com/embed/avatars/0.png"
                },
                thumbnail: {
                    url: "https://unsplash.it/200"
                },
                image: {
                    url: "https://unsplash.it/380/200"
                },
                fields: [
                    {
                        name: "Field 1, *lorem* **ipsum**, ~~dolor~~",
                        value: "Field value"
                    },
                    {
                        name: "Field 2",
                        value: "You can use custom emojis <:Kekwlaugh:722088222766923847>. <:GangstaBlob:742256196295065661>",
                        inline: false
                    },
                    {
                        name: "Inline field",
                        value: "Fields can be inline",
                        inline: true
                    },
                    {
                        name: "Inline field",
                        value: "*Lorem ipsum*",
                        inline: true
                    },
                    {
                        name: "Inline field",
                        value: "value",
                        inline: true
                    },
                    {
                        name: "Another field",
                        value: "> Nope, didn't forget about this",
                        inline: false
                    }
                ],
                footer: {
                    text: "Footer text",
                    icon_url: "https://unsplash.it/100"
                },
            }
        ]
    }
    
    var _payload = new DiscordWebhook(url)
        .SetPayload(_payloadData)
        .Execute()
        .Destroy()
}

// Embed message build from system methods (https://glitchii.github.io/embedbuilder/)
if (keyboard_check_pressed(ord("E"))) {
    var _embedData = new DiscordEmbed()
        .SetTitle("Hello ~~people~~ world :wave:")
        .SetDescription("You can use [links](https://discord.com) or emojis :smile: 😎\n```\nAnd also code blocks\n```")
        .SetColor(#41F097)
        .SetTimestamp("2025-11-29T16:35:57.178Z")
        .SetURL("https://discord.com")
        .SetAuthor("Author name", "https://discor.com", "https://unsplash.it/100")
        .SetThumbnail("https://unsplash.it/200")
        .SetImageURL("https://unsplash.it/380/200")
        .AddField("Field 1, *lorem* **ipsum**, ~~dolor~~", "Field value")
        .AddField("Field 2", "You can use custom emojis <:Kekwlaugh:722088222766923847>. <:GangstaBlob:742256196295065661>")
        .AddField("Inline field", "Fields can be inline", true)
        .AddField("Inline field", "*Lorem ipsum*", true)
        .AddField("Inline field", "value", true)
        .AddField("Another field", "> Nope, didn't forget about this")
        .SetFooter("Footer text", "https://unsplash.it/100")
    
    var _embed = new DiscordWebhook(url)
        .SetUser("GMHook", "https://i.imgur.com/RApIX2B.png")
        .SetContent("You can~~not~~ do `this`.```py\nAnd this.\nprint('Hi')```\n*italics* or _italics_     __*underline italics*__\n**bold**     __**underline bold**__\n***bold italics***  __***underline bold italics***__\n__underline__     ~~Strikethrough~~")
        .AddEmbed(_embedData)
        .Execute()
        .Destroy()
}

// Pool creation (https://birdie0.github.io/discord-webhooks-guide/structure/poll.html)
if (keyboard_check_pressed(ord("R"))) {
    var _pollData = new DiscordPoll("Cat person or dog person?")
        .AddAnswer("meow!", 1365720705324421202)
        .AddAnswer("woof!", "🐶")
    
    var _poll = new DiscordWebhook(url)
        .AddPoll(_pollData)
        .Execute()
        .Destroy();
}

// Screen capture
if (keyboard_check_pressed(ord("T"))) {
    var _filename = "capture.png";
    surface_save(application_surface, _filename);
    var _capture = new DiscordWebhook(url)
        .AddFile(_filename)
        .Execute()
        .Destroy();
    file_delete(_filename);
}

// Buffer file
if (keyboard_check_pressed(ord("Y"))) {
    var _bufferData = buffer_create(1, buffer_grow, 1)
    buffer_get_surface(_bufferData, application_surface, 0);
    var _buffer = new DiscordWebhook(url)
        .AddBuffer(_bufferData, "capture.buff")
        .Execute()
        .Destroy();
    buffer_delete(_bufferData)
}

// Text file
if (keyboard_check_pressed(ord("U"))) {
    var _bufferData = buffer_create(1, buffer_grow, 1);
    var _s = string_format(current_second, 2, 0)
    var _m = string_format(current_minute, 2, 0)
    var _h = string_format(current_hour, 2, 0)
    buffer_write(_bufferData, buffer_text, $"[{_s}:{_m}:{_h}] - GMHook v{GMHOOK_VERSION}\n");
    buffer_write(_bufferData, buffer_text, $"[{_s}:{_m}:{_h}] - Checking game state...\n");
    buffer_write(_bufferData, buffer_text, $"[{_s}:{_m}:{_h}] - The game is runing fine! :)\n");
    var _buffer = new DiscordWebhook(url)
        .AddBuffer(_bufferData, "gamedata.log")
        .Execute()
        .Destroy();
    buffer_delete(_bufferData);
}