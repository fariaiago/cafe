const std = @import("std");
const rl = @import("raylib");

const Mesa = struct {
	const size: f32 = 2;
	const State = enum {
		client,
		vampire,
		empty,
		success_vampire,
		success_client,
	};

	progress: u8 = 0,
	state: State = State.empty,
	pos: rl.Vector3,
	timestamp: f64 = 0,

	fn update(self: *Mesa, secs: f64) void
	{
		switch (self.state)
		{
			.client, .vampire => {
				if (secs - self.timestamp < 15)
				{
					self.progress = @intFromFloat(secs - self.timestamp);
				}
				else if (secs - self.timestamp > 15)
				{
					self.state = State.empty;
				}
			},
			.empty => {
				const rng = rl.getRandomValue(0, 100000);
				if (rng < 1)
				{
					self.spawnVampire();
				}
				else if (rng < 3)
				{
					self.spawnClient();
				}
			},
			else => self.progress = 0,
		}
	}

	fn draw(self: Mesa, camera: rl.Camera, bil_texture: []rl.Texture2D) void
	{
		rl.drawCube( self.pos, size, size, size, switch (self.state)
		{
			.client => rl.Color.yellow,
			.vampire => rl.Color.maroon,
			.empty => rl.Color.dark_blue,
			.success_client, .success_vampire => rl.Color.green,
		});
		switch (self.state)
		{
			.client, .vampire => rl.drawBillboard(camera, bil_texture[self.progress],
				self.pos.add(rl.Vector3{.x = 0, .y = 1.5, .z = 0}), 1, rl.Color.white),
			else => {},
		}
	}

	fn onMouseClick(self: *Mesa) void
	{
		switch (self.state)
		{
			.vampire => self.state = .empty,
			.empty => self.spawnClient(),
			else => {}
		}
	}

	fn spawnVampire(self: *Mesa) void
	{
		self.state = .vampire;
		self.progress = 0;
		self.timestamp = rl.getTime();
	}

	fn spawnClient(self: *Mesa) void
	{
		self.state = .client;
		self.progress = 0;
		self.timestamp = rl.getTime();
	}
};

const Maquina = struct {
	pos: rl.Vector3,
	const size = rl.Vector3{.x = 1, .y = 2, .z = 1};

	fn draw(self: Maquina) void
	{
		rl.drawCube( self.pos, size.x, size.y, size.z, rl.Color.magenta);
	}

	fn onMouseClick() void
	{
		has_coffe = true;
	}
};

const SPEED = 4;
var has_coffe = false;

pub fn main() !void
{
	rl.setRandomSeed(@intCast(std.time.timestamp()));
	var mesas : [16]Mesa = undefined;
	for (0..4) |i|
	{
		for (0..4) |j|
		{
			mesas[i * 4 + j] = Mesa{ .pos = rl.Vector3{ .x = @as(f32, @floatFromInt(i)) * 4, .y = 1,
				.z = @as(f32, @floatFromInt(j)) * 4}};
		}
	}
	var maquina_frente = Maquina{ .pos = rl.Vector3{.x = -4, .y = 1, .z = 6}};
	var maquina_tras = Maquina{ .pos = rl.Vector3{.x = 20, .y = 1, .z = 8}};
	rl.setConfigFlags(rl.ConfigFlags{.msaa_4x_hint = true});

	rl.initWindow(1080, 720, "Jogo");
	defer rl.closeWindow();

	var clock_frames: [15]rl.Texture2D = undefined;
	for (0..15) |i|
	{
		var image = rl.genImageColor(210, 64, rl.Color.gray);
		rl.imageDrawRectangle(&image, 2, 2, 210 - 14 * @as(i32, @intCast(i)) - 4, 60, rl.Color.green);
		defer rl.unloadImage(image);
		clock_frames[i] = rl.loadTextureFromImage(image); // TODO Transformar em circulos
	}
	
	defer {
		for (clock_frames) |texture|
		{
			rl.unloadTexture(texture);
		}
	}

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
		rl.setMousePosition(540, 360);
		if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left))
		{
			const ray = rl.getScreenToWorldRay(rl.getMousePosition(), camera);

			for (mesas, 0..) |mesa, i|
			{
				const collision = rl.getRayCollisionBox(ray,
					rl.BoundingBox{ .min = rl.Vector3{ .x = mesa.pos.x - Mesa.size / 2, .y = mesa.pos.y - Mesa.size / 2, .z = mesa.pos.z - Mesa.size / 2 },
					.max = rl.Vector3{ .x = mesa.pos.x + Mesa.size / 2, .y = mesa.pos.y + Mesa.size / 2, .z = mesa.pos.z + Mesa.size / 2 }});
				if (collision.hit)
				{
					mesas[i].onMouseClick();
					break;
				}
			}
			const collision = rl.getRayCollisionBox(ray,
				rl.BoundingBox{ .min = maquina_frente.pos.subtract(Maquina.size.scale(0.5)), .max = maquina_frente.pos.add(Maquina.size.scale(0.5))});
			if (collision.hit)
			{
				Maquina.onMouseClick();
			}
		}
		for (mesas, 0..) |mesa, i|
		{
			mesas[i].update(rl.getTime());
			_ = mesa.progress;
		}
		
		rl.beginDrawing();
		defer rl.endDrawing();

		rl.clearBackground(rl.Color.ray_white);
		{
			rl.beginMode3D(camera);
			defer rl.endMode3D();
			rl.drawPlane(rl.Vector3{ .x = 6.0, .y = 0.0, .z = 6.0 }, rl.Vector2{ .x = 16.0, .y = 16.0 },
					rl.Color.light_gray);
			for (mesas) |mesa|
			{
				mesa.draw(camera, &clock_frames);
			}
			maquina_frente.draw();
			maquina_tras.draw();
		}
		rl.drawFPS(0, 0);
		if(has_coffe)
		{
			rl.drawRectangle(100, 100, 100, 100, rl.Color.black);
		}
	}
}