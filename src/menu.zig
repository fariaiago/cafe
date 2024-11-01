const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");

pub var jogar_pressed = false;

pub fn draw() void
{
	var font = rg.guiGetFont();
	font.baseSize = 2;
	rg.guiSetFont(font);
	rl.drawText("Café Transilvânia", 340, 16, 48, rl.Color.black);
	if (rg.guiButton(rl.Rectangle{.x = 540 - 128, .y = 500, .width = 256, .height = 128}, "Jogar") == 1)
	{
		jogar_pressed = true;
	}
}