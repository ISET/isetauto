'''
generate vehicle positions for isetauto using sumo
Jiayue, 2022
'''
import os
import sys
import optparse

if 'SUMO_HOME' in os.environ:
    tools = os.path.join(os.environ['SUMO_HOME'], 'tools')
    assign = os.path.join(tools, 'assign')
    sys.path.append(tools)
    sys.path.append(assign)
else:
    sys.exit("please declare environment variable 'SUMO_HOME'")
import randomTrips
import generateJSON
def get_options(args=None):
    # add options for matlab calls
    optParser = optparse.OptionParser()
    # for example "city_cross_4lanes";
    optParser.add_option("--randomseed", type="int", default=1127, dest="seed")
    optParser.add_option("--root", default='/home/xjy/Documents/ISET/sumo/out_dir', dest='root_dir',
                         help='root directory for xodr files and sumo files to be generated')
    optParser.add_option("-n", "--opendrive-net", dest="net_xodr", default="road_001.xodr",
                         help="define the path of opendrive net file")
    optParser.add_option("-x", "--net-xml", dest="net_xml",default ="net.net.xml",
                         help="define the path of xml net file")                         
    optParser.add_option("-f", "--fcd-xml", dest="fcd",default="fcd.xml",
                         help="define the path of xml net file")
    optParser.add_option("-e", "--end", type="float",
                         default=100, help="end time (default 100)")
    optParser.add_option("-t", "--trip", dest="tripFile",
                         default="trips.trips.xml", help="define trip file name")
    optParser.add_option("-r", "--route-files", dest="route_xml",
                         default="routes.rou.xml", help="define trip file name")
    optParser.add_option("-v", "--vehicle-class",
                         dest="vClass", default="car", help="define vehicle type")
    optParser.add_option("-p", "--period", dest="period", type="float", default=1.0,
                         help="period of generating a vehicle in a node in each time step")
    optParser.add_option("--max-num-vehicles", default=15, dest='max_num_vehicles',
                         help="maximum number of vehicles on at the same time")
    (options, args) = optParser.parse_args(args=args)


    return options



def main(opt):
    sumo_dir= os.path.join(opt.root_dir,'sumo')

    if os.path.isdir(sumo_dir):
        print('exists')

    else:
        os.makedirs(sumo_dir)


    net_xodr = os.path.join(opt.root_dir,opt.net_xodr)
    net_xml= os.path.join(sumo_dir,opt.net_xml)
    trips_xml = os.path.join(sumo_dir, opt.tripFile)
    route_xml=os.path.join(sumo_dir, opt.route_xml)
    max_v = str(opt.max_num_vehicles)
    fcd_xml=os.path.join(sumo_dir,opt.fcd)
    fcd_json=os.path.join(sumo_dir,opt.fcd.rstrip('.xml'))
    cfg=os.path.join(sumo_dir,'test.sumocfg')

    nconv_cmd= 'netconvert --opendrive '+net_xodr+' -o '+net_xml+' --offset.disable-normalization'
    os.system(nconv_cmd)


    trip_options=[
    '-n',net_xml,
    '-e',opt.end,
    '-o',trips_xml,
    '-p',opt.period,
    '-s',opt.seed,
    #'--vehicle-class','bus',
    '--allow-fringe'
    ]
    randomTrips.main(randomTrips.get_options(trip_options))


    dua_cmd = 'duarouter --route-files '+trips_xml+' --net-file '+net_xml+' --output-file '+route_xml
    os.system(dua_cmd)


    simu_cmd='sumo --fcd-output '+fcd_xml+' -n '+net_xml+' -r '+route_xml+' --max-num-vehicles '+max_v
    os.system(simu_cmd)




    generateJSON.main(generateJSON.get_options(['-f',fcd_xml,'-o',fcd_json]))
    # json_cmd='python generateJSON.py -f '+fcd_xml+' -o '+fcd_json
    # os.system(json_cmd)

    

if __name__ == "__main__":
    if not main(get_options()):
        sys.exit(1)

# visulize vehicle positions

# root_dir='D:\\tmp\\'
# fcd_xml=os.path.join(root_dir,'fcd1.xml')

# import xml.dom.minidom as xmldom
# import matplotlib.pyplot as plt
# import numpy as np
# from math import pi
# def pos_vis(fcd_xml,time):
#     xml_file= xmldom.parse(fcd_xml)
#     eles = xml_file.documentElement
#     vehicles=eles.getElementsByTagName('timestep')[time].getElementsByTagName('vehicle')
#     x=[]
#     y=[]
#     id=[]
#     ang=[]
#     for vhc in vehicles:
#         v_x,v_y = vhc.getAttribute('x'),vhc.getAttribute('y')
#         v_id = vhc.getAttribute('id')
#         v_ang = vhc.getAttribute('angle')
#         x.append(float(v_x))
#         y.append(float(v_y))
#         id.append(v_id)
#         ang.append(float(v_ang))
#     print(id)
#     print(x,y)
#     x=np.asarray(x)
#     y=np.asarray(y)
#     ang = np.asarray(ang)
#     x1 = x + np.sin(ang*pi/180)
#     y1 = y+np.cos(ang*pi/180)
#     x_plt,y_plt = np.hstack((x,x1)),np.hstack((y,y1))
#     c = ['#1f77b4']*len(x) + ['#ff7f0e']*len(x)
#     plt.scatter(x_plt,y_plt,c=c)
#     plt.gca().set_aspect('equal')
#     #plt.show()
#     plt.savefig(os.path.join(sumo_dir,'time_'+str(time)+'.png'))
#     return id,x,y,ang

# id,x,y,ang=pos_vis(fcd_xml,50)
