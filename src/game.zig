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
				if (secs - self.timestamp < PROGRESS_ANIM_LEN)
				{
					self.progress = @intFromFloat(secs - self.timestamp);
				}
				else if (secs - self.timestamp > PROGRESS_ANIM_LEN)
				{
					lifes -= 1;
					self.state = .empty;
				}
			},
			.empty => {
				const rng = rl.getRandomValue(0, 100000); // TODO Melhorar isso aqui
				if (rng < 1)
				{
					self.spawnVampire();
				}
				else if (rng < 3)
				{
					self.spawnClient();
				}
			},
			.success_client, .success_vampire => {
				if (secs - self.timestamp > SUCCESS_ANIM_LEN)
				{
					self.state = .empty;
				}
			},
		}
	}

	fn draw(self: Mesa, bil_texture: []rl.Texture2D) void
	{
		switch (self.state) {
			.client => rl.drawModel(vox_models[1], self.pos, 0.1, rl.Color.white),
			.vampire => rl.drawModel(vox_models[2], self.pos, 0.1, rl.Color.white),
			else => rl.drawModel(vox_models[0], self.pos, 0.1, rl.Color.white),
		}
		switch (self.state)
		{
			.client, .vampire => rl.drawBillboard(camera, bil_texture[self.progress],
				self.pos.add(rl.Vector3{.x = 0, .y = 2, .z = 0}), 1, rl.Color.white),
			else => {},
		}
	}

	fn onMouseClick(self: *Mesa) void
	{
		switch (self.state)
		{
			.vampire => {
				self.state = .success_vampire;
				self.progress = 0;
				self.timestamp = rl.getTime();
			},
			.client => {
				if (has_coffe)
				{
					has_coffe = false;
					self.state = .success_client;
					self.progress = 0;
					self.timestamp = rl.getTime();
				}
			},
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

const SPEED = 5;
const MESA_NUM = 16;
const MESA_ROW_LEN = 4;
const PROGRESS_ANIM_LEN = 15;
const SUCCESS_ANIM_LEN = 2;
const INTERACTION_MAX_DIST = 7.0;
const MODEL_NUM = 3;

var mesas : [MESA_NUM]Mesa = undefined;
var clock_frames: [PROGRESS_ANIM_LEN]rl.Texture2D = undefined;
var maquina_frente = Maquina{ .pos = rl.Vector3{.x = -2, .y = 1, .z = 6}};
var maquina_fundo = Maquina{ .pos = rl.Vector3{.x = 16, .y = 1, .z = 8}};
pub var camera = rl.Camera{ .position = rl.Vector3{ .x = -4.0, .y = 1.0, .z = 0.0},
	.target = rl.Vector3{ .x = 1.0, .y = 1.0, .z = 0.0},
	.up = rl.Vector3{ .x = 0.0, .y = 1.0, .z = 0.0},
	.fovy = 45.0,
	.projection = rl.CameraProjection.camera_perspective,
};

const vox_paths: [MODEL_NUM][*:0]const u8 = [_][*:0]const u8{"res/model/mesa.vox", "res/model/mesa_cliente.vox", "res/model/mesa_vampiro.vox"};

var has_coffe = false;
pub var lifes: u8 = 3;
var vox_models: [MODEL_NUM]rl.Model = undefined;

pub fn init() void
{
	for (0..MODEL_NUM) |i|
	{
		vox_models[i] = rl.loadModel(vox_paths[i]);
	}
	for (0..MESA_ROW_LEN) |i|
	{
		for (0..MESA_ROW_LEN) |j|
		{
			mesas[i * MESA_ROW_LEN + j] = Mesa{ .pos = rl.Vector3{ .x = @as(f32, @floatFromInt(i)) * 4, .y = 0,
				.z = @as(f32, @floatFromInt(j)) * 4}};
		}
	}
	// Gera os quadros da barra de progresso
	for (0..PROGRESS_ANIM_LEN) |i|
	{
		var image = rl.genImageColor(210, 64, rl.Color.gray);
		rl.imageDrawRectangle(&image, 2, 2, 210 - (PROGRESS_ANIM_LEN - 1) * @as(i32, @intCast(i)) - 4, 60, rl.Color.green);
		defer rl.unloadImage(image);
		clock_frames[i] = rl.loadTextureFromImage(image); // TODO Transformar em circulos
	}
}

pub fn deinit() void
{
	for (clock_frames) |texture|
	{
		rl.unloadTexture(texture);
	}
	for (0..MODEL_NUM) |i|
	{
		 rl.unloadModel(vox_models[i]);
	}
}

pub fn restart() void
{
	camera.position = rl.Vector3{ .x = -4.0, .y = 1.0, .z = 0.0};
	camera.target = rl.Vector3{ .x = 1.0, .y = 1.0, .z = 0.0};
	for (0..MESA_NUM) |i|
	{
		mesas[i].state = .empty;
	}
}

pub fn update() void
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
			var box = rl.getModelBoundingBox(vox_models[1]);
			box.min = box.min.scale(0.1).add(mesa.pos);
			box.max = box.max.scale(0.1).add(mesa.pos);
			const collision = rl.getRayCollisionBox(ray, box);
			if (collision.hit and collision.distance < INTERACTION_MAX_DIST)
			{
				mesas[i].onMouseClick();
				break;
			}
		}
		const collision_frente = rl.getRayCollisionBox(ray,
			rl.BoundingBox{ .min = maquina_frente.pos.subtract(Maquina.size.scale(0.5)), .max = maquina_frente.pos.add(Maquina.size.scale(0.5))});
		const collision_fundo = rl.getRayCollisionBox(ray,
			rl.BoundingBox{ .min = maquina_fundo.pos.subtract(Maquina.size.scale(0.5)), .max = maquina_fundo.pos.add(Maquina.size.scale(0.5))});
		if ((collision_frente.hit and collision_frente.distance < INTERACTION_MAX_DIST) or (collision_fundo.hit and collision_fundo.distance < INTERACTION_MAX_DIST))
		{
			Maquina.onMouseClick();
		}
	}
	for (0..MESA_NUM) |i|
	{
		mesas[i].update(rl.getTime());
	}
}

pub fn draw() void
{
	for (0..lifes) |i|
	{
		rl.drawRectangle(@intCast(i * 36), 0, 32, 32, rl.Color.red);
	}
	rl.drawFPS(0, 48);
	if(has_coffe)
	{
		rl.drawRectangle(1080 - 64, 0, 64, 64, rl.Color.black);
	}
}

pub fn draw3d() void
{
	rl.drawPlane(rl.Vector3{ .x = 8.0, .y = 0.0, .z = 8.0 }, rl.Vector2{ .x = 24.0, .y = 24.0 },
			rl.Color.light_gray);
	for (mesas) |mesa|
	{
		mesa.draw(&clock_frames);
	}
	maquina_frente.draw();
	maquina_fundo.draw();

}
