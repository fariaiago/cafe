const std = @import("std");
const rl = @import("raylib");

const SPEED = 4;

pub fn main() !void
{
	rl.setConfigFlags(rl.ConfigFlags{.msaa_4x_hint = true});

	rl.initWindow(1080, 720, "Jogo");
	defer rl.closeWindow();

	var camera = rl.Camera{ .position = rl.Vector3{ .x = -4.0, .y = 1.0, .z = 0.0},
		.target = rl.Vector3{ .x = 1.0, .y = 1.0, .z = 0.0},
		.up = rl.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0},
		.fovy = 45.0,
		.projection = rl.CameraProjection.camera_perspective,
	};

	rl.disableCursor();

	while (!rl.windowShouldClose())
	{
		var mov = rl.Vector3{
			.x = @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.key_w)) - @as(i32, @intFromBool(rl.isKeyDown(rl.KeyboardKey.key_s))) ),
			.y = @floatFromInt(@intFromBool(rl.isKeyDown(rl.KeyboardKey.key_d)) - @as(i32, @intFromBool(rl.isKeyDown(rl.KeyboardKey.key_a))) ),
			.z = 0,
		};
		mov = mov.normalize();
		mov = mov.multiply(.{ .x = rl.getFrameTime() * SPEED, .y = rl.getFrameTime() * SPEED, .z = 0} );
		const rot = rl.Vector3{.x = rl.getMouseDelta().x / 5.4, .y = rl.getMouseDelta().y / 5.4, .z = 0};
		
		rl.updateCameraPro(&camera, mov, rot, 0);
		
		rl.beginDrawing();
		defer rl.endDrawing();

		rl.clearBackground(rl.Color.ray_white);
		{
			rl.beginMode3D(camera);
			defer rl.endMode3D();
			rl.drawPlane(rl.Vector3{ .x = 6.0, .y = 0.0, .z = 6.0 }, rl.Vector2{ .x = 16.0, .y = 16.0 },
					rl.Color.light_gray);
			for (0..4) |i|
			{
				for (0..4) |j|
				{
					rl.drawCube(rl.Vector3{ .x = @as(f32, @floatFromInt(i)) * 4, .y = 1, .z = @as(f32, @floatFromInt(j)) * 4},
						2, 2, 2, rl.Color.dark_blue);
				}
			}
		}
	}
}