# <h1 align="center">GMHook 1.0.0</h1>
GMHook is a Discord Webhook integration system made for GameMaker, implemented with complete message, embed, file and poll support

## How to use!
1. Create a Discord Webhook in your server channel by going to **Edit channel** → **Integrations** → **Webhooks** → **Create Webhook**.
   Configure the name, avatar and channel, then copy the webhook URL.
   
2. Create a webhook instance and start sending messages:
   ```gml
   // Create webhook instance
   webhook = new DiscordWebhook("https://discord.com/api/webhooks/YOUR_WEBHOOK_URL");
   
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

## Complete API Reference

### DiscordWebhook Methods
- `SetUser(username, avatar_url)` - Set custom webhook identity
- `SetContent(content)` - Set message text content
- `SetPayload(payload)` - Set raw payload as a struct or a valid JSON string
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

### DiscordEmbed Methods
- `SetTitle(title)` - Set embed title
- `SetDescription(description)` - Set main text
- `SetColor(color)` - Set sidebar color
- `SetAuthor(name, icon_url, url)` - Set author info
- `SetURL(url)` - Make title clickable
- `SetImageURL(url)` - Set large image from URL
- `SetImageFile(filename)` - Set large image from attached file
- `SetThumbnail(url)` - Set small corner image
- `SetFooter(text, icon_url)` - Set bottom text
- `SetTimestamp(timestamp)` - Set time indicator
- `AddField(name, value, inline)` - Add data field

### DiscordPoll Methods
- `AddAnswer(text, emoji)` - Add poll option with optional emoji
