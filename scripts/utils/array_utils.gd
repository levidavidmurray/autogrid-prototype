class_name ArrayUtils

static func create_2d_array(size: Vector2i, default_value: Variant = null) -> Array:
	var array = []
	array.resize(size.y)
	for y in range(size.y):
		array[y] = []
		array[y].resize(size.x)
		for x in range(size.x):
			array[y][x] = default_value
	return array


static func for_2d_array(arr: Array, cb: Callable) -> void:
	var i = 0
	for y in range(arr.size()):
		for x in range(arr[y].size()):
			if cb.get_argument_count() == 1:
				cb.call(arr[y][x])
			elif cb.get_argument_count() == 2:
				cb.call(x, y)
			elif cb.get_argument_count() == 3:
				cb.call(x, y, i)
			else:
				printerr("[ArrayUtils::for_2d_array] Invalid number of arguments passed: %s" % cb.get_argument_count())
			i += 1


static func is_valid_2d_array(arr: Array) -> bool:
	if arr.size() == 0:
		return false
	if arr[0].size() == 0:
		return false
	return true


static func flatten_2d_array(arr: Array) -> Array:
	var flat = []
	if not is_valid_2d_array(arr):
		return flat
	var size = arr[0].size() * arr.size()
	flat.resize(size)
	var i = 0
	for y in range(arr.size()):
		for x in range(arr[y].size()):
			flat[i] = arr[y][x]
			i += 1
	return flat
