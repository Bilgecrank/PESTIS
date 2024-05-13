/*
 * Author: Bilgecrank
 * 
 * Instantiate player loadouts, and set the event handler to save the variable locally.
 *
 * Dependencies: ace;
 *
 * Returns: True.
 *
 */

private ["_loadout, _earPlugs"];
localNamespace setVariable ["PESTIS_playerActive", true];

// Ensure player is not a logic entity.
if !((typeOf player) regexMatch ".*virtual.*") then {
	diag_log text format ["PESTIS: Loading gear for %1", name player];
	_loadout = missionProfileNamespace getVariable "PESTIS_loadout";
	_earPlugs = missionProfileNamespace getVariable "PESTIS_earplugs";
	
	if !(isNil "_loadout") then {
		// If player has a set loadout, set it.
		player setUnitLoadout [_loadout, true];
	} else {
		// For backwards compatability.
		private _transferredLoadout = missionProfileNamespace getVariable "pestisLoadout";
		if !(isNil "_transferredLoadout") then {
			player setUnitLoadout [_transferredLoadout, true];
		};
	};
	
	if !(isNil "_earPlugs") then {
		// Based on ace_hearing_fnc_putInEarplugs, sets earplugs and updates the settings as needed.
		player setVariable ["ACE_hasEarPlugsIn", _earPlugs, true];
		[[true]] call ace_hearing_fnc_updateVolume;
		[] call ace_hearing_fnc_updateHearingProtection;
	};
	
	// Ensure player is loaded in to set event handler
	waitUntil { !isNull findDisplay 46 };
	
	//Assign EH to turn off auto-saving and do a final save of the player's loadout.
	
	findDisplay 46 displayAddEventHandler [
		"Unload",
		{
		localNamespace setVariable ["PESTIS_playerActive", false];
		missionProfileNamespace setVariable ["PESTIS_loadout", getUnitLoadout [player, true]];
		missionProfileNamespace setVariable ["PESTIS_earplugs", player getVariable ["ACE_hasEarPlugsIn", false]];
		saveMissionProfileNamespace;
	}];
	
	// Start autosave.
	[] spawn {
		while {sleep 300; localNamespace getVariable "PESTIS_playerActive"} do {
			missionProfileNamespace setVariable ["PESTIS_loadout", getUnitLoadout [player, true]];
			missionProfileNamespace setVariable ["PESTIS_earplugs", player getVariable ["ACE_hasEarPlugsIn", false]];
			saveMissionProfileNamespace;
		};
	};
	
};
true; //Return