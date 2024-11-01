const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub var voltar_pressed = false;

pub fn draw() void
{
	var font = rg.guiGetFont();
	font.baseSize = 3;
	rg.guiSetFont(font);
	rl.drawText("Você perdeu!", 380, 256, 48, rl.Color.black);
	if (rg.guiButton(rl.Rectangle{.x = 540 - 128, .y = 500, .width = 256, .height = 128}, "Voltar ao menu") == 1)
	{
		voltar_pressed = true;
	}
}