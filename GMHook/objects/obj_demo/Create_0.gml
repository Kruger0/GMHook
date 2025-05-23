
#macro WEBHOOK_URL "https://discord.com/api/webhooks/1374805471780802662/Mn75drFiI1Y7YwhmR6JXlZqcQbmGUmNOiTYAu9-5gLibJimikKFOcxrqWHQK-ZENuelT"

surf	= -1
stroke	= 8
mx		= 0
my		= 0
mxp		= 0
myp		= 0
color	= #202020
bg		= #E0D0B0
label	= ""

dbg_view("GMS Paint", true, 16, 32, 350, 200)
dbg_section("Brush")
dbg_color(ref_create(self, "color"), "Pencil Color")
dbg_text_input(ref_create(self, "label"), "Drawing Description")

send = function() {
	var _filename = "screenshot.png"
	surface_save(surf, _filename)
	print = new DiscordWebhook(WEBHOOK_URL)
	//print.SetUser("Gamemaker Paint", "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcReflYD3bP9E2XvdDCU-8Z42M30Q43YWQjYxg&s")
	print.SetContent(label)
	print.AddFile(_filename)
	print.Execute()
	file_delete(_filename)
}
dbg_button("Send Drawing!", ref_create(self, "send"))


embed_demo = new DiscordEmbed()
	.SetTitle("Title")
	.SetDescription("Text message. You can use Markdown here. *Italic* **bold** __underline__ ~~strikeout~~ [hyperlink](https://google.com) `code`")
	.SetColor(#E8D44F)
	.SetURL("https://google.com/")
	.SetAuthor("Birdie♫", "https://i.imgur.com/R66g1Pe.jpg", "https://www.reddit.com/r/cats/")
	.SetFields([
		{
          "name": "Text",
          "value": "More text",
          "inline": true
        },
        {
          "name": "Even more text",
          "value": "Yup",
          "inline": true
        },
        {
          "name": "Use `\"inline\": true` parameter, if you want to display fields in the same line.",
          "value": "okay..."
        },
	])
	.AddField("Thanks!", "You're welcome :wink:")
	.SetThumbnail("https://i.imgur.com/CaQK26p.jpeg")
	.SetImage("https://i.imgur.com/ZGPxFN2.jpg")
	.SetFooter("Woah! So cool!", "https://i.imgur.com/fKL31aD.jpg")
	.SetTimestamp("2015-12-31T12:00:00.000Z")

webhook_embed = new DiscordWebhook(WEBHOOK_URL) 
	.SetUser("Webhook", "https://i.imgur.com/4M34hi2.png")
	.SetContent("Text message. Up to 2000 characters.")
	.AddEmbed(embed_demo)
	.Execute()




//poll_demo = new DiscordPoll("Cat person or dog person?", 48, true)
//	.AddAnswer("meow!", 1365720705324421202)
//	.AddAnswer("woof!", "🐶")	

webhook_poll = new DiscordWebhook(WEBHOOK_URL)
	.SetContent("Hello Discord")
	//.AddPoll(poll_demo)
	//.Execute()

var json_map = ds_map_create();
    
