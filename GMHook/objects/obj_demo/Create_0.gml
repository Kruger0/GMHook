
url = "https://discord.com/api/webhooks/1375319109251629127/Q5vYMgwZW0_nG39LMe8zeuqU4R3KRdRnt3a01cJNx9YT61747O8U9jlvUYCDBNOzYKDV";

#region Example 1. Message build from playload struct (https://glitchii.github.io/embedbuilder/)

payload = {
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

webhook1 = new DiscordWebhook(url)
    .SetPayload(payload);

#endregion

#region Example 2. Message build from system methods (https://glitchii.github.io/embedbuilder/)

embed = new DiscordEmbed()
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

webhook2 = new DiscordWebhook(url)
    .SetUser("GMHook", "https://i.imgur.com/RApIX2B.png")
    .SetContent("You can~~not~~ do `this`.```py\nAnd this.\nprint('Hi')```\n*italics* or _italics_     __*underline italics*__\n**bold**     __**underline bold**__\n***bold italics***  __***underline bold italics***__\n__underline__     ~~Strikethrough~~")
    .AddEmbed(embed);

#endregion

#region Example 3. Pool creation (https://birdie0.github.io/discord-webhooks-guide/structure/poll.html)

poll = new DiscordPoll("Cat person or dog person?")
    .AddAnswer("meow!", 1365720705324421202)
    .AddAnswer("woof!", "🐶")

webhook3 = new DiscordWebhook(url)
    .AddPoll(poll)

#endregion

