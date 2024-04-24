#include "..\script_component.hpp"
/*
 * Author: Blue
 * Administer defibrillator shock
 *
 * Arguments:
 * 0: Medic <OBJECT>
 * 1: Patient <OBJECT>
 * 2: Is in manual mode <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, cursorTarget, false] call ACM_circulation_fnc_AED_AdministerShock;
 *
 * Public: No
 */

params ["_medic", "_patient", ["_manual", false]];

//playSound3D [QPATHTO_R(sound\aed_shock.wav), _patient, false, getPosASL _patient, 15, 1, 15]; // 0.1s

_patient setVariable [QGVAR(AED_Charged), false, true];
_patient setVariable [QGVAR(AED_InUse), false, true];
_medic setVariable [QGVAR(AED_Medic_InUse), false, true];

_patient setVariable [QGVAR(AED_LastShock), CBA_missionTime, true];

private _totalShocks = _patient getVariable [QGVAR(AED_ShockTotal), 0];
_patient setVariable [QGVAR(AED_ShockTotal), (_totalShocks + 1), true];

if !(_manual) then {
    [{ // Reminder to start CPR
        params ["_patient", "_medic"];

        [_patient] call FUNC(AED_TrackCPR);
        playSound3D [QPATHTO_R(sound\aed_startcpr.wav), _patient, false, getPosASL _patient, 15, 1, 15]; // 1.858s

    }, [_patient, _medic], 2] call CBA_fnc_waitAndExecute;
};

if (_patient getVariable [QGVAR(CardiacArrest_RhythmState), 0] in [1,5]) exitWith {
    _patient setVariable [QGVAR(CardiacArrest_RhythmState), 1, true];
};

private _amiodarone = ([_patient] call FUNC(getCardiacMedicationEffects)) get "amiodarone";

private _CPREffectiveness = 0;

private _CPRAmount = _patient getVariable [QGVAR(CPR_StoppedTotal), 0];
if (_CPRAmount > 0) then {
    _CPREffectiveness = linearConversion [60, 120, _CPRAmount, 0, 10, false] max 0;
};

if (random 100 < (_CPREffectiveness + (10 + (10 * _amiodarone)))) exitWith { // ROSC
    [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
    _patient setVariable [QGVAR(CardiacArrest_RhythmState), 0];
};