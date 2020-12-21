extends Node

# Board generation
signal initialize(size)
signal board_generation_requested(name)

# Basic
signal field_pressed(position)
signal board_changed()

# Action related
signal action_changed(name)
signal action_triggered()
signal action_succeeded() # temporary variables after action was performed

# Turn management
signal queue_shuffle_requested()
signal queue_clear_requested()
signal turn_passed()
signal current_entity_changed(index)

# Board related entity actions
signal entity_added(index)
signal entity_moved(index, destination)
signal entity_removed(index)

# Targeting
signal targeting_called(action)
signal targets_changed(targets) # Argument currently holding array with same format as systems/board.flood_fill
signal targets_display_changed(targets)

# Damage system
signal attack_requested(target, damage, pierce)
signal regeneration_requested(target, regeneration)
