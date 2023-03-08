extends Node


const ITEM_LIST = {
	"money": { "name": "money", "char": "$", "value": 1, "equip": false, "interact": false },
	"stair": { "name": "staircase", "char": ">", "interact": true },
	"sword": { "name": "sword", "char": "T", "value": 2, "equip": true, "interact": false }
}


const ENEMY_LIST = {
	"zombie": { "name": "zamble", "char": "Z", "hp": 3, "attack": 1, "move_delay": 1, "notice_range": 8}
}


const CHARACTER_LIST = {
	"default": { "name": "nameless", "hp": 15, "attack": 2}
}
