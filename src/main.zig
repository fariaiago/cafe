const std = @import("std");
const rl = @import("raylib");

// Cenas
const game = @import("game.zig");

pub fn main() !void
{
	rl.setRandomSeed(@intCast(std.time.timestamp()));
	rl.setConfigFlags(rl.ConfigFlags{.msaa_4x_hint = true});

	rl.initWindow(1080, 720, "Jogo");
	defer rl.closeWindow();

	
	game.init();
	defer game.deinit();

	rl.disableCursor();

	while (!rl.windowShouldClose())
	{
		game.update();
		
		rl.beginDrawing();
		defer rl.endDrawing();
		rl.clearBackground(rl.Color.ray_white);
		{
			rl.beginMode3D(game.camera);
			defer rl.endMode3D();
			game.draw3d();
		}
		game.draw();
	}
}