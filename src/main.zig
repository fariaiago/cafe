const std = @import("std");
const rl = @import("raylib");

const SPEED = 400;

pub fn main() !void
{
	var path : [100]u8 = undefined;
	_ = try std.fs.cwd().realpath("/", &path);
	std.debug.print("{s}\n", .{try std.fs.cwd().realpath(".", &path)});
	rl.setConfigFlags(rl.ConfigFlags{.msaa_4x_hint = true});
	rl.initWindow(1080, 720, "Jogo");
	defer rl.closeWindow();
	var pos = rl.Vector2{ .x = 0, .y = 0};
	var camera = std.mem.zeroes(rl.Camera);
	camera.position = rl.Vector3{ .x = 0.0, .y = 10.0, .z = 10.0};
	camera.target = rl.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 };
	camera.up = rl.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0 };
	camera.fovy = 45.0;
	camera.projection = rl.CameraProjection.camera_perspective; 
	while (!rl.windowShouldClose())
	{
		var delta = rl.Vector2{ .x = 0, .y = 0};
		delta.x = @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.key_right)) - @as(i32, @intFromBool(rl.isKeyDown(rl.KeyboardKey.key_left))) );
		delta.y = @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.key_down)) - @as(i32, @intFromBool(rl.isKeyDown(rl.KeyboardKey.key_up))) );
		delta = delta.normalize();
		delta = delta.multiply(.{ .x = rl.getFrameTime() * SPEED, .y = rl.getFrameTime() * SPEED} );
		pos = pos.add(delta);
		rl.beginDrawing();
		rl.clearBackground(rl.Color.ray_white);
		{
			rl.beginMode3D(camera);
			rl.drawCube(rl.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 }, 2, 2, 2, rl.Color.blue);
			rl.drawPlane(rl.Vector3{ .x = 0.0, .y = 0.0, .z = 0.0 }, rl.Vector2{ .x = 8.0, .y = 8.0 }
				, rl.Color.light_gray);
			defer rl.endMode3D();
		}
		rl.drawRectangleV(pos, .{.x = 100, .y = 100}, rl.Color.red);
		defer rl.endDrawing();
	}
}