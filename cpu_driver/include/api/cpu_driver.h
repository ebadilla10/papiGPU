#include <stdio.h>
#include <stdbool.h>
#include <api/types/papiGPU_types.h>

#define DEBUGLOG // To print all information from API execution
#define PORTNAME "/dev/ttyUSB1"

/* Rotate angles in radians */
struct papiGPU_rotate_angles{
  gpu_angle row;
  gpu_angle pitch;
  gpu_angle yaw;
};

/* 3-Dimensional scale constants */
struct papiGPU_scales{
  gpu_scale sx;
  gpu_scale sy;
  gpu_scale sz;
};

/* 3-Dimensional translation constants */
struct papiGPU_translation{
  gpu_translation tx;
  gpu_translation ty;
  gpu_translation tz;
};

/* 3-Dimensional vertex values */
struct papiGPU_vertex{
  gpu_vertex x;
  gpu_vertex y;
  gpu_vertex z;
};


/***********************
  Initialize the papiGPU

INPUT   portname[] is a string with the portname
OUTPUT *state      is the papiGPU general state
RETURN  0          if function was succesful
        errno      if function failed
***********************/
int papiGPU_initialize(gpu_portname         portname[],
                       enum papiGPU_states *state);


// FIXME: The camara could need to set transformation parameters
/******************
  Create the camara

INPUT   cam_vertex  are vertex values of camara
INPUT   fp_distance is the distances of focal point
OUTPUT *state       is the papiGPU general state
RETURN  0           if function was succesful
        errno       if function failed
******************/
int papiGPU_create_camara(struct papiGPU_vertex  cam_vertex,
                          gpu_focal_point        fp_distance,
                          enum papiGPU_states   *state);


/**********************************
  Create an object and keep it open

INPUT   enable      is enable for object projection
INPUT   rota_angles are the rotate angles
INPUT   scales      are the scale constants
INPUT   translation are the translation constants
OUTPUT *object_id   is the object ID
OUTPUT *state       is the papiGPU general state
RETURN  0           if function was succesful
        errno       if function failed
**********************************/
int papiGPU_create_object(bool                          enable,
                          struct papiGPU_rotate_angles  rota_angles,
                          struct papiGPU_scales         scales,
                          struct papiGPU_translation    translation,
                          gpu_object_id                *object_id,
                          enum papiGPU_states          *state);


/*******************************
  Insert a vertex in open object

INPUT   object_id is the open object ID
INPUT   vertex    are the vertex values
OUTPUT *vertex_id is the vertex ID
OUTPUT *state     is the papiGPU general state
RETURN  0         if function was succesful
        errno     if function failed
*******************************/
int papiGPU_insert_vertex(gpu_object_id          object_id,
                          struct papiGPU_vertex  vertex,
                          gpu_obj_vertex_id     *vertex_id,
                          enum papiGPU_states   *state);


/*****************
  Close the object

INPUT   object_id is the open object ID
OUTPUT *state     is the papiGPU general state
RETURN  0         if function was succesful
        errno     if function failed
*****************/
int papiGPU_close_object(gpu_object_id        object_id,
                         enum papiGPU_states *state);


/**********************************************
  Change the transformation matrix of an object

INPUT   object_id   is the open object ID
INPUT   rota_angles are the rotate angles
INPUT   scales      are the scale constants
INPUT   translation are the translation constants
OUTPUT *state       is the papiGPU general state
RETURN  0           if function was succesful
        errno       if function failed
**********************************************/
int papiGPU_change_transf_matrix(gpu_object_id                object_id,
                                 struct papiGPU_rotate_angles rota_angles,
                                 struct papiGPU_scales        scales,
                                 struct papiGPU_translation   translation,
                                 enum papiGPU_states         *state);


/*************************************
  Refresh the all parameter in papiGPU

OUTPUT *state is the papiGPU general state
RETURN  0     if function was succesful
        errno if function failed
*************************************/
int papiGPU_refresh(enum papiGPU_states *state);


/* TODO: Missing functions - For next versions
int papiGPU_color_vertex();
int papiGPU_remove_vertex();
int papiGPU_remove_object();
int papiGPU_uninitialize();
*/
