-- KMAutos: publish substantive starter learning content for the three free courses.
-- Run this once in Supabase SQL Editor. Re-running does not duplicate modules or lessons.
-- Modules for Automotive Electrical Fundamentals
insert into public.modules(course_id,title,description,sort_order,published)
select c.id,v.title,v.description,v.n,true from public.courses c cross join (values
 ('Electrical principles','Build a safe foundation in automotive voltage, current and resistance.',1),
 ('Circuit components and wiring','Understand the parts and paths that make vehicle circuits work.',2),
 ('Practical electrical testing','Use a digital multimeter to prove a fault rather than guess.',3)
) v(title,description,n) where c.slug='automotive-electrical-fundamentals'
and not exists(select 1 from public.modules m where m.course_id=c.id and m.sort_order=v.n);
-- Modules for ECU, Sensors & Actuators
insert into public.modules(course_id,title,description,sort_order,published)
select c.id,v.title,v.description,v.n,true from public.courses c cross join (values
 ('Electronic control unit fundamentals','Learn how an ECU receives inputs, processes logic and controls outputs.',1),
 ('Sensors and signal diagnosis','Understand common sensor types, reference supplies and signal checks.',2),
 ('Actuators and control strategies','Explore how modules command motors, solenoids and relays.',3)
) v(title,description,n) where c.slug='ecu-sensors-actuators'
and not exists(select 1 from public.modules m where m.course_id=c.id and m.sort_order=v.n);
-- Modules for Scan Tools & Fault Finding
insert into public.modules(course_id,title,description,sort_order,published)
select c.id,v.title,v.description,v.n,true from public.courses c cross join (values
 ('Diagnostic process and DTCs','Use a repeatable process to understand customer concerns and fault codes.',1),
 ('Live data and test plans','Interpret scan data and choose tests that isolate the cause.',2),
 ('Verification and case studies','Confirm repairs and document evidence-based diagnostic conclusions.',3)
) v(title,description,n) where c.slug='scan-tools-fault-finding'
and not exists(select 1 from public.modules m where m.course_id=c.id and m.sort_order=v.n);

-- Lesson content: each entry is a complete introductory lesson with workshop guidance.
insert into public.lessons(module_id,title,content,duration_minutes,sort_order,published)
select m.id,v.title,v.content,v.minutes,v.n,true
from public.modules m join public.courses c on c.id=m.course_id
join (values
('automotive-electrical-fundamentals',1,'What voltage, current and resistance mean',
'LEARNING OBJECTIVES
Explain voltage, current and resistance, and relate each to a vehicle circuit.

THE THREE CORE IDEAS
Voltage is electrical potential difference: the push that can move charge through a complete circuit. It is measured in volts (V). Current is the flow of electric charge and is measured in amperes (A). Resistance is opposition to current flow and is measured in ohms (Ω).

OHM’S LAW
For a simple resistive circuit: V = I × R. If a 12 V supply is connected across a 6 Ω load, the current is 2 A (12 ÷ 6). Real vehicle circuits include changing loads, electronic controls and wiring losses, so use this relationship as a foundation rather than assuming every circuit is purely resistive.

VEHICLE EXAMPLE
A headlamp needs a complete path from its power source, through protection and control, through the lamp, and back to ground. An open connection stops current. Excessive resistance in a connector can reduce the voltage available to the lamp and create heat.

WORKSHOP CHECK
With a circuit operating, measure voltage across the battery and then across the load. Compare the readings with the manufacturer’s specifications. Never short a battery positive terminal to ground with a meter probe.

KEY TAKEAWAY
Voltage is the push, current is the flow, and resistance opposes the flow. A circuit must be complete for current to flow.',12,1),
('automotive-electrical-fundamentals',1,'Series and parallel circuits',
'LEARNING OBJECTIVES
Recognise series and parallel circuit layouts and predict what happens when a branch opens.

SERIES CIRCUITS
Components are connected in one path. The same current passes through each component. Supply voltage is shared between the loads. If one connection opens, the whole path stops conducting.

PARALLEL CIRCUITS
Loads have separate branches across the supply. Each branch receives approximately the same supply voltage, while total current is the sum of branch currents. An open fault in one branch may leave other branches working.

AUTOMOTIVE EXAMPLES
A simple test lamp in series with a current-limited test circuit can show continuity, but never use an incandescent test lamp on sensitive ECU or airbag circuits. Vehicle lighting commonly uses parallel branches so one lamp failure need not extinguish every lamp.

PRACTICE
Draw a battery, fuse and two lamps. First connect both lamps in series, then redraw them in parallel. Mark the current path and predict which lamp remains lit if one lamp is removed.

KEY TAKEAWAY
Identify the circuit topology before testing. It helps predict whether one failed component should affect one function or several.',10,2),
('automotive-electrical-fundamentals',2,'Fuses, relays and circuit protection',
'PURPOSE OF PROTECTION
A fuse is designed to open a circuit when current exceeds its rating for a sufficient time. It protects wiring from overheating and reduces fire risk. A fuse is not a device to protect a component from every possible fault.

FUSE SELECTION
Always use the specified fuse type and rating. Installing a larger fuse can allow wiring to overheat before the fuse opens. Never bridge a fuse with wire or foil.

RELAYS
A conventional relay uses a low-current coil circuit to switch a separate higher-current contact circuit. Identify the coil and contact terminals from the relay diagram; terminal numbering and internal arrangements must be verified for the specific relay.

DIAGNOSTIC METHOD
If a fuse is blown, do not simply replace it repeatedly. Check the circuit diagram, identify loads on that fuse, inspect for chafed wiring or water ingress, and use an approved current-limited diagnostic method to locate the short.

SAFETY
Disconnect the battery only when the vehicle manufacturer’s procedure requires it. Some systems need memory retention or a prescribed shutdown/wait period.

KEY TAKEAWAY
A fuse protects the circuit wiring. Find the reason it opened before returning the vehicle to service.',12,1),
('automotive-electrical-fundamentals',2,'Grounds and voltage drop',
'WHY GROUNDS MATTER
The ground side is part of the circuit, not an optional connection. Corrosion, loose fasteners or damaged ground straps can add resistance and cause slow cranking, dim lamps, erratic sensors or communication issues.

VOLTAGE DROP
Voltage drop is the voltage used across resistance while current flows. A resistance problem may look normal during an unloaded continuity test but become obvious under operating load.

TESTING
Use a digital multimeter on DC volts. With the circuit operating, measure from battery positive to the load supply terminal to assess the positive-side drop. Measure from the load ground terminal to battery negative to assess the ground-side drop. Compare results with vehicle service information; acceptable limits vary by circuit and manufacturer.

IMPORTANT
A resistance or continuity test is normally performed on a de-energised circuit. Do not measure resistance on a live circuit. Avoid piercing insulation unless an approved repair method is available.

WORKSHOP EXAMPLE
If a starter turns slowly, test battery condition and connections first, then measure positive and ground-side voltage drop while cranking. This is more informative than replacing the starter based only on sound.

KEY TAKEAWAY
Test voltage drop under load to find unwanted resistance in a working circuit.',14,2),
('automotive-electrical-fundamentals',3,'Using a digital multimeter safely',
'BEFORE YOU MEASURE
Inspect the meter, leads and probes. Confirm the lead is in the correct socket and select the correct function and range. The black lead normally goes to COM. The red lead goes to the voltage/ohms socket for voltage and resistance measurements.

VOLTAGE
Connect the meter in parallel with the part of the circuit being checked. Select DC volts for typical vehicle battery and control-circuit measurements. Start on a suitable range if the meter is not auto-ranging.

CURRENT
Current is measured in series, using the correct fused current input and range. An incorrect connection can short the circuit through the meter. For many vehicle parasitic-draw checks, use the manufacturer’s procedure or a suitable current clamp to avoid interrupting modules during sleep.

RESISTANCE AND CONTINUITY
Switch the circuit off and isolate it as required before measuring resistance. Never place an ohmmeter across a powered circuit or an airbag inflator.

PRACTICE
Measure a standalone battery voltage, then measure voltage across a known low-voltage lamp while it is operating. Record the test points, conditions and readings.

KEY TAKEAWAY
Choose the measurement function and connection method before touching the probes to the circuit.',15,1),
('automotive-electrical-fundamentals',3,'A simple no-power diagnostic routine',
'THE SYMPTOM
A vehicle accessory does not operate. Avoid assuming the accessory itself has failed. Begin by confirming the customer’s concern and checking whether other functions are affected.

STEP 1 — VERIFY
Operate the function under the conditions described. Note warning messages, sounds and whether the fault is constant or intermittent.

STEP 2 — CONSULT INFORMATION
Use the correct wiring diagram and service information for the exact vehicle. Identify the fuse, relay, switch/module, load and ground points. Do not rely on wire colour alone.

STEP 3 — CHECK THE SUPPLY
Check the relevant fuse electrically, not only visually. If power is missing, work upstream. If power is present at the load, check the ground side under load.

STEP 4 — PROVE THE FAULT
Use appropriate voltage and voltage-drop tests. Do not bypass safety interlocks or apply battery voltage to an ECU output without an approved test procedure.

STEP 5 — VERIFY THE REPAIR
Repair using the specified terminal, wire gauge, sealing and routing method. Repeat the original operating test and check for related faults.

CASE EXERCISE
A lamp is dim. List three possible causes before testing: low supply voltage, high resistance in the positive path, or high resistance in the ground path. Design one measurement for each possibility.

KEY TAKEAWAY
A good technician follows evidence from symptom to circuit to test result, then verifies the repair.',15,2),

('ecu-sensors-actuators',1,'What an ECU does',
'THE CONTROL LOOP
An electronic control unit (ECU) receives information from sensors and other modules, evaluates the inputs using programmed logic, and commands outputs. It may also communicate with other controllers over a vehicle network.

INPUTS, PROCESSING AND OUTPUTS
Inputs can include temperature, pressure, position, speed and switch states. The ECU checks these against operating conditions and calibration maps. Outputs may operate injectors, ignition coils, relays, solenoids, motors or warning indicators.

POWER AND GROUND FIRST
Before diagnosing a controller, confirm its battery feeds, ignition feeds, grounds and network connections according to the wiring diagram. A module that is not powered correctly cannot be expected to communicate or control reliably.

DIAGNOSTIC CLUES
A communication fault does not automatically prove the ECU is defective. Check battery voltage, fuses, grounds, network wiring, connector condition and whether other modules report the same missing controller.

KEY TAKEAWAY
Treat the ECU as one part of a complete electrical and network system. Prove its supplies and connections before condemning it.',13,1),
('ecu-sensors-actuators',1,'Module communication and CAN basics',
'WHY NETWORKS EXIST
Modern vehicles contain many control modules. A communication network lets them share information without a separate wire for every signal.

CAN OVERVIEW
A typical high-speed Controller Area Network uses CAN High and CAN Low as a differential pair. The voltage behaviour and resistance checks depend on network design and vehicle state. Some vehicles use multiple CAN networks, gateways and other protocols.

SAFE DIAGNOSIS
Use the exact manufacturer wiring diagram. Do not assume every pair of twisted wires is CAN. Do not probe network pins with a test lamp. Resistance checks are made only with the network powered down and isolated as specified by service information.

A SYSTEMATIC APPROACH
Scan all modules and record which ones communicate. If several modules on one network are missing, consider a shared power, ground, gateway or network fault. If one module is missing, inspect its local supplies, connector and branch wiring.

KEY TAKEAWAY
Network diagnosis begins with a complete vehicle scan and a correct network topology, not random wire probing.',14,2),
('ecu-sensors-actuators',2,'Sensor types and reference voltage',
'COMMON SENSOR TYPES
Vehicles use thermistors for temperature, pressure transducers, Hall-effect and magnetoresistive speed/position sensors, potentiometers and switches. Their signal types and test methods differ.

REFERENCE SUPPLY
Some sensors receive a regulated reference voltage from a controller, often 5 V, but the correct value and shared circuits are vehicle-specific. A shorted sensor or harness can pull down a shared reference supply and affect several sensors.

TEST PLAN
Identify the sensor type from service information. Check supply, ground and signal at the correct connector pins. Compare readings with manufacturer specifications and operating conditions. Use a scope where a changing waveform is needed.

DO NOT GUESS
Never apply battery voltage to a 5 V reference or signal pin. Avoid resistance tests on powered electronic circuits.

CASE
If several unrelated sensors show implausible low readings, investigate a shared reference or ground before replacing each sensor individually.

KEY TAKEAWAY
Know what type of sensor you are testing and what its expected signal should look like.',14,1),
('ecu-sensors-actuators',2,'Reading sensor live data',
'WHAT LIVE DATA SHOWS
A scan tool displays values calculated or reported by control modules. These values can reveal whether a signal is plausible, stable and responsive to a changing condition.

CONTEXT IS ESSENTIAL
Check units, engine temperature, engine speed, load, throttle position and other relevant conditions. A coolant temperature reading after an overnight cold soak should be reasonably close to ambient temperature, subject to sensor and display tolerances.

COMPARE, DO NOT GUESS
Compare related values and manufacturer specifications. For example, compare accelerator pedal tracks where the vehicle uses redundant sensors. Their relationship matters more than one isolated number.

GRAPHING
Graphing can reveal dropouts, spikes and slow response that are difficult to see in a static display. Capture data during the condition that creates the complaint.

KEY TAKEAWAY
Live data is evidence. Interpret it in operating context and verify suspicious values with an independent test.',13,2),
('ecu-sensors-actuators',3,'How actuators are controlled',
'ACTUATOR EXAMPLES
Common outputs include relays, solenoids, injectors, ignition coils, throttle motors, cooling fans and electronic valves. Some are switched on the power side; others are controlled on the ground side or by pulse-width modulation.

PWM
Pulse-width modulation rapidly switches a driver on and off. The duty cycle changes the average energy delivered to a load. A multimeter may show an averaged value; an oscilloscope is better for viewing the actual waveform.

ACTIVE TESTS
A scan tool may command an actuator while the vehicle is stationary. Follow all safety precautions: fans can start unexpectedly, throttle plates can move, and fuel or ignition systems may be hazardous.

DIAGNOSIS
Confirm power supply, ground/driver control, wiring integrity and load condition using the specified procedure. A command shown on the scan tool does not prove the actuator physically moved.

KEY TAKEAWAY
Separate the command, electrical output and mechanical result when diagnosing an actuator.',14,1),
('ecu-sensors-actuators',3,'A structured sensor-to-actuator fault trace',
'SCENARIO
A vehicle has poor throttle response and stores a throttle-related fault. Do not replace the throttle body from the code description alone.

GATHER EVIDENCE
Record all DTCs, freeze-frame data, warning messages and relevant live data. Check battery voltage and technical service information.

CHECK INPUTS
Compare accelerator pedal position tracks and throttle position feedback. Look for smooth, correlated changes as the pedal is moved with the engine off, following the manufacturer procedure.

CHECK OUTPUT AND MECHANICS
Inspect throttle body wiring and connector condition. Use the approved active test if permitted. Check for binding, contamination or mechanical damage only as directed by service information.

REPAIR AND VERIFY
Carry out the prescribed repair, clear codes only after recording them, perform any required adaptation, then repeat the original test and road test if safe.

KEY TAKEAWAY
A fault code identifies a detected condition or circuit. The diagnostic process identifies the root cause.',16,2),

('scan-tools-fault-finding',1,'A repeatable diagnostic workflow',
'START WITH THE CUSTOMER
Record the exact symptom, when it occurs, environmental conditions and recent repairs. Confirm the concern before connecting tools.

SCAN THE WHOLE VEHICLE
Use a compatible scan tool to identify modules and record all DTCs. Save freeze-frame or event data before clearing anything. Note communication faults and low-voltage codes.

PRIORITISE
Look for shared causes, power supply issues, network faults and related codes. A group of codes may be caused by one underlying problem.

TEST PLAN
Use service information to choose a test that can confirm or reject a cause. Avoid replacing parts based on a code description or internet guess.

VERIFY
After repair, clear codes when appropriate, repeat the operating conditions and rescan. Confirm the customer’s original complaint is resolved.

KEY TAKEAWAY
A diagnostic workflow turns symptoms and codes into a testable plan and a verified repair.',13,1),
('scan-tools-fault-finding',1,'Understanding DTCs and freeze-frame data',
'WHAT A DTC MEANS
A diagnostic trouble code records that a module detected a condition outside its monitoring criteria. It does not necessarily identify the failed component.

CODE FAMILIES
Powertrain, body, chassis and network codes can point to different systems. Manufacturer-specific definitions and subcodes may add essential detail. Always use the correct code description for the vehicle.

FREEZE FRAME
Freeze-frame data captures selected operating conditions when a fault was recorded. Review engine speed, load, temperature, voltage and other available parameters to understand the event.

BEFORE CLEARING
Save a complete scan report and note status (current, pending, history) where available. Clearing codes too early can erase useful diagnostic evidence and readiness information.

KEY TAKEAWAY
Treat a DTC as a clue about what the controller detected, not a parts replacement instruction.',12,2),
('scan-tools-fault-finding',2,'Interpreting live data and choosing tests',
'SELECT RELEVANT PIDS
Do not display every parameter at once. Choose data directly related to the complaint and understand each parameter’s units, update rate and operating conditions.

LOOK FOR RELATIONSHIPS
Compare commanded and actual values, paired sensors, bank-to-bank readings and values before and after a system changes state.

BUILD A HYPOTHESIS
Write down what the data suggests and what test would prove it. Example: if a temperature value is implausible after a cold soak, compare it with ambient temperature and test the sensor circuit using the wiring diagram.

CONFIRM INDEPENDENTLY
Use a multimeter, pressure gauge, smoke machine or oscilloscope only where the service procedure calls for it. Scan data may be calculated, filtered or substituted by a module.

KEY TAKEAWAY
Choose a test because it distinguishes between possible causes, not because the tool makes it easy to run.',15,1),
('scan-tools-fault-finding',2,'Building a diagnostic test plan',
'DEFINE THE FAILURE
Write a clear statement of the symptom and the conditions required to reproduce it.

LIST POSSIBLE CAUSES
Group causes into power/ground, wiring/connectors, input signal, output/load, mechanical condition and software/configuration.

RANK TESTS
Start with checks that are safe, quick and highly informative. Follow OEM service information and technical bulletins. Avoid unnecessary parts substitution.

RECORD RESULTS
For every test, record the condition, test points, equipment, expected result and actual result. A result without test conditions is difficult to interpret.

DECISION POINT
Each test should lead to a next step: if the result is within specification, move to the next branch; if not, isolate the affected circuit or component.

KEY TAKEAWAY
A written test plan prevents repeated checks and makes the diagnosis explainable to another technician.',14,2),
('scan-tools-fault-finding',3,'Confirming a repair and closing the case',
'REPAIR QUALITY
Use the correct repair method, terminals, seals, torque values, software procedure and safety precautions. Do not leave temporary bypasses or unsecured wiring.

POST-REPAIR CHECK
Repeat the original test under the same conditions. Confirm the system operates correctly and that no new DTCs have appeared.

ROAD TEST AND ADAPTATION
Perform road tests, relearns or calibrations only when required and safe. Observe warnings and live data during the verification process.

DOCUMENTATION
Record the customer concern, DTCs, evidence, tests performed, root cause, repair and verification result. This supports quality control and future diagnosis.

KEY TAKEAWAY
A repair is not complete until the original fault has been verified as resolved.',12,1),
('scan-tools-fault-finding',3,'Case study: intermittent no-start',
'CUSTOMER CONCERN
The engine intermittently cranks but does not start. The fault is more common after the vehicle has been parked overnight.

INITIAL EVIDENCE
Confirm battery condition and cranking speed. Scan all modules and save codes and freeze-frame data. Check whether engine speed is reported during cranking.

FORM A TEST PLAN
If engine speed is absent, follow the crankshaft sensor and circuit diagnostic procedure. If engine speed is present, continue with the manufacturer’s fuel, ignition, synchronisation and immobiliser checks as appropriate.

CAPTURE THE INTERMITTENT EVENT
Use graphing or an oscilloscope to capture the relevant signal while the fault is present. Inspect connectors, harness routing, grounds and evidence of moisture or heat damage.

CONCLUSION
Do not replace a crank sensor solely because the engine will not start. Prove whether the signal is missing, distorted, or present but not accepted by the control system.

KEY TAKEAWAY
Intermittent faults require capturing evidence during the failure, not guessing from symptoms alone.',16,2)
) as v(course_slug,module_order,title,content,minutes,n)
on c.slug=v.course_slug and m.course_id=c.id and m.sort_order=v.module_order
where not exists(select 1 from public.lessons old where old.module_id=m.id and old.sort_order=v.n);
-- Publish the three starter courses and their newly authored modules/lessons.
update public.courses set published=true where slug in ('automotive-electrical-fundamentals','ecu-sensors-actuators','scan-tools-fault-finding');
