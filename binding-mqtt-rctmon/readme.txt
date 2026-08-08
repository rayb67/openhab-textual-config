# registry details
# https://rctclient.readthedocs.io/en/latest/inverter_registry.html#power-mng

power_mng.battery_type
"Lead-acid Powerfit" = 0x00
"Li-Ion Akesol" = 0x01
"Laukner" = 0x02
"Li-Ion RCT Power" = 0x03
"Li-Ion Zach" = 0x04
"No battery" = 0x05
"Power loop 200 V" = 0x06
"BYD D-BOX H" = 0x07

power_mng.force_inv_class
Change inverter class. 
"take from serial number" = 0x00
"power inverter" = 0x01
"power storage" = 0x02

power_mng.soc_strategy
SOC target selection. ENUM values: 
"SOC target = SOC" = 0x00
"Constant" = 0x01
"External" = 0x02
"Middle battery voltage" = 0x03
"Internal" = 0x04
"Schedule" = 0x05

prim_sm.state
Inverter status. ENUM values: 
"Standby" = 0x00
"Initialization" = 0x01
"Standby" = 0x02
"Efficiency (debug state)" = 0x03
"Insulation check" = 0x04
"Island check (decide if grid or island mode)" = 0x05
="Power check (check if enough energy is available to start)" = 0x06
"Symmetry (DC link alignment)" = 0x07
"Relais test" = 0x08
"Grid passive (inverter has power from the grid, not synchronized" = 0x09
"Prepare Bat Passive" = 0x0A
"Battery Passive (inverter not connected to grid, powered by battery)" = 0x0B
"H/W check (start-preparation)" = 0x0C
"Feed in" = 0x0D

