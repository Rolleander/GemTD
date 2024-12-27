# ResourceLoader.gd
extends Node

class_name ResourcesLoader

func load_resources_from_folder(array: Array, folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir == null:
		print("Failed to open directory: " + folder_path)
		return
	var files = dir.get_files()
	for file_name in files:
		if file_name.ends_with(".tres"):
			var file_path = folder_path + "/" + file_name
			var resource = load(file_path)
			array.append(resource)
	return
