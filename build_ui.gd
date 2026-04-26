extends SceneTree

func _init() -> void:
	print("Building UI resources...")
	
	# 1. Fonts
	var heading_font = SystemFont.new()
	heading_font.font_names = PackedStringArray(["Noto Serif", "Georgia", "Times New Roman", "Serif"])
	ResourceSaver.save(heading_font, "res://assets/fonts/heading_font.tres")
	
	var body_font = SystemFont.new()
	body_font.font_names = PackedStringArray(["Noto Sans", "Arial", "Helvetica", "Sans-Serif"])
	ResourceSaver.save(body_font, "res://assets/fonts/body_font.tres")
	
	# 2. Theme
	var theme = Theme.new()
	theme.default_font = body_font
	theme.default_font_size = 16
	
	theme.set_font("font", "Label", body_font)
	theme.set_font("font", "Button", body_font)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color("F5E6C8")
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color("1A1A1A")
	theme.set_stylebox("panel", "PanelContainer", panel_style)
	
	var nested_panel = StyleBoxFlat.new()
	nested_panel.bg_color = Color("E8DAB7")
	nested_panel.border_width_left = 1
	nested_panel.border_width_top = 1
	nested_panel.border_width_right = 1
	nested_panel.border_width_bottom = 1
	nested_panel.border_color = Color("1A1A1A")
	theme.set_stylebox("panel", "Panel", nested_panel)
	
	var btn_normal = StyleBoxFlat.new()
	btn_normal.bg_color = Color("B8860B")
	btn_normal.border_width_left = 1
	btn_normal.border_width_top = 1
	btn_normal.border_width_right = 1
	btn_normal.border_width_bottom = 1
	btn_normal.border_color = Color("1A1A1A")
	theme.set_stylebox("normal", "Button", btn_normal)
	theme.set_color("font_color", "Button", Color("1A1A1A"))
	
	var btn_hover = StyleBoxFlat.new()
	btn_hover.bg_color = Color("D4AF37")
	btn_hover.border_width_left = 2
	btn_hover.border_width_top = 2
	btn_hover.border_width_right = 2
	btn_hover.border_width_bottom = 2
	btn_hover.border_color = Color("1A1A1A")
	theme.set_stylebox("hover", "Button", btn_hover)
	
	var btn_pressed = StyleBoxFlat.new()
	btn_pressed.bg_color = Color("8B6508")
	btn_pressed.border_width_left = 1
	btn_pressed.border_width_top = 1
	btn_pressed.border_width_right = 1
	btn_pressed.border_width_bottom = 1
	btn_pressed.border_color = Color("1A1A1A")
	theme.set_stylebox("pressed", "Button", btn_pressed)
	
	ResourceSaver.save(theme, "res://assets/theme/governor_archive.tres")
	print("Theme saved.")
	
	# Helper
	var pack_and_save = func(node: Node, path: String):
		var pack = PackedScene.new()
		pack.pack(node)
		ResourceSaver.save(pack, path)
		node.free()
	
	# 3. Landing Screen
	var landing = Control.new()
	landing.name = "LandingScreen"
	landing.set_script(load("res://src/menus/LandingScreen.gd"))
	landing.theme = theme
	landing.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var landing_bg = ColorRect.new()
	landing_bg.color = Color("F5E6C8")
	landing_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	landing.add_child(landing_bg)
	landing_bg.owner = landing
	
	var landing_center = CenterContainer.new()
	landing_center.name = "CenterContainer"
	landing_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	landing.add_child(landing_center)
	landing_center.owner = landing
	
	var landing_vbox = VBoxContainer.new()
	landing_vbox.name = "VBoxContainer"
	landing_vbox.add_theme_constant_override("separation", 24)
	landing_center.add_child(landing_vbox)
	landing_vbox.owner = landing
	
	var landing_title = Label.new()
	landing_title.text = "Rail Empire"
	landing_title.add_theme_font_override("font", heading_font)
	landing_title.add_theme_font_size_override("font_size", 64)
	landing_title.add_theme_color_override("font_color", Color("1A1A1A"))
	landing_vbox.add_child(landing_title)
	landing_title.owner = landing
	
	var landing_btn = Button.new()
	landing_btn.name = "ContinueButton"
	landing_btn.text = "Click to continue"
	landing_vbox.add_child(landing_btn)
	landing_btn.owner = landing
	
	pack_and_save.call(landing, "res://scenes/menus/landing_screen.tscn")
	
	# 4. Main Menu
	var main_menu = Control.new()
	main_menu.name = "MainMenu"
	main_menu.set_script(load("res://src/menus/MainMenu.gd"))
	main_menu.theme = theme
	main_menu.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var main_bg = ColorRect.new()
	main_bg.color = Color("E8DAB7")
	main_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_menu.add_child(main_bg)
	main_bg.owner = main_menu
	
	var main_margin = MarginContainer.new()
	main_margin.name = "MarginContainer"
	main_margin.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	main_margin.add_theme_constant_override("margin_left", 64)
	main_margin.add_theme_constant_override("margin_top", 64)
	main_margin.add_theme_constant_override("margin_bottom", 64)
	main_menu.add_child(main_margin)
	main_margin.owner = main_menu
	
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "VBoxContainer"
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	main_vbox.add_theme_constant_override("separation", 16)
	main_margin.add_child(main_vbox)
	main_vbox.owner = main_menu
	
	var main_title = Label.new()
	main_title.text = "Rail Empire"
	main_title.add_theme_font_override("font", heading_font)
	main_title.add_theme_font_size_override("font_size", 48)
	main_title.add_theme_color_override("font_color", Color("1A1A1A"))
	main_vbox.add_child(main_title)
	main_title.owner = main_menu
	
	var btn_new = Button.new(); btn_new.name = "NewGameButton"; btn_new.text = "New Game"; main_vbox.add_child(btn_new); btn_new.owner = main_menu
	var btn_load = Button.new(); btn_load.name = "LoadGameButton"; btn_load.text = "Load Game"; btn_load.disabled = true; main_vbox.add_child(btn_load); btn_load.owner = main_menu
	var btn_set = Button.new(); btn_set.name = "SettingsButton"; btn_set.text = "Settings"; main_vbox.add_child(btn_set); btn_set.owner = main_menu
	var btn_cred = Button.new(); btn_cred.name = "CreditsButton"; btn_cred.text = "Credits"; main_vbox.add_child(btn_cred); btn_cred.owner = main_menu
	var btn_quit = Button.new(); btn_quit.name = "QuitButton"; btn_quit.text = "Quit"; main_vbox.add_child(btn_quit); btn_quit.owner = main_menu
	
	pack_and_save.call(main_menu, "res://scenes/menus/main_menu.tscn")
	
	# 5. Prototype Start Menu
	var proto = Control.new()
	proto.name = "PrototypeStartMenu"
	proto.set_script(load("res://src/menus/PrototypeStartMenu.gd"))
	proto.theme = theme
	proto.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var proto_bg = ColorRect.new()
	proto_bg.color = Color("E8DAB7")
	proto_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	proto.add_child(proto_bg)
	proto_bg.owner = proto
	
	var proto_center = CenterContainer.new()
	proto_center.name = "CenterContainer"
	proto_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	proto.add_child(proto_center)
	proto_center.owner = proto
	
	var proto_panel = PanelContainer.new()
	proto_panel.name = "PanelContainer"
	proto_center.add_child(proto_panel)
	proto_panel.owner = proto
	
	var proto_vbox = VBoxContainer.new()
	proto_vbox.name = "VBoxContainer"
	proto_panel.add_child(proto_vbox)
	proto_vbox.owner = proto
	
	var proto_title = Label.new()
	proto_title.text = "Colonial Bengal"
	proto_title.add_theme_font_override("font", heading_font)
	proto_title.add_theme_font_size_override("font_size", 32)
	proto_vbox.add_child(proto_title)
	proto_title.owner = proto
	
	var proto_begin = Button.new(); proto_begin.name = "BeginButton"; proto_begin.text = "Begin Prototype"; proto_vbox.add_child(proto_begin); proto_begin.owner = proto
	var proto_back = Button.new(); proto_back.name = "BackButton"; proto_back.text = "Back"; proto_vbox.add_child(proto_back); proto_back.owner = proto
	
	pack_and_save.call(proto, "res://scenes/menus/prototype_start_menu.tscn")
	
	# 6. Settings Shell
	var settings = Control.new()
	settings.name = "SettingsShell"
	settings.set_script(load("res://src/menus/SettingsShell.gd"))
	settings.theme = theme
	settings.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var set_bg = ColorRect.new()
	set_bg.color = Color("F5E6C8")
	set_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	settings.add_child(set_bg)
	set_bg.owner = settings
	
	var set_margin = MarginContainer.new()
	set_margin.name = "MarginContainer"
	set_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	set_margin.add_theme_constant_override("margin_left", 64)
	set_margin.add_theme_constant_override("margin_top", 64)
	set_margin.add_theme_constant_override("margin_right", 64)
	set_margin.add_theme_constant_override("margin_bottom", 64)
	settings.add_child(set_margin)
	set_margin.owner = settings
	
	var set_vbox = VBoxContainer.new()
	set_vbox.name = "VBoxContainer"
	set_margin.add_child(set_vbox)
	set_vbox.owner = settings
	
	var set_title = Label.new()
	set_title.text = "Settings"
	set_title.add_theme_font_override("font", heading_font)
	set_title.add_theme_font_size_override("font_size", 32)
	set_vbox.add_child(set_title)
	set_title.owner = settings
	
	var tabs = TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	set_vbox.add_child(tabs)
	tabs.owner = settings
	
	var tab_audio = MarginContainer.new(); tab_audio.name = "Audio"; tabs.add_child(tab_audio); tab_audio.owner = settings
	var tab_video = MarginContainer.new(); tab_video.name = "Video"; tabs.add_child(tab_video); tab_video.owner = settings
	var tab_game = MarginContainer.new(); tab_game.name = "Gameplay"; tabs.add_child(tab_game); tab_game.owner = settings
	
	var set_back = Button.new(); set_back.name = "BackButton"; set_back.text = "Back"; set_vbox.add_child(set_back); set_back.owner = settings
	
	pack_and_save.call(settings, "res://scenes/menus/settings_shell.tscn")
	
	# 7. Credits Shell
	var credits = Control.new()
	credits.name = "CreditsShell"
	credits.set_script(load("res://src/menus/CreditsShell.gd"))
	credits.theme = theme
	credits.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var cred_bg = ColorRect.new()
	cred_bg.color = Color("F5E6C8")
	cred_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	credits.add_child(cred_bg)
	cred_bg.owner = credits
	
	var cred_margin = MarginContainer.new()
	cred_margin.name = "MarginContainer"
	cred_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	cred_margin.add_theme_constant_override("margin_left", 64)
	cred_margin.add_theme_constant_override("margin_top", 64)
	cred_margin.add_theme_constant_override("margin_right", 64)
	cred_margin.add_theme_constant_override("margin_bottom", 64)
	credits.add_child(cred_margin)
	cred_margin.owner = credits
	
	var cred_vbox = VBoxContainer.new()
	cred_vbox.name = "VBoxContainer"
	cred_margin.add_child(cred_vbox)
	cred_vbox.owner = credits
	
	var cred_title = Label.new()
	cred_title.text = "Rail Empire Team"
	cred_title.add_theme_font_override("font", heading_font)
	cred_title.add_theme_font_size_override("font_size", 32)
	cred_vbox.add_child(cred_title)
	cred_title.owner = credits
	
	var cred_panel = PanelContainer.new()
	cred_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	cred_vbox.add_child(cred_panel)
	cred_panel.owner = credits
	
	var cred_text = RichTextLabel.new()
	cred_text.text = "Created by...\nMusic by...\nArt by..."
	cred_text.add_theme_color_override("default_color", Color("1A1A1A"))
	cred_panel.add_child(cred_text)
	cred_text.owner = credits
	
	var cred_back = Button.new(); cred_back.name = "BackButton"; cred_back.text = "Back"; cred_vbox.add_child(cred_back); cred_back.owner = credits
	
	pack_and_save.call(credits, "res://scenes/menus/credits_shell.tscn")
	
	# 8. Theme Preview
	var preview = Control.new()
	preview.name = "ThemePreview"
	preview.theme = theme
	preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var prev_bg = ColorRect.new()
	prev_bg.color = Color("F5E6C8")
	prev_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview.add_child(prev_bg)
	prev_bg.owner = preview
	
	var prev_center = CenterContainer.new()
	prev_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview.add_child(prev_center)
	prev_center.owner = preview
	
	var prev_panel = PanelContainer.new()
	prev_center.add_child(prev_panel)
	prev_panel.owner = preview
	
	var prev_vbox = VBoxContainer.new()
	prev_panel.add_child(prev_vbox)
	prev_vbox.owner = preview
	
	var prev_lbl1 = Label.new(); prev_lbl1.text = "Heading Example"; prev_lbl1.add_theme_font_override("font", heading_font); prev_lbl1.add_theme_font_size_override("font_size", 24); prev_vbox.add_child(prev_lbl1); prev_lbl1.owner = preview
	var prev_lbl2 = Label.new(); prev_lbl2.text = "Body text example."; prev_vbox.add_child(prev_lbl2); prev_lbl2.owner = preview
	var prev_btn1 = Button.new(); prev_btn1.text = "Normal Button"; prev_vbox.add_child(prev_btn1); prev_btn1.owner = preview
	var prev_btn2 = Button.new(); prev_btn2.text = "Disabled Button"; prev_btn2.disabled = true; prev_vbox.add_child(prev_btn2); prev_btn2.owner = preview
	
	pack_and_save.call(preview, "res://scenes/debug/theme_preview.tscn")
	
	print("Done building UI scenes!")
	quit()
