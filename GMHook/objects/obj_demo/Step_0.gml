
if (keyboard_check_pressed(vk_space)) {
	webhook_poll.Execute()
}

if webhook_poll.Delivered() {
	webhook_poll.Delete()
}
