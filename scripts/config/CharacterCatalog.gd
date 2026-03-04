extends RefCounted
class_name CharacterCatalog

const CHARACTER_OPTIONS := [
	{
		"id": "elon_mvsk",
		"name": "Elon Mvsk",
		"attack_table_path": "res://assets/data/characters/ElonMvskAttackTable.tres"
	},
	{
		"id": "mark_zuck",
		"name": "Mark Zuck",
		"attack_table_path": "res://assets/data/characters/MarkZuckAttackTable.tres"
	},
	{
		"id": "sam_altmyn",
		"name": "Sam Altmyn",
		"attack_table_path": "res://assets/data/characters/SamAltmynAttackTable.tres"
	},
	{
		"id": "peter_thyell",
		"name": "Peter Thyell",
		"attack_table_path": "res://assets/data/characters/PeterThyellAttackTable.tres"
	},
	{
		"id": "zef_bezos",
		"name": "Zef Bezos",
		"attack_table_path": "res://assets/data/characters/ZefBezosAttackTable.tres"
	},
	{
		"id": "bill_geytz",
		"name": "Bill Geytz",
		"attack_table_path": "res://assets/data/characters/BillGeytzAttackTable.tres"
	},
	{
		"id": "sundar_pichoy",
		"name": "Sundar Pichoy",
		"attack_table_path": "res://assets/data/characters/SundarPichoyAttackTable.tres"
	},
	{
		"id": "jensen_hwang",
		"name": "Jensen Hwang",
		"attack_table_path": "res://assets/data/characters/JensenHwangAttackTable.tres"
	},
	{
		"id": "larry_pagyr",
		"name": "Larry Pagyr",
		"attack_table_path": "res://assets/data/characters/LarryPagyrAttackTable.tres"
	},
	{
		"id": "sergey_brinn",
		"name": "Sergey Brinn",
		"attack_table_path": "res://assets/data/characters/SergeyBrinnAttackTable.tres"
	},
	{
		"id": "satya_nadello",
		"name": "Satya Nadello",
		"attack_table_path": "res://assets/data/characters/SatyaNadelloAttackTable.tres"
	},
	{
		"id": "tim_cuke",
		"name": "Tim Cuke",
		"attack_table_path": "res://assets/data/characters/TimCukeAttackTable.tres"
	},
	{
		"id": "jack_dorsee",
		"name": "Jack Dorsee",
		"attack_table_path": "res://assets/data/characters/JackDorseeAttackTable.tres"
	},
	{
		"id": "travis_kalanik",
		"name": "Travis Kalanik",
		"attack_table_path": "res://assets/data/characters/TravisKalanikAttackTable.tres"
	},
	{
		"id": "reed_hestings",
		"name": "Reed Hestings",
		"attack_table_path": "res://assets/data/characters/ReedHestingsAttackTable.tres"
	},
	{
		"id": "steve_jobz",
		"name": "Steve Jobz",
		"attack_table_path": "res://assets/data/characters/SteveJobzAttackTable.tres"
	}
]

const STORY_OPPONENT_IDS := [
	"mark_zuck",
	"sam_altmyn",
	"peter_thyell",
	"zef_bezos",
	"bill_geytz",
	"sundar_pichoy",
	"jensen_hwang",
	"larry_pagyr",
	"sergey_brinn",
	"satya_nadello",
	"tim_cuke",
	"jack_dorsee",
	"travis_kalanik",
	"reed_hestings",
	"steve_jobz"
]

static func get_selectable_roster() -> Array[Dictionary]:
	var roster: Array[Dictionary] = []
	for entry in CHARACTER_OPTIONS:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		roster.append((entry as Dictionary).duplicate(true))
	return roster

static func get_story_opponent_pool() -> Array[Dictionary]:
	var by_id := {}
	for entry in CHARACTER_OPTIONS:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var item := entry as Dictionary
		var character_id := str(item.get("id", ""))
		if character_id == "":
			continue
		by_id[character_id] = item

	var roster: Array[Dictionary] = []
	for character_id in STORY_OPPONENT_IDS:
		var item: Variant = by_id.get(character_id, null)
		if typeof(item) != TYPE_DICTIONARY:
			continue
		roster.append((item as Dictionary).duplicate(true))
	return roster
