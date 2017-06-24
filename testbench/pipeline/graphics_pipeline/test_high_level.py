import numpy as np

params = {	't_x': -7.6, 't_y': -3.5, 't_z': 25,
		  	'cos_pitch': 1, 'cos_yaw': 0.5, 'cos_roll': 0.5,
			'sen_pitch': 0, 'sen_yaw': 0.866, 'sen_roll': 0.866,
		  	's_x': -3.75, 's_y': 14.0, 's_z': -3.5,
			'c_x': 13.0, 'c_y': 4.0, 'c_z': -8.0,
			'X': -21, 'Y': 7.5, 'Z': -5.0,
			'd_f': 7.0
		}

T = np.matrix([[1, 0, 0, params['t_x']],
			   [0, 1, 0, params['t_y']],
			   [0, 0, 1, params['t_z']],
			   [0, 0, 0, 1]])

R_x = np.matrix([[1, 0, 0, 0],
			     [0, params['cos_pitch'], -params['sen_pitch'], 0],
			     [0, params['sen_pitch'],  params['cos_pitch'], 0],
	  		     [0, 0, 0, 1]])
  
R_y = np.matrix([[params['cos_yaw'], 0, params['sen_yaw'], 0],
			     [0, 1, 0, 0],
			     [-params['sen_yaw'], 0, params['cos_yaw'], 0],
	  		     [0, 0, 0, 1]])

R_z = np.matrix([[params['cos_roll'], -params['sen_roll'], 0, 0],
			     [params['sen_roll'],  params['cos_roll'], 0, 0],
			     [0, 0, 1, 0],
	  		     [0, 0, 0, 1]])

S = np.matrix([[params['s_x'], 0, 0, 0],
			   [0, params['s_y'], 0, 0],
			   [0, 0, params['s_z'], 0],
			   [0, 0, 0, 1]])

P = np.matrix([[params['X']],
			   [params['Y']],
			   [params['Z']],
			   [1]])

World = T*R_y*R_x*R_z*S
Points_world = World*P
print "Las coordenadas de los puntos en el mundo es:\nX:", Points_world[0,0], "\nY:",Points_world[1,0],"\nZ:",Points_world[2,0]

P_c = np.matrix([	[Points_world[0,0]-params['c_x']],
			   		[Points_world[1,0]-params['c_y']],
			   		[Points_world[2,0]-params['c_z']],
			   		[1]])
print "Las coordenadas de los puntos en el mundo respecto a la camara:\nX:", P_c[0,0], "\nY:",P_c[1,0],"\nZ:",P_c[2,0]

Points_2D = np.matrix([ [-P_c[0,0]*params['d_f']/P_c[2,0] ],
			   			[ P_c[1,0]*params['d_f']/P_c[2,0] ]])

print "La coordenada en X de la proyeccion es:", Points_2D[0,0], "y en Y es:" ,Points_2D[1,0]
