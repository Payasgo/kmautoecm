-- KMAutos curriculum taxonomy: 18 subject families x 3 learning levels.
-- Safe to run once in Supabase SQL Editor after the new curriculum page is deployed.
create table if not exists public.course_categories (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 slug text not null unique,
 description text not null default '',
 sort_order integer not null default 0,
 created_at timestamptz not null default now()
);
alter table public.courses add column if not exists category_id uuid references public.course_categories(id) on delete set null;
alter table public.course_categories enable row level security;
drop policy if exists "Authenticated users read course categories" on public.course_categories;
create policy "Authenticated users read course categories" on public.course_categories for select to authenticated using (true);
insert into public.course_categories(title,slug,description,sort_order) values
('Automotive Foundations','automotive-foundations','Vehicle systems, workshop safety, tools, service information and diagnostic process.',1),
('Electrical & Electronics Fundamentals','electrical-electronics','Voltage, current, resistance, circuit theory, components and safe measurement.',2),
('Advanced Automotive Electrical','advanced-automotive-electrical','Wiring diagrams, voltage drop, parasitic draw, circuit faults and networked circuits.',3),
('Vehicle Networks, Modules & Software','vehicle-networks-modules-software','ECU architecture, BCM, TCM, CAN, LIN, programming and module communication.',4),
('ADAS & Active Safety','adas-active-safety','Driver assistance sensors, calibration concepts, radar, camera and safety systems.',5),
('Engine Mechanical Systems','engine-mechanical','Engine construction, lubrication, cooling, timing, compression and mechanical testing.',6),
('Engine Performance & Emissions','engine-performance-emissions','Fuel, ignition, air management, emissions, sensor data and performance diagnosis.',7),
('Integrated Vehicle Diagnostics','integrated-vehicle-diagnostics','Systematic diagnosis, scan data, DTC strategy, test plans and verification.',8),
('HVAC & Thermal Management','hvac-thermal-management','Climate control, refrigeration cycle, sensors, actuators and thermal systems.',9),
('Manual Drivetrain, Axles & AWD','manual-drivetrain-axles-awd','Clutches, manual gearboxes, differentials, shafts and all-wheel drive.',10),
('Automatic Transmissions','automatic-transmissions','Hydraulic and electronic controls, solenoids, adaptations and transmission diagnosis.',11),
('Steering, Suspension & Tires','steering-suspension-tires','Steering geometry, EPS, suspension, wheel alignment and tire systems.',12),
('Brake Systems','brake-systems','Hydraulic brakes, ABS, stability control, sensors and electronic parking brakes.',13),
('Alternative Fuels & Emerging Powertrains','alternative-fuels-powertrains','Alternative fuels, energy systems, safety and emerging vehicle technologies.',14),
('Diesel Engine Systems','diesel-engine-systems','Diesel combustion, injection, common rail, turbocharging and aftertreatment.',15),
('Hybrid & Electric Vehicles','hybrid-electric-vehicles','High-voltage safety, battery systems, inverters, motors and hybrid control.',16),
('Body, Structure & Collision','body-structure-collision','Body electronics, restraints, airbag systems, structural awareness and post-repair checks.',17),
('Service Operations & Automotive Business','service-operations-business','Workshop process, customer communication, estimates, quality and business practice.',18)
on conflict(slug) do nothing;
-- Create unpublished pathway shells. They stay hidden from students until lesson content is authored and reviewed.
insert into public.courses(title,slug,description,level,sort_order,category_id,published)
select c.title || ' — ' || l.level || ' Level',
       c.slug || '-' || lower(l.level),
       c.description || ' ' || l.outcome,
       l.level,
       c.sort_order * 10 + l.level_order,
       c.id,
       false
from public.course_categories c
cross join (values
 ('Foundation','Understand core principles and identify system components.',1),
 ('Technician','Test components, interpret measurements and follow diagnostic procedures.',2),
 ('Advanced','Analyse complex faults, evaluate evidence and validate repair strategies.',3)
) as l(level,outcome,level_order)
on conflict(slug) do nothing;
-- Link the original starter courses into the relevant taxonomy categories.
update public.courses set category_id=(select id from public.course_categories where slug='electrical-electronics'), level='Foundation'
where slug='automotive-electrical-fundamentals';
update public.courses set category_id=(select id from public.course_categories where slug='vehicle-networks-modules-software'), level='Technician'
where slug='ecu-sensors-actuators';
update public.courses set category_id=(select id from public.course_categories where slug='integrated-vehicle-diagnostics'), level='Advanced'
where slug='scan-tools-fault-finding';
