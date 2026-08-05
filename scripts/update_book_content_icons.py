import json

with open("game/prose-quest/assets/data/book_content.json", "r", encoding="utf-8") as f:
    data = json.load(f)

part_icon_map = {
    1: "res://assets/images/map_icons/part_01_campsite.png",
    2: "res://assets/images/map_icons/part_02_woodcutter_hut.png",
    3: "res://assets/images/map_icons/part_03_hamlet.png",
    4: "res://assets/images/map_icons/part_04_trading_post.png",
    5: "res://assets/images/map_icons/part_05_fortified_village.png",
    6: "res://assets/images/map_icons/part_06_stone_keep.png",
    7: "res://assets/images/map_icons/part_07_grand_library_town.png",
    8: "res://assets/images/map_icons/part_08_walled_city.png",
    9: "res://assets/images/map_icons/part_09_crystal_citadel.png",
    10: "res://assets/images/map_icons/part_10_imperial_metropolis.png",
}

chap_icon_map = {
    1: "res://assets/images/map_icons/ch_01_kindling.png",
    2: "res://assets/images/map_icons/ch_02_flint_steel.png",
    3: "res://assets/images/map_icons/ch_03_wood_shavings.png",
    4: "res://assets/images/map_icons/ch_04_timber_axe.png",
    5: "res://assets/images/map_icons/ch_05_firewood_stack.png",
    6: "res://assets/images/map_icons/ch_06_sawmill_blade.png",
    7: "res://assets/images/map_icons/ch_07_stone_well.png",
    8: "res://assets/images/map_icons/ch_08_roof_shears.png",
    9: "res://assets/images/map_icons/ch_09_hearth_smoker.png",
    10: "res://assets/images/map_icons/ch_10_village_signpost.png",
    11: "res://assets/images/map_icons/ch_11_tavern_tankard.png",
    12: "res://assets/images/map_icons/ch_12_merchant_scale.png",
    13: "res://assets/images/map_icons/ch_13_trade_contract.png",
    14: "res://assets/images/map_icons/ch_14_mounted_shields.png",
    15: "res://assets/images/map_icons/ch_15_travel_sack.png",
    16: "res://assets/images/map_icons/ch_16_palisade_spike.png",
    17: "res://assets/images/map_icons/ch_17_watchtower_horn.png",
    18: "res://assets/images/map_icons/ch_18_keep_keyring.png",
    19: "res://assets/images/map_icons/ch_19_knight_helmet.png",
    20: "res://assets/images/map_icons/ch_20_banner_crest.png",
    21: "res://assets/images/map_icons/ch_21_leather_codex.png",
    22: "res://assets/images/map_icons/ch_22_astrolabe_map.png",
    23: "res://assets/images/map_icons/ch_23_city_archway.png",
    24: "res://assets/images/map_icons/ch_24_plaza_fountain.png",
    25: "res://assets/images/map_icons/ch_25_blueprint_scroll.png",
    26: "res://assets/images/map_icons/ch_26_clocktower_gear.png",
    27: "res://assets/images/map_icons/ch_27_mana_crystal.png",
    28: "res://assets/images/map_icons/ch_28_scrying_orb.png",
    29: "res://assets/images/map_icons/ch_29_alchemist_flask.png",
    30: "res://assets/images/map_icons/ch_30_golem_core.png",
    31: "res://assets/images/map_icons/ch_31_leyline_conduit.png",
    32: "res://assets/images/map_icons/ch_32_royal_seal.png",
    33: "res://assets/images/map_icons/ch_33_typeblock_press.png",
    34: "res://assets/images/map_icons/ch_34_imperial_crown.png",
    35: "res://assets/images/map_icons/ch_35_triumph_arch.png",
}

for part in data.get("parts", []):
    num = part.get("number", 1)
    if num in part_icon_map:
        part["map_icon"] = part_icon_map[num]

for chap in data.get("chapters", []):
    num = chap.get("number", 1)
    if num in chap_icon_map:
        chap["map_icon"] = chap_icon_map[num]

with open("game/prose-quest/assets/data/book_content.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)

print("Successfully updated book_content.json with all 45 map icons!")
