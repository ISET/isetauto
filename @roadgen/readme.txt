use sumo for isetauto following these steps:
1. install isetauto, isetcam, iset3d, pbrt-v4
2. replace paths in the demos with your own
3. run s_recipeMatCreate.m to prepare assets
4. install sumo
5. put sumo4iset.py and generateJSON.py in your sumo/tools directory
6. run t_sumo_demo.m

parameters for using sumo:
sumo	true/false
	--true when using sumo
carperiod	--Generate vehicles with equidistant departure times and period=FLOAT (default 1.0), ranging from 0 to 1.0
carmaxnum	--maximum number of cars at a time
randomseed	--randomseed for reproduction of vehicle positions

Car only now, other vehicles under development...

--by Jiayue, 2022
