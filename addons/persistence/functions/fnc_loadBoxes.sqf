/*
 * Author: Bilgecrank
 * 
 * Sorts and inserts items into different boxes based on item types or name.
 *
 * Params:
 * 0: A weapons and inventory array from PESTIS_fnc_boxToArray. <ARRAY>
 *
 * Returns: True
 *
 */
diag_log text "PESTIS: Sorting and loading boxes.";
 
params ["_inventory", ["_specialInventory", [[],[]]], ["_emptyVehicles", true]];

// Grab the upward limit for items in a mission.
private _countLimit = missionNamespace getVariable "PESTIS_limitInventoryCount";

// The array of containers used in the mission.
private _missionBoxes = [	gunCrate,			//0
							bulletCrate, 		//1
							launcherCrate, 		//2
							missileCrate, 		//3
							bombCrate, 			//4
							grenadeCrate,		//5
							uniformCrate, 		//6
							itemCrate, 			//7
							medicalCrate,		//8
							attachmentCrate,	//9
							radioCrate,			//10
							specialCrate		//11
							];

// Add vehicles to the missionBoxes variable.
if (_emptyVehicles) then {
	_missionBoxes append [	seahawk,			//12
							mrzr1,				//13
							mrzr2,				//14
							rhib1,				//15
							rhib2				//16
							];
};

// All ace medical objects.
private _aceMedical = ["ACE_fieldDressing", "ACE_packingBandage", "ACE_elasticBandage", "ACE_quikclot", "ACE_tourniquet",
					   "ACE_splint", "ACE_morphine", "ACE_adenosine", "ACE_atropine", "ACE_epinephrine",
					   "ACE_plasmaIV", "ACE_plasmaIV_500", "ACE_plasmaIV_250", "ACE_bloodIV", "ACE_bloodIV_500",
					   "ACE_bloodIV_250", "ACE_salineIV", "ACE_salineIV_500", "ACE_salineIV_250", "ACE_personalAidKit",
					   "ACE_surgicalKit", "ACE_suture", "ACE_bodyBag"];

//Initialize all the boxes to receive stored items.
{
	clearItemCargoGlobal _x;
	clearWeaponCargoGlobal _x;
	clearBackpackCargoGlobal _x;
	clearMagazineCargoGlobal _x;
	_x setMaxLoad 100000;
} forEach _missionBoxes;

// Handle special weapons crate.
{
	_x params ["_weapon", "_muzzle", "_flashlight", "_optic", 
			   "_primaryMag", "_secondaryMag", "_bipod"];
	[ _weapon ] call BIS_fnc_itemType params[ "_type", "_subType" ];
	if (_type == "WEAPON") then {
		specialCrate addWeaponWithAttachmentsCargoGlobal [_x, 1];
	} else {
		(_specialInventory select 1) pushback [_weapon, 1]; //Put binoculars in the in the item side.
	};
} forEach (_specialInventory select 0);

// Add all non-weapon items to the inventory stack.
(_inventory select 1) append (_specialInventory select 1);

// Handle weapons variable
{
	_x params ["_weapon", "_muzzle", "_flashlight", "_optic", 
			   "_primaryMag", "_secondaryMag", "_bipod"];
	private "_crateToStore";
	[ _weapon ] call BIS_fnc_itemType params[ "_type", "_subType" ];
	if (_type == "WEAPON") then {
		if (toUpper _subType == "GRENADELAUNCHER" ||
			toUpper _subType ==	"LAUNCHER" ||
			toUpper _subType == "MISSILELAUNCHER" ||
			toUpper _subType ==	"ROCKETLAUNCHER") then {
			_crateToStore = launcherCrate;
			} else {
			_crateToStore = gunCrate;
			};
	} else {
		_crateToStore = itemCrate; //Non-weapon weapon item(binoculars), goes into the itemCrate.
	};
	_crateToStore addWeaponWithAttachmentsCargoGlobal [_x, 1];
} forEach (_inventory select 0);

// Handle inventory variable.
{
	_x params ["_item", "_count"];
	private "_crateToStore";
	[ _item ] call BIS_fnc_itemType params[ "_type", "_subType" ];
	if (toUpper _subType == "BACKPACK") then {
		// Handle backpacks
		if (_item regexMatch "tfar.*") then {
			// Redirect TFAR radio backpacks to radio crate.
			_crateToStore = radioCrate;
		} else {
			// Normal backpacks go to the uniformCrate.
			_crateToStore = uniformCrate; 
		};
		_crateToStore addBackpackCargoGlobal _x;;
	} else {
		switch (toUpper _type) do {
			case "ITEM" : {
				// Handle ACE objects.
				if (_item regexMatch "ace.*") then {
					if (_item in _aceMedical) then {
						// Is a medical objects.
						_crateToStore = medicalCrate;
					} else {
						// Is a normal ACE item.
						_crateToStore = itemCrate;
					};
				} else {
					switch (toUpper _subType) do {
						case "ACCESSORYMUZZLE" : {
							_crateToStore = attachmentCrate;
						};
						case "ACCESSORYPOINTER" : {
							_crateToStore = attachmentCrate;
						};
						case "ACCESSORYSIGHTS" : {
							_crateToStore = attachmentCrate;
						};
						case "ACCESSORYBIPOD" : {
							_crateToStore = attachmentCrate;
						};
						case "RADIO" : {
							_crateToStore = radioCrate;
						};
						case "FIRSTAIDKIT" : {
							_crateToStore = medicalCrate;
						};
						case "MEDIKIT" : {
							_crateToStore = medicalCrate;
						};
						default {
							_crateToStore = itemCrate;
						};
					};
				};
			};
			case "EQUIPMENT" : {
				_crateToStore = uniformCrate;
			};
			case "MAGAZINE" : {
				switch (toUpper _subType) do {
					case "GRENADE" : {
						_crateToStore = grenadeCrate;
					};
					case "FLARE" : {
						_crateToStore = grenadeCrate;
					};
					case "SHELL" : {
						_crateToStore = grenadeCrate;
					};
					case "SHOTGUNSHELL" : {
						_crateToStore = grenadeCrate;
					};
					case "SMOKESHELL" : {
						_crateToStore = grenadeCrate;
					};
					case "ROCKET" : {
						_crateToStore = missileCrate;
					};
					case "MISSILE" : {
						_crateToStore = missileCrate;
					};
					case "UNKNOWNMAGAZINE" : {
						if (_item regexMatch ".*grenade.*") then {
							_crateToStore = grenadeCrate;
						} else {
							_crateToStore = itemCrate;
						};
					};
					default {
						_crateToStore = bulletCrate;
					};
				};
			};
			case "MINE" : {
				_crateToStore = bombCrate;
			};
			default {
				_crateToStore = itemCrate;
			};
		};
		if (!isNil "_countLimit" && {_count > _countLimit}) then {
			_count = _countLimit;
		};
		_crateToStore addItemCargoGlobal [_item, _count];
	};
} forEach (_inventory select 1);
true;