#include "..\script_component.hpp"
/*
 * Author: Glowbal
 * Local callback for fully healing a patient.
 *
 * Arguments:
 * 0: Patient <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_medical_treatment_fnc_fullHealLocal
 *
 * Public: No
 */

params ["_patient"];
TRACE_1("fullHealLocal",_patient);

if (!alive _patient) exitWith {};

// check if on fire, then put out the fire before healing
if ((["ace_fire"] call ACEFUNC(common,isModLoaded)) && {[_patient] call ACEFUNC(fire,isBurning)}) then {
    _patient setVariable [QACEGVAR(fire,intensity), 0, true];
};

private _state = GET_SM_STATE(_patient);
TRACE_1("start",_state);

// Treatment conditions would normally limit full heal to non-unconscious units
// However, this may be called externally (through Zeus)
if IN_CRDC_ARRST(_patient) then {
    TRACE_1("Exiting cardiac arrest",_patient);
    [QACEGVAR(medical,CPRSucceeded), _patient] call CBA_fnc_localEvent;
    _state = GET_SM_STATE(_patient);
    TRACE_1("after CPRSucceeded",_state);
};

// AMS Stuff
[_patient] call EFUNC(airway,resetVariables);
[_patient] call EFUNC(breathing,resetVariables);
[_patient] call EFUNC(circulation,resetVariables);

_patient setVariable [VAR_PAIN, 0, true];
_patient setVariable [VAR_BLOOD_VOL, DEFAULT_BLOOD_VOLUME, true];

// Tourniquets
{
    if (_x != 0) then {
        [_patient, "ACE_tourniquet"] call ACEFUNC(common,addToInventory);
    };
} forEach GET_TOURNIQUETS(_patient);
_patient setVariable [VAR_TOURNIQUET, DEFAULT_TOURNIQUET_VALUES, true];
_patient setVariable [QACEGVAR(medical_treatment,occludedMedications), nil, true];

// Wounds and Injuries
_patient setVariable [VAR_OPEN_WOUNDS, createHashMap, true];
_patient setVariable [VAR_BANDAGED_WOUNDS, createHashMap, true];
_patient setVariable [VAR_STITCHED_WOUNDS, createHashMap, true];
_patient setVariable [QACEGVAR(medical,isLimping), false, true];
_patient setVariable [VAR_FRACTURES, DEFAULT_FRACTURE_VALUES, true];

// Update wound bleeding
[_patient] call ACEFUNC(medical_status,updateWoundBloodLoss);

// Vitals
_patient setVariable [VAR_HEART_RATE, DEFAULT_HEART_RATE, true];
_patient setVariable [VAR_BLOOD_PRESS, [80, 120], true];
_patient setVariable [VAR_PERIPH_RES, DEFAULT_PERIPH_RES, true];

// IVs
_patient setVariable [QACEGVAR(medical,ivBags), nil, true];

// Damage storage
_patient setVariable [QACEGVAR(medical,bodyPartDamage), [0,0,0,0,0,0], true];

// wakeup needs to be done after achieving stable vitals, but before manually reseting unconc var
if IS_UNCONSCIOUS(_patient) then {
    if (!([_patient] call ACEFUNC(medical_status,hasStableVitals))) then { systemchat "shit"; ERROR_2("fullheal [unit %1][state %2] did not restore stable vitals",_patient,_state); };
    TRACE_1("Waking up",_patient);
    [QACEGVAR(medical,WakeUp), _patient] call CBA_fnc_localEvent;
    _state = GET_SM_STATE(_patient);
    TRACE_1("after WakeUp",_state);
    if IS_UNCONSCIOUS(_patient) then { ERROR_2("fullheal [unit %1][state %2] failed to wake up patient",_patient,_state); };
};

// Generic medical admin
// _patient setVariable [VAR_CRDC_ARRST, false, true]; // this should be set by statemachine transition
// _patient setVariable [VAR_UNCON, false, true]; // this should be set by statemachine transition
_patient setVariable [VAR_HEMORRHAGE, 0, true];
_patient setVariable [VAR_IN_PAIN, false, true];
_patient setVariable [VAR_PAIN_SUPP, 0, true];

// Medication
_patient setVariable [VAR_MEDICATIONS, [], true];

// Reset triage card since medication is reset
_patient setVariable [QACEGVAR(medical,triageCard), [], true];

[_patient] call ACEFUNC(medical_engine,updateDamageEffects);

// Reset damage
_patient setDamage 0;

[QACEGVAR(medical,FullHeal), _patient] call CBA_fnc_localEvent;
_state = GET_SM_STATE(_patient);
TRACE_1("after FullHeal",_state);
