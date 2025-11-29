[![GitHub license](https://img.shields.io/github/license/Kruger0/GMHook)](https://github.com/Kruger0/GMHook/blob/main/LICENSE)
[![GitHub release](https://img.shields.io/github/v/release/Kruger0/GMHook)](https://github.com/Kruger0/GMHook/releases)
[![GameMaker](https://img.shields.io/badge/GameMaker-2024.13+-blue?logo=gamemaker)](https://gamemaker.io/)
[![Discord API](https://img.shields.io/badge/Discord-API%20v10-5865F2?logo=discord&logoColor=white)](https://discord.com/developers/docs)
[![GitHub last commit](https://img.shields.io/github/last-commit/Kruger0/GMHook)](https://github.com/Kruger0/GMHook/commits)
<div align="center">
  <img src="https://github.com/user-attachments/assets/d29423cd-4bb0-44e0-b8ec-814621924429" alt="GMHook Icon" width="256">
  <h1>GMHook 2.1.0</h1>
</div>
GMHook is a Discord Webhook integration system made for GameMaker, implemented with complete message, embed, file and poll support


## How to use!
1. Create a Discord Webhook in your server channel by going to **Edit channel** → **Integrations** → **Webhooks** → **Create Webhook**.
   Configure the name, avatar and channel, then copy the webhook URL.
   
2. Create a webhook instance and start sending messages:
   ```gml
   // Create webhook instance
   webhook = new DiscordWebhook("YOUR_WEBHOOK_URL");
   
   // Send a simple message
   webhook.SetContent("Hello from GameMaker!")
          .Execute();
   ```

3. Create rich embeds for better presentation:
   ```gml
   // Create an embed
   embed = new DiscordEmbed();
   embed.SetTitle("Game Stats")
        .SetDescription("Player achievements")
        .SetColor(0x00ff00)
        .AddField("Score", string(score), true)
        .AddField("Level", string(level), true);
   
   // Send the embed
   webhook.AddEmbed(embed)
          .Execute();
   ```

4. Call the function `webhook.Async(trace)` in an Async HTTP event to get the message ID, in order to use features like `Processed()`, `Edit()` or `Delete()`:
   ```gml
   // Async HTTP Event
   webhook.Async(true);

   // Anywhere
   if (webhook.Processed()) {
       show_debug_message("Message sent successfully!");
   }
   ```

## Advanced Features

### File Uploads
Send screenshots, logs or any file directly to Discord:
```gml
// Send a file
webhook.SetContent("Check out this screenshot!")
       .AddFile("screenshot.png")
       .Execute();

// Send a buffer as file
webhook.AddBuffer(my_buffer, "game_data.json")
       .Execute();

// Send an embed with attatched images
embed.SetTitle("Game Screenshot")
     .SetDescription("Latest gameplay")
     .SetImageURL("https://example.com/image.png")      // Use web image
     .SetImageFile("screenshot.png");                   // Or use attached file that is included on the webhook

webhook.AddEmbed(embed);
```

### Interactive Polls
Create polls for community engagement:
```gml
// Create a poll
poll = new DiscordPoll("What's your favorite feature?", 24, false);
poll.AddAnswer("Embeds", "📋")
    .AddAnswer("File Upload", "📎")
    .AddAnswer("Polls", "🗳️");

webhook.AddPoll(poll)
       .Execute();
```

### Message Management
Edit or delete messages after sending:
```gml
// After successful send, you can edit the message
webhook.SetContent("Updated message!")
       .Edit();

// Or delete it completely
webhook.Delete();
```

### Custom User Identity
Make your webhook appear as different users:
```gml
webhook.SetUser("GameBot", "https://example.com/bot_avatar.png")
       .SetContent("Message from custom bot!")
       .Execute();
```

### Batch Operations
Set multiple embeds or fields at once:
```gml
// Set multiple embeds at once
embeds_array = [embed1, embed2, embed3];
webhook.SetEmbeds(embeds_array);

// Set multiple fields for an embed
fields_array = [
    {name: "Field 1", value: "Value 1", inline: true},
    {name: "Field 2", value: "Value 2", inline: false}
];
embed.SetFields(fields_array);
```

### Webhook Restrictions
- **No reaction detection**: Webhooks cannot detect when users react to messages they send
- **No incoming events**: Webhooks are send-only and cannot listen for Discord events  
- **No self-reactions**: Webhooks cannot add reactions to their own messages

For interactive features requiring user input detection, consider using a Discord bot alongside webhooks.

## Complete API Reference

### DiscordWebhook Methods
- `SetURL(url)` - Change the webhook URL after creation
- `SetUser(username, avatar_url)` - Set custom webhook identity
- `SetContent(content)` - Set message text content
- `SetThread(thread_name)` - Set the name of the thread to be created (Forum Channels)
- `SetFlags(suppress_embeds, suppress_notifications)` - Set flags to hide embeds or send silently
- `SetPayload(payload)` - Set raw payload as a struct or a valid JSON string
- `GetPayload()` - Get the current payload struct
- `SetEmbeds(embeds)` - Set an array of embeds at once
- `SetTTS(enabled)` - Enable text-to-speech
- `AddEmbed(embed)` - Attach rich embed
- `AddPoll(poll)` - Attach interactive poll
- `AddFile(filename)` - Attach file from disk
- `AddBuffer(buffer, name)` - Attach buffer as file
- `Execute()` - Send new message
- `Edit()` - Edit existing message
- `Delete()` - Delete message
- `Async(trace)` - Process HTTP response with optional debug traces
- `Processed()` - Check if request completed
- `Clear()` - Clear all webhook data and reset to initial state
- `Destroy()` - Destroy webhook object and clean up all resources. Use if the webhook created but not executed

### DiscordEmbed Methods
- `SetTitle(title)` - Set embed title
- `SetDescription(description)` - Set main text
- `SetFields(fields)` - Set multiple fields at once using an array
- `SetColor(color)` - Set sidebar color
- `SetAuthor(name, url, icon_url)` - Set author info
- `SetURL(url)` - Make title clickable
- `SetImageURL(url)` - Set large image from URL
- `SetImageFile(filename)` - Set large image from attached file
- `SetThumbnail(url)` - Set small corner image
- `SetFooter(text, icon_url)` - Set bottom text
- `SetTimestamp(timestamp)` - Set time indicator
- `AddField(name, value, inline)` - Add data field

### DiscordPoll Methods
- `AddAnswer(text, emoji)` - Add poll option with optional emoji (supports both emoji names as strings and emoji IDs as numbers)

## Related links
- [Webhook Documentation](https://discord.com/developers/docs/resources/webhook)
- [Discord Webhooks Guide](https://birdie0.github.io/discord-webhooks-guide/index.html)
- [Embed Visualizer](https://leovoel.github.io/embed-visualizer/)
- [Discord.py](https://discordpy.readthedocs.io/en/stable/)
- [Embed Builder](https://glitchii.github.io/embedbuilder/)
- [Discohook](https://discohook.org/)
