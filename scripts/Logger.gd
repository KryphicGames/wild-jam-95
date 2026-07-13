extends Node

@export var messageFormat: String = "[%02d:%02d:%02d.%03d] [%s] %s: %s"

func Info(text: String, title: String = "Logger"):
	var time = Time.get_time_dict_from_system()
	var message = messageFormat % [
		time.hour,
		time.minute,
		time.second,
		Time.get_ticks_msec() % 1000,
		title,
		"INFO",
		text
	]
	print(message)

func Debug(text: String, title: String = "Logger"):
	var time = Time.get_time_dict_from_system()
	var message = messageFormat % [
		time.hour,
		time.minute,
		time.second,
		Time.get_ticks_msec() % 1000,
		title,
		"DEBUG",
		text
	]
	print(message)

func Warn(text: String, title: String = "Logger"):
	var time = Time.get_time_dict_from_system()
	var message = messageFormat % [
		time.hour,
		time.minute,
		time.second,
		Time.get_ticks_msec() % 1000,
		title,
		"WARN",
		text
	]
	print(message)
	push_warning(message)

func Error(text: String, title: String = "Logger"):
	var time = Time.get_time_dict_from_system()
	var message = messageFormat % [
		time.hour,
		time.minute,
		time.second,
		Time.get_ticks_msec() % 1000,
		title,
		"ERROR",
		text
	]
	print(message)
	push_error(message)
