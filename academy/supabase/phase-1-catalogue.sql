-- KMAutos Academy Phase 1: 18 subject families x 3 learning levels = 54 pathways.
-- Run once in Supabase SQL Editor. Safe to re-run: upserts by unique slug.
with subjects(subject_slug,subject_title,description,sort_order) as (
 values
 ('automotive-foundations','Automotive Foundations','Vehicle systems, workshop safety, tools, service information and diagnostic process.',1),
 ('electrical-electronics','Electrical & Electronics','Voltage, current, resistance, circuit theory, components and safe measurement.',2),
 ('advanced-automotive-electrical','Advanced Automotive Electrical','Wiring diagrams, voltage drop, parasitic draw, circuit faults and networked circuits.',3),
 ('vehicle-networks-modules-software','Vehicle Networks, Modules & Software','ECU architecture, BCM, TCM, CAN, LIN, programming and module communication.',4),
 ('adas-active-safety','ADAS & Active Safety','Driver assistance sensors, calibration concepts, radar, camera and safety systems.',5),
 ('engine-mechanical','Engine Mechanical Systems','Engine construction, lubrication, cooling, timing, compression and mechanical testing.',6),
 ('engine-performance-emissions','Engine Performance & Emissions','Fuel, ignition, air management, emissions, sensor data and performance diagnosis.',7),
 ('integrated-vehicle-diagnostics','Integrated Vehicle Diagnostics','Systematic diagnosis, scan data, DTC strategy, test plans and verification.',8),
 ('hvac-thermal-management','HVAC & Thermal Management','Climate control, refrigeration cycle, sensors, actuators and thermal systems.',9),
 ('manual-drivetrain-axles-awd','Manual Drivetrain, Axles & AWD','Clutches, manual gearboxes, differentials, shafts and all-wheel drive.',10),
 ('automatic-transmissions','Automatic Transmissions','Hydraulic and electronic controls, solenoids, adaptations and transmission diagnosis.',11),
 ('steering-suspension-tires','Steering, Suspension & Tires','Steering geometry, EPS, suspension, wheel alignment and tire systems.',12),
 ('brake-systems','Brake Systems','Hydraulic brakes, ABS, stability control, sensors and electronic parking brakes.',13),
 ('alternative-fuels-powertrains','Alternative Fuels & Emerging Powertrains','Alternative fuels, energy systems, safety and emerging vehicle technologies.',14),
 ('diesel-engine-systems','Diesel Engine Systems','Diesel combustion, injection, common rail, turbocharging and aftertreatment.',15),
 ('hybrid-electric-vehicles','Hybrid & Electric Vehicles','High-voltage safety, battery systems, inverters, motors and hybrid control.',16),
 ('body-structure-collision','Body, Structure & Collision','Body electronics, restraints, airbag systems, structural awareness and post-repair checks.',17),
 ('service-operations-business','Service Operations & Automotive Business','Workshop process, customer communication, estimates, quality and business practice.',18)
), levels(level,level_slug,level_order,objective) as (
 values
 ('Foundation','foundation',1,'Understand core principles, identify components and explain how systems operate safely.'),
 ('Technician','technician',2,'Test components, interpret measurements and follow structured diagnostic procedures.'),
 ('Advanced','advanced',3,'Analyse complex faults, evaluate evidence and validate repair strategies.')
)
insert into public.courses(title,slug,description,level,published,sort_order)
select s.subject_title || ' — ' || l.level,
       s.subject_slug || '-' || l.level_slug,
       s.description || ' ' || l.objective,
       l.level,true,(s.sort_order * 10)+l.level_order
from subjects s cross join levels l
on conflict(slug) do update set
 title=excluded.title,
 description=excluded.description,
 level=excluded.level,
 published=true,
 sort_order=excluded.sort_order;

-- Align the original starter courses with the Phase 1 level names.
update public.courses set level='Technician' where slug='ecu-sensors-actuators';
update public.courses set level='Advanced' where slug='scan-tools-fault-finding';
