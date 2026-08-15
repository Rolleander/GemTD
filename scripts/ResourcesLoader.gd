extends Node

class_name ResourcesLoader


func load_resources_from_folder(array: Array, folder_path: String) -> void:
	var files := ResourceLoader.list_directory(folder_path)

	for file_name in files:
		if not file_name.ends_with(".tres"):
			continue

		var file_path := folder_path.path_join(file_name)

		if not ResourceLoader.exists(file_path):
			push_error("Resource does not exist: " + file_path)
			continue

		var resource := ResourceLoader.load(file_path)

		if resource == null:
			push_error("Failed to load resource: " + file_path)
			continue

		array.append(resource)
