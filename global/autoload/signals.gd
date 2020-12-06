extends Node

signal initialize(size)
signal board_generation_requested(name)

signal field_pressed(position)
signal board_changed()

signal action_changed(name)
signal action_triggered(name)
signal action_succeeded(ap) # Consider changing argument to more general information e.g. full character dict

signal queue_shuffle_requested()
signal queue_clear_requested()
signal turn_passed()
signal current_entity_changed(index)

signal entity_added(index)
signal entity_moved(index, destination)

signal targeting_called(action)
signal targets_changed(targets) # Argument currently holding array with same format as systems/board.flood_fill
signal targets_display_changed(targets)
