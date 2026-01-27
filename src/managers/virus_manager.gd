class_name VirusManager
extends Node

########################
### CONFIG / EXPORTS ###
########################

@export var virus_scene: PackedScene

## base caps (wave 0)
@export var base_max_health := 3
@export var base_max_speed := 0.15
@export var base_spawn_interval := 1.2

## per-wave scaling
@export var health_per_wave := 1
@export var speed_per_wave := 0.04
@export var spawn_interval_decay := 0.05
@export var min_spawn_interval := 0.25

## base event chances (per second, normalized later per frame)
@export var popup_chance := 0.01
@export var scramble_chance := 0.005
@export var backdoor_chance := 0.003
@export var bruteforce_chance := 0.002

## per-wave chance scaling
@export var event_chance_per_wave := 0.005

## username used in terminal messages
@export var terminal_username := "usr/M.A.L"


######################
### INTERNAL STATE ###
######################

var _rng := RandomNumberGenerator.new()
var _current_wave := 0
var _spawning := false
var _bruteforce_active := false
var _bruteforce_idx := -1
var _paths: Array[Path2D] = []


##############
### TIMERS ###
##############

@onready var spawn_timer := Timer.new()
@onready var popup_timer := Timer.new()
@onready var scramble_timer := Timer.new()
@onready var backdoor_timer := Timer.new()
@onready var bruteforce_timer := Timer.new()


#################
### LIFECYCLE ###
#################

func _ready() -> void:
	_rng.randomize()

	_setup_timer(spawn_timer, true)
	_setup_timer(popup_timer)
	_setup_timer(scramble_timer)
	_setup_timer(backdoor_timer)
	backdoor_timer.wait_time = 10
	_setup_timer(bruteforce_timer)

	add_child(spawn_timer)
	add_child(popup_timer)
	add_child(scramble_timer)
	add_child(backdoor_timer)
	add_child(bruteforce_timer)

	spawn_timer.timeout.connect(_spawn_virus)
	bruteforce_timer.timeout.connect(_end_bruteforce)


func _process(delta: float) -> void:
	if !_spawning:
		return

	_process_events(delta)


########################
### PUBLIC INTERFACE ###
########################

func start_wave(wave_idx: int) -> void:
	_current_wave = wave_idx
	_spawning = true

	var interval : float = max(
		min_spawn_interval,
		base_spawn_interval - (spawn_interval_decay * wave_idx)
	)

	spawn_timer.wait_time = interval
	spawn_timer.start()


func end_wave() -> void:
	_spawning = false
	spawn_timer.stop()


######################
### SPAWNING LOGIC ###
######################

func _spawn_virus() -> void:
	if virus_scene == null || GameManager.current_state != GameManager.GAME_STATE.ACTIVE:
		return

	var virus := virus_scene.instantiate() as Virus
	
	var path_idx = -1
	if _bruteforce_active:
		path_idx = _bruteforce_idx
	
	GameManager.game_board.add_virus_to_path(virus, path_idx)

	var max_health := base_max_health + (_current_wave * health_per_wave)
	var max_speed := base_max_speed + (_current_wave * speed_per_wave)

	virus.max_health = _rng.randi_range(1, max_health)
	virus.health = virus.max_health
	virus.speed = _rng.randf_range(0.05, max_speed)
	virus.tier = max_health - base_max_health - 1

	# stagger next spawn dynamically
	spawn_timer.start()


####################
### EVENT SYSTEM ###
####################

func _process_events(delta: float) -> void:
	var wave_bonus := _current_wave * event_chance_per_wave

	_try_event(popup_timer, popup_chance + wave_bonus, _spawn_popup, delta)
	_try_event(scramble_timer, scramble_chance + wave_bonus, _scramble_board, delta)
	_try_event(backdoor_timer, backdoor_chance + wave_bonus, _create_backdoor, delta)
	_try_event(bruteforce_timer, bruteforce_chance + wave_bonus, _start_bruteforce, delta)


func _try_event(timer: Timer, chance: float, action: Callable, delta: float) -> void:
	if !timer.is_stopped() || GameManager.current_state != GameManager.GAME_STATE.ACTIVE:
		return

	# convert per-second probability into per-frame
	if _rng.randf() < chance * delta:
		action.call()
		timer.start()


#####################
### EVENT ACTIONS ###
#####################

func _spawn_popup() -> void:
	# hook for UI / terminal
	GameManager.spawn_popup()


func _scramble_board() -> void:
	GameManager.scramble_board()


func _create_backdoor() -> void:
	print("BACKDOOR CREATED")
	
	var path: GamePath = GameManager.game_board.get_virus_path([0, 1, 4, 5].pick_random())
	if not GameManager.game_board.invalid_paths.has(path) and path.is_node_ready():
		path.create_backdoor()

	GameManager.send_terminal_message("backdoor")
	# TODO add visuals


func _start_bruteforce() -> void:
	_bruteforce_active = true
	bruteforce_timer.wait_time = 10
	bruteforce_timer.start()
	_bruteforce_idx = randi_range(0, 5)
	GameManager.game_board.toggle_brute_for_path(true, _bruteforce_idx)
	GameManager.send_terminal_message("brute force")
	#TODO add visuals (remove message for end once this is done)


func _end_bruteforce() -> void:
	_bruteforce_active = false
	GameManager.game_board.toggle_brute_for_path(false, _bruteforce_idx)
	GameManager.terminal.push_new_message("bruteforce over")


############
### UTIL ###
############

func _setup_timer(timer: Timer, autostart := false) -> void:
	timer.one_shot = true
	timer.autostart = autostart
	timer.wait_time = 5.0
