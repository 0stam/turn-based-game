extends Node


signal initialize(size)
signal board_generation_requested(name)

signal field_pressed(position)
signal board_changed()

signal action_changed(name)
signal entity_added(position)
signal queue_shuffle_requested()
signal queue_clear_requested()
