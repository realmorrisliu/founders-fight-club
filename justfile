set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

# Start the game using run/main_scene from project.godot.
run:
	@./scripts/godot.sh run

# Open the Godot editor for this project.
editor:
	@./scripts/godot.sh editor

# Run a specific scene, e.g.:
# just run-scene "res://scenes/Main.tscn"
run-scene scene:
	@./scripts/godot.sh run-scene "{{scene}}"

# Run automated headless tests (default: smoke suite).
test suite="smoke":
	@./scripts/test.sh "{{suite}}"
