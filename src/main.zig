const std = @import("std");
const rl = @import("raylib");

// Cenas
const menu = @import("menu.zig");
const game = @import("game.zig");
const retry = @import("retry.zig");

const Cenas = enum {
	menu,
	game,
	retry,
};

pub fn main() !void
{
	var current_scene = Cenas.menu;
	rl.setRandomSeed(@intCast(std.time.timestamp()));
	rl.setConfigFlags(rl.ConfigFlags{.msaa_4x_hint = true});

	rl.initWindow(1080, 720, "Jogo");
	defer rl.closeWindow();
	
	game.init();
	defer game.deinit();

	while (!rl.windowShouldClose())
	{
		if (menu.jogar_pressed)
		{
			current_scene = .game;
			menu.jogar_pressed = false;
			rl.disableCursor();
		}
		else if (game.lifes == 0)
		{
			game.restart();
			current_scene = .retry;
			game.lifes = 3;
			rl.enableCursor();
		}
		else if (retry.voltar_pressed)
		{
			current_scene = .menu;
			retry.voltar_pressed = false;
		}

		switch (current_scene)
		{
			.game => game.update(),
			else => {},
		}
		
		rl.beginDrawing();
		defer rl.endDrawing();
		rl.clearBackground(rl.Color.ray_white);
		
		switch (current_scene) {
			.menu => menu.draw(),
			.game => {
				{
					rl.beginMode3D(game.camera);
					defer rl.endMode3D();
					game.draw3d();
				}
				game.draw();
			},
			.retry => retry.draw(),
		}
	}
}