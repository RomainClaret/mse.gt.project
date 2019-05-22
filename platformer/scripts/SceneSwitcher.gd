extends Node

var _params = null


func change_scene(next_scene, params=null):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_params = params
	get_tree().change_scene(next_scene)


func get_param(name):
    if _params != null and _params.has(name):
        return _params[name]
    return null