extends Node


const ITEM_LIST = {
	"money": { "name": "money", "char": "$", "interact": false, "value": 1, "equip": null,  },
	"stair": { "name": "staircase", "char": ">", "interact": true },
	"sword": { "name": "sword", "char": "T", "interact": false, "value": 2, "equip": "weapon", "effect": {"attack": 2} },
	"knife": { "name": "knife", "char": "I", "interact": false, "value": 1, "equip": "weapon", "effect": {"attack": 1} },
}


const ENEMY_LIST = {
	"zombie": { "name": "zamble", "char": "Z", "hp": 3, "attack": 1, "move_delay": 1, "notice_range": 8}
}


const CHARACTER_LIST = {
	"default": { "name": "nameless", "hp": 15, "attack": 2}
}
