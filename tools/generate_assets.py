#!/usr/bin/env python3
"""
Rail Empire Asset Pipeline
==========================
Procedurally generates 2D isometric sprites for the Godot train game using
Blender's Python API (bpy). Each asset is rendered with a transparent
background (RGBA) and exported as a PNG.

Run from the project root:
    blender --background --python tools/generate_assets.py

Game context:
    - 2D isometric train strategy game set in 1857 Bengal
    - Isometric angle: ~45° from top-down, looking at the corner
    - Target resolution: ~64-128 px for tiles, ~32-64 px for trains / cities
"""

import bpy
import math
import os
import random

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
PROJECT_ROOT = os.path.dirname(SCRIPT_DIR)
OUTPUT_DIR = os.path.join(PROJECT_ROOT, "assets", "generated")

# Render resolution (128 px gives crisp 1x / 2x scaling for the game)
RENDER_SIZE = 128

# Isometric camera constants
# 45° from top-down  => 45° from the Z axis (zenith angle)
# Azimuth set to 45° so we look at the corner.
CAM_DISTANCE = 10.0
CAM_THETA = math.radians(45.0)   # polar angle from +Z
CAM_PHI = math.radians(45.0)     # azimuth from +X toward +Y

# ---------------------------------------------------------------------------
# Scene Utilities
# ---------------------------------------------------------------------------


def ensure_output_dir() -> None:
    """Create the output directory if it does not exist."""
    os.makedirs(OUTPUT_DIR, exist_ok=True)


def clear_scene() -> None:
    """Remove every object and purge unused data blocks (meshes, mats, etc.)."""
    # Delete all objects from the current scene
    for obj in list(bpy.context.scene.objects):
        bpy.data.objects.remove(obj, do_unlink=True)

    # Purge orphaned data blocks so names stay clean between assets
    for block in (bpy.data.meshes, bpy.data.materials, bpy.data.cameras,
                  bpy.data.lights, bpy.data.curves, bpy.data.metaballs):
        for item in list(block):
            if item.users == 0:
                block.remove(item)


def setup_render_engine() -> None:
    """Configure Blender for sprite rendering (transparent BG, RGBA PNG)."""
    scene = bpy.context.scene

    # Prefer Eevee (fast), fall back to Eevee Legacy or Cycles if unavailable
    try:
        scene.render.engine = 'BLENDER_EEVEE_NEXT'
    except (TypeError, RuntimeError):
        try:
            scene.render.engine = 'BLENDER_EEVEE'
        except (TypeError, RuntimeError):
            scene.render.engine = 'CYCLES'

    scene.render.resolution_x = RENDER_SIZE
    scene.render.resolution_y = RENDER_SIZE
    scene.render.resolution_percentage = 100
    scene.render.film_transparent = True
    scene.render.image_settings.file_format = 'PNG'
    scene.render.image_settings.color_mode = 'RGBA'


def setup_camera(ortho_scale: float = 3.0) -> bpy.types.Object:
    """Create an orthographic camera at the isometric angle."""
    cam_data = bpy.data.cameras.new(name="IsometricCamera")
    cam_obj = bpy.data.objects.new("IsometricCamera", cam_data)
    bpy.context.collection.objects.link(cam_obj)

    cam_data.type = 'ORTHO'
    cam_data.ortho_scale = ortho_scale

    # Spherical coordinates: theta from +Z, phi from +X
    x = CAM_DISTANCE * math.sin(CAM_THETA) * math.cos(CAM_PHI)
    y = CAM_DISTANCE * math.sin(CAM_THETA) * math.sin(CAM_PHI)
    z = CAM_DISTANCE * math.cos(CAM_THETA)
    cam_obj.location = (x, y, z)

    # Point camera at the origin
    direction = -cam_obj.location
    rot_quat = direction.to_track_quat('-Z', 'Y')
    cam_obj.rotation_euler = rot_quat.to_euler()

    bpy.context.scene.camera = cam_obj
    return cam_obj


def setup_lighting() -> None:
    """Add a key sun + fill sun for soft, readable shading."""
    # Key light (warm, from above-right)
    sun_key_data = bpy.data.lights.new(name="Sun_Key", type='SUN')
    sun_key_data.energy = 4.0
    sun_key_data.color = (1.0, 0.98, 0.95)
    sun_key_obj = bpy.data.objects.new("Sun_Key", sun_key_data)
    bpy.context.collection.objects.link(sun_key_obj)
    sun_key_obj.location = (8, 4, 12)
    sun_key_obj.rotation_euler = (math.radians(50), 0, math.radians(30))

    # Fill light (cool, from opposite side)
    sun_fill_data = bpy.data.lights.new(name="Sun_Fill", type='SUN')
    sun_fill_data.energy = 1.5
    sun_fill_data.color = (0.9, 0.95, 1.0)
    sun_fill_obj = bpy.data.objects.new("Sun_Fill", sun_fill_data)
    bpy.context.collection.objects.link(sun_fill_obj)
    sun_fill_obj.location = (-6, -8, 6)
    sun_fill_obj.rotation_euler = (math.radians(60), 0, math.radians(220))


def new_material(name: str, rgb: tuple, roughness: float = 0.8,
                 metallic: float = 0.0) -> bpy.types.Material:
    """Create a simple Principled BSDF material."""
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        bsdf.inputs["Base Color"].default_value = (*rgb, 1.0)
        bsdf.inputs["Roughness"].default_value = roughness
        bsdf.inputs["Metallic"].default_value = metallic
    return mat


def assign_material(obj: bpy.types.Object, mat: bpy.types.Material) -> None:
    """Assign (or replace) the active material on a mesh object."""
    if obj.data.materials:
        obj.data.materials[0] = mat
    else:
        obj.data.materials.append(mat)


def render_to_png(filename: str) -> None:
    """Render the current scene to a PNG in OUTPUT_DIR."""
    filepath = os.path.join(OUTPUT_DIR, filename)
    bpy.context.scene.render.filepath = filepath
    bpy.ops.object.select_all(action='DESELECT')
    bpy.ops.render.render(write_still=True)
    print(f"  -> {filepath}")


# ---------------------------------------------------------------------------
# Low-poly Builders
# ---------------------------------------------------------------------------

def create_diamond(size: float = 1.0) -> bpy.types.Object:
    """Create a flat diamond mesh in the XY plane (isometric ground tile)."""
    mesh = bpy.data.meshes.new("Diamond")
    obj = bpy.data.objects.new("Diamond", mesh)
    bpy.context.collection.objects.link(obj)

    verts = [
        (size, 0.0, 0.0),      # right
        (0.0, size, 0.0),      # front
        (-size, 0.0, 0.0),     # left
        (0.0, -size, 0.0),     # back
    ]
    faces = [(0, 1, 2, 3)]
    mesh.from_pydata(verts, [], faces)
    mesh.update()
    return obj


# ---------------------------------------------------------------------------
# 1. Terrain Tiles
# ---------------------------------------------------------------------------

def build_plains_tile() -> None:
    """Flat green-brown ground."""
    tile = create_diamond(size=1.0)
    mat = new_material("Plains", (0.38, 0.55, 0.26), roughness=1.0)
    assign_material(tile, mat)


def build_river_tile() -> None:
    """Blue water with slight wave ridges."""
    tile = create_diamond(size=1.0)
    mat = new_material("River", (0.22, 0.42, 0.72), roughness=0.25, metallic=0.15)
    assign_material(tile, mat)

    wave_mat = new_material("Wave", (0.45, 0.62, 0.92), roughness=0.2)
    for i in range(3):
        bpy.ops.mesh.primitive_plane_add(size=0.6, location=(0.0, -0.25 + i * 0.25, 0.015))
        wave = bpy.context.active_object
        wave.scale = (0.75, 0.06, 1.0)
        assign_material(wave, wave_mat)


def build_wetland_tile() -> None:
    """Muddy green with scattered puddles."""
    tile = create_diamond(size=1.0)
    mat = new_material("Wetland", (0.32, 0.42, 0.22), roughness=1.0)
    assign_material(tile, mat)

    puddle_mat = new_material("Puddle", (0.18, 0.24, 0.28), roughness=0.15)
    for _ in range(5):
        x = random.uniform(-0.55, 0.55)
        y = random.uniform(-0.55, 0.55)
        if abs(x) + abs(y) < 0.75:
            bpy.ops.mesh.primitive_cylinder_add(
                radius=random.uniform(0.08, 0.16), depth=0.01,
                location=(x, y, 0.01)
            )
            puddle = bpy.context.active_object
            assign_material(puddle, puddle_mat)


def build_forest_tile() -> None:
    """Green ground with low-poly tree tops peeking up."""
    tile = create_diamond(size=1.0)
    mat = new_material("ForestGround", (0.22, 0.48, 0.22), roughness=1.0)
    assign_material(tile, mat)

    trunk_mat = new_material("Trunk", (0.42, 0.28, 0.18), roughness=1.0)
    leaf_mat = new_material("Leaf", (0.16, 0.52, 0.18), roughness=0.9)

    for _ in range(6):
        x = random.uniform(-0.6, 0.6)
        y = random.uniform(-0.6, 0.6)
        if abs(x) + abs(y) < 0.85:
            # Trunk
            bpy.ops.mesh.primitive_cylinder_add(
                radius=0.035, depth=0.25, location=(x, y, 0.125)
            )
            trunk = bpy.context.active_object
            assign_material(trunk, trunk_mat)

            # Crown
            bpy.ops.mesh.primitive_cone_add(
                radius1=0.17, radius2=0.0, depth=0.32, location=(x, y, 0.38)
            )
            crown = bpy.context.active_object
            assign_material(crown, leaf_mat)


def build_hills_tile() -> None:
    """Brown elevation mound rising from a diamond base."""
    tile = create_diamond(size=1.0)
    mat = new_material("HillsBase", (0.46, 0.38, 0.24), roughness=1.0)
    assign_material(tile, mat)

    # Central mound
    bpy.ops.mesh.primitive_uv_sphere_add(radius=0.65, location=(0.0, 0.0, 0.0))
    mound = bpy.context.active_object
    mound.scale = (1.0, 1.0, 0.32)
    # Raise so the bottom sits flush with the ground plane
    mound.location.z = 0.65 * 0.32
    mound_mat = new_material("HillMound", (0.52, 0.44, 0.28), roughness=1.0)
    assign_material(mound, mound_mat)


# ---------------------------------------------------------------------------
# 2. Train Sprites
# ---------------------------------------------------------------------------

def _rotate_scene_meshes(rot_z: float) -> None:
    """Rotate every mesh object around the world Z axis by *rot_z* radians."""
    cos_r = math.cos(rot_z)
    sin_r = math.sin(rot_z)
    for obj in bpy.context.scene.objects:
        if obj.type == 'MESH':
            x, y, z = obj.location
            obj.location = (x * cos_r - y * sin_r, x * sin_r + y * cos_r, z)
            obj.rotation_euler.z += rot_z


def _build_train_common(length: float, width: float, height: float,
                        body_color: tuple, is_mixed: bool = False) -> None:
    """Shared geometry for trains: body, wheels, chimney, optional windows."""
    # Main body
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0.0, 0.0, height / 2 + 0.16))
    body = bpy.context.active_object
    body.scale = (length, width, height)
    body_mat = new_material("TrainBody", body_color, roughness=0.55)
    assign_material(body, body_mat)

    # Wheels
    wheel_mat = new_material("Wheel", (0.1, 0.1, 0.1), roughness=0.6, metallic=0.5)
    wheel_r = 0.14
    wheel_w = 0.04
    wheel_z = 0.16
    wheel_y = width / 2 + 0.025

    axle_x_positions = [-length * 0.32, length * 0.32]
    if length > 1.1:
        axle_x_positions = [-length * 0.35, 0.0, length * 0.35]

    for wx in axle_x_positions:
        for side in (-1, 1):
            bpy.ops.mesh.primitive_cylinder_add(
                radius=wheel_r, depth=wheel_w, location=(wx, side * wheel_y, wheel_z)
            )
            wheel = bpy.context.active_object
            wheel.rotation_euler = (math.radians(90), 0, 0)
            assign_material(wheel, wheel_mat)

    # Chimney
    bpy.ops.mesh.primitive_cylinder_add(
        radius=0.07, depth=0.22,
        location=(length * 0.32, 0.0, height + 0.16 + 0.11)
    )
    chimney = bpy.context.active_object
    chimney_mat = new_material("Chimney", (0.15, 0.15, 0.15),
                               roughness=0.5, metallic=0.8)
    assign_material(chimney, chimney_mat)

    if is_mixed:
        win_mat = new_material("Window", (0.2, 0.22, 0.28), roughness=0.2)
        for wx in (-length * 0.2, length * 0.2):
            bpy.ops.mesh.primitive_plane_add(
                size=0.14, location=(wx, width / 2 + 0.008, height / 2 + 0.16)
            )
            win = bpy.context.active_object
            assign_material(win, win_mat)


def build_train_freight(direction: str = "SE") -> None:
    """Long boxy freight locomotive."""
    rot = {"SE": 0.0,
           "SW": math.radians(90.0),
           "NW": math.radians(180.0),
           "NE": math.radians(270.0)}.get(direction, 0.0)

    _build_train_common(length=1.45, width=0.42, height=0.48,
                        body_color=(0.52, 0.22, 0.16), is_mixed=False)
    _rotate_scene_meshes(rot)


def build_train_mixed(direction: str = "SE") -> None:
    """Shorter passenger-style mixed locomotive."""
    rot = {"SE": 0.0,
           "SW": math.radians(90.0),
           "NW": math.radians(180.0),
           "NE": math.radians(270.0)}.get(direction, 0.0)

    _build_train_common(length=0.95, width=0.38, height=0.52,
                        body_color=(0.62, 0.48, 0.28), is_mixed=True)
    _rotate_scene_meshes(rot)


# ---------------------------------------------------------------------------
# 3. City Markers
# ---------------------------------------------------------------------------

def build_city(size: str = "small", is_port: bool = False) -> None:
    """Cluster of simple box buildings; port cities get a dock/warehouse."""
    configs = {
        "small":  {"count": (2, 3), "hmax": 0.35, "base": 0.55},
        "medium": {"count": (3, 5), "hmax": 0.7,  "base": 0.85},
        "large":  {"count": (5, 8), "hmax": 1.1,  "base": 1.25},
    }
    cfg = configs[size]

    # Ground plate
    bpy.ops.mesh.primitive_plane_add(size=cfg["base"], location=(0.0, 0.0, 0.01))
    base = bpy.context.active_object
    base_mat = new_material("CityBase", (0.55, 0.52, 0.48), roughness=1.0)
    assign_material(base, base_mat)

    bld_mat = new_material("Building", (0.65, 0.58, 0.48), roughness=0.9)
    roof_mat = new_material("Roof", (0.42, 0.32, 0.26), roughness=1.0)

    count = random.randint(*cfg["count"])
    for _ in range(count):
        w = random.uniform(0.14, 0.28)
        d = random.uniform(0.14, 0.28)
        h = random.uniform(0.12, cfg["hmax"])
        x = random.uniform(-cfg["base"] * 0.28, cfg["base"] * 0.28)
        y = random.uniform(-cfg["base"] * 0.28, cfg["base"] * 0.28)

        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, y, h / 2))
        bld = bpy.context.active_object
        bld.scale = (w, d, h)
        assign_material(bld, bld_mat)

        # Simple flat roof
        bpy.ops.mesh.primitive_cube_add(size=1.0, location=(x, y, h + 0.02))
        roof = bpy.context.active_object
        roof.scale = (w + 0.02, d + 0.02, 0.04)
        assign_material(roof, roof_mat)

    if is_port:
        dock_mat = new_material("Dock", (0.45, 0.38, 0.32), roughness=1.0)
        # Warehouse block
        bpy.ops.mesh.primitive_cube_add(
            size=1.0, location=(cfg["base"] * 0.38, 0.0, cfg["hmax"] * 0.25)
        )
        wh = bpy.context.active_object
        wh.scale = (0.22, cfg["base"] * 0.5, cfg["hmax"] * 0.5)
        assign_material(wh, dock_mat)

        # Dock platform
        bpy.ops.mesh.primitive_cube_add(
            size=1.0, location=(cfg["base"] * 0.55, 0.0, 0.03)
        )
        dock = bpy.context.active_object
        dock.scale = (0.12, cfg["base"] * 0.6, 0.06)
        assign_material(dock, dock_mat)


# ---------------------------------------------------------------------------
# 4. Track Sprite
# ---------------------------------------------------------------------------

def build_track_segment() -> None:
    """Straight rail segment with wooden ties."""
    rail_mat = new_material("Rail", (0.32, 0.32, 0.32),
                            roughness=0.4, metallic=0.6)
    tie_mat = new_material("Tie", (0.38, 0.28, 0.18), roughness=1.0)

    length = 1.0
    rail_w = 0.02
    rail_h = 0.035
    rail_offset = 0.09

    # Two parallel rails
    for side in (-1, 1):
        bpy.ops.mesh.primitive_cube_add(
            size=1.0, location=(0.0, side * rail_offset, rail_h / 2)
        )
        rail = bpy.context.active_object
        rail.scale = (length, rail_w, rail_h)
        assign_material(rail, rail_mat)

    # Wooden ties
    tie_count = 7
    for i in range(tie_count):
        x = -length / 2 + (i / (tie_count - 1)) * length
        bpy.ops.mesh.primitive_cube_add(
            size=1.0, location=(x, 0.0, 0.012)
        )
        tie = bpy.context.active_object
        tie.scale = (0.05, 0.32, 0.025)
        assign_material(tie, tie_mat)


# ---------------------------------------------------------------------------
# 5. Cargo Icons
# ---------------------------------------------------------------------------

def build_cargo(cargo_type: str = "coal") -> None:
    """Small cargo piles: coal (black), grain (golden), textiles (bales)."""
    if cargo_type == "coal":
        mat = new_material("Coal", (0.08, 0.08, 0.08), roughness=0.95)
        bpy.ops.mesh.primitive_cone_add(
            radius1=0.2, radius2=0.0, depth=0.22, location=(0.0, 0.0, 0.11)
        )
        pile = bpy.context.active_object
        assign_material(pile, mat)

        for _ in range(4):
            bpy.ops.mesh.primitive_uv_sphere_add(
                radius=0.055,
                location=(random.uniform(-0.1, 0.1),
                          random.uniform(-0.1, 0.1),
                          0.055)
            )
            lump = bpy.context.active_object
            assign_material(lump, mat)

    elif cargo_type == "grain":
        mat = new_material("Grain", (0.72, 0.56, 0.2), roughness=1.0)
        bpy.ops.mesh.primitive_cone_add(
            radius1=0.22, radius2=0.0, depth=0.2, location=(0.0, 0.0, 0.1)
        )
        pile = bpy.context.active_object
        assign_material(pile, mat)

    elif cargo_type == "textiles":
        colours = [
            (0.72, 0.22, 0.22),   # red bale
            (0.22, 0.32, 0.62),   # indigo bale
            (0.78, 0.68, 0.22),   # turmeric bale
        ]
        spots = [
            (0.0, 0.0, 0.06),
            (0.13, 0.0, 0.06),
            (-0.07, 0.1, 0.06),
            (0.06, 0.1, 0.18),
        ]
        for i, pos in enumerate(spots):
            mat = new_material(f"Textile_{i}", colours[i % len(colours)], roughness=0.8)
            bpy.ops.mesh.primitive_cube_add(size=1.0, location=pos)
            bale = bpy.context.active_object
            bale.scale = (0.11, 0.07, 0.11)
            assign_material(bale, mat)


# ---------------------------------------------------------------------------
# Render Orchestration
# ---------------------------------------------------------------------------

def render_asset(filename: str, builder, ortho_scale: float = 3.0,
                 **kwargs) -> None:
    """Clean the scene, build the asset, and render it to PNG."""
    clear_scene()
    setup_camera(ortho_scale=ortho_scale)
    setup_lighting()
    builder(**kwargs)
    bpy.ops.object.select_all(action='DESELECT')
    render_to_png(filename)


def main() -> None:
    """Generate every asset required for Phase 0."""
    random.seed(42)
    ensure_output_dir()
    setup_render_engine()

    print("\n=== Terrain Tiles ===")
    render_asset("plains_tile.png", build_plains_tile, ortho_scale=2.6)
    render_asset("river_tile.png", build_river_tile, ortho_scale=2.6)
    render_asset("wetland_tile.png", build_wetland_tile, ortho_scale=2.6)
    render_asset("forest_tile.png", build_forest_tile, ortho_scale=3.0)
    render_asset("hills_tile.png", build_hills_tile, ortho_scale=2.8)

    print("\n=== Train Sprites ===")
    for direction in ("NW", "NE", "SW", "SE"):
        render_asset(f"train_freight_{direction}.png",
                     build_train_freight, ortho_scale=2.4, direction=direction)
        render_asset(f"train_mixed_{direction}.png",
                     build_train_mixed, ortho_scale=2.4, direction=direction)

    print("\n=== City Markers ===")
    render_asset("city_small.png", build_city, ortho_scale=1.8, size="small")
    render_asset("city_medium.png", build_city, ortho_scale=2.2, size="medium")
    render_asset("city_large.png", build_city, ortho_scale=2.8, size="large")
    # Port variants (Colonial Bengal had major river ports)
    render_asset("city_small_port.png", build_city,
                 ortho_scale=1.8, size="small", is_port=True)
    render_asset("city_medium_port.png", build_city,
                 ortho_scale=2.2, size="medium", is_port=True)
    render_asset("city_large_port.png", build_city,
                 ortho_scale=2.8, size="large", is_port=True)

    print("\n=== Track Segment ===")
    render_asset("track_segment.png", build_track_segment, ortho_scale=1.8)

    print("\n=== Cargo Icons ===")
    render_asset("cargo_coal.png", build_cargo, ortho_scale=1.0, cargo_type="coal")
    render_asset("cargo_grain.png", build_cargo, ortho_scale=1.0, cargo_type="grain")
    render_asset("cargo_textiles.png", build_cargo,
                 ortho_scale=1.0, cargo_type="textiles")

    print("\n========================================")
    print(f"Asset pipeline complete. Output: {OUTPUT_DIR}")
    print("========================================\n")


if __name__ == "__main__":
    main()
